const byte interruptPin = 2;
volatile byte state = LOW;
unsigned long start;

int count=0;
void setup() {
  Serial.begin(9600);
  pinMode(interruptPin, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(interruptPin), blink, CHANGE);

  pinMode(8,OUTPUT);
  pinMode(9,OUTPUT);
  pinMode(10,OUTPUT);
  pinMode(11,OUTPUT);

  start=millis();
}

void loop() {
  unsigned long current=millis();
  // if (current-start>1000){
  //   start=millis();
  //   Serial.println(count);
  //   count=0;
  // }
  // turnanticlockwise();
  number();

}

void blink() {
  state = !state;
  count+=1;
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