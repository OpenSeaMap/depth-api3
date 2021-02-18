from django.shortcuts import render

from rest_framework.response import Response
from rest_framework import viewsets, status

from . import serializers
from . import gauge

            
# note: just a demo with data stored in RAM instead usage of python Django ORM framework
#
# 
# read gauges in xml format
# http://depth.openseamap.org:8080/org.osm.depth.upload/api2/gauge/#/definitions/Gauge 

        
gauges = {
    1: gauge(id=1, name='Spree 555', latitude='12.0', longitude='50.3', gaugeType='Test', waterlevel="1.2"),
    2: gauge(id=2, name='Havel 456', latitude='12.0', longitude='50.3', gaugeType='Test', waterlevel="1.2"),
    3: gauge(id=3, name='Rein. 123', latitude='12.0', longitude='50.3', gaugeType='Test', waterlevel="1.2"),
}

def get_next_gauge_id():
    return max(gauges) + 1


class Gauge_ViewSet(viewsets.ViewSet):
    # Required for the Browsable API renderer to have a nice form.
    serializer_class = serializers.GaugeSerializer

    def list(self, request):
        serializer = serializers.GaugeSerializer(
            instance=gauges.values(), many=True)
        return Response(serializer.data)

    def create(self, request):
        serializer = serializers.GaugeSerializer(data=request.data)
        if serializer.is_valid():
            task = serializer.save()
            task.id = get_next_gauge_id()
            gauges[task.id] = task
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def retrieve(self, request, pk=None):
        try:
            task = gauges[int(pk)]
        except KeyError:
            return Response(status=status.HTTP_404_NOT_FOUND)
        except ValueError:
            return Response(status=status.HTTP_400_BAD_REQUEST)

        serializer = serializers.GaugeSerializer(instance=task)
        return Response(serializer.data)

    def update(self, request, pk=None):
        try:
            task = gauges[int(pk)]
        except KeyError:
            return Response(status=status.HTTP_404_NOT_FOUND)
        except ValueError:
            return Response(status=status.HTTP_400_BAD_REQUEST)

        serializer = serializers.GaugeSerializer(
            data=request.data, instance=task)
        if serializer.is_valid():
            task = serializer.save()
            gauges[task.id] = task
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def partial_update(self, request, pk=None):
        try:
            task = gauges[int(pk)]
        except KeyError:
            return Response(status=status.HTTP_404_NOT_FOUND)
        except ValueError:
            return Response(status=status.HTTP_400_BAD_REQUEST)

        serializer = serializers.GaugeSerializer(
            data=request.data,
            instance=task,
            partial=True)
        if serializer.is_valid():
            task = serializer.save()
            gauges[task.id] = task
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, pk=None):
        try:
            task = gauges[int(pk)]
        except KeyError:
            return Response(status=status.HTTP_404_NOT_FOUND)
        except ValueError:
            return Response(status=status.HTTP_400_BAD_REQUEST)

        del gauges[task.id]
        return Response(status=status.HTTP_204_NO_CONTENT)

