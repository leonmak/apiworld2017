import processing.serial.*;
import http.requests.*;

Serial myPort;  // Create object from Serial class
String val = "";     // Data received from the serial port

void setup()
{
  // I know that the first port in the serial list on my mac
  // is Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  size(200,200); //make our canvas 200 x 200 pixels big
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
}

void draw()
{
  if ( myPort.available() > 0) 
  {  // If data is available,
    String digit = myPort.readStringUntil('\n');         // read it and store it in val
    if (digit != null) {
      String digitKey = digit.replace("\n", "").replace("\r", "");
      val = val + digitKey;
      println("Key typed: " + digitKey);
    }
    
    if (val.length() >= 4) {
      println("You typed: " + val); //print it out in the console
      
      String url = "http://apiworld2017.back4app.io/verify?otp=" + val;
      println(url);
      PostRequest post = new PostRequest(url, "UTF-8"); 
      post.send();
      println("Reponse Content: " + post.getContent());
      println("Reponse  Content-Length Header: " + post.getHeader("Content-Length"));
      String result = post.getContent();
      
      if (result.charAt(0) == '1') //Set the condition to output 1 [Turn on Green light] or output 0 [Turn on red light] 
      {
         myPort.write("x");         //send a 1 
         println("x");
      } else if (result.charAt(0) == '0') 
      {                           //otherwise
        myPort.write("y");          //send a 0
        println("y");
      }
      
      val = "";
      
    }
  } 
}