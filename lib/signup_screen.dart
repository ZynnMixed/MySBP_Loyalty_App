import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mysbp_loyalty_app/utils/constants.dart';

import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  bool _showPin = false;
  bool _showConfirmPin = false;
  bool _isLoading = false;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  // Focus nodes for auto-focus management
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _pinFocus = FocusNode();
  final FocusNode _confirmPinFocus = FocusNode();

  // Validation states
  String? _phoneError;
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _pinError;
  String? _confirmPinError;

  // Touched states (for showing errors only after blur)
  bool _phoneTouched = false;
  bool _firstNameTouched = false;
  bool _lastNameTouched = false;
  bool _emailTouched = false;
  bool _pinTouched = false;
  bool _confirmPinTouched = false;

  // Animation controller for shake effect
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  static const Color _deepBlue = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Add listeners for real-time validation
    _phoneController.addListener(_validatePhone);
    _firstNameController.addListener(_validateFirstName);
    _lastNameController.addListener(_validateLastName);
    _emailController.addListener(_validateEmail);
    _pinController.addListener(_validatePin);
    _confirmPinController.addListener(_validateConfirmPin);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _phoneFocus.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _pinFocus.dispose();
    _confirmPinFocus.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    if (!_phoneTouched) return;
    setState(() {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        _phoneError = 'Phone number is required';
      } else if (phone.length < 9 || phone.length > 10) {
        _phoneError = 'Phone number must be 9-10 digits';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validateFirstName() {
    if (!_firstNameTouched) return;
    setState(() {
      final name = _firstNameController.text.trim();
      if (name.isEmpty) {
        _firstNameError = 'First name is required';
      } else {
        _firstNameError = null;
      }
    });
  }

  void _validateLastName() {
    if (!_lastNameTouched) return;
    setState(() {
      final name = _lastNameController.text.trim();
      if (name.isEmpty) {
        _lastNameError = 'Last name is required';
      } else {
        _lastNameError = null;
      }
    });
  }

  void _validateEmail() {
    if (!_emailTouched) return;
    setState(() {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Valid email is required';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePin() {
    if (!_pinTouched) return;
    setState(() {
      final pin = _pinController.text.trim();
      if (pin.isEmpty) {
        _pinError = '6-digit PIN is required';
      } else if (pin.length != 6) {
        _pinError = 'PIN must be exactly 6 digits';
      } else {
        _pinError = null;
      }
    });
  }

  void _validateConfirmPin() {
    if (!_confirmPinTouched) return;
    setState(() {
      final pin = _pinController.text.trim();
      final confirmPin = _confirmPinController.text.trim();
      if (confirmPin.isEmpty) {
        _confirmPinError = 'Please confirm your PIN';
      } else if (pin != confirmPin) {
        _confirmPinError = 'PINs do not match';
      } else {
        _confirmPinError = null;
      }
    });
  }

  bool get _isFormValid {
    final phone = _phoneController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    return phone.isNotEmpty &&
        phone.length >= 9 &&
        phone.length <= 10 &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email) &&
        password.isNotEmpty &&
        pin.length == 6 &&
        confirmPin == pin;
  }

  OutlineInputBorder _getBorder(String? error, bool touched) {
    if (error != null && touched) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.grey),
    );
  }

  OutlineInputBorder _getFocusedBorder(String? error, bool touched) {
    if (error != null && touched) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      );
    }
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _deepBlue, width: 2),
    );
  }

  Widget _buildSuffixIcon(String? error, String value, bool touched) {
    if (touched && value.isNotEmpty) {
      if (error == null) {
        return const Icon(Icons.check_circle, color: Colors.green);
      } else {
        return const Icon(Icons.error, color: Colors.red);
      }
    }
    return const SizedBox.shrink();
  }

  Future<void> _handleRegister() async {
    // Mark all fields as touched
    setState(() {
      _phoneTouched = true;
      _firstNameTouched = true;
      _lastNameTouched = true;
      _emailTouched = true;
      _pinTouched = true;
      _confirmPinTouched = true;
    });

    // Trigger validation
    _validatePhone();
    _validateFirstName();
    _validateLastName();
    _validateEmail();
    _validatePin();
    _validateConfirmPin();

    // Check if form is valid
    if (!_isFormValid) {
      _shakeController.forward(from: 0);

      // Focus first invalid field
      if (_phoneError != null) {
        _phoneFocus.requestFocus();
      } else if (_firstNameError != null) {
        _firstNameFocus.requestFocus();
      } else if (_lastNameError != null) {
        _lastNameFocus.requestFocus();
      } else if (_emailError != null) {
        _emailFocus.requestFocus();
      } else if (_pinError != null) {
        _pinFocus.requestFocus();
      } else if (_confirmPinError != null) {
        _confirmPinFocus.requestFocus();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final phone = _phoneController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final pin = _pinController.text.trim();

    setState(() => _isLoading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        // Hash the PIN for security
        final pinHash = sha256.convert(utf8.encode(pin)).toString();

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'phone': '+60$phone',
          'firstName': firstName,
          'lastName': lastName,
          'pinHash': pinHash,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text(
              'Your account has been created successfully! Please login with your phone number and PIN.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      if (!mounted) return;
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please login.';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak. Use at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      } else {
        message = e.message ?? 'Registration failed';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.appBarColor,
        elevation: 0,
        title: const Text(
          'Sign up to your account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Constants.appBarTextColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Constants.appBarIconColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Info paragraph
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'We are setting up your profile to unlock the reward on MySBP Loyalty.',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Phone Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: false,
                            decimal: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          onChanged: (_) {
                            if (!_phoneTouched) {
                              setState(() => _phoneTouched = true);
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixText: '+60 ',
                            labelText: 'Phone Number *',
                            border: _getBorder(_phoneError, _phoneTouched),
                            focusedBorder: _getFocusedBorder(
                              _phoneError,
                              _phoneTouched,
                            ),
                            errorText: _phoneTouched ? _phoneError : null,
                            suffixIcon: _buildSuffixIcon(
                              _phoneError,
                              _phoneController.text,
                              _phoneTouched,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(thickness: 1, height: 32),
                      ],
                    ),
                    // Name Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) {
                            if (!_firstNameTouched) {
                              setState(() => _firstNameTouched = true);
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'First Name *',
                            border: _getBorder(
                              _firstNameError,
                              _firstNameTouched,
                            ),
                            focusedBorder: _getFocusedBorder(
                              _firstNameError,
                              _firstNameTouched,
                            ),
                            errorText: _firstNameTouched
                                ? _firstNameError
                                : null,
                            suffixIcon: _buildSuffixIcon(
                              _firstNameError,
                              _firstNameController.text,
                              _firstNameTouched,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _lastNameController,
                          focusNode: _lastNameFocus,
                          textCapitalization: TextCapitalization.words,
                          onChanged: (_) {
                            if (!_lastNameTouched) {
                              setState(() => _lastNameTouched = true);
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Last Name *',
                            border: _getBorder(
                              _lastNameError,
                              _lastNameTouched,
                            ),
                            focusedBorder: _getFocusedBorder(
                              _lastNameError,
                              _lastNameTouched,
                            ),
                            errorText: _lastNameTouched ? _lastNameError : null,
                            suffixIcon: _buildSuffixIcon(
                              _lastNameError,
                              _lastNameController.text,
                              _lastNameTouched,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(thickness: 1, height: 32),
                      ],
                    ),
                    // Email Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) {
                            if (!_emailTouched) {
                              setState(() => _emailTouched = true);
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Email *',
                            border: _getBorder(_emailError, _emailTouched),
                            focusedBorder: _getFocusedBorder(
                              _emailError,
                              _emailTouched,
                            ),
                            errorText: _emailTouched ? _emailError : null,
                            suffixIcon: _buildSuffixIcon(
                              _emailError,
                              _emailController.text,
                              _emailTouched,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(thickness: 1, height: 32),
                      ],
                    ),
                    // Password Section (hidden, but still functional for Firebase Auth)
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Password (for account security)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        '* This password is for account security and recovery purposes only. You will use your PIN to login.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(thickness: 1, height: 32),
                    // PIN Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _pinController,
                          focusNode: _pinFocus,
                          obscureText: !_showPin,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          onChanged: (_) {
                            if (!_pinTouched) {
                              setState(() => _pinTouched = true);
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: '6-Digit PIN *',
                            border: _getBorder(_pinError, _pinTouched),
                            focusedBorder: _getFocusedBorder(
                              _pinError,
                              _pinTouched,
                            ),
                            errorText: _pinTouched ? _pinError : null,
                            counterText: '',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_pinTouched &&
                                    _pinController.text.isNotEmpty)
                                  _pinError == null
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                IconButton(
                                  icon: Icon(
                                    _showPin
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPin = !_showPin;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirmPinController,
                          focusNode: _confirmPinFocus,
                          obscureText: !_showConfirmPin,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          onChanged: (_) {
                            if (!_confirmPinTouched) {
                              setState(() => _confirmPinTouched = true);
                            }
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Confirm PIN *',
                            border: _getBorder(
                              _confirmPinError,
                              _confirmPinTouched,
                            ),
                            focusedBorder: _getFocusedBorder(
                              _confirmPinError,
                              _confirmPinTouched,
                            ),
                            errorText: _confirmPinTouched
                                ? _confirmPinError
                                : null,
                            counterText: '',
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_confirmPinTouched &&
                                    _confirmPinController.text.isNotEmpty)
                                  _confirmPinError == null
                                      ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                        ),
                                IconButton(
                                  icon: Icon(
                                    _showConfirmPin
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showConfirmPin = !_showConfirmPin;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (_pinController.text.isNotEmpty &&
                            _confirmPinController.text.isNotEmpty &&
                            _pinController.text.length == 6)
                          Builder(
                            builder: (context) {
                              final matches =
                                  _pinController.text ==
                                  _confirmPinController.text;
                              return Text(
                                matches
                                    ? '✓ PINs match'
                                    : '✗ PINs do not match',
                                style: TextStyle(
                                  color: matches ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 12),
                        const Divider(thickness: 1, height: 32),
                      ],
                    ),
                    // Register Button
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? const Color(0xFF0F52BA)
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'sans-serif',
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: _isFormValid ? 8 : 0,
                            shadowColor: const Color(0xFF0F52BA).withAlpha(77),
                          ),
                          onPressed: _isLoading || !_isFormValid
                              ? null
                              : _handleRegister,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Register Now'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
