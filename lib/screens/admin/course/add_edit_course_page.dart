import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/course_model.dart';
import '../../../services/firestore_service.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'package:edu_one/widgets/custom_text_area.dart';
import '../../../models/user_model.dart'; // Import the UserModel

class AddEditCoursePage extends StatefulWidget {
  final CourseModel? course;

  const AddEditCoursePage({super.key, this.course});

  @override
  State<AddEditCoursePage> createState() => _AddEditCoursePageState();
}

class _AddEditCoursePageState extends State<AddEditCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Change the state variable to hold the instructor's ID instead of the whole object.
  String? _selectedInstructorId;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Pre-fill the form if a course is provided for editing
    if (widget.course != null) {
      _nameController.text = widget.course!.name;
      _descriptionController.text = widget.course!.description;
      // Store the instructor's ID from the existing course data.
      _selectedInstructorId = widget.course!.instructor;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.course != null;
      final String courseId = isEditing ? widget.course!.id! : '';

      final courseModel = CourseModel(
        id: courseId,
        name: _nameController.text,
        description: _descriptionController.text,
        // Use the selected instructor's ID from the state variable.
        instructor: _selectedInstructorId!,
      );

      try {
        if (isEditing) {
          // Update an existing course
          await _firestoreService.updateCourse(courseModel);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course updated successfully!')),
            );
          }
        } else {
          // Add a new course
          await _firestoreService.addCourse(courseModel);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course added successfully!')),
            );
          }
        }
        if (mounted) {
          Navigator.pop(context); // Go back to the previous page
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save course: $e')));
        }
      }
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
                // Name Field
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

                // Instructor Dropdown
                StreamBuilder<List<UserModel>>(
                  stream: _firestoreService.getStaffUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading instructors: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('No instructors found.');
                    }

                    final instructors = snapshot.data!;

                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: 'Select an instructor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceVariant,
                      ),
                      // Use the string ID for the value.
                      value: _selectedInstructorId,
                      onChanged: (String? newId) {
                        setState(() {
                          _selectedInstructorId = newId;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an instructor';
                        }
                        return null;
                      },
                      items: instructors.map<DropdownMenuItem<String>>((user) {
                        // The value is the user's ID.
                        return DropdownMenuItem<String>(
                          value: user.id,
                          child: Text(user.name),
                        );
                      }).toList(),
                    );
                  },
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
