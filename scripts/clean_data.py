
import pandas as pd

# 1. Historical dataset (2015-2020) - city-level daily, pollutant breakdown 
hist = pd.read_csv('Raw_Data/city_day.csv')
hist.columns = [c.strip().lower().replace('.', '').replace(' ', '_') for c in hist.columns]
hist['date'] = pd.to_datetime(hist['date'])
hist['city'] = hist['city'].str.strip()
hist.to_csv('Raw_Data/historical_clean.csv', index=False)
print("Historical rows:", len(hist))

# 2. Recent dataset (2022-2025) - full NCR + national 
recent = pd.read_csv('Raw_Data/aqi.csv')
recent.columns = [c.strip().lower() for c in recent.columns]
recent['date'] = pd.to_datetime(recent['date'], format='%d-%m-%Y')
recent['area'] = recent['area'].str.strip().str.title()  # NOIDA -> Noida
recent = recent.drop(columns=['unit', 'note'])
recent.to_csv('Raw_Data/recent_clean.csv', index=False)
print("Recent rows:", len(recent))

# 3. city_hour dataset (2015-2020) - hourly granularity 
city_hour = pd.read_csv('Raw_Data/city_hour.csv')
city_hour.columns = [c.strip().lower().replace('.', '').replace(' ', '_') for c in city_hour.columns]
city_hour['datetime'] = pd.to_datetime(city_hour['datetime'])
city_hour['city'] = city_hour['city'].str.strip()
city_hour.to_csv('Raw_Data/city_hour_clean.csv', index=False)
print("City hour rows:", len(city_hour))

# 4. stations dataset - metadata: station -> city mapping
stations = pd.read_csv('Raw_Data/stations.csv', encoding='utf-8-sig')  # utf-8-sig fixes BOM/weird symbols
stations.columns = [c.strip().lower() for c in stations.columns]
stations = stations.rename(columns={'stationid': 'station_id', 'stationname': 'station_name'})
stations['city'] = stations['city'].str.strip()
stations.to_csv('Raw_Data/stations_clean.csv', index=False)
print("Stations rows:", len(stations))

print("\nCleaning done. All 4 clean CSVs saved in Raw_Data folder.")