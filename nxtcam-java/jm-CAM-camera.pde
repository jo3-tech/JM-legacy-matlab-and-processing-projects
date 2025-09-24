//FOR JAVA  
//==LIBRARIES============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
//needs the following imports in the main tab:
//JMyron.*;

//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
JMyron cam;            // declare video object

//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_CAMcreate()
{
  cam=new JMyron();                            // initialise/make new instance of video object
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_CAMstart(int cam_width, int cam_height)
{
    cam.start(cam_width,cam_height); 
    cam.findGlobs(0);         // disable intelligence to speed up frame rate
    println("starting cam");  // start webcam
}
//---------------------------------------------------------------------------------------------------------------------------------------
PImage jm_CAMget(int cam_width, int cam_height)
{
  PImage copycam=createImage(cam_width,cam_height,RGB);
  copycam.loadPixels();
  cam.imageCopy(copycam.pixels);
  copycam.updatePixels();
  return copycam;
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_CAMupdate()    // this function is called automatically once the camera is started
{
  cam.update();                  // update camera view
//  image(cam, 0, 0);          // this doesn't work when i start to wrap the bluetooth stuff, it only works in draw() :-S ketai is too finicky!!!
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_CAMstop()
{
  cam.stop();
}
//---------------------------------------------------------------------------------------------------------------------------------------
