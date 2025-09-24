//FOR JAVA AND ANDROID
//==LIBRARIES============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
//needs the following imports in the main tab:
//Blobscanner.*;

//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
Detector bd;           // declare the blob scanner Detector object
//---------------------------------------------------------------------------------------------------------------------------------------
int _blobWE;               // coloured object weight (total no of pixels) 
int _blobA;               // coloured object bounding box area
int _nBLOBS;              // total no. of blobs

//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BAcreate(int x_start, int y_start, int x_end, int y_end, int bright_threshold)
{
  bd=new Detector(this, x_start, y_start, x_end, y_end, bright_threshold); 
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BAanalyse(PImage input)
{
  bd.imageFindBlobs(input);             // find blobs within segmented output image
  int nBLOBS = bd.getBlobsNumber();     // get total number of blobs found
  
  bd.loadBlobsFeatures();               // load centre of mass, contours, bounding box etc..
  bd.weightBlobs(false);                // only needs to be true if global weight required?
  
  int theBLOB=0; int blobWE=bd.getBlobWeight(theBLOB);      // set the first blob found to be the required blob & get its weight
  
  if(nBLOBS>1)                        // select largest blob if more than 1
  {
    for(int i=1; i<nBLOBS; i++)
    {
      int newbWE=bd.getBlobWeight(i);
      if(newbWE>blobWE) { theBLOB=i; blobWE=newbWE; } 
    }
  }
  
  _nBLOBS=nBLOBS; _blobWE=blobWE; _blobA=bd.getBlobWidth(theBLOB)*bd.getBlobHeight(theBLOB);
}
//---------------------------------------------------------------------------------------------------------------------------------------
int jm_BAtotalBlobs()
{
  return _nBLOBS;
}
//---------------------------------------------------------------------------------------------------------------------------------------
int jm_BAblobWeight()
{
  return _blobWE;
}
//---------------------------------------------------------------------------------------------------------------------------------------
int jm_BAblobArea()
{
  return _blobA;
}
