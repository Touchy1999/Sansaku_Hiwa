from rest_framework import generics
from rest_framework import serializers
from .models import Spot
import io
from rest_framework.parsers import JSONParser
#シリアライザーを追加
class CurrentLocationSerializer(serializers.Serializer):
    range = serializers.IntegerField()
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()

class SpotSerializer(serializers.ModelSerializer):
    class Meta:
        model = Spot
        fields = ['name', 'lat', 'lng', 'description', 'relation']

class HintSerializer(serializers.ModelSerializer):
     class Meta:
         model = Spot
         fields = ['name', 'lat', 'lng', 'description']

class ScenarioSerializer(serializers.Serializer):
    goal = SpotSerializer()
    hints = HintSerializer(many=True)
