import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'red_apoyo_view.dart'; 
import 'login.dart'; // Importamos la vista de login que ya diseñamos

class ProfileView extends StatefulWidget {
  final bool isWeb;

  const ProfileView({super.key, required this.isWeb});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final StreamSubscription<AuthState> _authSubscription;
  User? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Validar inmediatamente si hay sesión activa al abrir la pantalla
    _currentUser = Supabase.instance.client.auth.currentUser;

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
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _emergencySignOut() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signOut();
      _showMessage("Sesión cerrada de forma segura.");
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
    final Widget content = _currentUser == null 
        ? _buildUnauthenticatedState() // Vista si NO hay sesión
        : _buildProfileContent();      // Vista si SÍ hay sesión

    // Envolver en Scaffold proporciona automáticamente un AppBar y botón "Atrás" nativo
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Mi Perfil", 
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: widget.isWeb ? 24 : 20)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: widget.isWeb
          ? SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: content,
                ),
              ),
            )
          : SingleChildScrollView(child: content),
    );
  }

  // --- ESTADO: USUARIO NO AUTENTICADO ---
  Widget _buildUnauthenticatedState() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isWeb ? 200.0 : 32.0, 
        vertical: widget.isWeb ? 80.0 : 60.0
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.lock_person_rounded, 
            size: widget.isWeb ? 100 : 80, 
            color: const Color(0xFF6B52A3).withValues(alpha: 0.5)
          ),
          const SizedBox(height: 24),
          Text(
            "Inicia sesión para ver tu perfil",
            style: GoogleFonts.dmSans(
              fontSize: widget.isWeb ? 32 : 24,
              fontWeight: FontWeight.bold, 
              color: const Color(0xFF221144)
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            "Al acceder podrás configurar tu red de apoyo, ajustar tu seguridad y mantener tu información respaldada.",
            style: TextStyle(fontSize: widget.isWeb ? 16 : 14, color: Colors.black54, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          
          SizedBox(
            height: widget.isWeb ? 54 : 50,
            child: FilledButton.icon(
              onPressed: () {
                // Navegamos hacia la pantalla bonita de Login que diseñamos antes
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text("Ir a iniciar sesión", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6B52A3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // --- ESTADO: USUARIO AUTENTICADO ---
  Widget _buildProfileContent() {
    final userEmail = _currentUser?.email ?? "usuario@correo.com";
    final initial = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "U";

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isWeb ? 40.0 : 20.0, 
        vertical: widget.isWeb ? 16.0 : 8.0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- TARJETA DE USUARIO M3 ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(widget.isWeb ? 20 : 16), 
            decoration: BoxDecoration(
              color: const Color(0xFFF3EDF7), 
              borderRadius: BorderRadius.circular(widget.isWeb ? 28 : 20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: widget.isWeb ? 40 : 28,
                  backgroundColor: const Color(0xFF6B52A3),
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: widget.isWeb ? 32 : 20, 
                      color: Colors.white, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
                const SizedBox(width: 16), 
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail,
                        style: GoogleFonts.dmSans(
                          fontSize: widget.isWeb ? 18 : 16, 
                          fontWeight: FontWeight.bold, 
                          color: const Color(0xFF1D1B20)
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.verified_user_rounded, size: widget.isWeb ? 14 : 12, color: const Color(0xFF4F378B)),
                          const SizedBox(width: 4),
                          Text(
                            "Sesión activa y segura",
                            style: TextStyle(
                              fontSize: widget.isWeb ? 14 : 12, 
                              color: const Color(0xFF4F378B).withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text(
            "Ajustes de Seguridad",
            style: GoogleFonts.dmSans(
              fontSize: widget.isWeb ? 16 : 15, 
              fontWeight: FontWeight.bold, 
              color: const Color(0xFF49454F),
            ),
          ),
          const SizedBox(height: 12),
          
          // --- MENÚ AGRUPADO (Estilo Premium/M3) ---
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(widget.isWeb ? 28 : 20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              children: [
                _buildM3ListTile(
                  title: "Red de Apoyo", 
                  subtitle: "Configura tus contactos de confianza",
                  icon: Icons.people_alt_outlined,
                  iconColor: const Color(0xFF6B52A3),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RedApoyoView()));
                  }
                ),
                const Divider(height: 1, indent: 64, endIndent: 20, color: Color(0xFFF4F2F6)),
                _buildM3ListTile(
                  title: "Modo Discreto", 
                  subtitle: "Oculta el rastro de la aplicación",
                  icon: Icons.visibility_off_outlined,
                  iconColor: Colors.grey.shade700,
                  onTap: () {
                     _showMessage("Próximamente: Opciones de camuflaje");
                  }
                ),
                const Divider(height: 1, indent: 64, endIndent: 20, color: Color(0xFFF4F2F6)),
                _buildM3ListTile(
                  title: "Centro de ayuda", 
                  subtitle: "Preguntas frecuentes y soporte",
                  icon: Icons.help_outline_rounded,
                  iconColor: const Color(0xFF6B52A3),
                  isLast: true, 
                  onTap: () {
                     _showMessage("Abriendo centro de ayuda...");
                  }
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // --- BOTÓN DE EMERGENCIA M3 ---
          SizedBox(
            width: double.infinity,
            height: widget.isWeb ? 56 : 48, 
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _emergencySignOut,
              icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Icon(Icons.warning_amber_rounded, size: widget.isWeb ? 22 : 18),
              label: Text(
                "Cierre Rápido y Seguro", 
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold, 
                  fontSize: widget.isWeb ? 16 : 14,
                  letterSpacing: 0.1,
                )
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E), 
                foregroundColor: Colors.white,
                shape: const StadiumBorder(), 
                elevation: 0,
              ),
            ),
          ),
          
          SizedBox(height: widget.isWeb ? 40 : 100),
        ],
      ),
    );
  }

  Widget _buildM3ListTile({
    required String title, 
    required String subtitle,
    required IconData icon, 
    required Color iconColor,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(title == "Red de Apoyo" ? (widget.isWeb ? 28 : 20) : 0),
        bottom: Radius.circular(isLast ? (widget.isWeb ? 28 : 20) : 0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.isWeb ? 20 : 16, vertical: widget.isWeb ? 16 : 12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(widget.isWeb ? 10 : 8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: widget.isWeb ? 22 : 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: widget.isWeb ? 16 : 15, color: const Color(0xFF1D1B20))
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle, 
                    style: TextStyle(fontSize: widget.isWeb ? 13 : 12, color: const Color(0xFF49454F)) 
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: widget.isWeb ? 24 : 20, color: const Color(0xFFCAC4D0)),
          ],
        ),
      ),
    );
  }
}