import contentfromwiki
from azure.ai.textanalytics import TextAnalyticsClient
from azure.core.credentials import AzureKeyCredential

class EntityRecognition:
    def __init__(self, key, endpoint):
        self.key = key
        self.endpoint = endpoint
        self.client = self.authenticate_client()

    def authenticate_client(self):
        ta_credential = AzureKeyCredential(self.key)
        text_analytics_client = TextAnalyticsClient(endpoint=self.endpoint, credential=ta_credential)
        return text_analytics_client

    def recognize_entities(self, text_list):
        try:
            name_list = []
            for text in text_list:
                documents = [text]
                result = self.client.recognize_entities(documents=documents, language="ja")[0]
                for entity in result.entities:
                    if entity.category == 'Location':
                        name_list.append(entity.text)

            # setで重複を削除して、リストに戻す
            name_list = list(set(name_list))
            return name_list  # name_listを戻り値として返す

            
        except Exception as err:
            print("Encountered exception: {}".format(err))

"""
if __name__ == '__main__':
    key = ""
    endpoint = "https://sansaku2.cognitiveservices.azure.com/"
    keyword = "織田信長"
    chunk_size = 5050

    # Wikipediaからテキストを抽出する
    extractor = contentfromwiki.WikipediaExtractor(keyword)
    extractor.search_keyword()
    extractor.extract_content()
    description_list = extractor.get_chunked_content(chunk_size)
    

    entity_recognition = EntityRecognition(key, endpoint)
    name_list = entity_recognition.recognize_entities(description_list)

    print(name_list)"""
