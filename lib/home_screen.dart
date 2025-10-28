import 'package:flutter/material.dart';
import 'package:mysbp_loyalty_app/utils/constants.dart';

import 'inbox_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: replace with real value from backend/state
  final int _stampsCount = 6;
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
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
}
