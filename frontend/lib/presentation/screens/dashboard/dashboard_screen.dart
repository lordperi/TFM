import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../screens/nutrition/food_search_screen.dart';
import '../../screens/nutrition/meal_history_screen.dart';
import '../../screens/nutrition/nutrition_hub_screen.dart';
import '../profile/profile_screen.dart';
import '../../bloc/glucose/glucose_bloc.dart';
import '../../bloc/nutrition/nutrition_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../../data/repositories/profile_repository.dart';
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
                : BlocProvider(
                    create: (ctx) {
                      final auth = ctx.read<AuthBloc>().state;
                      final bloc =
                          ProfileBloc(repository: ProfileRepository());
                      if (auth is AuthAuthenticated) {
                        bloc.add(LoadProfile(auth.accessToken));
                        bloc.add(LoadXPSummary(auth.accessToken));
                      }
                      return bloc;
                    },
                    child: const _ChildDashboard(),
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
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<NutritionBloc>(),
                        child: const NutritionHubScreen(),
                      ),
                    ),
                  );
                } else if (index == 2) {
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
                                icon: const Icon(Icons.add_circle,
                                    color: Colors.orange),
                                tooltip: 'Registrar Dosis de Insulina',
                                onPressed: () {
                                  final authState =
                                      context.read<AuthBloc>().state;
                                  if (authState is AuthAuthenticated &&
                                      authState.selectedProfile != null) {
                                    _showManualInsulinDialog(
                                      context,
                                      authState.selectedProfile!.id,
                                      true,
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

  static String _levelTitle(int level) {
    if (level <= 2) return 'Explorador';
    if (level <= 4) return 'Aventurero';
    if (level <= 6) return 'Guerrero';
    if (level <= 8) return 'Héroe';
    if (level <= 10) return 'Campeón';
    return 'Leyenda';
  }

  void _onLogComida(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NutritionBloc>(),
          child: const NutritionHubScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final childName = (authState is AuthAuthenticated &&
            authState.selectedProfile != null)
        ? authState.selectedProfile!.displayName
        : 'Héroe';

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final xp = profileState is ProfileLoaded ? profileState.xpSummary : null;
        final level = xp?.currentLevel ?? 1;
        final totalXp = xp?.totalXp ?? 0;
        final xpToNext = xp?.xpToNextLevel ?? 100;
        final progress = xp?.progressPercentage.clamp(0.0, 1.0) ?? 0.0;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                const GlucoseAlertWidget(),
                const SizedBox(height: 16),

                // ── Avatar + nivel ──────────────────────────────────────────
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 124,
                      height: 124,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.amber.shade300, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 58,
                        backgroundColor: const Color(0xFFEC4899),
                        child: Text(
                          childName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 52,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                        child: Text(
                          '⭐ NVL $level',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Saludo ─────────────────────────────────────────────────
                Text(
                  '¡Hola, $childName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _levelTitle(level),
                  style: TextStyle(
                    color: Colors.amber.shade300,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // ── Barra XP ───────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('⚡ Experiencia',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text(
                            '$totalXp XP  •  Faltan $xpToNext',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          if (progress > 0)
                            FractionallySizedBox(
                              widthFactor: progress.clamp(0.04, 1.0),
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFBBF24),
                                      Color(0xFFFFD700)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.6),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Botón principal: Registrar Comida ──────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () => _onLogComida(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 6,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🍽️', style: TextStyle(fontSize: 26)),
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('¡REGISTRAR COMIDA!',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15)),
                            Text('Gana XP por cada comida',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Botón: Añadir Dosis ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (authState is AuthAuthenticated &&
                          authState.selectedProfile != null) {
                        _showManualInsulinDialog(
                          context,
                          authState.selectedProfile!.id,
                          false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle),
                        SizedBox(width: 8),
                        Text('AÑADIR DOSIS',
                            style:
                                TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Botón: Mis Dosis ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      if (authState is AuthAuthenticated &&
                          authState.selectedProfile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<NutritionBloc>(),
                              child: MealHistoryScreen(
                                patientId:
                                    authState.selectedProfile!.id,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.vaccines),
                        SizedBox(width: 8),
                        Text('MIS DOSIS',
                            style: TextStyle(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shared dialog helper
// ---------------------------------------------------------------------------
void _showManualInsulinDialog(BuildContext context, String patientId, bool isAdult) {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(children: [
        const Icon(Icons.vaccines, color: Colors.orange),
        const SizedBox(width: 8),
        Text(isAdult ? 'Registrar Dosis' : '¿Cuánta insulina te pusiste?'),
      ]),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Unidades (U)', suffixText: 'U'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () {
            final units = double.tryParse(controller.text);
            if (units != null && units > 0) {
              context.read<NutritionBloc>().add(LogInsulinDose(patientId, units));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dosis registrada')),
              );
            }
          },
          child: const Text('REGISTRAR'),
        ),
      ],
    ),
  );
}
