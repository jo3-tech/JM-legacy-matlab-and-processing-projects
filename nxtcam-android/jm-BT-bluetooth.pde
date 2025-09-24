//FOR ANDROID  
//==LIBRARIES============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
//needs the following imports in the main tab:
//android.content.Intent;      // this is required for overriding the onActivityResult() function which supports ketai bluetooth somehow?
//android.os.Bundle;           // this is required for overriding the onCreate() function in order to enable ketai bluetooth on startup
//ketai.net.bluetooth.*;       // these 2 are required for bluetooth
//ketai.net.*;

//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
KetaiBluetooth bt;
//---------------------------------------------------------------------------------------------------------------------------------------
String _btmsg="program not started"; 

//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BTcreate()
{
  bt = new KetaiBluetooth(this);
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BTactivity(int requestCode, int resultCode, Intent data)
{
  bt.onActivityResult(requestCode, resultCode, data);
}
//---------------------------------------------------------------------------------------------------------------------------------------
String jm_BTmessage()
{
  return _btmsg;
}  
//---------------------------------------------------------------------------------------------------------------------------------------
boolean jm_BTfind()
{
  bt.start();               // start listening for devices 
  if(bt.isStarted())        // or u can use if(bt.start()) since it returns a value of true if it worked
  {
    bt.discoverDevices();   // Start finding devices
    _btmsg="searching for devices";
    println("searching for devices");
    return true;     // indicate bluetooth search has successfully begun
  } 
  else 
  {
    _btmsg="error; problem with bluetooth/bluetooth off?";
    println("error; problem with bluetooth/bluetooth off?");
    return false;    // indicate bluetooth search failed to start
  }
} 
//---------------------------------------------------------------------------------------------------------------------------------------
boolean jm_BTfinished()
{
  if(bt.isDiscovering()){ return false; }
  else{ _btmsg = "bluetooth search completed"; println("bluetooth search completed"); return true; }
}
//---------------------------------------------------------------------------------------------------------------------------------------
boolean jm_BTconnect(String device_name)        // if needed make a function that connects using bt.connectDevice(HW_ADDRESS);
{
  // now search for the service we want
  boolean connecting=false;
  ArrayList<String> devices = bt.getDiscoveredDeviceNames();
  
  for (int i=0; i < devices.size(); i++) 
  {
    if(devices.get(i).toString().equals(device_name)) 
    {
      bt.connectToDeviceByName(device_name);       
      connecting=true;   
      break;
    }
  }
  
  if(connecting) { _btmsg = "connected to device " + device_name; println("connecting to device " + device_name); } 
  else { _btmsg = device_name + " not found"; println(device_name + " not found"); } 
  
  return connecting;

//***there is no actual way to check if the connection was actually made; for some reason it makes the connection but the value returned doesn't acknowlegde this***
//you just have to put a delay in your program to give enough time for the connection to be made... about 5-10 seconds
}   
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BTsend(String device_name, byte data[])
{
  bt.writeToDeviceName(device_name,data);
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BTstop()
{
  if(bt.isStarted()){ bt.stop(); }
}
//---------------------------------------------------------------------------------------------------------------------------------------
