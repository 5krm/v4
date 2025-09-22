// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../controllers/smart_server_controller.dart';
// import '../models/smart_server_model.dart';
// import '../widgets/custom_card.dart';
// import '../widgets/loading_widget.dart';
// import '../widgets/custom_error_widget.dart';

// class SmartServerScreen extends StatelessWidget {
//   final SmartServerController controller = Get.put(SmartServerController());

//   SmartServerScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Smart Server Selection'),
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => controller.refreshAllData(),
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () => _showSettingsDialog(context),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoadingSettings.value && 
//             controller.isLoadingRecommendations.value) {
//           return const LoadingWidget(message: 'Loading smart server data...');
//         }

//         return RefreshIndicator(
//           onRefresh: () => controller.refreshAllData(),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildStatusCard(),
//                 const SizedBox(height: 16),
//                 _buildRecommendationsSection(),
//                 const SizedBox(height: 16),
//                 _buildAnalyticsSection(),
//                 const SizedBox(height: 16),
//                 _buildQuickActionsSection(),
//                 const SizedBox(height: 16),
//                 _buildAdvancedSettingsSection(),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildStatusCard() {
//     return Obx(() {
//       final settings = controller.smartServerSettings.value;
//       final currentRec = controller.currentRecommendation.value;
      
//       return CustomCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.psychology,
//                   color: Theme.of(Get.context!).primaryColor,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'AI Server Selection',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: settings.learningEnabled ? Colors.green : Colors.grey,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     settings.learningEnabled ? 'Learning' : 'Static',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildStatusItem(
//                     'Mode',
//                     settings.optimizationMode.toUpperCase(),
//                     Icons.tune,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildStatusItem(
//                     'Auto-Failover',
//                     settings.autoFailover ? 'ON' : 'OFF',
//                     Icons.swap_horiz,
//                   ),
//                 ),
//               ],
//             ),
//             if (currentRec != null) ...[
//               const SizedBox(height: 16),
//               const Divider(),
//               const SizedBox(height: 8),
//               Text(
//                 'Current Recommendation',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(
//                     Icons.location_on,
//                     size: 16,
//                     color: Colors.grey[600],
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     '${currentRec.serverCountry} - ${currentRec.serverCity ?? 'Unknown'}',
//                     style: const TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: controller.getScoreColor(currentRec.recommendationScore),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       controller.formatRecommendationScore(currentRec.recommendationScore),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildStatusItem(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, size: 20, color: Colors.grey[600]),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRecommendationsSection() {
//     return Obx(() {
//       if (controller.isLoadingRecommendations.value) {
//         return const CustomCard(
//           child: LoadingWidget(message: 'Loading recommendations...'),
//         );
//       }

//       if (controller.recommendationsError.value.isNotEmpty) {
//         return CustomCard(
//           child: CustomErrorWidget(
//             message: controller.recommendationsError.value,
//             onRetry: () => controller.loadRecommendations(),
//           ),
//         );
//       }

//       final recommendations = controller.serverRecommendations;
      
//       if (recommendations.isEmpty) {
//         return CustomCard(
//           child: Column(
//             children: [
//               Icon(
//                 Icons.psychology_outlined,
//                 size: 48,
//                 color: Colors.grey[400],
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'No Recommendations Available',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'The AI is analyzing servers to provide personalized recommendations.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey[500]),
//               ),
//             ],
//           ),
//         );
//       }

//       return CustomCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.recommend, size: 20),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Server Recommendations',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Spacer(),
//                 Text(
//                   '${recommendations.length} servers',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             ...recommendations.take(5).map((rec) => _buildRecommendationItem(rec)),
//             if (recommendations.length > 5) ...[
//               const SizedBox(height: 8),
//               Center(
//                 child: TextButton(
//                   onPressed: () => _showAllRecommendations(),
//                   child: Text('View All ${recommendations.length} Recommendations'),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildRecommendationItem(ServerRecommendation rec) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: Theme.of(Get.context!).primaryColor,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '#${rec.recommendationRank}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${rec.serverCountry} - ${rec.serverCity ?? 'Unknown'}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 14,
//                       ),
//                     ),
//                     Text(
//                       rec.serverProtocol.toUpperCase(),
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: controller.getScoreColor(rec.recommendationScore),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   controller.formatRecommendationScore(rec.recommendationScore),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           if (rec.factors.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 4,
//               children: rec.factors.entries.take(3).map((entry) {
//                 return Chip(
//                   label: Text(
//                     '${entry.key}: ${entry.value}',
//                     style: const TextStyle(fontSize: 10),
//                   ),
//                   backgroundColor: Colors.grey[100],
//                   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                 );
//               }).toList(),
//             ),
//           ],
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => _showRecommendationDetails(rec),
//                   child: const Text('Details'),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () => _connectToServer(rec),
//                   child: const Text('Connect'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnalyticsSection() {
//     return Obx(() {
//       if (controller.isLoadingAnalytics.value) {
//         return const CustomCard(
//           child: LoadingWidget(message: 'Loading analytics...'),
//         );
//       }

//       final analytics = controller.serverAnalytics.value;
      
//       return CustomCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.analytics, size: 20),
//                 SizedBox(width: 8),
//                 Text(
//                   'Performance Analytics',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildAnalyticsItem(
//                     'Total Recommendations',
//                     analytics.totalRecommendations.toString(),
//                     Icons.recommend,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildAnalyticsItem(
//                     'Success Rate',
//                     '${(analytics.successRate * 100).toStringAsFixed(1)}%',
//                     Icons.check_circle,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildAnalyticsItem(
//                     'Average Score',
//                     '${(analytics.averageScore * 100).toStringAsFixed(1)}%',
//                     Icons.star,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildAnalyticsItem(
//                     'Successful Connections',
//                     analytics.successfulConnections.toString(),
//                     Icons.link,
//                   ),
//                 ),
//               ],
//             ),
//             if (analytics.topServers.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               const Divider(),
//               const SizedBox(height: 8),
//               Text(
//                 'Top Performing Servers',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               const SizedBox(height: 8),
//               ...analytics.topServers.take(3).map((server) => 
//                 _buildTopServerItem(server)
//               ),
//             ],
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildAnalyticsItem(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, size: 24, color: Theme.of(Get.context!).primaryColor),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTopServerItem(Map<String, dynamic> server) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.location_on,
//             size: 16,
//             color: Colors.grey[600],
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               '${server['country']} - ${server['city'] ?? 'Unknown'}',
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Text(
//             '${(server['score'] * 100).toStringAsFixed(0)}%',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               color: Theme.of(Get.context!).primaryColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActionsSection() {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.flash_on, size: 20),
//               SizedBox(width: 8),
//               Text(
//                 'Quick Actions',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               _buildActionChip(
//                 'Refresh Recommendations',
//                 Icons.refresh,
//                 () => controller.loadRecommendations(),
//               ),
//               _buildActionChip(
//                 'Trigger Failover',
//                 Icons.swap_horiz,
//                 () => controller.triggerFailover(),
//               ),
//               _buildActionChip(
//                 'Reset Learning',
//                 Icons.psychology_outlined,
//                 () => _showResetLearningDialog(),
//               ),
//               _buildActionChip(
//                 'Provide Feedback',
//                 Icons.feedback,
//                 () => _showFeedbackDialog(),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
//     return ActionChip(
//       avatar: Icon(icon, size: 16),
//       label: Text(label, style: const TextStyle(fontSize: 12)),
//       onPressed: onTap,
//       backgroundColor: Colors.grey[100],
//     );
//   }

//   Widget _buildAdvancedSettingsSection() {
//     return Obx(() {
//       if (!controller.showAdvancedSettings.value) {
//         return CustomCard(
//           child: ListTile(
//             leading: const Icon(Icons.settings_outlined),
//             title: const Text('Advanced Settings'),
//             subtitle: const Text('Configure AI learning and optimization'),
//             trailing: const Icon(Icons.expand_more),
//             onTap: () => controller.toggleAdvancedSettings(),
//           ),
//         );
//       }

//       final settings = controller.smartServerSettings.value;
      
//       return CustomCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text('Advanced Settings'),
//               trailing: IconButton(
//                 icon: const Icon(Icons.expand_less),
//                 onPressed: () => controller.toggleAdvancedSettings(),
//               ),
//             ),
//             const Divider(),
//             _buildSettingItem(
//               'Optimization Mode',
//               controller.getOptimizationModeDescription(settings.optimizationMode),
//               trailing: DropdownButton<String>(
//                 value: settings.optimizationMode,
//                 items: ['speed', 'security', 'balanced', 'reliability']
//                     .map((mode) => DropdownMenuItem(
//                           value: mode,
//                           child: Text(mode.toUpperCase()),
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     controller.toggleOptimizationMode(value);
//                   }
//                 },
//               ),
//             ),
//             _buildSettingItem(
//               'Auto-Failover',
//               'Automatically switch to backup servers on failure',
//               trailing: Switch(
//                 value: settings.autoFailover,
//                 onChanged: (value) => controller.toggleAutoFailover(value),
//               ),
//             ),
//             _buildSettingItem(
//               'AI Learning',
//               'Enable machine learning for better recommendations',
//               trailing: Switch(
//                 value: settings.learningEnabled,
//                 onChanged: (value) => controller.toggleLearning(value),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => _showWeightsDialog(),
//                     child: const Text('Scoring Weights'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => _showThresholdsDialog(),
//                     child: const Text('Thresholds'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildSettingItem(String title, String subtitle, {Widget? trailing}) {
//     return ListTile(
//       title: Text(title),
//       subtitle: Text(subtitle),
//       trailing: trailing,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//     );
//   }

//   // Dialog Methods
//   void _showSettingsDialog(BuildContext context) {
//     // Implementation for settings dialog
//   }

//   void _showAllRecommendations() {
//     // Implementation for showing all recommendations
//   }

//   void _showRecommendationDetails(ServerRecommendation rec) {
//     // Implementation for recommendation details
//   }

//   void _connectToServer(ServerRecommendation rec) {
//     // Implementation for connecting to server
//   }

//   void _showResetLearningDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Reset Learning Data'),
//         content: const Text(
//           'This will clear all AI learning data and reset recommendations to default. This action cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.resetLearningData();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Reset'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFeedbackDialog() {
//     // Implementation for feedback dialog
//   }

//   void _showWeightsDialog() {
//     // Implementation for weights configuration
//   }

//   void _showThresholdsDialog() {
//     // Implementation for thresholds configuration
//   }
// }