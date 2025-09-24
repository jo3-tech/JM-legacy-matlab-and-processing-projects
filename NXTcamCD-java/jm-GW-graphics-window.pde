//FOR JAVA  
//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
int dev_width=0, dev_height=0; // variables for storing ideal/standard/development graphics window/renderer size (width,height) in which
                               // software will not need to scale i.e. scale factor will = 1

//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_GWsize(int w, int h, String choice)      // choice="set" graphics window to prefered size (width,height); for basis of development
{                                                // choice="display" window to prefered size; for testing &/or exporting
  if(choice.equals("set")) { dev_width=w; dev_height=h; }
  else { size(w,h); }                            // anything other than "set" will assume choice="display"
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_GWsize(String window)
{
  if(window.equals("fill")) { size(displayWidth,displayHeight); }  // fill pc screen
  else { println("jm_GWsize:invalid selection!"); exit(); }
}  
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_GWsize(String window, String orient, String choice)
{
  int w=0, h=0;
  
  if(window.equals("emulator")) 
  {
    if(orient.equals("portrait")) { w=480; h=750; }
    else { w=750; h=480; }
    if(choice.equals("set")) { dev_width=w; dev_height=h; }        // should actually be (450,800) for android emulator
    else { size(w,h); }
  }
  
  else if(window.equals("x10mini")) 
  {
    if(orient.equals("portrait")){ w=240; h=320; }
    else { w=320; h=240; }    
    if(choice.equals("set")) { dev_width=w; dev_height=h; }
    else { size(w,h); }
  }
  
  else if(window.equals("galaxys3")) 
  {
    if(orient.equals("portrait")){ w=720; h=1280; }
    else { w=1280; h=720; }
    if(choice.equals("set")) { dev_width=w; dev_height=h; }
    else { size(w,h); }
  }
  
  else if(window.equals("bigcam")) 
  {
    if(orient.equals("portrait")){ w=960; h=1280; }
    else { w=960; h=1280; }
    if(choice.equals("set")) { dev_width=w; dev_height=h; }
    else { size(w,h); }
  }
  
  else if(window.equals("smallcam")) 
  {
    if(orient.equals("portrait")){ w=480; h=640; }
    else { w=640; h=480; }
    if(choice.equals("set")) { dev_width=w; dev_height=h; }
    else { size(w,h); }
  }
  
  else if(window.equals("minicam")) 
  {
    if(orient.equals("portrait")){ w=240; h=320; }
    else { w=320; h=240; }
    if(choice.equals("set")) { dev_width=w; dev_height=h; }
    else { size(w,h); }
  }
  
  else { println("jm_GWsize:invalid window selection!"); exit(); }
}
//---------------------------------------------------------------------------------------------------------------------------------------
float jm_GWscale(String choice)      // calculate scale factor for scaling with resepct to display window width w & height h
{
  if(dev_width==0||dev_height==0) 
  { 
    println("jm_GWscale:cannot calculate scale factor until the graphics window size(width,height) on which this app is based/being developed"); 
    println("has been 'set' using jm_GWsize()"); 
    exit(); return 0.0;
  }
  if(choice.equals("w")) { return float(width)/float(dev_width); }          // OR typecast it i.e.; (float) width/dev_width;
  else if(choice.equals("h")) { return float(height)/float(dev_height); }
  else { println("jm_GWscale:invalid choice selection!"); exit(); return 0.0;} 
}
//---------------------------------------------------------------------------------------------------------------------------------------
int jm_GWdevw()
{
  return dev_width;
}
//---------------------------------------------------------------------------------------------------------------------------------------
int jm_GWdevh()
{
  return dev_height;
}
//---------------------------------------------------------------------------------------------------------------------------------------
