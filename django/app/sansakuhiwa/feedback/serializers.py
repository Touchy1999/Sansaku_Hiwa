from rest_framework import serializers
from explore.models import Spot


class SpotSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Spot
        fields = ['url', 'name', 'lat', 'lng', 'description', 'relation']

# class HintSerializer(serializers.HyperlinkedModelSerializer):
#     class Meta:
#         model = Spot
#         fields = ['url', 'name', 'lat', 'lng', 'description']


# class PersonSerializer(serializers.HyperlinkedModelSerializer):
#     class Meta:
#         model = Person
#         fields = ['url', 'name', 'description']

# class ScenarioSerializer(serializers.HyperlinkedModelSerializer):
#     goal = SpotSerializer()
#     hint = HintSerializer(many=True)
