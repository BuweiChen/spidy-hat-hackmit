import { useState, useEffect } from "react";
import axios from "axios";

const SongStatus = () => {
  const [songStatus, setSongStatus] = useState("");

  useEffect(() => {
    const checkSongStatus = async () => {
      try {
        const response = await axios.get(
          "http://localhost:8000/is_song_playing"
        );
        setSongStatus(response.data.status);
      } catch (error) {
        console.error("Error checking song status:", error);
      }
    };

    const interval = setInterval(checkSongStatus, 5000); // Poll every 5 seconds
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="mt-5">
      <h2 className="text-xl font-semibold">Theme Song Status</h2>
      <div className="text-lg mt-2">{songStatus}</div>
    </div>
  );
};

export default SongStatus;
