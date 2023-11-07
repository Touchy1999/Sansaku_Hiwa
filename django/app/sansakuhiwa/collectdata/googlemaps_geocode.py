import requests
import json
import clean_text

# Google Maps Geocoding APIのエンドポイントとAPIキー
api_key = "********"
geocoding_endpoint = "https://maps.googleapis.com/maps/api/geocode/json"

class LocationCoordinates:
    def __init__(self, api_key, geocoding_endpoint):
        self.api_key = api_key
        self.geocoding_endpoint = geocoding_endpoint

    def get_coordinates(self, location):
        params = {
            "key": self.api_key,
            "address": location,
        }
        response = requests.get(self.geocoding_endpoint, params=params)
        data = response.json()
        if data["results"]:
            result = data["results"][0]
            geometry = result["geometry"]["location"]
            latitude = geometry["lat"]
            longitude = geometry["lng"]
            return latitude, longitude
        return None
"""
if __name__ == '__main__':
    name_list = clean_text.cleaned_names

    location_coordinates = LocationCoordinates(api_key, geocoding_endpoint)

    # 各地名の緯度と経度を取得
    coordinates_list = []
    # 削除するインデックスを保持するリスト
    indices_to_remove = []  
    for i, location in enumerate(name_list):
        coordinates = location_coordinates.get_coordinates(location)
        if coordinates:
            coordinates_list.append(coordinates)
        else:
            indices_to_remove.append(i)

    # 削除するインデックスを逆順に処理して要素を削除
    for index in reversed(indices_to_remove):
        del name_list[index]
    # 結果の表示
    result_list = []
    for location, coordinates in zip(name_list, coordinates_list):
        latitude, longitude = coordinates
        result = {
            "location": location,
            "latitude": latitude,
            "longitude": longitude
        }
        result_list.append(result)
   
    json_result = json.dumps(result_list, ensure_ascii=False)
    print(json_result)
"""