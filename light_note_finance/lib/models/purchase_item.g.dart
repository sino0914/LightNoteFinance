// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseItemAdapter extends TypeAdapter<PurchaseItem> {
  @override
  final int typeId = 5;

  @override
  PurchaseItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseItem(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      price: fields[3] as int,
      type: fields[4] as PurchaseItemType,
      isAvailable: fields[5] as bool,
      iconPath: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isAvailable)
      ..writeByte(6)
      ..write(obj.iconPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PurchaseItemTypeAdapter extends TypeAdapter<PurchaseItemType> {
  @override
  final int typeId = 4;

  @override
  PurchaseItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PurchaseItemType.bookmarkFeature;
      case 1:
        return PurchaseItemType.highlightFeature;
      case 2:
        return PurchaseItemType.chooseBooks;
      case 3:
        return PurchaseItemType.extraDailySummary;
      case 4:
        return PurchaseItemType.watchAd;
      default:
        return PurchaseItemType.bookmarkFeature;
    }
  }

  @override
  void write(BinaryWriter writer, PurchaseItemType obj) {
    switch (obj) {
      case PurchaseItemType.bookmarkFeature:
        writer.writeByte(0);
        break;
      case PurchaseItemType.highlightFeature:
        writer.writeByte(1);
        break;
      case PurchaseItemType.chooseBooks:
        writer.writeByte(2);
        break;
      case PurchaseItemType.extraDailySummary:
        writer.writeByte(3);
        break;
      case PurchaseItemType.watchAd:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
