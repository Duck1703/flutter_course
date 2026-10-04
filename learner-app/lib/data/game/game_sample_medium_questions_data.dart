import 'game_quiz_question_data.dart';

const gameSampleMediumQuestions = [
  GameQuizQuestionData(
    id: 6,
    question: "Who wrote 'Romeo and Juliet'?",
    options: [
      'Charles Dickens',
      'William Shakespeare',
      'Mark Twain',
      'Jane Austen',
    ],
    correctOption: 'William Shakespeare',
    category: 'Literature',
    language: 'en',
    difficulty: GameQuestionDifficulty.medium,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          "William Shakespeare wrote Romeo and Juliet around 1594-1596. It's one of his most famous tragedies.",
      explainForWrongAnswers: {
        'Charles Dickens':
            "Charles Dickens was a Victorian novelist who wrote works like 'A Tale of Two Cities' and 'Great Expectations'.",
        'Mark Twain':
            "Mark Twain was an American writer known for 'The Adventures of Tom Sawyer' and 'Adventures of Huckleberry Finn'.",
        'Jane Austen':
            "Jane Austen was an English novelist known for 'Pride and Prejudice' and 'Sense and Sensibility'.",
      },
      aiHintMessage:
          'This famous playwright lived in Elizabethan England and wrote many tragedies.',
    ),
  ),
  GameQuizQuestionData(
    id: 7,
    question: 'What is the chemical symbol for gold?',
    options: ['Go', 'Gd', 'Au', 'Ag'],
    correctOption: 'Au',
    category: 'Chemistry',
    language: 'en',
    difficulty: GameQuestionDifficulty.medium,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          "Au comes from the Latin word 'aurum' meaning gold. Gold is element 79 on the periodic table.",
      explainForWrongAnswers: {
        'Go': 'There is no element with the symbol Go in the periodic table.',
        'Gd': 'Gd is the symbol for Gadolinium, a rare earth element.',
        'Ag': "Ag is the symbol for silver, from the Latin word 'argentum'.",
      },
      aiHintMessage:
          "Think about the Latin origin of this precious metal's name.",
    ),
  ),
  GameQuizQuestionData(
    id: 8,
    question: 'In which year did World War II end?',
    options: ['1943', '1944', '1945', '1946'],
    correctOption: '1945',
    category: 'History',
    language: 'en',
    difficulty: GameQuestionDifficulty.medium,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          'World War II ended in 1945. Germany surrendered in May, and Japan surrendered in September after the atomic bombings.',
      explainForWrongAnswers: {
        '1943':
            'The war was still ongoing in 1943 with major battles in Europe and the Pacific.',
        '1944': '1944 saw the D-Day invasion, but the war continued into 1945.',
        '1946':
            'The war had already ended by 1946. Post-war reconstruction had begun.',
      },
      aiHintMessage: 'Think about when the atomic bombs were dropped on Japan.',
    ),
  ),
  GameQuizQuestionData(
    id: 9,
    question: 'What is the largest planet in our solar system?',
    options: ['Earth', 'Saturn', 'Jupiter', 'Neptune'],
    correctOption: 'Jupiter',
    category: 'Astronomy',
    language: 'en',
    difficulty: GameQuestionDifficulty.medium,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          'Jupiter is the largest planet in our solar system with a mass about 318 times that of Earth and a diameter of about 143,000 km.',
      explainForWrongAnswers: {
        'Earth':
            "Earth is relatively small compared to the gas giants. It's the fifth largest planet.",
        'Saturn':
            'Saturn is the second largest planet, famous for its rings, but smaller than Jupiter.',
        'Neptune':
            'Neptune is the fourth largest planet and the farthest from the Sun.',
      },
      aiHintMessage:
          'This gas giant is known for its Great Red Spot storm and has the most moons.',
    ),
  ),
  GameQuizQuestionData(
    id: 10,
    question: 'Who painted the Mona Lisa?',
    options: [
      'Vincent van Gogh',
      'Pablo Picasso',
      'Leonardo da Vinci',
      'Michelangelo',
    ],
    correctOption: 'Leonardo da Vinci',
    category: 'Art',
    language: 'en',
    difficulty: GameQuestionDifficulty.medium,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          "Leonardo da Vinci painted the Mona Lisa between 1503 and 1519. It's now housed in the Louvre Museum in Paris.",
      explainForWrongAnswers: {
        'Vincent van Gogh':
            "Van Gogh was a Dutch post-impressionist painter known for 'Starry Night' and 'Sunflowers'.",
        'Pablo Picasso':
            'Picasso was a Spanish painter and sculptor, co-founder of Cubism, who lived much later than the Mona Lisa.',
        'Michelangelo':
            'Michelangelo was a contemporary of da Vinci but is more famous for the Sistine Chapel ceiling.',
      },
      aiHintMessage:
          'This Renaissance polymath was also an inventor and scientist.',
    ),
  ),
];
