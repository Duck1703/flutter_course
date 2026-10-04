class GameMoneyLadderLevelData {
  final int level;
  final int amount;
  final bool isSafeHaven;
  final String difficulty;

  const GameMoneyLadderLevelData({
    required this.level,
    required this.amount,
    required this.isSafeHaven,
    required this.difficulty,
  });
}

const gameMoneyLadderLevels = [
  GameMoneyLadderLevelData(
    level: 1,
    amount: 1000,
    isSafeHaven: false,
    difficulty: 'Easy',
  ),
  GameMoneyLadderLevelData(
    level: 2,
    amount: 2000,
    isSafeHaven: false,
    difficulty: 'Easy',
  ),
  GameMoneyLadderLevelData(
    level: 3,
    amount: 5000,
    isSafeHaven: false,
    difficulty: 'Easy',
  ),
  GameMoneyLadderLevelData(
    level: 4,
    amount: 10000,
    isSafeHaven: false,
    difficulty: 'Easy',
  ),
  GameMoneyLadderLevelData(
    level: 5,
    amount: 20000,
    isSafeHaven: true,
    difficulty: 'Easy',
  ),
  GameMoneyLadderLevelData(
    level: 6,
    amount: 40000,
    isSafeHaven: false,
    difficulty: 'Medium',
  ),
  GameMoneyLadderLevelData(
    level: 7,
    amount: 80000,
    isSafeHaven: false,
    difficulty: 'Medium',
  ),
  GameMoneyLadderLevelData(
    level: 8,
    amount: 150000,
    isSafeHaven: false,
    difficulty: 'Medium',
  ),
  GameMoneyLadderLevelData(
    level: 9,
    amount: 250000,
    isSafeHaven: false,
    difficulty: 'Medium',
  ),
  GameMoneyLadderLevelData(
    level: 10,
    amount: 400000,
    isSafeHaven: true,
    difficulty: 'Medium',
  ),
  GameMoneyLadderLevelData(
    level: 11,
    amount: 500000,
    isSafeHaven: false,
    difficulty: 'Hard',
  ),
  GameMoneyLadderLevelData(
    level: 12,
    amount: 600000,
    isSafeHaven: false,
    difficulty: 'Hard',
  ),
  GameMoneyLadderLevelData(
    level: 13,
    amount: 750000,
    isSafeHaven: false,
    difficulty: 'Hard',
  ),
  GameMoneyLadderLevelData(
    level: 14,
    amount: 900000,
    isSafeHaven: false,
    difficulty: 'Hard',
  ),
  GameMoneyLadderLevelData(
    level: 15,
    amount: 1000000,
    isSafeHaven: true,
    difficulty: 'Hard',
  ),
];
