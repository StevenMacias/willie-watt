#include <ArduinoJson.h>

int led = 9;           // The PWM pin the LED is attached to
int brightness = 0;    // How bright the LED is

const size_t capacity_in = JSON_OBJECT_SIZE(2) + 30;      // The size of the incomming json (Calculated from this assistant: https://arduinojson.org/v6/assistant/)
const size_t capacity_out = JSON_OBJECT_SIZE(7) + 120;    // The size of the outgoing json (Calculated from this assistant: https://arduinojson.org/v6/assistant/)

// set pin numbers:

const int in = A0;     // Used to bias the diode  anode
const int t0 = 20.3;
const float vf0 = 573.44;

// variables will change:
int i;
float dtemp, dtemp_avg, t, b;
float max_temp = 30;      // Default safe value for temperature
String input;             // Input json string 


void setup() {
  Serial.begin(9600);
  pinMode(in, INPUT_PULLUP);   // Set the pin IN with npull up to bias the diode
  pinMode(led, OUTPUT);

}


// When the temperature reaches the max temperature, do something (right now: light up diode):
void openValveFunc()
{
  if (t > max_temp) {
    
    analogWrite(led, 255);

    }else
    {
    analogWrite(led, 0);
    }
}

// Calculating the temperature t:
void findTemperature()
{
    dtemp_avg = 0;
    for (i = 0; i < 1024; i++) {
      float vf = analogRead(A0) * (4976.30 / 1023.000);
      dtemp = (vf - vf0) * 0.4545454;
      dtemp_avg = dtemp_avg + dtemp;
    }
    t = t0 - dtemp_avg / 1024;  
}

void loop() {
  
  findTemperature();
  
  if(Serial.available()){
    DynamicJsonDocument doc_in(capacity_in);    // Create a Json Document for the incomming json-string 
    input = Serial.readStringUntil('\n');       // Read the incomming json-string
    deserializeJson(doc_in, input);             // Deserialize the json-string

    max_temp = doc_in["max_temp"]; // 30        // Set the max temperature value from the json-string
    }

    DynamicJsonDocument doc_out(capacity_out);  // Create a new Json Document for the outgoing json-string
    doc_out["press_sensor_1"] = 120;            // Set all the values (some are hardcoded for the time being – should of course be changed in the future):
    doc_out["temp_sensor_1"] = t;
    doc_out["press_sensor_2"] = 120;
    doc_out["temp_sensor_2"] = t;
    doc_out["valve_state_1"] = 0;
    doc_out["temp_target"] = max_temp;
    doc_out["uControllerState"] = 20;           // What is this value exactly??
  
    serializeJson(doc_out, Serial);             // Serialize the Json Document and send the json-string:
    Serial.print("\n");

    openValveFunc();
}
