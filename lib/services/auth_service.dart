import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream del usuario actual (null si no está autenticado).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actualmente autenticado.
  User? get currentUser => _auth.currentUser;

  /// Iniciar sesión con correo y contraseña.
  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Registrar nueva cuenta y crear perfil en Firestore.
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Actualizar displayName en Firebase Auth
    await credential.user!.updateDisplayName(name.trim());

    // Crear documento de perfil en Firestore
    await _db
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'name': name.trim(),
      'email': email.trim(),
      'currency': 'COP',
      'phone': '',
      'birthdate': '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  /// Cerrar sesión.
  Future<void> signOut() => _auth.signOut();

  /// Cambiar contraseña (reautentica primero).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No hay sesión activa');

    // Re-autenticar
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Actualizar contraseña
    await user.updatePassword(newPassword);
  }

  /// Mensaje de error legible en español.
  static String errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Correo no registrado. ¿Aún no tienes cuenta?';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'weak-password':
        return 'La contraseña es muy débil (mínimo 6 caracteres)';
      case 'invalid-email':
        return 'El correo no es válido';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta de nuevo más tarde';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      default:
        return 'Error: ${e.message}';
    }
  }
}
