// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListingModelAdapter extends TypeAdapter<ListingModel> {
  @override
  final int typeId = 1;

  @override
  ListingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListingModel(
      id: fields[0] as int,
      namaProduk: fields[1] as String,
      merek: fields[2] as String?,
      kategori: fields[3] as String,
      satuan: fields[4] as String,
      urlGambar: fields[5] as String?,
      stok: fields[6] as int,
      hargaNormal: fields[7] as double,
      hargaMinimum: fields[8] as double,
      hargaSekarang: fields[9] as double,
      persenDiskon: fields[10] as double?,
      waktuTurunBerikutnya: fields[11] as DateTime?,
      lelangBerakhir: fields[12] as DateTime,
      tanggalKedaluwarsa: fields[13] as DateTime,
      sisaHari: fields[14] as int?,
      namaPenjual: fields[15] as String?,
      kotaGudang: fields[16] as String?,
      jarakKm: fields[17] as double?,
      latGudang: fields[19] as double?,
      lngGudang: fields[20] as double?,
      status: fields[18] as String,
      nomorBatch: fields[21] as String?,
      jenisPenyimpanan: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ListingModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.namaProduk)
      ..writeByte(2)
      ..write(obj.merek)
      ..writeByte(3)
      ..write(obj.kategori)
      ..writeByte(4)
      ..write(obj.satuan)
      ..writeByte(5)
      ..write(obj.urlGambar)
      ..writeByte(6)
      ..write(obj.stok)
      ..writeByte(7)
      ..write(obj.hargaNormal)
      ..writeByte(8)
      ..write(obj.hargaMinimum)
      ..writeByte(9)
      ..write(obj.hargaSekarang)
      ..writeByte(10)
      ..write(obj.persenDiskon)
      ..writeByte(11)
      ..write(obj.waktuTurunBerikutnya)
      ..writeByte(12)
      ..write(obj.lelangBerakhir)
      ..writeByte(13)
      ..write(obj.tanggalKedaluwarsa)
      ..writeByte(14)
      ..write(obj.sisaHari)
      ..writeByte(15)
      ..write(obj.namaPenjual)
      ..writeByte(16)
      ..write(obj.kotaGudang)
      ..writeByte(17)
      ..write(obj.jarakKm)
      ..writeByte(19)
      ..write(obj.latGudang)
      ..writeByte(20)
      ..write(obj.lngGudang)
      ..writeByte(18)
      ..write(obj.status)
      ..writeByte(21)
      ..write(obj.nomorBatch)
      ..writeByte(22)
      ..write(obj.jenisPenyimpanan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
