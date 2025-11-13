import 'package:expense_tracker/screens/auth/auth_service.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final authService = AuthService();

  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  String userFullName = '';
  String userEmail = '';
  String userPass = '';

  void signup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        authService.signupWithEmailAndPassword(
          userEmail,
          userPass,
          userFullName,
        );

        //success snackbar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign up successful')));
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('signup error')));
      }
    }
  }

  void login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await authService.signInWithEmailAndPassword(userEmail, userPass);
        //logic to add user's fullname to user profile db

        //success snackbar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign in successful')));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login error')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,

        body: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight,
            child: Stack(
              children: [
                // White card at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: isLogin ? 500 : 520,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(70),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              isLogin ? 'L O G I N' : 'S I G N U P',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge!.copyWith(fontSize: 24),
                            ),

                            const SizedBox(height: 16),
                            //fullname
                            isLogin
                                ? const SizedBox(height: 16)
                                : TextFormField(
                                    decoration: InputDecoration(
                                      //when not focused
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      //when focused
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey.shade200,
                                      hintText: 'Full name',
                                      prefixIcon: const Icon(
                                        Icons.account_circle,
                                      ),
                                    ),
                                    obscureText: false,
                                    keyboardType: TextInputType.name,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'please enter your full name';
                                      }
                                      return null;
                                    },
                                    onSaved: (newValue) {
                                      userFullName = newValue!;
                                    },
                                  ),
                            const SizedBox(height: 16),

                            TextFormField(
                              decoration: InputDecoration(
                                //when not focused
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                //when focused
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                hintText: 'Email address',
                                prefixIcon: const Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || !value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                userEmail = newValue!;
                              },
                            ),

                            const SizedBox(height: 16),
                            TextFormField(
                              decoration: InputDecoration(
                                //when not focused
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                //when focused
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.password),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                userPass = newValue!;
                              },
                            ),

                            const SizedBox(height: 16),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot Password',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(
                                        color: const Color.fromARGB(
                                          255,
                                          40,
                                          40,
                                          40,
                                        ),
                                      ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 40,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLogin ? login : signup,
                                child: Text(
                                  isLogin ? 'Login' : 'Sign up',
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: Text(
                                isLogin
                                    ? "I don't have an account"
                                    : 'I already have an account',
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .copyWith(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Image completely outside the card, at the top
                Positioned(
                  top: 100,
                  left: MediaQuery.of(context).size.width / 2 - 65,
                  child: Image.asset(
                    'assets/images/auth 2.png',
                    height: 130,
                    width: 130,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
