import wikipedia
import json

class WikipediaDescriptionFetcher:
    def __init__(self):
        # Wikipediaの言語設定（日本語）
        wikipedia.set_lang("ja")

    def fetch_description(self, data):
        # dataの各要素に対して検索と概要取得を行い、descriptionを追加
        for item in data:
            keyword = item["name"]

            try:
                # キーワードで検索
                search_response = wikipedia.search(keyword)

                if search_response:
                    # 検索結果の最初のページを取得
                    page_data = None
                    for option in search_response:
                        try:
                            page_data = wikipedia.page(option)
                            break
                        except wikipedia.exceptions.DisambiguationError:
                            continue

                    if page_data:
                        description = page_data.summary
                    else:
                        # 検索結果がない場合は空の文字列とする
                        description = ""
                else:
                    # 検索結果がない場合は空の文字列とする
                    description = ""
            except wikipedia.exceptions.PageError:
                description = ""

            # descriptionをdataに追加
            item["description"] = description

        return data

"""if __name__ == '__main__':
    data = [
        {
            "name": "二条御所",
            "lat": 35.0142299,
            "lng": 135.748218,
            "relation": "織田信長"
        },
        {
            "name": "大徳寺",
            "lat": 35.043891,
            "lng": 135.74603,
            "relation": "織田信長"
        },
        {
            "name": "槇島城",
            "lat": 34.8976063,
            "lng": 135.7973416,
            "relation": "織田信長"
        }
    ]

    fetcher = WikipediaDescriptionFetcher()
    data_with_description = fetcher.fetch_description(data)

    data_json = json.dumps(data_with_description, ensure_ascii=False)
    print(data_json)

    with open('sa.json', 'w') as f:
        print(data_json, file=f)"""
