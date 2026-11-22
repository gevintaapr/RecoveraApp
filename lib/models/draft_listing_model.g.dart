// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_listing_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DraftListingModelAdapter extends TypeAdapter<DraftListingModel> {
  @override
  final int typeId = 2;

  @override
  DraftListingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DraftListingModel(
      idDraft: fields[0] as String,
      namaProduk: fields[1] as String,
      merek: fields[2] as String?,
      kategori: fields[3] as String,
      jenisPenyimpanan: fields[4] as String,
      satuan: fields[5] as String,
      jumlah: fields[6] as int,
      hargaNormal: fields[7] as double,
      hargaMinimum: fields[8] as double,
      tanggalKedaluwarsa: fields[9] as DateTime,
      nomorBatch: fields[10] as String,
      gambarProduk: fields[11] as Uint8List?,
      waktuDisimpan: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DraftListingModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.idDraft)
      ..writeByte(1)
      ..write(obj.namaProduk)
      ..writeByte(2)
      ..write(obj.merek)
      ..writeByte(3)
      ..write(obj.kategori)
      ..writeByte(4)
      ..write(obj.jenisPenyimpanan)
      ..writeByte(5)
      ..write(obj.satuan)
      ..writeByte(6)
      ..write(obj.jumlah)
      ..writeByte(7)
      ..write(obj.hargaNormal)
      ..writeByte(8)
      ..write(obj.hargaMinimum)
      ..writeByte(9)
      ..write(obj.tanggalKedaluwarsa)
      ..writeByte(10)
      ..write(obj.nomorBatch)
      ..writeByte(11)
      ..write(obj.gambarProduk)
      ..writeByte(12)
      ..write(obj.waktuDisimpan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DraftListingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
