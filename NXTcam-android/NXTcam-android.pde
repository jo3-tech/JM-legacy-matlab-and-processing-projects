//==SKETCH PERMISSIONS===================================================================================================================
//you must tick bluetooth, bluetooth_admin, camera & write_external_storage

//==LIBRARIES============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
import android.view.WindowManager;  // these 2 required to access commands that prevent screen from sleeping/backlight going off
import android.view.View;
import android.content.Intent;      // these 2 required to enable BT on startup?
import android.os.Bundle;  
import android.view.KeyEvent;  //  for soft key (virtual keyboard) & hard key (hard buttons) input

import ketai.ui.*;             // NOTE: Ketai_v9_gingerbread(2.3.7) is being used

import ketai.camera.*;         

import ketai.net.bluetooth.*;
import ketai.net.*;

import Blobscanner.*;

//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
int gwW,gwH;           // declare variables to store graphics window width & height
int dwW,dwH;           // to store development window width & height
float wSF,hSF;         // scale factors for scaling with respect to screen width & height
//---------------------------------------------------------------------------------------------------------------------------------------
PImage introI;         // intro image
int introT;            // total time to show the intro
PImage bgI;            // main background image
PImage exitI;          // exit image
float xoff = 0.0;      // ??
//---------------------------------------------------------------------------------------------------------------------------------------
int camW,camH,fR;         // to store video/cam width & height, & frame rate
//---------------------------------------------------------------------------------------------------------------------------------------
PImage iRGBI;          // to store acquired image(s)
PImage oSEGI;          // to store the segmented output image
float[] aveRGB;        // average of R, G & B components of colour to track 
float T;               // threshold for creating segmented image output
//---------------------------------------------------------------------------------------------------------------------------------------
String device_name;    // device name="Joe-NXT"           
byte[] cmd;            // to store bluetooth message package
int initialT;
int currentT;
int waitT;             // total time (ms) to wait for bluetooth to connect before continuing
//---------------------------------------------------------------------------------------------------------------------------------------
final int nothing=-999;
boolean mouse_clicked=false;
boolean input_finished=true;
String keyboard_input="";
boolean blinker;
//---------------------------------------------------------------------------------------------------------------------------------------
int CTRL;                    // program control
int prevCTRL;                // previous CTRL
final int test_screen=-2;
final int anim_intro=-1;
final int end_now=0;
final int control_end=1;
final int home=2;
final int define_device=3;
final int define_colour=4;
final int bt_find=5;          // find devices/server
final int bt_searching=6;     // check if searching is finished
final int bt_finished=7;      // searching is finished, now try to connect
final int wait=8;             // device has been found, wait a bit to make sure bt connection has been made; NOTE: also needed for the cam to start!
final int start_tracking=9;   // bt connected, now start tracking
final int bt_messaging=10;    // send bt message to device
//---------------------------------------------------------------------------------------------------------------------------------------
PFont courier=createFont("Courier",72,true); // create font with; original font size=72,  smoothing
PFont calibri=createFont("calibri",72,true);

int gnC=255; float gnO=255; PFont gnF=calibri; float gnS=13; int gbC=#FF8000, gbS=#0BFF00; float gbT=2, gbO=220, gbW=120, gbH=40, gbR=10; boolean ghL=true; // general button attributes
//---------------------------------------------------------------------------------------------------------------------------------------
//                              no.   name                   snColor nOpacity nFont nSize bColor bStroke bThick bOpacity bX  bY   bW   bH  bR   hLight
//---------------------------------------------------------------------------------------------------------------------------------------
jm_TB heading       = new jm_TB(home, "NXTcam",               gnC,    gnO,     gnF,  gnS,  gbS,   gbC,    gbT,   gbO,    10, 10,  gbW, 30, gbR, true);
jm_TB website       = new jm_TB(0,    "https://github.com/jo3-tech",gnC,    gnO,     gnF,  gnS,  0,     0,      0,     0,      0,  0,   135, 15, gbR, false);
jm_TB btMSG         = new jm_TB(0,    "program not started",  gbS,    gnO,     gnF,  gnS,  0,     0,      0,     0,      10, 430, 620, 20, 0,   false);    // place bluetooth messages at bottom of gw
jm_TB blobMSG       = new jm_TB(0,    "tracking not started", gbS,    gnO,     gnF,  gnS,  0,     0,      0,     0,      10, 450, 620, 20, 0,   false);    // place blob messages at bottom of gw
String devmsg="Type Name & press ENTER/RETURN: ";
jm_TB devtextfield  = new jm_TB(0,    devmsg,                 gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,    10, 60,  620, 20, gbR, false);
String colmsg="Type Values & press ENTER/RETURN: ";
jm_TB coltextfield  = new jm_TB(0,    colmsg,                 gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,    10, 60,  620, 20, gbR, false);
String colintro="You must use the counterpart application on your PC called NXTcamCD to define the colour. Enter the values above separated by a comma (,) only and press ENTER/RETURN e.g. 130,23,5,63 defines a variation of red."; 
jm_TB col_intro     = new jm_TB(0,    colintro,               gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,    10, 85,  620, 100,gbR, false);
jm_TB wait_bar      = new jm_TB(0,    "...Please Wait...",    gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,    300,220, gbW, gbH,gbR, false);
jm_TB load_bar      = new jm_TB(0,    "",                     0,      0,       gnF,  0,    gbS,   gbS,    gbT,   150,    300,220, gbW, gbH,gbR, false);
jm_TB end_request   = new jm_TB(0,    "Exit Program?",        gnC,    gnO,     gnF,  gnS,  1,     gbS,    gbT,   255,    300,220, gbW, gbH,gbR, false);
jm_TB end_yes       = new jm_TB(end_now, "Yes",               gnC,    gnO,     gnF,  gnS,  1,     gbS,    gbT,   255,    200,300, 100, 30, gbR, true);
jm_TB end_no        = new jm_TB(0,    "No",                   gnC,    gnO,     gnF,  gnS,  1,     gbS,    gbT,   255,    400,300, 100, 30, gbR, true);
//---------------------------------------------------------------------------------------------------------------------------------------
//                              no.            name      snColor nOpacity nFont nSize bColor bStroke bThick bOpacity bX   bY   bW   bH   bR   hLight
//---------------------------------------------------------------------------------------------------------------------------------------
String intro="Welcome to NXTcam.\n\nThis app turns your android phone camera into a computer vision sensor for your Lego Mindstorms NXT to track coloured objects.\n\nYou must pair your NXT to your phone using your phones Bluetooth menu, and turn on Bluetooth on both devices before you begin.\n\nTo begin, use the menu buttons to Set the Name of your NXT device as it appears when you turn on your NXT (case sensitive!), and also Define a Colour to track. To connect to your NXT & start tracking, click Connect & Track or to just watch the app track an object with no connection, click Just Track.\n\nThe NXT will send a continuous stream of numbers via bluetooth to inbox number 0 on your NXT. These numbers will be between 0 & 255 indicating the position of the coloured object in the camera view, where 0 is the left edge of the camera and 255 is the right edge.\n\nPress NXTcam to return to the home screen at any time.";
jm_TB introduction  = new jm_TB(home,          intro,    gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     160, 65,  450, 350, gbR, false);

String device="Set your NXT Name";
jm_TB define_dev    = new jm_TB(define_device, device,   gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     20,  65,  gbW, gbH, gbR, ghL);

String colour="Define Colour to Track";
jm_TB define_col    = new jm_TB(define_colour, colour,   gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     20,  165, gbW, gbH, gbR, ghL);

String contrack="Connect & Track";
jm_TB con_track     = new jm_TB(bt_find,       contrack, gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     20,  265, gbW, gbH, gbR, ghL);

String justrack="Just Track";
jm_TB just_track    = new jm_TB(wait,          justrack, gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     20,  365, gbW, gbH, gbR, ghL);
//---------------------------------------------------------------------------------------------------------------------------------------

jm_TB[] home_buttons = { introduction, define_dev,  define_col, con_track, just_track }; 


//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void setup()
{   
  println("...");  
  println("...Setup Start...");
  println("...");
  
  // Setup Graphics Window
  println("...Setup Graphics Window...");
  
  jm_GWsize("smallcam","landscape","set");   // set graphics window size for basis of development
  //NOTE: the above must always be the same as what I've put in the java program since that is what I used to develop the app
  jm_GWsize("n/a","landscape","display");    // set graphics window orientation                         **if this gives any issue u can put it in the onResume() function**
  gwW=width; gwH=height;                     // get graphics window size being displayed
  dwW=jm_GWdevw(); dwH=jm_GWdevh();          // get development window size  
  wSF=jm_GWscale("w");                       // calculate width scale factor
  hSF=jm_GWscale("h");                       // calculate height scale factor

  // Setup Drawing
  println("...Setup Drawing...");
  
  smooth();                                      // draw text & shapes to screen with smoothing

  textFont(courier,15);                          // set text font with; font size for display=15

  // Setup Animated Intro & Background
  println("...Setup Animated Intro & Background...");

  introI=loadImage("photon.jpg");
  introT=3000;

  bgI=loadImage("background.jpg");
  xoff=0.0;  
  
  // Setup Webcam/Camera
  println("...Setup Webcam/Camera...");

  //NOTE: all of the cam setup stuff needs to & has been placed in the onResume() function for  
  //android mode if you want to mix the use of bluetooth & cam in the same program
  //for android mode the cam can be started within the draw(); not true for java mode 

  // Setup Colour Definition & Segmentation
  println("...Setup Definition & Colour Segmentation...");

  aveRGB=new float[3];                         // initialise

  File f=new File(dataPath("colour.txt"));

  if(f.exists())
  {
    String colour[]=loadStrings(dataPath("colour.txt"));
    String channels[]=split(colour[0],',');
    aveRGB[0]=float(channels[0]); aveRGB[1]=float(channels[1]); aveRGB[2]=float(channels[2]); T=float(channels[3]);
    println("file exists");
  }
  else 
  {
    aveRGB[0]=226; aveRGB[1]=66; aveRGB[2]=81; T=84;  // daytime red using the samsung galaxy s3 phone camera image
//    aveRGB[0]=130.02856; aveRGB[1]=22.986076; aveRGB[2]=5.3403254; T=62.90088;  // evening red using the pc philips spc230nc webcam image
//    aveRGB[0]=132.37625; aveRGB[1]=129.96645; aveRGB[2]=66.46748; T=99;       // yellow using the pc philips spc230nc webcam image
    println("file does not exist");
    saveStrings(dataPath("colour.txt"),new String[]{str(aveRGB[0])+","+str(aveRGB[1])+","+str(aveRGB[2])+","+str(T)});
  }   
  
  iRGBI=createImage(camW,camH,RGB);
  oSEGI=createImage(iRGBI.width,iRGBI.height,RGB);  // set segmented output image to same size as captured image
  
  // Setup Blob Scanner
  println("...Setup Blob Scanner...");

  jm_BAcreate(0,0,oSEGI.width,oSEGI.height,255);
  blobMSG.jm_TBsetName("defined colour to track: "+str(aveRGB[0])+","+str(aveRGB[1])+","+str(aveRGB[2])+","+str(T));
  
  // Setup Bluetooth
  println("...Setup Bluetooth...");
  
  File fS=new File(dataPath("device.txt"));
  
  if(fS.exists()){ String device[]=loadStrings(dataPath("device.txt")); device_name=device[0]; }
  else { device_name = "Joe-NXT"; saveStrings(dataPath("device.txt"),new String[]{device_name}); }
  
  btMSG.jm_TBsetName(jm_BTmessage()+": "+device_name);

//  cmd=new byte[8];      // this doesn't work I have no clue why!!!! the nxt just doesn't receive the messages
//  cmd[0]=byte(0x06); cmd[1]=byte(0x00); cmd[2]=byte(0x00); cmd[3]=byte(0x09); cmd[4]=byte(0x00); cmd[5]=byte(0x02); cmd[5]=byte(0); cmd[7]=byte(0x00);
  cmd=new byte[]{byte(0x06),byte(0x00),byte(0x00),byte(0x09),byte(0x00),byte(0x02),byte(0),byte(0x00)};    // hence it must be done this way! or initialise at global level (b4 setup)

  waitT=8000;

  initialT=millis();
  background(0);
  CTRL=anim_intro;
//  CTRL=home;
//  CTRL=test_screen;                                                                                                 //*****FOR TESTING*****

  println("...");  
  println("...Setup End...");
  println("...");
}
//---------------------------------------------------------------------------------------------------------------------------------------
void draw()   // draw start
{

if((CTRL!=start_tracking)&&(CTRL!=control_end)&&(CTRL!=bt_messaging)&&(CTRL!=anim_intro))
{
  image(bgI,0,0,gwW,gwH);

  xoff = xoff + 0.03;    // controls the speed (origo = 0.01; higher value = faster)
  float n = noise(xoff)*dwW*1.5;  // control the range of motion?
  if(n<dwW/2){ n=dwW/2; }  // limit the upper limit of the range

  pushStyle();                    // store current drawing style (stroke, fill, etc)
  pushMatrix();                   // store coordinate system
  
  translate(dwW*wSF,15*hSF);         // shift coordinate system to location of button
  scale(wSF,hSF);                   // scale button & text
  stroke(gbS);
  strokeWeight(4);
  line(0, 0, n-dwW, 0);
  
  popMatrix();                    // restore coordinate system
  popStyle();                     // restore previous drawing style
  
  website.bX=n;
  website.bY=15;    // **must be the same as the y value in translate!
  website.jm_TBdisplay(wSF,hSF);
}

switch(CTRL)  // program control (switch) start
{

case anim_intro:

  currentT=millis()-initialT;  
  
  if(currentT>=introT) { CTRL=home; }
  if(currentT>=introT/2) { /*do nothing*/ }    // blurring seems to take up a lot of processing power & hence takes longer than what I specified :-S
  else
  {
    float growth_factor=float(currentT)/float(introT-1500);
    image(introI,0,0,(gwW*growth_factor),(gwH*growth_factor));
  }  
  
break;  

case test_screen:

  wait_bar.jm_TBdisplay(wSF,hSF);
  int cT=millis()-initialT;
  load_bar.jm_TBsetbW((gbW*cT)/waitT);
  load_bar.jm_TBdisplay(wSF,hSF);
  if(cT>waitT){ noLoop(); }

break;
  
case end_now:
  
  noLoop(); exit(); // end program

break;

case control_end:

  image(exitI,0,0);   // display image of last screen
  end_request.jm_TBdisplay(wSF,hSF); end_yes.jm_TBdisplay(wSF,hSF); end_no.jm_TBdisplay(wSF,hSF);
  if(mouse_clicked) 
  {
    if(end_yes.jm_TBmouseOver(wSF,hSF)){ CTRL=end_yes.jm_TBgetNum(); }
    else if(end_no.jm_TBmouseOver(wSF,hSF)){ CTRL=prevCTRL; prevCTRL=nothing; }
  }

break;

case home:

  if((prevCTRL==bt_find)||(prevCTRL==bt_finished)){ /*allow the error message set in use_image to show*/ }
  else 
  { 
    btMSG.jm_TBsetName("nxt name: "+device_name);                // reset bluetooth & blob analysis message
    blobMSG.jm_TBsetName("defined colour to track: "+int(aveRGB[0])+","+int(aveRGB[1])+","+int(aveRGB[2])+","+int(T));  // hide the decimals, dont need to use str(..), seems it converts to string automatically
  }
  
  jm_CAMstop();    // stop camera & bluetooth
  jm_BTstop();

  KetaiKeyboard.hide(this);
  
  for (int i=0; i<home_buttons.length; i++)
  {
    home_buttons[i].jm_TBdisplay(wSF,hSF);
    
    if(mouse_clicked)
    {
      if(home_buttons[i].jm_TBmouseOver(wSF,hSF))
      {
        CTRL=home_buttons[i].jm_TBgetNum();
        if(CTRL==define_colour){ KetaiKeyboard.show(this); input_finished=false; keyboard_input=int(aveRGB[0])+","+int(aveRGB[1])+","+int(aveRGB[2])+","+int(T); } // hide the decimals, dont need to use str(..), seems it converts to string automatically
        else if(CTRL==define_device){ KetaiKeyboard.show(this); input_finished=false; keyboard_input=device_name; }
        else if(CTRL==wait) { initialT=millis(); }
        mouse_clicked=false;       // indicate mouse click has been dealt with 
        mouseX=-1; mouseY=-1;      // indicate finger has left the button (mainly for android)
      }
    }
  }
    
break;

case define_device:

  if(input_finished){ saveStrings(dataPath("device.txt"),new String[]{keyboard_input}); device_name=keyboard_input; CTRL=home; } 
  if (frameCount % 12 == 0){ blinker = !blinker; }  
  if(blinker){ devtextfield.jm_TBsetName(devtextfield.jm_TBgetName().substring(0,32)+keyboard_input+"|"); }
  else { devtextfield.jm_TBsetName(devtextfield.jm_TBgetName().substring(0,32)+keyboard_input); }
  devtextfield.jm_TBdisplay(wSF,hSF);
  
  if(mouse_clicked)
  {
    if(devtextfield.jm_TBmouseOver(wSF,hSF)){ KetaiKeyboard.show(this); }
    mouse_clicked=false;       // indicate mouse click has been dealt with 
    mouseX=-1; mouseY=-1;      // indicate finger has left the button (mainly for android)}    
  } 
  
  println("NAME:"+device_name);
    
break;

case define_colour:

  boolean success=true;

  if(input_finished)
  {
    try 
    {
      String[] values=split(keyboard_input,',');
      aveRGB[0]=float(values[0]); aveRGB[1]=float(values[1]); aveRGB[2]=float(values[2]); T=float(values[3]);
    }
    catch (RuntimeException e) 
    {
      println(e);
      success=false;
    }    
  
    if(success=true){ saveStrings(dataPath("colour.txt"),new String[]{keyboard_input}); }
    CTRL=home;
  }
  if (frameCount % 12 == 0){ blinker = !blinker; }
  if(blinker){ coltextfield.jm_TBsetName(coltextfield.jm_TBgetName().substring(0,34)+keyboard_input+"|"); }
  else { coltextfield.jm_TBsetName(coltextfield.jm_TBgetName().substring(0,34)+keyboard_input); }
  col_intro.jm_TBdisplay(wSF,hSF);
  coltextfield.jm_TBdisplay(wSF,hSF);
  
  if(mouse_clicked)
  {
    if(coltextfield.jm_TBmouseOver(wSF,hSF)){ KetaiKeyboard.show(this); }
    mouse_clicked=false;       // indicate mouse click has been dealt with 
    mouseX=-1; mouseY=-1;      // indicate finger has left the button (mainly for android)}
  }
  
  println("RGB:"+aveRGB[0]+","+aveRGB[1]+","+aveRGB[2]+","+T);

break;

case bt_find:

  wait_bar.jm_TBdisplay(wSF,hSF);
  
  if(jm_BTfind()){ CTRL=bt_searching; }
  else { prevCTRL=bt_find; CTRL=home; }
  btMSG.jm_TBsetName(jm_BTmessage());

break;

case bt_searching:

  wait_bar.jm_TBdisplay(wSF,hSF);

  if(jm_BTfinished()){ btMSG.jm_TBsetName(jm_BTmessage()); CTRL=bt_finished; }

break;

case bt_finished:

  wait_bar.jm_TBdisplay(wSF,hSF);

  boolean rtn=jm_BTconnect(device_name); btMSG.jm_TBsetName(jm_BTmessage());
  if(rtn==true){ CTRL=wait; }
  else { prevCTRL=bt_finished; CTRL=home; }

  initialT=millis();
       
break;

case wait:

//NOTE: 
//jm_BTconnect() doesn't actually check whether there was a connection made bcos for some reason it doesn't acknowledge it.
//all we can do is delay a bit (5 to 10 secs)to make sure it connects b4 we continue or bad things start to happen
//also in this section we need to give some time for the cam to start so we are killing 2 birds with one stone

  jm_CAMstart();

  currentT=millis()-initialT;

  wait_bar.jm_TBdisplay(wSF,hSF);
  load_bar.jm_TBsetbW((gbW*currentT)/waitT);
  load_bar.jm_TBdisplay(wSF,hSF);

  println("waiting for proper connection");
  if(currentT>=waitT) { CTRL=start_tracking; }

break;

case start_tracking:  

  // Image Aquisition
  println("...Image Aquisition...");
  
//  iRGBI=loadImage("test"+1+".jpg");     // capture/aquire image(s)                                                  *****FOR TESTING*****
  //NOTE: in android mode we can make use of the onCameraPreviewEvent() function to update the cam which is wrapped up in the tab 
  iRGBI=jm_CAMget();                    // capture/acquire webcam image & copy to input image

  // Colour Segmentation using Euclidean Distance Measure
  println("...Colour Segmentation...");

  oSEGI=jm_CSeuclidean(iRGBI,aveRGB,T); // segment captured image(s)

  // Blob Analysis  
  println("...Blob Analysis...");

  jm_BAanalyse(oSEGI);
  blobMSG.jm_TBsetName(jm_BAmessage());

  image(iRGBI,0,0,gwW,gwH);            // display cam same size as the gw
//  image(oSEGI,width/2,height/2);       // doesn't seem to causes same OutOfMemoryError error experienced in java mode *****FOR TESTING*****

  stroke(#FE00FF);
  strokeWeight(8*wSF);
//  bd.drawBox(#FE00FF,8*wSF);    //***not sure if u can draw the box for only one blob; doesnt seem to be a method for it**** u can do it manually by getting boxheight & width & drawing a rectangle****
  point(map(jm_BAblobx(),0,camW,0,gwW),map(jm_BAbloby(),0,camH,0,gwH));    // display point at location of blob  (must map to gw size since we resize cam to gw)

//  g.removeCache(iRGBI);         //***this is to fix the OutOfMemoryError found in java mode but
//  g.removeCache(oSEGI);         //it doesn't happen here so not really needed

//  noLoop();                                                                                             //******* FOR TESTING *******

  CTRL=bt_messaging;

break;

case bt_messaging:

  // Bluetooth Message  
  println("...Bluetooth Message...");

  if(jm_BAblobx()==-1)
  {
    // Dont send any bt message to nxt (on nxt, you need to clear mailbox every cycle & hence if mailbox remains empty it means no object was found or object is too close/far)
//    cmd[6]=byte(126); println(cmd[6]); bt.writeToDeviceName(device_name,cmd);                        //FOR TESTING*****
  }
  
  else
  {
//    cmd[6]=byte(233); println(cmd[6]);           //FOR TESTING**** note; it may print a negative number (no idea why!!!) but it sends the correct number to nxt
    cmd[6]=byte(round(map(jm_BAblobx(),0,camW,0,255)));  // map value to send to between 0 & 255, & round it to nearest whole number (or create map() function yourself e.g.; new value(v)=origo(w) x P where P=255/wmax (for 0<=w<=wmax & 0<=v<=vmax)

//    println("orio x= "+ jm_BAblobx());
    println("mapped x= "+ round(map(jm_BAblobx(),0,camW,0,255)));   
    println("byted mapped x= "+ cmd[6]);

    bt.writeToDeviceName(device_name,cmd);  // send bt message to nxt indicating location (x-coordinate), nxt should turn left or right &/or move forward towards this location
  }

  CTRL=start_tracking;

break;

}   // program control (switch) end

if(CTRL!=anim_intro)  // display the ffg on all screens except anim intro
{
  heading.jm_TBdisplay(wSF,hSF);      // display heading on all screens
  btMSG.jm_TBdisplay(wSF,hSF);        // display bluetooth message on all screens
  blobMSG.jm_TBdisplay(wSF,hSF);      // display blob message on all screens
}

}   // draw end
//---------------------------------------------------------------------------------------------------------------------------------------
void mouseClicked()
{
  if(heading.jm_TBmouseOver(wSF,hSF)) 
  {
    CTRL=heading.jm_TBgetNum(); mouse_clicked=false; mouseX=-1; mouseY=-1;  // indicate finger has left the button        //*****only needed for android****  
  }      
  else { mouse_clicked=true; }
}
//---------------------------------------------------------------------------------------------------------------------------------------
void keyPressed()    // keyPressed() works, keyReleased() works, but keyTyped() doesn't work in android mode 
{
  if(input_finished==false)
  {
    if(key==CODED)
    {
      if(keyCode==KeyEvent.KEYCODE_DEL){ key=BACKSPACE; }    // of ir u import android.view.KeyEvent; u can just use KeyEvent.KEYCODE_DEL
    }

    if(key!=CODED)
    {
      switch(key)
      {
        case ENTER:
        case RETURN: 
          input_finished=true;
        break;

        case BACKSPACE:
          if(keyboard_input.length()>0){ keyboard_input=keyboard_input.substring(0,keyboard_input.length()-1); }
        break; 

        case DELETE:
          //do nothing... for now
        break;
        
        default:
          keyboard_input=keyboard_input+key;
        break;
      }
    }
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------
boolean surfaceKeyDown(int code, KeyEvent event) //NOTE: BACK key doesnt exist in java but the ESC key does so that has a different method 
{
  if (event.getKeyCode() == KeyEvent.KEYCODE_BACK)
  { prevCTRL=CTRL; CTRL=control_end; exitI=get(); return false; } // prevent the app from quitting automatically, get the last screen displayed
  return super.surfaceKeyDown(code, event);
}
//---------------------------------------------------------------------------------------------------------------------------------------
boolean surfaceKeyUp(int code, KeyEvent event) 
{
  return super.surfaceKeyDown(code, event);
}
//---------------------------------------------------------------------------------------------------------------------------------------
void onCreate(Bundle savedInstanceState) 
{
  super.onCreate(savedInstanceState);
  jm_BTcreate();                              // create bluetooth object
  getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);    // prevent screen froms sleeping 
}
//---------------------------------------------------------------------------------------------------------------------------------------
void onActivityResult(int requestCode, int resultCode, Intent data) 
{
  jm_BTactivity(requestCode, resultCode, data);
}
//---------------------------------------------------------------------------------------------------------------------------------------
void onResume()
{
  super.onResume();
  camW=320; camH=240; fR=20;                  // set cam width & height; minicam=320,240; smallcam=640,480
  jm_CAMcreate(camW,camH,fR);                 // create came object
}
//---------------------------------------------------------------------------------------------------------------------------------------
/*
NOTE:
in java;
stop() function where cam object is stopped
*/
//---------------------------------------------------------------------------------------------------------------------------------------
