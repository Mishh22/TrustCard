import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/scan_record.dart';
import '../services/scan_history_service.dart';
import '../utils/app_theme.dart';

class ScanHistoryScreen extends StatefulWidget {
  final String? cardId;

  const ScanHistoryScreen({super.key, this.cardId});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan History'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Please log in to view scan history'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cardId != null ? 'Card Scan History' : 'My Scan History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ScanRecord>>(
        stream: ScanHistoryService.getScanHistoryStream(currentUser.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorWidget(context, 'Error loading scan history: ${snapshot.error}');
          }

          final allScans = snapshot.data ?? [];
          
          // Filter scans for specific card if cardId is provided
          final scans = widget.cardId != null 
              ? allScans.where((scan) => scan.cardId == widget.cardId).toList()
              : allScans;

          if (scans.isEmpty) {
            return _buildEmptyWidget(context);
          }

          return Column(
            children: [
              // Analytics Summary
              _buildAnalyticsSummary(context, scans),
              
              // Scan List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scans.length,
                  itemBuilder: (context, index) {
                    final scan = scans[index];
                    return _buildScanCard(context, scan);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsSummary(BuildContext context, List<ScanRecord> scans) {
    final totalScans = scans.length;
    final uniqueScanners = scans.map((s) => s.scannerId).toSet().length;
    final lastScan = scans.isNotEmpty ? scans.first.scannedAt : null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scan Analytics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Scans',
                  totalScans.toString(),
                  Icons.qr_code_scanner,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Unique Scanners',
                  uniqueScanners.toString(),
                  Icons.people,
                ),
              ),
            ],
          ),
          if (lastScan != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Last scanned: ${_formatDateTime(lastScan)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(BuildContext context, ScanRecord scan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Scanner Avatar
            CircleAvatar(
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            
            // Scan Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.scannerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (scan.scannerCompany != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      scan.scannerCompany!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        scan.timeAgo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (scan.location != null) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          scan.location!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Action Button
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showScanDetails(context, scan),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_scanner_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Scans Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your card hasn\'t been scanned yet.\nShare your QR code to get started!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showScanDetails(BuildContext context, ScanRecord scan) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scan Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Scanner', scan.scannerName),
            if (scan.scannerCompany != null)
              _buildDetailRow(context, 'Company', scan.scannerCompany!),
            _buildDetailRow(context, 'Scanned At', _formatDateTime(scan.scannedAt)),
            if (scan.location != null)
              _buildDetailRow(context, 'Location', scan.location!),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}