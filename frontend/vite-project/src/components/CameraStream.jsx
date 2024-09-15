import { useEffect, useState } from "react";
import axios from "axios";

const CameraStream = () => {
  const [streamUrl, setStreamUrl] = useState(null);

  useEffect(() => {
    // Stream camera feed from the Arduino endpoint
    setStreamUrl("http://<ARDUINO_IP_ADDRESS>/stream");
  }, []);

  const captureImage = async () => {
    try {
      const response = await axios.get("http://localhost:8000/classify", {
        responseType: "blob",
      });
      // Send image to the backend for classification
      const formData = new FormData();
      formData.append("file", response.data);

      await axios.post("http://localhost:8000/classify", formData);
    } catch (error) {
      console.error("Error capturing image:", error);
    }
  };

  return (
    <div className="mt-5">
      <h2 className="text-xl font-semibold">Camera Stream</h2>
      {streamUrl && (
        <img src={streamUrl} alt="Camera Stream" className="w-96 h-64 border" />
      )}
      <button
        onClick={captureImage}
        className="mt-5 bg-blue-600 px-4 py-2 rounded-md hover:bg-blue-500"
      >
        Capture & Classify
      </button>
    </div>
  );
};

export default CameraStream;
