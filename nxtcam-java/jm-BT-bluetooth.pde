//FOR JAVA
//==LIBRARIES============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
//needs the following imports in the main tab:
//bluetoothDesktop.*;

//==GLOBAL VARIABLES & CONSTANTS=========================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
Bluetooth bt;          // declare bluetooth object
Client server;
Service[] services;
//---------------------------------------------------------------------------------------------------------------------------------------
boolean btfinished=false;  // indicate whether bluetooth search has finished
boolean btconnected=false; // indicate whether bluetooth is connected
String btmsg="program not started"; 

//==FUNCTIONS============================================================================================================================
//---------------------------------------------------------------------------------------------------------------------------------------
String jm_BTmessage()
{
  return btmsg;
}  
//---------------------------------------------------------------------------------------------------------------------------------------
boolean jm_BTfind()
{
  btfinished=false; btconnected=false;
  
  try 
  {
    bt = new Bluetooth(this, Bluetooth.UUID_RFCOMM); // RFCOMM

    bt.find();  // start finding the service
    btmsg="searching for server";
    return true;     // indicate bluetooth search has successfully begun
  } 
  catch (RuntimeException e) 
  {
    println(e);
    btmsg="error; problem with bluetooth/bluetooth off?";
    return false;    // indicate bluetooth search failed to start
  }
} 
//---------------------------------------------------------------------------------------------------------------------------------------
boolean jm_BTfinished()
{
  return btfinished;
}
//---------------------------------------------------------------------------------------------------------------------------------------
// this gets called automatically when the bluetooth search process is over
void serviceDiscoveryCompleteEvent(Service[] s)
{
  services = (Service[])s;
  
  btfinished=true;

  btmsg = "bluetooth search completed.";
}
//---------------------------------------------------------------------------------------------------------------------------------------
boolean jm_BTconnect(String service_name)
{
  // now search for the service we want
  for (int i=0; i<services.length; i++) 
  {
    println(services[i].name);
    if (services[i].name.equals(service_name)) 
    {
      try 
      {
        // we found our service, so try to connect to it
        // if we try to connect to it more than once, this will throw an error.
        server = services[i].connect();
        btmsg = "connected to service " + service_name + " on server " + server.device.name;
        btconnected=true; return true;
      } 
      catch (Exception e) 
      {
        btmsg = "found service " + service_name + " on server " + server.device.name + ", but connection failed";
        println(e);
        return false;
      }
    } 
  }

  btmsg = "Service " + service_name + " not found.";
  return false;
}   
//---------------------------------------------------------------------------------------------------------------------------------------
boolean jm_BTconnected()
{
  return btconnected;
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BTstop()
{
  btconnected=false;    // I don't think it matters if you stop it or not so we'll just use a variable to say we intend for it to identiified as stopped
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BTsend(byte data[])
{
  server.write(data);
}
//---------------------------------------------------------------------------------------------------------------------------------------
void jm_BTsend(byte data)
{
  server.write(data);
}
//---------------------------------------------------------------------------------------------------------------------------------------
