import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  /// Inicializa o plugin, configura timezone e pede permissão (Android 13+)
  static Future<void> initialize() async {
    if (_ready) return;

    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _plugin.initialize(initSettings);

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        final bool? result = await androidImplementation
            .requestNotificationsPermission();
        print('🔔 Permissão de Notificações (visuais) habilitada: $result');

        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'task_channel',
          'Compromissos',
          description: 'Lembretes e compromissos do app MordoMo',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );
        await androidImplementation.createNotificationChannel(channel);
      } else {
        print(
          '⚠️ Implementação Android do plugin não encontrada durante a inicialização.',
        );
      }

      _ready = true;
      print('✅ NotificationService inicializado com sucesso');
    } catch (e, st) {
      print('⚠️ Erro ao inicializar NotificationService: $e');
      print(st);
    }
  }

  /// Verifica se a permissão para agendar alarmes exatos está concedida.
  static Future<bool> canScheduleExactAlarms() async {
    final status = await Permission.scheduleExactAlarm.status;
    print('ℹ️ Status da permissão SCHEDULE_EXACT_ALARM: $status');
    return status == PermissionStatus.granted;
  }

  /// Tenta abrir as configurações de permissão de alarmes exatos.
  static Future<void> openExactAlarmSettings() async {
    await openAppSettings();
    print(
      'ℹ️ Abrindo configurações do app para que o usuário possa conceder a permissão.',
    );
  }

  /// Agenda uma notificação para uma data/hora específicas
  static Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      if (!_ready) await initialize();

      if (scheduledDate.isBefore(DateTime.now())) {
        print('⚠️ Data no passado ($scheduledDate), não será agendada.');
        return false;
      }

      // =========================================================================
      // CÓDIGO CORRIGIDO AQUI
      // =========================================================================
      final bool exactAlarmsPermitted = await canScheduleExactAlarms();
      if (!exactAlarmsPermitted) {
        print('! Falha: Permissão para agendar alarmes exatos não concedida.');
        print('! Solicitando ao usuário para conceder a permissão...');
        await openAppSettings(); // Abre as configurações do app para o usuário
        return false; // Retorna falso porque a permissão ainda não foi concedida
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'task_channel',
            'Compromissos',
            channelDescription: 'Lembretes e compromissos do app MordoMo',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
            showWhen: true,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await _plugin.zonedSchedule(
        id,
        title,
        body.isNotEmpty ? body : 'Você tem um compromisso agora!',
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
      // =========================================================================

      print('✅ Notificação agendada para: $scheduledTZDate');
      return true;
    } catch (e, st) {
      print('⚠️ Falha ao agendar notificação: $e');
      print(st);
      return false;
    }
  }

  /// Cancela uma notificação específica pelo id
  static Future<void> cancelNotification(int id) async {
    if (!_ready) await initialize();

    try {
      await _plugin.cancel(id);
      print('✅ Notificação $id cancelada');
    } catch (e, st) {
      print('⚠️ Erro ao cancelar notificação $id: $e');
      print(st);
    }
  }

  /// Cancela todas as notificações agendadas
  static Future<void> cancelAllNotifications() async {
    if (!_ready) await initialize();

    try {
      await _plugin.cancelAll();
      print('✅ Todas as notificações canceladas');
    } catch (e, st) {
      print('⚠️ Erro ao cancelar todas as notificações: $e');
      print(st);
    }
  }

  /// Recupera notificações pendentes para debug
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    if (!_ready) await initialize();

    try {
      final pending = await _plugin.pendingNotificationRequests();
      print('📋 Notificações pendentes: ${pending.length}');
      for (var notif in pending) {
        print(' - ID: ${notif.id} | Title: ${notif.title}');
      }
      return pending;
    } catch (e, st) {
      print('⚠️ Erro ao listar pendentes: $e');
      print(st);
      return [];
    }
  }

  /// Verifica se notificações visuais estão habilitadas no dispositivo
  static Future<bool> areNotificationsEnabled() async {
    if (!_ready) await initialize();

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final bool? enabled = await androidImplementation
          ?.areNotificationsEnabled();
      print('🔔 Notificações (visuais) habilitadas: ${enabled ?? true}');
      return enabled ?? true;
    } catch (e, st) {
      print('⚠️ Erro ao checar habilitação de notificações visuais: $e');
      print(st);
      return false;
    }
  }
}
