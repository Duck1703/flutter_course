import 'game_quiz_question_data.dart';

const gameSampleEasyQuestions = [
  GameQuizQuestionData(
    id: 1,
    question: 'What is the capital of Vietnam?',
    options: ['Hanoi', 'Ho Chi Minh City', 'Da Nang', 'Hai Phong'],
    correctOption: 'Hanoi',
    category: 'Geography',
    language: 'en',
    difficulty: GameQuestionDifficulty.easy,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          'Hanoi is the capital city of Vietnam, located in the northern part of the country. It has been the capital since 1976.',
      explainForWrongAnswers: {
        'Ho Chi Minh City':
            'Ho Chi Minh City is the largest city in Vietnam but not the capital.',
        'Da Nang':
            'Da Nang is a major port city in central Vietnam, but not the capital.',
        'Hai Phong':
            'Hai Phong is an important port city in northern Vietnam, but not the capital.',
      },
      aiHintMessage:
          'Think about the political center of Vietnam, located in the north.',
    ),
  ),
  GameQuizQuestionData(
    id: 2,
    question: 'How many continents are there on Earth?',
    options: ['5', '6', '7', '8'],
    correctOption: '7',
    category: 'Geography',
    language: 'en',
    difficulty: GameQuestionDifficulty.easy,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          'There are 7 continents: Africa, Antarctica, Asia, Europe, North America, Australia (Oceania), and South America.',
      explainForWrongAnswers: {
        '5':
            'This is incorrect. Some models combine continents, but the standard count is 7.',
        '6':
            'This might combine Europe and Asia into Eurasia, but the standard count is 7.',
        '8': 'There are only 7 recognized continents on Earth.',
      },
      aiHintMessage:
          'Count the major landmasses: Africa, Antarctica, Asia, Europe, North America, South America, and one more...',
    ),
  ),
  GameQuizQuestionData(
    id: 3,
    question: 'What is 2 + 2?',
    options: ['3', '4', '5', '6'],
    correctOption: '4',
    category: 'Mathematics',
    language: 'en',
    difficulty: GameQuestionDifficulty.easy,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          'Basic addition: 2 + 2 equals 4. This is one of the fundamental arithmetic operations.',
      explainForWrongAnswers: {
        '3': 'This would be the result of 1 + 2, not 2 + 2.',
        '5': 'This would be the result of 2 + 3, not 2 + 2.',
        '6': 'This would be the result of 2 x 3 or 3 + 3, not 2 + 2.',
      },
      aiHintMessage:
          'This is basic addition. What do you get when you combine two groups of two?',
    ),
  ),
  GameQuizQuestionData(
    id: 4,
    question: 'What color is the sky on a clear day?',
    options: ['Red', 'Blue', 'Green', 'Yellow'],
    correctOption: 'Blue',
    category: 'Science',
    language: 'en',
    difficulty: GameQuestionDifficulty.easy,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          "The sky appears blue due to Rayleigh scattering of sunlight in Earth's atmosphere. Shorter blue wavelengths scatter more than other colors.",
      explainForWrongAnswers: {
        'Red':
            'The sky can appear red during sunrise or sunset, but not on a clear day.',
        'Green':
            'The sky is not typically green. This color might appear during certain weather phenomena.',
        'Yellow':
            'The sun appears yellow, but the sky itself is blue on a clear day.',
      },
      aiHintMessage:
          'Think about what you see when you look up on a sunny day.',
    ),
  ),
  GameQuizQuestionData(
    id: 5,
    question: 'How many days are there in a week?',
    options: ['5', '6', '7', '8'],
    correctOption: '7',
    category: 'General Knowledge',
    language: 'en',
    difficulty: GameQuestionDifficulty.easy,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          'A week consists of 7 days: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, and Sunday.',
      explainForWrongAnswers: {
        '5':
            'This is the number of weekdays (work days), but a full week has 7 days.',
        '6': 'This is incorrect. A week has 7 days total.',
        '8': 'This is one day too many. A week has exactly 7 days.',
      },
      aiHintMessage: 'Count from Monday to Sunday. How many days is that?',
    ),
  ),
];
