from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from transformers import ViTImageProcessor, ViTForImageClassification
from fastapi.responses import StreamingResponse
from PIL import Image
import io
import torch
import requests
from io import BytesIO

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict it to specific domains instead of "*"
    allow_credentials=True,
    allow_methods=["*"],  # You can restrict to specific methods like ['GET', 'POST']
    allow_headers=["*"],  # You can restrict to specific headers like ['Content-Type']
)

# Load model and image processor
model_name_or_path = "vit-base-avengers-v1"
image_processor = ViTImageProcessor.from_pretrained(model_name_or_path)
model = ViTForImageClassification.from_pretrained(model_name_or_path)

# Store the result for later retrieval
classification_result = None


@app.post("/classify/")
async def classify_image(file: UploadFile = File(...)):
    global classification_result

    image_data = await file.read()
    image = Image.open(io.BytesIO(image_data))

    # Process the image for the model
    inputs = image_processor(images=image, return_tensors="pt")

    # Run the image through the model
    with torch.no_grad():
        outputs = model(**inputs)

    # Get predicted class
    logits = outputs.logits
    predicted_class_idx = logits.argmax(-1).item()
    classification_result = model.config.id2label[predicted_class_idx]

    return {"status": "Image classified successfully"}


@app.get("/get_classification/")
async def get_classification():
    global classification_result

    if classification_result:
        return {"predicted_class": classification_result}
    else:
        return {"error": "No classification result available yet"}


@app.get("/stream/")
async def stream_camera():
    # This could be modified to stream the camera images
    return StreamingResponse(  # Handle streaming from camera
        generate_images(), media_type="multipart/x-mixed-replace; boundary=frame"
    )


def generate_images():
    while True:
        frame = capture_frame_from_camera()
        if frame:
            yield (b"--frame\r\n" b"Content-Type: image/jpeg\r\n\r\n" + frame + b"\r\n")
        else:
            print("Failed to capture frame")


def capture_frame_from_camera():
    # This is where you configure the Arduino's endpoint
    arduino_ip = "http://<ARDUINO_IP_ADDRESS>"
    camera_endpoint = f"{arduino_ip}/capture"

    try:
        # Send a GET or POST request to Arduino to capture the frame
        response = requests.get(camera_endpoint)

        # Check if the request was successful
        if response.status_code == 200:
            # Return the image bytes for streaming
            return response.content
        else:
            raise Exception(
                f"Failed to capture frame. Status code: {response.status_code}"
            )

    except Exception as e:
        print(f"Error capturing frame from camera: {e}")
        return None
