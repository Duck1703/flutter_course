// Barrel file — M24, đúng senior `repositories/auth/auth_repository.dart`:
// một import duy nhất lộ cả contract lẫn hai impl (disabled + supabase).
export 'auth_repository_contract.dart';
export 'disabled_auth_repository.dart';
export 'supabase_auth_repository.dart';
