// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 3;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      id: fields[0] as int,
      idListing: fields[1] as int,
      namaProduk: fields[2] as String,
      kategori: fields[3] as String?,
      urlGambar: fields[4] as String?,
      namaPenjual: fields[5] as String?,
      namaPembeli: fields[6] as String?,
      jumlah: fields[7] as int,
      hargaSatuan: fields[8] as double,
      totalHarga: fields[9] as double,
      status: fields[10] as String,
      dibuatPada: fields[11] as DateTime,
      alamatGudang: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.idListing)
      ..writeByte(2)
      ..write(obj.namaProduk)
      ..writeByte(3)
      ..write(obj.kategori)
      ..writeByte(4)
      ..write(obj.urlGambar)
      ..writeByte(5)
      ..write(obj.namaPenjual)
      ..writeByte(6)
      ..write(obj.namaPembeli)
      ..writeByte(7)
      ..write(obj.jumlah)
      ..writeByte(8)
      ..write(obj.hargaSatuan)
      ..writeByte(9)
      ..write(obj.totalHarga)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.dibuatPada)
      ..writeByte(12)
      ..write(obj.alamatGudang);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
