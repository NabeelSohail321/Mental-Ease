import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mental_ease/Admin/providers/phycologistVerificationProvider.dart';
import 'package:mental_ease/Admin/providers/phycologist_report_provider.dart';
import 'package:provider/provider.dart';

class ReportsList extends StatelessWidget {
  final List<Report> reports;

  const ReportsList({Key? key, required this.reports}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    // Group reports by psychologist
    final reportsByPsychologist = <String, List<Report>>{};
    for (final report in reports) {
      if (!reportsByPsychologist.containsKey(report.doctorId)) {
        reportsByPsychologist[report.doctorId] = [];
      }
      reportsByPsychologist[report.doctorId]!.add(report);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reportsByPsychologist.length,
      itemBuilder: (context, index) {
        final psychologistId = reportsByPsychologist.keys.elementAt(index);
        final psychologistReports = reportsByPsychologist[psychologistId]!;
        final psychologistName = psychologistReports.first.psychologistName;

        return _buildPsychologistCard(
          context,
          psychologistId,
          psychologistName,
          psychologistReports,
          isSmallScreen,
        );
      },
    );
  }

  Widget _buildPsychologistCard(
      BuildContext context,
      String psychologistId,
      String psychologistName,
      List<Report> reports,
      bool isSmallScreen,
      ) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final padding = isSmallScreen ? 12.0 : 16.0;

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showReportsDialog(context, psychologistName, reports, isSmallScreen);
        },
        onDoubleTap: () {
          _showAdminOptionsDialog(context, psychologistId, psychologistName);
        },
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      psychologistName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 * textScaleFactor : 18 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006064),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    labelPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 4 : 8,
                    ),
                    label: Text(
                      '${reports.length} ${reports.length == 1 ? 'Report' : 'Reports'}',
                      style: TextStyle(
                        color: Color(0xFF006064),
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                    backgroundColor: const Color(0xFF80DEEA),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to view all reports',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
              Text(
                'Double tap for admin actions',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdminOptionsDialog(
      BuildContext context,
      String psychologistId,
      String psychologistName,
      ) async {
    final verificationProvider = Provider.of<PsychologistVerificationProvider>(
      context,
      listen: false,
    );
    await verificationProvider.fetchUsers();

    // Fetch the current status of the psychologist
    final psychologist = verificationProvider.users.firstWhere(
          (user) => user.id == psychologistId,
      orElse: () => User(
        id: psychologistId,
        role: 'Psychologist',
        isVerified: false,
        isListed: false,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Admin Actions for $psychologistName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Status:'),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  psychologist.isVerified ?? false ? Icons.verified : Icons.warning,
                  color: psychologist.isVerified ?? false ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  psychologist.isVerified ?? false ? 'Verified' : 'Unverified',
                  style: TextStyle(
                    color: psychologist.isVerified ?? false ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  psychologist.isListed ?? false ? Icons.visibility : Icons.visibility_off,
                  color: psychologist.isListed ?? false ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8),
                Text(
                  psychologist.isListed ?? false ? 'Listed' : 'Unlisted',
                  style: TextStyle(
                    color: psychologist.isListed ?? false ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: psychologist.isVerified ?? false ? Colors.red : Colors.green,
            ),
            onPressed: () async {
              try {
                await verificationProvider.toggleVerification(
                  psychologistId,
                  psychologist.isVerified ?? false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      psychologist.isVerified ?? false
                          ? '$psychologistName has been unverified'
                          : '$psychologistName has been verified',
                    ),
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                  ),
                );
              }
            },
            child: Text(
              psychologist.isVerified ?? false ? 'Unverify' : 'Verify',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: psychologist.isListed ?? false ? Colors.red : Colors.green,
            ),
            onPressed: () async {
              try {
                await verificationProvider.toggleListing(
                  psychologistId,
                  psychologist.isListed ?? false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      psychologist.isListed ?? false
                          ? '$psychologistName has been unlisted'
                          : '$psychologistName has been listed',
                    ),
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                  ),
                );
              }
            },
            child: Text(
              psychologist.isListed ?? false ? 'Unlist' : 'List',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }


  void _showReportsDialog(
      BuildContext context,
      String name,
      List<Report> reports,
      bool isSmallScreen,
      ) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(isSmallScreen ? 8 : 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Reports for $name',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 * textScaleFactor : 20 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006064),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: isSmallScreen ? 20 : 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6),
                width: double.infinity,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    return _buildReportItem(context, reports[index], isSmallScreen);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportItem(BuildContext context, Report report, bool isSmallScreen) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Card(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 6 : 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Report #${report.id.substring(0, 6)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF006064),
                      fontSize: isSmallScreen ? 14 * textScaleFactor : 16 * textScaleFactor,
                    ),
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(report.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: isSmallScreen ? 10 * textScaleFactor : 12 * textScaleFactor,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Reported by: ${report.patientName}',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 * textScaleFactor : 14 * textScaleFactor,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'Reason: ${report.reason}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 * textScaleFactor : 16 * textScaleFactor,
              ),
            ),
            if (report.customReport.isNotEmpty) ...[
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                'Details:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 14 * textScaleFactor : 16 * textScaleFactor,
                ),
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(
                report.customReport,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: isSmallScreen ? 12 * textScaleFactor : 14 * textScaleFactor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }}