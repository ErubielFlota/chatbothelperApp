import 'dart:async';
import 'package:chatbothelper/views/bienvenida.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

// Importaciones de tus vistas modulares
import 'views/chatbot_view.dart';
import 'views/legal_view.dart';
import 'views/profile_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('No se encontraron las credenciales de Supabase en el archivo .env');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey, 
  );

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  if (isFirstTime) {
    await prefs.setBool('isFirstTime', false);
  }

  runApp(ChatbotHelperApp(isFirstTime: isFirstTime));
}

class ChatbotHelperApp extends StatelessWidget {
  final bool isFirstTime; 

  const ChatbotHelperApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF6B52A3);

    return MaterialApp(
      title: 'Chatbot Helper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
          surface: const Color(0xFFF9FAFB),
        ),
        textTheme: GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: isFirstTime ? const WelcomeScreen() : const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 850;

        if (isWeb) {
          return _WebLayout(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          );
        } else {
          return _MobileLayout(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          );
        }
      },
    );
  }
}

/* =============================================================================
   PARADIGMA WEB / ESCRITORIO
   ============================================================================= */
class _WebLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _WebLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildWebNavBar(selectedIndex, onDestinationSelected),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(selectedIndex),
          child: _buildWebBody(),
        ),
      ),
    );
  }

  Widget _buildWebBody() {
    switch (selectedIndex) {
      case 1:
        return const LegalView(isWeb: true);
      case 2:
        return const ChatBotView(isWeb: true);
      case 3:
        return const ProfileView(isWeb: true);
      case 0:
      default:
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              HeroBanner(isWeb: true, onChatTap: () => onDestinationSelected(2)),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SupabaseSeccionesDinamicas(isWeb: true),
                        const SizedBox(height: 60),
                        
                        const SectionTitle(title: "¿En dónde puede existir la VSBG?"),
                        const SizedBox(height: 32),
                        const SupabaseLugaresVSBG(isWeb: true),
                        const SizedBox(height: 60),

                        const SectionTitle(title: "Mitos vs Realidades"),
                        const SizedBox(height: 24),
                        const SupabaseMitos(isWeb: true),
                        const SizedBox(height: 60),

                        const SectionTitle(title: "El Violentómetro"),
                        const Text("Mide los niveles de violencia. El abuso siempre escala.", style: TextStyle(color: Colors.black54, fontSize: 16)),
                        const SizedBox(height: 24),
                        const SupabaseViolentometro(isWeb: true),
                        const SizedBox(height: 60),

                        const SectionTitle(title: "Videoteca Informativa"),
                        const SizedBox(height: 24),
                        const SupabaseVideos(isWeb: true),
                        const SizedBox(height: 80),
                        
                        _buildBannerPlantillaInfo()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }

  PreferredSizeWidget _buildWebNavBar(int selectedIndex, ValueChanged<int> onDestinationSelected) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.94),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 85,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.black.withOpacity(0.04), height: 1), 
      ),
      title: Row(
        children: [
          const SizedBox(width: 32),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6B52A3).withOpacity(0.12), 
              borderRadius: BorderRadius.circular(14)
            ),
            child: const Icon(Icons.shield_outlined, color: Color(0xFF6B52A3), size: 26),
          ),
          const SizedBox(width: 16),
          Text(
            "Chatbot Helper", 
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w800, color: const Color(0xFF221144), fontSize: 24)
          ),
        ],
      ),
      actions: [
        _WebNavButton(title: "Inicio", isActive: selectedIndex == 0, onTap: () => onDestinationSelected(0)),
        _WebNavButton(title: "Temas legales", isActive: selectedIndex == 1, onTap: () => onDestinationSelected(1)),
        _WebNavButton(title: "ChatBot", isActive: selectedIndex == 2, onTap: () => onDestinationSelected(2)),
        const SizedBox(width: 24),
        Padding(
          padding: const EdgeInsets.only(right: 60.0),
          child: InkWell(
            onTap: () => onDestinationSelected(3),
            customBorder: const CircleBorder(),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF6B52A3).withOpacity(0.08),
              radius: 22,
              child: const Icon(Icons.person_outline_rounded, color: Color(0xFF6B52A3), size: 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerPlantillaInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B52A3).withOpacity(0.06),
            const Color(0xFFEAB8FF).withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF6B52A3).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            "Conoce nuestra plantilla informativa", 
            style: GoogleFonts.dmSans(fontSize: 30, fontWeight: FontWeight.bold, color: const Color(0xFF332255))
          ),
          const SizedBox(height: 16),
          const Text(
            "Escanea el código QR o haz clic en el botón para descargar nuestro archivo PDF.", 
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 16, color: Colors.black54)
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Contenedor del código QR
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6B52A3).withOpacity(0.2), width: 2),
                ),
                child: Center(
                  // Puedes reemplazar este Icono por: Image.network('url_de_tu_qr.png')
                  child: Image.asset('assets/QRCartilla.png'),
                ),
              ),
              const SizedBox(width: 48),
              // Botón del PDF
              FilledButton.icon(
                onPressed: () async {
                  final Uri url = Uri.parse('https://drive.google.com/file/d/1FOoF8lHy_5GpIyB0C9BN2mW8KRbrnjsC/view?usp=sharing'); // <-- Reemplaza con tu enlace PDF real
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    debugPrint('No se pudo abrir $url');
                  }
                },
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text("Descargar PDF", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6B52A3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* =============================================================================
   PARADIGMA MÓVIL
   ============================================================================= */
class _MobileLayout extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _MobileLayout({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          selectedIndex == 1 ? "Marco Legal" : selectedIndex == 2 ? "ChatBot" : selectedIndex == 3 ? "Mi Perfil" : "Bienvenido", 
          style: GoogleFonts.dmSans(color: const Color(0xFF221144), fontWeight: FontWeight.bold, fontSize: 20)
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF6B52A3).withOpacity(0.1), 
              radius: 18, 
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.person, size: 18, color: Color(0xFF6B52A3)),
                onPressed: () => onDestinationSelected(3),
              )
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey<int>(selectedIndex),
          child: _buildMobileBody(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B52A3).withOpacity(0.12), 
                blurRadius: 25, 
                offset: const Offset(0, 10)
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: NavigationBar(
              height: 68,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: const Color(0xFF6B52A3).withOpacity(0.15),
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: const [
                NavigationDestination(icon: Icon(Icons.home_outlined, color: Colors.black54), selectedIcon: Icon(Icons.home, color: Color(0xFF6B52A3)), label: 'Inicio'),
                NavigationDestination(icon: Icon(Icons.gavel_outlined, color: Colors.black54), selectedIcon: Icon(Icons.gavel, color: Color(0xFF6B52A3)), label: 'Legal'),
                NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded, color: Colors.black54), selectedIcon: Icon(Icons.chat_bubble, color: Color(0xFF6B52A3)), label: 'ChatBot'),
                NavigationDestination(icon: Icon(Icons.person_outline, color: Colors.black54), selectedIcon: Icon(Icons.person, color: Color(0xFF6B52A3)), label: 'Perfil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBody() {
    switch (selectedIndex) {
      case 1:
        return const LegalView(isWeb: false);
      case 2:
        return const ChatBotView(isWeb: false);
      case 3:
        return const ProfileView(isWeb: false);
      case 0:
      default:
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10.0, bottom: 110.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: HeroBanner(isWeb: false, onChatTap: () => onDestinationSelected(2)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SupabaseSeccionesDinamicas(isWeb: false),
              ),
              const SizedBox(height: 20),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SectionTitle(title: "¿En dónde puede\nexistir la VSBG?"),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SupabaseLugaresVSBG(isWeb: false),
              ),
              const SizedBox(height: 32),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SectionTitle(title: "Mitos vs Realidades"),
              ),
              const SizedBox(height: 16),
              const SupabaseMitos(isWeb: false),
              const SizedBox(height: 32),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SectionTitle(title: "El Violentómetro"),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text("Presta atención a las señales.", style: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 16),
              const SupabaseViolentometro(isWeb: false),
              const SizedBox(height: 32),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SectionTitle(title: "Videoteca"),
              ),
              const SizedBox(height: 16),
              const SupabaseVideos(isWeb: false),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(title: "Conoce nuestra plantilla informativa"),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B52A3).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFF6B52A3).withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            
                            child: Image.asset('assets/QRCartilla.png'),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Escanea el código o descarga el archivo para más detalles.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54, fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: () async {
                                final Uri url = Uri.parse('https://drive.google.com/file/d/1FOoF8lHy_5GpIyB0C9BN2mW8KRbrnjsC/view?usp=sharing'); // <-- Reemplaza con tu enlace PDF real
                                if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                  debugPrint('No se pudo abrir $url');
                                }
                              },
                              icon: const Icon(Icons.picture_as_pdf_rounded, size: 22),
                              label: const Text("Descargar PDF", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF6B52A3),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}

/* =============================================================================
   MÓDULO: HERO BANNER
   ============================================================================= */
class HeroBanner extends StatelessWidget {
  final bool isWeb;
  final VoidCallback onChatTap;
  
  const HeroBanner({super.key, required this.isWeb, required this.onChatTap});

  @override
  Widget build(BuildContext context) {
    final streamBanners = Supabase.instance.client
        .from('hero_banners')
        .stream(primaryKey: ['id'])
        .order('orden', ascending: true);

    return Container(
      width: double.infinity,
      height: isWeb ? 440 : 350, 
      margin: EdgeInsets.only(bottom: isWeb ? 0 : 32), 
      decoration: BoxDecoration(
        borderRadius: isWeb ? BorderRadius.zero : BorderRadius.circular(28),
        color: const Color(0xFFEBE8F0),
      ),
      child: ClipRRect(
        borderRadius: isWeb ? BorderRadius.zero : BorderRadius.circular(28),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: streamBanners,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Configura tus imágenes en Supabase', style: TextStyle(color: Colors.black45)),
              );
            }
            final banners = snapshot.data!;
            return _AutoCarousel(banners: banners, isWeb: isWeb, onChatTap: onChatTap);
          },
        ),
      ),
    );
  }
}

class _AutoCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final bool isWeb;
  final VoidCallback onChatTap;

  const _AutoCarousel({required this.banners, required this.isWeb, required this.onChatTap});

  @override
  State<_AutoCarousel> createState() => _AutoCarouselState();
}

class _AutoCarouselState extends State<_AutoCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.banners.length,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (int page) {
        setState(() { _currentPage = page; });
      },
      itemBuilder: (context, index) {
        final banner = widget.banners[index];
        final imageUrl = banner['imagen_url'] ?? '';
        final title = banner['titulo'] ?? 'Sin título';
        final subtitle = banner['subtitulo'] ?? '';

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.55), 
                BlendMode.darken
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.isWeb ? 1440 : double.infinity),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isWeb ? 60.0 : 24.0, 
                  vertical: 40.0
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: widget.isWeb ? 58 : 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: widget.isWeb ? 750 : double.infinity,
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: widget.isWeb ? 20 : 16, 
                          color: Colors.white.withOpacity(0.85), 
                          height: 1.5
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    FilledButton.icon(
                      onPressed: widget.onChatTap,
                      icon: const Icon(Icons.chat_bubble_rounded, size: 22),
                      label: const Text("Hablar con el ChatBot", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFEAB8FF), 
                        foregroundColor: const Color(0xFF221144),
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* =============================================================================
   MÓDULO: SECCIONES INFORMATIVAS DINÁMICAS
   ============================================================================= */
class SupabaseSeccionesDinamicas extends StatelessWidget {
  final bool isWeb;
  
  const SupabaseSeccionesDinamicas({super.key, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final streamDatos = Supabase.instance.client
        .from('secciones_informativas')
        .stream(primaryKey: ['id'])
        .order('orden', ascending: true);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: streamDatos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.withOpacity(0.1),
            child: Text('Error de conexión con la base de datos: ${snapshot.error}'),
          );
        }

        final secciones = snapshot.data;
        if (secciones == null || secciones.isEmpty) {
          return const Center(child: Text('Cargando módulos educativos...'));
        }

        if (isWeb) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: "Módulos de Información"),
              const SizedBox(height: 28),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 480, 
                  mainAxisExtent: 145, 
                  crossAxisSpacing: 28,
                  mainAxisSpacing: 28,
                ),
                itemCount: secciones.length,
                itemBuilder: (context, index) {
                  final seccion = secciones[index];
                  return _AnimatedWebGridCard(seccion: seccion);
                },
              ),
              const SizedBox(height: 40), 
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: "Módulos de Información"),
              const SizedBox(height: 18),
              SizedBox(
                height: 230, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none, 
                  itemCount: secciones.length,
                  itemBuilder: (context, index) {
                    final seccion = secciones[index];
                    return Container(
                      width: 290, 
                      margin: const EdgeInsets.only(right: 18),
                      child: MobilePreviewCard(
                        title: seccion['titulo'] ?? 'Sin título',
                        previewText: seccion['texto_previo'] ?? 'Resumen no disponible',
                        fullContent: seccion['contenido_completo'] ?? 'Contenido completo no disponible',
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.swipe_left_rounded, size: 16, color: Colors.black38),
                  SizedBox(width: 8),
                  Text("Desliza para ver más", style: TextStyle(fontSize: 13, color: Colors.black38, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 24),
            ],
          );
        }
      },
    );
  }
}

class _AnimatedWebGridCard extends StatelessWidget {
  final Map<String, dynamic> seccion;
  const _AnimatedWebGridCard({required this.seccion});

  @override
  Widget build(BuildContext context) {
    return ValueNotifierWrapper(
      builder: (context, isHovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0, isHovered ? -5 : 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isHovered ? const Color(0xFF6B52A3).withOpacity(0.4) : const Color(0xFFEBE8F0), 
              width: 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered ? const Color(0xFF6B52A3).withOpacity(0.08) : Colors.black.withOpacity(0.02),
                blurRadius: isHovered ? 20 : 10,
                offset: isHovered ? const Offset(0, 8) : const Offset(0, 4),
              )
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => _mostrarGlobalModalWeb(
              context, 
              seccion['titulo'] ?? 'Sin título', 
              seccion['contenido_completo'] ?? 'Contenido no disponible'
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isHovered ? const Color(0xFF6B52A3) : const Color(0xFF6B52A3).withOpacity(0.07), 
                      shape: BoxShape.circle
                    ),
                    child: Icon(Icons.menu_book_rounded, color: isHovered ? Colors.white : const Color(0xFF6B52A3)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          seccion['titulo'] ?? 'Sin título', 
                          style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF221144)),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          seccion['texto_previo'] ?? 'Haz clic para leer más...', 
                          style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}

class ValueNotifierWrapper extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;
  const ValueNotifierWrapper({super.key, required this.builder});

  @override
  State<ValueNotifierWrapper> createState() => _ValueNotifierWrapperState();
}

class _ValueNotifierWrapperState extends State<ValueNotifierWrapper> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );
  }
}

/* =============================================================================
   MÓDULO: LUGARES VSBG DINÁMICO (Corregido a Carrusel Horizontal)
   ============================================================================= */
class SupabaseLugaresVSBG extends StatelessWidget {
  final bool isWeb;
  
  const SupabaseLugaresVSBG({super.key, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final streamLugares = Supabase.instance.client
        .from('lugares_vsbg')
        .stream(primaryKey: ['id'])
        .order('orden', ascending: true);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: streamLugares,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return const Text('Configura los lugares en Supabase', style: TextStyle(color: Colors.black45));
        }

        final lugares = snapshot.data!;

        // Usamos SizedBox con un ListView horizontal para evitar que se aplasten
        return SizedBox(
          height: 110, // Altura suficiente para contener la tarjeta sin cortar la sombra
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(), // Efecto de rebote nativo
            itemCount: lugares.length,
            itemBuilder: (context, index) {
              final lugar = lugares[index];
              
              return Container(
                width: 320, // ¡Aquí está la magia! Un ancho fijo para que la tarjeta respire
                margin: EdgeInsets.only(right: isWeb ? 24.0 : 16.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    if (isWeb) {
                      // Abre modal en versión Web
                      _mostrarGlobalModalWeb(
                        context, 
                        lugar['titulo'] ?? 'Sin título', 
                        lugar['contenido_completo'] ?? 'Contenido no disponible'
                      );
                    } else {
                      // Abre nueva pantalla en versión Móvil
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: lugar['titulo'] ?? 'Sin título', 
                            content: lugar['contenido_completo'] ?? 'Contenido no disponible'
                          )
                        )
                      );
                    }
                  },
                  child: VerticalInfoCard(
                    avatarLetter: lugar['letra_avatar'] ?? '-',
                    title: lugar['titulo'] ?? 'Sin título',
                    subtitle: lugar['subtitulo'] ?? '',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/* =============================================================================
   MÓDULO: MITOS VS REALIDADES
   ============================================================================= */
class SupabaseMitos extends StatelessWidget {
  final bool isWeb;
  const SupabaseMitos({super.key, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client.from('mitos_realidades').stream(primaryKey: ['id']).order('orden');
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final mitos = snapshot.data!;
        
        return SizedBox(
          height: 250,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: mitos.length,
            itemBuilder: (context, index) {
              final mito = mitos[index];
              return Container(
                width: isWeb ? 400 : 300,
                margin: EdgeInsets.only(right: isWeb ? 24 : 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFEBE8F0)),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEBEE), 
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.cancel, color: Color(0xFFD32F2F)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(mito['mito'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB71C1C), fontSize: 15))),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFF388E3C)),
                            const SizedBox(width: 12),
                            Expanded(child: Text(mito['realidad'] ?? '', style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/* =============================================================================
   MÓDULO: EL VIOLENTÓMETRO
   ============================================================================= */
class SupabaseViolentometro extends StatelessWidget {
  final bool isWeb;
  const SupabaseViolentometro({super.key, required this.isWeb});

  Color _getColorForNivel(int nivel) {
    if (nivel == 1) return const Color(0xFFFDD835); 
    if (nivel == 2) return const Color(0xFFFB8C00); 
    return const Color(0xFFE53935); 
  }

  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client.from('violentometro').stream(primaryKey: ['id']).order('orden');
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        
        return SizedBox(
          height: 90,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final nivel = item['nivel'] as int? ?? 1;
              final color = _getColorForNivel(nivel);
              
              return Container(
                width: 200,
                margin: EdgeInsets.only(right: isWeb ? 16 : 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.5), width: 2),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color,
                      radius: 14,
                      child: Text(nivel.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['accion'] ?? '', 
                        style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.9), fontSize: 14),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/* =============================================================================
   MÓDULO: VIDEOTECA
   ============================================================================= */
class SupabaseVideos extends StatelessWidget {
  final bool isWeb;
  const SupabaseVideos({super.key, required this.isWeb});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client.from('videos_educativos').stream(primaryKey: ['id']).order('orden');
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final videos = snapshot.data!;
        
        return SizedBox(
          height: isWeb ? 260 : 220,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Container(
                width: isWeb ? 340 : 280,
                margin: EdgeInsets.only(right: isWeb ? 24 : 16),
                child: InkWell(
                  onTap: () => _launchUrl(video['video_url'] ?? 'https://youtube.com'),
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: NetworkImage(video['thumbnail_url'] ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.black.withOpacity(0.3),
                            ),
                            child: Center(
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF6B52A3), size: 36),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF6B52A3).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(video['duracion'] ?? '0:00', style: const TextStyle(color: Color(0xFF6B52A3), fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              video['titulo'] ?? '', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF221144)),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/* =============================================================================
   FUNCIONES GLOBALES Y COMPONENTES REUTILIZABLES COMPARTIDOS
   ============================================================================= */
void _mostrarGlobalModalWeb(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1.0),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800, maxHeight: 620),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B52A3).withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(title, style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF221144))),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.black54),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(36),
                        child: MarkdownBody(
                          data: content.replaceAll(r'\n', '\n'),
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                            h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF221144)),
                            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF221144)),
                            listBullet: const TextStyle(color: Color(0xFF6B52A3), fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF6B52A3),
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text("Entendido", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _WebNavButton extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _WebNavButton({required this.title, required this.isActive, required this.onTap});

  @override
  State<_WebNavButton> createState() => _WebNavButtonState();
}

class _WebNavButtonState extends State<_WebNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isActive 
                ? const Color(0xFF6B52A3).withOpacity(0.08) 
                : _isHovered ? const Color(0xFF6B52A3).withOpacity(0.03) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextButton(
            onPressed: widget.onTap,
            style: TextButton.styleFrom(
              foregroundColor: widget.isActive ? const Color(0xFF6B52A3) : Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              widget.title, 
              style: TextStyle(fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500, fontSize: 16)
            ),
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String title;
  final String content;

  const DetailScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(title, style: GoogleFonts.dmSans(color: const Color(0xFF221144), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B52A3), Color(0xFFEAB8FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ), 
                borderRadius: BorderRadius.circular(24)
              ),
              child: const Icon(Icons.shield_outlined, size: 64, color: Colors.white30),
            ),
            const SizedBox(height: 32),
            Text(title, style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF221144))),
            const SizedBox(height: 16),
            
            MarkdownBody(
              data: content.replaceAll(r'\n', '\n'), 
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                h1: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF221144)),
                h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF221144)),
                listBullet: const TextStyle(color: Color(0xFF6B52A3), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobilePreviewCard extends StatelessWidget {
  final String title;
  final String previewText;
  final String fullContent;

  const MobilePreviewCard({super.key, required this.title, required this.previewText, required this.fullContent});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(title: title, content: fullContent)));
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: GoogleFonts.dmSans(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF221144)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(previewText, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF6B52A3).withOpacity(0.08), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF6B52A3)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title, 
      style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF221144), height: 1.2)
    );
  }
}

class VerticalInfoCard extends StatelessWidget {
  final String avatarLetter;
  final String title;
  final String subtitle;

  const VerticalInfoCard({super.key, required this.avatarLetter, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6B52A3).withOpacity(0.12),
          radius: 22,
          child: Text(avatarLetter, style: const TextStyle(color: Color(0xFF6B52A3), fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF221144))),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFFAFAFC), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 14),
        ),
      ),
    );
  }
}