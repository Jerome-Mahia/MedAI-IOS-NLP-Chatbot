from rest_framework import serializers

from .models import *

class chatSerializer(serializers.ModelSerializer):
    class Meta:
        model = Chat
        fields = '__all__'
    
class chatTextSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatText
        fields = '__all__'