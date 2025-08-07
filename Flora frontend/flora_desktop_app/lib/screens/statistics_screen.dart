import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flora_desktop_app/providers/base_provider.dart';
import 'package:file_selector/file_selector.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isLoading = true;
  int totalUsers = 0;
  int totalOrders = 0;
  
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  List<MonthlyCountData> ordersByMonth = [];
  List<MonthlyCountData> reservationsByMonth = [];
  
  // Summary data
  int orderCount = 0;
  int reservationCount = 0;
  double donationsTotal = 0;
  int newUserCount = 0;

  @override
  void initState() {
    super.initState();
    _startDateController.text = DateFormat('yyyy-MM-dd').format(startDate);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(endDate);
    _loadData();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      await Future.wait([
        _fetchTotalUsers(),
        _fetchTotalOrders(),
        _fetchOrdersByMonth(),
        _fetchReservationsByMonth(),
        _fetchSummary(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading statistics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchTotalUsers() async {
    try {
      final result = await BaseApiService.get<int>(
        '/Statistics/total-users',
        (data) => data as int,
      );
      setState(() {
        totalUsers = result;
      });
    } on UnauthorizedException catch (e) {
      _handleAuthError(e.message);
    } on ApiException catch (e) {
      print('Error loading total users: ${e.message}');
    }
  }

  Future<void> _fetchTotalOrders() async {
    try {
      final result = await BaseApiService.get<int>(
        '/Statistics/total-orders',
        (data) => data as int,
      );
      setState(() {
        totalOrders = result;
      });
    } on UnauthorizedException catch (e) {
      _handleAuthError(e.message);
    } on ApiException catch (e) {
      print('Error loading total orders: ${e.message}');
    }
  }

  Future<void> _fetchOrdersByMonth() async {
    try {
      final result = await BaseApiService.get<List<MonthlyCountData>>(
        '/Statistics/orders-by-month',
        (data) {
          if (data is List) {
            return data.map((item) => MonthlyCountData.fromJson(item)).toList();
          }
          return <MonthlyCountData>[];
        },
      );
      setState(() {
        ordersByMonth = result;
      });
    } on UnauthorizedException catch (e) {
      _handleAuthError(e.message);
    } on ApiException catch (e) {
      print('Error loading orders by month: ${e.message}');
    }
  }

  Future<void> _fetchReservationsByMonth() async {
    try {
      final result = await BaseApiService.get<List<MonthlyCountData>>(
        '/Statistics/reservations-by-month',
        (data) {
          if (data is List) {
            return data.map((item) => MonthlyCountData.fromJson(item)).toList();
          }
          return <MonthlyCountData>[];
        },
      );
      setState(() {
        reservationsByMonth = result;
      });
    } on UnauthorizedException catch (e) {
      _handleAuthError(e.message);
    } on ApiException catch (e) {
      print('Error loading reservations by month: ${e.message}');
    }
  }

  Future<void> _fetchSummary() async {
    try {
      final queryParams = {
        'startDate': DateFormat('yyyy-MM-dd').format(startDate),
        'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      };
      
      final result = await BaseApiService.getWithParams<Map<String, dynamic>>(
        '/Statistics/summary',
        queryParams,
        (data) => data as Map<String, dynamic>,
      );
      
      setState(() {
        orderCount = result['orderCount'] ?? 0;
        reservationCount = result['reservationCount'] ?? 0;
        donationsTotal = (result['donationsTotal'] ?? 0).toDouble();
        newUserCount = result['newUserCount'] ?? 0;
      });
    } on UnauthorizedException catch (e) {
      _handleAuthError(e.message);
    } on ApiException catch (e) {
      print('Error loading summary: ${e.message}');
    }
  }

  void _handleAuthError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: $message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          endDate = picked;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
      
      // Automatically apply filter when date is changed
      _applyDateFilter();
    }
  }

  void _applyDateFilter() {
    if (startDate.isAfter(endDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start date cannot be after end date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    _fetchSummary();
  }

  Future<void> _generateReport() async {
    try {
      final queryParams = {
        'startDate': DateFormat('yyyy-MM-dd').format(startDate),
        'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      };
      
      // Postavite loading stanje
      setState(() {
        isLoading = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating report, please wait...'),
          duration: Duration(seconds: 2),
        ),
      );
      
      try {
        // Koristimo BaseApiService za dohvatanje PDF-a
        final apiUrl = '/Statistics/generate-report';
        final pdfBytes = await BaseApiService.downloadFile(apiUrl, queryParams);
        
        if (pdfBytes != null && pdfBytes.isNotEmpty) {
          // Generirajmo naziv datoteke s trenutnim datumom
          final now = DateTime.now();
          final formattedDate = DateFormat('yyyy-MM-dd_HHmm').format(now);
          final suggestedName = 'Flora_Report_${formattedDate}.pdf';
          
          // Koristimo FileSaveLocation za odabir gdje će se datoteka spremiti
          final location = await getSaveLocation(
            suggestedName: suggestedName,
            acceptedTypeGroups: <XTypeGroup>[
              XTypeGroup(
                label: 'PDF',
                extensions: ['pdf'],
              ),
            ],
          );
          
          if (location != null) {
            // Spremanje datoteke na odabranu lokaciju
            final file = XFile.fromData(
              pdfBytes,
              name: suggestedName,
              mimeType: 'application/pdf',
            );
            await file.saveTo(location.path);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report downloaded successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            // Korisnik je odustao od spremanja
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report download cancelled'),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No report data received from server'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error generating report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE91E63),
            ),
          ),
          const SizedBox(height: 25),
          
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left section (charts)
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total numbers section
                          Row(
                            children: [
                              _buildTotalCard(
                                'Total Users',
                                totalUsers.toString(),
                                const Color(0xFFE8EAFF),
                                'assets/images/user_icon.png',
                              ),
                              const SizedBox(width: 15),
                              _buildTotalCard(
                                'Total Order number',
                                totalOrders.toString(),
                                const Color(0xFFFFF8E1),
                                'assets/images/order_icon.png',
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 25),
                          
                          // Orders by month chart
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(22),
                              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Orders by months',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Expanded(
                                    child: ordersByMonth.isEmpty
                                      ? const Center(child: Text('No data available'))
                                      : LineChart(
                                          _createOrdersLineChartData(),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Reservations by month chart
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(22),
                              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Reservations by months',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Expanded(
                                    child: reservationsByMonth.isEmpty
                                      ? const Center(child: Text('No data available'))
                                      : LineChart(
                                          _createReservationsLineChartData(),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 30),
                    
                    // Right section (date filters and summary)
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select start date',
                              style: TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _startDateController,
                              readOnly: true,
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'yyyy-mm-dd',
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                isDense: true,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                                  onPressed: () => _selectDate(context, true),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 14),
                            
                            const Text(
                              'Select end date',
                              style: TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _endDateController,
                              readOnly: true,
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'yyyy-mm-dd',
                                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.grey.shade400),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                isDense: true,
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today, size: 16),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(minWidth: 30, minHeight: 30),
                                  onPressed: () => _selectDate(context, false),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 28),
                            
                            // Summary Cards
                            _buildSummaryCard(
                              'Orders',
                              orderCount.toString(),
                              Colors.green.shade50,
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryCard(
                              'Donations',
                              '${donationsTotal.toStringAsFixed(2)} KM',
                              Colors.orange.shade50,
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryCard(
                              'Reservations',
                              reservationCount.toString(),
                              Colors.blue.shade50,
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryCard(
                              'New users',
                              newUserCount.toString(),
                              Colors.purple.shade50,
                            ),
                            
                            const Spacer(),
                            
                            // Make report button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE91E63),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 1,
                                ),
                                onPressed: _generateReport,
                                child: const Text('Make report'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTotalCard(String title, String value, Color bgColor, String iconPath) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(
                  title.contains('User') ? Icons.person : Icons.shopping_bag,
                  color: bgColor == const Color(0xFFE8EAFF) 
                    ? Colors.blue 
                    : Colors.orange,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, Color bgColor) {
    IconData iconData;
    Color iconColor;
    
    switch (title) {
      case 'Orders':
        iconData = Icons.shopping_bag_outlined;
        iconColor = Colors.green;
        break;
      case 'Donations':
        iconData = Icons.favorite_outline;
        iconColor = Colors.orange;
        break;
      case 'Reservations':
        iconData = Icons.event_seat_outlined;
        iconColor = Colors.blue;
        break;
      case 'New users':
        iconData = Icons.person_add_outlined;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.bar_chart;
        iconColor = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  LineChartData _createOrdersLineChartData() {
    // Sort data by month to ensure chronological order
    final sortedData = List<MonthlyCountData>.from(ordersByMonth)
      ..sort((a, b) => a.month.compareTo(b.month));
    
    final spots = sortedData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final item = entry.value;
      return FlSpot(index, item.count.toDouble());
    }).toList();

    final maxY = sortedData.isEmpty ? 10.0 : (sortedData.map((e) => e.count).reduce((a, b) => a > b ? a : b) * 1.2).toDouble();
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value == value.roundToDouble() && value >= 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < sortedData.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat('MMM').format(sortedData[index].month),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (sortedData.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Color(0xFFFF8A65),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Color(0xFFFF8A65).withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  LineChartData _createReservationsLineChartData() {
    // Sort data by month to ensure chronological order
    final sortedData = List<MonthlyCountData>.from(reservationsByMonth)
      ..sort((a, b) => a.month.compareTo(b.month));
    
    final spots = sortedData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final item = entry.value;
      return FlSpot(index, item.count.toDouble());
    }).toList();
    
    final maxY = sortedData.isEmpty ? 10.0 : (sortedData.map((e) => e.count).reduce((a, b) => a > b ? a : b) * 1.2).toDouble();
    
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.shade100,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value == value.roundToDouble() && value >= 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 22,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < sortedData.length) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat('MMM').format(sortedData[index].month),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (sortedData.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Color(0xFFBA68C8),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: Color(0xFFBA68C8).withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}

class MonthlyCountData {
  final DateTime month;
  final int count;
  
  MonthlyCountData({
    required this.month,
    required this.count,
  });
  
  factory MonthlyCountData.fromJson(Map<String, dynamic> json) {
    return MonthlyCountData(
      month: DateTime.parse(json['month']),
      count: json['count'],
    );
  }
}