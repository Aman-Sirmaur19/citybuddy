import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../helper/api.dart';
import '../../helper/constants.dart';
import '../../models/citizen_model.dart';
import '../../models/organization_model.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_text_field.dart';
import '../tabs/tab_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool obstructPassword = true;
  bool obstructConfirmPassword = true;
  AuthMode _authMode = AuthMode.logIn;
  UserType _userType = UserType.citizen;
  String? _selectedOrganization;
  bool _isUsernameAvailable = false;
  bool _isChecking = false;
  Timer? _debounce;

  final List<String> _organizations = [
    'Municipal Corporation',
    'Municipality',
    'Notified Area Committee',
    'Cantonment Board',
    'Township',
    'Port Trust',
    'Special Purpose Agency',
  ];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _regIdController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      Utils.showErrorSnackBar(context, 'Fill all the fields.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text);
      if (userCredential.user != null && userCredential.user!.emailVerified) {
        await APIs.firestore
            .collection('users')
            .doc(APIs.user.uid)
            .update({'isVerified': true});
        Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (_) => const TabScreen()));
      } else {
        await FirebaseAuth.instance.signOut();
        Utils.showErrorSnackBar(context, 'Email not verified.');
      }
    } on FirebaseAuthException catch (error) {
      var errorMessage = error.toString();
      if (error.toString().contains('invalid-email')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('invalid-credential')) {
        errorMessage = 'Invalid login credentials.';
      }
      Utils.showErrorSnackBar(context, errorMessage);
    } catch (error) {
      Utils.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _signupCitizen() async {
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      Utils.showErrorSnackBar(context, 'Fill all the fields.');
      return;
    }
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      Utils.showErrorSnackBar(context, 'Re-enter same password.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .then((value) async {
        final citizen = CitizenModel(
          id: APIs.user.uid,
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          pushToken: '',
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          imageUrl: '',
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          followers: [],
          following: [],
          isVerified: false,
          postIds: [],
          complaintIds: [],
        );
        await APIs.createUser(citizen, null);
        await FirebaseAuth.instance.currentUser
            ?.sendEmailVerification()
            .then((value) {
          setState(() {
            _authMode = AuthMode.logIn;
          });
          Utils.showSnackBar(context, 'Verification link sent to your email.');
        });
      });
    } on FirebaseAuthException catch (error) {
      var errorMessage = error.toString();
      if (error.toString().contains('email-already-in-use')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('invalid-email')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak (minimum 6 characters).';
      }
      Utils.showErrorSnackBar(context, errorMessage);
    } catch (error) {
      Utils.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _signupOrganization() async {
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty ||
        _selectedOrganization == null ||
        _regIdController.text.trim().isEmpty ||
        _pinCodeController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _districtController.text.trim().isEmpty ||
        _stateController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty) {
      Utils.showErrorSnackBar(context, 'Fill all the fields.');
      return;
    }
    if (!_isUsernameAvailable) {
      Utils.showErrorSnackBar(context,
          'Username "${_usernameController.text.trim()}" isn\'t available.');
      return;
    }
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      Utils.showErrorSnackBar(context, 'Re-enter same password.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text, password: _passwordController.text)
          .then((value) async {
        final organization = OrganizationModel(
          id: APIs.user.uid,
          createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
          pushToken: '',
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          imageUrl: '',
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          followers: [],
          following: [],
          isVerified: false,
          organizationType: _selectedOrganization!,
          registrationId: _regIdController.text.trim(),
          pinCode: _pinCodeController.text.trim(),
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          district: _districtController.text.trim(),
          state: _stateController.text.trim(),
          country: _countryController.text.trim(),
          docLink: '',
          isDocVerified: false,
          postIds: [],
          complaintIds: [],
        );
        await APIs.createUser(null, organization);
        await FirebaseAuth.instance.currentUser
            ?.sendEmailVerification()
            .then((value) {
          setState(() {
            _authMode = AuthMode.logIn;
          });
          Utils.showSnackBar(context, 'Verification link sent to your email.');
        });
      });
    } on FirebaseAuthException catch (error) {
      var errorMessage = error.toString();
      if (error.toString().contains('email-already-in-use')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('invalid-email')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak (minimum 6 characters).';
      }
      Utils.showErrorSnackBar(context, errorMessage);
    } catch (error) {
      Utils.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      Utils.showErrorSnackBar(context, 'Enter your email.');
      return;
    }
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim())
          .then((value) => Utils.showSnackBar(
              context, 'Password reset link sent to your email.'));
    } on FirebaseAuthException catch (error) {
      Utils.showErrorSnackBar(context, error.toString());
    } catch (error) {
      Utils.showErrorSnackBar(context, error.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.removeListener(_onUsernameChanged);
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _regIdController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _debounce?.cancel();
  }

  void _onUsernameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkUsernameAvailability(_usernameController.text.trim());
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty) return;

    setState(() {
      _isChecking = true;
    });

    final query = await APIs.firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    setState(() {
      _isUsernameAvailable = query.docs.isEmpty;
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: _authMode == AuthMode.signUp ? 80 : 180),
            children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                // Optional: Avoids background color issues
                child: ClipOval(
                  child: Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/images/logo_dark.png'
                        : 'assets/images/logo_light.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain, // Ensures full visibility
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _authMode == AuthMode.logIn
                    ? 'Login Here'
                    : _authMode == AuthMode.signUp
                        ? 'Register Here'
                        : _authMode == AuthMode.reset
                            ? 'Reset Password'
                            : 'College Registration',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              Text(
                _authMode == AuthMode.logIn
                    ? 'Login with your email-id & password'
                    : _authMode == AuthMode.signUp
                        ? 'Following details are necessary for registration'
                        : _authMode == AuthMode.reset
                            ? 'Enter your registered email to get password reset link'
                            : 'Enter your college name to request for registration',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (_authMode == AuthMode.signUp)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          onTap: () => setState(() {
                            _userType = UserType.citizen;
                          }),
                          horizontalTitleGap: 0,
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          leading: Radio(
                            activeColor: Colors.deepPurpleAccent,
                            value: UserType.citizen,
                            groupValue: _userType,
                            onChanged: (UserType? val) {
                              setState(() {
                                _userType = val!;
                              });
                            },
                          ),
                          title: const Text(
                            'Citizen',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          onTap: () => setState(() {
                            _userType = UserType.organisation;
                          }),
                          horizontalTitleGap: 0,
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          leading: Radio(
                            activeColor: Colors.deepPurpleAccent,
                            value: UserType.organisation,
                            groupValue: _userType,
                            onChanged: (UserType? val) {
                              setState(() {
                                _userType = val!;
                              });
                            },
                          ),
                          title: const Text(
                            'Organization',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_authMode == AuthMode.signUp) ...[
                const SizedBox(height: 10),
                Text(
                  _userType == UserType.citizen
                      ? 'Enter your name'
                      : 'Enter organisation name',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                CustomTextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  hintText: 'Name',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Enter a unique username',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                CustomTextField(
                  controller: _usernameController,
                  keyboardType: TextInputType.name,
                  hintText: 'username',
                  suffixIcon: _isChecking
                      ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: CircularProgressIndicator(
                              color: Colors.deepPurpleAccent),
                        )
                      : _isUsernameAvailable
                          ? const Icon(Icons.check_circle_outline_rounded,
                              color: Colors.green)
                          : const Icon(Icons.cancel_rounded, color: Colors.red),
                ),
                const SizedBox(height: 20),
                Text(
                  _userType == UserType.citizen
                      ? 'Enter your phone number'
                      : 'Enter organization phone number',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                CustomTextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  hintText: 'Phone no.',
                ),
                const SizedBox(height: 20),
              ],
              Text(
                _userType == UserType.citizen
                    ? 'Enter your email'
                    : 'Enter organization email',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              CustomTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: 'Email',
              ),
              const SizedBox(height: 20),
              if (_authMode != AuthMode.reset) ...[
                const Text(
                  'Enter password',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                CustomTextField(
                  keyboardType: TextInputType.text,
                  controller: _passwordController,
                  obscureText: obstructPassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obstructPassword = !obstructPassword;
                      });
                    },
                    icon: Icon(
                      obstructPassword == false
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                  hintText: 'Password',
                ),
              ],
              if (_authMode == AuthMode.logIn)
                Container(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _authMode = AuthMode.reset;
                      });
                    },
                    child: Text(
                      'Forgot Password ?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                  ),
                ),
              if (_authMode == AuthMode.signUp) ...[
                const SizedBox(height: 20),
                const Text(
                  'Re-enter same password',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                CustomTextField(
                  controller: _confirmPasswordController,
                  keyboardType: TextInputType.text,
                  obscureText: obstructConfirmPassword,
                  hintText: 'Confirm Password',
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obstructConfirmPassword = !obstructConfirmPassword;
                      });
                    },
                    icon: Icon(
                      obstructConfirmPassword == false
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (_userType == UserType.organisation) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Enter organization details:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Choose organization type',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: 'Select an option',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.deepPurpleAccent),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                    value: _selectedOrganization,
                    items: _organizations.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOrganization = newValue;
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.deepPurpleAccent),
                    dropdownColor: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter registration number',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CustomTextField(
                              controller: _regIdController,
                              keyboardType: TextInputType.number,
                              hintText: 'Registration ID',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter Pincode',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CustomTextField(
                              controller: _pinCodeController,
                              keyboardType: TextInputType.number,
                              hintText: 'PINCODE',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter organization address',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomTextField(
                    controller: _addressController,
                    keyboardType: TextInputType.name,
                    hintText: 'Address',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter city name',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CustomTextField(
                              controller: _cityController,
                              keyboardType: TextInputType.name,
                              hintText: 'City',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter district name',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CustomTextField(
                              controller: _districtController,
                              keyboardType: TextInputType.name,
                              hintText: 'District',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter state name',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CustomTextField(
                              controller: _stateController,
                              keyboardType: TextInputType.name,
                              hintText: 'State',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter country name',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            CustomTextField(
                              controller: _countryController,
                              keyboardType: TextInputType.name,
                              hintText: 'Country',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attach organization document proof',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.deepPurpleAccent),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
              ],
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.deepPurpleAccent))
                  : ElevatedButton(
                      onPressed: () => _authMode == AuthMode.logIn
                          ? _login()
                          : _authMode == AuthMode.signUp &&
                                  _userType == UserType.citizen
                              ? _signupCitizen()
                              : _authMode == AuthMode.signUp &&
                                      _userType == UserType.organisation
                                  ? _signupOrganization()
                                  : _resetPassword(),
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 15,
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(_authMode == AuthMode.logIn
                          ? 'Login'
                          : _authMode == AuthMode.signUp
                              ? 'Sign Up'
                              : _authMode == AuthMode.reset
                                  ? 'Send Link'
                                  : 'Request for registration'),
                    ),
              const SizedBox(height: 25),
              Text(
                _authMode == AuthMode.logIn
                    ? 'Don\'t have an account ?'
                    : _authMode == AuthMode.signUp
                        ? 'Already have an account ?'
                        : 'Don\'t want to reset password ?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_authMode == AuthMode.signUp) {
                    setState(() {
                      _authMode = AuthMode.logIn;
                    });
                  } else {
                    setState(() {
                      _authMode = AuthMode.signUp;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '${_authMode == AuthMode.signUp ? 'LOGIN' : 'SIGN-UP'} INSTEAD',
                  style: const TextStyle(
                      color: Colors.deepPurpleAccent,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
