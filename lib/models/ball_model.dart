
class BallModel {
  final String id;
  final int runs;
  final bool isWicket;
  final bool isWide;
  final bool isNoBall;
  final bool isBye;
  final bool isLegBye;
  final bool isUndo;
  final String wicketType;
  final String outPlayerId;
  final int extraRuns;
  final bool changeStrike;

  const BallModel({
    required this.id,
    required this.runs,
    this.isWicket = false,
    this.isWide = false,
    this.isNoBall = false,
    this.isBye = false,
    this.isLegBye = false,
    this.isUndo = false,
    this.wicketType = '',
    this.outPlayerId = '',
    this.extraRuns = 0,
    this.changeStrike = false,
  });

  int get totalRuns {
    if (isWide || isNoBall) {
      return runs + 1 + extraRuns;
    }

    return runs + extraRuns;
  }

  bool get countBall {
    return !(isWide || isNoBall);
  }

  BallModel copyWith({
    String? id,
    int? runs,
    bool? isWicket,
    bool? isWide,
    bool? isNoBall,
    bool? isBye,
    bool? isLegBye,
    bool? isUndo,
    String? wicketType,
    String? outPlayerId,
    int? extraRuns,
    bool? changeStrike,
  }) {
    return BallModel(
      id: id ?? this.id,
      runs: runs ?? this.runs,
      isWicket: isWicket ?? this.isWicket,
      isWide: isWide ?? this.isWide,
      isNoBall: isNoBall ?? this.isNoBall,
      isBye: isBye ?? this.isBye,
      isLegBye: isLegBye ?? this.isLegBye,
      isUndo: isUndo ?? this.isUndo,
      wicketType: wicketType ?? this.wicketType,
      outPlayerId: outPlayerId ?? this.outPlayerId,
      extraRuns: extraRuns ?? this.extraRuns,
      changeStrike: changeStrike ?? this.changeStrike,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'runs': runs,
      'isWicket': isWicket,
      'isWide': isWide,
      'isNoBall': isNoBall,
      'isBye': isBye,
      'isLegBye': isLegBye,
      'isUndo': isUndo,
      'wicketType': wicketType,
      'outPlayerId': outPlayerId,
      'extraRuns': extraRuns,
      'changeStrike': changeStrike,
    };
  }

  factory BallModel.fromMap(Map<String, dynamic> map) {
    return BallModel(
      id: map['id']?.toString() ?? '',
      runs: map['runs'] ?? 0,
      isWicket: map['isWicket'] ?? false,
      isWide: map['isWide'] ?? false,
      isNoBall: map['isNoBall'] ?? false,
      isBye: map['isBye'] ?? false,
      isLegBye: map['isLegBye'] ?? false,
      isUndo: map['isUndo'] ?? false,
      wicketType: map['wicketType']?.toString() ?? '',
      outPlayerId: map['outPlayerId']?.toString() ?? '',
      extraRuns: map['extraRuns'] ?? 0,
      changeStrike: map['changeStrike'] ?? false,
    );
  }

  @override
  String toString() {
    return 'BallModel(id: $id, runs: $runs)';
  }
}
