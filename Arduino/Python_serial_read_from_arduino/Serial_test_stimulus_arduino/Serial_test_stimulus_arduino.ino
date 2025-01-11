int sample = 0; 

void setup() {
  Serial.begin(9600);
}

void loop() {
  // generates a square wave with amplitude of 150 units (0-150) that repeats every 1000 samples
  for (int i = 0; i < 500; i++)
  {
    Serial.print(sample);
    Serial.print("\n");
  }

  sample = 150;

  for (int i = 0; i < 500; i++)
  {
    Serial.print(sample);
    Serial.print("\n");
  }
  
  sample = 0;

}
