// import 'package:flutter/material.dart';
// import 'package:swipefit/resources/auth_methods.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   late String email;
//   late String password;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 40.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Placeholder for custom image
//             Flexible(
//               child: Hero(
//                 tag: 'icon',
//                 child: SizedBox(
//                   height: 100.0,
//                   child: Image.asset('assets/icon.png'),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40),

//             // Email Field
//             TextField(
//               keyboardType: TextInputType.emailAddress,
//               onChanged: (value) {
//                 email = value;
//               },
//               decoration: InputDecoration(
//                 hintText: "Email",
//                 filled: true,
//                 fillColor: Colors.grey[850],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Password Field
//             TextField(
//               obscureText: true,
//               onChanged: (value) {
//                 password = value;
//               },
//               decoration: InputDecoration(
//                 hintText: "Password",
//                 filled: true,
//                 fillColor: Colors.grey[850],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),

//             // Forgot Password
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 onPressed: () {},
//                 child: const Text(
//                   "Forgot password?",
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Login Button
//             ElevatedButton(
//               onPressed: () {
//                 AuthMethods().loginUser(
//                     email: email, password: password, context: context);
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                 ),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text("Login"),
//             ),
//             const SizedBox(height: 40),

//             // Google Button
//             ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                 ),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text("Login with Google"),
//             ),
//             const SizedBox(height: 20),

//             // Create New Account
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/signup');
//               },
//               style: ElevatedButton.styleFrom(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(30.0),
//                 ),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text("Create New Account"),
//                   SizedBox(width: 10),
//                   Icon(Icons.arrow_forward),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../resources/auth_methods.dart'; // Adjust the path as necessary

class LoginPage extends ConsumerStatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthMethods().loginUser(
        email: _emailController.text,
        password: _passwordController.text,
        context: context,
      );
      final currentUserId = await AuthMethods().getCurrentUserId();
      print('Logged in as user: $currentUserId');
      Navigator.pushNamedAndRemoveUntil(context, "/mainpage", (route) => false);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Placeholder for custom image
            Flexible(
              child: Hero(
                tag: 'icon',
                child: SizedBox(
                  height: 100.0,
                  child: Image.asset('assets/icon.png'),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Email Field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email",
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Forgot Password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Forgot password?",
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text("Login"),
            ),
            const SizedBox(height: 40),

            // Google Button
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Login with Google"),
            ),
            const SizedBox(height: 20),

            // Create New Account
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Create New Account"),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
