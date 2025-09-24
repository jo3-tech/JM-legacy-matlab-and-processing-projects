//FOR JAVA AND ANDROID
//==CLASSES==============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
class jm_TB            // button (or non scrollable text) class
{
  int number;          // text number
  
  String name;         // text name i.e. the text content is being referred to as the name (n)
  int nColor;          // name colour
  float nOpacity;      // name opacity
  PFont nFont;         // name font
  float nSize;         // name size
  
  int bColor;          // text box/button colour
  int bStroke;         // box stroke
  float bThick;        // box stroke thickness
  float bOpacity;      // box opacity
  float bX, bY;        // box location
  float bW, bH, bR;    // box size (width, height & corner radii)
  
  boolean bHlight;     // button/box highlight; true (yes) or false (no) 
  int lButton;         // this is put here (along with button number) to help the user keep track of the last button (which must also have been created with this class) that was pressed
//....................................................................................................................................... 
  jm_TB(int iNU, String iNA, int inC, float inO, PFont inF, float inS, int ibC, int ibS, float ibT, float ibO, float ibX, float ibY, float ibW, float ibH, float ibR, boolean ihL)
  {
    number=iNU; name=iNA; nColor=inC; nOpacity=inO; nFont=inF; nSize=inS; bColor=ibC; bStroke=ibS; bThick=ibT; bOpacity=ibO; bX=ibX; bY=ibY; bW=ibW; bH=ibH; bR=ibR; bHlight=ihL;
    lButton=-1;
  }
//.......................................................................................................................................  
  void jm_TBdisplay(float wS, float hS)
  {    
    pushStyle();                    // store current drawing style (stroke, fill, etc)
    
    rectMode(CORNER);
    textAlign(CENTER,CENTER);
    
    pushMatrix();                   // store coordinate system
    translate(bX*wS,bY*hS);         // shift coordinate system to location of button
    scale(wS,hS);                   // scale button & text

    if(bColor==-number){ noFill(); }
    else{ fill(bColor,bOpacity); }
    
    if(bStroke==-number){ noStroke(); }
    else{ stroke(bStroke,bOpacity); strokeWeight(bThick); }
    
    rect(0,0,bW,bH,bR);             // display button
    
    if(bHlight==true)                   
    {
      if(jm_TBmouseOver(wS,hS))
      {
        fill(#FFFFFF,70); 
        rect((-0.02*bW),(-0.075*bH),(1.04*bW),(1.15*bH),bR); // display highlight 
      }
    }
    
    if(nColor==-number){ noFill(); }
    else{ fill(nColor,nOpacity); }  // specify text color & opacity
    
    textFont(nFont,nSize);
//    text(name,bW/2,bH/2);           // display name      *****this doesnt wrap the text automatically*****
    text(name,0,0,bW,bH);           // display name
  
    popMatrix();                    // restore coordinate system
    
    popStyle();                     // restore previous drawing style
  }
//.......................................................................................................................................  
  void jm_TBdisplay()
  {
    jm_TBdisplay(1,1);
  }
//.......................................................................................................................................  
  boolean jm_TBmouseOver(float wS, float hS)  
  {
    if(mouseX>=bX*wS && mouseX<=(bX+bW)*wS && mouseY>=bY*hS && mouseY<=(bY+bH)*hS){ return true; }
    else{ return false; }
  }                  
//.......................................................................................................................................  
  boolean jm_TBmouseOver()
  {
    return jm_TBmouseOver(1,1);
  }
//.......................................................................................................................................  
  void jm_TBsetName(String new_name)
  {
    name=new_name;
  }
//.......................................................................................................................................  
  String jm_TBgetName()
  {
    return name;
  }
//.......................................................................................................................................  
  int jm_TBgetNum()
  {
    return number;
  }
//.......................................................................................................................................
  void jm_TBsetbW(float new_width)
  {
    bW=new_width;
  }
}  // end button class
//---------------------------------------------------------------------------------------------------------------------------------------
