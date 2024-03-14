#include <avr/interrupt.h>

volatile unsigned long int interruptCount = 0; // Variable to count interrupts

unsigned long int start = 0;
// Define the ISR for INT0
ISR(INT0_vect) {
  interruptCount++; // Increment interrupt count
}

void setup() {
  // Set INT0 (pin D2 on Arduino Uno) as input
  DDRD &= ~(1 << PD2);

  // Enable external interrupt INT0
  EICRA |= (1 << ISC01) | (1 << ISC00); // Rising edge trigger
  EIMSK |= (1 << INT0); // Enable INT0 interrupt

  Serial.begin(9600);
  sei();
  start = millis();
}

void loop() {
  unsigned long int current = millis();
  if(current - start > 500){
    start = current;
    Serial.println(interruptCount);
    interruptCount = 0;
  }
}


void turnclockwise(){
  turnA();
  delay(10);
  turnB();
  delay(10);
  turnC();
  delay(10);
  turnD();
  delay(10);

}
void turnanticlockwise(){
  turnD();
  delay(10);
  turnC();
  delay(10);
  turnB();
  delay(10);
  turnA();
  delay(10);
}
void turnA(){
  digitalWrite(8,HIGH);
  digitalWrite(9,LOW);
  digitalWrite(10,LOW);
  digitalWrite(11,LOW);
}
void turnB(){
  digitalWrite(8,LOW);
  digitalWrite(9,HIGH);
  digitalWrite(10,LOW);
  digitalWrite(11,LOW);
}
void turnC(){
  digitalWrite(8,LOW);
  digitalWrite(9,LOW);
  digitalWrite(10,HIGH);
  digitalWrite(11,LOW);
}
void turnD(){
  digitalWrite(8,LOW);
  digitalWrite(9,LOW);
  digitalWrite(10,LOW);
  digitalWrite(11,HIGH);
}

void number(){
  digitalWrite(8,HIGH);
  digitalWrite(9,HIGH);
  digitalWrite(10,HIGH);
  digitalWrite(11,LOW);
}