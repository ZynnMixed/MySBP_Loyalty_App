import 'package:flutter/material.dart';
import 'package:mysbp_loyalty_app/utils/constants.dart';

import 'inbox_screen.dart';
import 'maps_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: replace with real value from backend/state
  final int _stampsCount = 6;
  int _currentRewardPage = 0;
  int _currentNavIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int cappedStamps = _stampsCount.clamp(0, 10);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Keeps logo left, button right
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Logo in rounded border box + stamps text
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  'assets/images/silverbrand_logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$cappedStamps/10',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'STAMPS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Right: Notification bell
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const InboxScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_none,
                            size: 28,
                            color: Colors.white,
                          ),
                          tooltip: 'Inbox',
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Stamp Card Widget
                    _buildStampCard(cappedStamps),
                    const SizedBox(height: 30),
                    // Rewards Carousel Section
                    _buildRewardsSection(cappedStamps),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentNavIndex,
        selectedItemColor: const Color(0xFF1565C0), // Dark blue
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });

          // Navigate based on tab index
          if (index == 2) {
            // MAPS tab
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapsScreen()),
            );
          } else {
            // TODO: Navigate to other screens
            print('Tapped on tab: $index');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.print), label: 'HOME'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'REWARDS',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'MAPS'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'MORE'),
        ],
      ),
    );
  }

  Widget _buildStampCard(int filledStamps) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo at top
          Image.asset(
            'assets/images/silverbrand_logo.png',
            height: 60,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          // Title
          const Text(
            'Welcome to MySBP Digital Loyalty Card',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle
          const Text(
            'Tempah dan Terima Ganjaran',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          // Stamp Grid (2 rows x 5 columns)
          Column(
            children: [
              // First row (stamps 1-5)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) => _buildStamp(index + 1, index < filledStamps),
                ),
              ),
              const SizedBox(height: 16),
              // Second row (stamps 6-10)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) => _buildStamp(index + 6, index + 5 < filledStamps),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress text
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              children: [
                const TextSpan(
                  text: 'Your Stamps: ',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                TextSpan(
                  text: '$filledStamps',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const TextSpan(
                  text: ' / 10',
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Motivational message
          Text(
            filledStamps >= 10
                ? 'Congratulations! Redeem your reward!'
                : 'Keep collecting to earn exciting rewards!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: filledStamps >= 10 ? Colors.green[700] : Colors.black54,
              fontWeight: filledStamps >= 10
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStamp(int number, bool isFilled) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isFilled ? const Color(0xFF2196F3) : Colors.grey[300],
        shape: BoxShape.circle,
        boxShadow: isFilled
            ? [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.print,
        color: isFilled ? Colors.white : Colors.grey[600],
        size: 28,
      ),
    );
  }

  Widget _buildRewardsSection(int userStamps) {
    // Hardcoded rewards data
    final List<Map<String, dynamic>> rewards = [
      {
        'title': 'Free Small Coffee',
        'icon': '☕',
        'requiredStamps': 3,
        'description': 'Enjoy a complimentary small coffee on us!',
      },
      {
        'title': 'Free Pastry',
        'icon': '🥐',
        'requiredStamps': 7,
        'description': 'Get any pastry of your choice for free!',
      },
      {
        'title': 'Special Gift',
        'icon': '🎁',
        'requiredStamps': 10,
        'description': 'Unlock an exclusive surprise gift!',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'YOUR REWARDS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Full-screen horizontal carousel
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentRewardPage = index;
              });
            },
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              final isUnlocked = userStamps >= reward['requiredStamps'];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildRewardCard(
                  title: reward['title'],
                  icon: reward['icon'],
                  requiredStamps: reward['requiredStamps'],
                  description: reward['description'],
                  isUnlocked: isUnlocked,
                  userStamps: userStamps,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Page indicators (dots)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            rewards.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentRewardPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentRewardPage == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardCard({
    required String title,
    required String icon,
    required int requiredStamps,
    required String description,
    required bool isUnlocked,
    required int userStamps,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Left side - Reward info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.black87 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Description
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnlocked ? Colors.black54 : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? Colors.green[50]
                              : Colors.orange[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isUnlocked
                                ? Colors.green[300]!
                                : Colors.orange[300]!,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUnlocked ? Icons.check_circle : Icons.lock,
                              size: 16,
                              color: isUnlocked
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isUnlocked
                                  ? 'Unlocked'
                                  : 'Need $requiredStamps stamps',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isUnlocked
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Right side - Claim button (if unlocked)
                if (isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement claim reward functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Claiming $title...'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'CLAIM',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Lock overlay for locked rewards
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
