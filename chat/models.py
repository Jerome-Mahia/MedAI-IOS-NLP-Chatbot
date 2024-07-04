from django.db import models

# Create your models here.
class Chat(models.Model):
    date_created = models.DateTimeField(auto_now_add=True)

class ChatText(models.Model):
    chat = models.ForeignKey(Chat, on_delete=models.CASCADE)
    text = models.TextField()
    answer = models.TextField()
    date_created = models.DateTimeField(auto_now_add=True)