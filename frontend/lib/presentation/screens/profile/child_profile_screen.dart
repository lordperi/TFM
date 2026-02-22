import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/bloc/profile/profile_bloc.dart';
import '../../../presentation/bloc/auth/auth_bloc.dart';
import '../../../data/models/profile_models.dart';

/// Pantalla de perfil para modo niño.
/// Temática: "Héroe de la Salud" — RPG visual con niveles, medallas y misiones.
class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});

  static String _levelTitle(int level) {
    if (level <= 2) return 'Explorador';
    if (level <= 4) return 'Aventurero';
    if (level <= 6) return 'Guerrero';
    if (level <= 8) return 'Héroe';
    if (level <= 10) return 'Campeón';
    return 'Leyenda';
  }

  static String _levelEmoji(int level) {
    if (level <= 2) return '🌱';
    if (level <= 4) return '⚔️';
    if (level <= 6) return '🛡️';
    if (level <= 8) return '🦸';
    if (level <= 10) return '🏆';
    return '🌟';
  }

  static String _motivationalText(int level) {
    if (level <= 2) return '¡Empieza tu aventura!';
    if (level <= 4) return '¡Vas muy bien, sigue así!';
    if (level <= 6) return '¡Eres un verdadero guerrero!';
    if (level <= 8) return '¡Tu salud es tu superpoder!';
    if (level <= 10) return '¡Eres un campeón de la salud!';
    return '¡Eres una leyenda viviente!';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is! ProfileLoaded) {
          return const Center(child: Text('No se pudo cargar el perfil'));
        }

        final xpSummary = state.xpSummary;
        final achievements = state.achievements;

        final authState = context.read<AuthBloc>().state;
        final memberName = (authState is AuthAuthenticated &&
                authState.selectedProfile != null)
            ? authState.selectedProfile!.displayName
            : state.user.fullName ?? 'Campeón';

        final level = xpSummary?.currentLevel ?? 1;

        return SizedBox.expand(
          child: Container(
            color: const Color(0xFF4C1D95),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── HERO BANNER (fondo morado) ────────────────────────
                  _HeroBanner(
                    name: memberName,
                    level: level,
                    levelTitle: _levelTitle(level),
                    levelEmoji: _levelEmoji(level),
                    motivational: _motivationalText(level),
                  ),

                  // ── CONTENIDO SOBRE FONDO CLARO ───────────────────────
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F3FF),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    padding:
                        const EdgeInsets.fromLTRB(16, 24, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (xpSummary != null) ...[
                          _PowerBarCard(xpSummary: xpSummary, level: level),
                          const SizedBox(height: 14),
                          _StatsRow(
                              xpSummary: xpSummary,
                              achievements: achievements),
                          const SizedBox(height: 28),
                        ],
                        if (achievements != null) ...[
                          _AchievementsSection(achievements: achievements),
                          const SizedBox(height: 28),
                        ],
                        if (xpSummary?.recentTransactions.isNotEmpty ??
                            false)
                          _QuestLog(
                              transactions:
                                  xpSummary!.recentTransactions),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── HERO BANNER ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  final String name;
  final int level;
  final String levelTitle;
  final String levelEmoji;
  final String motivational;

  const _HeroBanner({
    required this.name,
    required this.level,
    required this.levelTitle,
    required this.levelEmoji,
    required this.motivational,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
      child: Column(
        children: [
          // Avatar con anillo de brillo + badge
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Anillo exterior (glow dorado)
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber.shade300, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.45),
                      blurRadius: 22,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              // Avatar
              CircleAvatar(
                radius: 58,
                backgroundColor: const Color(0xFFEC4899),
                child: Text(
                  name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 52,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // Badge de nivel
              Positioned(
                bottom: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 8)
                    ],
                  ),
                  child: Text(
                    '⭐ NIVEL $level ⭐',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$levelEmoji  $levelTitle  $levelEmoji',
            style: TextStyle(
              color: Colors.amber.shade300,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            motivational,
            style: TextStyle(
              color: Colors.purple.shade100,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── BARRA DE PODER ────────────────────────────────────────────────────────────

class _PowerBarCard extends StatelessWidget {
  final UserXPSummary xpSummary;
  final int level;

  const _PowerBarCard({required this.xpSummary, required this.level});

  @override
  Widget build(BuildContext context) {
    final progress = xpSummary.progressPercentage.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⚡  Barra de Poder',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Barra con gradiente y brillo
          Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              if (progress > 0)
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.04, 1.0),
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFBBF24), Color(0xFFFFD700)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.7),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '✨  Faltan ${xpSummary.xpToNextLevel} XP para Nivel ${level + 1}',
            style:
                const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── FILA DE ESTADÍSTICAS ──────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final UserXPSummary xpSummary;
  final AchievementsResponse? achievements;

  const _StatsRow({required this.xpSummary, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
            emoji: '⭐',
            value: '${xpSummary.totalXp}',
            label: 'XP Total'),
        const SizedBox(width: 10),
        _StatChip(
            emoji: '🏆',
            value: '${xpSummary.currentLevel}',
            label: 'Nivel'),
        const SizedBox(width: 10),
        _StatChip(
          emoji: '🎖️',
          value: '${achievements?.unlocked.length ?? 0}',
          label: 'Medallas',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const _StatChip(
      {required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900)),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}

// ── SECCIÓN DE MEDALLAS ───────────────────────────────────────────────────────

class _AchievementsSection extends StatelessWidget {
  final AchievementsResponse achievements;

  const _AchievementsSection({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.unlocked.length;
    final totalCount =
        unlockedCount + achievements.locked.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Text('🎖️', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Mis Medallas',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900)),
            ),
            if (totalCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.amber.shade400, width: 1.5),
                ),
                child: Text(
                  '$unlockedCount / $totalCount',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Conseguidas
        if (achievements.unlocked.isNotEmpty) ...[
          _SectionLabel(
              emoji: '✅', text: 'Conseguidas (${achievements.unlocked.length})',
              color: Colors.green.shade600),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemCount: achievements.unlocked.length,
            itemBuilder: (context, i) {
              final ua = achievements.unlocked[i];
              if (ua.achievement == null) return const SizedBox.shrink();
              return _AchievementCard(
                  achievement: ua.achievement!, unlocked: true);
            },
          ),
          const SizedBox(height: 18),
        ],

        // Por conseguir
        if (achievements.locked.isNotEmpty) ...[
          _SectionLabel(
              emoji: '🔒',
              text: 'Por conseguir (${achievements.locked.length})',
              color: Colors.grey.shade500),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemCount: achievements.locked.take(8).length,
            itemBuilder: (context, i) {
              return _AchievementCard(
                achievement: achievements.locked.toList()[i],
                unlocked: false,
              );
            },
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String emoji;
  final String text;
  final Color color;
  const _SectionLabel(
      {required this.emoji, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementCard(
      {required this.achievement, required this.unlocked});

  static Color _categoryColor(String category) {
    switch (category) {
      case 'glucose':
        return const Color(0xFF3B82F6);
      case 'meals':
        return const Color(0xFF10B981);
      case 'consistency':
        return const Color(0xFF8B5CF6);
      case 'social':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        title: Row(
          children: [
            Text(unlocked ? achievement.icon : '❓',
                style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                unlocked ? achievement.name : '???',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unlocked
                  ? achievement.description
                  : '¡Sigue jugando para descubrirla!',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star,
                      color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${achievement.xpReward} XP',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              unlocked
                  ? '🎉 ¡Ya tienes esta medalla!'
                  : '🔒 ¡Sigue así, ya casi la consigues!',
              style: TextStyle(
                  color: unlocked
                      ? Colors.green.shade600
                      : Colors.grey.shade500,
                  fontSize: 13),
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(unlocked ? '¡Genial! 🎉' : '¡A por ella! 💪'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = unlocked
        ? _categoryColor(achievement.category)
        : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => _showDetails(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: unlocked ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unlocked ? color : Colors.grey.shade300,
            width: unlocked ? 2 : 1,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unlocked ? achievement.icon : '❓',
              style: TextStyle(fontSize: unlocked ? 28 : 22),
            ),
            const SizedBox(height: 5),
            Text(
              unlocked ? achievement.name : '???',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: unlocked ? Colors.black87 : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (unlocked) ...[
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 9, color: Colors.amber),
                  Text(
                    ' ${achievement.xpReward}',
                    style: const TextStyle(
                        fontSize: 9,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── LOG DE MISIONES ───────────────────────────────────────────────────────────

class _QuestLog extends StatelessWidget {
  final List<XPTransaction> transactions;

  const _QuestLog({required this.transactions});

  static String _questEmoji(String reason) {
    switch (reason) {
      case 'meal_logged':
        return '🍽️';
      case 'glucose_check':
        return '💉';
      case 'streak':
        return '🔥';
      case 'achievement':
        return '🏆';
      case 'bolus_logged':
        return '⚗️';
      default:
        return '⭐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('⚔️', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Últimas Misiones',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
        const SizedBox(height: 14),
        ...transactions.take(5).map(
          (t) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Text(_questEmoji(t.reason),
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.description,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: t.amount > 0
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: t.amount > 0 ? Colors.green : Colors.red,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    '${t.amount > 0 ? '+' : ''}${t.amount} XP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          t.amount > 0 ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
