import wikipedia
#wikiから中身取り出し
class WikipediaExtractor:
    def __init__(self, keyword):
        self.keyword = keyword
        self.page_data = None
        self.clean_text = ""

    def remove_related_items(self, text):
        index = text.find("== 関連事項 ==")
        if index != -1:
            return text[:index]
        return text

    def remove_whitespace(self, text):
        # 改行と空白を削除
        text = text.replace("\n", "").replace(" ", "").replace("\t", "")

        # 空白行を削除
        lines = text.split("\n")
        non_blank_lines = [line for line in lines if line.strip() != ""]
        text = "\n".join(non_blank_lines)

        return text
    #azureでの最大サイズを超えないように分割
    def split_string(self, string, chunk_size):
        return [string[i:i+chunk_size] for i in range(0, len(string), chunk_size)]

    def search_keyword(self):
        wikipedia.set_lang("ja")
        search_response = wikipedia.search(self.keyword)
        if search_response:
            self.page_data = wikipedia.page(search_response[0])
    
    def extract_content(self):
        if self.page_data:
            clean_text = self.remove_related_items(self.page_data.content)
            self.clean_text = self.remove_whitespace(clean_text)
    
    def get_chunked_content(self, chunk_size):
        if self.clean_text:
            return self.split_string(self.clean_text, chunk_size)
        return []

"""
if __name__ == '__main__':
    keyword = "織田信長"
    extractor = WikipediaExtractor(keyword)
    extractor.search_keyword()
    extractor.extract_content()
    content_chunks = extractor.get_chunked_content(5050)
    print(content_chunks)"""
