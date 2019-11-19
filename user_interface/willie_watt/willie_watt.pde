/**
Willie Watt User Interface
willie_watt.pde
Purpose: Develop a user interface for a steam sterilization system.

@author Jon Ravn, Steven Macías, Sultan Tariq 
@version 1.0 01/11/2019
JSON: {"press_sensor_1": 120.00,"temp_sensor_1": 110,"press_sensor_2": 120.00,"temp_sensor_2": 110,"valve_state_1":0,"temp_target":120,"uControllerState": 20}\n
*/

import controlP5.*;
ControlP5 cp5;
import processing.serial.*;
Serial serial_port = null;

// Configuration constants

//static final String COM_PORT  = "COM4";
static final int COM_BAUDRATE = 9600;
static final int SCREEN_W = 1580;
static final int SCREEN_H = 800;


// Window constants
static final int text_size          = 12;
static final int background_color   = 0;


static final int tunning_values_x_pos    = 60;
static final int tunning_values_y_pos    = 90;
static final boolean DEBUG_ON            = false;

Textlabel myTextlabelB;
Textlabel myTextlabelC;
DropdownList d1;
JSONObject tx_json;
JSONObject max_temp_json;
JSONObject startstop_json;
JSONObject close_all_json;
Textarea myTextarea;
Textarea myTextarea2;
Println console;
Knob temperatureKnob;
Knob pressureKnob;
Knob outTemperatureKnob;
Knob outPressureKnob;
//JSONObject changeValveState;
Toggle startButton;
Button closeAllValve;
Button setMaxTemp;
Boolean closeValve = false;

// serial port buttons
String serial_list;                // list of serial ports
int serial_list_index = 0;         // currently selected serial port
int num_serial_ports = 0;          // number of serial ports in the list


// variables for the coordinates
float press_sensor_1         = 0;
float press_sensor_2         = 0;
float temp_sensor_1          = 0;
float temp_sensor_2          = 0;
int   valve_state_1           =0;
float temp_target= 0;
float max_temp;
JSONArray array_values = new JSONArray();
int uControllerState = 0;



void PRINT(String s)
{
  if(DEBUG_ON)
  {
    println(s);
  }
}

/**
Function that is called everytime a JSON string arrives through the UART
@param none
@return void
*/
void serialEvent(Serial serial_port) {
  try {
    String buffer = serial_port.readStringUntil('\n');
    if (buffer != null) {
      //println(buffer);
      JSONObject json = parseJSONObject(buffer);
      if (json == null) {
        println("JSONObject could not be parsed. Instead found:");
         myTextarea2.setText(buffer);
      } else {
        // Get the values of the Sensor Array
        //array_values = json.getJSONArray("array_values");
        // Get the values of the accelerometer
        press_sensor_1 = json.getFloat("press_sensor_1");
        press_sensor_2 = json.getFloat("press_sensor_2");
        temp_sensor_1 = json.getFloat("temp_sensor_1");
        temp_sensor_2 = json.getFloat("temp_sensor_2");
        valve_state_1= json.getInt("temp_target");
        temp_target=json.getInt("valve_state_1");
        uControllerState = json.getInt("uControllerState");
        myTextarea2.setText(json.toString());
     //update knobs
     temperatureKnob.setValue(temp_sensor_1);
     outTemperatureKnob.setValue(temp_sensor_2);
     pressureKnob.setValue(press_sensor_1);
     outPressureKnob.setValue(press_sensor_2);
     
     
     if(valve_state_1==0){
        cp5.getController("valve1").setColorActive(color(#f35454));
        cp5.getController("valve1").setColorBackground(color(#5c5c5c));
     }
     
     else{
      cp5.getController("valve1").setColorActive(color(#54f367));
      cp5.getController("valve1").setColorBackground(color(#5c5c5c));
     }
     
     cp5.getController("valve1").setValue(valve_state_1);
     
     if(temp_sensor_1 > 180)
     temperatureKnob.setColorForeground(color(#ff0000));
      
     if(press_sensor_1 > 15)
     pressureKnob.setColorForeground(color(#ff0000));
  
      } 
    } else
    {
      println("Buffer is null");
    }
  }
  catch (Exception e) {
    println("Initialization exception" + e);
  }
  
 

  try {
    // get message till line break (ASCII > 13)
    String message =serial_port.readStringUntil(13);
    // just if there is data
    if (message != null) {
      println("message received: "+trim(message));
    }
  }
  catch (Exception e) {
  }
}

/**
Function that initializes the user interface
@param none
@return void
*/
void setup() {
  // create window
  frameRate(20);
  size(1180, 500);
  smooth(4);
  tx_json = new JSONObject();

  // get the number of serial ports in the list
  num_serial_ports = Serial.list().length;

  cp5 = new ControlP5(this);

myTextlabelC = new Textlabel(cp5,"Sterilize-It",tunning_values_x_pos+350,5,400,200);
myTextlabelC.setColorValue(0xffffff00);
myTextlabelC.setFont(createFont("Georgia",50));

  // create a DropdownList,
  d1 = cp5.addDropdownList("serialPortList")
  .setPosition(tunning_values_x_pos, tunning_values_y_pos)
  .setOpen(false)
  .setBackgroundColor(color(#216329))
  .setColorActive(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorCaptionLabel(color(#216329))
  .setColorForeground(color(#216329))
  .setColorLabel(color(#000000))
  .setColorValue(color(#216329))
  .setColorValueLabel(color(#000000))
  .setItemHeight(25)
  .setHeight(200)
  .setBarHeight(25)
  .setWidth(110);
  
  customize(d1);

  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("connect")
  .setPosition(tunning_values_x_pos,tunning_values_y_pos-75)
  .setSize(100,35)
  .setValue(false)
  .setMode(ControlP5.SWITCH)
  .setColorBackground(color(#5c5c5c))
  .setColorActive(color(#f35454));
  
   startButton = cp5.addToggle("Start")
  .setPosition(tunning_values_x_pos+120,tunning_values_y_pos-75)
  .setSize(100,35)
  .setValue(false)
  .setMode(ControlP5.SWITCH)
  .setColorBackground(color(#5c5c5c))
  .setColorActive(color(#f35454));
  
  
  closeAllValve =cp5.addButton("closeAllValve")
  .setPosition(tunning_values_x_pos+225,tunning_values_y_pos-75)
  .setSize(100,35)
  .setValue(1)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000));

  cp5.addToggle("valve1")
  .setPosition(tunning_values_x_pos+600,tunning_values_y_pos)
  .setSize(50,25)
  .setValue(false)
  .setMode(ControlP5.SWITCH)
  .setColorBackground(color(#5c5c5c))
  .setColorActive(color(#f35454))
  .lock();

  cp5.addButton("refreshPorts")
  .setPosition(tunning_values_x_pos+150,tunning_values_y_pos)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000));

  cp5.addButton("consoleClearFunc")
  .setPosition(tunning_values_x_pos,tunning_values_y_pos+310)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000));
  
  cp5.addSlider("slider")
  .setPosition(tunning_values_x_pos+275,tunning_values_y_pos+310)
  .setSize(100,25)
  .setRange(0,200)
  .setValue(128);
     
  cp5.getController("slider").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  
  setMaxTemp=cp5.addButton("SetMaxTemp")
  .setPosition(tunning_values_x_pos+275,tunning_values_y_pos+350)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000))
  .lock();

cp5.addTextlabel("label")
.setText("Logs")
.setPosition(tunning_values_x_pos,tunning_values_y_pos+75)
.setColorValue(0xffffff00)
.setFont(createFont("Georgia",20));

                    
  myTextarea = cp5.addTextarea("txt")
                  .setPosition(tunning_values_x_pos,tunning_values_y_pos+100)
                  .setSize(380, 200)
                  .setFont(createFont("arial", 10))
                  .setLineHeight(14)
                  .setColor(color(#54f367))
                  .setColorBackground(color(#383a39))
                  .setColorForeground(color(#216329));
                  
 console = cp5.addConsole(myTextarea);

myTextlabelB = new Textlabel(cp5,"Input",tunning_values_x_pos+700,tunning_values_y_pos+75,400,200);
myTextlabelB.setColorValue(0xffffff00);
myTextlabelB.setFont(createFont("Georgia",20));
                    
  myTextarea2 = cp5.addTextarea("rx_json_textarea")
                  .setPosition(tunning_values_x_pos+700,tunning_values_y_pos+100)
                  .setSize(380, 200)
                  .setFont(createFont("arial", 10))
                  .setLineHeight(14)
                  .setColor(color(#54f3d3))
                  .setColorBackground(color(#383a39))
                  .setColorForeground(color(#216329));
  ;

               
                temperatureKnob = cp5.addKnob("Temperature")
               .setFont(createFont("times", 10))
               .setRange(0,200)
               .setValue(temp_sensor_1)
               .setPosition(tunning_values_x_pos+400,tunning_values_y_pos+100)
               .setRadius(50)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(4)
               .snapToTickMarks(false)
               .setColorForeground(color(#54f367))
               .setColorBackground(color(#000066))
               .setColorActive(color(255,255,0))
               .setDragDirection(Knob.VERTICAL)
               .setResolution(0.01)
               .lock()
               .setMin(0)
               .setMax(200)
               ;
               
                 pressureKnob = cp5.addKnob("Pressure")
               .setRange(0,20)
               .setValue(press_sensor_1)
               .setPosition(tunning_values_x_pos+590,tunning_values_y_pos+100)
               .setRadius(50)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(4)
               .snapToTickMarks(false)
               .setColorForeground(color(#54f367))
               .setColorBackground(color(#216329))
               .setColorActive(color(255,255,0))
               .setDragDirection(Knob.HORIZONTAL)
               .lock()
               ;
               
               
                outTemperatureKnob = cp5.addKnob("Out Temperature")
               .setFont(createFont("times", 10))
               .setRange(0,200)
               .setValue(temp_sensor_2)
               .setPosition(tunning_values_x_pos+400,tunning_values_y_pos+250)
               .setRadius(50)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(4)
               .snapToTickMarks(false)
               .setColorForeground(color(#54f367))
               .setColorBackground(color(#000066))
               .setColorActive(color(255,255,0))
               .setDragDirection(Knob.VERTICAL)
               .setResolution(0.01)
               .lock()
               .setMin(0)
               .setMax(200)
               ;
               
                outPressureKnob = cp5.addKnob("Out Pressure")
               .setRange(0,20)
               .setValue(press_sensor_2)
               .setPosition(tunning_values_x_pos+590,tunning_values_y_pos+250)
               .setRadius(50)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(4)
               .snapToTickMarks(false)
               .setColorForeground(color(#54f367))
               .setColorBackground(color(#216329))
               .setColorActive(color(255,255,0))
               .setDragDirection(Knob.HORIZONTAL)
               .lock()
               ;
}

public void transmitValues(int theValue) {
  println("Transmit values: "+theValue);
  if(serial_port != null)
  {
    
    // Why is this so slow? 2.5 seconds.
    serial_port.write(tx_json.toString().replace("\n", "").replace("\r", ""));
    serial_port.write('\n');

    println("Sending JSON though the UART: "+tx_json.toString().replace("\n", "").replace("\r", ""));
    println(tx_json.toString().length());
    delay(100);
  }
}

public void transmitAllJSON() {
 
  JSONObject _json = new JSONObject();
 
  if(serial_port != null)
  {
    _json.setFloat("start_stop",startButton.getValue());
    if(startButton.getValue() == 1)
{
     _json.setFloat("max temp", max_temp);
     _json.setFloat("close all valve",0);
     if (closeValve)
     {
     _json.setFloat("close all valve",1);
     }
}
  
    // Why is this so slow? 2.5 seconds.
    serial_port.write(_json.toString().replace("\n", "").replace("\r", ""));
    serial_port.write('\n');

    delay(100);
  }
}

  public void refreshPorts(int theValue) {
    println("Refresh ports: "+theValue);
    customize(d1);
  }


public void SetMaxTemp()
{ 
 transmitAllJSON();
}

  public void Start()
  {
  transmitAllJSON();
  
  if(startButton.getValue() == 0)
  {
    cp5.getController("SetMaxTemp").lock();
    cp5.getController("closeAllValve").lock();
    cp5.getController("Start").setColorActive(color(#f35454));
    cp5.getController("Start").setColorBackground(color(#5c5c5c));
  }
  else
  {
    cp5.getController("SetMaxTemp").unlock();
    cp5.getController("closeAllValve").unlock();
    cp5.getController("Start").setColorActive(color(#54f367));
    cp5.getController("Start").setColorBackground(color(#5c5c5c));
  }
  }
  
  public void closeAllValve()
  {
  closeValve = true;
  transmitAllJSON();
  closeValve = false;
  
  }
  
  public void consoleClearFunc()
  {
    try{
          console.clear();
        }
        catch (Exception e) {
          println(e);
        }
    
  }
  
  void slider(float value) {
  max_temp = value;
  
}

  void connect(boolean theFlag) {
    boolean port_error = false;
    if(theFlag==true) {
      if (serial_port == null) {
        // connect to the selected serial port
        try{
          serial_port = new Serial(this, Serial.list()[serial_list_index], COM_BAUDRATE);
          serial_port.clear();
          serial_port.bufferUntil('\n');
        }
        catch (Exception e) {
          println(e);
          port_error = true;
        }
        if(port_error == false)
        {
          lockButtons();
          
        }else
        {
          unlockButtons();
          //put the switch in off position
          cp5.getController("connect").setValue(0);
          
        }

      }
    } else {
      if (serial_port != null) {
        // disconnect from the serial port
        serial_port.clear();
        serial_port.stop();
        serial_port = null;
        unlockButtons();
      }
    }
  }

  void lockButtons()
  {
    cp5.getController("connect").setColorActive(color(#54f367));
    cp5.getController("connect").setColorBackground(color(#5c5c5c));
    cp5.getController("serialPortList").setLock(true);
    cp5.getController("serialPortList").setColorBackground(color(#5c5c5c));
    cp5.getController("calibrateSensors").setColorBackground(color(#5c5c5c));
    println("Connect");
  }

  void unlockButtons()
  {
    cp5.getController("connect").setColorActive(color(#f35454));
    cp5.getController("connect").setColorBackground(color(#5c5c5c));
    cp5.getController("serialPortList").setLock(false);
    cp5.getController("serialPortList").setColorBackground(color(#54f367));
    cp5.getController("calibrateSensors").setColorBackground(color(#54f367));
    println("Disconnect");
  }


  void controlEvent(ControlEvent theEvent) {
    // DropdownList is of type ControlGroup.
    // A controlEvent will be triggered from inside the ControlGroup class.
    // therefore you need to check the originator of the Event with
    // if (theEvent.isGroup())
    // to avoid an error message thrown by controlP5.

    if (theEvent.isGroup()) {
      // check if the Event was triggered from a ControlGroup
      println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    }
    else if (theEvent.isController()) {
      if (theEvent.isFrom(cp5.getController("serialPortList"))) {
        if (serial_port == null) {
          // connect to the selected serial port
          try{
            //serial_port = new Serial(this, Serial.list()[int(theEvent.getController().getValue())], 9600);
            serial_list_index = int(theEvent.getController().getValue());
            //serial_port.bufferUntil('\n');
          }
          catch (Exception e) {
            println(e);
          }
        }
      }else if(theEvent.isFrom(cp5.getController("baseSpeedValue")))
      {
        println("BaseSpeedValue Event");
        transmitValues(0);
        //delay(50);
      }
    }
  }

  void customize(DropdownList ddl) {
    // a convenience function to customize a DropdownList
    ddl.clear();
    ddl.getCaptionLabel().set("Serial Ports");
    num_serial_ports = Serial.list().length;
    println("num_serial_ports: "+num_serial_ports);
    for (int i=0;i<num_serial_ports;i++) {
      //println(Serial.list()[i]);
      ddl.addItem(Serial.list()[i], i);
    }
  }

  /**
  Main function to create the user interface
  @param none
  @return void
  */
  void draw()
  {
    background(background_color);
    myTextlabelB.draw(this); 
    myTextlabelC.draw(this); 
  }
