import 'package:edu_one/widgets/custom_text_area.dart';
import 'package:flutter/material.dart';

import '../../../widgets/custom_text_form_field.dart';

class AddEditAssignmentPage extends StatefulWidget {
  final Map<String, dynamic>? assignment;

  const AddEditAssignmentPage({super.key, this.assignment});

  @override
  State<AddEditAssignmentPage> createState() => _AddEditAssignmentPageState();
}

class _AddEditAssignmentPageState extends State<AddEditAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _courseController = TextEditingController();
  final _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the form if an assignment is provided for editing
    if (widget.assignment != null) {
      _titleController.text = widget.assignment!['title'] ?? '';
      _descriptionController.text = widget.assignment!['description'] ?? '';
      _courseController.text = widget.assignment!['course'] ?? '';
      _dueDateController.text = widget.assignment!['dueDate'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _courseController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final assignmentData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'course': _courseController.text,
        'dueDate': _dueDateController.text,
      };

      // Handle the save logic (e.g., call a service to save to a database)
      // This is a placeholder for actual functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.assignment == null
                ? 'Assignment added successfully!'
                : 'Assignment updated successfully!',
          ),
        ),
      );
      Navigator.pop(context); // Go back to the previous page
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.assignment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Assignment' : 'Add New Assignment',
          style: textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: Icon(Icons.check, color: colorScheme.onSurface),
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Field
                CustomTextFormField(
                  textController: _titleController,
                  hint: 'Assignment Title',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16.0),

                // Description Field
                CustomTextFormArea(
                  textController: _descriptionController,
                  hint: 'Description',
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 16.0),

                // Course Field
                CustomTextFormField(
                  textController: _courseController,
                  hint: 'Course Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a course name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16.0),

                // Due Date Field
                CustomTextFormField(
                  textController: _dueDateController,
                  hint: 'Due Date',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a due date';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
