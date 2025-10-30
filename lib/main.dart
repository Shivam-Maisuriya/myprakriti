import 'package:flutter/material.dart';

void main() {
  runApp(const MyPrakritiApp());
}

/// A simple global theme notifier to allow switching theme from Profile tab.
/// We use a ValueNotifier so MaterialApp can listen and rebuild themeMode.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class MyPrakritiApp extends StatelessWidget {
  const MyPrakritiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'MyPrakriti',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: _lightTheme,
          darkTheme: _darkTheme,
          home: const LoginPage(),
        );
      },
    );
  }
}

/// Light theme (natural/pastel)
final ThemeData _lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFFAF8F2), // beige-like
  cardColor: Colors.white,
  brightness: Brightness.light,
  primaryColor: Colors.teal,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
  ),
);

/// Dark theme (earthy)
final ThemeData _darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown, brightness: Brightness.dark),
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF1F1A17),
  cardColor: const Color(0xFF2C2724),
  brightness: Brightness.dark,
  primaryColor: Colors.brown,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
  ),
);

/// ---------------------------
/// LOGIN PAGE (local only)
/// ---------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_form.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    // Open main shell and pass user details
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MainShell(name: name, email: email)),
    );
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter email';
    if (!v.contains('@') || !v.contains('.com')) return 'Email must contain "@" and ".com"';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPrakriti — Login'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _form,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 6),
                      Text('Welcome to MyPrakriti',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          )),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _continue,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.0),
                          child: Text('Continue', style: TextStyle(fontSize: 16)),
                        ),
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

/// ---------------------------
/// MAIN SHELL with Bottom Nav
/// Holds user state: name, email, dosha
/// ---------------------------
class MainShell extends StatefulWidget {
  final String name;
  final String email;
  const MainShell({super.key, required this.name, required this.email});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  String? _doshaResult; // e.g., "Vata" or "Vata + Pitta"

  // Called when user wants to retake or start quiz — we push QuizScreen and await result:
  Future<void> _startQuiz() async {
    final result = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const QuizScreen()),
    );

    if (result == null) {
      // user cancelled → show Check Dosha tab (index 2)
      setState(() => _currentIndex = 2);
    } else {
      // user submitted → set dosha and switch to Profile tab
      setState(() {
        _doshaResult = result;
        _currentIndex = 3;
      });
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // pages
    final pages = <Widget>[
      ImprovementHome(dosha: _doshaResult),
      const KnowMoreScreen(),
      CheckDoshaStart(onStart: _startQuiz),
      ProfileScreen(
        name: widget.name,
        email: widget.email,
        dosha: _doshaResult,
        onRetake: _startQuiz,
        onLogout: _logout,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
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

/// ---------------------------
/// CHECK DOSHA starting page (tab)
/// ---------------------------
class CheckDoshaStart extends StatelessWidget {
  final VoidCallback onStart;
  const CheckDoshaStart({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Dosha'), backgroundColor: Theme.of(context).colorScheme.primary),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.health_and_safety, size: 78, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    const Text('My Prakriti Dosha Quiz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('A 30-question questionnaire to help identify your Prakriti (Vata / Pitta / Kapha).',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: onStart,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Quiz'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(160, 44)),
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

/// ---------------------------
/// QUIZ SCREEN — All 30 Questions
/// Cancel => returns null to caller (shell) which keeps Check Dosha tab
/// Submit => returns dosha string to caller; shell will set Profile tab
/// ---------------------------
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // -1 unanswered, 0 => A (Vata), 1 => B (Pitta), 2 => C (Kapha)
  final List<int> _answers = List<int>.filled(30, -1);

  final List<Map<String, Object>> _questions = [
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

  bool get _allAnswered => !_answers.contains(-1);

  void _onCancel() {
    Navigator.pop(context, null);
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

    final maxCount = [vata, pitta, kapha].reduce((a, b) => a > b ? a : b);
    final winners = <String>[];
    if (vata == maxCount) winners.add('Vata');
    if (pitta == maxCount) winners.add('Pitta');
    if (kapha == maxCount) winners.add('Kapha');

    final result = winners.join(' + ');
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPrakriti Quiz'),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
          itemBuilder: (context, index) {
            final q = _questions[index];
            final opts = q['opts'] as List<String>;
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Q${index + 1}. ${q['q']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < opts.length; i++)
                    RadioListTile<int>(
                      title: Text(opts[i]),
                      value: i,
                      groupValue: _answers[index],
                      onChanged: (val) => setState(() => _answers[index] = val ?? -1),
                    ),
                ]),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
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
      ),
    );
  }
}

/// ---------------------------
/// PROFILE SCREEN
/// - shows name, email, dosha
/// - theme toggle
/// - logout and retake quiz
/// ---------------------------
class ProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String? dosha;
  final VoidCallback onRetake;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.dosha,
    required this.onRetake,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool get _isDark => themeNotifier.value == ThemeMode.dark;

  void _toggleTheme(bool newVal) {
    themeNotifier.value = newVal ? ThemeMode.dark : ThemeMode.light;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(widget.email, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 14),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Text('Dosha: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(widget.dosha ?? 'Not calculated', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: widget.onRetake,
                      icon: const Icon(Icons.quiz),
                      label: const Text('Check Dosha Again'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, minimumSize: const Size(180, 44)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(180, 44)),
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Switch(
                        value: _isDark,
                        onChanged: _toggleTheme,
                        activeColor: Theme.of(context).colorScheme.primary,
                      )
                    ]),
                    const SizedBox(height: 6),
                    Text(_isDark ? 'Dark Earthy theme' : 'Light Natural theme', style: const TextStyle(color: Colors.grey))
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------
/// KNOW MORE (Prakriti Analysis) — full text
/// ---------------------------
class KnowMoreScreen extends StatelessWidget {
  const KnowMoreScreen({super.key});

  final String _content = '''
Prakriti Analysis

"Ayurveda Test to Identify Body Type"

Prakriti is your body constitution which is the total of one’s tri dosha percentage (vata, pitta, kapha) in a body. It is the key determinant of how one individual is different from another.

In detail, Prakriti has mentioned in Charak Samhita “Viman sthan” chapter 8. It is one of the most important investigations of ten investigations regarding patients (Dash vidh pareeksha). Prakriti is a very important diagnostic tool in Ayurveda.

Establishment of Prakriti
According to Ayurvedic texts, Prakriti is established at conception, at the time of the fusion of sperm and ovum. Prakriti remains the same throughout the life of an individual.

The formation of Prakriti is affected by the following factors:
Prakriti of sperm
Prakriti of ovum
Prakriti of the uterine cavity
Diet of a pregnant mother
Time/season of conception
Role of Panchmahabhuta

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
I am what? I’m a Vata person or a Pitta person or a kapha person? (Actually, who am I?)
What food suits me?
What foodstuff should I avoid?
What foodstuff should I consume in moderation?
Which food I can eat occasionally?
How should be my lifestyle?
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Know More — Prakriti Analysis'), backgroundColor: Theme.of(context).colorScheme.primary),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Prakriti Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                const Text('"Ayurveda Test to Identify Body Type"', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                const SizedBox(height: 14),
                Text(_content, style: const TextStyle(fontSize: 15, height: 1.5)),
                const SizedBox(height: 20),
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text('Reference', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('Charak Samhita — Viman sthan, chapter 8. Prakriti is one of ten important investigations.'),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------
/// IMPROVEMENT HOME (Home tab)
/// shows detailed tips depending on dosha if available
/// ---------------------------
class ImprovementHome extends StatelessWidget {
  final String? dosha;
  const ImprovementHome({super.key, this.dosha});

  @override
  Widget build(BuildContext context) {
    String title = 'Welcome to MyPrakriti';
    String body =
        'Take the quiz in the "Check Dosha" tab to discover your body type and receive personalized improvement tips based on Ayurveda.';

    // Detailed improvement tips for each dosha
    if (dosha != null) {
      if (dosha!.contains('Vata') && !dosha!.contains('+')) {
        title = 'Vata Balance & Lifestyle Tips';
        body = '''
🧘‍♀️ **General Nature:** Creative, energetic, quick-moving but can become anxious or tired easily.

🍲 **Diet Tips:**
• Prefer warm, moist, well-cooked meals (soups, stews, porridges).  
• Include ghee, warm milk, and root vegetables.  
• Avoid raw, dry, or cold foods.  
• Stay hydrated and eat at regular times.

💤 **Lifestyle:**
• Maintain a consistent daily routine.  
• Avoid overstimulation and multitasking.  
• Sleep early, wake early, and rest well.  
• Use gentle oil massage (Sesame oil) daily.

🧘‍♂️ **Yoga & Exercise:**
• Do calming, grounding yoga like Hatha or Yin.  
• Avoid excessive running; prefer stretching, walking, and meditation.
''';
      } else if (dosha!.contains('Pitta') && !dosha!.contains('+')) {
        title = 'Pitta Balance & Lifestyle Tips';
        body = '''
🔥 **General Nature:** Intelligent, ambitious, focused but can become irritable or overheated.

🍎 **Diet Tips:**
• Favor cool, fresh, non-spicy foods.  
• Eat cucumbers, melons, leafy greens, and milk.  
• Avoid fried, sour, and spicy dishes.  
• Drink coconut water or herbal teas (rose, mint).

💤 **Lifestyle:**
• Stay cool — both mentally and physically.  
• Practice forgiveness, patience, and relaxation.  
• Avoid skipping meals.  
• Spend time in nature and near water.

🧘‍♂️ **Yoga & Exercise:**
• Gentle cooling yoga (Moon salutations, Shitali pranayama).  
• Avoid competitive sports.  
• Swim or walk during cooler times of the day.
''';
      } else if (dosha!.contains('Kapha') && !dosha!.contains('+')) {
        title = 'Kapha Balance & Lifestyle Tips';
        body = '''
🌿 **General Nature:** Calm, loving, and grounded but can become lazy or attached.

🥗 **Diet Tips:**
• Prefer light, dry, and spicy foods.  
• Use more ginger, black pepper, and honey.  
• Avoid heavy, oily, and sweet meals.  
• Limit dairy and cold beverages.

💤 **Lifestyle:**
• Stay active — avoid daytime naps.  
• Engage in stimulating new activities.  
• Keep warm and avoid damp weather.  
• Practice regular cleansing or fasting (if suitable).

🏃 **Yoga & Exercise:**
• Energizing and warming yoga — Surya Namaskar, Vinyasa flow.  
• Regular cardio and outdoor walks.  
• Uplifting music and dynamic breathwork (Bhastrika).
''';
      } else {
        title = 'Balanced or Dual Dosha Tips';
        body = '''
⚖️ **General Nature:** You have traits from multiple doshas — balance is key.

🌿 **Diet Tips:**
• Eat seasonal, fresh, cooked meals.  
• Avoid extremes — too spicy, too cold, too oily, or too dry.  
• Hydrate moderately and eat mindfully.

💤 **Lifestyle:**
• Balance work and rest.  
• Practice regular sleep and meal schedules.  
• Use moderate physical activity daily.  
• Follow meditation to balance mental energy.

🧘‍♂️ **Yoga & Exercise:**
• Mix gentle and moderate yoga — alternate slow and active days.  
• Deep breathing and mindfulness will help balance your doshas.
''';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home — Improvements'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        body,
                        style: const TextStyle(fontSize: 16, height: 1.6),
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

