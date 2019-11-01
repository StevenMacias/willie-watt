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

// Configuration constants

//static final String COM_PORT  = "COM4";
static final int COM_BAUDRATE = 38400;
static final int SCREEN_W = 1180;
static final int SCREEN_H = 500;


// Window constants
static final int text_size          = 12;
static final int background_color   = 0;


static final int tunning_values_x_pos    = 60;
static final int tunning_values_y_pos    = 60;
static final boolean DEBUG_ON            = false;

DropdownList d1;
JSONObject tx_json;
Textarea myTextarea;
Textarea myTextarea2;
Println console;
Knob baseSpeedKnob;

// serial port buttons
String serial_list;                // list of serial ports
int serial_list_index = 0;         // currently selected serial port
int num_serial_ports = 0;          // number of serial ports in the list


// variables for the coordinates
float press_sensor_1         = 0;
float temp_sensor_1          = 0;
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
        array_values = json.getJSONArray("array_values");
        // Get the values of the accelerometer
        press_sensor_1 = json.getFloat("press_sensor_1");
        temp_sensor_1 = json.getFloat("temp_sensor_1");
        uControllerState = json.getInt("uControllerState");
        myTextarea2.setText(json.toString());

      }
    } else
    {
      println("Buffer is null");
    }
  }
  catch (Exception e) {
    println("Initialization exception");
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
  ;
  customize(d1);

  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("connect")
  .setPosition(tunning_values_x_pos+400,tunning_values_y_pos)
  .setSize(50,25)
  .setValue(false)
  .setMode(ControlP5.SWITCH)
  .setColorBackground(color(#5c5c5c))
  .setColorActive(color(#f35454))
  ;

  cp5.addButton("refreshPorts")
  .setPosition(tunning_values_x_pos+150,tunning_values_y_pos)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000))
  ;

  cp5.addButton("consoleClearFunc")
  .setPosition(tunning_values_x_pos,tunning_values_y_pos+310)
  .setSize(100,25)
  .setValue(0)
  .setColorActive(color(#6fe619))
  .setColorForeground(color(#216329))
  .setColorBackground(color(#54f367))
  .setColorLabel(color(#000000))
  ;


  myTextarea = cp5.addTextarea("txt")
                  .setPosition(tunning_values_x_pos,tunning_values_y_pos+100)
                  .setSize(380, 200)
                  .setFont(createFont("arial", 10))
                  .setLineHeight(14)
                  .setColor(color(#54f367))
                  .setColorBackground(color(#383a39))
                  .setColorForeground(color(#216329));
  ;
  console = cp5.addConsole(myTextarea);//

  myTextarea2 = cp5.addTextarea("rx_json_textarea")
                  .setPosition(tunning_values_x_pos+700,tunning_values_y_pos)
                  .setSize(380, 300)
                  .setFont(createFont("arial", 10))
                  .setLineHeight(14)
                  .setColor(color(#54f3d3))
                  .setColorBackground(color(#383a39))
                  .setColorForeground(color(#216329));
  ;

  baseSpeedKnob = cp5.addKnob("baseSpeedValue")
               .setRange(0,255)
               .setValue(50)
               .setPosition(tunning_values_x_pos+400,tunning_values_y_pos+100)
               .setRadius(50)
               .setNumberOfTickMarks(10)
               .setTickMarkLength(4)
               .snapToTickMarks(true)
               .setColorForeground(color(#54f367))
               .setColorBackground(color(#216329))
               .setColorActive(color(255,255,0))
               .setDragDirection(Knob.HORIZONTAL)
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

  public void refreshPorts(int theValue) {
    println("Refresh ports: "+theValue);
    customize(d1);
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
  }
