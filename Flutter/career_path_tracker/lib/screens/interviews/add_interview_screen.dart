import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/interview.dart';
import '../../core/providers/career_provider.dart';
import '../../core/theme/app_theme.dart';

class AddInterviewScreen extends StatefulWidget {
  final Interview? interview; // If provided, we are in edit mode
  
  const AddInterviewScreen({super.key, this.interview});

  @override
  State<AddInterviewScreen> createState() => _AddInterviewScreenState();
}

class _AddInterviewScreenState extends State<AddInterviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _roleController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late InterviewStatus _selectedStatus;
  late CompanyType _selectedCompanyType;

  @override
  void initState() {
    super.initState();
    final i = widget.interview;
    _companyController = TextEditingController(text: i?.companyName ?? '');
    _roleController = TextEditingController(text: i?.jobRole ?? '');
    _locationController = TextEditingController(text: i?.location ?? '');
    _notesController = TextEditingController(text: i?.notes ?? '');
    _selectedDate = i?.date ?? DateTime.now();
    _selectedTime = i != null ? TimeOfDay.fromDateTime(i.date) : TimeOfDay.now();
    _selectedStatus = i?.status ?? InterviewStatus.scheduled;
    _selectedCompanyType = i?.companyType ?? CompanyType.product;
  }

  @override
  void dispose() {
    _companyController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveInterview() async {
    if (_formKey.currentState!.validate()) {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final interview = Interview(
        id: widget.interview?.id, // Keep ID if editing
        companyName: _companyController.text,
        jobRole: _roleController.text,
        location: _locationController.text,
        date: dateTime,
        status: _selectedStatus,
        notes: _notesController.text,
        companyType: _selectedCompanyType,
      );

      final provider = Provider.of<CareerProvider>(context, listen: false);
      if (widget.interview == null) {
        await provider.addInterview(interview);
      } else {
        await provider.updateInterview(interview);
      }
      
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.interview != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Interview' : 'Add Interview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Job Role'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              const Text("Company Type", style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTypeChip("Product Based", CompanyType.product),
                  const SizedBox(width: 12),
                  _buildTypeChip("Service Based", CompanyType.service),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location / Link'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat('MM/dd/yyyy').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<InterviewStatus>(
                initialValue: _selectedStatus,
                items: InterviewStatus.values.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedStatus = v!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveInterview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEdit ? 'Update Interview' : 'Save Interview',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, CompanyType type) {
    final isSelected = _selectedCompanyType == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (v) => setState(() => _selectedCompanyType = type),
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.3),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryColor : Colors.white12,
        ),
      ),
    );
  }
}
