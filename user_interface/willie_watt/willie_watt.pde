   /**
Willie Watt User Interface
willie_watt.pde
Purpose: Develop a user interface for a steam sterilization system.

@author Jon Ravn, Steven Macías, Sultan Tariq
@version 1.0 01/11/2019
*/

import controlP5.*;
ControlP5 cp5;
import processing.serial.*;
Serial serial_port = null;
import meter.*;

// Configuration constants

//static final String COM_PORT  = "COM4";
static final int COM_BAUDRATE = 9600;
static final int SCREEN_W = 1180;
static final int SCREEN_H = 500;
static final int DIAG_X = 825;
static final int DIAG_Y = 10;



// Window constants
static final int text_size          = 12;
PImage img, diagram;

static final int tunning_values_x_pos    = 60;
static final int tunning_values_y_pos    = 90;
static final boolean DEBUG_ON            = false;

Textlabel myTextlabelB;
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
Meter m1,m2,m3,m4;

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
float timer=0;
JSONArray array_values = new JSONArray();
int uControllerState = 0;

// Control variables
boolean heater, water_pump, valve_0,valve_1,valve_2 = false;

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
        heater = json.getBoolean("heater");
        water_pump = json.getBoolean("water_pump");
        valve_0 = json.getBoolean("valve_0");
        valve_1 = json.getBoolean("valve_1");
        valve_2 = json.getBoolean("valve_2");
        timer=json.getFloat("timer");
        myTextarea2.setText(json.toString());
       //update knobs
       //temperatureKnob.setValue(temp_sensor_1);
       //outTemperatureKnob.setValue(temp_sensor_2);
       //pressureKnob.setValue(press_sensor_1);
       //outPressureKnob.setValue(press_sensor_2);


     /*if(valve_state_1==0){
        cp5.getController("valve1").setColorActive(color(#3e44ec));
        cp5.getController("valve1").setColorBackground(color(#5c5c5c));
     }

     else{
      cp5.getController("valve1").setColorActive(color(#57ebe0));
      cp5.getController("valve1").setColorBackground(color(#5c5c5c));
     }

     cp5.getController("valve1").setValue(valve_state_1);

     if(temp_sensor_1 > 180)
     temperatureKnob.setColorForeground(color(#ff0000));

     if(press_sensor_1 > 15)
     pressureKnob.setColorForeground(color(#ff0000));
     */
      }
    } else
    {
      println("Buffer is null");
    }
  }
  catch (Exception e) {
    println("Something went wrong in serialEvent: " + e);
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
  size(1300, 500);
  smooth(4);
  tx_json = new JSONObject();

  // get the number of serial ports in the list
  num_serial_ports = Serial.list().length;

  cp5 = new ControlP5(this);


  //Group g1= cp5.addGroup("a").setPosition(100,100).setWidth(180);
  //Group g2= cp5.addGroup("b").setPosition(200,200).setWidth(180);
  
  // create a DropdownList,

  
  cp5.addButton("refreshPorts")
  .setPosition(tunning_values_x_pos, tunning_values_y_pos-28)
  .setSize(155,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#0670FF))
  .setColorBackground(color(#3990b3))
  .setColorLabel(color(#000000))
  ;
  


  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("connect")
  .setPosition(tunning_values_x_pos,tunning_values_y_pos+10)
  .setSize(75,25)
  .setValue(false)
  .setMode(ControlP5.SWITCH)
  .setColorBackground(color(#5c5c5c))
  .setColorActive(color(#ba2929));

   startButton = cp5.addToggle("Start")
  .setPosition(tunning_values_x_pos+80,tunning_values_y_pos+10)
  .setSize(75,25)
  .setValue(false)
  .setMode(ControlP5.SWITCH)
  .setColorBackground(color(#5c5c5c))
  .setColorActive(color(#ba2929));

/*
  closeAllValve =cp5.addButton("closeAllValve")
  .setPosition(tunning_values_x_pos+190,tunning_values_y_pos-65)
  .setSize(110,25)
  .setValue(1)
  .setColorActive(color(#1986e6))
  .setColorForeground(color(#0670FF))
  .setColorBackground(color(#3990b3))
  .setColorLabel(color(#000000));

  cp5.addSlider("slider")
  .setPosition(tunning_values_x_pos+190,tunning_values_y_pos-20)
  .setSize(110,25)
  .setRange(0,200)
  .setValue(128)
  .setColorBackground(color(#3990b3));

  cp5.getController("slider").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  setMaxTemp=cp5.addButton("SetMaxTemp")
  .setPosition(tunning_values_x_pos+190,tunning_values_y_pos+20)
  .setSize(110,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#0670FF))
  .setColorBackground(color(#3990b3))
  .setColorLabel(color(#000000))
  .lock();
  /*cp5.addToggle("valve1")
  .setPosition(tunning_values_x_pos+600,tunning_values_y_pos)
  .setSize(50,25)
  .setValue(false)
  .setMode(ControlP5.SWITCH)
  .setColorBackground(color(#5c5c5c))
  .setColorActive(color(#3e44ec))
  .lock();*/



  cp5.addButton("consoleClearFunc")
  .setPosition(tunning_values_x_pos,tunning_values_y_pos+310)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#0670FF))
  .setColorBackground(color(#3990b3))
  .setColorLabel(color(#000000));

  cp5.addButton("connectSimulation")
  .setPosition(tunning_values_x_pos,tunning_values_y_pos+350)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#0670FF))
  .setColorBackground(color(#3990b3))
  .setColorLabel(color(#000000));



cp5.addTextlabel("label")
.setText("Logs")
.setPosition(tunning_values_x_pos,tunning_values_y_pos+75)
.setColorValue(#FFFFFF)
.setFont(createFont("Helvetica",14));


  myTextarea = cp5.addTextarea("txt")
                  .setPosition(tunning_values_x_pos,tunning_values_y_pos+100)
                  .setSize(180, 200)
                  .setFont(createFont("Helvetica", 8))
                  .setLineHeight(14)
                  .setColor(color(#57ebe0))
                  .setColorBackground(color(#383a39))
                  .setColorForeground(color(#0670ff));

 console = cp5.addConsole(myTextarea);


myTextlabelB = new Textlabel(cp5,"Input",tunning_values_x_pos+700,tunning_values_y_pos+75,400,200);
myTextlabelB.setColorValue(#FFFFFF);
myTextlabelB.setFont(createFont("Helvetica",14));

  myTextarea2 = cp5.addTextarea("rx_json_textarea")
                  .setPosition(tunning_values_x_pos+190,tunning_values_y_pos+100)
                  .setSize(180, 200)
                  .setFont(createFont("Helvetica", 8))
                  .setLineHeight(14)
                  .setColor(color(#54f3d3))
                  .setColorBackground(color(#383a39))
                  .setColorForeground(color(#0670FF));
  ;


// Meter Scale for temperature
  String[] scaleLabelsT = {"0", "20", "40", "60", "80", "100",  "120",  "140", "160",  "180",  "200" };     
    //Meter Scale for pressure
  String[] scaleLabelsH = {"0", "10", "20"};
    
    m1 = new Meter(this, tunning_values_x_pos+410,tunning_values_y_pos+100);
    m1.setMeterWidth(int(180));
        m1.setScaleLabels(scaleLabelsT);
  // Adjust font color of meter value  
    m1.setTitleFontSize(20);
    m1.setTitle("In Temperature (C)");
    m1.setScaleFontSize(12);
    m1.setScaleFontName("Times New Roman bold");
    m1.setScaleFontColor(color(200, 30, 70));
    m1.setArcThickness(5);
    m1.setMaxScaleValue(200);
    m1.setNeedleThickness(3);
    m1.setMinInputSignal(0);
    m1.setMaxInputSignal(200);
    m1.setFrameColor(color(0, 0, 0));
    m1.setTitleFontColor(color(0, 0, 0));
    m1.setPivotPointColor(color(0, 0, 0));
    m1.setArcColor(color(0, 0, 0));
    m1.setScaleFontColor(color(0, 0, 0));
    m1.setTicMarkColor(color(0, 0, 0));
    m1.setDisplayDigitalMeterValue(true);
    
  m2 = new Meter(this, tunning_values_x_pos+590, tunning_values_y_pos+100);
  m2.setMeterWidth(int(180));
  m2.setScaleLabels(scaleLabelsH);

  // Adjust font color of meter value  
    m2.setTitleFontSize(20);
    m2.setTitle("In Pressure (Bar)");
    m2.setScaleFontSize(12);
    m2.setScaleFontName("Times New Roman bold");
    m2.setScaleFontColor(color(200, 30, 70));
    m2.setArcThickness(5);
    m2.setMaxScaleValue(80);
    m2.setNeedleThickness(3);
    m2.setMinInputSignal(0);
    m2.setMaxInputSignal(80);
    m2.setFrameColor(color(0, 0, 0));
    m2.setTitleFontColor(color(0, 0, 0));
    m2.setPivotPointColor(color(0, 0, 0));
    m2.setArcColor(color(0, 0, 0));
    m2.setScaleFontColor(color(0, 0, 0));
    m2.setTicMarkColor(color(0, 0, 0));
    m2.setDisplayDigitalMeterValue(true);
  
    m3 = new Meter(this, tunning_values_x_pos+410,tunning_values_y_pos+210);
    m3.setMeterWidth(int(180));
    m3.setScaleLabels(scaleLabelsT);
  // Adjust font color of meter value  
    m3.setTitleFontSize(20);
    m3.setTitleFontName("Arial bold");
    m3.setTitle("Out Temperature (C)");
    m3.setScaleFontSize(12);
    m3.setScaleFontColor(color(200, 30, 70));
    m3.setArcThickness(5);
    m3.setMaxScaleValue(200);
    m3.setNeedleThickness(3);
    m3.setMinInputSignal(0);
    m3.setMaxInputSignal(200);
    m3.setFrameColor(color(0, 0, 0));
    m3.setTitleFontColor(color(0, 0, 0));
    m3.setPivotPointColor(color(0, 0, 0));
    m3.setArcColor(color(0, 0, 0));
    m3.setScaleFontColor(color(0, 0, 0));
    m3.setTicMarkColor(color(0, 0, 0));
    m3.setDisplayDigitalMeterValue(true);
    
     m4 = new Meter(this, tunning_values_x_pos+590,tunning_values_y_pos+210);
    m4.setMeterWidth(int(180));
    m4.setScaleLabels(scaleLabelsH);
  // Adjust font color of meter value  
    m4.setTitleFontSize(20);
    m4.setTitleFontName("Arial bold");
    m4.setTitle("Out Pressure (Bar)");
    m4.setScaleFontSize(12);
    m4.setScaleFontColor(color(200, 30, 70));
    m4.setArcThickness(5);
    m4.setMaxScaleValue(80);
    m4.setNeedleThickness(3);
    m4.setMinInputSignal(0);
    m4.setMaxInputSignal(80);
    m4.setFrameColor(color(0, 0, 0));
    m4.setTitleFontColor(color(0, 0, 0));
    m4.setPivotPointColor(color(0, 0, 0));
    m4.setArcColor(color(0, 0, 0));
    m4.setScaleFontColor(color(0, 0, 0));
    m4.setTicMarkColor(color(0, 0, 0));
    m4.setDisplayDigitalMeterValue(true);

  

   img = loadImage("img/logo-inv.png");
   diagram = loadImage("img/diagram.png");
   diagram.resize(0, 550);
   
   
   //dropdownlist should be intialiazed at last
    d1 = cp5.addDropdownList("serialPortList")
  .setPosition(tunning_values_x_pos, tunning_values_y_pos-65)
  .setOpen(false)
  .setBackgroundColor(color(#1986e6))
  .setColorActive(color(#0670FF))
  .setColorBackground(color(#3990b3))
  .setColorCaptionLabel(color(#0670FF))
  .setColorForeground(color(#0670FF))
  .setColorLabel(color(#000000))
  .setColorValue(color(#0670FF))
  .setColorValueLabel(color(#000000))
  .setItemHeight(25)
  .setHeight(200)
  .setBarHeight(25)
  .setWidth(155)
  .bringToFront();

  customize(d1);
   


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
    /*if(startButton.getValue() == 1)
{
     _json.setFloat("max_temp", max_temp);
     _json.setInt("close_all_valves",0);
     if (closeValve)
     {
     _json.setInt("close_all_valves",1);
     }
}*/

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
    cp5.getController("Start").setColorActive(color(#3e44ec));
    cp5.getController("Start").setColorBackground(color(#5c5c5c));
  }
  else
  {
    cp5.getController("SetMaxTemp").unlock();
    cp5.getController("closeAllValve").unlock();
    cp5.getController("Start").setColorActive(color(#57ebe0));
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

  public void connectSimulation(float clicked)
  {
    println("Connect simulation: "+clicked);
    if(clicked==0 && serial_port == null)
    {
    try{
          serial_port = new Serial(this, "/dev/pts/4", COM_BAUDRATE);
          serial_port.clear();
          serial_port.bufferUntil('\n');
        }
        catch (Exception e) {
          println(e);
        }
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
    cp5.getController("connect").setColorActive(color(#57ebe0));
    cp5.getController("connect").setColorBackground(color(#5c5c5c));
    cp5.getController("serialPortList").setLock(true);
    cp5.getController("serialPortList").setColorBackground(color(#5c5c5c));
    cp5.getController("calibrateSensors").setColorBackground(color(#5c5c5c));
    println("Connect");
  }

  void unlockButtons()
  {
    cp5.getController("connect").setColorActive(color(#3e44ec));
    cp5.getController("connect").setColorBackground(color(#5c5c5c));
    cp5.getController("serialPortList").setLock(false);
    cp5.getController("serialPortList").setColorBackground(color(#57ebe0));
    cp5.getController("calibrateSensors").setColorBackground(color(#57ebe0));
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

  void diagramControl()
  {
    noFill();
    strokeWeight(2);

    // Water pump
    if(water_pump){stroke(#03f5e3);}else{stroke(#6d6b6b);}
    rect(DIAG_X+25, DIAG_Y+65, 40, 40, 4);

    // Input valve
    if(valve_0){stroke(#03f5e3);}else{stroke(#6d6b6b);}
    rect(DIAG_X+110, DIAG_Y+115, 30, 30, 4);

    // Heaters
    if(heater){stroke(#f30404);}else{stroke(#6d6b6b);}
    rect(DIAG_X+75, DIAG_Y+200, 20, 100, 4);
    rect(DIAG_X+165, DIAG_Y+200, 20, 100, 4);
    
    
    // 3.2
    if(valve_1){stroke(#03f5e3);}else{stroke(#6d6b6b);}
    rect(DIAG_X+115, DIAG_Y+375, 37, 40, 4);
    
    // 3.3
    if(valve_2){stroke(#03f5e3);}else{stroke(#6d6b6b);}
    rect(DIAG_X+250, DIAG_Y+375, 37, 40, 4);

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
    void createBoxes()
    {
      
    stroke(0, 0, 0);
     //start
    rect(50, 20, 170, 120);
     //box around Setting values
    //rect(240, 20, 130, 120);
   
   //box around  guages
  rect(465, 185, 370, 230);   
 
   //box around logs
    rect(50, 180, 390, 250);
    
   //Time
   //rect(465, 120, 135, 40);  
   
   rect(1140, 440, 135, 40);  
  }
  
  void texts()
  {
  textFont(createFont("Helvetica",14));
     //box around connect
    fill(#ffffff);
    text("Start", tunning_values_x_pos, tunning_values_y_pos-75);  
    //text("Inputs",tunning_values_x_pos+190, tunning_values_y_pos-75);
    text("Guages",tunning_values_x_pos+425, tunning_values_y_pos+90);
     text("Timer", 1140, 435);  
 

  }
  
  
  
 void showMeters()
 {
    m1.updateMeter(int(temp_sensor_1));
    m2.updateMeter(int(press_sensor_1));
    m3.updateMeter(int(temp_sensor_2));
    m4.updateMeter(int(press_sensor_2));
 }
  /**
  Main function to create the user interface
  @param none
  @return void
  */
  void draw()
  {
    background(#3d7c91);
    image(img, 1280-20-(369/3), 20, 369/3, 295/3);
    image(diagram, DIAG_X, DIAG_Y);
    textSize(32);
    text(timer, 1160, 470);
    diagramControl();
           
    showMeters();
    
    createBoxes();
    texts();


    
  }
   
   
  
