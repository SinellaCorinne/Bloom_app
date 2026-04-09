from django.contrib import admin
from django.urls import path
from api import views  # ✅ On importe tes vues depuis le dossier api

urlpatterns = [
    path('admin/', admin.site.urls),

    # ─── IMITATION STRAPI (Authentification) ──────────────────────────
    
    # Pour l'inscription (POST /auth/local/register)
    path('auth/local/register', views.register_strapi),

    # Pour la connexion (POST /auth/local)
    path('auth/local', views.login_strapi),
    path('task', views.task_list_create),          # GET et POST
    path('task/<int:pk>', views.task_detail),
]