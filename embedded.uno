
#include <DHT.h>
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266HTTPClient.h>
#include <LiquidCrystal_I2C.h>
DHT dht(13, DHT11); // D7 on esp8266
#define BUZZER 12 // D6 on esp8266
#define REDPIN 14 // D5 on esp8266
#define GREENPIN 16 // D0 on esp8266
// SDA  - D2
// SCL - D1
LiquidCrystal_I2C lcd(0x27, 16, 2);
const char* ssid = "RCA-WiFii";          // Your WiFi SSID
const char* password = "@rca@2023";  // Your WiFi password

const char* serverAddress = "http://192.168.1.150/weather-station/backend.php";
void setup()
{
  Serial.begin(9600);
  Serial.println("DHT11 Temperature and Humidity Sensor");
  dht.begin();  pinMode(BUZZER, OUTPUT);
  pinMode(REDPIN, OUTPUT);
  pinMode(GREENPIN, OUTPUT);
    // Initialize the LCD display
  lcd.begin(16, 2);
  lcd.init();
  lcd.backlight();
 connectToWiFi();
}
void loop()
{
  delay(10000); // Wait for 10 seconds between readings
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
    Serial.print(" %");        // Display temperature on the LCD
    lcd.setCursor(0, 0);
    lcd.print("Temp: ");
    lcd.print(temperature);
    lcd.print(" ");//    Display the humidity on LCD
        lcd.setCursor(0,1);
     lcd.print("Humidity: ");
     lcd.print("");
     lcd.print(humidity);
     lcd.print(" ");    // Upload data to the server
    if (temperature >= 25)
    {
      digitalWrite(REDPIN, HIGH);
      digitalWrite(GREENPIN, LOW);
      for (int i = 0; i < 10; i++)
  {
    digitalWrite(BUZZER, HIGH);
    delay(100);  // Buzzer ON for 100 milliseconds
    digitalWrite(BUZZER, LOW);
    delay(100);  // Buzzer OFF for 100 milliseconds
  }
    }
    else
    {
      digitalWrite(REDPIN, LOW);
      digitalWrite(BUZZER, LOW);
      digitalWrite(GREENPIN, HIGH);
    }
  }
  sendDataToServer(temperature, humidity);
}
void connectToWiFi()
{
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
}
void sendDataToServer(float temperature, float humidity)
{
  WiFiClient client;
  HTTPClient http;
  // Build the URL with query parameters
  String url = serverAddress;
//  url += "/api/data";
  url += "?device=340722SPE02020";
  url += "&temperature=" + String(temperature);
  url += "&humidity=" + String(humidity);
  Serial.println("Heeeeee");
  // Send HTTP GET request
  http.begin(client, url);
  http.setTimeout(10000); // Set timeout to 10 seconds (for example)
  int httpResponseCode = http.GET();
  Serial.println(httpResponseCode);
  if (httpResponseCode > 0)
  {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
  }
  else
  {
    Serial.println("Error sending data to server");
  }
  http.end();
}