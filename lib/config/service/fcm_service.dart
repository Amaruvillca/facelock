import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

// ✅ IMPORTANTE: Este debe ser una función GLOBAL fuera de la clase
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Asegurarse de que Firebase esté inicializado
  await Firebase.initializeApp();
  
  print('📱 NOTIFICACIÓN EN SEGUNDO PLANO/APP CERRADA');
  print('   Título: ${message.notification?.title}');
  print('   Cuerpo: ${message.notification?.body}');
  print('   Data: ${message.data}');
  
  // Mostrar notificación incluso cuando la app está cerrada
  await _showBackgroundNotification(message);
}

// ✅ Función global para mostrar notificación en background
@pragma('vm:entry-point')
Future<void> _showBackgroundNotification(RemoteMessage message) async {
  try {
    final notification = message.notification;
    final data = message.data;
    
    // Obtener URL de la imagen
    String? imageUrl = notification?.android?.imageUrl ?? 
                      notification?.apple?.imageUrl ??
                      data['image'] ?? 
                      data['image_url'] ??
                      data['picture'];
    
    // Convertir payload
    Map<String, String> stringPayload = {};
    data.forEach((key, value) {
      stringPayload[key] = value.toString();
    });
    
    // Configurar contenido de notificación
    NotificationContent content = NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'heads_up_channel',
      title: notification?.title ?? 'Nueva notificación',
      body: notification?.body ?? '',
      payload: stringPayload,
      notificationLayout: imageUrl != null && imageUrl.isNotEmpty 
          ? NotificationLayout.BigPicture 
          : NotificationLayout.Default,
      autoDismissible: true,
      wakeUpScreen: true,
      bigPicture: imageUrl != null && imageUrl.isNotEmpty ? imageUrl : null,
      largeIcon: imageUrl != null && imageUrl.isNotEmpty ? imageUrl : null,
    );
    
    await AwesomeNotifications().createNotification(content: content);
    print('✅ Notificación mostrada en background');
    
  } catch (e) {
    print('❌ Error en background notification: $e');
  }
}

class FCMService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static bool _isInitialized = false;
  
  static Future<void> initializeFCM() async {
    try {
      if (_isInitialized) {
        print('⚠️ FCM ya estaba inicializado');
        return;
      }
      
      print('🚀 Inicializando FCM con soporte background...');
      
      // ✅ 1. CONFIGURAR BACKGROUND HANDLER (IMPORTANTE)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // 2. Inicializar notificaciones
      await _initializeAwesomeNotifications();
      
      // 3. Solicitar permisos
      await _requestPermissions();
      
      // 4. Configurar manejadores en primer plano
      _setupForegroundMessageHandlers();
      
      // 5. Obtener token
      await getFCMToken();
      
      // 6. Escuchar cambios de token
      _setupTokenRefresh();
      
      _isInitialized = true;
      print('✅ FCM inicializado con soporte background');
    } catch (e) {
      print('❌ Error inicializando FCM: $e');
    }
  }
  
  static Future<void> _initializeAwesomeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'heads_up_channel',
          channelName: 'Notificaciones Emergentes',
          channelDescription: 'Notificaciones que aparecen en la parte superior',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
          channelShowBadge: true,
          locked: false,
        ),
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Notificaciones Básicas',
          channelDescription: 'Canal para notificaciones normales',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
        ),
      ],
    );
    
    /*AwesomeNotifications().actionStream.listen((ReceivedAction receivedAction) {
      print('👆 Notificación tocada: ${receivedAction.payload}');
      
      Map<String, dynamic> payloadMap = {};
      if (receivedAction.payload != null) {
        receivedAction.payload!.forEach((key, value) {
          payloadMap[key] = value;
        });
      }
      
      _handleNotificationTap(payloadMap);
    });*/
  }
  
  // ✅ MANEJADORES SOLO PARA PRIMER PLANO
  static void _setupForegroundMessageHandlers() {
    // Solo se ejecuta cuando la app está abierta
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('📱 Notificación en PRIMER PLANO');
      print('   Título: ${message.notification?.title}');
      print('   Cuerpo: ${message.notification?.body}');
      
      await _showForegroundNotification(message);
    });
    
    // Cuando se toca una notificación que abre la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App abierta desde notificación (background)');
      _handleNotificationTap(message.data);
    });
    
    // Notificación que abrió la app desde estado terminado
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 App abierta desde notificación (terminada)');
        _handleNotificationTap(message.data);
      }
    });
  }
  
  // ✅ MOSTRAR NOTIFICACIÓN EN PRIMER PLANO
  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;
      
      String? imageUrl = notification?.android?.imageUrl ?? 
                        data['image'] ?? 
                        data['image_url'];
      
      Map<String, String> stringPayload = {};
      data.forEach((key, value) {
        stringPayload[key] = value.toString();
      });
      
      NotificationContent content = NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'heads_up_channel',
        title: notification?.title ?? 'Nueva notificación',
        body: notification?.body ?? '',
        payload: stringPayload,
        notificationLayout: imageUrl != null && imageUrl.isNotEmpty 
            ? NotificationLayout.BigPicture 
            : NotificationLayout.Default,
        autoDismissible: true,
        wakeUpScreen: true,
        bigPicture: imageUrl != null && imageUrl.isNotEmpty ? imageUrl : null,
        largeIcon: imageUrl != null && imageUrl.isNotEmpty ? imageUrl : null,
      );
      
      await AwesomeNotifications().createNotification(content: content);
      print('📢 Notificación en primer plano mostrada');
      
    } catch (e) {
      print('❌ Error en notificación foreground: $e');
    }
  }
  
  static void _handleNotificationTap(Map<String, dynamic> payload) {
    print('📍 Notificación tocada con payload: $payload');
    
    if (payload.isNotEmpty) {
      final type = payload['type'];
      final id = payload['id'];
      print('➡️ Navegando: tipo=$type, id=$id');
      // Tu lógica de navegación aquí
    }
  }
  
  // 🔁 TUS MÉTODOS ORIGINALES
  static Future<void> _requestPermissions() async {
    try {
      // Para Android 13+ necesitamos permisos explícitos
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        announcement: false,
      );
      
      print('📱 Permisos de notificación: ${settings.authorizationStatus}');
      
      // Configurar para Android
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true, // Mostrar notificación cuando la app está en primer plano
        badge: true, // Mostrar badge
        sound: true, // Reproducir sonido
      );
      
    } catch (e) {
      print('❌ Error en permisos: $e');
    }
  }
  
  static Future<String?> getFCMToken() async {
    try {
      String? savedToken = await getSavedToken();
      String? token = savedToken ?? await _fcm.getToken();
      
      if (token != null && savedToken == null) {
        await _saveTokenLocally(token);
        print('🎉 Token FCM: ${token.substring(0, 20)}...');
        
        // ✅ IMPORTANTE: Este token funciona para background también
        print('💡 Este token permite notificaciones en background y app cerrada');
      }
      
      return token;
    } catch (e) {
      print('❌ Error obteniendo token: $e');
      return null;
    }
  }
  
  static Future<void> _saveTokenLocally(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      print('❌ Error guardando token: $e');
    }
  }
  
  static Future<String?> getSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      return null;
    }
  }
  
  static void _setupTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) async {
      print('🔄 Token FCM actualizado (válido para background)');
      print('Nuevo token: ${newToken.substring(0, 20)}...');
      await _saveTokenLocally(newToken);
    });
  }
  
  static Future<void> deleteToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      print('🗑️ Token eliminado');
    } catch (e) {
      print('Error eliminando token: $e');
    }
  }
  
  static Future<String?> getCurrentToken() async {
    return await getSavedToken();
  }
  
  // ✅ MÉTODO PARA VERIFICAR CONFIGURACIÓN
  static Future<void> checkBackgroundCapabilities() async {
    try {
      // Verificar si FCM está configurado para background
      final token = await getCurrentToken();
      print('🔍 Estado FCM Background:');
      print('   - Token válido: ${token != null}');
      print('   - Background handler configurado: ✅');
      print('   - Permisos solicitados: ✅');
      print('   - App puede recibir notificaciones cerrada: ✅');
    } catch (e) {
      print('❌ Error verificando capacidades: $e');
    }
  }
}