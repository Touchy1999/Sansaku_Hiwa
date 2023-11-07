import contentfromwiki
import locationfromazure
import clean_text
import googlemaps_geocode
import wiki_description
import json

if __name__ == '__main__':
    new_data = []
    keywords = ["織田信長", "豊臣秀吉", "徳川家康"]
    for keyword in keywords:
        # Wikipediaからコンテンツを抽出する
        extractor = contentfromwiki.WikipediaExtractor(keyword)
        extractor.search_keyword()
        extractor.extract_content()
        content_chunks = extractor.get_chunked_content(5050)

        # Azure Text Analyticsでエンティティを抽出する
        key = "2b087a234c53499c9e22f9971ba27e43"
        endpoint = "https://sansakusuruo.cognitiveservices.azure.com/"
        entity_recognition = locationfromazure.EntityRecognition(key, endpoint)
        name_list = entity_recognition.recognize_entities(content_chunks)

        # 地名をクリーニングする
        cleaner = clean_text.LocationCleaner(name_list)
        cleaner.clean_location_names()

        # 結果を表示する
        cleaned_names = cleaner.cleaned_name_list
        
        """print("地名のリスト:")
        print(cleaned_names)
        removed_names = cleaner.removed_elements
        print("削除されたリスト")
        print(removed_names)"""

        # Google Maps Geocoding APIのエンドポイントとAPIキー
        api_key = "AIzaSyAvA_WHhDZnC3QAhRQB1GDThXHxWGpJjHU"
        geocoding_endpoint = "https://maps.googleapis.com/maps/api/geocode/json"

        location_coordinates = googlemaps_geocode.LocationCoordinates(api_key, geocoding_endpoint)

        # 各地名の緯度と経度を取得
        coordinates_list = []
        # 削除するインデックスを保持するリスト
        indices_to_remove = []  
        for i, location in enumerate(cleaned_names):
            coordinates = location_coordinates.get_coordinates(location)
            if coordinates:
                coordinates_list.append(coordinates)
            else:
                indices_to_remove.append(i)

        # 削除するインデックスを逆順に処理して要素を削除
        for index in reversed(indices_to_remove):
            del cleaned_names[index]
        # 結果の表示
        result_list = []
        for location, coordinates in zip(cleaned_names, coordinates_list):
            latitude, longitude = coordinates
            result = {
                "name": location,
                "lat": latitude,
                "lng": longitude,
                "relation": keyword
            }
            result_list.append(result)
        
        #json_result = json.dumps(result_list, ensure_ascii=False)
        # 京都にある範囲のデータを抽出
        filtered_data = []
        for item in result_list:
            latitude = item["lat"]
            longitude = item["lng"]
            if 34.82 <= latitude <= 35.09 and 135 <= longitude <= 136:
                filtered_data.append(item)
        
        #description
        fetcher = wiki_description.WikipediaDescriptionFetcher()
        data_with_description = fetcher.fetch_description(filtered_data)
        

        #"description"と"relation"入れ替え
        
        for item in data_with_description:
                new_item = {
                    "name": item["name"],
                    "lat": item["lat"],
                    "lng": item["lng"],
                    "description": item["description"],
                    "relation": item["relation"]
                }
                new_data.append(new_item)

    # Convert the data to JSON format
    json_result = json.dumps(new_data, ensure_ascii=False)

    # Print the JSON result"""
    print(json_result)


    with open('tokugawakyoto.json', 'w') as f:
        print(json_result, file=f)
