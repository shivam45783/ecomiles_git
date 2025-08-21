import 'package:EcoMiles/theme/theme_provider.dart';
import 'package:flutter/material.dart';
// import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class ModeInfoPage extends StatelessWidget {
  const ModeInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 15),
        //     child: GestureDetector(
        //       onTap: () => Provider.of<ThemeProvider>(
        //         context,
        //         listen: false,
        //       ).toggleTheme(),
        //       child: Icon(
        //         Provider.of<ThemeProvider>(context).appThemeMode ==
        //                 AppThemeMode.system
        //             ? Icons.computer_rounded
        //             : Provider.of<ThemeProvider>(context).appThemeMode ==
        //                   AppThemeMode.light
        //             ? Icons.light_mode_rounded
        //             : Icons.dark_mode_rounded,
        //         color: isDark ? Colors.white : Colors.black87,
        //       ),
        //     ),
        //   ),
        // ],
        toolbarHeight: 30,

        backgroundColor: isDark
            ? const Color.fromARGB(255, 54, 54, 54)
            : const Color.fromARGB(255, 253, 235, 215),
      ),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            width: double.infinity,
            // height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color.fromARGB(255, 54, 54, 54)
                  : const Color.fromARGB(255, 253, 235, 215),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: MediaQuery.of(context).size.width * 0.29,
                  ),
                  Text(
                    "EcoMiles",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'Tangerine',
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "Choose the right mode for your journey",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Our app provides two routing modes depending on your needs. "
                    "Use Time Mode for the fastest route anywhere, or Eco Mode "
                    "to reduce pollution when traveling in Gurugram.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.eco, size: 36, color: Colors.green),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Eco Mode",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "• Works only within Gurugram.\n"
                                  "• Uses our custom dataset.\n"
                                  "• Optimized for reduced pollution and eco-friendly routes.",
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // spacing before footer
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.timer, size: 36, color: Colors.blue),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Time Mode",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "• Works for any source and destination.\n"
                                  "• Uses Google Maps data.\n"
                                  "• Optimized for the fastest travel time.",
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.4,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Select the mode that best fits your journey.",
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ),
                  // const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
