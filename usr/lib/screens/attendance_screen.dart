import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/attendance_record.dart';
import '../services/storage_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Student> students = [];
  Map<String, bool> attendanceStatus = {};
  bool isLoading = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    final loadedStudents = await StorageService.loadStudents();
    final existingRecords = await StorageService.getAttendanceByDate(selectedDate);
    
    setState(() {
      students = loadedStudents;
      
      // Initialize attendance status
      for (var student in students) {
        final existingRecord = existingRecords.firstWhere(
          (record) => record.studentId == student.id,
          orElse: () => AttendanceRecord(
            id: '',
            studentId: '',
            studentName: '',
            date: DateTime.now(),
            isPresent: false,
          ),
        );
        
        if (existingRecord.id.isNotEmpty) {
          attendanceStatus[student.id] = existingRecord.isPresent;
        } else {
          attendanceStatus[student.id] = false;
        }
      }
      
      isLoading = false;
    });
  }

  Future<void> _saveAttendance() async {
    final allRecords = await StorageService.loadAttendanceRecords();
    
    // Remove old records for the selected date
    allRecords.removeWhere((record) {
      return record.date.year == selectedDate.year &&
             record.date.month == selectedDate.month &&
             record.date.day == selectedDate.day;
    });
    
    // Add new records
    for (var student in students) {
      final record = AttendanceRecord(
        id: '${student.id}_${selectedDate.toIso8601String()}',
        studentId: student.id,
        studentName: student.name,
        date: selectedDate,
        isPresent: attendanceStatus[student.id] ?? false,
      );
      allRecords.add(record);
    }
    
    await StorageService.saveAttendanceRecords(allRecords);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadData();
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = attendanceStatus.values.where((v) => v).length;
    final totalCount = students.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: students.isEmpty ? null : _saveAttendance,
            tooltip: 'Save Attendance',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _formatDate(selectedDate),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Change Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total',
                      totalCount.toString(),
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Present',
                      presentCount.toString(),
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Absent',
                      (totalCount - presentCount).toString(),
                      Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No students to mark attendance',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add students first from Manage Students',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final isPresent = attendanceStatus[student.id] ?? false;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: CheckboxListTile(
                              value: isPresent,
                              onChanged: (bool? value) {
                                setState(() {
                                  attendanceStatus[student.id] = value ?? false;
                                });
                              },
                              title: Text(
                                student.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text('Roll No: ${student.rollNumber}'),
                              secondary: CircleAvatar(
                                backgroundColor: isPresent
                                    ? Colors.green
                                    : Colors.grey,
                                child: Text(
                                  student.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              activeColor: Colors.green,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
