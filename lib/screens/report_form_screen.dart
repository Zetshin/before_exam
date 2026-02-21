import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/station.dart';
import '../models/violation_type.dart';
import '../models/incident_report.dart';
import '../services/api_service.dart';

class ReportFormScreen extends StatefulWidget {
  final IncidentReport? report; // null = create, non-null = edit

  const ReportFormScreen({super.key, this.report});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reporterController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Station> _stations = [];
  List<ViolationType> _types = [];
  int? _selectedStationId;
  int? _selectedTypeId;
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stations = await ApiService.getStations();
      final types = await ApiService.getViolationTypes();
      setState(() {
        _stations = stations;
        _types = types;
        _isLoading = false;

        if (widget.report != null) {
          _selectedStationId = widget.report!.stationId;
          _selectedTypeId = widget.report!.typeId;
          _reporterController.text = widget.report!.reporterName;
          _descriptionController.text = widget.report!.description ?? '';
          // Parse existing timestamp for edit mode
          try {
            _selectedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(widget.report!.timestamp);
          } catch (_) {
            _selectedDateTime = DateTime.now();
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStationId == null || _selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกสถานีและประเภทการทุจริต')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDateTime);

      final report = IncidentReport(
        stationId: _selectedStationId!,
        typeId: _selectedTypeId!,
        reporterName: _reporterController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        timestamp: widget.report?.timestamp ?? timestamp,
        aiResult: widget.report?.aiResult,
        aiConfidence: widget.report?.aiConfidence,
      );

      if (widget.report == null) {
        await ApiService.createReport(report);
      } else {
        await ApiService.updateReport(widget.report!.reportId!, report);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _reporterController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.report != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'แก้ไขรายงาน' : 'สร้างรายงานใหม่'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Station dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedStationId,
                      decoration: const InputDecoration(
                        labelText: 'หน่วยเลือกตั้ง',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      items: _stations.map((s) {
                        return DropdownMenuItem(value: s.stationId, child: Text(s.stationName));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedStationId = value),
                      validator: (value) => value == null ? 'กรุณาเลือกหน่วยเลือกตั้ง' : null,
                    ),
                    const SizedBox(height: 16),

                    // Violation type dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedTypeId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'ประเภทการทุจริต',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber),
                      ),
                      items: _types.map((t) {
                        return DropdownMenuItem(value: t.typeId, child: Text(t.typeName));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedTypeId = value),
                      validator: (value) => value == null ? 'กรุณาเลือกประเภทการทุจริต' : null,
                    ),
                    const SizedBox(height: 16),

                    // Reporter name
                    TextFormField(
                      controller: _reporterController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อผู้แจ้ง',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'กรุณากรอกชื่อผู้แจ้ง' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียดเหตุการณ์',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),

                    // Timestamp picker
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today, color: Colors.red),
                        title: const Text('วัน-เวลาเกิดเหตุ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy  HH:mm น.').format(_selectedDateTime),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        onTap: _pickDateTime,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveReport,
                      icon: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'กำลังบันทึก...' : (isEdit ? 'อัปเดตรายงาน' : 'บันทึกรายงาน')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
