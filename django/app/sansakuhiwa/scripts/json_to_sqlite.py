import json

from explore.models import Spot
import os
import json

# json_to_sqlite.pyスクリプトのパスを取得
script_path = os.path.dirname(os.path.abspath(__file__))

# collectdata/odakyoto.jsonファイルのパスを作成
#json_file_path = os.path.join(script_path, '../collectdata/odakyoto.json')
json_file_path = os.path.join(script_path, '../collectdata/oda_tokugawa_toyotomikyoto.json')


# collectdata/odakyoto.jsonファイルを開いて中身を読み込む
with open(json_file_path, 'r') as json_file:
    json_data = json.load(json_file)

# 中身を表示する

json_data
"""
data = [
    {
        "name": "上京武者小路",
        "lat": 35.0278551,
        "lng": 135.7569112,
        "description": "武者小路 実篤（むしゃのこうじ さねあつ、旧字体: 武者小路 實篤、1885年〈明治18年〉5月12日 - 1976年〈昭和51年〉4月9日）は、日本の小説家・詩人・劇作家・画家。貴族院勅選議員。華族の出で、トルストイに傾倒し、『白樺』創刊に参加。天衣無縫の文体で人道主義文学を創造し、「新しき村」を建設して実践運動を行った。伝記や美術論も数多い。\n姓の武者小路は本来「むしゃのこうじ」と読むが、実篤は「むしゃこうじ」に読み方を変更した。しかし、一般には「むしゃのこうじ」で普及しており、本人も誤りだと糺すことはなかったという。仲間からは「武者」（ムシャ）の愛称で呼ばれた。文化勲章受章。名誉都民。日本芸術院会員。贈従三位（没時叙位）。",
        "relation": "織田信長"
    },
    {
        "name": "六条本圀寺",
        "lat": 34.9992838,
        "lng": 135.8073194,
        "description": "本圀寺（ほんこくじ）は、京都市山科区御陵大岩にある日蓮宗の大本山（霊跡寺院）の寺院。山号は大光山。本尊は三宝尊。六条門流の祖山である。",
        "relation": "織田信長"
    }
]"""

def run():
    for item in json_data:
        
        spot = Spot.objects.create(
            name=item['name'],
            lat=item['lat'],
            lng=item['lng'],
            description=item['description'],
            relation=item['relation']
        )
        spot.save()

