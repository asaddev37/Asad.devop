import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';
import '../config/supabase_config.dart';
import 'custom_button.dart';
import 'custom_card.dart';

class ComplaintForm extends StatefulWidget {
  final String studentId;
  final String batchId;
  final String advisorId;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool hideBatchFields;
  final Color? cancelTextColor;

  const ComplaintForm({
    Key? key,
    required this.studentId,
    required this.batchId,
    required this.advisorId,
    this.onSubmit,
    this.onCancel,
    this.hideBatchFields = false,
    this.cancelTextColor,
  }) : super(key: key);

  @override
  _ComplaintFormState createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  String? _selectedTitle;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitComplaint() async {
    final title =
        _selectedTitle == 'Other' ? _titleController.text : _selectedTitle!;
    final description = _descriptionController.text;
    final mediaUrl = _mediaUrlController.text;

    if (title.isEmpty || description.isEmpty) {
      setState(() => _errorMessage = 'Title and description are required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? advisorId = widget.advisorId;
      if (advisorId == null || advisorId.isEmpty) {
        // Fetch advisor for the batch
        final batch = await SupabaseConfig.client
            .from('batches')
            .select('advisor_id')
            .eq('id', widget.batchId)
            .maybeSingle();
        advisorId = batch != null &&
                batch['advisor_id'] != null &&
                batch['advisor_id'].toString().isNotEmpty
            ? batch['advisor_id']
            : null;
      }
      if (advisorId != null && advisorId.isEmpty) advisorId = null;
      String? hodId;
      String status = 'Submitted';
      // Escalation logic: if not 'Other', check count in batch
      if (_selectedTitle != null && _selectedTitle != 'Other') {
        final count = await SupabaseService.countComplaintsByTitleInBatch(
          batchId: widget.batchId,
          title: title,
        );
        if (count >= 5) {
          // Escalate to HOD
          advisorId = null;
          status = 'Escalated';
          // Try to get HOD for the batch's department
          final profile = await SupabaseService.getStudentProfile();
          hodId = profile['batch']?['department']?['hod']?['id'];
        }
      }
      await SupabaseService.submitComplaint(
        studentId: widget.studentId,
        batchId: widget.batchId,
        advisorId: advisorId,
        title: title,
        description: description,
        mediaUrl: mediaUrl.isEmpty ? null : mediaUrl,
        status: status,
        hodId: hodId,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(status == 'Escalated'
                ? 'Complaint escalated to HOD!'
                : 'Complaint submitted successfully!')),
      );
      _clearForm();
      widget.onSubmit?.call();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _mediaUrlController.clear();
    setState(() => _selectedTitle = null);
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16), // Optional for spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submit Complaint',
                style: Theme.of(context).textTheme.titleLarge),
            DropdownButton<String>(
              hint: Text('Select Title'),
              value: _selectedTitle,
              items: Constants.complaintTitles
                  .map((title) =>
                  DropdownMenuItem(value: title, child: Text(title)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedTitle = value),
            ),
            if (_selectedTitle == 'Other')
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Custom Title'),
              ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _mediaUrlController,
              decoration:
              InputDecoration(labelText: 'Google Drive Link (Optional)'),
            ),
            const SizedBox(height: 8),
            if (!widget.hideBatchFields)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: widget.batchId,
                      decoration: const InputDecoration(
                        labelText: 'Batch',
                      ),
                      enabled: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: widget.advisorId ?? 'N/A',
                      decoration: const InputDecoration(
                        labelText: 'Batch Advisor',
                      ),
                      enabled: false,
                    ),
                  ),
                ],
              ),
            if (_errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              ),
            SizedBox(height: 16),
            Row(
              children: [
                if (widget.onCancel != null)
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () => widget.onCancel!(),
                      isOutlined: true,
                      textColor: widget.cancelTextColor ?? Color(0xFF1565C0),
                    ),
                  ),
                if (widget.onCancel != null) SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Submit',
                    onPressed: _submitComplaint,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

}
