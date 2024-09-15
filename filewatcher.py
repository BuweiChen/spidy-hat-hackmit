import os
import time
import requests
from fastapi import FastAPI
import uvicorn
from typing import Optional
from pathlib import Path

app = FastAPI()

# Define the directory to monitor and the server URL
directory_to_watch = "/Users/buweichen/repos/spidy-hat-hackmit/camera_output"
server_url = "http://0.0.0.0:8000/classify/"

# Function to send the image in a POST request
def send_file_to_server(file_path: str):
    with open(file_path, 'rb') as file:
        files = {'file': file}
        try:
            response = requests.post(server_url, files=files)
            if response.status_code == 200:
                print(f"File {file_path} sent successfully.")
            else:
                print(f"Failed to send {file_path}. Status code: {response.status_code}")
        except Exception as e:
            print(f"Error while sending {file_path}: {e}")

# Function to find the most recent .jpg or .jpeg file
def get_most_recent_image():
    image_files = [f for f in os.listdir(directory_to_watch) if f.endswith(('.jpg', '.jpeg'))]
    if not image_files:
        return None

    # Get the full path of the image files
    image_files_full_path = [os.path.join(directory_to_watch, f) for f in image_files]

    # Find the most recent file by modification time
    most_recent_file = max(image_files_full_path, key=os.path.getmtime)
    return most_recent_file

# Function to check for images periodically and send the most recent one
def check_for_images():
    while True:
        most_recent_image = get_most_recent_image()
        if most_recent_image:
            send_file_to_server(most_recent_image)
            # Optionally, delete the file after sending
            os.remove(most_recent_image)
        time.sleep(1)  # Wait for 1 second before checking again

@app.on_event("startup")
async def startup_event():
    # Start the file checking in a separate thread or background task
    import threading
    file_watcher_thread = threading.Thread(target=check_for_images)
    file_watcher_thread.daemon = True
    file_watcher_thread.start()

# FastAPI endpoint (not required for the client side but can be used to extend the functionality)
@app.get("/")
async def root():
    return {"message": "File watcher is running"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
