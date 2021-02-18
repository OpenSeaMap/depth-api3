
class gauge():
    def __init__(self, **kwargs):
        for field in ('id', 'name', 'latitude', 'longitude', 'gaugeType', 'waterlevel'):
            setattr(self, field, kwargs.get(field, None))   
    
