import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../config/admin_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isDarkMode = false;
  int _selectedMenuIndex = 0; // 0: Home, 1: About, 2: Privacy, 3: Login

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  void _onMenuTap(int index) {
    setState(() => _selectedMenuIndex = index);
  }

  void _navigateToLogin() {
    Navigator.of(context)
        .push(_createSlideRoute(const Duration(milliseconds: 400)));
  }

  Route _createSlideRoute(Duration duration) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const _LoginScreenPlaceholder(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  Widget _getBodyWidget() {
    switch (_selectedMenuIndex) {
      case 1:
        return _AboutSection(isDarkMode: _isDarkMode);
      case 2:
        return _PrivacySection(isDarkMode: _isDarkMode);
      case 3:
        return _ContactSection(isDarkMode: _isDarkMode);
      default:
        return _HomeContent(isDarkMode: _isDarkMode, onLogin: _navigateToLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? AdminTheme.darkTheme : AdminTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Smart Complaint System',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              tooltip: 'Toggle Theme',
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Login',
              onPressed: _navigateToLogin,
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_rounded,
                        size: 48, color: theme.colorScheme.onSurface),
                    const SizedBox(height: 8),
                    Text('Smart Complaint System',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: theme.colorScheme.onSurface)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                selected: _selectedMenuIndex == 0,
                onTap: () {
                  Navigator.pop(context);
                  _onMenuTap(0);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                selected: _selectedMenuIndex == 1,
                onTap: () {
                  Navigator.pop(context);
                  _onMenuTap(1);
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy Policy'),
                selected: _selectedMenuIndex == 2,
                onTap: () {
                  Navigator.pop(context);
                  _onMenuTap(2);
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: const Text('Contact'),
                onTap: () {
                  Navigator.pop(context);
                  _onMenuTap(3);
                },
              ),

              // Drawer Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 180),
                    Text(
                      '© 2024 All rights reserved',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Made by AK~~37',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _getBodyWidget(),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onLogin;
  const _HomeContent({required this.isDarkMode, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.blueGrey[800] : Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.verified_user_rounded,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 32),
            // App Title
            Text(
              'Smart Complaint System',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // App Tagline
            Text(
              'A seamless, transparent, and empowering platform for students, faculty, and administration to resolve issues together.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Login Button
            CustomButton(
              text: 'Login',
              width: 200,
              onPressed: onLogin,
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
              borderRadius: 24,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            const SizedBox(height: 32),
            // Footer
            Text(
              '© 2025 Smart Complaint System\nAll rights reserved.',
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final bool isDarkMode;
  const _AboutSection({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gradient header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [
                          theme.colorScheme.surfaceVariant,
                          theme.colorScheme.tertiaryContainer
                        ]
                      : [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.surfaceVariant
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 56,
                    color: isDarkMode
                        ? theme.colorScheme.onTertiaryContainer
                        : theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About the University Complaint System',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? theme.colorScheme.onTertiaryContainer
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A modern platform to empower, connect, and resolve university complaints efficiently and transparently.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode
                          ? theme.colorScheme.onTertiaryContainer
                              .withOpacity(0.9)
                          : theme.colorScheme.onPrimaryContainer
                              .withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Portals Overview with interactivity
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _InteractivePortalCard(
                  icon: Icons.admin_panel_settings,
                  title: 'Admin Portal',
                  description:
                      'Oversees the system, manages users, resolves escalated complaints, and ensures smooth operation.',
                  color: theme.colorScheme.primary,
                  details:
                      'Admins have full access to all data and analytics. They can assign roles, monitor complaint trends, and ensure policy compliance.',
                ),
                _InteractivePortalCard(
                  icon: Icons.school,
                  title: 'Student Portal',
                  description:
                      'Submit complaints, track status, communicate with advisors and HODs, and receive timely updates.',
                  color: Colors.blueAccent,
                  details:
                      'Students can view complaint history, attach evidence, and receive notifications about progress and resolution.',
                ),
                _InteractivePortalCard(
                  icon: Icons.group,
                  title: 'Batch Advisor Portal',
                  description:
                      'Reviews and addresses student complaints at the batch level, provides guidance, and escalates issues.',
                  color: Colors.teal,
                  details:
                      'Batch Advisors can filter complaints by urgency, communicate with students, and escalate unresolved issues to HODs or Admins.',
                ),
                _InteractivePortalCard(
                  icon: Icons.account_balance,
                  title: 'HOD Portal',
                  description:
                      'Manages department-wide complaints, oversees batch advisors, and ensures efficient resolution.',
                  color: Colors.deepPurple,
                  details:
                      'HODs can view analytics for their department, coordinate with batch advisors, and ensure departmental issues are addressed promptly.',
                ),
              ],
            ),
            const SizedBox(height: 36),
            // Benefits Card with animation and color
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(28),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [
                          theme.colorScheme.surfaceVariant,
                          theme.colorScheme.tertiaryContainer
                        ]
                      : [
                          theme.colorScheme.primaryContainer,
                          theme.colorScheme.surfaceVariant
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: isDarkMode
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onPrimaryContainer,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Why is this system useful for universities?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDarkMode
                              ? theme.colorScheme.onTertiaryContainer
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BenefitRow(
                          text: 'Promotes transparency and accountability'),
                      _BenefitRow(text: 'Accelerates complaint resolution'),
                      _BenefitRow(text: 'Empowers students and faculty'),
                      _BenefitRow(
                          text:
                              'Provides actionable analytics for administration'),
                      _BenefitRow(
                          text: 'Fosters a positive campus environment'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InteractivePortalCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String details;
  const _InteractivePortalCard(
      {required this.icon,
      required this.title,
      required this.description,
      required this.color,
      required this.details});

  @override
  State<_InteractivePortalCard> createState() => _InteractivePortalCardState();
}

class _InteractivePortalCardState extends State<_InteractivePortalCard> {
  bool _hovered = false;

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(widget.icon, color: widget.color),
            const SizedBox(width: 8),
            Text(widget.title),
          ],
        ),
        content: Text(widget.details),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.color.withOpacity(0.18)
              : widget.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 40, color: widget.color),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: widget.color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.info_outline),
              label: const Text('Learn More'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                elevation: _hovered ? 4 : 0,
              ),
              onPressed: () => _showDetailsDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final bool isDarkMode;
  const _PrivacySection({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                            theme.colorScheme.surfaceVariant,
                            theme.colorScheme.tertiaryContainer
                          ]
                        : [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.surfaceVariant
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.privacy_tip_rounded,
                      size: 48,
                      color: isDarkMode
                          ? theme.colorScheme.onTertiaryContainer
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Privacy Policy',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your privacy and data security are our top priorities',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? theme.colorScheme.onTertiaryContainer
                                .withOpacity(0.9)
                            : theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Privacy Sections
              _PrivacyCard(
                title: 'Data Collection & Usage',
                icon: Icons.data_usage,
                content:
                    'We collect only essential information required for complaint processing: user profiles, complaint details, and communication records. All data is used solely for system functionality and complaint resolution.',
                theme: theme,
                isDarkMode: isDarkMode,
              ),
              _PrivacyCard(
                title: 'Data Protection',
                icon: Icons.security,
                content:
                    'Your data is protected using industry-standard encryption, secure authentication, and role-based access controls. We implement strict security measures to prevent unauthorized access.',
                theme: theme,
                isDarkMode: isDarkMode,
              ),
              _PrivacyCard(
                title: 'User Rights',
                icon: Icons.person_outline,
                content:
                    'You have the right to access, modify, or delete your personal information. You can also request data export and withdraw consent at any time through your account settings.',
                theme: theme,
                isDarkMode: isDarkMode,
              ),
              _PrivacyCard(
                title: 'System Security',
                icon: Icons.shield,
                content:
                    'Our system employs secure authentication, encrypted data transmission, regular security audits, and compliance with university data protection standards.',
                theme: theme,
                isDarkMode: isDarkMode,
              ),
              _PrivacyCard(
                title: 'Compliance & Standards',
                icon: Icons.verified,
                content:
                    'We comply with university data protection policies, educational privacy regulations, and industry best practices for handling sensitive academic information.',
                theme: theme,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              // Contact Information
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.contact_support,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy Concerns?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'If you have any questions about our privacy practices or data handling, please contact our privacy team:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: privacy@smartcomplaint.com\nPhone: +1234567890',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
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
}

class _PrivacyCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final ThemeData theme;
  final bool isDarkMode;

  const _PrivacyCard({
    required this.title,
    required this.icon,
    required this.content,
    required this.theme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
            isDarkMode ? theme.colorScheme.surface : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder for login screen navigation
class _LoginScreenPlaceholder extends StatelessWidget {
  const _LoginScreenPlaceholder();
  @override
  Widget build(BuildContext context) {
    // Replace with actual LoginScreen navigation in your app
    Future.delayed(Duration.zero, () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
    return const SizedBox.shrink();
  }
}

class _ContactSection extends StatelessWidget {
  final bool isDarkMode;
  const _ContactSection({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                            theme.colorScheme.surfaceVariant,
                            theme.colorScheme.tertiaryContainer
                          ]
                        : [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.surfaceVariant
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.contact_support_rounded,
                      size: 48,
                      color: isDarkMode
                          ? theme.colorScheme.onTertiaryContainer
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Contact Us',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get in touch with our support team for assistance',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? theme.colorScheme.onTertiaryContainer
                                .withOpacity(0.9)
                            : theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Contact Methods
              _ContactCard(
                title: 'Technical Support',
                icon: Icons.engineering,
                description:
                    'For system issues, login problems, and technical assistance',
                email: 'tech-support@smartcomplaint.com',
                phone: '+1234567890',
                responseTime: 'Within 24 hours',
                theme: theme,
                isDarkMode: isDarkMode,
              ),
              _ContactCard(
                title: 'General Inquiries',
                icon: Icons.help_outline,
                description:
                    'For general questions about the complaint system and processes',
                email: 'info@smartcomplaint.com',
                phone: '+1234567891',
                responseTime: 'Within 48 hours',
                theme: theme,
                isDarkMode: isDarkMode,
              ),
              _ContactCard(
                title: 'Privacy & Data',
                icon: Icons.privacy_tip,
                description:
                    'For privacy concerns, data requests, and compliance questions',
                email: 'privacy@smartcomplaint.com',
                phone: '+1234567892',
                responseTime: 'Within 72 hours',
                theme: theme,
                isDarkMode: isDarkMode,
              ),
              _ContactCard(
                title: 'Emergency Support',
                icon: Icons.emergency,
                description: 'For urgent matters requiring immediate attention',
                email: 'emergency@smartcomplaint.com',
                phone: '+1234567893',
                responseTime: 'Within 4 hours',
                theme: theme,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              // Office Hours & Information
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Office Hours & Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.access_time,
                      label: 'Support Hours:',
                      value:
                          'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 2:00 PM',
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.location_on,
                      label: 'Main Office:',
                      value:
                          'University IT Department\nBuilding A, Floor 3\nCampus Address',
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.language,
                      label: 'Website:',
                      value: 'https://smartcomplaint.university.edu',
                      theme: theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Tips for Better Support
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                            theme.colorScheme.secondaryContainer,
                            theme.colorScheme.surface
                          ]
                        : [
                            theme.colorScheme.secondaryContainer,
                            theme.colorScheme.background
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: isDarkMode
                              ? theme.colorScheme.onSecondaryContainer
                              : theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for Better Support',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? theme.colorScheme.onSecondaryContainer
                                : theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TipRow(
                      text:
                          'Include your user ID and role when contacting support',
                      theme: theme,
                      isDarkMode: isDarkMode,
                    ),
                    _TipRow(
                      text:
                          'Provide specific details about your issue or question',
                      theme: theme,
                      isDarkMode: isDarkMode,
                    ),
                    _TipRow(
                      text:
                          'Attach screenshots or error messages if applicable',
                      theme: theme,
                      isDarkMode: isDarkMode,
                    ),
                    _TipRow(
                      text: 'Check our FAQ section before submitting a request',
                      theme: theme,
                      isDarkMode: isDarkMode,
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
}

class _ContactCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final String email;
  final String phone;
  final String responseTime;
  final ThemeData theme;
  final bool isDarkMode;

  const _ContactCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.email,
    required this.phone,
    required this.responseTime,
    required this.theme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          _ContactInfoRow(
            icon: Icons.email,
            label: 'Email:',
            value: email,
            theme: theme,
          ),
          const SizedBox(height: 8),
          _ContactInfoRow(
            icon: Icons.phone,
            label: 'Phone:',
            value: phone,
            theme: theme,
          ),
          const SizedBox(height: 8),
          _ContactInfoRow(
            icon: Icons.schedule,
            label: 'Response Time:',
            value: responseTime,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _ContactInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  final ThemeData theme;
  final bool isDarkMode;

  const _TipRow({
    required this.text,
    required this.theme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: isDarkMode
                ? theme.colorScheme.onSecondaryContainer
                : theme.colorScheme.onSecondaryContainer,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDarkMode
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
