//FOR ANDROID  
//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
int dev_width=0, dev_height=0; // variables for storing ideal/standard/development graphics window/renderer size (width,height) in which
                               // software will not need to scale i.e. scale factor will = 1

//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_GWsize(int w, int h, String choice)      // can only manually "set" graphics window to prefered size (width,height); for basis of development
{                                                // the gw "display" is always automatically set to fill the screen; for testing &/or exporting
  dev_width=w; dev_height=h;                     // i left choice in there so it is clear that we are setting the size for development 
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_GWsize(String window, String orient, String choice)
{
  int w=0, h=0;
  
  if(choice.equals("set"))
  {
    if(window.equals("emulator")) 
    {
      if(orient.equals("portrait")) { w=480; h=750; }  
      else { w=750; h=480; }    // should actually be (450,800) for android emulator
    }
    else if(window.equals("x10mini")) 
    {
      if(orient.equals("portrait")) { w=240; h=320; }
      else { w=320; h=240; }    
    }
    else if(window.equals("galaxys3")) 
    {
      if(orient.equals("portrait")) { w=720; h=1280; }
      else { w=1280; h=720; }
    }
    else if(window.equals("bigcam")) 
    {
      if(orient.equals("portrait")) { w=960; h=1280; }
      else { w=960; h=1280; }
    }
    else if(window.equals("smallcam")) 
    {
      if(orient.equals("portrait")){ w=480; h=640; }
      else { w=640; h=480; }
    }
    else if(window.equals("minicam")) 
    {
      if(orient.equals("portrait")){ w=240; h=320; }
      else { w=320; h=240; }
    }
    else { println("jm_GWsize:invalid window selection!"); exit(); }
    
    dev_width=w; dev_height=h;
  }
  
  else if(choice.equals("display"))
  {
    if(orient.equals("portrait")){ orientation(PORTRAIT); }
    else { orientation(LANDSCAPE); }
  }
  
  else { println("jm_GWsize:invalid choice selection!"); exit(); }
  
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
