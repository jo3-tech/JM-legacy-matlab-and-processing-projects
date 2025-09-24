//FOR JAVA AND ANDROID
//==LIBRARIES============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
//needs the following imports in the main tab:
//Blobscanner.*;

//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
Detector bd;           // declare the blob scanner Detector object
//---------------------------------------------------------------------------------------------------------------------------------------
int min_weight=700, max_weight=70000;        // 700, 70000 seems to work best for java mode, hence it should be abt half for android mode
float _blobX, _blobY;     // coloured object location (x,y)
String _blobmsg="tracking not started";

//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BAcreate(int x_start, int y_start, int x_end, int y_end, int bright_threshold)
{
  bd=new Detector(this, x_start, y_start, x_end, y_end, bright_threshold); 
}
//---------------------------------------------------------------------------------------------------------------------------------------
String jm_BAmessage()
{
  return _blobmsg;
}  
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BAanalyse(PImage input)
{
  bd.imageFindBlobs(input);             // find blobs within segmented output image
  int nBLOBS = bd.getBlobsNumber();     // get total number of blobs found
  
  bd.loadBlobsFeatures();               // load centre of mass, contours, bounding box etc..
  bd.weightBlobs(false);                // must be done b4 centroid method can be used (only needs to be true if global weight required? (total weight of all blobs in image)
  
  if(nBLOBS==0)                         // found no blobs
  {
    println("found no blobs");
    _blobmsg="found no objects";
    _blobX=-1;
  }

  else if(nBLOBS>=1)                    // found blobs
  {
    println("found "+nBLOBS+" blobs");
    int theBLOB=0; int blobWE=bd.getBlobWeight(theBLOB);      // set the first blob found to be the required blob & get its weight
    
    if(nBLOBS>1)                        // select largest blob if more than 1
    {
      for(int i=1; i<nBLOBS; i++)
      {
        int newbWE=bd.getBlobWeight(i);
        if(newbWE>blobWE) { theBLOB=i; blobWE=newbWE; } 
      }
    }
    
    if((blobWE>min_weight)&&(blobWE<max_weight))       // screen blob (only select the blob if it is large enough but not too large) >1000 && <10000
    {
      println("found suitable blob");
      _blobmsg="found suitable object";
      bd.findCentroids(false,false);    // compute centre of mass; but dont print coordinates or draw a points
      _blobX=bd.getCentroidX(theBLOB);   // get the location of the blobs (we only care about x-coordinate)
      _blobY=bd.getCentroidY(theBLOB);   // just need it for printing location to screen 
    } 
    else { _blobX=-1; println("found no suitable blobs"); _blobmsg="found no suitable objects"; }    // found no suitable blobs 
  }

}
//---------------------------------------------------------------------------------------------------------------------------------------
float jm_BAblobx()
{
  return _blobX;
}
//---------------------------------------------------------------------------------------------------------------------------------------
float jm_BAbloby()
{
  return _blobY;
}
//---------------------------------------------------------------------------------------------------------------------------------------
