// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerModelAdapter extends TypeAdapter<PlayerModel> {
  @override
  final int typeId = 0;

  @override
  PlayerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerModel(
      id: fields[0] as String,
      name: fields[1] as String,
      role: fields[2] as String,
      runs: fields[3] as int,
      balls: fields[4] as int,
      wickets: fields[5] as int,
      runsGiven: fields[6] as int,
      ballsBowled: fields[7] as int,
      matches: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.runs)
      ..writeByte(4)
      ..write(obj.balls)
      ..writeByte(5)
      ..write(obj.wickets)
      ..writeByte(6)
      ..write(obj.runsGiven)
      ..writeByte(7)
      ..write(obj.ballsBowled)
      ..writeByte(8)
      ..write(obj.matches);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
