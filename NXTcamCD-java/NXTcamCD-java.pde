//==LIBRARIES============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
import javax.swing.ImageIcon;    // needed to change icon in title/tray bar
import JMyron.*;
import Blobscanner.*;

//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
int gwW,gwH;           // declare variables to store graphics window width & height
int dwW,dwH;           // to store development window width & height
float wSF,hSF;         // scale factors for scaling with respect to screen width & height
//---------------------------------------------------------------------------------------------------------------------------------------
PImage bgI;            // main background image
PImage exitI;          // exit image
float xoff = 0.0;      // ??
//---------------------------------------------------------------------------------------------------------------------------------------
int camW,camH;         // to store video/cam width & height
//---------------------------------------------------------------------------------------------------------------------------------------
PImage iRGBI;          // to store acquired image(s)
PImage oSEGI;          // to store the segmented output image
PImage oSEGI3, oSEGI4, oSEGI5;  // to store segmented output image for when 3,4 & 5 objects are detected
float[] aveRGB;        // average of R, G & B components of all pixels in mask
float T;               // threshold for creating segmented image output
float To;              // set initial threshold default
float T3=0,T4=0,T5=0;  // backup threshold if 3, 4 or 5 objects are found
int maskX1=0, maskY1=0, maskX2=0, maskY2=0;  // opposite corners of the mask (X1,Y1) & (X2,Y2)
int boxX1=0, boxY1=0, boxX2=0, boxY2=0;  // opposite corners of the box (X1,Y1) & (X2,Y2)
int boxA;
boolean toohigh;
//---------------------------------------------------------------------------------------------------------------------------------------
int initialT;
int waitT;             // total time (ms) to wait for bluetooth to connect before continuing
//---------------------------------------------------------------------------------------------------------------------------------------
final int nothing=-999;
boolean mouse_clicked=false;
boolean input_finished=true;
String keyboard_input="";
boolean blinker;
//---------------------------------------------------------------------------------------------------------------------------------------
boolean finish_mask=false;
boolean finish_box=false;
//---------------------------------------------------------------------------------------------------------------------------------------
int n;        // no. of iterations carried out so far
float decrement; // amount by which to decrement T with each iteration
//boolean toohigh;  // indicate if the threshold value is too high          //shouldn't need this anymore****
//---------------------------------------------------------------------------------------------------------------------------------------
int CTRL;                    // program control          // 1 = define (X1,Y1) of mask, 2 = define (X2,Y2) of mask, 3 = tidy up mask, 4 = colour definition, 5 = segmentation, 6 = thresholding
int prevCTRL;                // previous CTRL
final int test_screen=-1;
final int end_now=0;
final int control_end=1;
final int home=2;
final int set_threshold=3;
final int use_image=4;
final int use_cam=5;
final int create_mask=6;
final int create_box=7;
final int corrections=8;
final int extract_colour=9;
final int determine_threshold=10;
final int result=11;
//---------------------------------------------------------------------------------------------------------------------------------------
PFont courier=createFont("Courier",72,true); // create font with; original font size=72,  smoothing
PFont calibri=createFont("calibri",72,true);

int gnC=255; float gnO=255; PFont gnF=calibri; float gnS=13; int gbC=#FF8000, gbS=#0BFF00; float gbT=2, gbO=220, gbW=120, gbH=40, gbR=10; boolean ghL=true; // general button attributes
//---------------------------------------------------------------------------------------------------------------------------------------
//                              no.   name                   snColor nOpacity nFont nSize bColor bStroke bThick bOpacity bX  bY   bW   bH  bR   hLight
//---------------------------------------------------------------------------------------------------------------------------------------
jm_TB heading       = new jm_TB(home, "NXTcamCD",               gnC,    gnO,     gnF,  gnS,  gbS,   gbC,    gbT,   gbO,    10, 10,  gbW, 30, gbR, true);
jm_TB website       = new jm_TB(0,    "https://github.com/jo3-tech",gnC,    gnO,     gnF,  gnS,  0,     0,      0,     0,      0,  0,   135, 15, gbR, false);
jm_TB user_rect     = new jm_TB(0,    "",                     0,      0,       gnF,  0,    gbC,   gbS,    gbT,   100,    0,  0,   0,   0,  0,   false);
jm_TB mainMSG       = new jm_TB(0,    "ready to begin",       gbS,    gnO,     gnF,  gnS,  0,     0,      0,     0,      10, 430, 620, 20, 0,   false);    // place main messages at bottom of gw
jm_TB subMSG        = new jm_TB(0,    "",                     gbS,    gnO,     gnF,  gnS,  0,     0,      0,     0,      10, 450, 620, 20, 0,   false);    // place bluetooth messages at bottom of gw
String thshmsg="Type Value & press ENTER/RETURN: ";
jm_TB thshtextfield = new jm_TB(0,    thshmsg,                gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,    10, 60,  620, 20, gbR, false);
String thshintro="See https://github.com/jo3-tech/JM-legacy-matlab-and-processing-projects for an explanation of what this value means and when to change it.";
jm_TB thsh_intro    = new jm_TB(0,    thshintro,              gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,    10, 85,  620, 100,gbR, false);
jm_TB wait_bar      = new jm_TB(0,    "...Please Wait...",    gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,    300,220, gbW, gbH,0,   false);
jm_TB load_bar      = new jm_TB(0,    "",                     0,      0,       gnF,  0,    gbS,   gbS,    gbT,   150,    300,220, gbW, gbH,0,   false);
jm_TB result_bar    = new jm_TB(0,    "",                     gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,    10, 60,  620, 20, gbR, false);
jm_TB end_request   = new jm_TB(0,    "Exit Program?",        gnC,    gnO,     gnF,  gnS,  1,     gbS,    gbT,   255,    300,220, gbW, gbH,gbR, false);
jm_TB end_yes       = new jm_TB(end_now, "Yes",               gnC,    gnO,     gnF,  gnS,  1,     gbS,    gbT,   255,    200,300, 100, 30, gbR, true);
jm_TB end_no        = new jm_TB(0,    "No",                   gnC,    gnO,     gnF,  gnS,  1,     gbS,    gbT,   255,    400,300, 100, 30, gbR, true);
//---------------------------------------------------------------------------------------------------------------------------------------
//                              no.            name            snColor nOpacity nFont nSize bColor bStroke bThick bOpacity bX   bY   bW   bH   bR   hLight
//---------------------------------------------------------------------------------------------------------------------------------------
String intro="Welcome to NXTcamCD; the NXTcam android app counterpart for Colour Definition on your PC.\n\nYou will require a clear image/picture of the object you wish to track. The object should be approximately centred in the image. For a more realistic result the object should be relatively close to the camera with a small but reasonable amount of the environment showing. The image can be uploaded using the 'Use Image' option in the menu. If you intend to use a webcam to take a picture, make sure it is connected BEFORE you run NXTcamCD and select 'Use Cam' in the menu.\n\nAt the end, the program will provide you with 4 numbers to enter into NXTcam on your phone.The first 3 numbers define the colour of the object and the last number is the suggested threshold or sensitivity. See the website for an explanation of the 'Threshold' and when to use the 'Set Threshold' option.\n\nPress NXTcamCD to return to this screen at any time.";
jm_TB introduction  = new jm_TB(home,          intro,          gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     160, 65,  450, 350, gbR, false);

jm_TB set_thresh    = new jm_TB(set_threshold, "Set Threshold",gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     20,  65,  gbW, gbH, gbR, ghL);

jm_TB use_pic       = new jm_TB(use_image,     "Use Image",    gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     20,  215, gbW, gbH, gbR, ghL);

jm_TB use_vid       = new jm_TB(use_cam,       "Use Cam",      gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     20,  365, gbW, gbH, gbR, ghL);
//---------------------------------------------------------------------------------------------------------------------------------------
jm_TB snapshot      = new jm_TB(create_mask,   "Take Snapshot",gnC,    gnO,     gnF,  gnS,  gbC,   gbS,    gbT,   gbO,     20,  365, gbW, gbH, gbR, ghL);
//---------------------------------------------------------------------------------------------------------------------------------------

jm_TB[] home_buttons = { introduction, set_thresh, use_pic, use_vid }; 


//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void setup()
{
  println("...");  
  println("...Setup Start...");
  println("...");

  // Setup Application Icons
  println("...Setup Application Icons...");

  ImageIcon titlebaricon = new ImageIcon(loadBytes("icon_tray-100.gif"));
  frame.setIconImage(titlebaricon.getImage());
 
  // Setup Graphics Window
  println("...Setup Graphics Window...");

  jm_GWsize("smallcam","landscape","set");     // set graphics window size for basis of development
//  jm_GWsize("galaxys3","landscape","display");    //*****************testing
  jm_GWsize("smallcam","landscape","display"); // set graphics window size to display
  gwW=width; gwH=height;                       // get graphics window size being displayed
  dwW=jm_GWdevw(); dwH=jm_GWdevh();            // get development window size
  wSF=jm_GWscale("w");                         // calculate width scale factor
  hSF=jm_GWscale("h");                         // calculate height scale factor

  // Setup Drawing
  println("...Setup Drawing...");
  
  smooth();                                      // draw text & shapes to screen with smooothing
  
  textFont(courier,15);                          // set text font with; font size for display=15
  
  bgI=loadImage("background.jpg");
  xoff=0.0;
  println("...image acquisition start...");

  // Setup Webcam/Camera
  println("...Setup Webcam/Camera...");

  camW=gwW; camH=gwH;                            // set cam width & height
  jm_CAMcreate();
  jm_CAMstart(camW,camH);                        // cam must be started here in java mode

  // Setup Colour Definition, Segmentation & Thresholding
  println("...Setup Definition & Colour Segmentation...");

  aveRGB=new float[3];  // initialise
  To=180; n=1; decrement=1; // toohigh=false;    //dont need too high anymore*****
  
  iRGBI=createImage(gwW,gwH,RGB);
  oSEGI=createImage(iRGBI.width,iRGBI.height,RGB);  // set segmented output image to same size as captured image
  oSEGI3=createImage(iRGBI.width,iRGBI.height,RGB);
  oSEGI4=createImage(iRGBI.width,iRGBI.height,RGB);
  oSEGI5=createImage(iRGBI.width,iRGBI.height,RGB);

  // Setup Blob Scanner
  println("...Setup Blob Scanner...");

  jm_BAcreate(0,0,gwW,gwH,255);    

  CTRL=home;
//  CTRL=use_image;

  println("...");  
  println("...Setup End...");
  println("...");
}
//---------------------------------------------------------------------------------------------------------------------------------------
void draw()   // draw start
{

if((CTRL==home)||(CTRL==set_threshold)||(CTRL==use_image))
{
  image(bgI,0,0,gwW,gwH);

  xoff = xoff + 0.01;    // controls the speed (origo = 0.01; higher value = faster)
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

  if(prevCTRL==use_image){ /*allow the error message set in use_image to show*/ }
  else { mainMSG.jm_TBsetName("ready to begin..."); subMSG.jm_TBsetName("initial threshold set: "+int(To)); }               // reset main & sub message; hide the decimals, dont need to use str(..), seems it converts to string automatically
  
  //NOTE: you need to stop the camera here in android mode, but this cant be done in java mode since it can only be started in setup
  
  //NOTE: you need to turn off the keybaord here if(keyboard_active) & set keyboard_active to false; in android
  
  for (int i=0; i<home_buttons.length; i++)
  {
    home_buttons[i].jm_TBdisplay(wSF,hSF);
    
    if(mouse_clicked)
    {
      if(home_buttons[i].jm_TBmouseOver(wSF,hSF))
      {
        CTRL=home_buttons[i].jm_TBgetNum();
        if(CTRL==set_threshold){ input_finished=false; keyboard_input=str(int(To)); } //NOTE:you need to turn on keyboard here for android if CTRL==set_threshold; keyboard_active=true; hide the decimals
        mouse_clicked=false;       // indicate mouse click has been dealt with 
        mouseX=-1; mouseY=-1;      // indicate finger has left the button (mainly for android)
      }
    }
  }

break;

case set_threshold:

  if(input_finished){ float Temp=To; To=float(keyboard_input); if(!(To>0)){ To=Temp; } CTRL=home; }
  if (frameCount % 12 == 0){ blinker = !blinker; }
  if(blinker){ thshtextfield.jm_TBsetName(thshtextfield.jm_TBgetName().substring(0,33)+keyboard_input+"|"); }
  else { thshtextfield.jm_TBsetName(thshtextfield.jm_TBgetName().substring(0,33)+keyboard_input); }
  thsh_intro.jm_TBdisplay(wSF,hSF);
  thshtextfield.jm_TBdisplay(wSF,hSF);
  println("To: "+To);

break;

case use_image:
  
  subMSG.jm_TBsetName("select an image.");
  selectInput("Select an image of your object:", "jm_MAINcheckFile");
  finish_mask=false; finish_box=false;
  noLoop();
  
//  finish_mask=false; finish_box=false; iRGBI=loadImage("definition_1_image.jpg"); iRGBI.resize(gwW,gwH); oSEGI=createImage(iRGBI.width,iRGBI.height,RGB); CTRL=create_mask;        //******************************for testing

break;

case use_cam:

  jm_CAMupdate();                       // update camera view
  iRGBI=jm_CAMget(camW,camH);           // capture/acquire webcam image & copy to input image
  image(iRGBI,0,0);                     // display cam
  subMSG.jm_TBsetName("capture an image.");
  snapshot.jm_TBdisplay(wSF,hSF);
  
  if(mouse_clicked && snapshot.jm_TBmouseOver(wSF,hSF)){ CTRL=snapshot.jm_TBgetNum(); mouse_clicked=false; mouseX=-1; mouseY=-1; } // indicate finger has left the button        //*****only needed for android****

  finish_mask=false; finish_box=false;

  g.removeCache(iRGBI);
  g.removeCache(oSEGI);

break;

case create_mask:  // if mouse has been clicked for the first time

  image(iRGBI,0,0);      // refresh the display so the screen doesnt fill with rectangles
  mainMSG.jm_TBsetName("select a rectangular area containing the required colour...");
  subMSG.jm_TBsetName("click once to start selection, move mouse to required position, click again to finish.");
  
  if(finish_mask==false)
  {
    if(mouse_clicked)
    { maskX1=mouseX; maskY1=mouseY; user_rect.bX=maskX1/wSF; user_rect.bY=maskY1/hSF; finish_mask=true; mouse_clicked=false; }       // indicate mouse click has been dealt with
  }
  else
  {
    user_rect.bW=(mouseX-user_rect.bX*wSF)/wSF; user_rect.bH=(mouseY-user_rect.bY*hSF)/hSF; user_rect.jm_TBdisplay(wSF,hSF); // noFill(); rectMode(CORNERS); rect(maskX1,maskY1,mouseX,mouseY);  // draw a rectangle from the click point to the mouse position
    if(mouse_clicked){ maskX2=mouseX; maskY2=mouseY; mouse_clicked=false; CTRL=create_box; }
  }
  
break;

case create_box:  // if mouse has been clicked for the first time

  image(iRGBI,0,0);      // refresh the display so the screen doesnt fill with rectangles
  mainMSG.jm_TBsetName("select a rectangular area that approximately just surrounds the entire object...");
  subMSG.jm_TBsetName("click once to start selection, move mouse to required position, click again to finish.");
  
  if(finish_box==false)
  {
    if(mouse_clicked)
    { boxX1=mouseX; boxY1=mouseY; user_rect.bX=boxX1/wSF; user_rect.bY=boxY1/hSF; finish_box=true; mouse_clicked=false; }       // indicate mouse click has been dealt with
  }
  else
  {
    user_rect.bW=(mouseX-user_rect.bX*wSF)/wSF; user_rect.bH=(mouseY-user_rect.bY*hSF)/hSF; user_rect.jm_TBdisplay(wSF,hSF); // noFill(); rectMode(CORNERS); rect(boxX1,boxY1,mouseX,mouseY);  // draw a rectangle from the click point to the mouse position
    if(mouse_clicked){ boxX2=mouseX; boxY2=mouseY; mouse_clicked=false; CTRL=corrections; }
  }
  
break;

case corrections:

  mainMSG.jm_TBsetName("defining colour...");
  subMSG.jm_TBsetName("mask & bounding box correction.");
  wait_bar.jm_TBdisplay(wSF,hSF);
  
  if(maskX1>maskX2){ int temp=maskX2; maskX2=maskX1; maskX1=temp; }  // makse sure maskX2 > maskX1
  if(maskY1>maskY2){ int temp=maskY2; maskY2=maskY1; maskY1=temp; }  // makse sure maskY2 > maskY1

  if(boxX1>boxX2){ int temp=boxX2; boxX2=boxX1; boxX1=temp; }  // makse sure boxX2 > boxX1
  if(boxY1>boxY2){ int temp=boxY2; boxY2=boxY1; boxY1=temp; }  // makse sure boxY2 > boxY1

  boxA=(abs(boxX2-boxX1)+1)*(abs(boxY2-boxY1)+1);
  println("bounding box area selected= "+ boxA);
  CTRL=extract_colour;

break;
  
case extract_colour:

  image(iRGBI,0,0);
  subMSG.jm_TBsetName("colour extraction.");
  wait_bar.jm_TBdisplay(wSF,hSF);

  aveRGB=jm_CErgbExtract(iRGBI,maskX1,maskY1,maskX2,maskY2);
    
  println("aveR=" + aveRGB[0] + " aveG=" + aveRGB[1] + " aveB=" + aveRGB[2]);
  
  T=To;    
  subMSG.jm_TBsetName("calculating ideal threshold.");  CTRL=determine_threshold;
    
break;  
    
case determine_threshold:

  image(iRGBI,0,0);
 
  wait_bar.jm_TBdisplay(wSF,hSF);
  load_bar.jm_TBsetbW(gbW-(gbW*T/To));
  load_bar.jm_TBdisplay(wSF,hSF);
  
  // Colour Segmentation using Euclidean Distance Measure
  println("...Colour Segmentation...");

  oSEGI=jm_CSeuclidean(iRGBI,aveRGB,T); // segment captured image(s)

  // Thresholding using Blob Analysis
  println("...Thresholding...");
  
  jm_BAanalyse(oSEGI);

  if(jm_BAtotalBlobs()>2||jm_BAtotalBlobs()==0)    //*************** NOTE: if you put the required colour on a black background for the definition, then you should be able to find one blob
  {              // BUT if not then it will most likely be impossible to find just one blob so you may need to use a value higher than 1 maybe 2 or 3 or more
    toohigh=false;
    n+=1; T=T-decrement;    // toohigh=false;    // dont need too high anymore*****
    println(jm_BAtotalBlobs()+" objects detected; proceeding with iteration "+n);      // print the no. of blobs found & the iteration no.
    if(jm_BAtotalBlobs()==3){ T3=T; oSEGI3=oSEGI; } else if(jm_BAtotalBlobs()==4){ T4=T; oSEGI4=oSEGI; } else if(jm_BAtotalBlobs()==5){ T5=T; oSEGI5=oSEGI; }      // set backup thresholds & segmented images
  }
      
  else
  {
    if(T==To||toohigh){ toohigh=true; T=T-decrement; n+=1; println("T; threshold too high; proceeding with iteration "+n); }    
    else if(jm_BAblobWeight()>boxA){ T=T-decrement; n+=1; println("WE; threshold too high; proceeding with iteration "+n); }
//    else if(jm_BAblobArea()>boxA){ T=T-decrement; n+=1; println("A; threshold too high; proceeding with iteration "+n); }     // prefer not to use this one; it may block out too many good results
    else
    {
      println(jm_BAtotalBlobs()+" objects detected, appropriate threshold found; T="+T);
      mainMSG.jm_TBsetName("colour defined successfully, appropriate threshold found...");
      subMSG.jm_TBsetName("enter values as shown above into NXTcam on your phone.");
      result_bar.jm_TBsetName(int(aveRGB[0])+","+int(aveRGB[1])+","+int(aveRGB[2])+","+int(T));  // display results & hide the decimals, dont need to use str(..), seems it converts to string automatically
      CTRL=result;
      //noLoop();              //****** for testing
    }
  }
  
  if(T<=0)  // if threshold value goes to 0 or below
  { 
    if(T3>0){ T=T3; oSEGI=oSEGI3; println("T3"); } else if(T4>0){ T=T4; oSEGI=oSEGI4; println("T4"); } else if(T5>0){ T=T5; oSEGI=oSEGI5; println("T5"); }      // apply backup thresholds & segmented images 
    println("failed to determine appropriate threshold");
    mainMSG.jm_TBsetName("colour defined successfully, failed to determine appropriate threshold...");
    subMSG.jm_TBsetName("enter values as shown above into NXTcam on your phone.. NOTE: you MAY need to experiment with the threshold.");
    result_bar.jm_TBsetName(int(aveRGB[0])+","+int(aveRGB[1])+","+int(aveRGB[2])+","+int(T));
    CTRL=result;
    //noLoop();              //****** for testing
  }  

  g.removeCache(iRGBI);
  g.removeCache(oSEGI);
  g.removeCache(oSEGI3); g.removeCache(oSEGI4); g.removeCache(oSEGI5);
    
break;

case result:

  image(iRGBI,0,0); filter(GRAY);
  tint(aveRGB[0],aveRGB[1],aveRGB[2],200);  // tint segmented image same colour as object
  image(oSEGI,0,0);
  noTint();                                 // disable tint
  result_bar.jm_TBdisplay(wSF,hSF);

break;

}   // program control (switch) end

heading.jm_TBdisplay(wSF,hSF);      // display heading on all screens
mainMSG.jm_TBdisplay(wSF,hSF);      // display main message on all screens
subMSG.jm_TBdisplay(wSF,hSF);       // display sub message on all screens

}   // draw end
//---------------------------------------------------------------------------------------------------------------------------------------
void mouseClicked()
{
  if(heading.jm_TBmouseOver(wSF,hSF)) 
  {
    CTRL=heading.jm_TBgetNum(); mouseX=-1; mouseY=-1;  // indicate finger has left the button        //*****only needed for android****  
  }      
  else { mouse_clicked=true; }
}
//---------------------------------------------------------------------------------------------------------------------------------------
void keyReleased()    // keyPressed() works, keyReleased() works, but keyTyped() doesn't work in android mode
{
  if(input_finished==false)
  {
    if(key==CODED)
    {
      //NOTE: you need to override the android.view.KeyEvent.KEYCODE_DEL & set key to BACKSPACE in android
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
}                     // I have to use keyTyped() or keyReleased() here otherwise using the SHIFT key + another key results in the capitalised word AND a "shift" character
//---------------------------------------------------------------------------------------------------------------------------------------
void keyPressed()     //NOTE: ESC doesnt exist in android but the BACK key does so that has a different method 
{
  if(key==ESC)
  { key=0; prevCTRL=CTRL; CTRL=control_end; exitI=get(); } // prevent the app from quitting & keyboard from closing automatically, get the last screen displayed
  
}                     // i have to use keyPressed() here because you have to catch the ESC key emmediately it is pressed or the program will exit
//---------------------------------------------------------------------------------------------------------------------------------------
public void stop()
{
  jm_CAMstop();        //stop cam object
  super.stop();
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_MAINcheckFile(File selection)
{
  if (selection == null){ CTRL=home; }  // if window was closed or user cancelled, go back home
  else
  {
    iRGBI=loadImage(selection.getAbsolutePath());
    if(iRGBI==null){ prevCTRL=use_image; CTRL=home; mainMSG.jm_TBsetName("error..."); subMSG.jm_TBsetName("please select an image file."); }
    else { iRGBI.resize(gwW,gwH); CTRL=create_mask; }  // i'de prefer not to use resize() function so we can upgrade processing but I have to for now!*****
  }
  mouse_clicked=false;
  loop();
}
//---------------------------------------------------------------------------------------------------------------------------------------
