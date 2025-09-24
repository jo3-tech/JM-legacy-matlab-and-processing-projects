//FOR JAVA AND ANDROID
//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
float[] jm_CErgbExtract(PImage input,int x1, int y1, int x2, int y2)
{
  float[] colour=new float[3];        // to store extracted colour
  int totPIX;                         // to store total number of pixels
  input.loadPixels();                 // load input image pixels for read/write access
  
  for(int x=x1; x<=x2; x++)
  {
    for(int y=y1; y<=y2; y++)
    {
      int loc = x + y*input.width;
    
      //extract & sum up the Red(R),Green(G) & Blue(B) channels in region of interest
      
      colour[0]=colour[0]+red(input.pixels[loc]);
      colour[1]=colour[1]+green(input.pixels[loc]);
      colour[2]=colour[2]+blue(input.pixels[loc]);
    }
  }

  totPIX=(abs(x2-x1)+1)*(abs(y2-y1)+1);

  //calculate the average values
  
  colour[0]=colour[0]/totPIX;  
  colour[1]=colour[1]/totPIX;
  colour[2]=colour[2]/totPIX;

  //input.updatePixels()              // shouldn't need this since we haven't written to/modified any pixels
  
  return colour;
}
//---------------------------------------------------------------------------------------------------------------------------------------
  
