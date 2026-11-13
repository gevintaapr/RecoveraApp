// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoritModelAdapter extends TypeAdapter<FavoritModel> {
  @override
  final int typeId = 0;

  @override
  FavoritModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoritModel(
      idListing: fields[0] as int,
      namaProduk: fields[1] as String,
      urlGambar: fields[2] as String?,
      hargaSaatDisimpan: fields[3] as double,
      hargaNormal: fields[4] as double,
      lelangBerakhir: fields[5] as DateTime,
      namaPenjual: fields[6] as String?,
      waktuDisimpan: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FavoritModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.idListing)
      ..writeByte(1)
      ..write(obj.namaProduk)
      ..writeByte(2)
      ..write(obj.urlGambar)
      ..writeByte(3)
      ..write(obj.hargaSaatDisimpan)
      ..writeByte(4)
      ..write(obj.hargaNormal)
      ..writeByte(5)
      ..write(obj.lelangBerakhir)
      ..writeByte(6)
      ..write(obj.namaPenjual)
      ..writeByte(7)
      ..write(obj.waktuDisimpan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
