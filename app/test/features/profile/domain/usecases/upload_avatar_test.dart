import 'dart:io';

import 'package:app/features/profile/domain/repositories/profile_repository.dart';
import 'package:app/features/profile/domain/usecases/upload_avatar.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'upload_avatar_test.mocks.dart';

@GenerateMocks([ProfileRepository])
void main() {
  late UploadAvatar usecase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    usecase = UploadAvatar(mockRepository);
  });

  final tFile = File('test_resources/avatar.jpg');
  const tAvatarUrl = 'https://example.com/avatar.jpg';

  final tParams = UploadAvatarParams(file: tFile);

  test('should upload avatar and return the url', () async {
    // Arrange
    when(
      mockRepository.uploadAvatar(tFile),
    ).thenAnswer((_) async => const Right(tAvatarUrl));

    // Act
    final result = await usecase(tParams);

    // Assert
    expect(result, const Right(tAvatarUrl));
    verify(mockRepository.uploadAvatar(tFile));
    verifyNoMoreInteractions(mockRepository);
  });
}
