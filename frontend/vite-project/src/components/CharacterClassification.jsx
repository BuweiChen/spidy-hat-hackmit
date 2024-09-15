import { useEffect, useState } from "react";
import axios from "axios";

const CharacterClassification = () => {
  const [character, setCharacter] = useState("");

  useEffect(() => {
    const fetchClassification = async () => {
      try {
        const response = await axios.get(
          "http://localhost:8000/get_classification"
        );
        if (response.data.predicted_class) {
          setCharacter(response.data.predicted_class);
        }
      } catch (error) {
        console.error("Error fetching classification:", error);
      }
    };

    const interval = setInterval(fetchClassification, 3000); // Poll every 3 seconds
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="mt-5">
      <h2 className="text-xl font-semibold">Recognized Character</h2>
      <div className="text-2xl mt-3">
        {character ? character : "No character recognized yet."}
      </div>
    </div>
  );
};

export default CharacterClassification;
