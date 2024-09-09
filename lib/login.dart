import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    const begin = 0.0;
    const end = 1.0;
    const curve = Curves.easeInOut;

    var tween = Tween<double>(begin: begin, end: end).chain(CurveTween(curve: curve));

    var fadeAnimation = animation.drive(tween);

    return FadeTransition(opacity: fadeAnimation, child: child);
  }
}

var db = FirebaseFirestore.instance;

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey <FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController new_emailController = TextEditingController();
  final TextEditingController new_passwordController = TextEditingController();
  final TextEditingController _passwordCheck = TextEditingController();
  final TextEditingController _goal = TextEditingController();

  bool login = false;
  bool pass_check = false;
  bool pass = false;
  bool email = false;
  bool value = false;
  
Future<void> _createUser() async {
  // Check for empty fields
  if (new_emailController.text.isEmpty ||
      new_passwordController.text.isEmpty ||
      _passwordCheck.text.isEmpty ||
      _goal.text.isEmpty) {

    email = true;
    pass = true;
    pass_check = true;
    value = true;
    setState(() {});
    // Display an error message or handle the case where fields are empty.
    return;
  }

  // Check for password match
  if (new_passwordController.text != _passwordCheck.text) {
    pass_check = true;
    setState(() {});
    return;
  }

  // Validate email and password format
  // Add more sophisticated validation as needed

  try {
    UserCredential newUser = await _auth.createUserWithEmailAndPassword(
      email: new_emailController.text,
      password: new_passwordController.text,
    );

    print("User signed in: ${newUser.user!.uid}");
    String user = newUser.user!.uid;

    FirebaseFirestore.instance.collection('users').doc(user).set({
      'goal(current)': int.parse(_goal.text),
      'Expense': [],
      'expense(index)': [],
      'expense(value)': [],
      'Income': [],
      'Income(Value)': [],
      'Income(index)': [],
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home(uid: user)),
    );

    new_emailController.clear();
    new_passwordController.clear();
    _passwordCheck.clear();
    _goal.clear();
  } catch (e) {
    print("Failed to sign in: $e");
    // Handle the error, e.g., show a snackbar or display an error message
    email = true;
    pass = true;
    value = true;
    new_emailController.clear();
    new_passwordController.clear();
    _passwordCheck.clear();
    _goal.clear();
    setState(() {});
  }
}
  

  Future<void> _signIn() async {
  
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text, 
      );
      print("User signed in: ${userCredential.user!.uid}");
      String user = userCredential.user!.uid;
    
      // Reset the login variable to false
    setState(() {
      login = false;
    });

       Navigator.push(
              context,
              FadePageRoute(builder: (context) => Home(uid: user)),
            );
      // Navigate to the next screen or perform other actions after successful login
    } catch (e) {
      print("Failed to sign in: $e");
      login = true;
      _passwordController.clear();
      setState(() {
        
      });
      // Handle the error, e.g., show a snackbar or display an error message
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Login Section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 34,
                        fontFamily: 'helvetica',
                        color: Color(0xffffffff),
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: login ? 'not a valid email or password' : null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: login ? 'incorrect password or email' : null,
                      ),
                    
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _signIn,
                      child: Text('Sign In'),
                    ),
                    SizedBox(height: 32.0),
                  ],
                ),
              ),

              // Spacer between sections
              SizedBox(width: 32.0),

              // Register Section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 34,
                        fontFamily: 'helvetica',
                        color: Color(0xffffffff),
                      ),
                    ),
                    TextFormField(
                      controller: new_emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: email ? "Email must be in abc@def.com format" : null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: new_passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: pass ? "Password must be at least 6 characters" : null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordCheck,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: pass_check ? "Passwords do not match" : null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _goal,
                      decoration: InputDecoration(
                        labelText: 'Enter savings goal',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: value ? 'value must be an integer or double of 2 decimal places' : null,
                      ),
                     
                    ),
                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _createUser,
                      child: Text('Register'),
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