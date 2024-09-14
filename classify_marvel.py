from huggingface_hub import login
from transformers import ViTImageProcessor, ViTForImageClassification
import requests
from io import BytesIO
from PIL import Image
import matplotlib.pyplot as plt
import matplotlib.image as mpimg

# Define model name or path
model_name_or_path = "vit-base-avengers-v1"

# Load the image processor and model
image_processor = ViTImageProcessor.from_pretrained(model_name_or_path)
model = ViTForImageClassification.from_pretrained(model_name_or_path)

# Load the image from URL
url = "https://t3.ftcdn.net/jpg/02/43/12/34/360_F_243123463_zTooub557xEWABDLk0jJklDyLSGl2jrr.jpg"
response = requests.get(url)
img = Image.open(BytesIO(response.content))

# Prepare the image for the model
inputs = image_processor(images=img, return_tensors="pt")

# Perform the forward pass to get logits
outputs = model(**inputs)

# Get the predicted class
logits = outputs.logits
predicted_class_idx = logits.argmax(-1).item()
print("Predicted class:", model.config.id2label[predicted_class_idx])
