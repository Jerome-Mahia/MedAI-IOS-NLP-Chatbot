
from rest_framework.views import APIView
from rest_framework import permissions, status
from rest_framework.response import Response 
from .serializers import *
from .models import *
from medchatbot_api.app import predict_class, get_response,model,intents

class ChatHistoryView(APIView):
    permission_classes = (permissions.AllowAny,)

    def get(self,request, format=None):
        chat = Chat.objects.all()
        serializer = chatSerializer(chat, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class CreateChatView(APIView):
    permission_classes = (permissions.AllowAny,)

    def post(self,request, format=None):
        new_chat = Chat()
        new_chat.save()
        serializer = chatSerializer(new_chat)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class ChatView(APIView):
    permission_classes = (permissions.AllowAny,)

    def get(self,request, pk, format=None):
        chat = Chat.objects.get(pk=pk)
        chat_text = ChatText.objects.filter(chat=chat)
        serializer = chatTextSerializer(chat_text, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self,request, pk, format=None):
        chat = Chat.objects.get(pk=pk)
        text = request.data['text']
        intents_list = predict_class(text, model)
        answer = get_response(intents_list, intents)
        chat_text = ChatText()
        chat_text.chat = chat
        chat_text.text = request.data['text']
        chat_text.answer = answer
        chat_text.save()
        return Response({'answer':answer}, status=status.HTTP_201_CREATED)