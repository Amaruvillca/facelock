import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:facelock/config/constants/enviroment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class VerificacionBiometricaScreen extends StatefulWidget {
  const VerificacionBiometricaScreen({super.key});

  @override
  State<VerificacionBiometricaScreen> createState() =>
      _VerificacionBiometricaScreenState();
}

class _VerificacionBiometricaScreenState
    extends State<VerificacionBiometricaScreen> {
  String? _userUid;
  late CameraController _controller;
  late Future<void> _initializeController;
  bool _isProcessing = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  bool _showHelpMessage = true;
  Timer? _helpMessageTimer;

  @override
  void initState() {
    super.initState();
    // Ocultar barra de estado y navegación
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _getCurrentUserUid().then((_) => _initializeCamera());

    // Ocultar mensaje de ayuda después de 5 segundos
    _helpMessageTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showHelpMessage = false);
      }
    });
  }

  @override
  void dispose() {
    // Restaurar la barra de estado y navegación
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    _helpMessageTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentUserUid() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() => _userUid = user.uid);
      } else {
        setState(() =>
            _errorMessage = '🔐 Debes iniciar sesión para verificar tu biometría');
      }
    } catch (e) {
      setState(() =>
          _errorMessage = '⚠️ Error al verificar tu cuenta: ${e.toString()}');
    }
  }

  Future<void> _initializeCamera() async {
    if (_userUid == null) return;

    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _initializeController = _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() => _isCameraReady = true);
      });

      await _initializeController;
      await _controller.setFlashMode(FlashMode.off);
      await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorMessage = '📷 Error al iniciar la cámara: ${e.toString()}');
      }
    }
  }

  Future<void> _verifyBiometricData() async {
    if (_isProcessing || !_isCameraReady || _userUid == null) return;

    setState(() {
      _isProcessing = true;
      _result = null;
      _errorMessage = null;
      _showHelpMessage = false;
    });

    try {
      final XFile image = await _controller.takePicture();
      final bytes = await image.readAsBytes();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Environment.urlBase}/clientes/comparar-imagen/$_userUid'),
      )
        ..files.add(http.MultipartFile.fromBytes(
          'imagen',
          bytes,
          filename: 'biometria_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ))..headers.addAll(
        {
          "X-API-Name": Environment.xApiName,
          "X-API-Version": Environment.xApiVersion,
          "X-Developed-By": Environment.xDevelopedBy,
          "X-Code": Environment.xCode
        }
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => _result = jsonResponse);
      } else {
        setState(() =>
            _errorMessage = jsonResponse['detail'] ?? '❌ Error en la verificación biométrica');
      }
    } catch (e) {
      if (mounted) {
        setState(() =>
            _errorMessage = '⚠️ Error al conectar con el servidor: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Vista de la cámara a pantalla completa
          _buildFullScreenCamera(),

          // AppBar transparente
          //_buildTransparentAppBar(),

          // Guías de captura
          _buildCaptureGuidelines(),

          // Mensaje de ayuda flotante
          if (_showHelpMessage && _userUid != null && _isCameraReady)
            _buildFloatingHelpMessage(),

          // Indicador de procesamiento
          if (_isProcessing) _buildProcessingIndicator(),

          // Resultados o errores
          if (_result != null) _buildResultOverlay(),
          if (_errorMessage != null) _buildErrorOverlay(),
          if (_userUid == null) _buildAuthErrorOverlay(),

          // Botón de captura
          if (_userUid != null &&
              !_isProcessing &&
              _result == null &&
              _errorMessage == null)
            _buildCaptureButton(),
        ],
      ),
    );
  }

  Widget _buildFullScreenCamera() {
    if (_errorMessage != null) {
      return Container(color: Colors.black);
    }

    if (!_isCameraReady || _userUid == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Preparando cámara...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8, // 70% de la altura = relación ~9:16
        margin: const EdgeInsets.only(top: 0), // Espacio para el AppBar
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: CameraPreview(_controller),
        ),
      ),
    );
  }

  Widget _buildTransparentAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Verificación Biométrica Facial',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
    );
  }

 Widget _buildCaptureGuidelines() {
  final width = MediaQuery.of(context).size.width * 0.7;
  final height = MediaQuery.of(context).size.width * 1;

  return Positioned.fill(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          opacity: _isProcessing ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: const Text(
            'Alinee su rostro dentro de la guía',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),

        // Guía con forma de rostro
        Stack(
          alignment: Alignment.center,
          children: [
            // Contorno ovalado principal
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: width,
              height: height,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing
                      ? Colors.grey
                      : Colors.white.withOpacity(0.8),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(height),
              ),
            ),

            // Líneas guía horizontales (ojos, nariz, boca)
            Positioned(
              top: height * 0.35,
              child: Container(
                width: width * 0.6,
                height: 1,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Positioned(
              top: height * 0.55,
              child: Container(
                width: width * 0.5,
                height: 1,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Positioned(
              top: height * 0.75,
              child: Container(
                width: width * 0.4,
                height: 1,
                color: Colors.white.withOpacity(0.5),
              ),
            ),

            // Línea vertical central
            Positioned(
              child: Container(
                width: 1,
                height: height * 0.9,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildFloatingHelpMessage() {
    return Positioned(
      bottom: 120,
      left: 20,
      right: 20,
      child: AnimatedOpacity(
        opacity: _showHelpMessage ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.yellow, size: 24),
              Text(
                'Consejo: Asegúrate de tener buena iluminación y quitar accesorios como lentes o gorras',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Verificando tu identidad...',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Por favor espera',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultOverlay() {
    final bool isSuccess = _result?['match'] == true;
    final String message = _result?['mensaje'] ?? '';

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Icon(
                    isSuccess ? Icons.verified_user : Icons.error_outline,
                    key: ValueKey<bool>(isSuccess),
                    color: isSuccess ? Colors.green : Colors.orange,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  isSuccess ? '✅ Verificación exitosa' : '⚠️ Verificación fallida',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, isSuccess),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('TERMINAR'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    if (!isSuccess)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => setState(() {
                            _result = null;
                            _showHelpMessage = true;
                            _helpMessageTimer = Timer(const Duration(seconds: 5),
                                () {
                              if (mounted) {
                                setState(() => _showHelpMessage = false);
                              }
                            });
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('REINTENTAR'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Ocurrió un error',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _errorMessage = null;
                    _showHelpMessage = true;
                    _helpMessageTimer = Timer(const Duration(seconds: 5), () {
                      if (mounted) {
                        setState(() => _showHelpMessage = false);
                      }
                    });
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'INTENTAR DE NUEVO',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar y volver',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthErrorOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_outlined, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Acceso requerido',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Para verificar tu biometría facial necesitas iniciar sesión primero',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'ENTENDIDO',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          children: [
            Text(
              _isCameraReady ? 'Presiona para verificar' : 'Preparando cámara...',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _verifyBiometricData,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(
                      color: _isCameraReady ? Colors.white : Colors.grey,
                      width: 3),
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCameraReady ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}