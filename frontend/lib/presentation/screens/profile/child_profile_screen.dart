import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../data/models/profile_models.dart';

class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! ProfileLoaded) {
          return const Center(child: Text('No se pudo cargar el perfil'));
        }

        final xpSummary = state.xpSummary;
        final achievements = state.achievements;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF7C3AED).withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Avatar with Level Badge
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFFEC4899),
                      child: Text(
                        state.user.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          'NI VEL ${xpSummary?.currentLevel ?? 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                Text(
                  '¡Hola, ${state.user.fullName ?? 'Campeón'}!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 32),
                
                // XP Progress Card
                if (xpSummary != null) ...[
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
                            Text(
                              '${xpSummary.totalXp - xpSummary.xpToNextLevel} / ${xpSummary.totalXp - xpSummary.xpToNextLevel + xpSummary.xpToNextLevel} XP',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: xpSummary.progressPercentage,
                            minHeight: 20,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faltan ${xpSummary.xpToNextLevel} XP para nivel ${xpSummary.currentLevel + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Total XP Display
                if (xpSummary != null)
                  Card(
                    color: const Color(0xFF7C3AED).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF59E0B), size: 32),
                          const SizedBox(width: 8),
                          Text(
                            '${xpSummary.totalXp} XP Total',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Recent XP Transactions
                if (xpSummary?.recentTransactions.isNotEmpty ?? false) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Últimas Actividades', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  ...xpSummary!.recentTransactions.take(5).map((transaction) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: transaction.amount > 0 ? Colors.green.shade100 : Colors.red.shade100,
                        child: Icon(
                          transaction.amount > 0 ? Icons.add : Icons.remove,
                          color: transaction.amount > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      title: Text(transaction.description),
                      trailing: Text(
                        '${transaction.amount > 0 ? '+' : ''}${transaction.amount} XP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: transaction.amount > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
                
                // Achievements Section
                if (achievements != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Logros', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(height: 12),
                  
                  // Unlocked Achievements
                  if (achievements.unlocked.isNotEmpty) ...[
                    Text('Desbloqueados (${achievements.unlocked.length})', 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green)
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: achievements.unlocked.map((ua) {
                        final achievement = ua.achievement;
                        if (achievement == null) return const SizedBox.shrink();
                        return _AchievementBadge(achievement: achievement, unlocked: true);
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Locked Achievements
                  if (achievements.locked.isNotEmpty) ...[
                    Text('Por desbloquear (${achievements.locked.length})', 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: achievements.locked.take(6).map((achievement) =>
                        _AchievementBadge(achievement: achievement, unlocked: false)
                      ).toList(),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementBadge({
    required this.achievement,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${achievement.name}\n${achievement.description}\n${achievement.xpReward} XP',
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: unlocked ? Colors.amber.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked ? Colors.amber : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              achievement.icon,
              style: TextStyle(
                fontSize: 32,
                color: unlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              achievement.name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: unlocked ? Colors.black87 : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
