#できなかった

'''
import openai
import json
import time
# Set the OpenAI API key
openai.api_key = "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"

# JSON data
data= [
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
    },
    {
        "name": "御所",
        "lat": 35.0254135,
        "lng": 135.7621246,
        "relation": "織田信長"
    },
    {
        "name": "大津",
        "lat": 35.0178371,
        "lng": 135.8552084,
        "relation": "織田信長"
    },
    {
        "name": "石清水八幡宮",
        "lat": 34.87941590000001,
        "lng": 135.7000573,
        "relation": "織田信長"
    },
    {
        "name": "妙覚寺",
        "lat": 35.0366477,
        "lng": 135.7539857,
        "relation": "織田信長"
    },
    {
        "name": "清涼殿",
        "lat": 35.0244109,
        "lng": 135.7617088,
        "relation": "織田信長"
    },
    {
        "name": "本能寺",
        "lat": 35.0040656,
        "lng": 135.7675375,
        "relation": "織田信長"
    },
    {
        "name": "東山",
        "lat": 34.9923961,
        "lng": 135.7757965,
        "relation": "織田信長"
    },
    {
        "name": "坂本城",
        "lat": 35.0582966,
        "lng": 135.8787651,
        "relation": "織田信長"
    },
    {
        "name": "山城勝龍寺城",
        "lat": 34.9182125,
        "lng": 135.7002789,
        "relation": "織田信長"
    },
    {
        "name": "比叡山延暦寺",
        "lat": 35.0704634,
        "lng": 135.8411275,
        "relation": "織田信長"
    },
    {
        "name": "比叡山",
        "lat": 35.0622477,
        "lng": 135.8315317,
        "relation": "織田信長"
    },
    {
        "name": "勧修寺晴",
        "lat": 34.9613511,
        "lng": 135.8076209,
        "relation": "織田信長"
    },
    {
        "name": "上京武者小路",
        "lat": 35.0278551,
        "lng": 135.7569112,
        "relation": "織田信長"
    },
    {
        "name": "本願寺",
        "lat": 34.99177700000001,
        "lng": 135.7516549,
        "relation": "織田信長"
    },
    {
        "name": "六条本圀寺",
        "lat": 34.9992838,
        "lng": 135.8073194,
        "relation": "織田信長"
    },
    {
        "name": "建勲神社",
        "lat": 35.0387057,
        "lng": 135.7431959,
        "relation": "織田信長"
    },
    {
        "name": "八上城",
        "lat": 35.0681695,
        "lng": 135.2606845,
        "relation": "織田信長"
    },
    {
        "name": "元亀",
        "lat": 35.0452001,
        "lng": 135.785247,
        "relation": "織田信長"
    }
]
name_list = []
for item in data:
    name_list.append(item["name"])
relation_list = []
for item in data:
    relation_list.append(item["relation"])
print(name_list)
print(relation_list)

chunk_size = (len(name_list) +2) // 3
name_chunks = [name_list[i:i+chunk_size] for i in range(0, len(name_list), chunk_size)]
print(name_chunks)
name = []
for i in range(3):
  name_str = "、".join(name_chunks[i])
  print(name_str)
  name.append(name_str)
print(name)

descriptions = []
# 各名前についてAPI呼び出しを行う
for i in range(3):
    res = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[
                {
                    "role": "user",
                    "content":  f"{name[i]}に関する簡単な説明それぞれ別にして順に教えて。一つ目の説明を始める時には初めに1.をつけ、２つ目の説明を始める時には2.をつけ、それ以降も同様にして"
                                
                },
            ],
    
    )
    print(messages)
    
    """res = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=messages,
        temperature=0.8
    )"""
    
    #chunk_descriptions = [choice["message"]["content"] for choice in res["choices"]]
    #descriptions.extend(chunk_descriptions)

print(descriptions)




"""# Iterate over the data and update description
res = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[
                {
                    "role": "user",
                    "content":  f"{name_str}に関する簡単な説明それぞれ別にして順に教えて。二条御所の説明を始める時には初めに1.をつけ、大徳寺の説明を始める時には2.をつけ、それ以降も同様にして"
                                
                },
            ],
    
)

# Extract the generated descriptions from the response
print(res["choices"][0]["message"]["content"])
"""

"""
new_data = []
for item in data:
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

# Print the JSON result
print(json_result)
"""'''