import 'package:manus/data/models/suggestion.dart';

final List<Suggestion> kSuggestionData = <Suggestion>[
  Suggestion(
    prompt: "Help me plan a trip",
    response:
        "# The Ultimate 30-Day Japan Grand Tour 🇯🇵\n\n"
        "Japan is a land of contrasts, where ancient traditions meet cutting-edge technology.\n\n"
        "## Part 1: Tokyo & Surroundings (Days 1-7)\n"
        "### Day 1: Arrival and Shinjuku\n"
        "- Land at Narita/Haneda.\n"
        "- Check into your hotel in Shinjuku.\n"
        "- Explore Golden Gai.\n"
        "### Day 2: Harajuku & Shibuya\n"
        "- Meiji Shrine in the morning.\n"
        "- Takeshita Street for lunch.\n"
        "- Shibuya Crossing at sunset.\n"
        "### Day 3: Asakusa & Akihabara\n"
        "- Senso-ji Temple.\n"
        "- Gaming and electronics in Akihabara.\n"
        "### Day 4: Nikko Day Trip\n"
        "- Toshogu Shrine.\n"
        "- Kegon Falls.\n"
        "### Day 5: Mt. Fuji (Kawaguchiko)\n"
        "- Chureito Pagoda views.\n"
        "- Lake cruise.\n"
        "### Day 6: Ghibli Museum & Kichijoji\n"
        "- Museum tour.\n"
        "- Inokashira Park walk.\n"
        "### Day 7: Tsukiji & Ginza\n"
        "- Sushi breakfast.\n"
        "- High-end shopping.\n\n"
        "## Part 2: Central Japan (Days 8-14)\n"
        "### Day 8: Hakone\n"
        "- Open Air Museum.\n"
        "- Owakudani volcanic valley.\n"
        "### Day 9: Takayama\n"
        "- Old Town preserved streets.\n"
        "- Hida beef dinner.\n"
        "### Day 10: Shirakawa-go\n"
        "- Gassho-zukuri farmhouses.\n"
        "- Observation deck view.\n"
        "### Day 11: Kanazawa\n"
        "- Kenrokuen Garden (Top 3 in Japan).\n"
        "- Higashi Chaya District.\n"
        "### Day 12: Matsumoto\n"
        "- The 'Black Crow' Castle.\n"
        "- City art gallery.\n"
        "### Day 13: Kiso Valley\n"
        "- Magome to Tsumago hike.\n"
        "- Ancient post towns.\n"
        "### Day 14: Nagoya\n"
        "- SCmaglev & Railway Park.\n"
        "- Atsuta Shrine.\n\n"
        "## Part 3: Kyoto & Nara (Days 15-21)\n"
        "### Day 15: Kyoto East\n"
        "- Kiyomizu-dera.\n"
        "- Gion District stroll.\n"
        "### Day 16: Kyoto West\n"
        "- Arashiyama Bamboo Grove.\n"
        "- Tenryu-ji Temple.\n"
        "### Day 17: Kyoto North\n"
        "- Kinkaku-ji (Golden Pavilion).\n"
        "- Ryoan-ji Zen Garden.\n"
        "### Day 18: Nara Day Trip\n"
        "- Deer Park.\n"
        "- Todai-ji Giant Buddha.\n"
        "### Day 19: Uji & Fushimi Inari\n"
        "- Tea ceremony in Uji.\n"
        "- 10,000 Torii gates at Inari.\n"
        "### Day 20: Kyoto South\n"
        "- Daigo-ji Temple.\n"
        "- Sake brewery district.\n"
        "### Day 21: Kyoto Imperial Palace\n"
        "- Garden tour.\n"
        "- Traditional textile center.\n\n"
        "## Part 4: Osaka & Western Japan (Days 22-30)\n"
        "### Day 22: Osaka Castle & Dotonbori\n"
        "- Historic castle visit.\n"
        "- Food crawl in Dotonbori.\n"
        "### Day 23: Universal Studios Japan\n"
        "- Super Nintendo World.\n"
        "- Harry Potter area.\n"
        "### Day 24: Kobe\n"
        "- Nunobiki Herb Gardens.\n"
        "- Kobe harborland.\n"
        "### Day 25: Himeji\n"
        "- White Heron Castle.\n"
        "- Koko-en Garden.\n"
        "### Day 26: Hiroshima\n"
        "- Peace Memorial Park.\n"
        "- Okonomiyaki lunch.\n"
        "### Day 27: Miyajima Island\n"
        "- Itsukushima floating Torii.\n"
        "- Mt. Misen hike.\n"
        "### Day 28: Okayama\n"
        "- Korakuen Garden.\n"
        "- Kurashiki Bikan Historical Quarter.\n"
        "### Day 29: Osaka Final Shopping\n"
        "- Shinsaibashi-suji.\n"
        "- Amerikamura exploration.\n"
        "### Day 30: Departure\n"
        "- Kansai Airport return.\n\n"
        "### Budget Breakdown\n"
        "| Category | Estimated Cost | Priority |\n"
        "| :--- | :--- | :--- |\n"
        "| Flights | \$1,200 | High |\n"
        "| JR Pass | \$600 | High |\n"
        "| Accommodation | \$3,000 | Medium |\n"
        "| Food | \$1,500 | Medium |\n"
        "| Activities | \$1,000 | Low |\n\n"
        "#### Detailed Daily Itinerary Continuation\n"
        "${'Item row\n' * 450}",
  ),
  Suggestion(
    prompt: "Explain quantum computing",
    response:
        "# Deep Dive: The Quantum Frontier ⚛️\n\n"
        "Quantum computing represents a paradigm shift in how we process information.\n\n"
        "## 1. Classical vs Quantum\n"
        "In a classical computer, information is stored in bits (0 or 1).\n"
        "In a quantum computer, we use **Qubits**.\n\n"
        "### Superposition\n"
        "Imagine a coin spinning. It's not heads or tails; it's a blur of both.\n\n"
        "### Entanglement\n"
        "> \"Spooky action at a distance.\" — Albert Einstein\n\n"
        "## 2. The Mathematics of Quantum\n"
        "We represent states using Dirac notation (Bra-Ket):\n"
        "|ψ⟩ = α|0⟩ + β|1⟩\n\n"
        "## 3. Quantum Algorithms\n"
        "- **Shor's Algorithm:** Breaking RSA encryption.\n"
        "- **Grover's Algorithm:** Searching unsorted databases.\n\n"
        "```python\n"
        "import qiskit\n"
        "qc = qiskit.QuantumCircuit(2)\n"
        "qc.h(0)\n"
        "qc.cx(0, 1)\n"
        "print(qc.draw())\n"
        "```\n\n"
        "### Hardware Implementations\n"
        "1. Superconducting loops (IBM, Google)\n"
        "2. Trapped ions (IonQ)\n"
        "3. Photonic systems (Xanadu)\n\n"
        "#### Comprehensive Technical Log\n"
        "${'Quantum State Entry #\n' * 180}",
  ),
  Suggestion(
    prompt: "Write a short story",
    response:
        "# The Weaver of Echoes 📖\n\n"
        "## Chapter 1: The Static\n"
        "The city of Oakhaven was built on the remains of a forgotten civilization.\n"
        "Lila found the artifact in the basement of the old library.\n\n"
        "## Chapter 2: The Awakening\n"
        "When she touched the glass, it hummed with a frequency that vibrated in her bones.\n"
        "\"Are you there?\" a voice whispered from the static.\n\n"
        "## Chapter 3: The Journey\n"
        "They traveled through the wasteland, guided by the pulses of the device.\n"
        "> \"Every echo is a memory that refused to die.\"\n\n"
        "#### The Epic Chronicle\n"
        "${'A new day dawned over the horizon of the shifting sands...\n' * 180}",
  ),
  Suggestion(
    prompt: "Compare Flutter vs React Native",
    response:
        "# The Great Mobile Framework Showdown 📱\n\n"
        "Selecting the right framework is crucial for project success.\n\n"
        "## 1. Architectural Differences\n"
        "### Flutter Architecture\n"
        "- **Engine:** C++ Skia/Impeller\n"
        "- **Language:** Dart\n"
        "- **Communication:** Direct compilation to ARM/x86\n\n"
        "### React Native Architecture\n"
        "- **Engine:** JavaScriptCore / Hermes\n"
        "- **Language:** JavaScript/TypeScript\n"
        "- **Communication:** The Bridge (Serialization) / JSI\n\n"
        "## 2. Performance Comparison\n"
        "| Feature | Flutter | React Native |\n"
        "| :--- | :--- | :--- |\n"
        "| Startup Time | Faster | Slower |\n"
        "| List Scrolling | Very Smooth | Good |\n"
        "| Animation | 60-120 FPS | 60 FPS |\n\n"
        "## 3. Developer Ecosystem\n"
        "- **Flutter:** Excellent documentation, growing package library.\n"
        "- **React Native:** Massive existing JS community, older libraries.\n\n"
        "## 4. Code Example\n"
        "```dart\n"
        "// Flutter\n"
        "Widget build(BuildContext context) {\n"
        "  return Center(child: Text('Hello World'));\n"
        "}\n"
        "```\n\n"
        "```javascript\n"
        "// React Native\n"
        "const App = () => (\n"
        "  <View><Text>Hello World</Text></View>\n"
        ");\n"
        "```\n\n"
        "#### Detailed Technical Specification Comparison\n"
        "${'Technical Comparison Row Data Point\n' * 450}",
  ),
  Suggestion(
    prompt: "Modern Web Tech Stack",
    response:
        "# Full-Stack Mastery 2024\n\n"
        "Building for the modern web requires speed and safety.\n\n"
        "## Frontend\n"
        "- Next.js 14\n"
        "- Tailwind CSS\n"
        "## Backend\n"
        "- Bun / Node.js\n"
        "- Elysia / Hono\n\n"
        "#### Development Log\n"
        "${'Log entry updated for production readiness...\n' * 180}",
  ),
  Suggestion(
    prompt: "Healthy Morning Routine",
    response:
        "# The 5 AM Blueprint ☀️\n\n"
        "Transform your life through discipline.\n\n"
        "## Routine\n"
        "1. Water (500ml)\n"
        "2. Exercise (20 mins)\n"
        "3. Reading (15 mins)\n\n"
        "#### Daily Habit Tracker\n"
        "${'Routine completed at 05:00 AM sharp.\n' * 180}",
  ),
  Suggestion(
    prompt: "Best Sci-Fi Movies",
    response:
        "# Cinema of the Future 🚀\n\n"
        "1. Interstellar\n"
        "2. The Matrix\n"
        "3. Dune: Part Two\n\n"
        "#### Extended Review Archive\n"
        "${'Reviewing masterpiece of cinematography...\n' * 180}",
  ),
  Suggestion(
    prompt: "Programming languages ranking",
    response:
        "# The Language Hierarchy 💻\n\n"
        "1. Python\n"
        "2. JavaScript\n"
        "3. Java\n"
        "4. Dart\n\n"
        "#### Benchmark Data\n"
        "${'Performance index calculated for scale.\n' * 180}",
  ),
  Suggestion(
    prompt: "Design a minimalist logo",
    response:
        "# Less is More 🎨\n\n"
        "Guidelines for branding.\n\n"
        "#### Portfolio Entry\n"
        "${'Design revision for brand alignment...\n' * 180}",
  ),
  Suggestion(
    prompt: "Explain Machine Learning",
    response:
        "# Intelligence from Data 🧠\n\n"
        "Algorithms that learn.\n\n"
        "#### Neural Network Training Log\n"
        "${'Epoch training complete with accuracy 99.2%\n' * 180}",
  ),
  Suggestion(
    prompt: "Benefits of Meditation",
    response:
        "# Peace of Mind 🧘‍♂️\n\n"
        "Reduced stress and better focus.\n\n"
        "#### Mindfulness Session Log\n"
        "${'Breathing technique optimized for calm.\n' * 180}",
  ),
  Suggestion(
    prompt: "Create a workout plan",
    response:
        "# The Iron path 💪\n\n"
        "Push, Pull, Legs.\n\n"
        "#### Training Log Archive\n"
        "${'Set completed with progressive overload.\n' * 180}",
  ),
];
