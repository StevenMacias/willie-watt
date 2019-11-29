#include <ArduinoJson.h>
#include <SPI.h>
#include "Adafruit_MAX31855.h"

#define WATER_PUMP  8
#define HEATER      9
#define VALVE_0     10
#define VALVE_1     11
//int led = 9;           // The PWM pin the LED is attached to
//int brightness = 0;    // How bright the LED is

const size_t capacity_in = JSON_OBJECT_SIZE(1) + 20;         // The size of the incomming json (Calculated from this assistant: https://arduinojson.org/v6/assistant/)
const size_t capacity_out = JSON_OBJECT_SIZE(12) + 190;    // The size of the outgoing json (Calculated from this assistant: https://arduinojson.org/v6/assistant/)

// set pin numbers:

//const int in = A0;     // Used to bias the diode  anode
//const int t0 = 20.3;
//const float vf0 = 573.44;

// variables will change:
int i;
//float dtemp, dtemp_avg, t, b;
float max_temp = 30;      // Default safe value for temperature
String input;             // Input json string 
int start = 0;            // Start/stop value from the input json string
int step = 0;             // Step counter
float temp;  
boolean heater = false;
boolean water_pump = false;
boolean valve_0 = false;
boolean valve_1 = false;
boolean valve_2 = false;


void setup() {
  Serial.begin(9600);
//  pinMode(in, INPUT_PULLUP);   // Set the pin IN with npull up to bias the diode
//  pinMode(led, OUTPUT);

}

// Function that control the sterilization process
void sterilizationProcess()
{
  // Start or continue the sterilization process if the UI sets start == true
  if(start == 1 && step == 0){
    closeValve();
    closeValve();                            // Close all valves
    closeValve();
    closeValve();  
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
    }
    else {
      step = 1;
    }
  }
  else if (start == 1 && step == 1){
    openValve();                              // Open input valve (3.1)
    pointValve();                             // Point 2.1 to the waterpump
    // Check if the main champer is filled?
    closeValve;                               // Close input valve (3.1)
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
    else {
      step = 2;    
    }
  }
  else if(start == 1 && step == 2){
    turnONHeater();                           // Turn on heaters (7)
    if(temp > 99.99){                         // Check if water is boiling (Also use pressure values to check it?)
      step = 3;
      turnOFFHeater();                        // Turn off heaters (7)
    }
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 3){
    openValve();                              // Open output valve (3.2)
    // wait for flush
    closeValve();                             // Close output valve (3.2)
    // wait one minute
    // if one minute has passed
    step = 4;
    if(start == 0){                           // Check if the program is told to abort the process
      openValve();                            // Open output valve (3.2)            
      openValve();                            // Open input valve (3.1)
      pointValve();                           // Point 2.1 to the disconnected end
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 4){
    openValve();                              // Open the draining vessel valve (3.3)
    step = 5;
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 5){
    openValve();                              // Open input valve (3.1)
    openValve();                              // Open output valve (3.2)
    openValve();                              // Open valve (2.2)
    pointValve();                             // Point 2.1 to the air compressor
    step = 6;
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 6){
    turnONAir();                              // Turn on air compressor and inject compressed air.
    // wait for air to drain the tubes
    turnOFFAir();                             // Turn off air compressor
    step = 7;
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 7){
    closeValve();                              // Close input valve (3.1)
    closeValve();                              // Close output valve (3.2)
    closeValve();                              // Close valve (2.2)
    step = 8;
    if(start == 0){                            // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                                // Stop the process
    }
  }
}


void openValve()
{

  //TODO: Implement openValve. It should probably take a parameter regarding to which valve it should open

}

void closeValve()
{

  //TODO: Implement closeValve. It should probably take a parameter regarding to which valve it should close

}


void pointValve()
{
  //TODO: Implement pointValve. It should probably take a parameter regarding to which way it should point
}

// Calculating the temperature t:
void findTemperature()
{/*
    dtemp_avg = 0;
    for (i = 0; i < 1024; i++) {
      float vf = analogRead(A0) * (4976.30 / 1023.000);
      dtemp = (vf - vf0) * 0.4545454;
      dtemp_avg = dtemp_avg + dtemp;
    }
    t = t0 - dtemp_avg / 1024;  

    TODO: Implement findTemperature. It I see no problem in this function to get and set both temperature values.
    
*/}

void findPressure()
{
  // TODO: Implement findPressure. It I see no problem in this function to get and set both pressure values.
}

void turnONHeater()
{
  // TODO: Implement turnONHeater.
}

void turnOFFHeater()
{
  // TODO: Implement turnOFFHeater. 
}

void turnONAir()
{
  // TODO: Implement turnONAir.
}

void turnOFFAir()
{
  // TODO: Implement turnOFFAir. 
}



void loop() {
  // Find temperatures and pressure values and then send them to the UI:
  findTemperature();
  findPressure();
  
  if(Serial.available()){
    DynamicJsonDocument doc_in(capacity_in);    // Create a Json Document for the incomming json-string 
    input = Serial.readStringUntil('\n');       // Read the incomming json-string
    deserializeJson(doc_in, input);             // Deserialize the json-string

    start = doc_in["start_stop"];               // Set the start value from the json-string
    }

  DynamicJsonDocument doc_out(capacity_out);  // Create a new Json Document for the outgoing json-string
  doc_out["press_sensor_1"] = 120;            // Set all the values (some are hardcoded for the time being – should of course be changed in the future):
  doc_out["temp_sensor_1"] = 30;
  doc_out["press_sensor_2"] = 120;
  doc_out["temp_sensor_2"] = 30;
  doc_out["valve_state_1"] = 0;
  doc_out["max_temp"] = max_temp;
  doc_out["heater"] = heater;
  doc_out["water_pump"] = water_pump;
  doc_out["valve_0"] = valve_0;
  doc_out["valve_1"] = valve_1;
  doc_out["valve_2"] = valve_2;
  doc_out["uControllerState"] = 20;           // What is this value exactly??
  
  serializeJson(doc_out, Serial);             // Serialize the Json Document and send the json-string:
  Serial.print("\n");

  sterilizationProcess();


}
