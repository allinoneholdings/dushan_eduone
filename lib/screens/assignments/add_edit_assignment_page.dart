import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../widgets/custom_text_form_field.dart';
import '../../../widgets/custom_text_area.dart';

class AddEditAssignmentPage extends StatefulWidget {
  final Map<String, dynamic>? assignment;
  final String? docId;

  const AddEditAssignmentPage({super.key, this.assignment, this.docId});

  @override
  State<AddEditAssignmentPage> createState() => _AddEditAssignmentPageState();
}

class _AddEditAssignmentPageState extends State<AddEditAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController =
      TextEditingController(); // Re-purposed to display the date

  String? _selectedCourse;
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form if an assignment is provided for editing
    if (widget.assignment != null) {
      _titleController.text = widget.assignment!['title'] ?? '';
      _descriptionController.text = widget.assignment!['description'] ?? '';
      _selectedCourse = widget.assignment!['course'];

      // Convert the Firebase timestamp to a DateTime object for the picker
      if (widget.assignment!['dueDate'] != null &&
          widget.assignment!['dueDate'] is Timestamp) {
        _selectedDueDate =
            (widget.assignment!['dueDate'] as Timestamp).toDate();
        _dueDateController.text = DateFormat(
          'yyyy-MM-dd h:mm a',
        ).format(_selectedDueDate!);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  // A method to handle the saving of the form data to Firebase
  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final assignmentData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'course': _selectedCourse,
        // Save the due date as a Firebase Timestamp
        'dueDate':
            _selectedDueDate != null
                ? Timestamp.fromDate(_selectedDueDate!)
                : null,
        // Add a timestamp for ordering
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        if (widget.docId == null) {
          // Add a new assignment
          await FirebaseFirestore.instance
              .collection('assignments')
              .add(assignmentData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment added successfully!')),
          );
        } else {
          // Update an existing assignment
          await FirebaseFirestore.instance
              .collection('assignments')
              .doc(widget.docId)
              .update(assignmentData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment updated successfully!')),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save assignment: $e')),
        );
      }
    }
  }

  // Function to show the date and time picker
  Future<void> _selectDateAndTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            _selectedDueDate != null
                ? TimeOfDay.fromDateTime(_selectedDueDate!)
                : TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dueDateController.text = DateFormat(
            'yyyy-MM-dd h:mm a',
          ).format(_selectedDueDate!);
        });
      }
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

                // Course Dropdown from Firebase
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('courses')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    List<DropdownMenuItem<String>> courseItems = [];
                    for (var doc in snapshot.data!.docs) {
                      courseItems.add(
                        DropdownMenuItem(
                          value: doc['name'],
                          child: Text(doc['name']),
                        ),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedCourse,
                      hint: const Text('Select a Course'),
                      decoration: InputDecoration(
                        labelText: 'Course Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      items: courseItems,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCourse = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a course';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16.0),

                // Due Date Field with Date Picker
                InkWell(
                  onTap: () => _selectDateAndTime(context),
                  child: AbsorbPointer(
                    child: CustomTextFormField(
                      textController: _dueDateController,
                      hint: 'Due Date',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a due date';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.none,
                    ),
                  ),
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
