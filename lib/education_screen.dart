import 'package:flutter/material.dart';
import 'services/draft_storage.dart';
import 'skills_screen.dart';
import 'resume_data.dart';

class EducationScreen extends StatefulWidget {
  final ResumeData resumeData;

  const EducationScreen({
    super.key,
    required this.resumeData,
  });

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final _formKey = GlobalKey<FormState>();

  String? selectedDegree;
  String? selectedBranch;
  String? selectedCollege;
  String? collegeError;

  final locationController = TextEditingController();
  final startYearController = TextEditingController();
  final endYearController = TextEditingController();
  final cgpaController = TextEditingController();

  final List<String> degrees = [
    'B.Tech',
    'B.E',
    'M.Tech',
    'M.E',
    'B.Sc',
    'M.Sc',
    'BCA',
    'MCA',
    'MBA',
    'Diploma',
    'Other',
  ];

  final List<String> branches = [
    'Computer Science and Engineering',
    'Artificial Intelligence and Machine Learning',
    'Artificial Intelligence and Data Science',
    'Information Technology',
    'Data Science',
    'Electronics and Communication Engineering',
    'Electrical and Electronics Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Chemical Engineering',
    'Biotechnology',
    'Other',
  ];

  final List<String> colleges = [
    'Vishnu Institute of Technology',
    'Shri Vishnu Engineering College for Women',
    'BVRIT Hyderabad College of Engineering for Women',
    'BVRIT Hyderabad College of Engineering',
    'Vignan’s Foundation for Science, Technology and Research',
    'Vignan’s Institute of Information Technology',
    'R.V.R. & J.C. College of Engineering',
    'Raghu Engineering College',
    'Gayatri Vidya Parishad College of Engineering',
    'Andhra University College of Engineering',
    'JNTU Kakinada',
    'JNTU Anantapur',
    'Sri Venkateswara University College of Engineering',
    'Pragati Engineering College',
    'Aditya Engineering College',
    'Sasi Institute of Technology and Engineering',
    'Madanapalle Institute of Technology & Science',
    'Koneru Lakshmaiah Education Foundation',
    'Velagapudi Ramakrishna Siddhartha Engineering College',
    'Lakireddy Bali Reddy College of Engineering',
    'Other',
  ];

  @override
  void dispose() {
    locationController.dispose();
    startYearController.dispose();
    endYearController.dispose();
    cgpaController.dispose();
    super.dispose();
  }

  Future<void> _selectCollege() async {
    final result = await showSearch<String?>(
      context: context,
      delegate: CollegeSearchDelegate(colleges),
    );

    if (result != null) {
      setState(() {
        selectedCollege = result;
        collegeError = null;
      });
    }
  }

  bool get _hasCurrentEducation =>
      selectedDegree != null ||
      selectedBranch != null ||
      selectedCollege != null ||
      locationController.text.trim().isNotEmpty ||
      startYearController.text.trim().isNotEmpty ||
      endYearController.text.trim().isNotEmpty ||
      cgpaController.text.trim().isNotEmpty;

  bool _appendEducation({bool clearForm = false}) {
    final collegeIsValid = selectedCollege != null &&
        selectedCollege!.trim().isNotEmpty;
    setState(() {
      collegeError = collegeIsValid ? null : 'Please select your college or university';
    });
    if (!_formKey.currentState!.validate() || !collegeIsValid) {
      return false;
    }

    final education = EducationData()
      ..degree = selectedDegree!
      ..branch = selectedBranch!
      ..college = selectedCollege!
      ..location = locationController.text.trim()
      ..startYear = startYearController.text.trim()
      ..endYear = endYearController.text.trim()
      ..cgpa = cgpaController.text.trim();

    widget.resumeData.education.add(education);
    if (clearForm) {
      setState(() {
        selectedDegree = null;
        selectedBranch = null;
        selectedCollege = null;
        collegeError = null;
        locationController.clear();
        startYearController.clear();
        endYearController.clear();
        cgpaController.clear();
        _formKey.currentState!.reset();
      });
    }
    return true;
  }

  Future<void> _saveEducation() async {
    if (_hasCurrentEducation) {
      if (!_appendEducation()) return;
    } else if (widget.resumeData.education.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one complete college education entry.'),
        ),
      );
      return;
    }
    await DraftStorage().save(widget.resumeData);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SkillsScreen(
          resumeData: widget.resumeData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Education',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Add your educational qualification.',
                    ),

                    const SizedBox(height: 28),

                    if (widget.resumeData.education.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          '${widget.resumeData.education.length} education entries added',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),

                    // DEGREE
                    DropdownButtonFormField<String>(
                      initialValue: selectedDegree,
                      decoration: const InputDecoration(
                        labelText: 'Degree *',
                        border: OutlineInputBorder(),
                      ),
                      items: degrees.map((degree) {
                        return DropdownMenuItem<String>(
                          value: degree,
                          child: Text(degree),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDegree = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your degree';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // BRANCH
                    DropdownButtonFormField<String>(
                      initialValue: selectedBranch,
                      decoration: const InputDecoration(
                        labelText: 'Branch / Course *',
                        border: OutlineInputBorder(),
                      ),
                      items: branches.map((branch) {
                        return DropdownMenuItem<String>(
                          value: branch,
                          child: Text(
                            branch,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBranch = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select your branch';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // COLLEGE SEARCH
                    InkWell(
                      onTap: _selectCollege,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'College / University *',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                          errorText: collegeError,
                        ),
                        child: Text(
                          selectedCollege ?? 'Search and select your college',
                          style: TextStyle(
                            color: selectedCollege == null
                                ? Colors.grey
                                : null,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // LOCATION
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location *',
                        hintText: 'e.g. Bhimavaram, Andhra Pradesh',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Please enter the college location'
                          : null,
                    ),

                    const SizedBox(height: 18),

                    // START YEAR
                    TextFormField(
                      controller: startYearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Start Year *',
                        hintText: 'e.g. 2024',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final year = value?.trim() ?? '';
                        if (year.isEmpty) return 'Please enter the start year';
                        if (!RegExp(r'^\d{4}$').hasMatch(year)) {
                          return 'Enter a valid 4-digit year';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // END YEAR
                    TextFormField(
                      controller: endYearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'End Year *',
                        hintText: 'e.g. 2028',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final year = value?.trim() ?? '';
                        if (year.isEmpty) return 'Please enter the end year';
                        if (!RegExp(r'^\d{4}$').hasMatch(year)) {
                          return 'Enter a valid 4-digit year';
                        }
                        final startYear = int.tryParse(startYearController.text.trim());
                        final endYear = int.tryParse(year);
                        if (startYear != null && endYear != null && endYear < startYear) {
                          return 'End year must be the same as or later than start year';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    // CGPA
                    TextFormField(
                      controller: cgpaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'CGPA / Percentage *',
                        hintText: 'e.g. 8.5',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final score = double.tryParse(
                          (value ?? '').trim().replaceAll('%', ''),
                        );
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your CGPA or percentage';
                        }
                        if (score == null || score <= 0 || score > 100) {
                          return 'Enter a score greater than 0 and at most 100';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _appendEducation(clearForm: true),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Another Education'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _saveEducation,
                        child: const Text('Save & Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CollegeSearchDelegate extends SearchDelegate<String?> {
  final List<String> colleges;

  CollegeSearchDelegate(this.colleges);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = colleges
        .where(
          (college) =>
              college.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _buildCollegeList(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = colleges
        .where(
          (college) =>
              college.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return _buildCollegeList(suggestions);
  }

  Widget _buildCollegeList(List<String> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No college found.\nTry another search.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final college = results[index];

        return ListTile(
          leading: const Icon(Icons.school),
          title: Text(college),
          onTap: () {
            close(context, college);
          },
        );
      },
    );
  }
}
