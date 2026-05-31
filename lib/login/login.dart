import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travelr/login/auth_service.dart';
import 'package:travelr/login/create_profile.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool _isSignUp = false;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleSignUp() {
    setState(() {
      _isSignUp = !_isSignUp; // Toggle between Sign-In and Sign-Up
      //_emailController.text = "";
      //_passwordController.text = "";
      _confirmPasswordController.text = "";
    });
  }

  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      //print("Email: $email, Password: $password");
      if (_isSignUp) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext newContext) =>
                CreateProfileScreen(email: email, password: password),
          ),
        );
      } else {
        await AuthService()
            .signIn(email: email, password: password, context: context);
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Password must contain at least one uppercase letter";
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Password must contain at least one lowercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must contain at least one digit";
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password must contain at least one special character";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Confirm password is required";
    }
    if (value != password) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      // Change to match your app background
      //systemNavigationBarIconBrightness: Brightness.dark, // Change icon color if needed
    ));

    return Scaffold(
      appBar: AppBar(
        title: Column(children: [
          const SizedBox(height: 16),
          Text(
            "travelr",
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ]),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelText(),
                const SizedBox(height: 8),
                _emailField(),
                const SizedBox(height: 8),
                _passwordField(),
                _confirmPasswordField(),
                const SizedBox(height: 8),
                _btnConfirm(),
                Row(
                  children: [
                    Text(
                      _isSignUp
                          ? "Already have an account?"
                          : "Don't have an account?",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    _toggleBtn()
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextFormField _emailField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      cursorColor: colorScheme.primary,
      controller: _emailController,
      validator: _validateEmail,
      decoration: const InputDecoration(
        hintText: "Email-ID",
      ),
    );
  }

  TextButton _toggleBtn() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextButton(
      onPressed: _toggleSignUp,
      style: ButtonStyle(
          overlayColor: WidgetStatePropertyAll(
            colorScheme.primary.withValues(alpha: 0.08),
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.only(left: 8))),
      child: Text(
        _isSignUp ? "Sign-In" : "Sign-Up",
        style: textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  TextButton _btnConfirm() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextButton(
      onPressed: _signIn,
      style: ButtonStyle(
        fixedSize: const WidgetStatePropertyAll(Size(double.infinity, 48)),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
        shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
      child: Center(
        child: Text(
          _isSignUp ? "Continue" : "Sign-In",
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  AnimatedContainer _confirmPasswordField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSignUp ? 64 : 0,
      curve: Curves.easeInOut,
      child: _isSignUp
          ? Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormField(
                cursorColor: Theme.of(context).colorScheme.primary,
                controller: _confirmPasswordController,
                validator: (value) =>
                    _validateConfirmPassword(value, _passwordController.text),
                obscureText: _obscureText,
                decoration: const InputDecoration(
                  hintText: "Confirm Password",
                ),
              ),
            )
          : null,
    );
  }

  TextFormField _passwordField() {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      cursorColor: colorScheme.primary,
      controller: _passwordController,
      validator: _validatePassword,
      obscureText: _obscureText,
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: Icon(
              _obscureText
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _toggleVisibility,
          ),
        ),
        hintText: "Password",
      ),
    );
  }

  Text _labelText() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      _isSignUp ? "Sign-Up" : "Sign-In",
      style: textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
