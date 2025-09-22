// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../controllers/vpn_health_controller.dart';
// import '../models/vpn_health_model.dart';
// import '../widgets/custom_card.dart';
// import '../widgets/custom_button.dart';
// import '../widgets/loading_widget.dart';
// import '../widgets/empty_state_widget.dart';

// class VpnHealthScreen extends StatelessWidget {
//   final VpnHealthController controller = Get.put(VpnHealthController());

//   VpnHealthScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('VPN Health Monitor'),
//         backgroundColor: Theme.of(context).primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           Obx(
//             () => IconButton(
//               icon: Icon(
//                 controller.autoRefresh.value ? Icons.pause : Icons.play_arrow,
//               ),
//               onPressed: controller.toggleAutoRefresh,
//               tooltip: controller.autoRefresh.value
//                   ? 'Pause Auto Refresh'
//                   : 'Start Auto Refresh',
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => controller.refreshData(),
//             tooltip: 'Refresh Data',
//           ),
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               switch (value) {
//                 case 'export':
//                   // Fixed: Provide required parameters for exportHealthData
//                   controller.exportHealthData(
//                     monitorIds: controller.monitors.map((m) => m.id).toList(),
//                     format: 'csv',
//                     startDate: DateTime.now().subtract(
//                       const Duration(days: 30),
//                     ),
//                     endDate: DateTime.now(),
//                   );
//                   break;
//                 case 'settings':
//                   _showSettingsDialog(context);
//                   break;
//                 case 'filters':
//                   _showFiltersDialog(context);
//                   break;
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'export',
//                 child: ListTile(
//                   leading: Icon(Icons.download),
//                   title: Text('Export Data'),
//                   contentPadding: EdgeInsets.zero,
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'filters',
//                 child: ListTile(
//                   leading: Icon(Icons.filter_list),
//                   title: Text('Filters'),
//                   contentPadding: EdgeInsets.zero,
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'settings',
//                 child: ListTile(
//                   leading: Icon(Icons.settings),
//                   title: Text('Settings'),
//                   contentPadding: EdgeInsets.zero,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const LoadingWidget(message: 'Loading health data...');
//         }

//         if (controller.error.value.isNotEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Error loading health data',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   controller.error.value,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 24),
//                 CustomButton(
//                   text: 'Retry',
//                   onPressed: controller.initializeHealthMonitoring,
//                 ),
//               ],
//             ),
//           );
//         }

//         return RefreshIndicator(
//           onRefresh: controller.refreshData,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHealthSummaryCard(),
//                 const SizedBox(height: 16),
//                 _buildQuickActionsCard(),
//                 const SizedBox(height: 16),
//                 _buildActiveAlertsCard(),
//                 const SizedBox(height: 16),
//                 _buildPerformanceChartsCard(),
//                 const SizedBox(height: 16),
//                 _buildMonitorsListCard(),
//                 const SizedBox(height: 16),
//                 _buildRecentChecksCard(),
//               ],
//             ),
//           ),
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showCreateMonitorDialog(context),
//         backgroundColor: Theme.of(context).primaryColor,
//         child: const Icon(Icons.add, color: Colors.white),
//         tooltip: 'Create Monitor',
//       ),
//     );
//   }

//   Widget _buildHealthSummaryCard() {
//     return Obx(() {
//       final summary = controller.healthSummary.value;

//       return CustomCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.health_and_safety,
//                   color: summary.overallHealthColor,
//                   size: 28,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Overall Health',
//                         style: Get.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         summary.overallHealthStatus.toUpperCase(),
//                         style: Get.textTheme.bodyLarge?.copyWith(
//                           color: summary.overallHealthColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: summary.overallHealthColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: summary.overallHealthColor.withOpacity(0.3),
//                     ),
//                   ),
//                   child: Text(
//                     '${summary.overallHealthScore.toStringAsFixed(1)}%',
//                     style: TextStyle(
//                       color: summary.overallHealthColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildSummaryItem(
//                     'Monitors',
//                     '${summary.activeMonitors}/${summary.totalMonitors}',
//                     Icons.monitor,
//                     Colors.blue,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildSummaryItem(
//                     'Healthy',
//                     summary.healthyMonitors.toString(),
//                     Icons.check_circle,
//                     Colors.green,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildSummaryItem(
//                     'Issues',
//                     (summary.degradedMonitors + summary.unhealthyMonitors)
//                         .toString(),
//                     Icons.warning,
//                     Colors.orange,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildSummaryItem(
//                     'Alerts',
//                     summary.totalAlerts.toString(),
//                     Icons.notification_important,
//                     Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildMetricItem(
//                     'Avg Uptime',
//                     '${summary.averageUptime.toStringAsFixed(2)}%',
//                     Icons.trending_up,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildMetricItem(
//                     'Avg Latency',
//                     '${summary.averageLatency.toStringAsFixed(1)} ms',
//                     Icons.speed,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildMetricItem(
//                     'Avg Speed',
//                     '${summary.averageSpeed.toStringAsFixed(1)} Mbps',
//                     Icons.network_check,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildSummaryItem(
//     String label,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 24),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: Get.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildMetricItem(String label, String value, IconData icon) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.grey[600], size: 20),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: Get.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         Text(
//           label,
//           style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickActionsCard() {
//     return CustomCard(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Quick Actions',
//             style: Get.textTheme.titleLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Wrap(
//             spacing: 12,
//             runSpacing: 12,
//             children: [
//               _buildQuickActionButton(
//                 'Run All Checks',
//                 Icons.play_circle_filled,
//                 Colors.green,
//                 () => _runAllHealthChecks(),
//               ),
//               _buildQuickActionButton(
//                 'Create Monitor',
//                 Icons.add_circle,
//                 Colors.blue,
//                 () => _showCreateMonitorDialog(Get.context!),
//               ),
//               _buildQuickActionButton(
//                 'View Alerts',
//                 Icons.notifications,
//                 Colors.orange,
//                 () => _showAlertsDialog(Get.context!),
//               ),
//               _buildQuickActionButton(
//                 'Export Data',
//                 Icons.download,
//                 Colors.purple,
//                 () => controller.exportHealthData(
//                   monitorIds: controller.monitors.map((m) => m.id).toList(),
//                   format: 'csv',
//                   startDate: DateTime.now().subtract(const Duration(days: 30)),
//                   endDate: DateTime.now(),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActionButton(
//     String label,
//     IconData icon,
//     Color color,
//     VoidCallback onPressed,
//   ) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: 18),
//       label: Text(label),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color.withOpacity(0.1),
//         foregroundColor: color,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: BorderSide(color: color.withOpacity(0.3)),
//         ),
//       ),
//     );
//   }

//   Widget _buildActiveAlertsCard() {
//     return Obx(() {
//       final alerts = controller.filteredAlerts;

//       return CustomCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Active Alerts',
//                     style: Get.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 if (alerts.isNotEmpty)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       alerts.length.toString(),
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (alerts.isEmpty)
//               const EmptyStateWidget(
//                 icon: Icons.check_circle,
//                 title: 'No Active Alerts',
//                 message: 'All systems are running smoothly',
//                 iconColor: Colors.green,
//               )
//             else
//               ...alerts.take(3).map((alert) => _buildAlertItem(alert)),
//             if (alerts.length > 3)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: TextButton(
//                   onPressed: () => _showAlertsDialog(Get.context!),
//                   child: Text('View All ${alerts.length} Alerts'),
//                 ),
//               ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildAlertItem(VpnHealthAlert alert) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: alert.severityColor.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: alert.severityColor.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(alert.severityIcon, color: alert.severityColor, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   alert.title,
//                   style: Get.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   alert.message,
//                   style: Get.textTheme.bodySmall?.copyWith(
//                     color: Colors.grey[600],
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: alert.severityColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   alert.severityDisplayName,
//                   style: TextStyle(
//                     color: alert.severityColor,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 controller.formatDuration(alert.duration),
//                 style: Get.textTheme.bodySmall?.copyWith(
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPerformanceChartsCard() {
//     return Obx(() {
//       return CustomCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Performance Charts',
//                     style: Get.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 DropdownButton<String>(
//                   value: controller.selectedTimeRange.value,
//                   onChanged: (value) => controller.changeTimeRange(value!),
//                   items: const [
//                     DropdownMenuItem(value: '1h', child: Text('1 Hour')),
//                     DropdownMenuItem(value: '6h', child: Text('6 Hours')),
//                     DropdownMenuItem(value: '24h', child: Text('24 Hours')),
//                     DropdownMenuItem(value: '7d', child: Text('7 Days')),
//                     DropdownMenuItem(value: '30d', child: Text('30 Days')),
//                   ],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (controller.showPerformanceChart.value) _buildPerformanceChart(),
//             if (controller.showUptimeChart.value) const SizedBox(height: 16),
//             if (controller.showUptimeChart.value) _buildUptimeChart(),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildPerformanceChart() {
//     return Obx(() {
//       final data = controller.performanceHistory;

//       if (data.isEmpty) {
//         return const SizedBox(
//           height: 200,
//           child: Center(child: Text('No performance data available')),
//         );
//       }

//       return SizedBox(
//         height: 200,
//         child: LineChart(
//           LineChartData(
//             gridData: FlGridData(show: true),
//             titlesData: FlTitlesData(
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) {
//                     return Text(
//                       '${value.toInt()}ms',
//                       style: const TextStyle(fontSize: 10),
//                     );
//                   },
//                 ),
//               ),
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 30,
//                   getTitlesWidget: (value, meta) {
//                     if (value.toInt() < data.length) {
//                       final time = data[value.toInt()].timestamp;
//                       return Text(
//                         '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
//                         style: const TextStyle(fontSize: 10),
//                       );
//                     }
//                     return const Text('');
//                   },
//                 ),
//               ),
//               topTitles: const AxisTitles(
//                 sideTitles: SideTitles(showTitles: false),
//               ),
//               rightTitles: const AxisTitles(
//                 sideTitles: SideTitles(showTitles: false),
//               ),
//             ),
//             borderData: FlBorderData(show: true),
//             lineBarsData: [
//               LineChartBarData(
//                 spots: data.asMap().entries.map((entry) {
//                   return FlSpot(entry.key.toDouble(), entry.value.latency);
//                 }).toList(),
//                 isCurved: true,
//                 color: Colors.blue,
//                 barWidth: 2,
//                 dotData: const FlDotData(show: false),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildUptimeChart() {
//     return Obx(() {
//       final data = controller.uptimeHistory;

//       if (data.isEmpty) {
//         return const SizedBox(
//           height: 200,
//           child: Center(child: Text('No uptime data available')),
//         );
//       }

//       return SizedBox(
//         height: 200,
//         child: LineChart(
//           LineChartData(
//             gridData: FlGridData(show: true),
//             titlesData: FlTitlesData(
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) {
//                     return Text(
//                       '${value.toInt()}%',
//                       style: const TextStyle(fontSize: 10),
//                     );
//                   },
//                 ),
//               ),
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 30,
//                   getTitlesWidget: (value, meta) {
//                     if (value.toInt() < data.length) {
//                       final time = data[value.toInt()].timestamp;
//                       return Text(
//                         '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
//                         style: const TextStyle(fontSize: 10),
//                       );
//                     }
//                     return const Text('');
//                   },
//                 ),
//               ),
//               topTitles: const AxisTitles(
//                 sideTitles: SideTitles(showTitles: false),
//               ),
//               rightTitles: const AxisTitles(
//                 sideTitles: SideTitles(showTitles: false),
//               ),
//             ),
//             borderData: FlBorderData(show: true),
//             lineBarsData: [
//               LineChartBarData(
//                 spots: data.asMap().entries.map((entry) {
//                   return FlSpot(entry.key.toDouble(), entry.value.uptime);
//                 }).toList(),
//                 isCurved: true,
//                 color: Colors.green,
//                 barWidth: 2,
//                 dotData: const FlDotData(show: false),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildMonitorsListCard() {
//     return Obx(() {
//       final monitors = controller.filteredMonitors;

//       return CustomCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'Health Monitors',
//                     style: Get.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.filter_list),
//                   onPressed: () => _showFiltersDialog(Get.context!),
//                   tooltip: 'Filter Monitors',
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             if (monitors.isEmpty)
//               const EmptyStateWidget(
//                 icon: Icons.monitor_heart,
//                 title: 'No Monitors Found',
//                 message: 'Create your first health monitor to get started',
//               )
//             else
//               ...monitors.map((monitor) => _buildMonitorItem(monitor)),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildMonitorItem(VpnHealthMonitor monitor) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: monitor.statusColor.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: monitor.statusColor.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(monitor.statusIcon, color: monitor.statusColor, size: 24),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       monitor.monitorName,
//                       style: Get.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       monitor.typeDisplayName,
//                       style: Get.textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Switch(
//                 value: monitor.isActive,
//                 onChanged: (value) =>
//                     controller.toggleMonitor(monitor.id, value),
//                 activeColor: Colors.green,
//               ),
//               PopupMenuButton<String>(
//                 onSelected: (value) {
//                   switch (value) {
//                     case 'edit':
//                       _showEditMonitorDialog(Get.context!, monitor);
//                       break;
//                     case 'check':
//                       controller.performManualCheck(monitor.id);
//                       break;
//                     case 'delete':
//                       _showDeleteConfirmation(Get.context!, monitor);
//                       break;
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                     value: 'edit',
//                     child: ListTile(
//                       leading: Icon(Icons.edit),
//                       title: Text('Edit'),
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'check',
//                     child: ListTile(
//                       leading: Icon(Icons.play_circle),
//                       title: Text('Run Check'),
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                   ),
//                   const PopupMenuItem(
//                     value: 'delete',
//                     child: ListTile(
//                       leading: Icon(Icons.delete, color: Colors.red),
//                       title: Text(
//                         'Delete',
//                         style: TextStyle(color: Colors.red),
//                       ),
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildMonitorMetric(
//                   'Status',
//                   monitor.statusDisplayName,
//                   monitor.statusColor,
//                 ),
//               ),
//               Expanded(
//                 child: _buildMonitorMetric(
//                   'Health Score',
//                   '${monitor.healthScore.toStringAsFixed(1)}%',
//                   _getScoreColor(monitor.healthScore),
//                 ),
//               ),
//               Expanded(
//                 child: _buildMonitorMetric(
//                   'Uptime',
//                   '${monitor.uptimePercentage.toStringAsFixed(2)}%',
//                   Colors.blue,
//                 ),
//               ),
//               Expanded(
//                 child: _buildMonitorMetric(
//                   'Avg Latency',
//                   '${monitor.averageLatency.toStringAsFixed(1)}ms',
//                   Colors.orange,
//                 ),
//               ),
//             ],
//           ),
//           if (monitor.lastCheckAt != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text(
//                 'Last check: ${_formatDateTime(monitor.lastCheckAt!)}',
//                 style: Get.textTheme.bodySmall?.copyWith(
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMonitorMetric(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: Get.textTheme.bodyMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildRecentChecksCard() {
//     return Obx(() {
//       final checks = controller.recentChecks;

//       return CustomCard(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Recent Health Checks',
//               style: Get.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (checks.isEmpty)
//               const EmptyStateWidget(
//                 icon: Icons.history,
//                 title: 'No Recent Checks',
//                 message:
//                     'Health checks will appear here once monitors are active',
//               )
//             else
//               ...checks.take(5).map((check) => _buildCheckItem(check)),
//             if (checks.length > 5)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8),
//                 child: TextButton(
//                   onPressed: () => _showAllChecksDialog(Get.context!),
//                   child: Text('View All ${checks.length} Checks'),
//                 ),
//               ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildCheckItem(VpnHealthCheck check) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: check.statusColor.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: check.statusColor.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             check.isSuccess ? Icons.check_circle : Icons.error,
//             color: check.statusColor,
//             size: 20,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   check.checkType.toUpperCase(),
//                   style: Get.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 if (check.errorMessage != null)
//                   Text(
//                     check.errorMessage!,
//                     style: Get.textTheme.bodySmall?.copyWith(
//                       color: Colors.red[600],
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (check.latency != null)
//                 Text(
//                   '${check.latency!.toStringAsFixed(1)}ms',
//                   style: Get.textTheme.bodySmall?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               Text(
//                 _formatDateTime(check.createdAt),
//                 style: Get.textTheme.bodySmall?.copyWith(
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Dialog Methods
//   void _showCreateMonitorDialog(BuildContext context) {
//     final nameController = TextEditingController();
//     final typeController = TextEditingController(text: 'ping');
//     final intervalController = TextEditingController(text: '300');

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Create Health Monitor'),
//         content: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Monitor Name',
//                   hintText: 'Enter monitor name',
//                 ),
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: typeController.text,
//                 decoration: const InputDecoration(labelText: 'Monitor Type'),
//                 items: const [
//                   DropdownMenuItem(value: 'ping', child: Text('Ping Monitor')),
//                   DropdownMenuItem(value: 'speed', child: Text('Speed Test')),
//                   DropdownMenuItem(
//                     value: 'connection',
//                     child: Text('Connection Monitor'),
//                   ),
//                   DropdownMenuItem(value: 'dns', child: Text('DNS Monitor')),
//                   DropdownMenuItem(
//                     value: 'leak',
//                     child: Text('Leak Detection'),
//                   ),
//                 ],
//                 onChanged: (value) => typeController.text = value!,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: intervalController,
//                 decoration: const InputDecoration(
//                   labelText: 'Check Interval (seconds)',
//                   hintText: 'Enter check interval',
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           Obx(
//             () => ElevatedButton(
//               onPressed: controller.isCreatingMonitor.value
//                   ? null
//                   : () {
//                       if (nameController.text.isNotEmpty) {
//                         controller.createMonitor(
//                           name: nameController.text,
//                           serverId: 1, // Default server
//                           monitorType: typeController.text,
//                           configuration: {
//                             'interval': int.parse(intervalController.text),
//                           },
//                         );
//                         Navigator.of(context).pop();
//                       }
//                     },
//               child: controller.isCreatingMonitor.value
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : const Text('Create'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditMonitorDialog(BuildContext context, VpnHealthMonitor monitor) {
//     final nameController = TextEditingController(text: monitor.monitorName);
//     final intervalController = TextEditingController(
//       text: monitor.checkInterval.toString(),
//     );

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Monitor'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: 'Monitor Name'),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: intervalController,
//               decoration: const InputDecoration(
//                 labelText: 'Check Interval (seconds)',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               controller.updateMonitor(monitor.id, {
//                 'monitor_name': nameController.text,
//                 'check_interval': int.parse(intervalController.text),
//               });
//               Navigator.of(context).pop();
//             },
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeleteConfirmation(BuildContext context, VpnHealthMonitor monitor) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Monitor'),
//         content: Text(
//           'Are you sure you want to delete "${monitor.monitorName}"?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               controller.deleteMonitor(monitor.id);
//               Navigator.of(context).pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAlertsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           height: MediaQuery.of(context).size.height * 0.8,
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   const Expanded(
//                     child: Text(
//                       'Active Alerts',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.close),
//                   ),
//                 ],
//               ),
//               const Divider(),
//               Expanded(
//                 child: Obx(() {
//                   final alerts = controller.activeAlerts;

//                   if (alerts.isEmpty) {
//                     return const Center(
//                       child: EmptyStateWidget(
//                         icon: Icons.check_circle,
//                         title: 'No Active Alerts',
//                         message: 'All systems are running smoothly',
//                         iconColor: Colors.green,
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     itemCount: alerts.length,
//                     itemBuilder: (context, index) {
//                       final alert = alerts[index];
//                       return Card(
//                         margin: const EdgeInsets.only(bottom: 8),
//                         child: ListTile(
//                           leading: Icon(
//                             alert.severityIcon,
//                             color: alert.severityColor,
//                           ),
//                           title: Text(alert.title),
//                           subtitle: Text(alert.message),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               if (!alert.isAcknowledged)
//                                 IconButton(
//                                   onPressed: () =>
//                                       controller.acknowledgeAlert(alert.id),
//                                   icon: const Icon(Icons.check),
//                                   tooltip: 'Acknowledge',
//                                 ),
//                               IconButton(
//                                 onPressed: () =>
//                                     _showResolveAlertDialog(context, alert),
//                                 icon: const Icon(Icons.close),
//                                 tooltip: 'Resolve',
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showResolveAlertDialog(BuildContext context, VpnHealthAlert alert) {
//     final notesController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Resolve Alert'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Resolve alert: ${alert.title}'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: notesController,
//               decoration: const InputDecoration(
//                 labelText: 'Resolution Notes',
//                 hintText: 'Enter resolution notes (optional)',
//               ),
//               maxLines: 3,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               controller.resolveAlert(alert.id);
//               Navigator.of(context).pop();
//             },
//             child: const Text('Resolve'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAllChecksDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           height: MediaQuery.of(context).size.height * 0.8,
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   const Expanded(
//                     child: Text(
//                       'All Health Checks',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.close),
//                   ),
//                 ],
//               ),
//               const Divider(),
//               Expanded(
//                 child: Obx(() {
//                   final checks = controller.recentChecks;

//                   return ListView.builder(
//                     itemCount: checks.length,
//                     itemBuilder: (context, index) {
//                       final check = checks[index];
//                       return _buildCheckItem(check);
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showFiltersDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Filter Options'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Obx(
//               () => DropdownButtonFormField<String>(
//                 value: controller.statusFilter.value,
//                 decoration: const InputDecoration(labelText: 'Status Filter'),
//                 items: const [
//                   DropdownMenuItem(value: 'all', child: Text('All Statuses')),
//                   DropdownMenuItem(value: 'healthy', child: Text('Healthy')),
//                   DropdownMenuItem(value: 'degraded', child: Text('Degraded')),
//                   DropdownMenuItem(
//                     value: 'unhealthy',
//                     child: Text('Unhealthy'),
//                   ),
//                   DropdownMenuItem(value: 'error', child: Text('Error')),
//                 ],
//                 onChanged: (value) => controller.applyStatusFilter(value!),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Obx(
//               () => DropdownButtonFormField<String>(
//                 value: controller.severityFilter.value,
//                 decoration: const InputDecoration(labelText: 'Severity Filter'),
//                 items: const [
//                   DropdownMenuItem(value: 'all', child: Text('All Severities')),
//                   DropdownMenuItem(value: 'critical', child: Text('Critical')),
//                   DropdownMenuItem(value: 'high', child: Text('High')),
//                   DropdownMenuItem(value: 'medium', child: Text('Medium')),
//                   DropdownMenuItem(value: 'low', child: Text('Low')),
//                 ],
//                 onChanged: (value) => controller.applySeverityFilter(value!),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Obx(
//               () => DropdownButtonFormField<String>(
//                 value: controller.monitorTypeFilter.value,
//                 decoration: const InputDecoration(
//                   labelText: 'Monitor Type Filter',
//                 ),
//                 items: const [
//                   DropdownMenuItem(value: 'all', child: Text('All Types')),
//                   DropdownMenuItem(value: 'ping', child: Text('Ping Monitor')),
//                   DropdownMenuItem(value: 'speed', child: Text('Speed Test')),
//                   DropdownMenuItem(
//                     value: 'connection',
//                     child: Text('Connection Monitor'),
//                   ),
//                   DropdownMenuItem(value: 'dns', child: Text('DNS Monitor')),
//                   DropdownMenuItem(
//                     value: 'leak',
//                     child: Text('Leak Detection'),
//                   ),
//                 ],
//                 onChanged: (value) => controller.applyMonitorTypeFilter(value!),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               controller.clearFilters();
//               Navigator.of(context).pop();
//             },
//             child: const Text('Clear All'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Apply'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSettingsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Health Monitor Settings'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Obx(
//               () => SwitchListTile(
//                 title: const Text('Auto Refresh'),
//                 subtitle: const Text('Automatically refresh health data'),
//                 value: controller.autoRefresh.value,
//                 onChanged: (value) => controller.toggleAutoRefresh(),
//               ),
//             ),
//             Obx(
//               () => ListTile(
//                 title: const Text('Refresh Interval'),
//                 subtitle: Text('${controller.refreshInterval.value} seconds'),
//                 trailing: DropdownButton<int>(
//                   value: controller.refreshInterval.value,
//                   onChanged: (value) =>
//                       controller.updateRefreshInterval(value!),
//                   items: const [
//                     DropdownMenuItem(value: 15, child: Text('15s')),
//                     DropdownMenuItem(value: 30, child: Text('30s')),
//                     DropdownMenuItem(value: 60, child: Text('1m')),
//                     DropdownMenuItem(value: 300, child: Text('5m')),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Methods
//   void _runAllHealthChecks() {
//     for (final monitor in controller.monitors) {
//       if (monitor.isActive) {
//         controller.performManualCheck(monitor.id);
//       }
//     }

//     Get.snackbar(
//       'Health Checks',
//       'Running health checks for all active monitors',
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//     );
//   }

//   Color _getScoreColor(double score) {
//     if (score >= 90) return Colors.green;
//     if (score >= 75) return Colors.lightGreen;
//     if (score >= 60) return Colors.orange;
//     if (score >= 40) return Colors.deepOrange;
//     return Colors.red;
//   }

//   String _formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);

//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inHours < 1) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inDays < 1) {
//       return '${difference.inHours}h ago';
//     } else {
//       return '${difference.inDays}d ago';
//     }
//   }
// }
