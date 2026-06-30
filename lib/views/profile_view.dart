import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileView extends StatelessWidget {
  final bool isWeb;

  const ProfileView({super.key, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40.0 : 20.0, 
        vertical: 24.0
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mi Cuenta",
            style: GoogleFonts.dmSans(
              fontSize: isWeb ? 32 : 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6B52A3).withAlpha(10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEAB8FF).withAlpha(40)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isWeb ? 40 : 32,
                  backgroundColor: const Color(0xFF6B52A3),
                  child: Text(
                    "U",
                    style: TextStyle(
                      fontSize: isWeb ? 32 : 24, 
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
                        "Usuario Anónimo",
                        style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Sesión segura local protegida por cifrado de extremo a extremo",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          _buildProfileOption(title: "Configuración de anonimato y privacidad", icon: Icons.privacy_tip_outlined),
          _buildProfileOption(title: "Autenticación segura y Passkeys", icon: Icons.fingerprint_rounded),
          _buildProfileOption(title: "Historial de consultas borrado automáticamente", icon: Icons.auto_delete_outlined),
          _buildProfileOption(title: "Centro de ayuda institucional urgente", icon: Icons.help_outline_rounded),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: isWeb ? 200 : double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          
          SizedBox(height: isWeb ? 40 : 100),
        ],
      ),
    );

    if (isWeb) {
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

  Widget _buildProfileOption({required String title, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
      ),
      child: ListTile(
        onTap: () {},
        leading: Icon(icon, color: const Color(0xFF6B52A3)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
      ),
    );
  }
}