import 'package:manus/data/models/suggestion.dart';

const List<Suggestion> kSuggestionData = <Suggestion>[
  Suggestion(
    prompt: "Help me plan a trip",
    response: "# Trip Plan: Tokyo, Japan 🇯🇵\n\n"
        "Tokyo is a vibrant mix of ultramodern and traditional.\n\n"
        "## Day 1: Shinjuku & Shibuya\n"
        "- **Morning:** Visit the Meiji Jingu Shrine.\n"
        "- **Afternoon:** Cross the famous Shibuya Crossing.\n"
        "- **Evening:** Dinner at Omoide Yokocho (Memory Lane).\n\n"
        "### Transport Tips\n"
        "> Use a **Suica** or **Pasmo** card for seamless travel on subways.\n\n"
        "| Activity | Cost | Type |\n"
        "| :--- | :--- | :--- |\n"
        "| Meiji Jingu | Free | Cultural |\n"
        "| Shibuya Sky | ¥2,200 | Observation |\n"
        "| Robot Restaurant | ¥8,000 | Entertainment |\n\n"
        "Enjoy your journey!",
  ),
  Suggestion(
    prompt: "Explain quantum computing",
    response: "## Quantum Computing ⚛️\n\n"
        "Quantum computing is a type of computing that uses quantum-mechanical phenomena, such as **superposition** and **entanglement**.\n\n"
        "### Key Concepts\n"
        "1. **Qubits:** Unlike bits (0 or 1), qubits can exist in both states simultaneously.\n"
        "2. **Entanglement:** Qubits can be linked, so the state of one affects another instantly.\n\n"
        "```python\n"
        "def quantum_logic(qubit):\n"
        "    if qubit.is_entangled:\n"
        "        return 'Instant action'\n"
        "    return 'Classical world'\n"
        "```\n\n"
        "*It's like a coin spinning on a table; while it's spinning, it's both heads and tails.*",
  ),
  Suggestion(
    prompt: "Write a short story",
    response: "### The Last Signal 🛰️\n\n"
        "The neon lights of **Sector 7** flickered in the acid rain. Elias sat by the terminal, watching the waves of data crash against his firewall.\n\n"
        "> \"Hope is the only thing stronger than fear.\"\n\n"
        "Suddenly, a message appeared. Not in code, but in plain text: *'I am still here.'* It was the signal from the Voyager probe, lost sixty years ago. But the probe wasn't sending data. It was sending a **prayer**.\n\n"
        "**The End.**",
  ),
  Suggestion(
    prompt: "Compare Flutter vs React Native",
    response: "# Framework Comparison 📱\n\n"
        "| Feature | Flutter | React Native |\n"
        "| :--- | :--- | :--- |\n"
        "| **Language** | Dart | JavaScript |\n"
        "| **Performance** | Native (Skia) | Bridge (JS) |\n"
        "| **UI** | Widget-based | Native Components |\n"
        "| **Developer** | Google | Meta |\n\n"
        "### Recommendation\n"
        "- Use **Flutter** if you want high-performance, custom UI.\n"
        "- Use **React Native** if you have a strong web background.",
  ),
  Suggestion(
    prompt: "Modern Web Tech Stack",
    response: "# Modern Web Stack 2024\n\n"
        "For a scalable application, consider this stack:\n\n"
        "### Frontend\n"
        "- **Next.js**: Server-side rendering and static generation.\n"
        "- **Tailwind CSS**: Utility-first styling.\n"
        "- **Zustand**: Lightweight state management.\n\n"
        "### Backend\n"
        "1. **Node.js** with **Hono**\n"
        "2. **PostgreSQL** with **Prisma**\n"
        "3. **Redis** for caching\n\n"
        "```typescript\n"
        "const db = await prisma.user.findUnique({\n"
        "  where: { id: user_id }\n"
        "});\n"
        "```",
  ),
  Suggestion(
    prompt: "Healthy Morning Routine",
    response: "## Your Peak Performance Morning ☀️\n\n"
        "A consistent morning routine sets the tone for the day.\n\n"
        "### The Steps\n"
        "- **06:00:** Hydrate with 500ml water.\n"
        "- **06:15:** *Mindfulness* meditation (10 mins).\n"
        "- **06:30:** Movement (yoga or a brisk walk).\n"
        "- **07:00:** Deep work block.\n\n"
        "> \"Win the morning, win the day.\"\n\n"
        "| Habit | Benefit | Difficulty |\n"
        "| :--- | :--- | :--- |\n"
        "| No Phone | Focus | High |\n"
        "| Cold Shower | Energy | Medium |\n"
        "| Journaling | Clarity | Low |",
  ),
  Suggestion(
    prompt: "Best Sci-Fi Movies",
    response: "### Must-Watch Sci-Fi 🚀\n\n"
        "1. **Inception (2010)**: Exploration of dreams within dreams.\n"
        "2. **Blade Runner 2049**: Visual masterpiece about identity.\n"
        "3. **Arrival**: Linguistic approach to first contact.\n\n"
        "--- \n\n"
        "**Fun Fact:** *Interstellar's* black hole visualization was so scientifically accurate it led to published research papers.",
  ),
  Suggestion(
    prompt: "Programming languages ranking",
    response: "# Language Popularity Index 💻\n\n"
        "Based on recent developer surveys:\n\n"
        "1. **Python**: Dominant in AI and Data Science.\n"
        "2. **JavaScript**: The backbone of the web.\n"
        "3. **TypeScript**: Bringing safety to JS.\n"
        "4. **Rust**: High performance and memory safety.\n\n"
        "### Code Snippet (Rust)\n"
        "```rust\n"
        "fn main() {\n"
        "    println!(\"Hello, Manus!\");\n"
        "}\n"
        "```",
  ),
];
