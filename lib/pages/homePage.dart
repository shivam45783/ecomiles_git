// import 'package:EcoMiles/auth/google_auth.dart';
// import 'package:EcoMiles/auth/logout.dart';
import 'package:EcoMiles/components/settingOverlay.dart';
// import 'package:EcoMiles/components/splashButton.dart';
import 'package:EcoMiles/pages/mapPage.dart';
import 'package:EcoMiles/provider/mapProvider.dart';
import 'package:EcoMiles/provider/settingsProvider.dart';
import 'package:flutter/material.dart';
import 'package:EcoMiles/components/loadingOverlay.dart';
// import 'package:EcoMiles/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:EcoMiles/provider/loadingProvider.dart';
// import 'package:EcoMiles/pages/mapPage.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String? showLoginMessage;
  const HomePage({super.key, this.showLoginMessage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Provider.of<LoadingProvider>(context, listen: false).hide();
    if (widget.showLoginMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.showLoginMessage!)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    //  final mapPage = MapPage(isDark: isDark);
    final mapProvider = Provider.of<MapProvider>(context);
    LoadingProvider loadingInstance = Provider.of<LoadingProvider>(context);
    SettingsProvider settingsInstance = Provider.of<SettingsProvider>(context);
    // final googleAuth = GoogleAuth(context: context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: settingsInstance.showSettings
          ? null
          : loadingInstance.isLoading == false
          ? FloatingActionButton(
              onPressed: () {
                // mapPage.getCurrentLocation();
                mapProvider.getCurrentLocation();
              },
              child: Icon(Icons.my_location_rounded),
              backgroundColor: isDark ? Colors.black87 : Colors.white,
            )
          : null,

      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                // GestureDetector(
                //   onTap: () => settingsInstance.show(),
                //   child: Icon(
                //     Icons.settings_rounded,
                //     color: isDark ? Colors.white : Colors.black87,
                //   ),
                // ),
                const SizedBox(width: 10),

                // GestureDetector(
                //   onTap: () => Provider.of<ThemeProvider>(
                //     context,
                //     listen: false,
                //   ).toggleTheme(),

                //   child: Icon(
                //     Provider.of<ThemeProvider>(context).appThemeMode ==
                //             AppThemeMode.system
                //         ? Icons.computer_rounded
                //         : Provider.of<ThemeProvider>(context).appThemeMode ==
                //               AppThemeMode.light
                //         ? Icons.light_mode_rounded
                //         : Icons.dark_mode_rounded,
                //     color: isDark ? Colors.white : Colors.black87,
                //   ),
                // ),
              ],
            ),
          ),
        ],

        toolbarHeight: 30,
        backgroundColor: isDark
            ? const Color.fromARGB(0, 54, 54, 54)
            : const Color.fromARGB(0, 253, 235, 215),
        // backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(child: MapPage(isDark: isDark)),
            Positioned(
              top: 40,
              left: 15,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.black87 : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: TextField(
                    autocorrect: true,
                    controller: mapProvider.searchController,
                    onChanged: (_) => {
                      setState(() {}),
                      mapProvider.onSearchChanged(
                        mapProvider.searchController!.text,
                      ),
                      // print(mapProvider.searchController!.text),
                    },
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search here',
                      hintStyle: TextStyle(fontSize: 16, color: Colors.grey),

                      prefixIcon: Icon(Icons.search),
                      suffixIcon: mapProvider.searchController!.text.isEmpty
                          ? null
                          : Padding(
                              padding: const EdgeInsets.only(
                                right: 8.0,
                                left: 4.0,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.clear),

                                onPressed: () {
                                  mapProvider.searchController!.clear();
                                  mapProvider.predictionsResponse.clear();
                                  mapProvider.notifyListeners();
                                },
                              ),
                            ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (settingsInstance.showSettings)
              AnimatedOpacity(
                opacity: 0.6,
                duration: Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () => settingsInstance.hide(),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black87,
                  ),
                ),
              ),
            if (loadingInstance.isLoading == false)
              Positioned(
                top: 120, // adjust for safe area
                right: 20,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => settingsInstance.show(),

                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black87 : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.settings_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (mapProvider.destinationLocation != null)
                      GestureDetector(
                        onTap: () async {
                          if (mapProvider.destinationLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a destination.'),
                              ),
                            );
                            return;
                          }
                          loadingInstance.show();
                          try {
                            await mapProvider.getNavigation();
                          } catch (e) {
                            print("Navigation error: $e");
                          } finally {
                            loadingInstance.hide();
                          }
                        },
                        // onTap: () async {
                        //   await mapProvider.getNavigation();
                        // },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black87 : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.directions_rounded,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (mapProvider.destinationLocation != null)
                      GestureDetector(
                        onTap: () async {
                          if (mapProvider.destinationLocation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a destination.'),
                              ),
                            );
                            return;
                          }
                          loadingInstance.show();
                          try {
                            // await mapProvider.getNavigation();
                            mapProvider.getDirections(
                              mapProvider.destinationLocation!,
                            );
                          } catch (e) {
                            print("Navigation error: $e");
                          } finally {
                            loadingInstance.hide();
                          }
                        },

                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black87 : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.route_rounded,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (mapProvider.locationSubscription?.isPaused == false)
                      GestureDetector(
                        onTap: () async {
                          loadingInstance.show();
                          mapProvider.endNavigation();
                          loadingInstance.hide();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.cancel,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (mapProvider.showCancelRoute)
              Positioned(
                top: 110,
                left: 20,
                child: GestureDetector(
                  onTap: () async {
                    // mapProvider.setDestination();
                    mapProvider.deletePoints();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      // shape: BoxShape.,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Cancel Route",
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 105,
              left: 15,
              right: 15,
              child:
                  mapProvider.predictionsResponse.isNotEmpty &&
                      mapProvider.searchController!.text.isNotEmpty
                  ? Container(
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(context).size.height *
                            0.5, // Limit height
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: mapProvider.predictionsResponse.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 0.1,
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        itemBuilder: (context, index) {
                          final place = mapProvider.predictionsResponse[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // Handle selection
                                loadingInstance.show();
                                mapProvider.selectPlace(place['primaryText']);
                                mapProvider.searchController!.clear();
                                mapProvider.predictionsResponse.clear();
                                mapProvider.notifyListeners();
                                loadingInstance.hide();
                              },
                              splashColor: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              highlightColor: isDark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                              child: ListTile(
                                leading: Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                ),
                                title: Text(
                                  place['primaryText'] ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  place['secondaryText'] ?? '',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                                // onTap: () {
                                //   // Handle selection
                                //   loadingInstance.show();
                                //   mapProvider.selectPlace(place['primaryText']);
                                //   mapProvider.searchController!.clear();
                                //   mapProvider.predictionsResponse.clear();
                                //   mapProvider.notifyListeners();
                                //   loadingInstance.hide();
                                // },
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox.shrink(),
            ),

            SettingsOverlay(
              isDark: isDark,
              showSettings: settingsInstance.showSettings,
            ),
            if (loadingInstance.isLoading)
              LoadingOverlay(
                loading: loadingInstance.isLoading,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }
}
