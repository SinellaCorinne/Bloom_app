import 'dart:async';
import 'package:flutter/material.dart';
import '../helpers/db_helpert.dart';
import '../models/tasks.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Task> _tasks = [];
  bool isLoading = false;
  String? errorMessage;

  List<Task> get tasks => List.unmodifiable(_tasks);

  // --- 💾 LOGIQUE DE CACHE SQLITE (LIVRABLE 3) ---

  /// Sauvegarde une tâche dans la base SQLite locale.
  /// [isSynced] : 1 si synchronisé avec Render, 0 sinon.
  Future<void> _saveToLocalDB(Task task, {int isSynced = 1}) async {
    try {
      await DBHelper.insert('tasks', {
        'id': task.id.toString(),
        'title': task.title,
        'description': task.description ?? '', // Utilisation de description selon ton modèle
        'priority': task.priority,
        'date': task.date.toIso8601String(),
        'isSynced': isSynced,
      });
    } catch (e) {
      debugPrint("❌ Erreur sauvegarde SQLite: $e");
    }
  }

  /// Charge les tâches depuis SQLite pour un affichage instantané (Offline-First).
  Future<void> _loadFromLocalDB() async {
    try {
      final localData = await DBHelper.getData('tasks');
      _tasks = localData.map((item) => Task(
        id: int.parse(item['id']),
        title: item['title'],
        description: item['description'] ?? '',
        priority: item['priority'],
        date: DateTime.parse(item['date']),
        isDone: false, // L'état réel sera mis à jour par l'API
      )).toList();
    } catch (e) {
      debugPrint("❌ Erreur lecture SQLite: $e");
    }
  }

  // --- 🌐 MÉTHODES API & SYNCHRONISATION ---

  /// Charge les tâches : Priorité au Cache (Performance) puis mise à jour API (Sync).
  Future<void> loadTasks() async {
    isLoading = true;
    notifyListeners();

    await _loadFromLocalDB();
    notifyListeners();

    try {
      // 1. Récupérer les données du serveur
      final apiTasks = await _api.getTasks();

      // 2. Récupérer les tâches locales qui n'ont PAS encore été synchronisées
      final localData = await DBHelper.getData('tasks');
      final unsyncedTasks = localData
          .where((item) => item['isSynced'] == 0)
          .map((item) => Task(
        id: int.parse(item['id']),
        title: item['title'],
        description: item['description'],
        priority: item['priority'],
        date: DateTime.parse(item['date']),
        isDone: false,
      )).toList();

      // 3. Fusionner : On garde les tâches de l'API + nos tâches locales en attente
      _tasks = [...apiTasks, ...unsyncedTasks];

      // 4. Mettre à jour le cache uniquement pour les tâches venant du serveur
      for (var task in apiTasks) {
        await _saveToLocalDB(task, isSynced: 1);
      }

      errorMessage = null;
    } catch (e) {
      errorMessage = 'Mode hors-ligne';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Ajoute une tâche : UI réactive (local) puis envoi serveur.
  Future<void> addTask(Task task) async {
    // 1. On ajoute immédiatement à la liste mémoire pour que l'UI se mette à jour
    _tasks.add(task);
    errorMessage = null; // On réinitialise l'erreur pour ne pas bloquer l'affichage
    notifyListeners(); // La  tâche apparaît instantanément à l'écran !

    try {
      // 2. On tente la sauvegarde SQLite locale tout de suite
      await _saveToLocalDB(task, isSynced: 0);

      // 3. On envoi au serveur Render
      final created = await _api.createTask(task);

      // 4. Si ça réussit, on met à jour l'ID (celui de la DB) et on marque comme synchronisé
      final index = _tasks.indexOf(task);
      if (index != -1) {
        _tasks[index] = created;
        await _saveToLocalDB(created, isSynced: 1);
      }
    } catch (e) {
      // Si ça échoue, on ne supprime pas la tâche de la liste !
      // On change juste le message d'erreur ou on affiche un petit bandeau (SnackBar)
      errorMessage = "Mode hors-ligne : Sauvegardé localement";
      debugPrint("Erreur réseau : La tâche reste en local (isSynced=0)");
    } finally {
      notifyListeners();
    }
  }
  /// Alterne l'état terminé/non terminé d'une tâche (Livrable 6).
  Future<void> toggleTask(int id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      // 1. Changement immédiat en mémoire pour l'utilisateur
      _tasks[index].isDone = !_tasks[index].isDone;
      notifyListeners();

      try {
        // 2. Mise à jour partielle sur Render
        await _api.updateTask(id, {'isDone': _tasks[index].isDone});
        // 3. Update SQLite
        await _saveToLocalDB(_tasks[index], isSynced: 1);
      } catch (e) {
        await _saveToLocalDB(_tasks[index], isSynced: 0);
        errorMessage = "État mis à jour localement (hors-ligne)";
        notifyListeners();
      }
    }
  }

  /// Met à jour une tâche complète et synchronise.
  Future<void> updateTask(int id, Task task) async {
    try {
      final updated = await _api.updateTask(id, task.toJson());
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updated;
        await _saveToLocalDB(updated, isSynced: 1);
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Erreur de modification (mode hors-ligne)';
      notifyListeners();
    }
  }

  /// Supprime une tâche de l'API et de la liste.
  Future<void> deleteTask(int id) async {
    try {
      await _api.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      // Optionnel : ajouter DBHelper.delete(id) pour nettoyer SQLite
      notifyListeners();
    } catch (e) {
      errorMessage = 'Impossible de supprimer sur le serveur';
      notifyListeners();
    }
  }

  /// Génère l'ID suivant pour les créations de tâches.
  int get nextId =>
      _tasks.isEmpty ? 1 : _tasks.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
}