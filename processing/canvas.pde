/*
 *  Author:     EDGEtronics
 *  Version:    1.0
 *  Licence:    GNU General Public License v3.0
 *  
 *  Description:  Control interface for LSS based pan-tilt
 */
 
import controlP5.*;
import java.util.*;
import java.util.regex.*;
import processing.serial.*;
import processing.video.*;
ControlP5 cp5;

//Canvas variables
boolean showLabel = false, comSel;
int headerHeight = 115, orientation = 1;
Button infoButton, sendButton, resetButton, tp, tm, pp, pm;
Button haltButton, limpButton, calibrateButton, stopButton;
PGraphics header, middleCanvas;
PImage logo;
PFont robotoTitle, roboto;
Textlabel textLabel, invertlabel;
String labelMSG = "";
Textarea infoBox;
Serial usb;
Capture video;
long time = millis();

void settings() {
  size(830, 600);
}

void setup() {
  header = createGraphics(width, headerHeight);
  middleCanvas = createGraphics(width, height-headerHeight);
  
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
  }
  video = new Capture(this, Capture.list()[cameras.length-1]);
  video.start();
  
  logo = loadImage("data/logo.png");
  roboto = createFont("data/roboto.ttf", 20);
  robotoTitle = createFont("data/roboto.ttf", 30);
  
  cp5 = new ControlP5(this);
  
  CColor c = new CColor();
  c.setBackground(color(0, 0, 0));
    
  PImage[] info = {loadImage("data/info1.png"), loadImage("data/info2.png"), loadImage("data/info3.png")};
  infoButton = createButton("INFO", "", width-50, headerHeight*0.3-15, 20, 20);
  infoButton.setImages(info);
  infoButton.setSwitch(true);
  infoButton.setOff();
  
  c.setBackground(color(57, 57, 57));
  
  textLabel = cp5.addTextlabel("label")
    .setText(labelMSG)
    .setPosition(50, headerHeight+20)
    .setColorValue(255)
    .setFont(robotoTitle)
    .hide();
  
  int min = 0, max = 0;
  String label = "";
  
  createLabel("TILT", "TILT", 35, headerHeight+35);
  
  cp5.addTextfield("tilt_input")
    .setPosition(40, headerHeight+70)
    .setSize(200, 25)
    .setFont(roboto)
    .setAutoClear(false)
    .setColorBackground(color(255))
    .setColor(color(254, 175, 60))
    .setLabelVisible(false)
    .setText("0.0")
    .setColorCaptionLabel(color(125))
    .onMove(new CallbackListener() {
      void controlEvent(CallbackEvent theEvent) {
          //Check min & max values
          float inputVal = float(cp5.get(Textfield.class, "tilt_input").getText());
          if (inputVal < cp5.getController("tilt_slider").getMin()) inputVal = cp5.getController("tilt_slider").getMin();
          else if (inputVal > cp5.getController("tilt_slider").getMax()) inputVal = cp5.getController("tilt_slider").getMax();
          
          //Update inputs
          cp5.getController("tilt_slider").setValue(inputVal);
          cp5.get(Textfield.class, "tilt_input").setText(str(inputVal));
          
          //Send command
          if (comSel && Serial.list().length != 0) usb.write("#1D" + str(inputVal) + "\r");
        }
    }
    );

  cp5.addSlider("tilt_slider")
    .setPosition(40, headerHeight+100)
    .setSize(200, 22)
    .setRange(-45, 45)
    .setValue(0)
    .setLabelVisible(false)
    .setColorCaptionLabel(color(125))
    .setColorActive(0xff000000)
    .setColorForeground(color(254, 175, 60))
    .setColorBackground(0xffffffff)
    .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        //Update inputs
        cp5.get(Textfield.class, "tilt_input").setText(nf(cp5.getController("tilt_slider").getValue(), 0, 1).replace(',', '.'));
        int angle = int(cp5.getController("tilt_slider").getValue()*10);
        
        //Send command
        if (comSel && Serial.list().length != 0){
          usb.write("#1D" + str(angle) + "\r");
          println(angle);
        }
      }
    }
    );
    
  tp = createButton("tp", "+", 250, cp5.getController("tilt_input").getPosition()[1], 25, 25);
  tp.onChange(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      tiltPlus();
    }
  }
  );
  
  tm = createButton("tm", "-", 250, cp5.getController("tilt_slider").getPosition()[1]-2, 25, 25);
  tm.onChange(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      tiltMinus();
    }
  }
  );
  
  createLabel("PAN", "PAN", 35, headerHeight+135);
  
  cp5.addTextfield("pan_input")
    .setPosition(40, headerHeight+170)
    .setSize(200, 25)
    .setFont(roboto)
    .setAutoClear(false)
    .setColorBackground(color(255))
    .setColor(color(200, 90, 0))
    .setLabelVisible(false)
    .setText("0.0")
    .setColorCaptionLabel(color(125))
    .onMove(new CallbackListener() {
      void controlEvent(CallbackEvent theEvent) {
          //Check min & max values
          float inputVal = float(cp5.get(Textfield.class, "pan_input").getText());
          if (inputVal < cp5.getController("pan_slider").getMin()) inputVal = cp5.getController("pan_slider").getMin();
          else if (inputVal > cp5.getController("pan_slider").getMax()) inputVal = cp5.getController("pan_slider").getMax();
          
          //Update inputs
          cp5.getController("pan_slider").setValue(inputVal);
          cp5.get(Textfield.class, "pan_input").setText(str(inputVal));
          
          //Send command
          if (comSel && Serial.list().length != 0) usb.write("#0D" + str(inputVal) + "\r");
        }
    }
    );

  cp5.addSlider("pan_slider")
    .setPosition(40, headerHeight+200)
    .setSize(200, 22)
    .setRange(-90, 90)
    .setValue(0)
    .setLabelVisible(false)
    .setColorCaptionLabel(color(125))
    .setColorActive(0xff000000)
    .setColorForeground(color(200, 90, 0))
    .setColorBackground(0xffffffff)
    .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        //Update inputs
        cp5.get(Textfield.class, "pan_input").setText(nf(cp5.getController("pan_slider").getValue(), 0, 1).replace(',', '.'));
        int angle = int(cp5.getController("pan_slider").getValue()*10);
        
        //Send command
        if (comSel && Serial.list().length != 0) usb.write("#0D" + str(angle) + "\r");
      }
    }
    );
    
  pp = createButton("pp", "+", 250, cp5.getController("pan_input").getPosition()[1], 25, 25);
  pp.onChange(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      panPlus();
    }
  }
  );
  
  pm = createButton("pm", "-", 250, cp5.getController("pan_slider").getPosition()[1]-2, 25, 25);
  pm.onChange(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      panMinus();
    }
  }
  );
  
  createLabel("directCMD", "DIRECT COMMAND", 35, headerHeight+235);

  cp5.addTextfield("direct")
    .setPosition(40, headerHeight+270)
    .setSize(170, 30)
    .setFont(roboto)
    .setAutoClear(false)
    .setColorBackground(color(255))
    .setColor(color(57))
    .setLabelVisible(false)
    .setColorCaptionLabel(color(125))
    .setCaptionLabel("");
    
  sendButton = createButton("SEND", "SEND", 215, headerHeight+270, 60, 30);
  sendButton.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      sendCMD();
    }
  });
    
  createLabel("invertlabel", "INVERT          RESET", 60, headerHeight+320);
  
  cp5.addToggle("invert")
    .setPosition(80, headerHeight+353)
    .setSize(40, 20)
    .setValue(true)
    .setLabelVisible(false)
    .setColorActive(color(57))
    .setColorBackground(0xffffffff)
    .setMode(ControlP5.SWITCH)
    .onChange(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
         invert();  
      }
    });

  resetButton = createButton("RESET", "R", 190, headerHeight+350, 40, 25);
  resetButton.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      reset();
    }
  });
  
  createLabel("speedL", "SPEED", 65, headerHeight+390);
  createList("speedSel", 80, headerHeight+420, 40, 4*20, Arrays.asList("30", "40", "50", "60"), 3);

  createLabel("labelLED", "LED", 185, headerHeight+390);
  createList("LED", 170, headerHeight+420, 80, 4*20, Arrays.asList(" OFF", " RED", " GREEN", " BLUE", " YELLOW", " CYAN", " PINK", " WHITE"), 2);
  
  createList("COMmenu", width-65, headerHeight*0.7, 60, 3*30, Arrays.asList(" OFF", " USB"), 0);

  createList("BAUDmenu", cp5.getController("COMmenu").getPosition()[0]-85, headerHeight*0.7, 80, 6*30, Arrays.asList(" 9600", " 19200", " 38400", " 57600", " 115200"), 4);

  haltButton = createButton("HOLD", "HOLD", cp5.getController("BAUDmenu").getPosition()[0]-65, headerHeight*0.7, 60, 30);
  haltButton.setColor(c);
  haltButton.setFont(createFont("data/roboto.ttf", 18));
  haltButton.onChange(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (comSel && Serial.list().length != 0) halt();
    }
  });
  
  limpButton = createButton("LIMP", "LIMP", haltButton.getPosition()[0]-65, headerHeight*0.7, 60, 30);
  limpButton.setColor(c);
  limpButton.setFont(createFont("data/roboto.ttf", 18));
  limpButton.setSwitch(true);
  limpButton.setOff();
  limpButton.onChange(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (comSel && Serial.list().length != 0) limp();
    }
  });
  
  calibrateButton = createButton("CALIBRATE", "CALIBRATE", limpButton.getPosition()[0]-115, headerHeight*0.7, 110, 30);
  calibrateButton.setValue(0);
  calibrateButton.setColor(c);
  calibrateButton.setFont(createFont("data/roboto.ttf", 18));
  calibrateButton.setSwitch(true);
  calibrateButton.setOff();
  calibrateButton.onClick(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (comSel && Serial.list().length != 0) calibration();
    }
  });
  
  stopButton = createButton("EMERGENCY", "RESET", calibrateButton.getPosition()[0]-70, headerHeight*0.7, 65, 30);
  stopButton.setColor(c);
  stopButton.setFont(createFont("data/roboto.ttf", 18));
  stopButton.setSwitch(true);
  stopButton.setOff();
  stopButton.onChange(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      if (comSel && Serial.list().length != 0) emergencySTOP();
    }
  });
  
  infoBox = cp5.addTextarea("information")
    .setPosition(width - 130, headerHeight*0.65)
    .setSize(150, 60)
    .setLineHeight(30)
    .setColor(color(57))
    .setColorBackground(color(255))
    .setFont(createFont("data/roboto.ttf", 18))
    .bringToFront()
    .hide()
    .setText(" Youtube \n"
    +" Github \n"
    +" Instagram"
    );
}

void draw() {
  // Counter for interface message
  if (time - millis() > 1500) showLabel = false;
  time = millis();
  
  middleCanvas.beginDraw();
  drawMiddleCanvas();
  image(middleCanvas, -1/2*width, -1/2*height+headerHeight);
  image(video, -1/2*width+310, -1/2*height+headerHeight+70, 640*3/4, 480*3/4);
  middleCanvas.endDraw();
  
  header.beginDraw();
  drawHeader();
  image(header, -1/2*width, -1/2*height);
  header.endDraw();
}

void drawHeader() {
  push();
  noStroke();
  fill(57);
  rect(-1/2*width, -1/2*height, width, headerHeight*0.65);
  fill(254, 175, 60);
  rect(-1/2*width, -1/2*height+headerHeight*0.65, width, headerHeight*0.35);
  pop();
  fill(255);
  textFont(robotoTitle);
  text("LSS PAN-TILT", width-250, 0.45*headerHeight);
  image(logo, -1/2*width, -1/2*height+0.1*headerHeight, 2.4*headerHeight, headerHeight);
}

void drawMiddleCanvas() {
  middleCanvas.background(125);
  if (showLabel) {
    textLabel.setText(labelMSG);
    textLabel.show();
  } else textLabel.hide();
  
  if (infoButton.isOn()) infoBox.show();
  else infoBox.hide();
}

void captureEvent(Capture video) {
  video.read();
}

void exit() {
   super.exit();
}
