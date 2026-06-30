import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // Asegúrate de que esta ruta apunte correctamente a tu main.dart

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false; // Alterna entre Iniciar Sesión y Crear Cuenta
  bool _obscurePassword = true;

  // Instancia de Supabase
  final supabase = Supabase.instance.client;
  
  // Variable para escuchar el estado de la sesión
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    
    // Configuramos el escuchador para detectar cuando el usuario regresa de Google
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      // Si el evento es un inicio de sesión exitoso y la sesión existe, lo dejamos pasar
      if (event == AuthChangeEvent.signedIn && session != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    // Es vital cancelar la suscripción al salir para evitar fugas de memoria
    _authSubscription.cancel(); 
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Lógica: Iniciar sesión con Correo
  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // La navegación la manejará automáticamente el listener de arriba
    } on AuthException catch (e) {
      _showError(e.message);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      _showError('Ocurrió un error inesperado');
      if (mounted) setState(() => _isLoading = false);
    } 
  }

  // Lógica: Registrarse con Correo
  Future<void> _signUp() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso. Revisa tu correo para confirmar tu cuenta.'),
            backgroundColor: Color(0xFF6B52A3),
          ),
        );
        setState(() => _isSignUp = false); // Regresa a la vista de login
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Ocurrió un error inesperado');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Lógica: Iniciar sesión con Google
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // Usamos el mismo scheme que configuramos en AndroidManifest.xml
        redirectTo: 'chatbothelper://login-callback', 
      );
    } on AuthException catch (e) {
      _showError(e.message);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      _showError('Ocurrió un error al conectar con Google');
      if (mounted) setState(() => _isLoading = false);
    } 
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF991B1B), // Rojo suave para errores
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450), // Tarjeta centrada y contenida
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado
                      Icon(Icons.shield_rounded, size: 48, color: const Color(0xFF6B52A3).withValues(alpha: 0.8)),
                      const SizedBox(height: 24),
                      Text(
                        _isSignUp ? "Crear una cuenta" : "Iniciar Sesión",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Accede a tu asistente de manera segura.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 32),

                      // Campos de Texto
                      _buildTextField(
                        controller: _emailController,
                        label: "Correo electrónico",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Contraseña",
                        icon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      const SizedBox(height: 24),

                      // Botón Principal
                      FilledButton(
                        onPressed: _isLoading ? null : (_isSignUp ? _signUp : _signIn),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6B52A3),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _isSignUp ? "Registrarse" : "Ingresar",
                                style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Divisor
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text("O continuar con", style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 13)),
                          ),
                          const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Botón de Google
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28, color: Color(0xFF111827)), 
                        label: Text(
                          "Google",
                          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Alternar entre Login y Registro
                      TextButton(
                        onPressed: () => setState(() {
                          _isSignUp = !_isSignUp;
                          _emailController.clear();
                          _passwordController.clear();
                        }),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B52A3)),
                        child: Text(
                          _isSignUp ? "¿Ya tienes cuenta? Inicia sesión" : "¿No tienes cuenta? Regístrate",
                          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para los campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTogglePassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Color(0xFF111827)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
        suffixIcon: onTogglePassword != null
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF), size: 20),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6B52A3), width: 1.5),
        ),
      ),
    );
  }
}