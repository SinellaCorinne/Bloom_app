from django.db import models
from django.contrib.auth.models import User

class Task(models.Model):
    title = models.CharField(max_length=255)
    content = models.TextField(blank=True, null=True)
    priority = models.CharField(max_length=50, default='medium')
    color = models.CharField(max_length=50, blank=True, null=True)
    dueDate = models.DateTimeField(null=True, blank=True)
    completed = models.BooleanField(default=False)
    # On lie chaque tâche à un utilisateur
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='tasks', null=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.title