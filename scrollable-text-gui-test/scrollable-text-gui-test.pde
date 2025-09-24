//---------------------------------------------------------------------------------------------------------------------------------------
//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
final int W=480, H=750;    // standard screen width & height (480,800 as per emulator). for galaxy s3; (720,1280) & x10 mini pro; (240,320)
int dW, dH;          // display width & height
float wS, hS;        // scale factor for scaling with respect to screen width & height respectively
//---------------------------------------------------------------------------------------------------------------------------------------
PImage homeI;        // declare a variable to store the home image
PFont arial, calibri, cambria;         // declare a variable to store the fonts
//---------------------------------------------------------------------------------------------------------------------------------------
final float ofontS=72;     // original font size for creating font
//---------------------------------------------------------------------------------------------------------------------------------------
final int nothing=-999;    // my version of null for numbers
//---------------------------------------------------------------------------------------------------------------------------------------
boolean press=false, click=false, move=false;    // flags indicating whether the mouse has been pressed or clicked
//---------------------------------------------------------------------------------------------------------------------------------------
final int backButton=0, homeButton=1;            // the back & home buttons
int lButton;                  // last button pressed
int cButton;                  // current button pressed
int bTot;                             // total no. of buttons
rectButton[] buttons;                 // array of buttons
//---------------------------------------------------------------------------------------------------------------------------------------
int tTot;                    // total no. of text boxes
rectText[] texts;        // array of text boxes
//---------------------------------------------------------------------------------------------------------------------------------------
//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void setup()
{
  //println("...scaling...");
  //scaling//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //size(W,H);                                // set screen size for development
  size(displayWidth,displayHeight);           // set screen size for exporting to pc           NOTE: UNCOMMENT THIS LINE WHEN EXPORTING FOR PC
  //size(720,1280);                           // for testing with other screen sizes
  //size(240,320);
  orientation(PORTRAIT);                    // lock screen orientation
  dW=width; dH=height;
  wS=float(dW)/float(W);
  hS=float(dH)/float(H);
  
  //println("...general...");
  //general//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  smooth();                                 // draw text & shapes to screen with smooothing
  textAlign(CENTER,CENTER);

  //println("...variables...");  
  //variables////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //N/A
  
  //println("...images...");
  //images///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  homeI=loadImage("home.jpg");              // load & resize images
  homeI.resize(dW,dH);
  
  //println("...fonts...");
  //fonts////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  arial=createFont("arial",ofontS,true);    // create fonts with smoothing
  calibri=createFont("calibri",ofontS,true); 
  cambria=createFont("cambria",ofontS,true);
  
  //println("...media...");
  //media////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //N/A

  //println("...buttons...");
  //buttons//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
  bTot=7;       // total no. of buttons
  buttons=new rectButton[bTot]; // initialise program buttons array
 
  int gnC=#E81010; float gnO=255; PFont gnF=calibri; float gnS=18; int gbC=#35F20C, gbS=#FAFF00; float gbt=1, gbO=200, gbW=150, gbH=40, gbR=10; boolean ghL=true;

  //variable -b (or -ve of button number) indicates noFill() or noStroke()  
  //                          no name                 nColor   nOpacity nFont      nSize bColor   bStroke  bThick   bOpacity bX             bY      bW      bH     bR     hLight   
  //all screens buttons//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  int b=0;
  buttons[b] = new rectButton(b, "Go Back",           #43FA08, gnO,     cambria,   gnS,  -b,      -b,      gbt,     0,       5,             10,   gbW,    gbH,   gbR,   ghL);
  
  b=1;
  buttons[b] = new rectButton(b, "Go Home",           #43FA08, gnO,     cambria,   gnS,  -b,      -b,      gbt,     0,       (W/2)-(gbW/2), 10,     gbW,    gbH,   gbR,   ghL);
  
  b=2;
  buttons[b] = new rectButton(b, "Page 1",            #FFFFFF, gnO,     gnF,       gnS,  -b,      -b,      gbt,     0,       20,            500,    gbW,    gbH,   gbR,   ghL);

  //home screen buttons//////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
  b=3;
  buttons[b] = new rectButton(b, "Button 1",         gnC,     gnO,     gnF,       gnS,  gbC,     gbS,     gbt,     gbO,     20,            150,    gbW,    gbH,   gbR,   ghL);
  //variable 'nothing' (-b (or -ve of button number indicates noFill() or noStroke()
  
  b=4;
  buttons[b] = new rectButton(b, "Button 2",         gnC,     gnO,     gnF,       gnS,  gbC,     gbS,     gbt,     gbO,     W-20-gbW,      150,    gbW,    gbH,   gbR,   ghL);
  
  //test screen buttons//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  b=5;
  buttons[b] = new rectButton(b, "Page 2",            #FFFFFF, gnO,     gnF,       gnS,  -b,      -b,      gbt,     0,       20,            500,    gbW,    gbH,   gbR,   ghL);

  b=6;
  buttons[b] = new rectButton(b, "Button 3",         gnC,     gnO,     gnF,       gnS,  gbC,     gbS,     gbt,     gbO,     20,            150,    gbW,    gbH,   gbR,   ghL);
  
  //println("...text boxes...");
  //text boxes///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
  tTot=1;       // total no. of text boxes
  texts=new rectText[tTot]; // initialise program text boxes array
  
  int gtC=#E81010; float gtO=255; PFont gtF=calibri; float gtS=18; int gtbC=#35F20C, gtbS=#FAFF00; float gtbt=1, gtbO=200, gtbW=300, gtbH=150, gtbR=10; boolean gtbhL=true;

  //variable -b (or -ve of button number) indicates noFill() or noStroke()  
  //                      no name    snColor   nOpacity nFont      nSize bColor   bStroke  bThick   bOpacity bX              bY      bW      bH     bR     hLight   
  //all screens buttons//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  int t=0;
  texts[t] = new rectText(t, test,   gtC,      gtO,     cambria,   gtS,  gtbC,    gtbS,    gtbt,     gtbO,   (W/2)-(gtbW/2), 210,    gtbW,   gtbH,  gtbR,  gtbhL);


  //println("...start screen...");
  //start Screen
  cButton=1;                       // set current button to home button
  lButton=nothing;
  println("...starting...");
}
//---------------------------------------------------------------------------------------------------------------------------------------
void draw()
{
  //buttons start
  switch(cButton)
  {
    //nothing////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    case nothing:
    
    noLoop();
    exit();    // end the program
    
    break;
    
    //backbutton/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    case backButton:
    
    println("back button pressed");
    println("last button "+lButton);
    println("button b4 last button "+buttons[lButton].lButton);
    cButton=buttons[lButton].lButton;        // set the current button to the identity of the last button stored in the last button
    lButton=backButton;                                        // make sure not to set lButton to either the backbutton or cButton anywhere here at all!!!
    println("sending to button "+cButton);
    
    break;
    
    //homebutton/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //home button => home screen
    case homeButton:  
    
    homeScreenEvent(2, 4, 0, 0, homeI, nothing);
    
    int[] noPressHome={3};
    cancelPress(noPressHome);
    
    break;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //button 1 press on home screen => no change from home screen
    case 3:
    
    if(press){ println(buttons[cButton].name + "is changing!!! something on the current screen"); }
    else { println(buttons[cButton].name + "changed! something on the current screen"); }
    
    //go back to the screen from which it was called regardless of whether it was pressed or clicked
    internalBack();
        
    break;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //button 2 press on home screen => test screen 
    case 4:
    
    //paint a new screen
    regularScreenEvent(5, 6, nothing, nothing, backButton, homeI, nothing);
    
    int[] noPress4={ 5, 6 };
    cancelPress(noPress4);
    
    println("at this point, lButton is still "+lButton);
    println("& stored last button is still "+buttons[cButton].lButton);
    
    break;
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //T1 press on test screen => no screen change 
    case 6:
    
    link("http://www.processing.org");
    
    // go back to the screen from which it was called regardless of if it was pressed or clicked
    internalBack();
    
    break;
      
  }
  //buttons end

}
//---------------------------------------------------------------------------------------------------------------------------------------
void mousePressed()
{
  press=true;
}
//---------------------------------------------------------------------------------------------------------------------------------------
void mouseClicked()
{
  click=true;
}
//---------------------------------------------------------------------------------------------------------------------------------------
void mouseReleased()
{
  press=false;
}
//---------------------------------------------------------------------------------------------------------------------------------------
void mouseMoved()
{
  move=true;
}
//---------------------------------------------------------------------------------------------------------------------------------------
void allScreenButtons()
{
  buttons[backButton].display(wS,hS);    // home & back buttons displays on every screen
  buttons[homeButton].display(wS,hS);
  if(click)
  {
    if(buttons[backButton].mouseOver(wS,hS)){ cButton=buttons[backButton].number; }
    else if(buttons[homeButton].mouseOver(wS,hS)){ cButton=buttons[homeButton].number; }
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------
void onButtonEvent(int first, int last)    // handles clicks, presses & movements
{ println("button pressed");
  for(int i=first; i<=last; i++)
  {
    buttons[i].display(wS,hS);              // display the buttons & names with scaling   //OR buttons[i].display();       // display the button & name with no scaling
    //println("printing button "+buttons[i].name);    
    if(click||press)
    {
      if(buttons[i].mouseOver(wS,hS)){ cButton=buttons[i].number; }
    }
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------
void onTextEvent(int first, int last)
{
  for(int i=first; i<=last; i++)
  {
    if(click||press)
    {
      texts[i].update(wS,hS);
    }
    texts[i].display(wS,hS);              // display the buttons & names with scaling   //OR buttons[i].display();       // display the button & name with no scaling
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------
void homeScreenEvent(int bfirst, int blast, int tfirst, int tlast, PImage I, int bgColor)  // null indicates dont use and image; use bgColor instead, otherwise set bgColor to nothing
{
  buttons[cButton].lButton=nothing;     // for home screen make sure the back button always quits the program
    
  if((lButton!=cButton)||move||press||click)  // if its the first time on this screen or there is a button event, then redraw the screen
  {
    lButton=cButton;                        // set last button to current button
    
    if(I==null){ background(bgColor); }
    else{ background(I); }    // set home page background
    
    allScreenButtons();
    if(bfirst!=nothing){ onButtonEvent(bfirst,blast); }  // only check buttons if there are actually buttons on the screen
    if(tfirst!=nothing){ onTextEvent(tfirst, tlast); }  // only check texts if there are actually text boxes in the screen
    
    click=false;     // indicate click has been dealt with
//    if(cButton==lButton){ press=false; }      // if no button was pressed or clicked indicate that press has been dealt with
    move=false;    // indicate move has been dealt with
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------
void regularScreenEvent(int bfirst, int blast, int tfirst, int tlast, int backButton, PImage I, int bgColor)
{
  if((lButton!=cButton)||move||press||click)  // if its the first time on this screen or there is a button event, then redraw the screen
  {
    if((lButton!=backButton)&&(lButton!=cButton))
    { buttons[cButton].lButton=lButton; println("stored last button is "+buttons[cButton].lButton); } // store the last buttons identity in the current button
    lButton=cButton;                        // set last button to current button 
     
    if(I==null){ background(bgColor); }
    else{ background(I); }    // set home page background

    allScreenButtons();
    if(bfirst!=nothing){ onButtonEvent(bfirst,blast); }  // only check buttons if there are actually buttons on the screen
    if(tfirst!=nothing){ onTextEvent(tfirst, tlast); }  // only check texts if there are actually text boxes in the screen
    
    click=false;     // indicate click has been dealt with
//    if(cButton==lButton){ press=false; }      // if no button was pressed or clicked indicate that press has been dealt with
    move=false;    // indicate move has been dealt with    
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------
void internalBack()                      // go back to the previous screen internally (i.e. without the back button actually being pressed)
{
  buttons[cButton].lButton=lButton;
  lButton=cButton;                        // set last button to current button
  cButton=0;    // go back via the back button
}
//---------------------------------------------------------------------------------------------------------------------------------------
void cancelPress(int[] cancel)
{
  if(press)
  {
    for(int i=0; i<cancel.length; i++)
    {
      if(cancel[i]==cButton){ cButton=lButton; break; }
    }
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------
//==END==================================================================================================================================
