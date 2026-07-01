import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileView extends StatefulWidget {
  final bool isWeb;

  const ProfileView({super.key, required this.isWeb});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final StreamSubscription<AuthState> _authSubscription;
  User? _currentUser;
  
  // Controladores para el formulario de login/registro
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true; // Para alternar entre Iniciar Sesión y Registrarse

  @override
  void initState() {
    super.initState();
    // Escuchar los cambios de estado de la sesión (Login / Logout)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _currentUser = data.session?.user;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  // --- MÉTODOS DE AUTENTICACIÓN ---

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Por favor, llena todos los campos.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        _showMessage("Registro exitoso. Por favor revisa tu correo para confirmar (si está configurado) o inicia sesión.");
        setState(() => _isLogin = true); // Cambiar a la vista de login tras registro
      }
    } on AuthException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (e) {
      _showMessage("Ocurrió un error inesperado.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      _showMessage("Error al cerrar sesión.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF6B52A3),
      ),
    );
  }

  // --- CONSTRUCCIÓN DE LA INTERFAZ ---

  @override
  Widget build(BuildContext context) {
    // Si el usuario está logueado mostramos el perfil, si no, el formulario de auth
    final Widget content = _currentUser == null 
        ? _buildAuthForm() 
        : _buildProfileContent();

    if (widget.isWeb) {
      return SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: content,
          ),
        ),
      );
    }

    return SingleChildScrollView(child: content);
  }

  // Vista cuando el usuario NO ha iniciado sesión
  Widget _buildAuthForm() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isWeb ? 200.0 : 24.0, 
        vertical: 40.0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isLogin ? "Iniciar Sesión" : "Crear Cuenta",
            style: GoogleFonts.dmSans(
              fontSize: widget.isWeb ? 32 : 28, 
              fontWeight: FontWeight.bold, 
              color: const Color(0xFF221144)
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isLogin ? "Accede a tu cuenta para continuar" : "Regístrate para guardar tu progreso",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Correo electrónico",
              prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6B52A3)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF6B52A3), width: 2),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: "Contraseña",
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF6B52A3)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF6B52A3), width: 2),
              ),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 32),
          
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _isLoading ? null : _handleAuth,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6B52A3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isLogin ? "Entrar" : "Registrarse", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
          
          TextButton(
            onPressed: () {
              setState(() {
                _isLogin = !_isLogin;
                _emailController.clear();
                _passwordController.clear();
              });
            },
            child: Text(
              _isLogin ? "¿No tienes cuenta? Regístrate aquí" : "¿Ya tienes cuenta? Inicia sesión",
              style: const TextStyle(color: Color(0xFF6B52A3), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Vista cuando el usuario SÍ ha iniciado sesión
  Widget _buildProfileContent() {
    // Obtenemos la primera letra del correo para el avatar
    final userEmail = _currentUser?.email ?? "usuario@correo.com";
    final initial = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "U";

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isWeb ? 40.0 : 20.0, 
        vertical: 24.0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mi Cuenta",
            style: GoogleFonts.dmSans(
              fontSize: widget.isWeb ? 32 : 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6B52A3).withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEAB8FF).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: widget.isWeb ? 40 : 32,
                  backgroundColor: const Color(0xFF6B52A3),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: widget.isWeb ? 32 : 24, 
                      color: Colors.white, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail,
                        style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Sesión activa y segura",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          _buildProfileOption(title: "Configuración de privacidad", icon: Icons.privacy_tip_outlined),
          _buildProfileOption(title: "Historial de consultas", icon: Icons.history_rounded),
          _buildProfileOption(title: "Centro de ayuda", icon: Icons.help_outline_rounded),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: widget.isWeb ? 200 : double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _signOut,
              icon: _isLoading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          SizedBox(height: widget.isWeb ? 40 : 100),
        ],
      ),
    );
  }

  Widget _buildProfileOption({required String title, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
      ),
      child: ListTile(
        onTap: () {
          // Aquí puedes añadir la navegación a las sub-pantallas
        },
        leading: Icon(icon, color: const Color(0xFF6B52A3)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      ),
    );
  }
}