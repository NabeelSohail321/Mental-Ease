import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mental_ease/Admin/providers/phycologist_revenue_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:pdf/widgets.dart' as pw;

class AdminPsychologistRevenueScreen extends StatefulWidget {
  @override
  _AdminPsychologistRevenueScreenState createState() => _AdminPsychologistRevenueScreenState();
}

class _AdminPsychologistRevenueScreenState extends State<AdminPsychologistRevenueScreen> {
  late AdminPsychologistRevenueProvider _provider;
  Uint8List? _appLogo;

   pw.Font? _pdfRegularFont;
   pw.Font? _pdfBoldFont;
  @override
  void initState() {
    super.initState();
    _provider = AdminPsychologistRevenueProvider();
    _provider.fetchRevenueData();
    _provider.startRealtimeUpdates();
    _loadAppLogo();
  }

  Future<void> _loadPdfFonts() async {
    try {
      // Load font data
      final regularFontData = await rootBundle.load('assets/fonts/PlaypenSans-Regular.ttf');
      final boldFontData = await rootBundle.load('assets/fonts/PlaypenSans-Bold.ttf');

      // Create font objects
      _pdfRegularFont = pw.Font.ttf(regularFontData.buffer.asUint8List() as ByteData);
      _pdfBoldFont = pw.Font.ttf(boldFontData.buffer.asUint8List() as ByteData);
    } catch (e) {
      print('Error loading fonts: $e');
      // Fallback to default fonts if custom fonts fail to load
      _pdfRegularFont = pw.Font.helvetica();
      _pdfBoldFont = pw.Font.helveticaBold();
    }
  }

// The rest of your _generatePdf method remains the same as in my previous response
// with t

  Future<void> _loadAppLogo() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/bi_peace-fill.png');
      _appLogo = data.buffer.asUint8List();
    } catch (e) {
      print("Error loading app logo: $e");
    }
  }


  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _generatePdf(AdminPsychologistRevenueProvider provider) async {
    try {
      // Load fonts if not already loaded
      if (_pdfRegularFont == null || _pdfBoldFont == null) {
        await _loadPdfFonts();
      }

      final filteredRevenues = provider.revenues.where((revenue) {
        if (provider.showCompleted && provider.showPending) return true;
        if (provider.showCompleted && revenue.completedAppointments > 0) return true;
        if (provider.showPending && revenue.pendingAppointments > 0) return true;
        return false;
      }).toList();

      if (filteredRevenues.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No data available to generate PDF')),
        );
        return;
      }

      final pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(
            base: _pdfRegularFont,
            bold: _pdfBoldFont,
          ),
          build: (pw.Context context) {
            return [
              // Header with logo and title
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (_appLogo != null)
                    pw.Column(
                      children: [
                        pw.Image(
                          pw.MemoryImage(_appLogo!),
                          height: 60,
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text("Mental Ease",
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        )
                      ]
                    ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Psychologist Revenue Report',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Date Range: ${DateFormat('dd/MM/yyyy').format(provider.startDate)} - ${DateFormat('dd/MM/yyyy').format(provider.endDate)}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Generated on: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Summary section
              pw.Header(
                level: 1,
                text: 'Summary',
                textStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#006064'),
                ),
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(font: _pdfRegularFont),
                headers: ['Metric', 'Value'],
                data: [
                  ['Completed Revenue', '\$${provider.revenues.fold(0.0, (sum, revenue) => sum + revenue.completedRevenue).toStringAsFixed(2)}'],
                  ['Pending Revenue', '\$${provider.revenues.fold(0.0, (sum, revenue) => sum + revenue.pendingRevenue).toStringAsFixed(2)}'],
                  ['Total Revenue', '\$${provider.revenues.fold(0.0, (sum, revenue) => sum + revenue.totalRevenue).toStringAsFixed(2)}'],
                  ['Completed Appointments', provider.revenues.fold(0, (sum, revenue) => sum + revenue.completedAppointments).toString()],
                  ['Pending Appointments', provider.revenues.fold(0, (sum, revenue) => sum + revenue.pendingAppointments).toString()],
                  ['Total Appointments', provider.revenues.fold(0, (sum, revenue) => sum + revenue.totalAppointments).toString()],
                ],
              ),
              pw.SizedBox(height: 20),

              // Detailed revenue data
              pw.Header(
                level: 1,
                text: 'Psychologist Revenue Details',
                textStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Table.fromTextArray(
                context: context,
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#006064'),
                ),
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
                cellStyle: pw.TextStyle(font: _pdfRegularFont),
                headers: ['Psychologist', 'Completed', 'Pending', 'Total Revenue'],
                data: filteredRevenues.map((revenue) {
                  return [
                    revenue.doctorName ?? 'Psychologist ${revenue.doctorId.substring(0, 4)}...',
                    '${revenue.completedAppointments} (\$${revenue.completedRevenue.toStringAsFixed(2)})',
                    '${revenue.pendingAppointments} (\$${revenue.pendingRevenue.toStringAsFixed(2)})',
                    '\$${revenue.totalRevenue.toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),

              // Footer
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Text(
                'Note: Psychologists earn 90% of each appointment',
                style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic,
                  font: _pdfRegularFont,
                ),
              ),
            ];
          },
        ),
      );

      // Try to get temporary directory with fallback
      Directory output;
      try {
        output = await getTemporaryDirectory();
      } catch (e) {
        try {
          output = await getApplicationDocumentsDirectory();
        } catch (e) {
          try {
            output = await getDownloadsDirectory() ?? Directory.systemTemp;
          } catch (e) {
            output = Directory.systemTemp;
          }
        }
      }

      // Create output directory if it doesn't exist
      if (!await output.exists()) {
        await output.create(recursive: true);
      }

      final file = File('${output.path}/psychologist_revenue_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the PDF preview
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
      );
      print('PDF generation error: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AdminPsychologistRevenueProvider>.value(
      value: _provider,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        floatingActionButton: Consumer<AdminPsychologistRevenueProvider>(
          builder: (context, provider, child) {
            if (provider.revenues.isEmpty) return SizedBox.shrink();
            return FloatingActionButton.extended(
              onPressed: () => _generatePdf(provider),
              icon: Icon(Icons.picture_as_pdf,color: Colors.white,),
              label: Text('Generate PDF',style: TextStyle(color: Colors.white),),
              backgroundColor: Color(0xFF006064),
            );
          },
        ),

      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PreferredSize(
      preferredSize: Size.fromHeight(size.height * 0.2),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(size.height * 0.03)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Psychologist ',
                        style: TextStyle(
                          color: Color(0xFF006064),
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.bold,
                          fontFamily: "CustomFont",
                        ),
                      ),
                      TextSpan(
                        text: 'Revenue',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: size.height * 0.035,
                          fontWeight: FontWeight.bold,
                          fontFamily: "CustomFont",
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Divider(thickness: 2, indent: 50, endIndent: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<AdminPsychologistRevenueProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.revenues.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDateRangePicker(context, provider),
              SizedBox(height: 20),
              // _buildStatusFilter(context, provider),
              SizedBox(height: 20),
              _buildSummaryCard(context, provider),
              SizedBox(height: 20),
              _buildRevenueChart(context, provider),
              SizedBox(height: 20),
              _buildPsychologistList(context, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateRangePicker(BuildContext context, AdminPsychologistRevenueProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                context,
                'Start Date',
                provider.startDate,
                    (date) => provider.setDateRange(date, provider.endDate),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildDatePicker(
                context,
                'End Date',
                provider.endDate,
                    (date) => provider.setDateRange(provider.startDate, date),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context, AdminPsychologistRevenueProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilterChip(
                    label: Text('Completed'),
                    selected: provider.showCompleted,
                    onSelected: provider.toggleShowCompleted,
                    selectedColor: Color(0xFF80DEEA),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: FilterChip(
                    label: Text('Pending'),
                    selected: provider.showPending,
                    onSelected: provider.toggleShowPending,
                    selectedColor: Color(0xFF80DEEA),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
      BuildContext context,
      String label,
      DateTime date,
      Function(DateTime) onDateSelected,
      ) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(Duration(days: 365)),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, AdminPsychologistRevenueProvider provider) {
    final size = MediaQuery.of(context).size;
    final totalCompletedRevenue = provider.revenues.fold(
      0.0,
          (sum, revenue) => sum + revenue.completedRevenue,
    );
    final totalPendingRevenue = provider.revenues.fold(
      0.0,
          (sum, revenue) => sum + revenue.pendingRevenue,
    );
    final totalCompletedAppointments = provider.revenues.fold(
      0,
          (sum, revenue) => sum + revenue.completedAppointments,
    );
    final totalPendingAppointments = provider.revenues.fold(
      0,
          (sum, revenue) => sum + revenue.pendingAppointments,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(size.width * 0.03)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.02,
        ),
        child: Column(
          children: [
            Text(
              'Summary',
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  context,
                  'Completed Revenue',
                  '\$${totalCompletedRevenue.toStringAsFixed(2)}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildSummaryItem(
                  context,
                  'Pending Revenue',
                  '\$${totalPendingRevenue.toStringAsFixed(2)}',
                  Icons.pending,
                  Colors.orange,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.015),
            Divider(),
            SizedBox(height: size.height * 0.015),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  context,
                  'Completed Appts',
                  totalCompletedAppointments.toString(),
                  Icons.event_available,
                  Colors.green,
                ),
                _buildSummaryItem(
                  context,
                  'Pending Appts',
                  totalPendingAppointments.toString(),
                  Icons.event_busy,
                  Colors.orange,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.015),
            Divider(),
            SizedBox(height: size.height * 0.015),
            Text(
              'Psychologists earn 90% of each appointment',
              style: TextStyle(
                fontSize: size.width * 0.03,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value, IconData icon, Color color) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: width * 0.06, color: color),
        SizedBox(height: width * 0.02),
        Text(
          title,
          style: TextStyle(
            fontSize: width * 0.03,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: width * 0.01),
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.04,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart(BuildContext context, AdminPsychologistRevenueProvider provider) {
    final filteredRevenues = provider.revenues.where((revenue) {
      if (provider.showCompleted && provider.showPending) return true;
      if (provider.showCompleted && revenue.completedAppointments > 0) return true;
      if (provider.showPending && revenue.pendingAppointments > 0) return true;
      return false;
    }).toList();

    if (filteredRevenues.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 300,
              padding: EdgeInsets.all(8),
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: 45,
                  labelStyle: TextStyle(fontSize: 10),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: TextStyle(fontSize: 10),
                ),
                series: <CartesianSeries>[
                  BarSeries<PsychologistRevenue, String>(
                    dataSource: filteredRevenues,
                    xValueMapper: (revenue, _) => revenue.doctorName ?? 'Psychologist ${revenue.doctorId.substring(0, 4)}...',
                    yValueMapper: (revenue, _) => revenue.totalRevenue,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.outer,
                      textStyle: TextStyle(fontSize: 10),
                      builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                        return Text('\$${data.totalRevenue.toStringAsFixed(2)}');
                      },
                    ),
                    color: Color(0xFF006064),
                  )
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
                    final revenue = data as PsychologistRevenue;
                    return Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            revenue.doctorName ?? 'Psychologist ${revenue.doctorId.substring(0, 4)}...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006064),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text('Total Revenue: \$${revenue.totalRevenue.toStringAsFixed(2)}'),
                          Text('Completed: \$${revenue.completedRevenue.toStringAsFixed(2)}'),
                          Text('Pending: \$${revenue.pendingRevenue.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPsychologistList(BuildContext context, AdminPsychologistRevenueProvider provider) {
    final filteredRevenues = provider.revenues.where((revenue) {
      if (provider.showCompleted && provider.showPending) return true;
      if (provider.showCompleted && revenue.completedAppointments > 0) return true;
      if (provider.showPending && revenue.pendingAppointments > 0) return true;
      return false;
    }).toList();

    if (filteredRevenues.isEmpty) {
      return Center(
        child: Text(
          'No revenue data found for selected filters',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Psychologist Revenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredRevenues.length,
              itemBuilder: (context, index) {
                final revenue = filteredRevenues[index];
                return _buildPsychologistItem(context, revenue);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPsychologistItem(BuildContext context, PsychologistRevenue revenue) {
    final hasCompleted = revenue.completedAppointments > 0;
    final hasPending = revenue.pendingAppointments > 0;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFE0F7FA),
          child: Icon(Icons.person, color: Color(0xFF006064)),
        ),
        title: Text(
          revenue.doctorName ?? 'Psychologist ${revenue.doctorId}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasCompleted)
              Text(
                'Completed: ${revenue.completedAppointments} (\$${revenue.completedRevenue.toStringAsFixed(2)})',
                style: TextStyle(color: Colors.green),
              ),
            if (hasPending)
              Text(
                'Pending: ${revenue.pendingAppointments} (\$${revenue.pendingRevenue.toStringAsFixed(2)})',
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${revenue.totalRevenue.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006064),
              ),
            ),
            Text(
              '${revenue.totalAppointments} appts',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          _showRevenueDetails(context, revenue);
        },
      ),
    );
  }

  void _showRevenueDetails(BuildContext context, PsychologistRevenue revenue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Revenue Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Psychologist: ${revenue.doctorName ?? revenue.doctorId}'),
              SizedBox(height: 15),
              _buildDetailRow('Completed Appointments:', revenue.completedAppointments.toString(), Colors.green),
              _buildDetailRow('Completed Revenue:', '\$${revenue.completedRevenue.toStringAsFixed(2)}', Colors.green),
              _buildDetailRow('Pending Appointments:', revenue.pendingAppointments.toString(), Colors.orange),
              _buildDetailRow('Pending Revenue:', '\$${revenue.pendingRevenue.toStringAsFixed(2)}', Colors.orange),
              Divider(),
              _buildDetailRow('Total Appointments:', revenue.totalAppointments.toString(), Color(0xFF006064)),
              _buildDetailRow('Total Revenue:', '\$${revenue.totalRevenue.toStringAsFixed(2)}', Color(0xFF006064)),
              Divider(),
              _buildDetailRow('Avg per appt:', '\$${(revenue.totalAppointments > 0 ? revenue.totalRevenue / revenue.totalAppointments : 0).toStringAsFixed(2)}', Colors.blue),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}