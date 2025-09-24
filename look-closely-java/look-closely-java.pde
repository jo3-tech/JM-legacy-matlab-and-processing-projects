//==LIBRARIES============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
import ddf.minim.*;

//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
int W=480, H=750;    // standard screen width & height (480,800 as per emulator). for galaxy s3; (720,1280) & x10 mini pro; (240,320)  
int dW, dH;          // display width & height
float wS;            // scale factor for scaling with respect to screen width
float hS;            // scale factor for scaling with respect to screen height
//---------------------------------------------------------------------------------------------------------------------------------------
PImage lookI;        // declare variable to store the 'spot the difference' image
PImage booI;         // declare variable to store the 'scary' image
PFont cambria;       // cambria
//---------------------------------------------------------------------------------------------------------------------------------------
Minim minim;         // define a minim variable
AudioPlayer growl;   // declare variable to store 'growl' audio
AudioPlayer scream;  // declare variable to store 'scream' audio
//---------------------------------------------------------------------------------------------------------------------------------------
float ofontS=72;     // original font size for creating font
float tfontS=44;     // font size for text
String message="Look Closely & Try to Spot the Difference";
float tX,tY;         // text location
float tbW=W/2, tbH=H/2; // text box width & height
int iT=0;            // initial time
int control=0;       // to control the program flow; 0 = spot the difference; 1 = boo!
int mDuration=4000;  // total time (ms) to display message
int sDuration=8000;  // total time (ms) to display 'spot the difference' image
float iX,iY;         // 'scary' image location
float vibX=10,vibY=vibX*H/W; // max translation of 'scary' image from its original location during vibration
boolean playing=false; // indicate when audio is still playing
float lvol=1, rvol=1; // left & right channels volume

//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void setup()
{
  //println("...setup start...");
  
  // Scaling
  //println("...scaling...");
  
  //size(W,H);                                // set screen size for development
  size(displayWidth,displayHeight);         // set screen size for exporting to pc           NOTE: UNCOMMENT THIS LINE WHEN EXPORTING FOR PC
  //size(720,1280);                           // for testing with other screen sizes
  //size(240,320);
  //orientation(PORTRAIT);                    // lock screen orientation                     NOT REALLY NECESSARY FOR THIS APP
  dW=width; dH=height;
  wS=float(dW)/float(W);
  hS=float(dH)/float(H);
  
  // General
  //println("...general...");
  smooth();                                 // draw text & shapes to screen with smooothing
  
  // Variables
  //println("...variables...");
  
  tX=dW/2; tY=dH/2;                         // initialise text location
  iX=dW/2; iY=dH/2;                         // initialise 'scary' image location
  
  // Images
  //println("...images...");

  lookI=loadImage("look closely.jpg");      // load & resize images
  lookI.resize(dW,dH/2);
  booI=loadImage("boo.jpg");
  booI.resize(dW,dH);

  // Fonts
  //println("...fonts...");
  
  cambria=createFont("cambria",ofontS,true);// create fonts with smoothing
  
  // Media
  //println("...media...");
  
  minim=new Minim(this);                    // initialise minim variable
  growl=minim.loadFile("growl.mp3");        // load media files
  scream=minim.loadFile("scream.mp3");  
  
  // Message
  //println("...message...");
  
  background(255,0,0);                      // set background colour; red
  
  textFont(cambria,tfontS);                 // set text font & scale size so it is always proportionate to the screen size
  fill(#080808);                            // set text color; black
  rectMode(CENTER);
  
  pushMatrix();                             // store coordinate system
  translate(tX,tY);                         // shift coordinate system to location of text
  scale(wS,hS);                             // scale text
  text(message,0,0,tbW,tbH);                // display text & wrap in a box
  popMatrix();                              // restore coordinate system
  
  iT=millis();                              // set current time as initial time
  
  //println("...setup end...");
}
//---------------------------------------------------------------------------------------------------------------------------------------
void draw()
{
  //println("...drawing..."+wS);
  
  switch(control)
  {
    case 0: // Spot the Difference
    
    if((millis()-iT)>=mDuration)            // display 'spot the difference' image after specified duration
    {
      // Look Closely
      //println("...look closely...");
      
      image(lookI,0,0);
      image(lookI,0,dH/2);
      iT=millis();                          // set current time as initial time
      control=1;
    }
    
    break;
    
    case 1: // Be Afraid... Be Very Afraid 
    
    if((millis()-iT)>=sDuration)            // display 'scary' image after specified duration
    {
      // Boo!
      //println("...boo shakes!...");
 
      if(playing==false)
      {
        growl.play();                       // start media play back
        growl.setVolume(1);
        
        scream.play();
        scream.setVolume(1);        
        
        playing=true;                       // indicate growling audio is playing
      }   

      imageMode(CENTER);
      image(booI,random((iX)-(vibX*wS),(iX)+(vibX*wS)),random((iY)-(vibY*hS),(iY)+(vibY*hS)));  // vibrate image
    }

    break;
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------
void stop()
{
  // Release Media Player
  //println("...release...");
  
  growl.close();    // release the players
  scream.close();
  minim.stop();

  super.stop();
}

//==CLASSES==============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
//N/A

//==END==================================================================================================================================
