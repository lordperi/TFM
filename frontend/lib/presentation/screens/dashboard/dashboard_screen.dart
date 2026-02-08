import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../screens/nutrition/food_search_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchar el modo actual para decidir qué UI mostrar
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isAdult = themeState.uiMode.isAdult;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isAdult ? 'Panel de Control' : 'Mi Aventura'),
            actions: [
              // Toggle de Tema
              IconButton(
                icon: Icon(isAdult ? Icons.child_care : Icons.person),
                onPressed: () {
                  context.read<ThemeBloc>().add(const ToggleUiMode());
                },
                tooltip: 'Cambiar Modo',
              ),
              // Logout
              // User Menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'switch') {
                    context.read<AuthBloc>().add(const UnselectProfile());
                  } else if (value == 'logout') {
                     context.read<AuthBloc>().add(const LogoutRequested());
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: 'switch',
                      child: Row(
                        children: [
                          Icon(Icons.switch_account, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text('Cambiar Perfil'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Cerrar Sesión'),
                        ],
                      ),
                    ),
                  ];
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.account_circle),
                ),
              ),
            ],
          ),
          body: isAdult ? const _AdultDashboard() : const _ChildDashboard(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => const FoodSearchScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(isAdult ? Icons.home : Icons.map),
                label: isAdult ? 'Inicio' : 'Mapa',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.restaurant),
                label: 'Comidas',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
            selectedItemColor: Theme.of(context).primaryColor,
            currentIndex: 0,
            onTap: (index) {
              if (index == 2) {
                // Navigate to profile screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }
            },
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// ADULT UX COMPONENT
// -----------------------------------------------------------------------------
class _AdultDashboard extends StatelessWidget {
  const _AdultDashboard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de Resumen Rápido
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Glucosa Actual', style: Theme.of(context).textTheme.titleMedium),
                      const Icon(Icons.more_horiz),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '105', 
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary
                        )
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text('mg/dL'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Hace 5 min • Estable', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text('Tendencia (24h)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          
          // Placeholder Gráfico
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.show_chart, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text('Gráfico de Datos', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CHILD UX COMPONENT
// -----------------------------------------------------------------------------
class _ChildDashboard extends StatelessWidget {
  const _ChildDashboard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Colors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar y Nivel
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFFEC4899), // Pink
                  child: Icon(Icons.face, size: 80, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B), // Amber
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text(
                      'NVL 5',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              '¡Hola, Campeón!', 
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28)
            ),
            const SizedBox(height: 32),
            
            // Barra de Experiencia (XP)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Experiencia', style: Theme.of(context).textTheme.labelLarge),
                      Text('450 / 500 XP', style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.9,
                      minHeight: 20,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)), // Emerald
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Botón de Acción Principal Modificado
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED), // Violet
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gamepad),
                    SizedBox(width: 8),
                    Text('JUGAR MINIJUEGO'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
