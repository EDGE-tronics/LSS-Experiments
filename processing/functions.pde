// Buttons
Button createButton(String name, String label, float x, float y, int sizex, int sizey){
  return cp5.addButton(name)
            .setCaptionLabel(label)
            .setPosition(x,y)
            .setSize(sizex,sizey)
            .align(1,1,CENTER,1)
            .setColorForeground(color(57,57,57))
            .setColorBackground(color(57,57,57))
            .setColorActive(color(254, 175, 60))
            .setFont(createFont("data/roboto.ttf", 20));
}

// Labels
void createLabel(String name, String label, float x, float y){
  cp5.addTextlabel(name)
    .setText(label)
    .setPosition(x,y)
    .setColorValue(255)
    .setFont(roboto);
}

// Lists
void createList(String name, float x, float y, int sizex, int sizey, List options, int opt){
  CColor cl = new CColor();
  cl.setBackground(color(57, 57, 57));

  cp5.addScrollableList(name)
     .setPosition(x,y)
     .setSize(sizex,sizey)
     .setBarHeight(30)
     .setItemHeight(30)
     .addItems(options)
     .setColor(cl)
     .setValue(opt)
     .setFont(createFont("data/roboto.ttf", 18))
     .setColorForeground(0xffC85A00)
     .setType(ScrollableList.DROPDOWN);
}

// Direct command
void sendCMD(){
  String cmd = cp5.get(Textfield.class,"direct").getText().toUpperCase();
  if (!cmd.isEmpty()){
    if (cmd.charAt(0) != '#') cmd = '#' + cmd + '\r';
  }
  //usb.write(cmd);
  cp5.get(Textfield.class,"direct").clear();
}

void tiltPlus(){
  if (cp5.getController("tilt_slider").getValue() + 5 < cp5.getController("tilt_slider").getMax()) {
    cp5.get(Textfield.class, "tilt_input").setText(nf(cp5.getController("tilt_slider").getValue()+5, 0, 1).replace(',', '.'));
    cp5.getController("tilt_slider").setValue(int(cp5.get(Textfield.class, "tilt_input").getText()));
  }
  else{
    cp5.get(Textfield.class, "tilt_input").setText(str(cp5.getController("tilt_slider").getMax()));
    cp5.getController("tilt_slider").setValue(cp5.getController("tilt_slider").getMax());
  }
}

void tiltMinus(){
  if (cp5.getController("tilt_slider").getValue() - 5 > cp5.getController("tilt_slider").getMin()) {
    cp5.get(Textfield.class, "tilt_input").setText(nf(cp5.getController("tilt_slider").getValue()-5, 0, 1).replace(',', '.'));
    cp5.getController("tilt_slider").setValue(int(cp5.get(Textfield.class, "tilt_input").getText()));
  }
  else{
    cp5.get(Textfield.class, "tilt_input").setText(str(cp5.getController("tilt_slider").getMin()));
    cp5.getController("tilt_slider").setValue(cp5.getController("tilt_slider").getMin());
  }
}

void panPlus(){
  if (cp5.getController("pan_slider").getValue() + 5 < cp5.getController("pan_slider").getMax()) {
    cp5.get(Textfield.class, "pan_input").setText(nf(cp5.getController("pan_slider").getValue()+5, 0, 1).replace(',', '.'));
    cp5.getController("pan_slider").setValue(int(cp5.get(Textfield.class, "pan_input").getText()));
  }
  else{
    cp5.get(Textfield.class, "pan_input").setText(str(cp5.getController("pan_slider").getMax()));
    cp5.getController("pan_slider").setValue(cp5.getController("pan_slider").getMax());
  }
}

void panMinus(){
  if (cp5.getController("pan_slider").getValue() - 5 > cp5.getController("pan_slider").getMin()) {
    cp5.get(Textfield.class, "pan_input").setText(nf(cp5.getController("pan_slider").getValue()-5, 0, 1).replace(',', '.'));
    cp5.getController("pan_slider").setValue(int(cp5.get(Textfield.class, "pan_input").getText()));
  }
  else{
    cp5.get(Textfield.class, "pan_input").setText(str(cp5.getController("pan_slider").getMin()));
    cp5.getController("pan_slider").setValue(cp5.getController("pan_slider").getMin());
  }
}

//Reset
void reset(){
  cp5.get(Textfield.class, "pan_input").setText("0.0");
  cp5.getController("pan_slider").setValue(0.0);
  cp5.get(Textfield.class, "tilt_input").setText("0.0");
  cp5.getController("tilt_slider").setValue(0.0);
}

void invert(){
  if (cp5.getController("invert").getValue() == 1) orientation = 1;
  else orientation = -1; 
  if (comSel && Serial.list().length != 0) usb.write("#254G" + str(orientation) + "\r");
}

void LED(int n) {
  if (comSel && Serial.list().length != 0) usb.write("#254LED" + n + "\r");
}

void speedSel(int n) {
  String selectedSpeed = cp5.get(ScrollableList.class, "speedSel").getItem(n).get("name").toString();
  if (comSel && Serial.list().length != 0)  usb.write("#254SR" + selectedSpeed + "\r");
}

// Change communication method
void COMmenu(int n) {
  switch(n){
    case 1:
      comSel = true;
      if (Serial.list().length != 0){
        usb = new Serial(this, Serial.list()[0], 115200);
        usb.write("#254EM0\r");
        delay(200);
        usb.write("#254FPC20\r");
      }
      break;
    default:
      comSel = false;
      break;
  }
}

void emergencySTOP(){
   labelMSG = "EMERGENCY STOP";
   showLabel = true;
   if (comSel && Serial.list().length != 0) {
     usb.write("#254H\r");
     usb.write("#254RESET\r");
     delay(1000);
     usb.write("#254LED2\r");
   }
}

void halt(){
  if(limpButton.isOn()) limpButton.setOff();
  if(haltButton.isOn()){
    labelMSG = "Please wait while the servos stop";
    time = millis();
    showLabel = true;
    usb.write("#254H\r");
  }
}

void limp(){
   if(limpButton.isOn()){
     labelMSG = "Please wait while the servos go limp";
     time = millis();
     showLabel = true;
     usb.write("#254L\r");
   }
   else usb.write("#254H\r");
}

void calibration(){
   if(!limpButton.isOn()){
     labelMSG = "Press LIMP & position the servos";
     time = millis();
     showLabel = true;
     usb.write("#254LED1\r");
     calibrateButton.setOff();
   }
   else if(calibrateButton.isOn()){
     usb.write("#254CO\r");
     delay(100);
     labelMSG = "Calibrateion successful";
     time = millis();
     showLabel = true;
   }
   calibrateButton.setOff();
   limpButton.setOff();
   usb.write("#254LED" + str(cp5.get(ScrollableList.class, "LED").getValue()) + "\r");
}

void mousePressed() {
  if (!cp5.get(ScrollableList.class, "BAUDmenu").isMouseOver()) {    
    cp5.get(ScrollableList.class, "BAUDmenu").close();
  }
  if (!cp5.get(ScrollableList.class, "COMmenu").isMouseOver()) {    
    cp5.get(ScrollableList.class, "COMmenu").close();
  }
  if (!cp5.get(ScrollableList.class, "speedSel").isMouseOver()) {    
    cp5.get(ScrollableList.class, "speedSel").close();
  }
  if (!cp5.get(ScrollableList.class, "LED").isMouseOver()) {    
    cp5.get(ScrollableList.class, "LED").close();
  }
  if (infoButton.isOn()) {
    if (mouseX >= 0.8*width){
      if (mouseY > headerHeight*0.65 && mouseY < headerHeight*0.65+20) link("https://www.youtube.com/channel/UCkTFc5mqRC0YSArZ_RmEZ7g");
      else if (mouseY >= headerHeight*0.65+20 && mouseY < headerHeight*0.65+40) link("https://github.com/EDGE-tronics/LSS-Experiments");
      else if (mouseY >= headerHeight*0.65+40 && mouseY < headerHeight*0.65+60) link("https://www.instagram.com/edgetronics/?hl=en");
    }
  }
}

void keyPressed() {
  if (!cp5.get(Textfield.class, "direct").isMouseOver() && !sendButton.isMouseOver()){
    if (key == CODED){
      switch(keyCode){
        case UP:
          tiltPlus();
          break;
        case DOWN:
          tiltMinus();
          break;
        case LEFT:
          panPlus();
          break;
        case RIGHT:
          panMinus();
          break;
      }
    }
  }
}
