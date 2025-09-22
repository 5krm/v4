// // ignore_for_file: unused_local_variable, unnecessary_to_list_in_spreads

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/vpn_protocol_controller.dart';
// import '../models/vpn_protocol_model.dart';
// import '../widgets/custom_card.dart';
// import '../widgets/loading_overlay.dart';

// class VpnProtocolScreen extends StatelessWidget {
//   const VpnProtocolScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(VpnProtocolController());

//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0E27),
//       appBar: AppBar(
//         title: const Text(
//           'VPN Protocol Selection',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: const Color(0xFF1A1F3A),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           Obx(() => IconButton(
//                 icon: controller.isLoadingStats
//                     ? const SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.white),
//                         ),
//                       )
//                     : const Icon(Icons.refresh),
//                 onPressed: controller.isLoadingStats
//                     ? null
//                     : () => controller.refreshStats(),
//                 tooltip: 'Refresh Statistics',
//               )),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (value) {
//               switch (value) {
//                 case 'reset_stats':
//                   _showResetStatsDialog(context, controller);
//                   break;
//                 case 'test_all':
//                   _testAllProtocols(controller);
//                   break;
//                 case 'compare':
//                   _showCompareDialog(context, controller);
//                   break;
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'reset_stats',
//                 child: Row(
//                   children: [
//                     Icon(Icons.restore, color: Colors.red),
//                     SizedBox(width: 8),
//                     Text('Reset Statistics'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'test_all',
//                 child: Row(
//                   children: [
//                     Icon(Icons.speed, color: Colors.blue),
//                     SizedBox(width: 8),
//                     Text('Test All Protocols'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'compare',
//                 child: Row(
//                   children: [
//                     Icon(Icons.compare_arrows, color: Colors.green),
//                     SizedBox(width: 8),
//                     Text('Compare Protocols'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading) {
//           return const LoadingOverlay(message: 'Loading protocol settings...');
//         }

//         return RefreshIndicator(
//           onRefresh: () => controller.loadSettings(),
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Current Status Card
//                 _buildCurrentStatusCard(controller),
//                 const SizedBox(height: 16),

//                 // Auto Selection Settings
//                 _buildAutoSelectionCard(controller),
//                 const SizedBox(height: 16),

//                 // Protocol Recommendations
//                 if (controller.recommendations.isNotEmpty) ...[
//                   _buildRecommendationsCard(controller),
//                   const SizedBox(height: 16),
//                 ],

//                 // Available Protocols
//                 _buildProtocolsCard(context, controller),
//                 const SizedBox(height: 16),

//                 // Protocol Statistics
//                 if (controller.protocolStats.isNotEmpty) ...[
//                   _buildStatisticsCard(context, controller),
//                   const SizedBox(height: 16),
//                 ],

//                 // Test Results
//                 if (controller.testResults.isNotEmpty) ...[
//                   _buildTestResultsCard(controller),
//                   const SizedBox(height: 16),
//                 ],

//                 // Protocol Comparison
//                 if (controller.comparison != null) ...[
//                   _buildComparisonCard(controller),
//                   const SizedBox(height: 16),
//                 ],

//                 // Usage Summary
//                 _buildUsageSummaryCard(controller),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildCurrentStatusCard(VpnProtocolController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF4CAF50).withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.security,
//                   color: const Color(0xFF4CAF50),
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Text(
//                   'Current Protocol',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               if (controller.isSwitching)
//                 const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor:
//                         AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2A2F4A),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: Color(int.parse(
//                     '0xFF${controller.getProtocolColor(controller.currentProtocol)}')),
//                 width: 2,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Text(
//                   controller.getProtocolIcon(controller.currentProtocol),
//                   style: const TextStyle(fontSize: 32),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         controller
//                             .getProtocolDisplayName(controller.currentProtocol),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         controller.currentProtocol == 'auto'
//                             ? 'Automatically selected based on conditions'
//                             : 'Manually selected protocol',
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (controller.currentProtocol != 'auto')
//                   IconButton(
//                     icon: const Icon(Icons.speed, color: Colors.blue),
//                     onPressed: () =>
//                         controller.testProtocol(controller.currentProtocol),
//                     tooltip: 'Test Protocol',
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAutoSelectionCard(VpnProtocolController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Auto Selection Settings',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Auto Selection Toggle
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2A2F4A),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.auto_awesome,
//                   color: controller.autoSelectionEnabled
//                       ? const Color(0xFF4CAF50)
//                       : Colors.grey[400],
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Auto Protocol Selection',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         'Automatically choose the best protocol',
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Switch(
//                   value: controller.autoSelectionEnabled,
//                   onChanged: (_) => controller.toggleAutoSelection(),
//                   activeColor: const Color(0xFF4CAF50),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 12),

//           // Optimization Toggle
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2A2F4A),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.tune,
//                   color: controller.optimizationEnabled
//                       ? const Color(0xFF2196F3)
//                       : Colors.grey[400],
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Protocol Optimization',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         'Optimize protocol settings for performance',
//                         style: TextStyle(
//                           color: Colors.grey[400],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Switch(
//                   value: controller.optimizationEnabled,
//                   onChanged: (_) => controller.toggleOptimization(),
//                   activeColor: const Color(0xFF2196F3),
//                 ),
//               ],
//             ),
//           ),

//           if (controller.autoSelectionEnabled) ...[
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: controller.isLoadingRecommendations
//                   ? null
//                   : () => controller.getRecommendations(),
//               icon: controller.isLoadingRecommendations
//                   ? const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : const Icon(Icons.refresh),
//               label: const Text('Update Recommendations'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF4CAF50),
//                 foregroundColor: Colors.white,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildRecommendationsCard(VpnProtocolController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Protocol Recommendations',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...controller.recommendations.take(3).map((recommendation) {
//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2A2F4A),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: Color(int.parse(
//                       '0xFF${controller.getRecommendationColor(recommendation.score)}')),
//                   width: 1,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Text(
//                     controller.getProtocolIcon(recommendation.protocol),
//                     style: const TextStyle(fontSize: 24),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               controller.getProtocolDisplayName(
//                                   recommendation.protocol),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 8, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: Color(int.parse(
//                                         '0xFF${controller.getRecommendationColor(recommendation.score)}'))
//                                     .withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(
//                                 controller.getRecommendationLevel(
//                                     recommendation.score),
//                                 style: TextStyle(
//                                   color: Color(int.parse(
//                                       '0xFF${controller.getRecommendationColor(recommendation.score)}')),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           recommendation.reason,
//                           style: TextStyle(
//                             color: Colors.grey[400],
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Column(
//                     children: [
//                       Text(
//                         '${recommendation.score}%',
//                         style: TextStyle(
//                           color: Color(int.parse(
//                               '0xFF${controller.getRecommendationColor(recommendation.score)}')),
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       if (recommendation.protocol != controller.currentProtocol)
//                         TextButton(
//                           onPressed: () => controller.switchProtocol(
//                             recommendation.protocol,
//                             reason: 'recommendation',
//                           ),
//                           child: const Text(
//                             'Switch',
//                             style: TextStyle(color: Color(0xFF4CAF50)),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildProtocolsCard(BuildContext context, VpnProtocolController controller) {
//     final protocols = controller.getSortedProtocols();

//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Available Protocols',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...protocols.map((protocol) {
//             final isSelected = protocol.key == controller.currentProtocol;
//             final stats = controller.getProtocolStats(protocol.key);

//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isSelected
//                     ? const Color(0xFF4CAF50).withOpacity(0.1)
//                     : const Color(0xFF2A2F4A),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: isSelected
//                       ? const Color(0xFF4CAF50)
//                       : Color(int.parse(
//                               '0xFF${controller.getProtocolColor(protocol.key)}'))
//                           .withOpacity(0.3),
//                   width: isSelected ? 2 : 1,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         controller.getProtocolIcon(protocol.key),
//                         style: const TextStyle(fontSize: 28),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   protocol.name,
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 if (isSelected) ...[
//                                   const SizedBox(width: 8),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 8, vertical: 2),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFF4CAF50),
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                     child: const Text(
//                                       'ACTIVE',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               protocol.description,
//                               style: TextStyle(
//                                 color: Colors.grey[400],
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           if (!isSelected)
//                             ElevatedButton(
//                               onPressed: () =>
//                                   controller.switchProtocol(protocol.key),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Color(int.parse(
//                                     '0xFF${controller.getProtocolColor(protocol.key)}')),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 8),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                               ),
//                               child: const Text('Select'),
//                             ),
//                           const SizedBox(height: 8),
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               IconButton(
//                                 icon: const Icon(Icons.speed,
//                                     color: Colors.blue, size: 20),
//                                 onPressed: () =>
//                                     controller.testProtocol(protocol.key),
//                                 tooltip: 'Test Protocol',
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.info_outline,
//                                     color: Colors.grey, size: 20),
//                                 onPressed: () => _showProtocolDetails(
//                                     context, protocol, stats),
//                                 tooltip: 'Protocol Details',
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   if (stats != null) ...[
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF1A1F3A),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           _buildStatItem('Success Rate',
//                               '${stats.successRate.toStringAsFixed(1)}%'),
//                           _buildStatItem('Avg Speed',
//                               controller.formatSpeed(stats.avgSpeed)),
//                           _buildStatItem('Usage', '${stats.usageCount}'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsCard(BuildContext context, VpnProtocolController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Text(
//                 'Protocol Statistics',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               TextButton.icon(
//                 onPressed: () => _showDetailedStats(context, controller),
//                 icon: const Icon(Icons.analytics, color: Color(0xFF2196F3)),
//                 label: const Text(
//                   'View Details',
//                   style: TextStyle(color: Color(0xFF2196F3)),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2A2F4A),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: controller.protocolStats.entries.take(3).map((entry) {
//                 final protocol = entry.key;
//                 final stats = entry.value;

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   child: Row(
//                     children: [
//                       Text(
//                         controller.getProtocolIcon(protocol),
//                         style: const TextStyle(fontSize: 20),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           controller.getProtocolDisplayName(protocol),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(
//                             '${stats.successRate.toStringAsFixed(1)}%',
//                             style: TextStyle(
//                               color: stats.successRate >= 90
//                                   ? const Color(0xFF4CAF50)
//                                   : stats.successRate >= 70
//                                       ? const Color(0xFFFF9800)
//                                       : const Color(0xFFF44336),
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             '${stats.usageCount} uses',
//                             style: TextStyle(
//                               color: Colors.grey[400],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTestResultsCard(VpnProtocolController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Recent Test Results',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...controller.testResults.entries.map((entry) {
//             final protocol = entry.key;
//             final result = entry.value;

//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2A2F4A),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: result.isSuccessful
//                       ? const Color(0xFF4CAF50)
//                       : const Color(0xFFF44336),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         controller.getProtocolIcon(protocol),
//                         style: const TextStyle(fontSize: 24),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           controller.getProtocolDisplayName(protocol),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       Icon(
//                         result.isSuccessful ? Icons.check_circle : Icons.error,
//                         color: result.isSuccessful
//                             ? const Color(0xFF4CAF50)
//                             : const Color(0xFFF44336),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildTestStatItem(
//                         'Download',
//                         controller.formatSpeed(result.speedTest.download),
//                         Icons.download,
//                       ),
//                       _buildTestStatItem(
//                         'Upload',
//                         controller.formatSpeed(result.speedTest.upload),
//                         Icons.upload,
//                       ),
//                       _buildTestStatItem(
//                         'Latency',
//                         '${result.speedTest.latency.toStringAsFixed(0)}ms',
//                         Icons.timer,
//                       ),
//                     ],
//                   ),
//                   if (!result.isSuccessful) ...[
//                     const SizedBox(height: 8),
//                     Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF44336).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         'Error: Connection failed',
//                         style: const TextStyle(
//                           color: Color(0xFFF44336),
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildComparisonCard(VpnProtocolController controller) {
//     final comparison = controller.comparison!;

//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Protocol Comparison',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Winner
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF4CAF50).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFF4CAF50), width: 2),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.emoji_events,
//                     color: Color(0xFF4CAF50), size: 32),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Best Overall',
//                         style: TextStyle(
//                           color: Color(0xFF4CAF50),
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       Text(
//                         controller.getProtocolDisplayName(
//                             comparison.sortedProtocols.first.protocol),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Text(
//                   controller.getProtocolIcon(comparison.sortedProtocols.first.protocol),
//                   style: const TextStyle(fontSize: 32),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Comparison metrics
//           ...comparison.protocols.entries.map((entry) {
//             final protocol = entry.key;
//             final data = entry.value;

//             return Container(
//               margin: const EdgeInsets.only(bottom: 12),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2A2F4A),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     protocol.toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ...data.characteristics.entries.map((charEntry) {
//                     final charName = charEntry.key;
//                     final charValue = charEntry.value;

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 2),
//                       child: Row(
//                         children: [
//                           Text(
//                             controller.getProtocolIcon(protocol),
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               controller.getProtocolDisplayName(protocol),
//                               style: TextStyle(
//                                 color: Colors.grey[300],
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             charValue.toString(),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildUsageSummaryCard(VpnProtocolController controller) {
//     final summary = controller.getUsageSummary();

//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Usage Summary',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2A2F4A),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildSummaryItem(
//                       'Total Usage',
//                       '${summary['total_usage']}',
//                       Icons.bar_chart,
//                       const Color(0xFF2196F3),
//                     ),
//                     _buildSummaryItem(
//                       'Protocol Switches',
//                       '${summary['total_switches']}',
//                       Icons.swap_horiz,
//                       const Color(0xFFFF9800),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildSummaryItem(
//                       'Success Rate',
//                       '${(summary['avg_success_rate'] as double).toStringAsFixed(1)}%',
//                       Icons.check_circle,
//                       const Color(0xFF4CAF50),
//                     ),
//                     _buildSummaryItem(
//                       'Most Used',
//                       controller.getProtocolDisplayName(
//                           summary['most_used_protocol']),
//                       Icons.star,
//                       const Color(0xFF9C27B0),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTestStatItem(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.grey[400], size: 16),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 10,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryItem(
//       String label, String value, IconData icon, Color color) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[400],
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }

//   // Dialog and action methods

//   void _showResetStatsDialog(
//       BuildContext context, VpnProtocolController controller) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1A1F3A),
//         title: const Text(
//           'Reset Statistics',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: const Text(
//           'Are you sure you want to reset all protocol statistics? This action cannot be undone.',
//           style: TextStyle(color: Colors.grey),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               controller.resetStats();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF44336),
//             ),
//             child: const Text('Reset'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _testAllProtocols(VpnProtocolController controller) {
//     for (final protocol in controller.availableProtocols.keys) {
//       if (protocol != 'auto') {
//         controller.testProtocol(protocol);
//       }
//     }

//     Get.snackbar(
//       'Testing Started',
//       'Testing all available protocols...',
//       snackPosition: SnackPosition.BOTTOM,
//     );
//   }

//   void _showCompareDialog(
//       BuildContext context, VpnProtocolController controller) {
//     final selectedProtocols = <String>[];

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setState) => AlertDialog(
//           backgroundColor: const Color(0xFF1A1F3A),
//           title: const Text(
//             'Compare Protocols',
//             style: TextStyle(color: Colors.white),
//           ),
//           content: SizedBox(
//             width: double.maxFinite,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Select protocols to compare:',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 16),
//                 ...controller.availableProtocols.entries.map((entry) {
//                   final protocol = entry.key;
//                   final protocolData = entry.value;

//                   if (protocol == 'auto') return const SizedBox.shrink();

//                   return CheckboxListTile(
//                     title: Text(
//                       protocolData.name,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                     subtitle: Text(
//                       protocolData.description,
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     value: selectedProtocols.contains(protocol),
//                     onChanged: (value) {
//                       setState(() {
//                         if (value == true) {
//                           selectedProtocols.add(protocol);
//                         } else {
//                           selectedProtocols.remove(protocol);
//                         }
//                       });
//                     },
//                     activeColor: const Color(0xFF4CAF50),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: selectedProtocols.length >= 2
//                   ? () {
//                       Navigator.of(context).pop();
//                       controller.compareProtocols(selectedProtocols);
//                     }
//                   : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF4CAF50),
//               ),
//               child: const Text('Compare'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showProtocolDetails(
//       BuildContext context, VpnProtocol protocol, ProtocolStats? stats) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1A1F3A),
//         title: Row(
//           children: [
//             Text(
//               Get.find<VpnProtoGelCot.find<V>()pnProtocolController>().getProtocolIcon(protocol.key),
//               style: const TextStyle(fontSize: 24),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               protocol.name,
//               style: const TextStyle(color: Colors.white),
//             ),
//           ],
//         ),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 protocol.description,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 16),
//               if (stats != null) ...[
//                 const Text(
//                   'Statistics:',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 _buildDetailRow(
//                     'Success Rate', '${stats.successRate.toStringAsFixed(1)}%'),
//                 _buildDetailRow('Usage Count', '${stats.usageCount}'),
//                 _buildDetailRow(
//               Get.find<VpnProto  lCo    'Ave>()rage Speed', Get.find<VpnProtocolController>().formatSpeed(stats.avgSpeed)),
//                 _buildDetailRow('Average Latency', '${stats.totalDuration}ms'),
//                 _buildDetGet.find<VpnProtoaolCilRow('Co>()nnection Time',
//                     Get.find<VpnProtocolController>().formatDuration(stats.totalDuration)),
//                 _buildDetailRow(
//                     'Last Used', stats.lastUsed?.toString() ?? 'Never'),
//                 const SizedBox(height: 16),
//               ],
//               const Text(
//                 'Features:',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               ...protocol.features
//                   .map((feature) => Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 2),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.check,
//                                 color: Color(0xFF4CAF50), size: 16),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 feature,
//                                 style: const TextStyle(color: Colors.grey),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ))
//                   .toList(),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(color: Colors.grey),
//           ),
//           Text(
//             value,
//             style: const TextStyle(color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDetailedStats(
//       BuildContext context, VpnProtocolController controller) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1A1F3A),
//         title: const Text(
//           'Detailed Statistics',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 400,
//           child: SingleChildScrollView(
//             child: Column(
//               children: controller.protocolStats.entries.map((entry) {
//                 final protocol = entry.key;
//                 final stats = entry.value;

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF2A2F4A),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             controller.getProtocolIcon(protocol),
//                             style: const TextStyle(fontSize: 20),
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             controller.getProtocolDisplayName(protocol),
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       _buildDetailRow('Success Rate',
//                           '${stats.successRate.toStringAsFixed(1)}%'),
//                       _buildDetailRow('Usage Count', '${stats.usageCount}'),
//             Get.find<VpnProto olC         >()_buildDetailRow('Average Speed',
//                           Get.find<VpnProtocolController>().formatSpeed(stats.avgSpeed)),
//                       _buildDetailRow(
//                           'Average Latency', '${stats.totalDuratiGet.find<VpnProtooolCn}ms'),
//  >()                     _buildDetailRow('Connection Time',
//                           Get.find<VpnProtocolController>().formatDuration(stats.totalDuration)),
//                       _buildDetailRow(
//                           'Last Used', stats.lastUsed?.toString() ?? 'Never'),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }
// }
