import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants/firebase_constants.dart';

/// Service class for handling Firebase Storage operations
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile picture for a user
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfilePicture({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Create a unique file name
      final String fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath =
          '${FirebaseConstants.profilePicturesPath}/$fileName';

      // Create a reference to the file location
      final Reference storageRef = _storage.ref().child(filePath);

      // Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload profile picture: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  /// Upload question image
  /// Returns the download URL of the uploaded image
  Future<String> uploadQuestionImage({
    required String quizId,
    required String questionId,
    required File imageFile,
  }) async {
    try {
      // Create a unique file name
      final String fileName =
          '${quizId}_${questionId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath =
          '${FirebaseConstants.questionImagesPath}/$fileName';

      // Create a reference to the file location
      final Reference storageRef = _storage.ref().child(filePath);

      // Set metadata
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'quizId': quizId,
          'questionId': questionId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload question image: ${e.message}');
    } catch (e) {
      throw Exception('Failed to upload question image: $e');
    }
  }

  /// Delete an image from storage using its URL
  Future<void> deleteImage(String imageUrl) async {
    try {
      // Create a reference from the URL
      final Reference storageRef = _storage.refFromURL(imageUrl);

      // Delete the file
      await storageRef.delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete image: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture(String imageUrl) async {
    try {
      await deleteImage(imageUrl);
    } catch (e) {
      throw Exception('Failed to delete profile picture: $e');
    }
  }

  /// Delete question image
  Future<void> deleteQuestionImage(String imageUrl) async {
    try {
      await deleteImage(imageUrl);
    } catch (e) {
      throw Exception('Failed to delete question image: $e');
    }
  }

  /// Delete all images for a quiz (when quiz is deleted)
  Future<void> deleteQuizImages(String quizId) async {
    try {
      // List all files in the quiz's folder
      final Reference folderRef = _storage.ref().child(
        FirebaseConstants.questionImagesPath,
      );
      final ListResult result = await folderRef.listAll();

      // Filter and delete files that belong to this quiz
      for (var item in result.items) {
        final metadata = await item.getMetadata();
        final String? storedQuizId = metadata.customMetadata?['quizId'];

        if (storedQuizId == quizId) {
          await item.delete();
        }
      }
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete quiz images: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete quiz images: $e');
    }
  }

  /// Get image metadata
  Future<FullMetadata> getImageMetadata(String imageUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      return await storageRef.getMetadata();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get image metadata: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get image metadata: $e');
    }
  }

  /// Update image metadata
  Future<void> updateImageMetadata({
    required String imageUrl,
    required Map<String, String> customMetadata,
  }) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      final SettableMetadata metadata = SettableMetadata(
        customMetadata: customMetadata,
      );
      await storageRef.updateMetadata(metadata);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update image metadata: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update image metadata: $e');
    }
  }

  /// Get download URL from storage path
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      final Reference storageRef = _storage.ref().child(storagePath);
      return await storageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Failed to get download URL: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Check if file exists in storage
  Future<bool> fileExists(String storagePath) async {
    try {
      final Reference storageRef = _storage.ref().child(storagePath);
      await storageRef.getDownloadURL();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false;
      }
      throw Exception('Failed to check file existence: ${e.message}');
    } catch (e) {
      throw Exception('Failed to check file existence: $e');
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String imageUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(imageUrl);
      final FullMetadata metadata = await storageRef.getMetadata();
      return metadata.size ?? 0;
    } on FirebaseException catch (e) {
      throw Exception('Failed to get file size: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get file size: $e');
    }
  }

  /// List all profile pictures
  Future<List<String>> listProfilePictures() async {
    try {
      final Reference folderRef = _storage.ref().child(
        FirebaseConstants.profilePicturesPath,
      );
      final ListResult result = await folderRef.listAll();

      final List<String> urls = [];
      for (var item in result.items) {
        final url = await item.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } on FirebaseException catch (e) {
      throw Exception('Failed to list profile pictures: ${e.message}');
    } catch (e) {
      throw Exception('Failed to list profile pictures: $e');
    }
  }

  /// List all question images for a quiz
  Future<List<String>> listQuizImages(String quizId) async {
    try {
      final Reference folderRef = _storage.ref().child(
        FirebaseConstants.questionImagesPath,
      );
      final ListResult result = await folderRef.listAll();

      final List<String> urls = [];
      for (var item in result.items) {
        final metadata = await item.getMetadata();
        final String? storedQuizId = metadata.customMetadata?['quizId'];

        if (storedQuizId == quizId) {
          final url = await item.getDownloadURL();
          urls.add(url);
        }
      }

      return urls;
    } on FirebaseException catch (e) {
      throw Exception('Failed to list quiz images: ${e.message}');
    } catch (e) {
      throw Exception('Failed to list quiz images: $e');
    }
  }
}
