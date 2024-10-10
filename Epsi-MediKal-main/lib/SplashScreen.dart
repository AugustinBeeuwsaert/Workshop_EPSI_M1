import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:medzair_app/SignUpScreen.dart';
import 'package:medzair_app/LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BounceInDown(
          duration: Duration(seconds: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                './images/MedikalLogo2.png',
                width: 150,
                height: 150,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void navigateToSignUpScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen(onCancel: () {})),
    );
  }

  void navigateToLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(userType: '')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2F8F9D),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BounceInDown(
                    duration: Duration(seconds: 2),
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 5,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          './images/MedikalLogo2.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  FadeInUp(
                    duration: Duration(milliseconds: 1500),
                    child: ElevatedButton(
                      onPressed: () => navigateToSignUpScreen(context),
                      child: Text('Sign Up', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF2F8F9D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 100.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  FadeInUp(
                    duration: Duration(milliseconds: 1800),
                    child: ElevatedButton(
                      onPressed: () => navigateToLoginScreen(context),
                      child: Text('Login', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF2F8F9D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 100.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 30,
          child: _buildAnimatedCircle(
              Colors.white.withOpacity(0.2), 100, Duration(seconds: 8)),
        ),
        Positioned(
          bottom: 100,
          right: 50,
          child: _buildAnimatedCircle(
              Colors.white.withOpacity(0.15), 150, Duration(seconds: 10)),
        ),
        Positioned(
          bottom: 200,
          left: 80,
          child: _buildAnimatedCircle(
              Colors.white.withOpacity(0.2), 80, Duration(seconds: 12)),
        ),
        Positioned(
          top: 300,
          left: 200,
          child: _buildAnimatedCircle(
              Colors.white.withOpacity(0.25), 120, Duration(seconds: 9)),
        ),
        Positioned(
          top: 400,
          right: 100,
          child: _buildAnimatedCircle(
              Colors.white.withOpacity(0.15), 180, Duration(seconds: 11)),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: _buildAnimatedCircle(
              Colors.white.withOpacity(0.3), 90, Duration(seconds: 15)),
        ),
      ],
    );
  }

  Widget _buildAnimatedCircle(Color color, double size, Duration duration) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    ).animate()
      ..moveY(duration: duration, begin: 60, end: -60)
      ..fade(duration: duration);
  }
}
