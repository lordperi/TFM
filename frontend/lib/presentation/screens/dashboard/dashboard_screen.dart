import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../screens/nutrition/food_search_screen.dart';
import '../../screens/nutrition/meal_history_screen.dart';
import '../profile/profile_screen.dart';
import '../../bloc/glucose/glucose_bloc.dart';
import '../../bloc/nutrition/nutrition_bloc.dart';
import '../../screens/glucose/add_glucose_screen.dart';
import '../../widgets/glucose/glucose_chart.dart';
import '../../widgets/glucose/glucose_alert_widget.dart';
import '../../screens/glucose/glucose_history_screen.dart';
import '../../../data/models/nutrition_models.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Cached insulin events. Updated whenever NutritionBloc emits
  /// [MealHistoryLoaded]. Persists even when NutritionBloc moves to
  /// another state (e.g. ingredient search), so the chart always shows data.
  List<MealLogEntry> _insulinEvents = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.selectedProfile != null) {
      final patientId = authState.selectedProfile!.id;
      context.read<GlucoseBloc>().add(LoadGlucoseHistory(patientId));
      context.read<NutritionBloc>().add(LoadMealHistory(patientId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Reload data when the selected profile changes
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated && state.selectedProfile != null) {
              final patientId = state.selectedProfile!.id;
              context.read<GlucoseBloc>().add(LoadGlucoseHistory(patientId));
              context.read<NutritionBloc>().add(LoadMealHistory(patientId));

              final isChild =
                  state.selectedProfile!.themePreference.toLowerCase() ==
                      'child';
              context
                  .read<ThemeBloc>()
                  .add(SetUiMode(isChild ? UiMode.child : UiMode.adult));
            }
          },
        ),
        // Cache insulin events whenever a fresh history load completes.
        // Using setState keeps the chart updated without depending on
        // NutritionBloc's current state (which changes for searches, etc.).
        BlocListener<NutritionBloc, NutritionState>(
          listener: (context, state) {
            if (state is MealHistoryLoaded) {
              setState(() => _insulinEvents = state.meals);
            }
          },
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isAdult = themeState.uiMode.isAdult;

          return Scaffold(
            appBar: AppBar(
              title: Text(isAdult ? 'Panel de Control' : 'Mi Aventura'),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'switch') {
                      context.read<AuthBloc>().add(const UnselectProfile());
                    } else if (value == 'logout') {
                      context.read<AuthBloc>().add(const LogoutRequested());
                    }
                  },
                  itemBuilder: (BuildContext context) => [
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
                  ],
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(Icons.account_circle),
                  ),
                ),
              ],
            ),
            body: isAdult
                ? _AdultDashboard(insulinEvents: _insulinEvents)
                : const _ChildDashboard(),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ADULT UX COMPONENT
// -----------------------------------------------------------------------------
class _AdultDashboard extends StatelessWidget {
  final List<MealLogEntry> insulinEvents;

  const _AdultDashboard({this.insulinEvents = const []});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const GlucoseAlertWidget(),

          // Tarjeta de Resumen Rápido
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<GlucoseBloc, GlucoseState>(
                builder: (context, state) {
                  String value = '--';
                  String timeCmd = '';

                  if (state is GlucoseLoaded && state.history.isNotEmpty) {
                    final latest = state.history.reduce((curr, next) =>
                        curr.timestamp.isAfter(next.timestamp) ? curr : next);
                    value = latest.glucoseValue.toString();
                    final diff =
                        DateTime.now().difference(latest.timestamp).inMinutes;
                    timeCmd = 'Hace $diff min';
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Glucosa Actual',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.blueAccent),
                                tooltip: 'Añadir Medida',
                                onPressed: () {
                                  final authState =
                                      context.read<AuthBloc>().state;
                                  if (authState is AuthAuthenticated &&
                                      authState.selectedProfile != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => AddGlucoseScreen(
                                              patientId: authState
                                                  .selectedProfile!.id)),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.history),
                                tooltip: 'Ver Historial Glucosa',
                                onPressed: () {
                                  final authState =
                                      context.read<AuthBloc>().state;
                                  if (authState is AuthAuthenticated &&
                                      authState.selectedProfile != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => GlucoseHistoryScreen(
                                              patientId: authState
                                                  .selectedProfile!.id)),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.vaccines,
                                    color: Colors.orange),
                                tooltip: 'Historial Insulina',
                                onPressed: () {
                                  final authState =
                                      context.read<AuthBloc>().state;
                                  if (authState is AuthAuthenticated &&
                                      authState.selectedProfile != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider.value(
                                          value: context.read<NutritionBloc>(),
                                          child: MealHistoryScreen(
                                            patientId: authState
                                                .selectedProfile!.id,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                            child: Text('mg/dL'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (timeCmd.isNotEmpty)
                        Text(timeCmd,
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Tendencia (24h)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          // Gráfico de Glucosa con marcadores de insulina superpuestos
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<GlucoseBloc, GlucoseState>(
                  builder: (context, state) {
                    if (state is GlucoseLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is GlucoseLoaded) {
                      final authState = context.read<AuthBloc>().state;
                      int? min;
                      int? max;
                      if (authState is AuthAuthenticated &&
                          authState.selectedProfile != null) {
                        min = authState.selectedProfile!.targetRangeLow;
                        max = authState.selectedProfile!.targetRangeHigh;
                      }

                      return GlucoseChart(
                        history: state.history,
                        targetMin: min,
                        targetMax: max,
                        // Pass cached insulin events — these survive
                        // NutritionBloc state transitions
                        insulinEvents: insulinEvents,
                      );
                    } else if (state is GlucoseError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const Center(child: Text('Sin datos recientes'));
                  },
                ),
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
            const GlucoseAlertWidget(),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Color(0xFFEC4899),
                  child: Icon(Icons.face, size: 80, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Text(
                      'NVL 5',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '¡Hola, Campeón!',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 32),
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
                      Text('Experiencia',
                          style: Theme.of(context).textTheme.labelLarge),
                      Text('450 / 500 XP',
                          style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.9,
                      minHeight: 20,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981)),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated &&
                      authState.selectedProfile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<NutritionBloc>(),
                          child: MealHistoryScreen(
                            patientId: authState.selectedProfile!.id,
                          ),
                        ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.vaccines, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'MIS DOSIS',
                      style: TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
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
