// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../controllers/data_usage_controller.dart';
// import '../models/data_usage_model.dart';
// import '../widgets/custom_card.dart';
// import '../widgets/loading_overlay.dart';
// import '../widgets/error_banner.dart';
// import '../widgets/lazy_loading_widget.dart';

// class DataUsageScreen extends StatelessWidget {
//   const DataUsageScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(DataUsageController());

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Data Usage Monitor'),
//         actions: [
//           Obx(() => IconButton(
//                 icon: Icon(
//                   controller.autoRefresh ? Icons.sync : Icons.sync_disabled,
//                   color: controller.autoRefresh ? Colors.green : Colors.grey,
//                 ),
//                 onPressed: () => _showRefreshSettings(context, controller),
//               )),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () => _showSettings(context, controller),
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) =>
//                 _handleMenuAction(context, controller, value),
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'export',
//                 child: Row(
//                   children: [
//                     Icon(Icons.download),
//                     SizedBox(width: 8),
//                     Text('Export Data'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'reset',
//                 child: Row(
//                   children: [
//                     Icon(Icons.refresh),
//                     SizedBox(width: 8),
//                     Text('Reset Usage'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'help',
//                 child: Row(
//                   children: [
//                     Icon(Icons.help),
//                     SizedBox(width: 8),
//                     Text('Help'),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading) {
//           return const LoadingOverlay(
//               message: 'Loading data usage settings...');
//         }

//         return RefreshIndicator(
//           onRefresh: controller.refreshData,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (controller.error.isNotEmpty)
//                   ErrorBanner(
//                     message: controller.error,
//                     onDismiss: controller.clearError,
//                   ),

//                 // Status Overview
//                 _buildStatusOverview(controller),
//                 const SizedBox(height: 16),

//                 // Quick Actions
//                 _buildQuickActions(controller),
//                 const SizedBox(height: 16),

//                 // Usage Charts - Lazy loaded for better performance
//                 LazyChart(
//                   chartBuilder: () => _buildUsageCharts(controller),
//                   height: 300,
//                   debugLabel: 'data_usage_charts',
//                 ),
//                 const SizedBox(height: 16),

//                 // Alerts
//                 if (controller.hasAlerts) ...[
//                   _buildAlertsSection(controller),
//                   const SizedBox(height: 16),
//                 ],

//                 // Real-time Data
//                 _buildRealTimeSection(controller),
//                 const SizedBox(height: 16),

//                 // Statistics
//                 _buildStatisticsSection(controller),
//                 const SizedBox(height: 16),

//                 // Top Apps
//                 _buildTopAppsSection(controller),
//                 const SizedBox(height: 16),

//                 // Recent Records
//                 _buildRecentRecordsSection(controller),
//               ],
//             ),
//           ),
//         );
//       }),
//       floatingActionButton: Obx(() => FloatingActionButton(
//             onPressed: controller.isEnabled ? controller.refreshData : null,
//             backgroundColor: controller.isEnabled ? Colors.blue : Colors.grey,
//             child: const Icon(Icons.refresh),
//           )),
//     );
//   }

//   Widget _buildStatusOverview(DataUsageController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 controller.getStatusIcon(),
//                 style: const TextStyle(fontSize: 24),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Data Usage Monitor',
//                       style: Get.textTheme.titleLarge,
//                     ),
//                     Text(
//                       controller.statusText,
//                       style: Get.textTheme.bodyMedium?.copyWith(
//                         color: _getStatusColor(controller.statusText),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Switch(
//                 value: controller.isEnabled,
//                 onChanged: (_) => controller.toggleEnabled(),
//               ),
//             ],
//           ),
//           if (controller.monitor != null) ...[
//             const SizedBox(height: 16),
//             _buildUsageProgress(controller),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildUsageProgress(DataUsageController controller) {
//     final monitor = controller.monitor!;

//     return Column(
//       children: [
//         if (monitor.dailyLimitMb != null)
//           _buildProgressBar(
//             'Daily Usage',
//             monitor.dailyUsageBytes,
//             monitor.dailyLimitMb! * 1024 * 1024,
//             monitor.dailyUsagePercentage,
//           ),
//         if (monitor.weeklyLimitMb != null) ...[
//           const SizedBox(height: 8),
//           _buildProgressBar(
//             'Weekly Usage',
//             monitor.weeklyUsageBytes,
//             monitor.weeklyLimitMb! * 1024 * 1024,
//             monitor.weeklyUsagePercentage,
//           ),
//         ],
//         if (monitor.monthlyLimitMb != null) ...[
//           const SizedBox(height: 8),
//           _buildProgressBar(
//             'Monthly Usage',
//             monitor.monthlyUsageBytes,
//             monitor.monthlyLimitMb! * 1024 * 1024,
//             monitor.monthlyUsagePercentage,
//           ),
//         ],
//       ],
//     );
//   }

//   Widget _buildProgressBar(
//       String label, int used, int limit, double percentage) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(label, style: Get.textTheme.bodyMedium),
//             Text(
//               '${_formatBytes(used)} / ${_formatBytes(limit)}',
//               style: Get.textTheme.bodySmall,
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         LinearProgressIndicator(
//           value: percentage / 100,
//           backgroundColor: Colors.grey[300],
//           valueColor: AlwaysStoppedAnimation<Color>(
//             _getProgressColor(percentage),
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           '${percentage.toStringAsFixed(1)}%',
//           style: Get.textTheme.bodySmall?.copyWith(
//             color: _getProgressColor(percentage),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickActions(DataUsageController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Quick Actions',
//             style: Get.textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               _buildActionChip(
//                 'Auto Disconnect',
//                 controller.monitor?.autoDisconnect ?? false,
//                 Icons.power_off,
//                 () => controller.toggleAutoDisconnect(),
//               ),
//               _buildActionChip(
//                 'Real-time Monitor',
//                 controller.autoRefresh,
//                 Icons.monitor,
//                 () => controller.setAutoRefresh(!controller.autoRefresh),
//               ),
//               ActionChip(
//                 label: const Text('Reset Daily'),
//                 avatar: const Icon(Icons.today, size: 18),
//                 onPressed: () => _showResetDialog(controller, 'daily'),
//               ),
//               ActionChip(
//                 label: const Text('Export Data'),
//                 avatar: const Icon(Icons.download, size: 18),
//                 onPressed: () => _showExportDialog(controller),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionChip(
//       String label, bool isActive, IconData icon, VoidCallback onPressed) {
//     return FilterChip(
//       label: Text(label),
//       avatar: Icon(icon, size: 18),
//       selected: isActive,
//       onSelected: (_) => onPressed(),
//       selectedColor: Colors.blue.withOpacity(0.2),
//     );
//   }

//   Widget _buildUsageCharts(DataUsageController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Usage Timeline',
//                 style: Get.textTheme.titleMedium,
//               ),
//               DropdownButton<String>(
//                 value: controller.selectedPeriod,
//                 items: const [
//                   DropdownMenuItem(value: 'daily', child: Text('Daily')),
//                   DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
//                   DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
//                 ],
//                 onChanged: (value) => controller.setPeriod(value!),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           if (controller.isLoadingStats)
//             const Center(child: CircularProgressIndicator())
//           else if (controller.statsError.isNotEmpty)
//             Center(
//               child: Column(
//                 children: [
//                   Text(
//                     'Failed to load statistics',
//                     style:
//                         Get.textTheme.bodyMedium?.copyWith(color: Colors.red),
//                   ),
//                   TextButton(
//                     onPressed: controller.loadStats,
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             )
//           else if (controller.stats != null)
//             _buildChart(controller.stats!)
//           else
//             const Center(
//               child: Text('No usage data available'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChart(UsageStats stats) {
//     return SizedBox(
//       height: 200,
//       child: LineChart(
//         LineChartData(
//           gridData: FlGridData(show: true),
//           titlesData: FlTitlesData(
//             leftTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   return Text(
//                     _formatBytes(value.toInt()),
//                     style: const TextStyle(fontSize: 10),
//                   );
//                 },
//               ),
//             ),
//             bottomTitles: AxisTitles(
//               sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (value, meta) {
//                   final index = value.toInt();
//                   if (index >= 0 && index < stats.usageTimeline.length) {
//                     final date = stats.usageTimeline[index].date;
//                     return Text(
//                       '${date}',
//                       style: const TextStyle(fontSize: 10),
//                     );
//                   }
//                   return const Text('');
//                 },
//               ),
//             ),
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           ),
//           borderData: FlBorderData(show: true),
//           lineBarsData: [
//             LineChartBarData(
//               spots: stats.usageTimeline.asMap().entries.map((entry) {
//                 return FlSpot(
//                   entry.key.toDouble(),
//                   entry.value.usage.toDouble(),
//                 );
//               }).toList(),
//               isCurved: true,
//               color: Colors.blue,
//               barWidth: 2,
//               dotData: FlDotData(show: false),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAlertsSection(DataUsageController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.warning, color: Colors.orange),
//               const SizedBox(width: 8),
//               Text(
//                 'Alerts (${controller.alerts.length})',
//                 style: Get.textTheme.titleMedium,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           ...controller.alerts.map((alert) => _buildAlertItem(alert)),
//         ],
//       ),
//     );
//   }

//   Widget _buildAlertItem(UsageAlert alert) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: _getAlertColor(alert.type).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: _getAlertColor(alert.type).withOpacity(0.3),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             _getAlertIcon(alert.type),
//             color: _getAlertColor(alert.type),
//             size: 20,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   alert.type, // Changed from alert.title to alert.type
//                   style: Get.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   alert.message,
//                   style: Get.textTheme.bodySmall,
//                 ),
//                 Text(
//                   alert.timestamp
//                       .toString(), // Changed from alert.formattedTimestamp to alert.timestamp.toString()
//                   style: Get.textTheme.bodySmall?.copyWith(
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRealTimeSection(DataUsageController controller) {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.speed, color: Colors.green),
//               const SizedBox(width: 8),
//               Text(
//                 'Real-time Usage',
//                 style: Get.textTheme.titleMedium,
//               ),
//               const Spacer(),
//               if (controller.isLoadingRealTime)
//                 const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           if (controller.realTimeData != null) ...[
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildRealTimeMetric(
//                     'Download',
//                     controller
//                         .realTimeData!.currentSession.formattedDownloadSpeed,
//                     Icons.download,
//                     Colors.blue,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _buildRealTimeMetric(
//                     'Upload',
//                     controller
//                         .realTimeData!.currentSession.formattedUploadSpeed,
//                     Icons.upload,
//                     Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildRealTimeMetric(
//                     'Total Today',
//                     controller.realTimeData!.currentSession.formattedTotal,
//                     Icons.today,
//                     Colors.orange,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _buildRealTimeMetric(
//                     'Active Apps',
//                     controller.realTimeData!.activeApps.length.toString(),
//                     Icons.apps,
//                     Colors.purple,
//                   ),
//                 ),
//               ],
//             ),
//           ] else
//             const Center(
//               child: Text('No real-time data available'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRealTimeMetric(
//       String label, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: Get.textTheme.titleMedium?.copyWith(
//               color: color,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             label,
//             style: Get.textTheme.bodySmall,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsSection(DataUsageController controller) {
//     if (controller.stats == null) {
//       return const SizedBox.shrink();
//     }

//     final stats = controller.stats!;

//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Statistics',
//             style: Get.textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   'Total Usage',
//                   _formatBytes(stats.currentUsage
//                       .totalUsage), // Changed from stats.totalBytes
//                   Icons.data_usage,
//                   Colors.blue,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildStatCard(
//                   'Avg Daily',
//                   _formatBytes(stats.currentUsage.totalUsage ~/
//                       30), // Changed from stats.averageDailyBytes
//                   Icons.calendar_today,
//                   Colors.green,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatCard(
//                   'Peak Day',
//                   _formatBytes(stats.currentUsage
//                       .totalUsage), // Changed from stats.peakDayBytes
//                   Icons.trending_up,
//                   Colors.orange,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: _buildStatCard(
//                   'Sessions',
//                   stats.currentUsage.recordCount
//                       .toString(), // Changed from stats.totalSessions
//                   Icons.devices,
//                   Colors.purple,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(
//       String label, String value, IconData icon, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, size: 20, color: color),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: Get.textTheme.titleSmall?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             label,
//             style: Get.textTheme.bodySmall,
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopAppsSection(DataUsageController controller) {
//     if (controller.topApps.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Top Apps',
//             style: Get.textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//           ...controller.topApps.take(5).map((app) => _buildAppUsageItem(app)),
//           if (controller.topApps.length > 5)
//             TextButton(
//               onPressed: () => _showAllApps(controller),
//               child: Text('View all ${controller.topApps.length} apps'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppUsageItem(AppUsageData app) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.blue.withOpacity(0.1),
//         child: Text(
//           app.appName.substring(0, 1).toUpperCase(),
//           style: const TextStyle(color: Colors.blue),
//         ),
//       ),
//       title: Text(app.appName),
//       subtitle: Text('${app.sessionCount} sessions'),
//       trailing: Text(
//         app.formattedUsage, // Changed from _formatBytes(app.totalBytes)
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentRecordsSection(DataUsageController controller) {
//     if (controller.recentRecords.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Recent Activity',
//             style: Get.textTheme.titleMedium,
//           ),
//           const SizedBox(height: 12),
//           ...controller.recentRecords
//               .take(5)
//               .map((record) => _buildRecordItem(record)),
//           if (controller.recentRecords.length > 5)
//             TextButton(
//               onPressed: () => _showAllRecords(controller),
//               child:
//                   Text('View all ${controller.recentRecords.length} records'),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecordItem(DataUsageRecord record) {
//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: Colors.green.withOpacity(0.1),
//         child: const Icon(
//           Icons.data_usage,
//           color: Colors.green,
//           size: 20,
//         ),
//       ),
//       title: Text(record.appName),
//       subtitle: Text(
//         record.recordedAt.toString(), // Changed from record.formattedTimestamp
//         style: const TextStyle(
//           fontSize: 12,
//           color: Colors.grey,
//         ),
//       ),
//       trailing: Text(
//         record.formattedTotal, // Changed from _formatBytes(record.totalBytes)
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   // Dialog methods
//   void _showSettings(BuildContext context, DataUsageController controller) {
//     showDialog(
//       context: context,
//       builder: (context) => _DataUsageSettingsDialog(controller: controller),
//     );
//   }

//   void _showRefreshSettings(
//       BuildContext context, DataUsageController controller) {
//     showDialog(
//       context: context,
//       builder: (context) => _RefreshSettingsDialog(controller: controller),
//     );
//   }

//   void _showResetDialog(DataUsageController controller, String resetType) {
//     Get.dialog(
//       AlertDialog(
//         title: Text('Reset $resetType Usage'),
//         content: Text(
//             'Are you sure you want to reset $resetType usage data? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.resetUsage(resetType);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Reset'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showExportDialog(DataUsageController controller) {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Export Data'),
//         content: const Text('Choose export format and options.'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.exportData(format: 'json', includeRecords: true);
//             },
//             child: const Text('Export JSON'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAllApps(DataUsageController controller) {
//     // Navigate to detailed apps screen
//   }

//   void _showAllRecords(DataUsageController controller) {
//     // Navigate to detailed records screen
//   }

//   void _handleMenuAction(
//       BuildContext context, DataUsageController controller, String action) {
//     switch (action) {
//       case 'export':
//         _showExportDialog(controller);
//         break;
//       case 'reset':
//         _showResetDialog(controller, 'all');
//         break;
//       case 'help':
//         _showHelpDialog();
//         break;
//     }
//   }

//   void _showHelpDialog() {
//     Get.dialog(
//       AlertDialog(
//         title: const Text('Data Usage Monitor Help'),
//         content: const SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Features:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text('• Track data usage by app and time period'),
//               Text('• Set daily, weekly, and monthly limits'),
//               Text('• Automatic disconnect when limits are reached'),
//               Text('• Real-time usage monitoring'),
//               Text('• Usage alerts and notifications'),
//               Text('• Export usage data'),
//               SizedBox(height: 16),
//               Text(
//                 'Tips:',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text('• Enable auto-disconnect to prevent overages'),
//               Text('• Set warning thresholds for early alerts'),
//               Text('• Monitor top apps to identify heavy users'),
//               Text('• Use real-time data for immediate feedback'),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper methods
//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'normal':
//         return Colors.green;
//       case 'near daily limit':
//       case 'near weekly limit':
//       case 'near monthly limit':
//         return Colors.orange;
//       case 'daily limit exceeded':
//       case 'weekly limit exceeded':
//       case 'monthly limit exceeded':
//         return Colors.red;
//       case 'disabled':
//         return Colors.grey;
//       default:
//         return Colors.blue;
//     }
//   }

//   Color _getProgressColor(double percentage) {
//     if (percentage >= 100) return Colors.red;
//     if (percentage >= 80) return Colors.orange;
//     if (percentage >= 60) return Colors.yellow[700]!;
//     return Colors.green;
//   }

//   Color _getAlertColor(String type) {
//     switch (type) {
//       case 'warning':
//         return Colors.orange;
//       case 'limit_reached':
//         return Colors.red;
//       case 'info':
//         return Colors.blue;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getAlertIcon(String type) {
//     switch (type) {
//       case 'warning':
//         return Icons.warning;
//       case 'limit_reached':
//         return Icons.error;
//       case 'info':
//         return Icons.info;
//       default:
//         return Icons.notifications;
//     }
//   }

//   IconData _getConnectionIcon(String connectionType) {
//     switch (connectionType.toLowerCase()) {
//       case 'vpn':
//         return Icons.vpn_lock;
//       case 'wifi':
//         return Icons.wifi;
//       case 'mobile':
//         return Icons.signal_cellular_4_bar;
//       default:
//         return Icons.device_unknown;
//     }
//   }

//   Color _getConnectionColor(String connectionType) {
//     switch (connectionType.toLowerCase()) {
//       case 'vpn':
//         return Colors.green;
//       case 'wifi':
//         return Colors.blue;
//       case 'mobile':
//         return Colors.orange;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _formatBytes(int bytes) {
//     if (bytes == 0) return '0 B';
//     const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
//     int i = (bytes.bitLength - 1) ~/ 10;
//     return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
//   }
// }

// // Settings Dialog
// class _DataUsageSettingsDialog extends StatefulWidget {
//   final DataUsageController controller;

//   const _DataUsageSettingsDialog({required this.controller});

//   @override
//   State<_DataUsageSettingsDialog> createState() =>
//       _DataUsageSettingsDialogState();
// }

// class _DataUsageSettingsDialogState extends State<_DataUsageSettingsDialog> {
//   late TextEditingController _dailyLimitController;
//   late TextEditingController _weeklyLimitController;
//   late TextEditingController _monthlyLimitController;
//   late TextEditingController _warningThresholdController;
//   late TextEditingController _resetDayController;

//   bool _autoDisconnect = false;
//   bool _enabled = false;

//   @override
//   void initState() {
//     super.initState();
//     final monitor = widget.controller.monitor;

//     _dailyLimitController = TextEditingController(
//       text: monitor?.dailyLimitMb?.toString() ?? '',
//     );
//     _weeklyLimitController = TextEditingController(
//       text: monitor?.weeklyLimitMb?.toString() ?? '',
//     );
//     _monthlyLimitController = TextEditingController(
//       text: monitor?.monthlyLimitMb?.toString() ?? '',
//     );
//     _warningThresholdController = TextEditingController(
//       text: monitor?.warningThreshold?.toString() ?? '80',
//     );
//     _resetDayController = TextEditingController(
//       text: monitor?.resetDay?.toString() ?? '1',
//     );

//     _autoDisconnect = monitor?.autoDisconnect ?? false;
//     _enabled = monitor?.enabled ?? false;
//   }

//   @override
//   void dispose() {
//     _dailyLimitController.dispose();
//     _weeklyLimitController.dispose();
//     _monthlyLimitController.dispose();
//     _warningThresholdController.dispose();
//     _resetDayController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Data Usage Settings'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SwitchListTile(
//               title: const Text('Enable Monitoring'),
//               value: _enabled,
//               onChanged: (value) => setState(() => _enabled = value),
//             ),
//             SwitchListTile(
//               title: const Text('Auto Disconnect'),
//               subtitle: const Text('Disconnect when limits are reached'),
//               value: _autoDisconnect,
//               onChanged: (value) => setState(() => _autoDisconnect = value),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _dailyLimitController,
//               decoration: const InputDecoration(
//                 labelText: 'Daily Limit (MB)',
//                 hintText: 'Leave empty for no limit',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _weeklyLimitController,
//               decoration: const InputDecoration(
//                 labelText: 'Weekly Limit (MB)',
//                 hintText: 'Leave empty for no limit',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _monthlyLimitController,
//               decoration: const InputDecoration(
//                 labelText: 'Monthly Limit (MB)',
//                 hintText: 'Leave empty for no limit',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _warningThresholdController,
//               decoration: const InputDecoration(
//                 labelText: 'Warning Threshold (%)',
//                 hintText: '80',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _resetDayController,
//               decoration: const InputDecoration(
//                 labelText: 'Monthly Reset Day',
//                 hintText: '1',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Get.back(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: _saveSettings,
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }

//   void _saveSettings() {
//     widget.controller.updateSettings(
//       enabled: _enabled,
//       dailyLimitMb: _parseLimit(_dailyLimitController.text),
//       weeklyLimitMb: _parseLimit(_weeklyLimitController.text),
//       monthlyLimitMb: _parseLimit(_monthlyLimitController.text),
//       autoDisconnect: _autoDisconnect,
//       warningThreshold: int.tryParse(_warningThresholdController.text),
//       resetDay: int.tryParse(_resetDayController.text),
//     );
//     Get.back();
//   }

//   int? _parseLimit(String text) {
//     if (text.trim().isEmpty) return null;
//     return int.tryParse(text);
//   }
// }

// // Refresh Settings Dialog
// class _RefreshSettingsDialog extends StatefulWidget {
//   final DataUsageController controller;

//   const _RefreshSettingsDialog({required this.controller});

//   @override
//   State<_RefreshSettingsDialog> createState() => _RefreshSettingsDialogState();
// }

// class _RefreshSettingsDialogState extends State<_RefreshSettingsDialog> {
//   late bool _autoRefresh;
//   late int _refreshInterval;

//   @override
//   void initState() {
//     super.initState();
//     _autoRefresh = widget.controller.autoRefresh;
//     _refreshInterval = widget.controller.refreshInterval;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Refresh Settings'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SwitchListTile(
//             title: const Text('Auto Refresh'),
//             value: _autoRefresh,
//             onChanged: (value) => setState(() => _autoRefresh = value),
//           ),
//           if (_autoRefresh) ...[
//             const SizedBox(height: 16),
//             Text('Refresh Interval: ${_refreshInterval}s'),
//             Slider(
//               value: _refreshInterval.toDouble(),
//               min: 10,
//               max: 300,
//               divisions: 29,
//               label: '${_refreshInterval}s',
//               onChanged: (value) =>
//                   setState(() => _refreshInterval = value.toInt()),
//             ),
//           ],
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Get.back(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             widget.controller.setAutoRefresh(_autoRefresh);
//             if (_autoRefresh) {
//               widget.controller.setRefreshInterval(_refreshInterval);
//             }
//             Get.back();
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }
// }
