// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      title: fields[0] as String,
      genre: fields[1] as String,
      year: fields[2] as int,
      userId: fields[10] as String,
      description: fields[3] as String,
      rating: fields[4] as double,
      posterUrl: fields[5] as String?,
      isWatched: fields[6] as bool,
      isFavorite: fields[7] as bool,
      dateAdded: fields[8] as DateTime?,
      tmdbId: fields[9] as int?,
      localPosterPath: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.genre)
      ..writeByte(2)
      ..write(obj.year)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.posterUrl)
      ..writeByte(6)
      ..write(obj.isWatched)
      ..writeByte(7)
      ..write(obj.isFavorite)
      ..writeByte(8)
      ..write(obj.dateAdded)
      ..writeByte(9)
      ..write(obj.tmdbId)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(11)
      ..write(obj.localPosterPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
