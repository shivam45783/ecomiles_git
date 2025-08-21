import 'package:EcoMiles/auth/google_auth.dart';
import 'package:EcoMiles/provider/mapProvider.dart';
import 'package:EcoMiles/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:EcoMiles/provider/settingsProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsOverlay extends StatefulWidget {
  final bool isDark;
  final bool showSettings;

  const SettingsOverlay({
    super.key,
    required this.isDark,
    required this.showSettings,
  });

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;

  // double get _baseHeight => MediaQuery.of(context).size.height * 0.4;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant SettingsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showSettings && !oldWidget.showSettings) {
      // Just opened, reset scroll
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppThemeMode appThemeMode = Provider.of<ThemeProvider>(
      context,
    ).appThemeMode;
    final mapProivder = Provider.of<MapProvider>(context);
    // final screenHeight = MediaQuery.of(context).size.height;
    final _baseHeight = MediaQuery.of(context).size.height * 0.5;
    final onClose = Provider.of<SettingsProvider>(context).hide;
    final googleAuth = GoogleAuth(context: context);
    final settingsInstance = Provider.of<SettingsProvider>(context);
    final visibleBottomPosition = widget.showSettings ? 0.0 : -_baseHeight;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),

      curve: Curves.easeOut,
      bottom: visibleBottomPosition.clamp(-_baseHeight, 0),
      left: 0,
      right: 0,
      height: _baseHeight,

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.isDark
              ? const Color.fromARGB(255, 54, 54, 54)
              : const Color.fromARGB(255, 253, 235, 215),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              SizedBox(height: 10),
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 20,
                  color: widget.isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(
                color: Colors.grey,
                indent: MediaQuery.of(context).size.width * 0.03,
                endIndent: MediaQuery.of(context).size.width * 0.03,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Material(
                        color: Colors.transparent,

                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child:
                                      FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .photoURL ==
                                          null
                                      ? const Icon(Icons.person)
                                      : CircleAvatar(
                                          radius: 18, // Half of 50
                                          backgroundImage: NetworkImage(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .photoURL
                                                .toString(),
                                          ),
                                        ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  FirebaseAuth
                                      .instance
                                      .currentUser!
                                      .displayName!,
                                  style: TextStyle(
                                    color: widget.isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Prefrence",
                              style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      mapProivder.setOptimisedRoute = true;

                                      mapProivder.notifyListeners();
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.4,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: widget.isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.eco,
                                            color:
                                                mapProivder.optimisedRoute ==
                                                    true
                                                ? Colors.purpleAccent
                                                : widget.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 25,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Eco",
                                            style: TextStyle(
                                              color:
                                                  mapProivder.optimisedRoute ==
                                                      true
                                                  ? Colors.purpleAccent
                                                  : widget.isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      mapProivder.setOptimisedRoute = false;
                                      mapProivder.notifyListeners();
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.4,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: widget.isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.timer,
                                            color:
                                                mapProivder.optimisedRoute ==
                                                    false
                                                ? Colors.purpleAccent
                                                : widget.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 25,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Time",
                                            style: TextStyle(
                                              color:
                                                  mapProivder.optimisedRoute ==
                                                      false
                                                  ? Colors.purpleAccent
                                                  : widget.isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // SizedBox(width: 10),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Theme",
                              style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(
                                        context,
                                        listen: false,
                                      ).selectTheme(AppThemeMode.system);
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.28,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: widget.isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.computer_rounded,
                                            color:
                                                appThemeMode ==
                                                    AppThemeMode.system
                                                ? Colors.purpleAccent
                                                : widget.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 25,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "System",
                                            style: TextStyle(
                                              color:
                                                  appThemeMode ==
                                                      AppThemeMode.system
                                                  ? Colors.purpleAccent
                                                  : widget.isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(
                                        context,
                                        listen: false,
                                      ).selectTheme(AppThemeMode.dark);
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.24,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: widget.isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.dark_mode_rounded,
                                            color:
                                                appThemeMode ==
                                                    AppThemeMode.dark
                                                ? Colors.purpleAccent
                                                : widget.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 25,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Dark",
                                            style: TextStyle(
                                              color:
                                                  appThemeMode ==
                                                      AppThemeMode.dark
                                                  ? Colors.purpleAccent
                                                  : widget.isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      Provider.of<ThemeProvider>(
                                        context,
                                        listen: false,
                                      ).selectTheme(AppThemeMode.light);
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.24,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: widget.isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.light_mode_rounded,
                                            color:
                                                appThemeMode ==
                                                    AppThemeMode.light
                                                ? Colors.purpleAccent
                                                : widget.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 25,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            "Light",
                                            style: TextStyle(
                                              color:
                                                  appThemeMode ==
                                                      AppThemeMode.light
                                                  ? Colors.purpleAccent
                                                  : widget.isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                    Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Map Styles",
                              style: TextStyle(
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      Provider.of<MapProvider>(
                                        context,
                                        listen: false,
                                      ).setMapStyles(MapType.normal);
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.25,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: widget.isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.roundabout_left_rounded,
                                            color:
                                                Provider.of<MapProvider>(
                                                      context,
                                                      listen: false,
                                                    ).mapType ==
                                                    MapType.normal
                                                ? Colors.purpleAccent
                                                : widget.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "Normal",
                                            style: TextStyle(
                                              color:
                                                  Provider.of<MapProvider>(
                                                        context,
                                                        listen: false,
                                                      ).mapType ==
                                                      MapType.normal
                                                  ? Colors.purpleAccent
                                                  : widget.isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      Provider.of<MapProvider>(
                                        context,
                                        listen: false,
                                      ).setMapStyles(MapType.hybrid);
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.25,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: widget.isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.satellite_alt_rounded,
                                            color:
                                                Provider.of<MapProvider>(
                                                      context,
                                                      listen: false,
                                                    ).mapType ==
                                                    MapType.hybrid
                                                ? Colors.purpleAccent
                                                : widget.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "Satellite",
                                            style: TextStyle(
                                              color:
                                                  Provider.of<MapProvider>(
                                                        context,
                                                        listen: false,
                                                      ).mapType ==
                                                      MapType.hybrid
                                                  ? Colors.purpleAccent
                                                  : widget.isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      Provider.of<MapProvider>(
                                        context,
                                        listen: false,
                                      ).setMapStyles(MapType.terrain);
                                    },
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.25,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: widget.isDark
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.black.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.terrain,
                                            color:
                                                Provider.of<MapProvider>(
                                                      context,
                                                      listen: false,
                                                    ).mapType ==
                                                    MapType.terrain
                                                ? Colors.purpleAccent
                                                : widget.isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "Terrain",
                                            style: TextStyle(
                                              color:
                                                  Provider.of<MapProvider>(
                                                        context,
                                                        listen: false,
                                                      ).mapType ==
                                                      MapType.terrain
                                                  ? Colors.purpleAccent
                                                  : widget.isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          googleAuth.signOut();
                          settingsInstance.hide();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            "/getStarted",
                            (route) => false,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.redAccent.withOpacity(0.8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: widget.isDark
                                    ? Colors.white
                                    : Colors.black87,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Logout",
                                style: TextStyle(
                                  color: widget.isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    // Material(
                    //   color: Colors.transparent,
                    //   child: InkWell(
                    //     borderRadius: BorderRadius.circular(8),
                    //     onTap: () {
                    //       Provider.of<LoadingProvider>(context).show();
                    //       Provider.of<MapProvider>(
                    //         context,
                    //         listen: false,
                    //       ).getNavigation();
                    //       Provider.of<LoadingProvider>(context).hide();
                    //     },
                    //     child: Container(
                    //       decoration: BoxDecoration(
                    //         borderRadius: BorderRadius.circular(8),
                    //         color: Colors.redAccent.withOpacity(0.8),
                    //       ),
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 16,
                    //         vertical: 8,
                    //       ),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Icon(
                    //             Icons.logout,
                    //             color: widget.isDark
                    //                 ? Colors.white
                    //                 : Colors.black87,
                    //             size: 20,
                    //           ),
                    //           const SizedBox(width: 8),
                    //           Text(
                    //             "getDirection",
                    //             style: TextStyle(
                    //               color: widget.isDark
                    //                   ? Colors.white
                    //                   : Colors.black87,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
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
