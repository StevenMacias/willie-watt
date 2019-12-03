#include <ArduinoJson.h>
#include <SPI.h>
#include "Adafruit_MAX31855.h"

#define MAXDO   2
#define MAXCLK  3
#define MAXCS1  4
#define MAXCS2  5
#define AIR_COMPRESSOR  6
#define WATER_PUMP  8
#define HEATER      9
#define VALVE_0     10      // The input valve (3.1)
#define VALVE_1     11      // The output valve (3.2)
#define VALVE_2     12      // The draining vessel valve (3.3)
#define VALVE_3     13      // The end valve (2.2)


const size_t capacity_in = JSON_OBJECT_SIZE(1) + 20;       // The size of the incomming json (Calculated from this assistant: https://arduinojson.org/v6/assistant/)
const size_t capacity_out = JSON_OBJECT_SIZE(12) + 190;    // The size of the outgoing json (Calculated from this assistant: https://arduinojson.org/v6/assistant/)


// initialize the Thermocouple
Adafruit_MAX31855 thermocouple(MAXCLK, MAXCS1, MAXDO);
Adafruit_MAX31855 thermocouple2(MAXCLK, MAXCS2, MAXDO);

// variables will change:
int i;
float max_temp = 110;       // Default safe value for temperature
String input;               // Input json string 
int start = 0;              // Start/stop value from the input json string
int step = 0;               // Step counter
float temp1;                // The first temperature value
float temp2;                // The secound temperature value
boolean aircomp = false;    // on-off value for the air compressor
boolean heater = false;     // On-off value for the heaters
boolean water_pump = false; // On-off value for the water pump
boolean valve_0 = false;    // On-off value for valve 0
boolean valve_1 = false;    // On-off value for valve 1
boolean valve_2 = false;    // On-off value for valve 2
boolean valve_3 = false;    // On-off value for valve 3


void setup() {
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  pinMode(12, OUTPUT);
  Serial.begin(9600);
  // wait for MAX chip to stabilize
  delay(500);

}

// Function that control the sterilization process
void sterilizationProcess()
{
  // Start or continue the sterilization process if the UI sets start == true
  if(start == 1 && step == 0){
    closeValve(VALVE_0);
    closeValve(VALVE_1);                      // Close all valves
    closeValve(VALVE_2);
    closeValve(VALVE_3);  
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
    }
    else {
      step = 1;
    }
  }
  else if (start == 1 && step == 1){
    openValve(VALVE_0);                       // Open input valve (3.1)
    pointValve();                             // Point 2.1 to the waterpump
    // Check if the main champer is filled?
    closeValve(VALVE_0);                      // Close input valve (3.1)
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
    if(temp1 > 99.99){                         // Check if water is boiling (Also use pressure values to check it?)
      step = 3;
      turnOFFHeater();                        // Turn off heaters (7)
    }
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 3){
    openValve(VALVE_1);                       // Open output valve (3.2)
    // wait for flush
    closeValve(VALVE_1);                      // Close output valve (3.2)
    wait(60);                                 // Wait one minute
    // when one minute has passed
    step = 4;
    if(start == 0){                           // Check if the program is told to abort the process
      openValve(VALVE_1);                     // Open output valve (3.2)            
      openValve(VALVE_0);                     // Open input valve (3.1)
      pointValve();                           // Point 2.1 to the disconnected end
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 4){
    openValve(VALVE_2);                       // Open the draining vessel valve (3.3)
    step = 5;
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 5){
    openValve(VALVE_0);                       // Open input valve (3.1)
    openValve(VALVE_1);                       // Open output valve (3.2)
    openValve(VALVE_3);                       // Open the end valve (2.2)
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
    closeValve(VALVE_0);                      // Close input valve (3.1)
    closeValve(VALVE_1);                      // Close output valve (3.2)
    closeValve(VALVE_2);                      // Close the draining vessel valve (3.3)
    closeValve(VALVE_3);                      // Close the end valve (2.2)
    step = 8;
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
  }
  else if (start == 1 && step == 8){
    openValve(VALVE_0);                       // Open input valve (3.1)
    pointValve();                             // Point 2.1 to the waterpump
    // Check if the main champer is filled?
    closeValve(VALVE_0);                      // Close input valve (3.1)
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
    else {
      step = 9;    
    }
  }
  else if(start == 1 && step == 9){
    turnONHeater();                           // Turn on heaters (7)
    if(temp1 > 99.99){                         // Check if water is boiling (Also use pressure values to check it?)
      // Wait for all the water to change from the liquid state to the gas state?
      step = 10;
      turnOFFHeater();                        // Turn off heaters (7)
    }
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 10){
    openValve(VALVE_1);                       // Open output valve (3.2)
    // wait for steam to be injected
    closeValve(VALVE_1);                      // Close output valve (3.2)
    // wait for steam to sterialize
    step = 11;
    if(start == 0){                           // Check if the program is told to abort the process
      openValve(VALVE_1);                     // Open output valve (3.2)            
      openValve(VALVE_0);                     // Open input valve (3.1)
      pointValve();                           // Point 2.1 to the disconnected end
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 11){
    if (temp2 < 130){
      step = 7;                                // If the temperature drops, try to inject steam again (Step 7)
    }
    else if(start == 0){                      // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
    else {
      step = 12;
    }
  }
  else if(start == 1 && step == 12){
    openValve(VALVE_2);                       // Open the draining vessel valve (3.3)
    openValve(VALVE_3);                       // Open the end valve (2.2)
    openValve(VALVE_0);                       // Open the input valve (3.1)
    openValve(VALVE_1);                        // Open the input valve (3.2)
    pointValve();                             // Point 2.1 to the air compressor
    turnONAir();                              // Turn on air compressor and inject compressed air.
    // wait for air to drain the tubes
    turnOFFAir();                             // Turn off air compressor
    step = 13;
    if(start == 0){                           // Check if the program is told to abort the process
      // Do the abort-procedure for this step.
      step = 0;                               // Stop the process
    }
  }
  else if(start == 1 && step == 13){
    closeValve(VALVE_0);                      // Close input valve (3.1)
    closeValve(VALVE_1);                      // Close output valve (3.2)
    closeValve(VALVE_2);                      // Close the draining vessel valve (3.3)
    closeValve(VALVE_3);                      // Close the end valve (2.2)
    step = 0;
    start = 0;
  }
}


void openValve(int valve)
{
  digitalWrite(valve, HIGH);
  if(valve == VALVE_0){
    valve_0 = true;
  }
  else if(valve == VALVE_1){
    valve_1 = true;
  }
  else if(valve == VALVE_2){
    valve_2 = true;
  }
  else if(valve == VALVE_3){
    valve_3 = true;
  }
}

void closeValve(int valve)
{
  digitalWrite(valve, LOW);
  if(valve == VALVE_0){
    valve_0 = false;
  }
  else if(valve == VALVE_1){
    valve_1 = false;
  }
  else if(valve == VALVE_2){
    valve_2 = false;
  }
  else if(valve == VALVE_3){
    valve_3 = false;
  }
}


void pointValve()
{
  //TODO: Implement pointValve. It should probably take a parameter regarding to which way it should point
}

// Calculating the temperature t:
void findTemperature()
{   
  temp1 = thermocouple.readCelsius();
  temp2 = thermocouple2.readCelsius();
}

void findPressure()
{
  // TODO: Implement findPressure. It I see no problem in this function to get and set both pressure values.
}

void turnONHeater()
{
  digitalWrite(HEATER, HIGH);
  heater = true;
}

void turnOFFHeater()
{
  digitalWrite(HEATER, LOW);
  heater = false;
}

void turnONAir()
{
  digitalWrite(AIR_COMPRESSOR, HIGH);
  aircomp = true;
}

void turnOFFAir()
{
  digitalWrite(AIR_COMPRESSOR, LOW);
  aircomp = false;
}

void recieveJSON(){
 DynamicJsonDocument doc_in(capacity_in);       // Create a Json Document for the incomming json-string 
 input = Serial.readStringUntil('\n');          // Read the incomming json-string
 deserializeJson(doc_in, input);                // Deserialize the json-string
 start = doc_in["start_stop"];                  // Set the start value from the json-string
}

void sendJSON(){
  DynamicJsonDocument doc_out(capacity_out);    // Create a new Json Document for the outgoing json-string
  doc_out["press_sensor_1"] = 120;              // Set all the values (some are hardcoded for the time being – should of course be changed in the future):
  doc_out["temp_sensor_1"] = temp1;
  doc_out["press_sensor_2"] = 120;
  doc_out["temp_sensor_2"] = temp2;
  doc_out["valve_state_1"] = 0;               
  doc_out["max_temp"] = max_temp;
  doc_out["heater"] = heater;
  doc_out["water_pump"] = water_pump;
  doc_out["valve_0"] = valve_0;
  doc_out["valve_1"] = valve_1;
  doc_out["valve_2"] = valve_2;
  doc_out["uControllerState"] = 20;             // What is this value exactly??
  
  serializeJson(doc_out, Serial);               // Serialize the Json Document and send the json-string:
  Serial.print("\n");
}

void wait(int j){
  j = j*2;
  for (int i=0; i<j; i++) {             // What do you think about this solution in order to wait? It will stop the program for 0.5 second using delay, and then monitor temp and pressure, and then stop for 0.5 second again, and repeating the process for j seconds.
  findTemperature();
  findPressure();
  if(Serial.available()){
  recieveJSON();
  }  
  sendJSON();
  if(start == 0){
    break;
  }
  delay(500);
 }
}



void loop() {
  // Find temperatures and pressure values and then send them to the UI:
  findTemperature();
  findPressure();
  
  if(Serial.available()){
    recieveJSON();
    }
    
  sendJSON();
  sterilizationProcess();
}
