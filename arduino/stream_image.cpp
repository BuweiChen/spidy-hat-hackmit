#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduCAM.h>
#include <SPI.h>

// WiFi credentials
const char* ssid = "HackMIT.2024";
const char* password = "H@cker2024";

// Backend server address (your laptop's local IP address)
const char* serverUrl = "http://10.189.49.247:8000/classify/";

// Arducam configuration
const int CS = 7;  // Chip select pin for Arducam
ArduCAM myCAM(OV2640, CS);

void setup() {
    Serial.begin(115200);

    // Initialize Arducam
    Wire.begin();
    SPI.begin();
    myCAM.init();

    // Connect to Wi-Fi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
        delay(1000);
        Serial.println("Connecting to WiFi...");
    }
    Serial.println("Connected to WiFi");

    // Initialize the ArduCAM and set the image format
    myCAM.set_format(JPEG);
    myCAM.InitCAM();
}

void loop() {
    // Capture image
    myCAM.flush_fifo();
    myCAM.clear_fifo_flag();
    myCAM.start_capture();
    while (!myCAM.get_bit(ARDUCHIP_TRIG, CAP_DONE_MASK));

    // Read image into buffer
    uint8_t buf[50000];  // Adjust buffer size if necessary
    int length = myCAM.read_fifo_length();
    if (length > 50000 || length == 0) {
        Serial.println("Image too large or empty");
        return;
    }

    myCAM.CS_LOW();
    myCAM.set_fifo_burst();
    myCAM.read_fifo(length, buf);
    myCAM.CS_HIGH();

    // Create HTTPClient object to send the image to the server
    HTTPClient http;
    http.begin(serverUrl);
    http.addHeader("Content-Type", "image/jpeg");

    // Send POST request to backend server with image data
    int httpResponseCode = http.POST(buf, length);
    if (httpResponseCode > 0) {
        String response = http.getString();
        Serial.println(response);  // Print the classification result
    } else {
        Serial.println("Error on sending POST");
    }

    http.end();  // Close connection

    // Free memory and delay before the next capture
    delay(10000);  // Adjust delay for continuous streaming
}
