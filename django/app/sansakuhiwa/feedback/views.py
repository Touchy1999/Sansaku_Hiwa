from rest_framework import viewsets, permissions, status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from explore.models import Spot
from .serializers import SpotSerializer#, PersonSerializer

# scenario  <- spot <- person

class SpotViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows places to be viewed or edited.
    """
    queryset = Spot.objects.all()
    serializer_class = SpotSerializer
    #permission_classes = [permissions.IsAuthenticated]

    def post(self, request, format=None):
        serializer = SpotSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# class PersonViewSet(viewsets.ModelViewSet):
#     """
#     API endpoint that allows people to be viewed or edited.
#     """
#     queryset = Person.objects.all()
#     serializer_class = PersonSerializer
#     permission_classes = [permissions.IsAuthenticated]

#     def post(self, request, format=None):
#         serializer = PersonSerializer(data=request.data)
#         if serializer.is_valid():
#             serializer.save()
#             return Response(serializer.data, status=status.HTTP_201_CREATED)
#         return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
