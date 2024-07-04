

from django.contrib import admin
from django.urls import path,include
from .views import *
urlpatterns = [
    path('chat-history', ChatHistoryView.as_view()),
    path('chat/<int:pk>', ChatView.as_view()),
    path('create-chat', CreateChatView.as_view()),
]