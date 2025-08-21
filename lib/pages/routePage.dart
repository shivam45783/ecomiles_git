import 'dart:convert';

import 'package:EcoMiles/components/loadingOverlay.dart';
import 'package:EcoMiles/provider/loadingProvider.dart';
import 'package:EcoMiles/provider/mapProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  // final TextEditingController _sourceController = TextEditingController();
  // final TextEditingController _destinationController = TextEditingController();
  final FocusNode _sourceFocusNode = FocusNode();
  final FocusNode _destinationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _sourceFocusNode.addListener(() {
      if (!_sourceFocusNode.hasFocus) {
        // Hide predictions when losing focus
        Provider.of<MapProvider>(
          context,
          listen: false,
        ).predictionsResponse.clear();
        setState(() {});
      }
    });

    _destinationFocusNode.addListener(() {
      if (!_destinationFocusNode.hasFocus) {
        Provider.of<MapProvider>(
          context,
          listen: false,
        ).predictionsResponse.clear();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _sourceFocusNode.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mapProvider = Provider.of<MapProvider>(context);
    final loadingInstance = Provider.of<LoadingProvider>(context);
    showSnackBar(String message) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 35,
      ),
      body: Stack(
        children: [
          // Background / map placeholder
          Container(
            color: isDark
                ? const Color.fromARGB(255, 54, 54, 54)
                : const Color.fromARGB(255, 253, 235, 215),
          ),

          // Search box
          Positioned(
            top: MediaQuery.of(context).padding.top + 40,
            left: 15,
            right: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icons + line
                  Column(
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        color: isDark ? Colors.lightBlue[300] : Colors.blue,
                      ),
                      Container(
                        width: 2,
                        height:
                            mapProvider.destinationController!.text.isNotEmpty
                            ? 35
                            : 25,
                        color: isDark ? Colors.grey[700] : Colors.grey[400],
                      ),
                      Icon(
                        Icons.location_on_rounded,
                        color: isDark ? Colors.red[300] : Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // Text fields stacked
                  Expanded(
                    child: Column(
                      children: [
                        _buildSearchField(
                          controller: mapProvider.sourceController!,
                          hint: "Choose starting point",
                          isDark: isDark,
                          onTextChanged: mapProvider.onSourceChanged,
                          focusNode: _sourceFocusNode,
                          // suffixIcon: Icon(
                          //   Icons.my_location_rounded,
                          //   color: isDark ? Colors.lightBlue[300] : Colors.blue,
                          //   // size: 17,
                          // ),
                        ),
                        const SizedBox(height: 5),
                        Divider(
                          height: 0.1,
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(height: 5),
                        _buildSearchField(
                          controller: mapProvider.destinationController!,
                          hint: "Choose destination",
                          isDark: isDark,
                          onTextChanged: mapProvider.onDestinationChanged,
                          focusNode: _destinationFocusNode,
                          // suffixIcon: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          Positioned(
            top:
                mapProvider.sourceController!.text.isNotEmpty &&
                    _sourceFocusNode.hasFocus &&
                    mapProvider.destinationController!.text.isEmpty
                ? 190
                : 210,
            left: 15,
            right: 15,
            child:
                mapProvider.predictionsResponse.isNotEmpty &&
                    mapProvider.sourceController!.text.isNotEmpty &&
                    _sourceFocusNode.hasFocus
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
                      padding: const EdgeInsets.all(0),
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
                              mapProvider.selectFromPlace(place['placeId']);
                              // mapProvider.sourceController!.clear();
                              mapProvider.sourceController!.text =
                                  place['primaryText'] ?? '';
                              mapProvider.predictionsResponse.clear();
                              mapProvider.notifyListeners();
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
                                  color: isDark ? Colors.white : Colors.black87,
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
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
          ),
          Positioned(
            top:
                mapProvider.destinationController!.text.isNotEmpty &&
                    _destinationFocusNode.hasFocus &&
                    mapProvider.sourceController!.text.isEmpty
                ? 190
                : 210,
            left: 15,
            right: 15,
            child:
                mapProvider.predictionsResponse.isNotEmpty &&
                    mapProvider.destinationController!.text.isNotEmpty &&
                    _destinationFocusNode.hasFocus
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
                      padding: const EdgeInsets.all(0),
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
                              print("placeId: ${place['placeId']}");
                              mapProvider.selectToPlace(place['placeId']);
                              // mapProvider.destinationController!.clear();
                              mapProvider.destinationController!.text =
                                  place['primaryText'] ?? '';
                              mapProvider.predictionsResponse.clear();
                              mapProvider.notifyListeners();
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
                                  color: isDark ? Colors.white : Colors.black87,
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
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.70,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icons + connector
                      Column(
                        children: [
                          Icon(
                            Icons.radio_button_checked,
                            size: 20,
                            color: Colors.greenAccent,
                          ),
                          Container(
                            width: 2,
                            height: 30,
                            color: Colors.grey[400],
                          ),
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // From & To text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "From",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              mapProvider.sourceController?.text.isNotEmpty ==
                                      true
                                  ? mapProvider.sourceController!.text
                                  : "Select starting point",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "To",
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                            Text(
                              mapProvider
                                          .destinationController
                                          ?.text
                                          .isNotEmpty ==
                                      true
                                  ? mapProvider.destinationController!.text
                                  : "Select destination",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                TextButton(
                  onPressed: () async {
                    if (mapProvider.fromLocation == null ||
                        mapProvider.toLocation == null) {
                      showSnackBar(
                        "Please select both a starting and destination point.",
                      );
                      return;
                    }

                    loadingInstance.show();

                    try {
                      bool shouldPop = false;

                      if (mapProvider.optimisedRoute) {
                        bool isInsideGurugram = await mapProvider
                            .getPloyLinesToPlot(
                              mapProvider.fromLocation!,
                              mapProvider.toLocation!,
                            );

                        if (!isInsideGurugram) {
                          showSnackBar("Route is outside Gurugram");
                        } else {
                          shouldPop = true;
                        }
                      } else {
                        await mapProvider.getPloyLinesToPlot(
                          mapProvider.fromLocation!,
                          mapProvider.toLocation!,
                        );
                        shouldPop = true;
                      }

                      if (shouldPop) {
                        loadingInstance.hide();
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.pop(context);
                        });
                        // Navigator.pop(context);
                      }
                    } catch (e) {
                      print("Error: $e");
                      showSnackBar("An error occurred. Please try again.");
                    } finally {
                      loadingInstance.hide();
                    }
                  },

                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Get Directions",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (loadingInstance.isLoading)
            LoadingOverlay(loading: loadingInstance.isLoading, isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    required ValueChanged<String> onTextChanged,
    required FocusNode focusNode,
    // required suffixIcon,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: (value) {
        setState(() {}); // Update UI for suffixIcon and predictions
        onTextChanged(value); // Call provider method
      },
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.grey[600],
          fontSize: 15,
        ),
        border: InputBorder.none,
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  controller.clear();
                  onTextChanged(''); // Clear predictions
                  setState(() {}); // Refresh UI
                },
                child: Icon(
                  Icons.clear,
                  size: 18,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
              )
            : null,
      ),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 15,
      ),
    );
  }
}
