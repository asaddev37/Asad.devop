import 'dart:async';
import 'package:flutter/material.dart';
import 'package:targets_cgpa/screens/home.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isImagePrecached = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Timer(Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 1300),
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isImagePrecached) {
      precacheImage(AssetImage('images/cgpa_.png'), context).then((_) {
        setState(() {
          _isImagePrecached = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2, // Subtle shadow for depth
        // Removed title for simplicity (optional: keep if you want branding here)
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _animation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'images/cgpa_.png',
                    height: 160,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              FadeTransition(
                opacity: _animation,
                child: Column(
                  children: [
                    Text(
                      'BS CGPA Calculator',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Made by AK~~37',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Easily calculate and track your CGPA to stay on top of your academics. '
                            'Plan your grades and improve your performance with our smart calculator!',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!), // Refined accent
                strokeWidth: 4,
              ),
              SizedBox(height: 10),
              Text(
                "Loading...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}