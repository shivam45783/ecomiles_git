import 'package:EcoMiles/components/loadingOverlay.dart';
import 'package:EcoMiles/components/splashButton.dart';
import 'package:EcoMiles/pages/homePage.dart';
import 'package:EcoMiles/provider/loadingProvider.dart';
import 'package:EcoMiles/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:EcoMiles/auth/google_auth.dart';
import 'package:EcoMiles/auth/apple_auth.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  // bool loading = false;

  @override
  Widget build(BuildContext context) {
    final googleAuth = GoogleAuth(context: context);
    final appleAuth = AppleAuth(context: context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeData = Theme.of(context);
    LoadingProvider loadingInstance = Provider.of<LoadingProvider>(context);
    void _simulateLoading() async {
      // Provider.of<LoadingProvider>(context, listen: false).show();
      loadingInstance.show();

      // Simulate a delay
      await Future.delayed(const Duration(seconds: 3));

      loadingInstance.hide();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: GestureDetector(
              onTap: () => Provider.of<ThemeProvider>(
                context,
                listen: false,
              ).toggleTheme(),
              child: Icon(
                Provider.of<ThemeProvider>(context).appThemeMode ==
                        AppThemeMode.system
                    ? Icons.computer_rounded
                    : Provider.of<ThemeProvider>(context).appThemeMode ==
                          AppThemeMode.light
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
        toolbarHeight: 30,

        backgroundColor: isDark
            ? const Color.fromARGB(255, 54, 54, 54)
            : const Color.fromARGB(255, 253, 235, 215),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          const Color.fromARGB(255, 54, 54, 54),
                          const Color.fromARGB(255, 0, 0, 0),
                        ]
                      : [
                          const Color.fromARGB(
                            255,
                            253,
                            235,
                            215,
                          ), // soft light gray
                          const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ), // pure white
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),

                    Text(
                      "EcoMiles",
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        fontFamily: 'Tangerine',
                      ),
                    ),

                    const SizedBox(height: 10),
                    Image(
                      image: AssetImage('assets/images/logo.png'),
                      width: MediaQuery.of(context).size.width * 0.59,
                    ),
                    // Lottie.asset(
                    //   'assets/animations/driving.json',
                    //   width: MediaQuery.of(context).size.width * 0.7,
                    // ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    // Center(
                    //   child: ElevatedButton(
                    //     onPressed: _simulateLoading,
                    //     child: const Text("Start Loading"),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          // color: themeData.colorScheme.secondaryContainer,
                          // borderRadius: BorderRadius.circular(15),
                          // border: Border.all(
                          //   color: isDark
                          //       ? Colors.white.withOpacity(0.1)
                          //       : Colors.black.withOpacity(0.1),
                          // ),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: isDark
                          //         ? Colors.white.withOpacity(0.05)
                          //         : Colors.black.withOpacity(0.1),
                          //     blurRadius: 10,
                          //     spreadRadius: 1,
                          //     offset: const Offset(0, 4),
                          //   ),
                          // ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Welcome to EcoMiles!",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Your eco-friendly driving companion.",
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 50,
                        // bottom: 10,
                        top: 5,
                      ),

                      child: SplashButton(
                        isDark: isDark,
                        onTap: () async {
                          final user = await googleAuth.signInWithGoogle();
                          print("user: $user");

                          loadingInstance.hide();
                          Future.delayed(const Duration(seconds: 1), () {
                            if (user != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                  (route) => false,
                                );
                              });
                            }
                          });
                          // if (user != null) {
                          //   Navigator.pushAndRemoveUntil(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => HomePage(
                          //         showLoginMessage:
                          //             'Signed in with Google as ${user!.displayName}',
                          //       ),
                          //     ),
                          //     (route) => false,
                          //   );
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => HomePage(
                          //       showLoginMessage:
                          //           'Signed in with Google as ${user!.displayName}',
                          //     ),
                          //   ),
                          // );
                          // }
                        },
                        // onTap: () async {
                        //   loadingInstance.show();

                        //   WidgetsBinding.instance.addPostFrameCallback((
                        //     _,
                        //   ) async {
                        //     final user = await googleAuth.signInWithGoogle();

                        //     if (!mounted) return;

                        //     if (user != null) {
                        //       Navigator.pushReplacement(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => HomePage(
                        //             showLoginMessage:
                        //                 'Signed in with Google as ${user.displayName}',
                        //           ),
                        //         ),
                        //       );
                        //     }

                        //     // Don't hide loading here, let HomePage handle it
                        //   });
                        // },
                        child: Row(
                          children: [
                            Image(
                              image: AssetImage(
                                'assets/images/google_icon.png',
                              ),
                              width: 34,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 50,
                        // bottom: 10,
                        top: 5,
                      ),

                      child: SplashButton(
                        isDark: isDark,
                        onTap: () async {
                          final user = await appleAuth.signInWithApple();
                          print("user: $user");
                          if (user != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Signed in with Apple as ${user.displayName}',
                                ),
                              ),
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                              (route) => false,
                            );
                          }
                        },

                        child: Row(
                          children: [
                            Image(
                              image: AssetImage('assets/images/apple_icon.png'),
                              width: 34,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Continue with Apple",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // if (loading)
              ),
            ),
            LoadingOverlay(loading: loadingInstance.isLoading, isDark: isDark),
          ],
        ),
      ),
    );
  }
}
