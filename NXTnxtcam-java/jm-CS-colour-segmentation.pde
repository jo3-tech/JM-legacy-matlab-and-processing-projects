//FOR JAVA AND ANDROID
//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
PImage jm_CSeuclidean(PImage origo,float rgb[],float threshold)
{
  PImage input=createImage(origo.width,origo.height,RGB);

  input.copy(origo,0,0,origo.width,origo.height,0,0,input.width,input.height); // have to transfer origo input to temp input since PImage is transferred by reference & blurring will change origo input
//  input.filter(BLUR,3);               // blurring reduces colour variation at the edges (like smoothing?), however it seems to take a lot of processing power especially in android mode
  
  PImage output=createImage(input.width,input.height,RGB);  // set the segmented output image to the same size as the input image
  float[][] distance=new float[input.width][input.height];  // to store euclidean distance matrix; set to the same size as input image
  input.loadPixels();                 // load input image pixels for read/write access
  output.loadPixels();                // load segmented output image pixels for read/write access
  
  for(int x=0; x<input.width; x++)
  {
    for(int y=0; y<input.height; y++)
    {
      int loc = x + y*input.width;
      
      // Extract the Red(R),Green(G) & Blue(B) channels of the image & apply euclidean distance formula
      
      distance[x][y]=sqrt(sq(red(input.pixels[loc])-rgb[0])+sq(green(input.pixels[loc])-rgb[1])+sq(blue(input.pixels[loc])-rgb[2]));
      //distance[x][y]=dist(red(input.pixels[loc]),green(input.pixels[loc]),blue(input.pixels[loc]),rgb[0],rgb[1],rgb[2]);
      
      // Create a black & white image based on the euclidean distance & threshold
      
      if(distance[x][y]<=threshold) { output.pixels[loc]=color(255); }  // if the pixel value is within the threshold, set it to white
      else { output.pixels[loc]=color(0); }              // if the pixel value is beyond the threshold, set it to black
    }
  }
  
  output.updatePixels();
  //input.updatePixels()              // shouldn't need this since we haven't written to/modified any pixels

  return output;  
}
//---------------------------------------------------------------------------------------------------------------------------------------
