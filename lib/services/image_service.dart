import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// Tira uma foto usando a câmera
  Future<String?> takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo == null) return null;

      // Salva a foto permanentemente
      final savedPath = await _saveImagePermanently(photo.path);
      return savedPath;
    } catch (e) {
      throw Exception('Erro ao tirar foto: $e');
    }
  }

  /// Escolhe uma foto da galeria
  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Salva a foto permanentemente
      final savedPath = await _saveImagePermanently(image.path);
      return savedPath;
    } catch (e) {
      throw Exception('Erro ao escolher foto: $e');
    }
  }

  /// Salva a imagem permanentemente no diretório do app
  Future<String> _saveImagePermanently(String tempPath) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String newPath = path.join(appDir.path, 'movie_posters', fileName);

    // Cria o diretório se não existir
    final Directory posterDir = Directory(path.join(appDir.path, 'movie_posters'));
    if (!await posterDir.exists()) {
      await posterDir.create(recursive: true);
    }

    // Copia a imagem para o novo local
    final File tempFile = File(tempPath);
    await tempFile.copy(newPath);

    return newPath;
  }

  /// Deleta uma imagem do armazenamento
  Future<void> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignora erro se o arquivo não existir
    }
  }

  /// Verifica se uma imagem existe
  Future<bool> imageExists(String imagePath) async {
    try {
      final File file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Mostra dialog para escolher entre câmera ou galeria
  static Future<String?> showImageSourceDialog(context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Foto'),
          content: const Text('Escolha a origem da foto:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'gallery'),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeria'),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context, 'camera'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Câmera'),
            ),
          ],
        );
      },
    );
  }
}