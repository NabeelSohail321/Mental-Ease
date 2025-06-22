import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Doctors_Listing.dart';
import 'Providers/Model_Provider.dart';
import 'UserDashboard.dart';

class Questions extends StatefulWidget {
  @override
  State<Questions> createState() => QuestionsState();
}

class QuestionsState extends State<Questions> {
  int currentQuestionIndex = 0;
  TextEditingController _textController = TextEditingController();
  String? lastInputValue;
  int? lastQuestionIndex;
  String? errorMessage;
  bool _isSubmitting = false;

  List<Map<String,dynamic>> questionsList = [
    {
      'question': 'I found myself getting upset by quite trivial things.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I was aware of dryness of my mouth.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I could not seem to experience any positive feeling at all.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I experienced breathing difficulty (eg, excessively rapid breathing,)',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I just couldn&#39;t seem to get going.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I tended to over-react to situations.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I had a feeling of shakiness (eg, legs going to give way).',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I found it difficult to relax.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I found myself in situations that made me so anxious I was most relieved when they ended.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I felt that I had nothing to look forward to.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I found myself getting upset rather easily.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I felt that I was using a lot of nervous energy.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I felt sad and depressed.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I found myself getting impatient when I was delayed in any way (eg, elevators, traffic lights)',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question' : 'I had a feeling of faintness.',
      'options' : ['Did not apply to me at all','Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time','Applied to me very much, or most of the time']
    },
    {
      'question': 'I felt that I had lost interest in just about everything.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': "I felt I wasn't worth much as a person.",
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I felt that I was rather touchy.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I perspired noticeably in the absence of high temperatures or physical exertion.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I felt scared without any good reason.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': "I felt that life wasn't worthwhile.",
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I found it hard to wind down.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I had difficulty in swallowing.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': "I couldn't seem to get any enjoyment out of the things I did.",
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I was aware of the action of my heart in the absence of physical exertion .',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I felt down-hearted and blue.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I found that I was very irritable.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I felt I was close to panic.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I found it hard to calm down after something upset me.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I feared that I would be "thrown" by some trivial but unfamiliar task.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I was unable to become enthusiastic about anything.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I found it difficult to tolerate interruptions to what I was doing.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I was in a state of nervous tension.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I felt I was pretty worthless.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I was intolerant of anything that kept me from getting on with what I was doing.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I felt terrified.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I could see nothing in the future to be hopeful about.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I felt that life was meaningless.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I found myself getting agitated.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I was worried about situations in which I might panic and make a fool of myself.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I experienced trembling (eg, in the hands).',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question': 'I found it difficult to work up the initiative to do things.',
      'options': [
        'Did not apply to me at all',
        'Applied to me to some degree, or some of the time',
        'Applied to me to a considerable degree, or a good part of the time',
        'Applied to me very much, or most of the time'
      ],
    },
    {
      'question' : 'Extraverted, enthusiastic.',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },

    {
      'question' : 'Critical, quarrelsome.',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },
    {
      'question' : 'Dependable, self-disciplined.',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },
    {
      'question' : 'Anxious, easily upset.',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },
    {
      'question' : 'Open to new experiences, complex',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },
    {
      'question' : 'Reserved, quiet.',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },
    {
      'question' : 'Sympathetic, warm.',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },
    {
      'question' : 'Disorganized, careless.',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },
    {
      'question' : 'Calm, emotionally stable.',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },
    {
      'question' : 'Conventional, uncreative.',
      'options': [
        'Disagree strongly',
        'Disagree moderately',
        'Disagree a little',
        'Neither agree nor disagree',
        'Agree a little',
        'Agree moderately',
        'Agree strongly',
      ]
    },
    {
      'question' : 'How much education have you completed?',
      'options': [
        'Less than high school',
        'High school',
        'University degree',
        'Graduate degree',

      ]
    },
    {
      'question' : 'What type of area did you live when you were a child?',
      'options': [
        'Rural (country side)',
        'Suburban',
        'Urban (town, city)',
      ]
    },
    {
      'question' : 'What is your gender?',
      'options': [
        'Male',
        'Female',
        'Other',
      ]
    },

    {
      'question' : 'How many years old are you?',
      'isTextInput': true,
      'inputType' : 'number'
    },
    {
      'question' : 'What is your religion?',
      'options': [
        'Hindu',
        'Jewish',
        'Muslim',
        'Buddhist',
        'Atheist',
        'Agnostic',
        'Christian (Other)',
        'Christian (Protestant)',
        'Christian (Mormon)',
        'Christian (Catholic)',
        'Sikh',
        'Other',
      ]
    },
    {
      'question' : 'What is your race?',
      'options': [
        'Asian',
        'Arab',
        'Black',
        'Indigenous Australian',
        'Native American',
        'White',
        'Other'
      ]
    },

    {
      'question' : 'What is your marital status?',
      'options': [
        'married	',
        'Never married',
        'Currently married',
        'Previously married',
      ]
    },
    {
      'question' : 'Including you, how many children did your mother have?',
      'isTextInput': true,
      'inputType' : 'number'
    },

  ];

  List<dynamic> selectedOptions = [];

  @override
  void initState() {
    super.initState();
    selectedOptions = List.filled(questionsList.length, null);
    _initializeController();
  }

  void _initializeController() {
    final text = selectedOptions[currentQuestionIndex]?.toString() ?? '';
    _textController = TextEditingController(text: text);
    lastInputValue = text;
    lastQuestionIndex = currentQuestionIndex;
  }

  void _showError(String message) {
    setState(() {
      errorMessage = message;
    });
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
      }
    });
  }

  void _handleNext() {
    if (selectedOptions[currentQuestionIndex] == null &&
        questionsList[currentQuestionIndex]['isTextInput'] != true) {
      _showError('Please select an option to continue');
      return;
    }

    if (currentQuestionIndex < questionsList.length - 1) {
      setState(() {
        currentQuestionIndex++;
        errorMessage = null;
      });
    }
  }

  void _handlePrevious() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        errorMessage = null;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (selectedOptions[currentQuestionIndex] == null &&
        questionsList[currentQuestionIndex]['isTextInput'] != true) {
      _showError('Please select an option to submit');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Process answers (convert from 0-3 to 1-4 for first 10 questions)
      List<dynamic> processedAnswers = selectedOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final answer = entry.value;

        if (answer is int && index < 11) { // First 10 questions use 0-3 scale
          return answer + 1; // Convert to 1-4
        }
        return answer;
      }).toList();

      final modelProvider = Provider.of<ModelProvider>(context, listen: false);

      // Ensure we await the prediction call
      await modelProvider.modelPrediction(processedAnswers);

      // Verify we have results before showing dialog
      if (modelProvider.predictionResult == null) {
        throw Exception('Prediction returned null');
      }

      // Show results
      _showPredictionResult(context);

    } catch (e) {
      _showError('Submission failed: ${e.toString()}');
      debugPrint('Submission error: $e');
      debugPrint('Selected answers: $selectedOptions');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showPredictionResult(BuildContext context) async {
    final modelProvider = Provider.of<ModelProvider>(context, listen: false);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Wait for prediction to complete if it's still processing
      while (modelProvider.isLoading) {
        await Future.delayed(Duration(milliseconds: 100));
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Verify we have a valid prediction result
      if (modelProvider.predictionResult == null) {
        throw Exception('No prediction data received');
      }

      // Show result dialog
      showDialog(
        context: context,
        builder: (context) {
          final prediction = modelProvider.predictionResult;
          final String category;
          final Color color;

          // Determine category from API response
          if (prediction['prediction'] == 'Normal') {
            category = 'Normal';
            color = Colors.green;
          } else if (prediction['prediction'] == 'Moderate') {
            category = 'Moderate';
            color = Colors.orange;
          } else if (prediction['prediction'] == 'Severe') {
            category = 'Severe';
            color = Colors.red;
          } else {
            category = 'Unknown result';
            color = Colors.grey;
          }

          return AlertDialog(
            title: Text('Assessment Result'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(prediction['prediction']),
                    size: 48,
                    color: color,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your result:',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 16),
                  if (prediction['prediction'] == 'Moderate' ||
                      prediction['prediction'] == 'Severe')
                    Text(
                      'Consider consulting a healthcare professional',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Text('OK'),
              ),
              if (prediction['prediction'] == 'Severe'||prediction['prediction'] == 'Moderate')
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => DoctorsListing()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  child: Text('Consult a doctor', style: TextStyle(color: Colors.green)),
                ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Failed to get results: ${e.toString()}'),
              SizedBox(height: 16),
              if (modelProvider.predictionResult != null)
                Text(
                  'Raw API response: ${modelProvider.predictionResult}',
                  style: TextStyle(fontSize: 10),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Normal':
        return Icons.check_circle;
      case 'Moderate':
        return Icons.warning;
      case 'Severe':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  void _showEmergencyContacts(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text('Emergency Contacts'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('National Suicide Prevention Lifeline'),
                    subtitle: Text('1-800-273-8255'),
                  ),
                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questionsList[currentQuestionIndex];
    final isLastQuestion = currentQuestionIndex == questionsList.length - 1;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 600;
    final buttonWidth = isDesktop ? screenWidth * 0.2 : screenWidth * 0.3;

    if (lastQuestionIndex != currentQuestionIndex) {
      _initializeController();
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.3),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(screenHeight * 0.03),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.03,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${currentQuestionIndex + 1} of ${questionsList.length}",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.06,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        currentQuestion['question'],
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          if (errorMessage != null)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.red[100],
              child: Center(
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red[800]),
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              child: currentQuestion['isTextInput'] == true
                  ? Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: TextField(
                  onChanged: (value) {
                    selectedOptions[currentQuestionIndex] = value;
                  },
                  key: ValueKey(currentQuestionIndex),
                  controller: _textController,
                  keyboardType: currentQuestion['inputType'] == 'number'
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters:
                  currentQuestion['inputType'] == 'number'
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z\s]'))
                  ],
                  decoration: InputDecoration(
                    labelText: 'Your answer',
                    border: OutlineInputBorder(),
                  ),
                ),
              )
                  : Column(
                children: List.generate(
                  currentQuestion['options'].length,
                      (index) {
                    final option = currentQuestion['options'][index];
                    final isSelected =
                        selectedOptions[currentQuestionIndex] == index;

                    return Container(
                      width: screenWidth * 0.9,
                      margin: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.005),
                      child: Card(
                        color: isSelected ? Color(0xFF006064) : null,
                        child: ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                selectedOptions[currentQuestionIndex] =
                                    index;
                                errorMessage = null;
                              });
                            },
                          ),
                          title: Text(
                            option,
                            style: TextStyle(
                              color:
                              isSelected ? Colors.white : Colors.black,
                              fontSize: screenHeight * 0.02,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              selectedOptions[currentQuestionIndex] =
                                  index;
                              errorMessage = null;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: buttonWidth,
                  child: ElevatedButton(
                    onPressed: currentQuestionIndex > 0 ? _handlePrevious : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF006064),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                    child: Text('Previous'),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  child: isLastQuestion
                      ? ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                  )
                      : ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF006064),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(36),
                      ),
                    ),
                    child: Text('Next'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}