import 'dart:async';
import 'package:chatbothelper/views/bienvenida.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

// Importamos las vistas para que pueda hacer los cambios de página
import 'views/chatbot_view.dart';
import 'views/legal_view.dart';
import 'views/profile_view.dart';
import 'views/mapa_instituciones.dart';

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
      title: 'ChatBot Helper', 
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          primary: seedColor,
          surface: const Color(0xFFFAF9FC), 
          surfaceContainerHighest: const Color(0xFFF3EDF7), 
        ),
        textTheme: GoogleFonts.dmSansTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFFAF9FC), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF9FC),
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
      appBar: _buildWebNavBar(context, selectedIndex, onDestinationSelected),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(selectedIndex),
          child: _buildWebBody(),
        ),
      ),
    );
  }

  Widget _buildWebBody() {
    switch (selectedIndex) {
      case 1: return const LegalView(isWeb: true);
      case 2: return const ChatBotView(isWeb: true);

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
                    padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 60.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SupabaseSeccionesDinamicas(isWeb: true),
                        const SizedBox(height: 80),
                        
                        const SectionTitle(isWeb: true, title: "¿En dónde puede existir la violencia?", subtitle: "Conoce los espacios más comunes."),
                        const SizedBox(height: 32),
                        const SupabaseLugaresVSBG(isWeb: true),
                        const SizedBox(height: 80),

                        const BannerMapaApoyo(isWeb: true),
                        const SizedBox(height: 80),

                        const SectionTitle(isWeb: true, title: "Mitos vs Realidades", subtitle: "Desmintiendo creencias comunes."),
                        const SizedBox(height: 32),
                        const SupabaseMitos(isWeb: true),
                        const SizedBox(height: 80),

                        const SectionTitle(isWeb: true, title: "El Violentómetro", subtitle: "Mide los niveles de violencia. El abuso siempre escala."),
                        const SizedBox(height: 32),
                        const SupabaseViolentometro(isWeb: true),
                        const SizedBox(height: 80),

                        const SectionTitle(isWeb: true, title: "Videoteca Informativa", subtitle: "Recursos audiovisuales de apoyo."),
                        const SizedBox(height: 32),
                        const SupabaseVideos(isWeb: true),
                        const SizedBox(height: 100),
                        
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

  PreferredSizeWidget _buildWebNavBar(BuildContext context, int selectedIndex, ValueChanged<int> onDestinationSelected) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.98),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 90,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFF0EBF5), height: 1), 
      ),
      title: Row(
        children: [
          const SizedBox(width: 32),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6B52A3), Color(0xFF8B6BCC)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            "ChatBot Helper", 
            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: const Color(0xFF1D1B20), fontSize: 24, letterSpacing: -0.5)
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileView(isWeb: true)),
              );
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, color: Color(0xFF6B52A3), size: 20),
                  const SizedBox(width: 8),
                  Text("Mi Perfil", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: const Color(0xFF6B52A3), fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerPlantillaInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(56),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1B20), 
        borderRadius: BorderRadius.circular(40),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=2000&auto=format&fit=crop'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(const Color(0xFF1D1B20).withOpacity(0.85), BlendMode.srcOver),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Descarga nuestra plantilla informativa", 
                  style: GoogleFonts.dmSans(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)
                ),
                const SizedBox(height: 16),
                const Text(
                  "Ten a la mano información vital, números de emergencia y pasos a seguir.", 
                  style: TextStyle(fontSize: 18, color: Colors.white70, height: 1.5)
                ),
                const SizedBox(height: 40),
                FilledButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse('https://drive.google.com/file/d/1FOoF8lHy_5GpIyB0C9BN2mW8KRbrnjsC/view?usp=sharing'); 
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {}
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text("Descargar PDF Gratuito", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB8FF),
                    foregroundColor: const Color(0xFF221144),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/QRCartilla.png', width: 160, height: 160, fit: BoxFit.cover),
            ),
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
    final bool isWebMobile = kIsWeb; 

    return Scaffold(
      extendBody: true, 
      extendBodyBehindAppBar: selectedIndex == 0, 
      appBar: AppBar(
        backgroundColor: selectedIndex == 0 ? Colors.transparent : const Color(0xFFFAF9FC),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: selectedIndex == 0 ? Colors.white : const Color(0xFF1D1B20)),
        title: selectedIndex != 0 ? Text(
          selectedIndex == 1 ? "Marco Legal" : "ChatBot", 
          style: GoogleFonts.dmSans(color: const Color(0xFF1D1B20), fontWeight: FontWeight.bold, fontSize: 20) 
        ) : null,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.account_circle_rounded, 
                size: 28, 
                color: selectedIndex == 0 ? Colors.white : const Color(0xFF6B52A3)
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileView(isWeb: false)),
                );
              },
            ),
          ),
        ],
      ),
      
      drawer: isWebMobile ? _buildSideMenu(context) : null, 

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: KeyedSubtree(
          key: ValueKey<int>(selectedIndex),
          child: _buildMobileBody(),
        ),
      ),
      
      bottomNavigationBar: !isWebMobile ? _buildBottomNavBar() : null,
    );
  }

  Widget _buildSideMenu(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 80, bottom: 40, left: 32, right: 32),
            decoration: const BoxDecoration(color: Color(0xFF1D1B20)), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                Text("VozSegura", style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 28, letterSpacing: -1)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                _buildDrawerItem(context, icon: Icons.home_rounded, title: "Inicio", index: 0),
                _buildDrawerItem(context, icon: Icons.gavel_rounded, title: "Marco Legal", index: 1),
                _buildDrawerItem(context, icon: Icons.chat_bubble_rounded, title: "ChatBot", index: 2),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: const Icon(Icons.person_rounded, color: Color(0xFF49454F)),
                    title: Text(
                      "Mi Perfil",
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFF1D1B20),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), 
                    onTap: () {
                      Navigator.pop(context); 
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileView(isWeb: kIsWeb)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required int index}) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? const Color(0xFF6B52A3) : const Color(0xFF49454F)),
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            color: isSelected ? const Color(0xFF6B52A3) : const Color(0xFF1D1B20),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), 
        tileColor: isSelected ? const Color(0xFF6B52A3).withOpacity(0.1) : Colors.transparent,
        onTap: () {
          onDestinationSelected(index);
          Navigator.pop(context); 
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
      ),
      child: NavigationBar(
        height: 65, 
        backgroundColor: Colors.white.withOpacity(0.95), 
        elevation: 0,
        indicatorColor: const Color(0xFF6B52A3).withOpacity(0.15),
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined, color: Color(0xFF49454F)), 
            selectedIcon: const Icon(Icons.home_rounded, color: Color(0xFF221144)), 
            label: 'Inicio'
          ),
          NavigationDestination(
            icon: const Icon(Icons.gavel_outlined, color: Color(0xFF49454F)), 
            selectedIcon: const Icon(Icons.gavel_rounded, color: Color(0xFF221144)), 
            label: 'Legal'
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF49454F)), 
            selectedIcon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF221144)), 
            label: 'ChatBot'
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBody() {
    switch (selectedIndex) {
      case 1: return const LegalView(isWeb: false);
      case 2: return const ChatBotView(isWeb: false);
      case 0:
      default:
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroBanner(isWeb: false, onChatTap: () => onDestinationSelected(2)),
              const SizedBox(height: 24),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SupabaseSeccionesDinamicas(isWeb: false),
              ),
              const SizedBox(height: 40),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SectionTitle(isWeb: false, title: "¿En dónde puede\nexistir la violencia?", subtitle: "Conoce los espacios."),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SupabaseLugaresVSBG(isWeb: false),
              ),
              const SizedBox(height: 40),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: BannerMapaApoyo(isWeb: false),
              ),
              const SizedBox(height: 40),


              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SectionTitle(isWeb: false, title: "Mitos vs Realidades", subtitle: "Lo que debes saber."),
              ),
              const SizedBox(height: 16),
              const SupabaseMitos(isWeb: false),
              const SizedBox(height: 40),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SectionTitle(isWeb: false, title: "El Violentómetro", subtitle: "Presta atención a las señales."),
              ),
              const SizedBox(height: 16),
              const SupabaseViolentometro(isWeb: false),
              const SizedBox(height: 40),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: SectionTitle(isWeb: false, title: "Videos Relacionados", subtitle: "Recursos audiovisuales."),
              ),
              const SizedBox(height: 16),
              const SupabaseVideos(isWeb: false),
              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(24), 
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D1B20),
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: const NetworkImage('https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=800&auto=format&fit=crop'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(const Color(0xFF1D1B20).withOpacity(0.85), BlendMode.srcOver),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Plantilla Informativa", style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                      const SizedBox(height: 8),
                      const Text(
                        "Descarga nuestra guía paso a paso para situaciones de emergencia.",
                        style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48, 
                        child: FilledButton.icon(
                          onPressed: () async {
                            final Uri url = Uri.parse('https://drive.google.com/file/d/1FOoF8lHy_5GpIyB0C9BN2mW8KRbrnjsC/view?usp=sharing'); 
                            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {}
                          },
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text("Descargar Guía", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFEAB8FF),
                            foregroundColor: const Color(0xFF221144),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)), 
                          ),
                        ),
                      ),
                    ],
                  ),
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
      height: isWeb ? 520 : 580, 
      decoration: BoxDecoration(
        borderRadius: isWeb ? BorderRadius.circular(40) : const BorderRadius.vertical(bottom: Radius.circular(32)),
        color: const Color(0xFF1D1B20),
      ),
      margin: isWeb ? const EdgeInsets.only(top: 24, left: 40, right: 40, bottom: 40) : EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: isWeb ? BorderRadius.circular(40) : const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: streamBanners,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white54));
            }
            if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Error de conexión, intentalo nuevamente.', style: TextStyle(color: Colors.white54)),
              );
            }
            return _AutoCarousel(banners: snapshot.data!, isWeb: isWeb, onChatTap: onChatTap);
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
    _timer = Timer.periodic(const Duration(seconds: 7), (Timer timer) {
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1200),
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
      onPageChanged: (int page) => setState(() => _currentPage = page),
      itemBuilder: (context, index) {
        final banner = widget.banners[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              banner['imagen_url'] ?? '',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.6),
                    const Color(0xFF1D1B20).withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isWeb ? 80.0 : 20.0, 
                  vertical: widget.isWeb ? 60.0 : 20.0 
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end, 
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFEAB8FF).withOpacity(0.2), borderRadius: BorderRadius.circular(100)),
                      child: Text("Tu espacio seguro", style: GoogleFonts.dmSans(color: const Color(0xFFEAB8FF), fontWeight: FontWeight.bold, fontSize: widget.isWeb ? 13 : 11)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      banner['titulo'] ?? 'Sin título',
                      style: GoogleFonts.dmSans(
                        fontSize: widget.isWeb ? 64 : 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: widget.isWeb ? 25 : 8),
                    SizedBox(
                      width: widget.isWeb ? 650 : double.infinity,
                      child: Text(
                        banner['subtitulo'] ?? '',
                        maxLines: 3, 
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: widget.isWeb ? 20 : 14, 
                          color: Colors.white70, 
                          height: 1.3,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                    ),
                    SizedBox(height: widget.isWeb ? 32 : 16),
                    FilledButton.icon(
                      onPressed: widget.onChatTap,
                      icon: Icon(Icons.chat_bubble_rounded, size: widget.isWeb ? 20 : 16),
                      label: Text("Hablar con el Asistente", style: TextStyle(fontSize: widget.isWeb ? 16 : 14, fontWeight: FontWeight.bold)),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white, 
                        foregroundColor: const Color(0xFF1D1B20),
                        padding: EdgeInsets.symmetric(horizontal: widget.isWeb ? 32 : 24, vertical: widget.isWeb ? 20 : 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      ),
                    ),
                    SizedBox(height: widget.isWeb ? 20 : 0),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* =============================================================================
   MÓDULO: SECCIONES INFORMATIVAS
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
        if (!snapshot.hasData) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
        final secciones = snapshot.data!;

        if (isWeb) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(isWeb: true, title: "Módulos de Información", subtitle: "Todo lo que necesitas saber de forma clara."),
              const SizedBox(height: 32),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 450, 
                  mainAxisExtent: 160, 
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: secciones.length,
                itemBuilder: (context, index) => _AnimatedWebGridCard(seccion: secciones[index]),
              ),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(isWeb: false, title: "Módulos de Información", subtitle: "Conceptos clave explicados."),
              const SizedBox(height: 16), 
              SizedBox(
                height: 140, 
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none, 
                  itemCount: secciones.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 260, 
                      margin: const EdgeInsets.only(right: 12),
                      child: MobilePreviewCard(
                        title: secciones[index]['titulo'] ?? 'Sin título',
                        previewText: secciones[index]['texto_previo'] ?? '',
                        fullContent: secciones[index]['contenido_completo'] ?? '',
                        imagenUrl: secciones[index]['imagen_url'], // Pasamos la URL al componente móvil
                      ),
                    );
                  },
                ),
              ),
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..translate(0, isHovered ? -4 : 0),
          decoration: BoxDecoration(
            color: isHovered ? Colors.white : const Color(0xFFF3EDF7), 
            borderRadius: BorderRadius.circular(28),
            boxShadow: isHovered ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))] : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              // Pasamos la URL al método de visualización web
              onTap: () => _mostrarGlobalModalWeb(context, seccion['titulo'] ?? '', seccion['contenido_completo'] ?? '', seccion['imagen_url']),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isHovered ? const Color(0xFF6B52A3) : Colors.white, 
                        borderRadius: BorderRadius.circular(20)
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
                            seccion['titulo'] ?? '', 
                            style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1D1B20)),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            seccion['texto_previo'] ?? '', 
                            style: const TextStyle(fontSize: 14, color: Color(0xFF49454F), height: 1.4),
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

/* =============================================================================
   MÓDULO: LUGARES VSBG
   ============================================================================= */

class SupabaseLugaresVSBG extends StatelessWidget {
  final bool isWeb;
  const SupabaseLugaresVSBG({super.key, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los datos de la base de datos ordenados
    final streamLugares = Supabase.instance.client.from('lugares_vsbg').stream(primaryKey: ['id']).order('orden');

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: streamLugares,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final lugares = snapshot.data!;

        return SizedBox(
          height: isWeb ? 120 : 90, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: lugares.length,
            itemBuilder: (context, index) {
              final lugar = lugares[index];
              return Container(
                width: isWeb ? 400 : 280, 
                margin: EdgeInsets.only(right: isWeb ? 24 : 12),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  elevation: 0,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      // AQUÍ ESTÁ EL CAMBIO: Pasamos la imagen_url a las vistas de detalle
                      if (isWeb) {
                        _mostrarGlobalModalWeb(
                          context, 
                          lugar['titulo'] ?? '', 
                          lugar['contenido_completo'] ?? '',
                          lugar['imagen_url'] // Enviamos la imagen web
                        );
                      } else {
                        Navigator.push(
                          context, 
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              title: lugar['titulo'] ?? '', 
                              content: lugar['contenido_completo'] ?? '',
                              imagenUrl: lugar['imagen_url'] 
                            )
                          )
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isWeb ? 24 : 16, 
                        vertical: isWeb ? 20 : 12
                      ), 
                      child: Row(
                        children: [
                          Container(
                            width: isWeb ? 48 : 40, height: isWeb ? 48 : 40,
                            decoration: BoxDecoration(color: const Color(0xFFF3EDF7), borderRadius: BorderRadius.circular(12)),
                            child: Center(
                              child: Text(
                                lugar['letra_avatar'] ?? '-', 
                                style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: const Color(0xFF6B52A3), fontSize: isWeb ? 20 : 16)
                              )
                            ),
                          ),
                          const SizedBox(width: 16), 
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  lugar['titulo'] ?? '', 
                                  style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: isWeb ? 18 : 15, color: const Color(0xFF1D1B20)), 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lugar['subtitulo'] ?? '', 
                                  style: TextStyle(color: const Color(0xFF49454F), fontSize: isWeb ? 14 : 12), 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFFCAC4D0), size: isWeb ? 16 : 14),
                        ],
                      ),
                    ),
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
        if (!snapshot.hasData) return const SizedBox();
        final mitos = snapshot.data!;
        
        return SizedBox(
          height: isWeb ? 340 : 260, 
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 20.0), 
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemCount: mitos.length,
            itemBuilder: (context, index) {
              final mito = mitos[index];
              return Container(
                width: isWeb ? 420 : 280, 
                margin: EdgeInsets.only(right: isWeb ? 32 : 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isWeb ? 32 : 20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isWeb ? 24 : 16), 
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3261E).withOpacity(0.06), 
                        borderRadius: BorderRadius.vertical(top: Radius.circular(isWeb ? 32 : 20)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.close_rounded, color: const Color(0xFFB3261E), size: isWeb ? 24 : 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              mito['mito'] ?? '', 
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: const Color(0xFF8C1D18), fontSize: isWeb ? 16 : 14, height: 1.3)
                            )
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(isWeb ? 24 : 16), 
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle_outline_rounded, color: const Color(0xFF386A20), size: isWeb ? 24 : 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mito['realidad'] ?? '', 
                                style: TextStyle(color: const Color(0xFF1D1B20), fontSize: isWeb ? 15 : 13, height: 1.4) 
                              )
                            ),
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
    if (nivel == 1) return const Color(0xFFF9A825); 
    if (nivel == 2) return const Color(0xFFE65100); 
    return const Color(0xFFB3261E); 
  }

  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client.from('violentometro').stream(primaryKey: ['id']).order('orden');
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 20.0),
          child: Wrap(
            spacing: isWeb ? 12 : 8, 
            runSpacing: isWeb ? 12 : 8,
            children: snapshot.data!.map((item) {
              final nivel = item['nivel'] as int? ?? 1;
              final color = _getColorForNivel(nivel);
              
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 20 : 14, 
                  vertical: isWeb ? 12 : 8
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(100), 
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      child: Icon(Icons.warning_rounded, color: Colors.white, size: isWeb ? 14 : 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item['accion'] ?? '', 
                      style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: isWeb ? 14 : 12),
                    ),
                  ],
                ),
              );
            }).toList(),
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

  @override
  Widget build(BuildContext context) {
    final stream = Supabase.instance.client.from('videos_educativos').stream(primaryKey: ['id']).order('orden');
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final videos = snapshot.data!;
        
        return SizedBox(
          height: isWeb ? 300 : 220, 
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isWeb ? 0 : 20.0),
            clipBehavior: Clip.none,
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Container(
                width: isWeb ? 400 : 240, 
                margin: EdgeInsets.only(right: isWeb ? 32 : 16),
                child: InkWell(
                  onTap: () async {
                    final Uri url = Uri.parse(video['video_url'] ?? 'https://youtube.com');
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  borderRadius: BorderRadius.circular(isWeb ? 32 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(isWeb ? 24 : 16),
                            image: DecorationImage(
                              image: NetworkImage(video['thumbnail_url'] ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5), 
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: isWeb ? 36 : 28),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        video['titulo'] ?? '', 
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold, 
                          fontSize: isWeb ? 18 : 15, 
                          color: const Color(0xFF1D1B20), 
                          height: 1.2
                        ),
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis, 
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
   FUNCIONES GLOBALES Y COMPONENTES COMPARTIDOS
   ============================================================================= */

// Modificamos esta función para aceptar la imagen opcionalmente
void _mostrarGlobalModalWeb(BuildContext context, String title, String content, [String? imagenUrl]) {
  showDialog(
    context: context,
    barrierColor: const Color(0xFF1D1B20).withOpacity(0.4), 
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Container(
          width: 800,
          height: 650,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                color: const Color(0xFFF3EDF7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1D1B20), letterSpacing: -0.5))),
                    Container(
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Renderizamos la imagen en la vista web si existe
                      if (imagenUrl != null && imagenUrl.isNotEmpty)
                        Container(
                          width: double.infinity,
                          height: 250,
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: const Color(0xFFF3EDF7),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.network(
                              imagenUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.image_not_supported_rounded, color: Color(0xFF6B52A3), size: 40)
                              ),
                            ),
                          ),
                        ),
                      MarkdownBody(
                        data: content.replaceAll(r'\n', '\n'),
                        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                          p: const TextStyle(fontSize: 17, height: 1.6, color: Color(0xFF49454F)),
                          h1: GoogleFonts.dmSans(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF1D1B20)),
                          h2: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1D1B20)),
                          listBullet: const TextStyle(color: Color(0xFF6B52A3), fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _WebNavButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _WebNavButton({required this.title, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30), 
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1D1B20) : Colors.transparent, 
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            title, 
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold, 
              fontSize: 15,
              color: isActive ? Colors.white : const Color(0xFF49454F)
            )
          ),
        ),
      ),
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

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isWeb; 

  const SectionTitle({super.key, required this.title, required this.subtitle, this.isWeb = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title, 
          style: GoogleFonts.dmSans(
            fontSize: isWeb ? 32 : 24, 
            fontWeight: FontWeight.w800, 
            color: const Color(0xFF1D1B20), 
            letterSpacing: -0.5, 
            height: 1.1
          )
        ),
        SizedBox(height: isWeb ? 8 : 4),
        Text(
          subtitle, 
          style: TextStyle(
            fontSize: isWeb ? 16 : 14, 
            color: const Color(0xFF49454F)
          )
        ),
      ],
    );
  }
}

class MobilePreviewCard extends StatelessWidget {
  final String title;
  final String previewText;
  final String fullContent;
  final String? imagenUrl; // Añadimos la URL como parámetro

  const MobilePreviewCard({
    super.key, 
    required this.title, 
    required this.previewText, 
    required this.fullContent,
    this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), 
      ),
      child: InkWell(
        // Pasamos la URL a la vista de detalle
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(title: title, content: fullContent, imagenUrl: imagenUrl))),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16), 
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1D1B20)), maxLines: 2),
                    const SizedBox(height: 6),
                    Text(previewText, style: const TextStyle(fontSize: 13, color: Color(0xFF49454F), height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFFF3EDF7), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF6B52A3), size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final String? imagenUrl; // Parámetro para recibir la imagen

  const DetailScreen({
    super.key, 
    required this.title, 
    required this.content,
    this.imagenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1D1B20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenedor dinámico que revisa si hay imagen
            Container(
              width: double.infinity, 
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EDF7), 
                borderRadius: BorderRadius.circular(24)
              ),
              child: (imagenUrl != null && imagenUrl!.isNotEmpty)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      imagenUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.menu_book_rounded, size: 54, color: Color(0xFF6B52A3))
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Icon(Icons.menu_book_rounded, size: 54, color: Color(0xFF6B52A3))
                  ),
            ),
            const SizedBox(height: 24),
            Text(title, style: GoogleFonts.dmSans(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1D1B20), letterSpacing: -1)),
            const SizedBox(height: 16),
            MarkdownBody(
              data: content.replaceAll(r'\n', '\n'), 
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF49454F)),
                h1: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1D1B20)),
                listBullet: const TextStyle(color: Color(0xFF6B52A3), fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/* =============================================================================
   MÓDULO: BANNER DE MAPA DE APOYO
   ============================================================================= */
class BannerMapaApoyo extends StatelessWidget {
  final bool isWeb;
  const BannerMapaApoyo({super.key, required this.isWeb});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWeb ? 40 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDF7), 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEBE8F0), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF6B52A3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.map_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Puntos de Apoyo Seguros",
                  style: GoogleFonts.dmSans(
                    fontSize: isWeb ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1D1B20),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Encuentra instituciones y líneas de atención cercanas en el área metropolitana.",
                  style: TextStyle(
                    fontSize: isWeb ? 15 : 13,
                    color: const Color(0xFF49454F),
                  ),
                ),
              ],
            ),
          ),
          if (isWeb) const SizedBox(width: 40),
          
          // Botón para Web (Con texto)
          if (isWeb)
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapaInstitucionesView(isWeb: true)),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text("Abrir Mapa"),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6B52A3),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            
          // Botón para Móvil (Solo ícono para ahorrar espacio)
          if (!isWeb)
            IconButton.filled(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapaInstitucionesView(isWeb: false)),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF6B52A3),
              ),
            ),
        ],
      ),
    );
  }
}