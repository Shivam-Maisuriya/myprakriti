import 'package:flutter/material.dart';

void main() => runApp(const MyPrakritiApp());

class MyPrakritiApp extends StatelessWidget {
  const MyPrakritiApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPrakriti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: false,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
    );
  }
}

/* ===========================
   LOGIN PAGE (local-only)
   =========================== */
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (!_formKey.currentState!.validate()) return;
    // Navigate to main app and pass name/email
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainShell(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPrakriti — Login'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 6),
                      const Text('Welcome to MyPrakriti',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enter email';
                          if (!v.contains('@') || !v.contains('.com')) return 'Email must include @ and .com';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size.fromHeight(45)),
                        onPressed: _onContinue,
                        child: const Text('Continue', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================
   MAIN SHELL with BOTTOM NAV
   Holds current user/profile/dosha state
   =========================== */
class MainShell extends StatefulWidget {
  final String name;
  final String email;
  const MainShell({super.key, required this.name, required this.email});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  String? _dosha; // stores result (e.g. "Vata", "Vata + Pitta")

  void _onLogout() {
    // return to login
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _openQuizFromCheckDosha() async {
    // Push quiz page and wait for result (null = cancelled)
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => QuizScreen()),
    );

    if (result != null) {
      // user submitted; result is dosha string
      setState(() {
        _dosha = result;
        _selectedIndex = 3; // go to profile tab
      });
    } else {
      // cancelled -> go to Check Dosha tab (index 2)
      setState(() => _selectedIndex = 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      ImprovementScreen(dosha: _dosha),
      const KnowMoreScreen(),
      CheckDoshaScreen(onStartQuiz: _openQuizFromCheckDosha),
      ProfileScreen(name: widget.name, email: widget.email, dosha: _dosha, onLogout: _onLogout, onRetake: _openQuizFromCheckDosha),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Know More'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Check Dosha'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

/* ===========================
   CHECK DOSHA (start screen)
   =========================== */
class CheckDoshaScreen extends StatelessWidget {
  final VoidCallback onStartQuiz;
  const CheckDoshaScreen({super.key, required this.onStartQuiz});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Dosha'), backgroundColor: Colors.teal),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.health_and_safety, size: 84, color: Colors.teal),
                const SizedBox(height: 12),
                const Text('My Prakriti Dosha Quiz', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('Tap below to start the 30-question quiz to find your Prakriti.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onStartQuiz,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Quiz'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(160, 44)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================
   QUIZ SCREEN (pushed route)
   - All 30 questions scrollable
   - Cancel returns null (handled by caller -> stays on Check Dosha tab)
   - Submit returns dosha string to caller (caller will set profile tab)
   =========================== */
class QuizScreen extends StatefulWidget {
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // -1 = unanswered, 0 = A (Vata), 1 = B (Pitta), 2 = C (Kapha)
  final List<int> _answers = List<int>.filled(30, -1);

  // Full 30 questions as provided by you (exact wording preserved / trimmed where needed)
  final List<Map<String, dynamic>> _questions = [
    {
      'q': 'What is your body frame?',
      'opts': ["It's thin", "It's medium", "It's heavy or good built"]
    },
    {
      'q': 'Type of Hair',
      'opts': ['Dry and with Splits End', 'Normal,Thin,More Hair Fall', 'Greasy, Heavy']
    },
    {
      'q': 'Color of Hair',
      'opts': ['Pale Brown', 'Red or Brown', 'Jet Black']
    },
    {
      'q': 'Skin',
      'opts': ['Dry, Rough', 'Soft, More Sweating, Acne', 'Moist, Greasy']
    },
    {
      'q': 'Complexion',
      'opts': ['Dark, Blackish', 'Pink to Red', 'Glowing, White']
    },
    {
      'q': 'Body Weight',
      'opts': ['Low, Difficult to Put on weight', 'Medium, Can Easily Lose or Gain Weight', 'Overweight, Difficult to Lose Weight']
    },
    {
      'q': 'Nails',
      'opts': ['Blackish, Small , Brittle', 'Reddish, Small', 'Pinkish, Big, Smooth']
    },
    {
      'q': 'Size and Color of the Teeth',
      'opts': ['Very Big or Very Small, Irregular ,Blackish', 'Medium Sized, Yellowish', 'Large, Shining White']
    },
    {
      'q': 'Pace of Performing Work',
      'opts': ['Fast, Always in Hurry', 'Medium, Energetic', 'Slow, Steady']
    },
    {
      'q': 'Mental Activity',
      'opts': ['Quick, Restless', 'Smart Intellect, Aggressive', 'Calm, Stable']
    },
    {
      'q': 'Memory',
      'opts': ['Short Term Bad', 'Good Memory', 'Long Term is Best']
    },
    {
      'q': 'Grasping power',
      'opts': ['Grasps Quickly but not Completely and Forgets Quickly', 'Grasps Quickly but Completely and have Good Memory', 'Grasps Late and Retains for Longer Time']
    },
    {
      'q': 'Sleep Pattern',
      'opts': ['Interrupted , Less', 'Moderate', 'Sleepy,Lazy']
    },
    {
      'q': 'Intolerance to weather Conditions',
      'opts': ['Aversion to Cold', 'Aversion to Heat', 'Aversion to Moist, Rainy and cool weather']
    },
    {
      'q': 'Reactions Under Adverse Situation',
      'opts': ['Anxiety, Worry, Irritability', 'Anger, Aggression', 'Calm, Reclusive, Sometimes Depressive']
    },
    {
      'q': 'Mood',
      'opts': ['Changes Quickly have Frequent Mood Swings', 'Changes Slowly', 'Stable Constant']
    },
    {
      'q': 'Eating Habit',
      'opts': ['Eats Quickly Without Chewing Properly', 'Eats at a Moderate Speed', 'Chews Food Properly']
    },
    {
      'q': 'Hunger',
      'opts': ['Irregular, Any Time', 'Sudden Hunger Pangs, Sharp Hunger', 'Can Skip any Meal Easily']
    },
    {
      'q': 'Body Temperature',
      'opts': ['Less than Normal, Hands and Feets are Cold', 'More than Normal, Face and Forehead Hot', 'Normal, Hands and Feets Slightly Cold']
    },
    {
      'q': 'Joints',
      'opts': ['Weak, Noise on Movement', 'Healthy with Optimal Strength', 'Heavy Weight Bearing']
    },
    {
      'q': 'Nature',
      'opts': ['Timid, Jealous', 'Egoistic, Fearless', 'Forgiving, Greatful , Not Greedy']
    },
    {
      'q': 'Body Energy',
      'opts': ['Becomes Low in Evening, Fatigues After Less Work', 'Moderate , Gets Tired After Medium Work', 'Excellent Energy Throughout Day Not Easily Fatigued']
    },
    {
      'q': 'Eyeball',
      'opts': ['Unsteady, Fast Moving', 'Moving Slowly', 'Steady']
    },
    {
      'q': 'Quality of Voice',
      'opts': ['Rough with Broken Words', 'Fast, Commanding', 'Soft and Deep']
    },
    {
      'q': 'Dreams',
      'opts': ['Sky, Wind, Flying , Objects and Confusion', 'Fire,Light,Bright Colors, Violence', 'Water Pools, Gardens and Good Relationships']
    },
    {
      'q': 'Social Relations',
      'opts': ['Make Less Friends Prefers Solitude', 'Good No. of Friends', 'Love to Socialize. Relationships are Longer Lasting']
    },
    {
      'q': 'Wealth',
      'opts': ['Spends Without Thinking Much', 'Saves but Spends on Valuable Things', 'Prefers More Savings']
    },
    {
      'q': 'Bowel Movements',
      'opts': ['Dry, hard, Blackish, Scanty Stools', 'Soft, Yellowish, Loose Stools', 'Heavy, Thick, Stick Stools']
    },
    {
      'q': 'Walking Pace',
      'opts': ['Quick, Fast With long Steps', 'Average , Steady', 'Slow with Short Steps']
    },
    {
      'q': 'Communication Skills',
      'opts': ['Fast, Irrelevant Talk, Speech not Clear', 'Good Speakers with Genuine Argumentative Skills', 'Authoritative, Firm and Little Speech']
    },
  ];

  // helper to check if all answered
  bool get _allAnswered => !_answers.contains(-1);

  void _onCancel() {
    Navigator.pop(context, null); // indicate cancelled
  }

  void _onSubmit() {
    if (!_allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please answer all questions before submitting')));
      return;
    }

    int vata = 0, pitta = 0, kapha = 0;
    for (final a in _answers) {
      if (a == 0) vata++;
      else if (a == 1) pitta++;
      else kapha++;
    }

    // decide winners, handle ties
    final maxCount = [vata, pitta, kapha].reduce((a, b) => a > b ? a : b);
    final winners = <String>[];
    if (vata == maxCount) winners.add('Vata');
    if (pitta == maxCount) winners.add('Pitta');
    if (kapha == maxCount) winners.add('Kapha');

    final result = winners.join(' + ');
    Navigator.pop(context, result); // return dosha string to caller
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPrakriti Quiz'),
        backgroundColor: Colors.teal,
        actions: [
          TextButton(
            onPressed: _onCancel,
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _questions.length,
          itemBuilder: (context, idx) {
            final q = _questions[idx];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Q${idx + 1}. ${q['q']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  ...List.generate(3, (optIndex) {
                    final optText = q['opts'][optIndex] as String;
                    return RadioListTile<int>(
                      value: optIndex,
                      groupValue: _answers[idx],
                      title: Text(optText),
                      onChanged: (val) => setState(() => _answers[idx] = val ?? -1),
                    );
                  })
                ]),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size.fromHeight(50)),
                child: const Text('Submit', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _onCancel,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, minimumSize: const Size.fromHeight(50)),
                child: const Text('Cancel', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===========================
   PROFILE SCREEN
   Shows name/email/dosha; Logout and retake quiz
   =========================== */
class ProfileScreen extends StatelessWidget {
  final String name;
  final String email;
  final String? dosha;
  final VoidCallback onLogout;
  final VoidCallback onRetake;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.dosha,
    required this.onLogout,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: Colors.teal),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 48, backgroundColor: Colors.teal.shade200, child: const Icon(Icons.person, size: 48, color: Colors.white)),
                      const SizedBox(height: 12),
                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(email, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 14),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Text('Dosha: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(dosha ?? 'Not calculated', style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: onRetake,
                        icon: const Icon(Icons.quiz),
                        label: const Text('Check Dosha Again'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: onLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* ===========================
   KNOW MORE / Prakriti Analysis (full text)
   =========================== */
class KnowMoreScreen extends StatelessWidget {
  const KnowMoreScreen({super.key});

  final String _prakriti = '''
Prakriti Analysis

"Ayurveda Test to Identify Body Type"

Prakriti is your body constitution which is the total of one’s tri dosha percentage (vata, pitta, kapha) in a body. It is the key determinant of how one individual is different from another.

In detail, Prakriti has mentioned in Charak Samhita “Viman sthan” chapter 8. It is one of the most important investigations of ten investigations regarding patients (Dash vidh pareeksha). Prakriti is a very important diagnostic tool in Ayurveda.

Establishment of Prakriti
According to Ayurvedic texts, Prakriti is established at conception, at the time of the fusion of sperm and ovum. Prakriti remains the same throughout the life of an individual.

The formation of Prakriti is affected by the following factors:
- Prakriti of sperm
- Prakriti of ovum
- Prakriti of the uterine cavity
- Diet of a pregnant mother
- Time/season of conception
- Role of Panchmahabhuta

What is this "TRIDOSHA" and how to determine our Prakriti?
Actually, TRIDOSHA is the base of Ayurveda. It is the most important theory. The word TRIDOSHA is made by the combination of two words Tri + dosa. Tri = 3 Dosha = Energy so TRIDOSHA means a combination of three energies. These are biological or physiological and physical forces that are responsible for the metabolic functions and structural composition of our body. Kapha we can correlate to anabolism. Pitta to metabolism. Vata to catabolism. The balance of these tri-energies is known as a state of health and their imbalance is a state of disease. Anything which maintains this balance in our body is good for our health. So specific diet, exercise, behaviour or medicine can be recommended according to Prakriti to restore this balance and provide health. The tri-energies are-

Relationship Between Vata, Pitta, Kapha and the 5 Elements

In chapter 1:44 of the book Charak Samhita sutra sthan.
सर्वदा सर्व भावनां सामान्यं वृद्धिकारणम्

ह्रास हेतुः विशेष श च प्रवृति: उभय स्य तु

This means that all the tissues (sapta dhatu) in the body can be developed properly if these doshas are nourished by nutrients similar in nature to them e.g. shukra dhatu in the body is nourished by regular intake of milk and ghee. Our lifestyle also affects dosha in the body like by vigorous exercise vata increases in the body and by sitting for long hours kapha increases in the body. These are a few examples given to show you how we can co-relate doshas functions in our daily life.

The same principle applies to opposites like Tila oil massage (which has properties opposite to vata) in vataj disorder decreases vata. This is an example which shows how opposite things can balance other doshas. Don’t get confused keep reading forward things are going to be clear.

To increase any dosha/dhatu in the body we need to choose the same herbs/dietary regimens, while to decrease any dosha/dhatu in the body we need to choose the opposite herbs/dietary regimens.

Now the question can come to our mind that why we should know our Prakriti.
According to Ayurvedic texts, Prakriti tells us about the vulnerability of an individual to develop particular types of diseases throughout his lifetime. There is a beautiful example that if a vata-type person develops vataj disorder then its prediction is difficult. If a Kapha-type or pitta-type person develops a similar vataj disease then the prediction is better and the disease is likely to be cured easily.

Prakriti Analysis using Tridoshas or Trienergies of the body plays a very important role in the diagnosis and treatment of the disease. Not only this but this Diagnostic tool also helps you to know about particular dietary regimens and herbs to avoid or to prefer. Prakriti Analysis helps us to maintain a healthy lifestyle as well.

So we should know our Prakriti to understand -
- I am what? I’m a Vata person or a Pitta person or a Kapha person? (Actually, who am I?)
- What food suits me?
- What foodstuff should I avoid?
- What foodstuff should I consume in moderation?
- Which food I can eat occasionally?
- How should be my lifestyle?
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Know More — Prakriti Analysis'), backgroundColor: Colors.teal),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prakriti Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
                    const SizedBox(height: 8),
                    Text('"Ayurveda Test to Identify Body Type"', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 14),
                    Text(_prakriti, style: const TextStyle(fontSize: 15, height: 1.5)),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.teal.shade50,
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Reference', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text('Charak Samhita — Viman sthan, chapter 8. Prakriti is one of ten important investigations.')
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
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

/* ===========================
   IMPROVEMENT PAGE (Home) - basic UI that can show tips later by dosha
   =========================== */
class ImprovementScreen extends StatelessWidget {
  final String? dosha;
  const ImprovementScreen({super.key, this.dosha});

  @override
  Widget build(BuildContext context) {
    String body;
    if (dosha == null) {
      body = 'Take the quiz to get personalized improvement tips for your Prakriti.';
    } else if (dosha == 'Vata') {
      body = 'Vata Tips:\n• Prefer warm cooked foods\n• Keep regular routine\n• Gentle yoga and oils';
    } else if (dosha == 'Pitta') {
      body = 'Pitta Tips:\n• Avoid spicy fried food\n• Stay cool and hydrated\n• Calming activities';
    } else if (dosha == 'Kapha') {
      body = 'Kapha Tips:\n• Light, spicy foods\n• Regular cardio exercise\n• Avoid heavy & oily foods';
    } else {
      body = 'Balanced / Combined: follow a mixed plan tailored to your dominant doshas.';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Home — Improvements'), backgroundColor: Colors.teal),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(body, style: const TextStyle(fontSize: 16, height: 1.5)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
