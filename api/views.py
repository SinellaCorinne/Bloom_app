from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth.models import User
from django.contrib.auth import authenticate
# ─── IMPORTATION MANQUANTE ICI ───
from .models import Task 

# 1. INSCRIPTION (Imite POST /auth/local/register)
@api_view(['POST'])
@permission_classes([AllowAny])
def register_strapi(request):
    data = request.data
    try:
        if User.objects.filter(username=data.get('username')).exists():
            return Response({"error": "Cet utilisateur existe déjà"}, status=status.HTTP_400_BAD_REQUEST)

        user = User.objects.create_user(
            username=data.get('username'),
            email=data.get('email'),
            password=data.get('password')
        )

        return Response({
            "jwt": "fake-jwt-token-bloom",
            "user": {
                "id": user.id,
                "username": user.username,
                "email": user.email,
                "confirmed": True,
                "blocked": False,
            }
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


# 2. CONNEXION (Imite POST /auth/local)
@api_view(['POST'])
@permission_classes([AllowAny])
def login_strapi(request):
    identifier = request.data.get('identifier')
    password = request.data.get('password')

    user = authenticate(username=identifier, password=password)

    if user is not None:
        return Response({
            "jwt": "fake-jwt-token-bloom",
            "user": {
                "id": user.id,
                "username": user.username,
                "email": user.email,
            }
        }, status=status.HTTP_200_OK)
    else:
        return Response({
            "error": "Identifiants invalides"
        }, status=status.HTTP_400_BAD_REQUEST)


# 3. LISTE ET CRÉATION DE TÂCHES (Correction indentation)
@api_view(['GET', 'POST'])
def task_list_create(request):
    if request.method == 'GET':
        tasks = Task.objects.all()
        data = []
        for t in tasks:
            data.append({
                "id": t.id,
                "title": t.title,
                "content": t.content,
                "priority": t.priority,
                "color": t.color,
                "dueDate": t.dueDate.isoformat() if t.dueDate else None,
            })
        return Response(data)

    elif request.method == 'POST':
        t = Task.objects.create(
            title=request.data.get('title'),
            content=request.data.get('content'),
            priority=request.data.get('priority', 'medium'),
            color=request.data.get('color'),
        )
        return Response({
            "id": t.id, 
            "title": t.title,
            "content": t.content
        }, status=status.HTTP_201_CREATED)


# 4. MODIFICATION ET SUPPRESSION
@api_view(['PATCH', 'DELETE'])
def task_detail(request, pk):
    try:
        task = Task.objects.get(pk=pk)
    except Task.DoesNotExist:
        return Response({"error": "Task not found"}, status=status.HTTP_404_NOT_FOUND)

    if request.method == 'PATCH':
        task.title = request.data.get('title', task.title)
        task.content = request.data.get('content', task.content)
        task.priority = request.data.get('priority', task.priority)
        task.save()
        return Response({"message": "Updated successfully"})

    elif request.method == 'DELETE':
        task.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)