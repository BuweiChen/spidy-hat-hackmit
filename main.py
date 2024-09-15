from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from transformers import ViTImageProcessor, ViTForImageClassification
from fastapi.responses import StreamingResponse
from PIL import Image
import io
import torch
import requests
import asyncio
import pygame
from contextlib import asynccontextmanager


app = FastAPI()

# Initialize pygame mixer for music playback
pygame.mixer.init()

# CORS Middleware to allow requests from other origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods
    allow_headers=["*"],  # Allow all headers
)

# Load the model and image processor
model_name_or_path = "vit-base-avengers-v1"
image_processor = ViTImageProcessor.from_pretrained(model_name_or_path)
model = ViTForImageClassification.from_pretrained(model_name_or_path)

# Global state to track classification result and song status
classification_result = None
is_song_playing = False

# Character-to-mp3 mapping
character_to_song = {
    "Iron Man": "Iron_Man.mp3",
    "Captain America": "Captain_America.mp3",
    "Thor": "Thor.mp3",
    "Spider Man": "Spider_Man.mp3",
    "Docter Strage": "Docter_Strage.mp3",
    "Black Panther": "Black_Panther.mp3",
    "Ant Man": "Ant_Man.mp3",
    "Captain Marvel": "Captain_Marvel.mp3",
    "Hulk": "Hulk.mp3",
    "Black Widow": "Black_Widow.mp3",
    "Hawkeye Avengers": "Hawkeye_Avengers.mp3",
    "Scarlet Witch": "Scarlet_Witch.mp3",
    "Vision Avengers": "Vision_Avengers.mp3",
    "Bucky Barnes": "Bucky_Barnes.mp3",
    "Falcon Avengers": "Falcon_Avengers.mp3",
    "Loki": "Loki.mp3",
}


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


@app.get("/is_song_playing/")
async def is_song_playing_endpoint():
    global is_song_playing
    if is_song_playing:
        return {"status": "Theme song is currently playing"}
    else:
        return {"status": "No theme song is playing"}


# Function to play the song using pygame
def play_song(song_file):
    pygame.mixer.music.load(song_file)  # Load the mp3 file
    pygame.mixer.music.play()  # Play the song


# Background task to periodically check classification and play song
async def check_for_character_and_play_song():
    global classification_result, is_song_playing

    while True:
        if classification_result and not is_song_playing:
            character = classification_result

            # Check if the recognized character has a theme song
            if character in character_to_song:
                song_file = character_to_song[character]
                is_song_playing = True

                print(f"Playing {song_file} for 10 seconds...")
                # Play the song (for 10 seconds)
                play_song(song_file)
                await asyncio.sleep(10)  # Wait for 10 seconds while the song plays

                # Stop the song after 10 seconds
                pygame.mixer.music.stop()
                print(f"Finished playing {song_file}.")
                is_song_playing = False
                classification_result = None  # Clear the classification after playing

        # Wait 1 second before checking again
        await asyncio.sleep(1)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Start the background task when the app starts
    task = asyncio.create_task(check_for_character_and_play_song())

    # Yield control to the application
    yield

    # Cleanup or shutdown tasks when app closes
    task.cancel()


app = FastAPI(lifespan=lifespan)


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
