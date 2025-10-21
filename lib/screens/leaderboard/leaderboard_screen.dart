import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/leaderboard_tile.dart';
import '../../config/theme.dart';
import '../../core/constants/app_constants.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedPeriod = AppConstants.periodAllTime;

  @override
  void initState() {
    super.initState();
    // Load leaderboard when screen is first created
    Future.microtask(() {
      context.read<LeaderboardProvider>().loadGlobalLeaderboard(limit: 100);
    });
  }

  Future<void> _refreshLeaderboard() async {
    await context.read<LeaderboardProvider>().loadGlobalLeaderboard(
      limit: 100,
      forceRefresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with gradient
          _buildHeader(),

          // Period filter tabs
          _buildPeriodTabs(),

          // Leaderboard list
          Expanded(child: _buildLeaderboardList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🏆 Leaderboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'See how you rank against other players',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPeriodTab(AppConstants.periodAllTime, '🌟 All Time'),
          _buildPeriodTab(AppConstants.periodThisWeek, '📅 This Week'),
          _buildPeriodTab(AppConstants.periodThisMonth, '📆 This Month'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(String period, String label) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
        // Period filtering to be implemented in future update
        // For now, always shows all-time rankings
        _refreshLeaderboard();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppTheme.textSecondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUserId = authProvider.currentUser?.uid;

    if (leaderboardProvider.isLoadingGlobal) {
      return const Center(child: CircularProgressIndicator());
    }

    if (leaderboardProvider.globalError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              leaderboardProvider.globalError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshLeaderboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final users = leaderboardProvider.globalLeaderboard;

    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No rankings yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to complete a quiz!',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: users.length + 1, // +1 for podium
        itemBuilder: (context, index) {
          if (index == 0) {
            // Show podium for top 3
            if (users.length >= 3) {
              return _buildPodium(users.take(3).toList(), currentUserId);
            } else if (users.isNotEmpty) {
              // Show simplified podium for less than 3 users
              return _buildSimplifiedPodium(users, currentUserId);
            }
            return const SizedBox.shrink();
          }

          final actualIndex = index - 1;

          // Skip users already shown in podium
          if (actualIndex < 3 && users.length >= 3) {
            return const SizedBox.shrink();
          }

          final user = users[actualIndex];
          final rank = actualIndex + 1;

          return LeaderboardTile(
            rank: rank,
            user: user,
            isCurrentUser: user.uid == currentUserId,
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<UserModel> topThree, String? currentUserId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Top 3 Champions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              if (topThree.length > 1)
                _buildPodiumPosition(
                  topThree[1],
                  2,
                  100,
                  const Color(0xFFC0C0C0),
                  currentUserId,
                ),
              const SizedBox(width: 8),
              // 1st place
              _buildPodiumPosition(
                topThree[0],
                1,
                130,
                const Color(0xFFFFD700),
                currentUserId,
              ),
              const SizedBox(width: 8),
              // 3rd place
              if (topThree.length > 2)
                _buildPodiumPosition(
                  topThree[2],
                  3,
                  80,
                  const Color(0xFFCD7F32),
                  currentUserId,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedPodium(List<UserModel> users, String? currentUserId) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Current Leaders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...users.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final user = entry.value;
            Color badgeColor;
            if (rank == 1)
              badgeColor = const Color(0xFFFFD700);
            else if (rank == 2)
              badgeColor = const Color(0xFFC0C0C0);
            else
              badgeColor = const Color(0xFFCD7F32);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSimplePodiumEntry(
                user,
                rank,
                badgeColor,
                currentUserId,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSimplePodiumEntry(
    UserModel user,
    int rank,
    Color badgeColor,
    String? currentUserId,
  ) {
    final isCurrentUser = user.uid == currentUserId;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.primaryColor.withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundImage: user.profilePictureUrl != null
                ? NetworkImage(user.profilePictureUrl!)
                : null,
            child: user.profilePictureUrl == null
                ? Text(user.username[0].toUpperCase())
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.fullName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '${user.totalPoints} pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(
    UserModel user,
    int rank,
    double height,
    Color medalColor,
    String? currentUserId,
  ) {
    final isCurrentUser = user.uid == currentUserId;
    String medal;
    if (rank == 1)
      medal = '🥇';
    else if (rank == 2)
      medal = '🥈';
    else
      medal = '🥉';

    return Column(
      children: [
        // Profile picture with medal
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: medalColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 36 : 32,
                backgroundColor: Colors.white,
                backgroundImage: user.profilePictureUrl != null
                    ? NetworkImage(user.profilePictureUrl!)
                    : null,
                child: user.profilePictureUrl == null
                    ? Text(
                        user.username[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: rank == 1 ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      )
                    : null,
              ),
            ),
            Positioned(
              top: -5,
              right: -5,
              child: Text(
                medal,
                style: TextStyle(fontSize: rank == 1 ? 28 : 24),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Username
        SizedBox(
          width: 80,
          child: Text(
            user.fullName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCurrentUser
                  ? AppTheme.primaryColor
                  : AppTheme.textPrimaryColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Points
        Text(
          '${user.totalPoints}',
          style: TextStyle(
            fontSize: rank == 1 ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: medalColor,
          ),
        ),
        const Text(
          'points',
          style: TextStyle(fontSize: 10, color: AppTheme.textSecondaryColor),
        ),
        const SizedBox(height: 8),
        // Podium base
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [medalColor.withOpacity(0.7), medalColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            border: Border.all(color: medalColor, width: 2),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
