/*
|| | Demonstrates changing the LED right upon authentication and confirmation
|| #
*/
#include <Keypad.h>

const byte ROWS = 4; //four rows
const byte COLS = 4; //four columns
//define the cymbols on the buttons of the keypads
char hexaKeys[ROWS][COLS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};
byte rowPins[ROWS] = {9, 8, 7, 6}; //connect to the row pinouts of the keypad
byte colPins[COLS] = {5, 4, 3, 2}; //connect to the column pinouts of the keypad
char val; // Data received from the serial port
int ledPinGreen = 10; // Set the pin to digital I/O 10
int ledPinRed = 11; // Set the pin to digital I/O 11
boolean ledState = LOW;

//initialize an instance of class NewKeypad
Keypad customKeypad = Keypad( makeKeymap(hexaKeys), rowPins, colPins, ROWS, COLS); 

void setup(){
  Serial.begin(9600);
   // initialize digital pin 10 and 11 as an output.
  pinMode(10, OUTPUT);
  pinMode(11, OUTPUT);
  // establishContact();  // send a byte to establish contact until receiver responds
  digitalWrite(10, LOW);   // turn the LED off (LOW is the voltage level)
  digitalWrite(11, LOW);
}
  
void loop(){
  char customKey = customKeypad.getKey();

  if (customKey){
    Serial.println(customKey);
  }
  
  if (Serial.available()) 
   { // If data is available to read,
     val = Serial.read(); // read it and store it in val

     if (val == 'x') 
     { // If 1 was received
       digitalWrite(ledPinGreen, HIGH); // turn the Green LED on
       digitalWrite(ledPinRed, LOW);
       delay(3500); //LED turn on for 3.5 seconds
       digitalWrite(ledPinGreen, LOW); //Switches LED off
       
     } else if (val == 'y') {
       digitalWrite(ledPinGreen, LOW);
       digitalWrite(ledPinRed, HIGH); // otherwise RED LED on
       delay(3500); //LED turn on for 3.5 seconds
       digitalWrite(ledPinRed, LOW); //Switches LED off
     } else {
      digitalWrite(ledPinGreen, LOW);
      digitalWrite(ledPinRed, LOW);
     }
   }

   delay(10); // Wait 3500 milliseconds for next reading
}

void establishContact() {
  while (Serial.available() <= 0) {
  Serial.println("A");   // send a capital A
  delay(300);
  }
}
