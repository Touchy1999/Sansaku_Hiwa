from django.shortcuts import render
from .models import Spot
from math import cos, sin, sqrt, radians, asin
from .serializers import CurrentLocationSerializer
from .serializers import ScenarioSerializer
from .serializers import SpotSerializer
from .serializers import HintSerializer
from rest_framework import status
from rest_framework.response import Response
#from rest_framework import viewsets
from rest_framework.views import APIView

#距離を計算する関数
def calculateDistance(center_lat, center_lng, lat, lng):
    p = 0.017453292519943295  # 1度あたりのラジアン値
    a = 0.5 - cos((lat - center_lat) * p) / 2 + cos(center_lat * p) * cos(lat * p) * (1 - cos((lng - center_lng) * p)) / 2
    distance = 2 * 6371 * asin(sqrt(a))  # 地球の直径 * asinの結果
    return distance
#遊ぶ時に使用する関数
class StoryViewSet(APIView):

    def post(self, request):
        #送られてきたJSONをpythonネイティブ型へパース
        serializer = CurrentLocationSerializer(data=request.data)
        if serializer.is_valid():
            set_distance = serializer.data['range']
            lat = serializer.data['latitude']
            lng = serializer.data['longitude']

            #story_goal = Spot.objects.order_by('?')[0]
            story_goals = Spot.objects.order_by('?')
            for g in story_goals:
                distance = calculateDistance(lat, lng, g.lat, g.lng)
                if distance < set_distance:
                    story_goal = g
                    break
                else:
                    pass

            sample_relation = story_goal.relation
            story_hints = []
            hints = Spot.objects.filter(relation=sample_relation)
            for i in hints:
                if i == story_goal:
                    continue
                else:
                    distance = calculateDistance(lat, lng, i.lat, i.lng)
                    if distance < set_distance:
                        story_hints.append(i)
            story_goal = SpotSerializer(story_goal)
            story_hints = HintSerializer(story_hints, many=True)
            s = ScenarioSerializer(data={'goal':story_goal.data, 'hints':story_hints.data})
            if s.is_valid():
                return Response(s.data, status=status.HTTP_200_OK, headers={'Content-Type': 'application/json; charset=UTF-8'})
            else:
                print("***invalid***")
                return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)   
        else:
            #print("data : " + str(request.data))
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
