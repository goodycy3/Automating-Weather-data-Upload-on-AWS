import os
import json
import boto3  
import requests  
from datetime import datetime
from dotenv import load_dotenv


# Load environment variables
load_dotenv()

# Configuration
OPENWEATHER_API_KEY = os.getenv('OPENWEATHER_API_KEY')
S3_BUCKET = ('${bucket_name}')
CITIES = ["London", "Nigeria", "New York"]

if not OPENWEATHER_API_KEY:
    raise ValueError("OPENWEATHER_API_KEY environment variable is required")
if not S3_BUCKET:
    raise ValueError("AWS_BUCKET_NAME environment variable is required")


class WeatherDashboard:
    def __init__(self, api_key, bucket_name):
        self.api_key = api_key
        self.bucket_name = bucket_name
        self.s3_client = boto3.client('s3')

    def fetch_weather(self, city):
        """Fetch weather data from OpenWeather API"""
        url = f"http://api.openweathermap.org/data/2.5/weather"
        params = {
            "q": city,
            "appid": self.api_key,
            "units": "imperial"
        }
        try:
            response = requests.get(url, params=params)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching weather data: {e}")
            return None

    def save_to_s3(self, weather_data, city):
        """Save weather data to S3 bucket"""
        if not weather_data:
            return False
        
        timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
        file_name = f"weather-data/{city}-{timestamp}.json"
        
        try:
            weather_data['timestamp'] = timestamp
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=file_name,
                Body=json.dumps(weather_data),
                ContentType='application/json'
            )
            print(f"Successfully saved data for {city} to S3")
            return True
        except Exception as e:
            print(f"Error saving to S3: {e}")
            return False

def main():
    dashboard = WeatherDashboard(api_key=OPENWEATHER_API_KEY, bucket_name=S3_BUCKET)
    
    for city in CITIES:
        print(f"\nFetching weather for {city}...")
        weather_data = dashboard.fetch_weather(city)
        if weather_data:
            temp = weather_data['main']['temp']
            feels_like = weather_data['main']['feels_like']
            humidity = weather_data['main']['humidity']
            description = weather_data['weather'][0]['description']
            
            print(f"Temperature: {temp}°F")
            print(f"Feels like: {feels_like}°F")
            print(f"Humidity: {humidity}%")
            print(f"Conditions: {description}")
            
            # Save to S3
            success = dashboard.save_to_s3(weather_data, city)
            if success:
                print(f"Weather data for {city} saved to S3!")
        else:
            print(f"Failed to fetch weather data for {city}")

if __name__ == "__main__":
    main()
