import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  String userEmail = '';
  String userPass = '';

  void submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print(userEmail);
      print(userPass);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
                  height: 500,
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
                          const SizedBox(height: 28),
                          Text(
                            'L O G I N',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge!.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 28),
                          TextFormField(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
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
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
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
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: submit,
                              child: const Text('Login'),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "I don't have an account",
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
    );
  }
}
