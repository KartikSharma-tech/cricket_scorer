// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchHistoryModelAdapter extends TypeAdapter<MatchHistoryModel> {
  @override
  final int typeId = 1;

  @override
  MatchHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchHistoryModel(
      teamAName: fields[0] as String,
      teamBName: fields[1] as String,
      teamAScore: fields[2] as int,
      teamAWickets: fields[3] as int,
      teamBScore: fields[4] as int,
      teamBWickets: fields[5] as int,
      overs: fields[6] as int,
      result: fields[7] as String,
      winner: fields[8] as String,
      matchDate: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MatchHistoryModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.teamAName)
      ..writeByte(1)
      ..write(obj.teamBName)
      ..writeByte(2)
      ..write(obj.teamAScore)
      ..writeByte(3)
      ..write(obj.teamAWickets)
      ..writeByte(4)
      ..write(obj.teamBScore)
      ..writeByte(5)
      ..write(obj.teamBWickets)
      ..writeByte(6)
      ..write(obj.overs)
      ..writeByte(7)
      ..write(obj.result)
      ..writeByte(8)
      ..write(obj.winner)
      ..writeByte(9)
      ..write(obj.matchDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
