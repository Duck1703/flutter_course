import 'game_quiz_question_data.dart';

const gameSampleHardQuestions = [
  GameQuizQuestionData(
    id: 11,
    question: 'What is the speed of light in vacuum?',
    options: ['299,792 km/s', '150,000 km/s', '1,000,000 km/s', '99,792 km/s'],
    correctOption: '299,792 km/s',
    category: 'Physics',
    language: 'en',
    difficulty: GameQuestionDifficulty.hard,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          "The speed of light in vacuum is approximately 299,792,458 meters per second (or 299,792 km/s). It's a fundamental constant of nature.",
      explainForWrongAnswers: {
        '150,000 km/s':
            'This is exactly half the speed of light, but the actual value is about 300,000 km/s.',
        '1,000,000 km/s':
            'This is more than three times faster than the actual speed of light.',
        '99,792 km/s':
            'This is only about one-third of the actual speed of light.',
      },
      aiHintMessage:
          "It's approximately 300,000 km/s, a fundamental constant denoted by 'c'.",
    ),
  ),
  GameQuizQuestionData(
    id: 12,
    question: 'Who developed the theory of relativity?',
    options: [
      'Isaac Newton',
      'Albert Einstein',
      'Niels Bohr',
      'Stephen Hawking',
    ],
    correctOption: 'Albert Einstein',
    category: 'Physics',
    language: 'en',
    difficulty: GameQuestionDifficulty.hard,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          'Albert Einstein developed both the special theory of relativity (1905) and general theory of relativity (1915), revolutionizing our understanding of space, time, and gravity.',
      explainForWrongAnswers: {
        'Isaac Newton':
            "Newton developed classical mechanics and the law of universal gravitation, which Einstein's theory later expanded upon.",
        'Niels Bohr':
            'Niels Bohr made major contributions to quantum mechanics, not relativity theory.',
        'Stephen Hawking':
            "Stephen Hawking worked on black holes and cosmology, building on Einstein's work but didn't develop relativity.",
      },
      aiHintMessage:
          "This German-born physicist's equation E=mc2 is one of the most famous in science.",
    ),
  ),
  GameQuizQuestionData(
    id: 13,
    question: 'What is the capital of Kazakhstan?',
    options: ['Almaty', 'Astana', 'Nur-Sultan', 'Shymkent'],
    correctOption: 'Astana',
    category: 'Geography',
    language: 'en',
    difficulty: GameQuestionDifficulty.hard,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          'The capital is currently named Astana (as of 2022). It was previously called Nur-Sultan (2019-2022) and Astana before that (1997-2019).',
      explainForWrongAnswers: {
        'Almaty':
            "Almaty was the capital until 1997 and remains Kazakhstan's largest city and cultural hub.",
        'Nur-Sultan':
            'This was the name from 2019-2022, but the city was renamed back to Astana in 2022.',
        'Shymkent':
            'Shymkent is the third-largest city in Kazakhstan but has never been the capital.',
      },
      aiHintMessage:
          "This city's name has changed multiple times in recent decades. Check the current name as of 2022.",
    ),
  ),
  GameQuizQuestionData(
    id: 14,
    question: 'In which year was the first iPhone released?',
    options: ['2005', '2006', '2007', '2008'],
    correctOption: '2007',
    category: 'Technology',
    language: 'en',
    difficulty: GameQuestionDifficulty.hard,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          'Apple released the first iPhone on June 29, 2007. Steve Jobs unveiled it at Macworld in January 2007, revolutionizing the smartphone industry.',
      explainForWrongAnswers: {
        '2005':
            "In 2005, the iPod was popular, but the iPhone hadn't been developed yet.",
        '2006':
            "Apple was still developing the iPhone in 2006. It wasn't announced until January 2007.",
        '2008':
            'By 2008, the iPhone 3G (second generation) was released. The original came out in 2007.',
      },
      aiHintMessage:
          "Think about when touchscreen smartphones became mainstream. Steve Jobs called it 'revolutionary'.",
    ),
  ),
  GameQuizQuestionData(
    id: 15,
    question: 'What is the smallest prime number?',
    options: ['0', '1', '2', '3'],
    correctOption: '2',
    category: 'Mathematics',
    language: 'en',
    difficulty: GameQuestionDifficulty.hard,
    explanation: GameQuestionExplanationData(
      explainForTrueAnswer:
          '2 is the smallest prime number and the only even prime number. A prime number has exactly two divisors: 1 and itself.',
      explainForWrongAnswers: {
        '0': '0 is not a prime number. It has infinitely many divisors.',
        '1':
            '1 is not considered prime because it has only one divisor (itself), not two.',
        '3':
            '3 is a prime number, but not the smallest. 2 is smaller and is also prime.',
      },
      aiHintMessage:
          "Remember, prime numbers must have exactly two divisors. What's the smallest number that fits this rule?",
    ),
  ),
];
