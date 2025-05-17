import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:targets_cgpa/menue/policy.dart';
import 'web_page.dart';
import 'package:targets_cgpa/menue/aboutpage.dart';
import 'package:targets_cgpa/menue/settings_page.dart';
import 'individual_semester.dart';
import 'current_target_cgpa.dart';
import 'achieving_target_cgpa.dart';
import 'history_screen.dart';
import 'package:targets_cgpa/menue/contact.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _storage = FlutterSecureStorage();
  final List<Map<String, String>> imageList = [
    {'path': 'images/islamabad-campus.jpg', 'label': 'Islamabad Campus', 'url': 'https://islamabad.comsats.edu.pk/'},
    {'path': 'images/attock-campus.jpg', 'label': 'Attock Campus', 'url': 'https://attock.comsats.edu.pk/'},
    {'path': 'images/abotta.jpg', 'label': 'Abbottabad Campus', 'url': 'https://www.cuiatd.edu.pk/'},
    {'path': 'images/lhr.png', 'label': 'Lahore Campus', 'url': 'https://lahore.comsats.edu.pk/default.aspx'},
    {'path': 'images/sahiwal_n.png', 'label': 'Sahiwal Campus', 'url': 'https://sahiwal.comsats.edu.pk/'},
    {'path': 'images/wah.png', 'label': 'Wah Campus', 'url': 'https://cuiwah.edu.pk/'},
    {'path': 'images/vehari.png', 'label': 'Vehari Campus', 'url': 'https://vehari.comsats.edu.pk/'},
    {'path': 'images/virtual--.png', 'label': 'Virtual Campus', 'url': 'https://vcomsats.edu.pk/aboutus'},
  ];

  int _currentIndex = 0;
  bool _isDarkMode = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (var image in imageList) {
      precacheImage(AssetImage(image['path']!), context);
    }
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }
  static const Color _lightModeErrorBg = Colors.black45; // Soft red background
  static const Color _lightModeErrorText = Colors.white; // Deep red text
  static const Color _darkModeErrorBg = Colors.white30;  // Dark red background
  static const Color _darkModeErrorText = Colors.black; // Light red text

  OverlayEntry? _overlayEntry;

  void _showFieldOverlay({
    required String message,
    required GlobalKey fieldKey,
    Duration duration = const Duration(seconds: 2),
  }) {
    _overlayEntry?.remove();
    final RenderBox? renderBox = fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 40, // Position above the field
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _isDarkMode ? _darkModeErrorBg : _lightModeErrorBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              message,
              style: TextStyle(
                color: _isDarkMode ? _darkModeErrorText : _lightModeErrorText,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }
  Future<bool?> _showSetPasswordDialog(BuildContext context) async {
    final pinControllers = List.generate(4, (_) => TextEditingController());
    final confirmPinControllers = List.generate(4, (_) => TextEditingController());

    final GlobalKey pinKey = GlobalKey();
    final GlobalKey confirmPinKey = GlobalKey();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Set 4-Digit PIN',
          style: TextStyle(
            color: _isDarkMode ? Colors.amberAccent : Colors.blue.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter a 4-digit PIN to secure your history.',
              style: TextStyle(color: _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
            ),
            SizedBox(height: 20),
            Row(
              key: pinKey,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: pinControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    obscureText: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '_',
                      hintStyle: TextStyle(color: _isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _isDarkMode ? Colors.amberAccent : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _isDarkMode ? Colors.amberAccent : Colors.blue.shade600),
                      ),
                      filled: true,
                      fillColor: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            Text(
              'Confirm your PIN by entering it again.',
              style: TextStyle(color: _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
            ),
            SizedBox(height: 20),
            Row(
              key: confirmPinKey,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: confirmPinControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    obscureText: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '_',
                      hintStyle: TextStyle(color: _isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _isDarkMode ? Colors.amberAccent : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _isDarkMode ? Colors.amberAccent : Colors.blue.shade600),
                      ),
                      filled: true,
                      fillColor: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: _isDarkMode ? Colors.amberAccent : Colors.grey.shade700),
            ),
          ),
          TextButton(
            onPressed: () {
              final pin = pinControllers.map((c) => c.text).join();
              final confirmPin = confirmPinControllers.map((c) => c.text).join();

              if (pin.length != 4 || confirmPin.length != 4) {
                _showFieldOverlay(
                  message: 'Please enter a 4-digit PIN',
                  fieldKey: pinKey,
                );
              } else if (pin == confirmPin) {
                _storage.write(key: 'history_password', value: pin);
                Navigator.pop(context, true);
              } else {
                _showFieldOverlay(
                  message: 'PINs do not match',
                  fieldKey: confirmPinKey,
                );
              }
            },
            child: Text(
              'Set',
              style: TextStyle(
                color: _isDarkMode ? Colors.amberAccent : Colors.blue.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PIN set successfully!',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: _isDarkMode ? Colors.amber.shade600 : Colors.blue.shade600,
          duration: Duration(seconds: 2),
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
    }

    return result;
  }

  Future<bool> _showPasswordDialog(BuildContext context) async {
    final pinControllers = List.generate(4, (_) => TextEditingController());
    final storedPassword = await _storage.read(key: 'history_password');

    final GlobalKey pinKey = GlobalKey();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Enter Your 4-Digit PIN',
          style: TextStyle(
            color: _isDarkMode ? Colors.amberAccent : Colors.blue.shade900,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _isDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your PIN to access history.',
              style: TextStyle(color: _isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
            ),
            SizedBox(height: 20),
            Row(
              key: pinKey,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: pinControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    obscureText: true,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '_',
                      hintStyle: TextStyle(color: _isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _isDarkMode ? Colors.amberAccent : Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: _isDarkMode ? Colors.amberAccent : Colors.blue.shade600),
                      ),
                      filled: true,
                      fillColor: _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade100,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: _isDarkMode ? Colors.grey.shade100 : Colors.grey.shade700),
            ),
          ),
          TextButton(
            onPressed: () {
              final enteredPin = pinControllers.map((c) => c.text).join();
              if (enteredPin.length != 4) {
                _showFieldOverlay(
                  message: 'Please enter a 4-digit PIN',
                  fieldKey: pinKey,
                );
              } else if (enteredPin == storedPassword) {
                Navigator.pop(context, true);
              } else {
                _showFieldOverlay(
                  message: 'Incorrect PIN',
                  fieldKey: pinKey,
                );
              }
            },
            child: Text(
              'Submit',
              style: TextStyle(
                color: _isDarkMode ? Colors.amberAccent : Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PIN verified successfully!',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          backgroundColor: _isDarkMode ? Colors.amber.shade600 : Colors.blue.shade600,
          duration: Duration(seconds: 2),
          action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
        ),
      );
    }

    return result;
  }
  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _handleSecureHistoryTap() async {
    final storedPassword = await _storage.read(key: 'history_password');

    if (storedPassword == null) {
      if (!mounted) return;
      final success = await _showSetPasswordDialog(context);
      if (success == true) {
        _navigateToHistoryScreen();
      }
    } else {
      if (!mounted) return;
      final isAuthenticated = await _showPasswordDialog(context);
      if (isAuthenticated) {
        _navigateToHistoryScreen();
      }
    }
  }

  void _navigateToHistoryScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => HistoryScreen(isDarkMode: _isDarkMode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final backgroundColor = _isDarkMode ? Colors.grey.shade900 : Colors.white;
    final appBarColor = _isDarkMode ? Colors.grey.shade800 : Colors.white;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    // final buttonColor = _isDarkMode ? Colors.grey.shade700 : Colors.blue.shade600;
    final iconColor = _isDarkMode ? Colors.amber : Colors.black87;


    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Center(
          child: Text(
            'Target CGPA',
            style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [appBarColor, _isDarkMode ? Colors.grey.shade700 : Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: iconColor),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.lightbulb : Icons.lightbulb_outline,
              color: iconColor,
            ),
            onPressed: () {
              // Add a delay of 300 milliseconds (or any desired duration)
              Future.delayed(Duration(milliseconds: 500), () {
                _toggleDarkMode(); // Call the function after the delay
              });
            },
          ),
        ],
        elevation: _isDarkMode ? 0 : 2,
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, _isDarkMode ? Colors.grey.shade800 : Colors.white],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 5),
            Text(
              "COMSATS University Islamabad",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            Text(
              "Vehari Campus",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor.withValues(alpha: 0.8)),
            ),
            SizedBox(height: 8),
            Text(
              "Plan. Track. Succeed.",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: _isDarkMode ? Colors.amberAccent.withAlpha(204) : Colors.grey.shade600.withAlpha(204),
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: _isDarkMode ? Colors.amberAccent.withAlpha(76) : Colors.grey.shade300,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            CarouselSlider(
              options: CarouselOptions(
                height: 220.0,
                autoPlay: true,
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 100),
                viewportFraction: 0.85,
                enlargeFactor: 0.3,
                autoPlayCurve: Curves.fastOutSlowIn,
                onPageChanged: (index, reason) {
                  setState(() => _currentIndex = index);
                },
              ),
              items: imageList.map((image) => _buildCarouselItem(image)).toList(),
            ),
            SizedBox(height: 8),
            AnimatedSmoothIndicator(
              activeIndex: _currentIndex,
              count: imageList.length,
              effect: ExpandingDotsEffect(
                activeDotColor: _isDarkMode ? Colors.amber : Colors.blue.shade600,
                dotColor: Colors.grey.shade400,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tap to Explore Campuses",
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: _isDarkMode ? Colors.amberAccent.withAlpha(179) : Colors.grey.shade600.withAlpha(179),
              ),
            ),
            SizedBox(height: 14),
            Expanded(  // Added Expanded to allow SingleChildScrollView to take available space
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "All Calculators:",
                      style: TextStyle(
                        color: _isDarkMode ? Colors.blue : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(  // Added Expanded to allow SingleChildScrollView to take available space
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildNavigationContainer(
                              context,
                              'Individual Semester GPA',
                              Icons.calculate,
                              _isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                              IndividualSemesterScreen(isDarkMode: _isDarkMode),
                            ),
                            SizedBox(height: 16),
                            _buildNavigationContainer(
                              context,
                              'Achieving Target CGPA',
                              Icons.trending_up,
                              _isDarkMode ? Colors.grey.shade700 : Colors.blue.shade100,
                              AchievingTargetCGPAScreen(isDarkMode: _isDarkMode),
                            ),
                            SizedBox(height: 16),
                            _buildNavigationContainer(
                              context,
                              'Current & Target CGPA',
                              Icons.timeline,
                              _isDarkMode ? Colors.grey.shade700 : Colors.green.shade100,
                              CurrentTargetCGPAScreen(isDarkMode: _isDarkMode),
                            ),
                            SizedBox(height: 16),
                            _buildNavigationContainer(
                              context,
                              'Secure  History',
                              Icons.history,
                              _isDarkMode ? Colors.grey.shade700 : Colors.orange.shade100,
                              null,
                              onTapOverride: _handleSecureHistoryTap,
                            ),
                          ],
                        ),
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
  }

  Widget _buildCarouselItem(Map<String, String> image) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) => WebPage(image['url']!),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final slideAnimation = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero).animate(animation);
              return FadeTransition(opacity: animation, child: SlideTransition(position: slideAnimation, child: child));
            },
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 220.0,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(image['path']!, fit: BoxFit.cover, height: 220.0, width: double.infinity),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                    gradient: LinearGradient(colors: [Colors.black12, Colors.black87], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    image['label']!,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1))]),
                  ),
                ),
              ),
              Positioned(bottom: 10, right: 10, child: Icon(Icons.open_in_new, color: Colors.white.withAlpha(204), size: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final ScrollController _scrollController = ScrollController();
    double _indicatorPosition = 0.0;

    _scrollController.addListener(() {
      setState(() {
        _indicatorPosition = _scrollController.offset / 2;
        if (_indicatorPosition < 0) _indicatorPosition = 0;
        if (_indicatorPosition > 100) _indicatorPosition = 100;
      });
    });

    final backgroundGradient = _isDarkMode
        ? LinearGradient(colors: [Colors.grey.shade900, Colors.grey.shade800], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : LinearGradient(colors: [Colors.white, Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight);
    final headerGradient = _isDarkMode
        ? LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight);
    final textColor = _isDarkMode ? Colors.white : Colors.black87;
    final iconColor = _isDarkMode ? Colors.amberAccent : Colors.blue.shade600;
    final dividerColor = _isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300;
    final indicatorGradient = _isDarkMode
        ? LinearGradient(colors: [Colors.amberAccent, Colors.orangeAccent], begin: Alignment.topCenter, end: Alignment.bottomCenter)
        : LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade500], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    final hoverColor = _isDarkMode ? Colors.grey.shade700 : Colors.blue.shade50.withAlpha(51);
    final subTextColor = _isDarkMode ? Colors.grey.shade300 : Colors.white;


    return SizedBox(
      width: 250,
      child: Drawer(
        child: Stack(
          children: [
            Container(decoration: BoxDecoration(gradient: backgroundGradient)),
            ListView(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: headerGradient,
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 8, offset: Offset(0, 4))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: _isDarkMode ? Colors.amberAccent.withAlpha(128) : Colors.blue.shade200, offset: Offset(1, 1), blurRadius: 2)],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Target CGPA', style: TextStyle(color: subTextColor, fontSize: 16, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                _buildDrawerItem(context, Icons.info, 'About', AboutPage(isDarkMode: _isDarkMode), textColor, iconColor, hoverColor),
                Divider(color: dividerColor, thickness: 1, indent: 16, endIndent: 16),
                _buildDrawerItem(context, Icons.settings, 'Settings', SettingsPage(isDarkMode: _isDarkMode), textColor, iconColor, hoverColor),
                Divider(color: dividerColor, thickness: 1, indent: 16, endIndent: 16),
                _buildDrawerItem(context, Icons.contact_mail, 'Contact', ContactPage(isDarkMode: _isDarkMode), textColor, iconColor, hoverColor),
                Divider(color: dividerColor, thickness: 1, indent: 16, endIndent: 16),
                _buildDrawerItem(context, Icons.policy, 'Policy', PolicyScreen(isDarkMode: _isDarkMode), textColor, iconColor, hoverColor),
              ],
            ),
            Positioned(
              left: 0,
              top: 150 + _indicatorPosition,
              child: Container(width: 4, height: 50, decoration: BoxDecoration(gradient: indicatorGradient)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget destination, Color textColor, Color iconColor, Color hoverColor) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 28),
      title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor)),
      tileColor: Colors.transparent,
      hoverColor: hoverColor,
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) => destination,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNavigationContainer(BuildContext context, String text, IconData icon, Color color, Widget? page, {VoidCallback? onTapOverride}) {
    final darkModeIconColors = {
      Icons.calculate: Colors.lightBlueAccent,
      Icons.trending_up: Colors.pinkAccent,
      Icons.timeline: Colors.lightGreenAccent,
      Icons.history: Colors.orangeAccent,
    };
    final lightModeIconColors = {
      Icons.calculate: Colors.blue.shade700,
      Icons.trending_up: Colors.purple.shade700,
      Icons.timeline: Colors.green.shade700,
      Icons.history: Colors.orange.shade700,
    };
    final iconColor = _isDarkMode ? darkModeIconColors[icon] ?? Colors.white : lightModeIconColors[icon] ?? Colors.black87;
    final textColor = _isDarkMode ? Colors.white : Colors.black87;

    return Container(
      width: double.infinity, // Full width
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: GestureDetector(
        onTap: onTapOverride ?? () {
          if (page != null) {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(position: Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset.zero).animate(animation), child: child);
                },
              ),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}