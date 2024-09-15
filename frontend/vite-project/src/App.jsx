// import React from "react";
import CameraStream from "./components/CameraStream";
import CharacterClassification from "./components/CharacterClassification";
import SongStatus from "./components/SongStatus";

function App() {
  return (
    <div className="bg-gray-900 text-white h-screen flex flex-col items-center">
      <h1 className="text-3xl font-bold mt-10">SpideySense Gadget</h1>
      <CameraStream />
      <CharacterClassification />
      <SongStatus />
    </div>
  );
}

export default App;
