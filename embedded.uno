#include <dummy.h>

#include <DHT.h>
#include <ESP8266WiFi.h>
#include <LiquidCrystal_I2C.h>
DHT dht(15, DHT11);
#define REDPIN 4
#define GREENPIN 0
#define BUZZER 12
const char* ssid = "RCA-WiFii";
const char* password = "@rca@2023";
const char* host = "192.168.1.150";
LiquidCrystal_I2C lcd(0x27, 16, 2);
void setup()
{
  Serial.begin(9600);
  Serial.println("DHT11 Temperature and Humidity Sensor");
  dht.begin();
  // LEDs
  pinMode(REDPIN, OUTPUT);
  pinMode(GREENPIN, OUTPUT);
  pinMode(BUZZER, OUTPUT);
  // LCD
  lcd.begin(5,4);
  lcd.init();
  lcd.backlight();
  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}
void loop()
{
  delay(2000);
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  if (isnan(temperature) || isnan(humidity))
  {
    Serial.println("Failed to read data from DHT sensor");
  }
  else
  {
    Serial.print("Temperature: ");
    Serial.print(temperature);
    Serial.print(" °C");
    Serial.println("");
    Serial.print("Humidity: ");
    Serial.print(humidity);
    Serial.print(" %");
  }
  if (temperature > 25){
    digitalWrite(REDPIN, HIGH);
    digitalWrite(BUZZER, HIGH);
    digitalWrite(GREENPIN, LOW);
   }
   else {
    digitalWrite(REDPIN, LOW);
    digitalWrite(BUZZER, LOW);
    digitalWrite(GREENPIN, HIGH);
   }
    Serial.println("About to send data ............");
   String tempData="";
//   String indexNumber = "340722SPE02020";
//   tempData = "{\"device\"=\"+indexNumber+\",\"temperature=\"+(String) temperature;
   tempData = "{\"temperature\": " +(String) temperature + ", \"humidity\": " + (String) humidity+ "}";
   uploadData("192.168.1.150",3000, "/data" , tempData);
   lcd.clear();
   lcd.print("Temperature:");
   lcd.print(temperature);
   delay(1000);
}
void uploadData(const char* host, const int httpPort, const char* filepath, const String& data) {
  WiFiClient wifiClient;
  if (wifiClient.connect(host, httpPort)) {
    wifiClient.print("POST ");
    wifiClient.print(filepath);
    wifiClient.println(" HTTP/1.1");
    wifiClient.print("Host: ");
    wifiClient.println(host);
    wifiClient.println("User-Agent: ESP8266/1.0");
    wifiClient.println("Content-Type: application/json");
    wifiClient.print("Content-Length: ");
    wifiClient.println(data.length());
    wifiClient.println();
    wifiClient.println(data);
    Serial.println("Request sent");
  } else {
    Serial.println("Failed to connect to server");
  }
  while (wifiClient.connected() && !wifiClient.available()) {
    delay(1); // Wait for response
  }
  if (wifiClient.available()) {
    String response = wifiClient.readStringUntil('\n');
    Serial.println("Response: " + response);
  }
  wifiClient.stop();
}