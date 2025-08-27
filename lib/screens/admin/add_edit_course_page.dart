import 'package:flutter/material.dart';

import '../../widgets/custom_text_area.dart';
import '../../widgets/custom_text_form_field.dart';

class AddEditCoursePage extends StatefulWidget {
  final Map<String, dynamic>? course;

  const AddEditCoursePage({
    super.key,
    this.course,
  });

  @override
  State<AddEditCoursePage> createState() => _AddEditCoursePageState();
}

class _AddEditCoursePageState extends State<AddEditCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the form if a course is provided for editing
    if (widget.course != null) {
      _nameController.text = widget.course!['name'] ?? '';
      _descriptionController.text = widget.course!['description'] ?? '';
      _instructorController.text = widget.course!['instructor'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final courseData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'instructor': _instructorController.text,
      };

      // Handle the save logic (e.g., call a service to save to a database)
      // This is a placeholder for actual functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.course == null
                ? 'Course added successfully!'
                : 'Course updated successfully!',
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
    final isEditing = widget.course != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Course' : 'Add New Course',
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
                // Course Name Field
                CustomTextFormField(
                  textController: _nameController,
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

                // Course Description Field
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

                // Instructor Name Field
                CustomTextFormField(
                  textController: _instructorController,
                  hint: 'Instructor Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an instructor name';
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
