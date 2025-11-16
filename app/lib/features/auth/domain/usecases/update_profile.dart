import '../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository _repository;

  UpdateProfile(this._repository);

  Future<void> call(String name) async {
    return await _repository.updateProfile(name);
  }
}
