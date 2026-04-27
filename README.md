# App Finanzas

Aplicación Flutter de finanzas personales con backend Firebase (Auth + Firestore).

---

## Inicio rápido — comandos en orden

Copia y pega estos comandos en la terminal, **en este orden**, la primera vez que configures el proyecto:

```bash
# 1. Instalar dependencias del proyecto
flutter pub get

# 2. Instalar Firebase CLI (solo la primera vez)
npm install -g firebase-tools

# 3. Instalar FlutterFire CLI (solo la primera vez)
dart pub global activate flutterfire_cli

# 4. Iniciar sesión en Firebase
firebase login

# 5. Conectar el proyecto con Firebase (genera lib/firebase_options.dart)
flutterfire configure --project=appfinanzas-ad4a2 --platforms=android,web,windows --yes

# 6. Correr la app en Chrome (desarrollo)
flutter run -d chrome

# 7. Compilar para producción web
flutter build web --release

# 8. Desplegar en Firebase Hosting
firebase init hosting
firebase deploy
```

> **Nota:** Los pasos 2, 3 y 4 solo se hacen **una sola vez** por máquina. Los pasos 7 y 8 solo cuando quieras publicar una nueva versión.

---

## Requisitos previos

| Herramienta | Versión mínima | Notas |
|---|---|---|
| Flutter | 3.41.7 | `flutter upgrade` para actualizar |
| Dart | 3.11.5 | Incluido con Flutter |
| Android Studio / SDK | SDK 36+ | Para compilar Android |
| Google Chrome | Cualquiera | Para correr en web (desarrollo) |
| Visual Studio 2022 | Build Tools + C++ Desktop | Solo para compilar Windows |
| Node.js | 18+ | Requerido por Firebase CLI |
| Java JDK | 17+ | Requerido por Android Gradle |

---

## 1. Clonar y preparar dependencias

```bash
git clone <URL_DEL_REPO>
cd finanzas
flutter pub get
```

---

## 2. Configurar Firebase (obligatorio antes de correr la app)

### 2.1 Crear proyecto en Firebase

1. Ve a [https://console.firebase.google.com](https://console.firebase.google.com)
2. Haz clic en **Agregar proyecto** y sigue los pasos
3. En el panel del proyecto activa:
   - **Authentication** → Método de inicio de sesión → **Correo electrónico/Contraseña** → Habilitar
   - **Firestore Database** → Crear base de datos → Modo de producción (o prueba para desarrollo)

### 2.2 Configurar reglas de Firestore

En **Firestore → Reglas**, pega esto y publica:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2.3 Conectar Flutter con Firebase

```bash
# Instalar FlutterFire CLI (una sola vez)
dart pub global activate flutterfire_cli

# Desde la raíz del proyecto, ejecutar:
flutterfire configure
```

- Selecciona tu proyecto de Firebase
- Marca las plataformas que necesitas (Android, iOS, Web, Windows)
- Esto genera automáticamente `lib/firebase_options.dart` con tus credenciales reales

> ⚠️ **Sin este paso la app no arranca.** El archivo `lib/firebase_options.dart` incluido en el repo es un placeholder.

---

## 3. Correr en desarrollo

### Web (Chrome)
```bash
flutter run -d chrome
```

### Android (emulador o dispositivo físico)
```bash
# Listar dispositivos disponibles
flutter devices

# Correr en un dispositivo específico
flutter run -d <DEVICE_ID>
```

### Windows (escritorio)
```bash
flutter run -d windows
```

---

## 4. Compilar para producción

### Web
```bash
flutter build web --release
# Salida: build/web/
```

Para desplegar en Firebase Hosting:
```bash
npm install -g firebase-tools
firebase login
firebase init hosting   # selecciona build/web como public directory
firebase deploy
```

### Android (APK)
```bash
flutter build apk --release
# Salida: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle para Play Store)
```bash
flutter build appbundle --release
# Salida: build/app/outputs/bundle/release/app-release.aab
```

### Windows
```bash
flutter build windows --release
# Salida: build/windows/x64/runner/Release/
```

---

## 5. Estructura del proyecto

```
lib/
├── main.dart                     # Punto de entrada + AuthGate
├── firebase_options.dart         # Credenciales Firebase (generado por flutterfire)
├── models/
│   ├── transaction.dart          # Modelo de transacción con Firestore
│   └── app_label.dart            # Modelo de etiqueta con Firestore
├── services/
│   ├── auth_service.dart         # Firebase Auth: login, registro, logout, cambio de contraseña
│   └── firestore_service.dart    # Firestore CRUD: transacciones, etiquetas, perfil
└── screens/
    ├── login_screen.dart
    ├── register_screen.dart
    ├── home_screen.dart           # Dashboard con gráfica y listado en tiempo real
    ├── historial_screen.dart      # Historial con búsqueda y filtros
    ├── statistics_screen.dart
    ├── add_transaction_screen.dart
    ├── labels_screen.dart
    ├── settings_screen.dart
    ├── user_settings_screen.dart
    └── change_password_screen.dart
```

### Estructura de Firestore

```
users/{userId}/
  ├── (documento)        → name, email, currency, phone, birthdate, createdAt
  ├── transactions/
  │   └── {txId}         → label, amount, isIncome, createdAt
  └── labels/
      └── {labelId}      → name, color, createdAt
```

---

## 6. Variables y configuración

No hay variables de entorno que configurar manualmente. Todo se gestiona a través de `firebase_options.dart` generado por `flutterfire configure`.

---

## 7. Checklist de despliegue

- [ ] `flutter pub get` ejecutado
- [ ] Proyecto creado en Firebase Console
- [ ] Authentication → Correo/Contraseña habilitado
- [ ] Firestore creado con reglas de seguridad configuradas
- [ ] `flutterfire configure` ejecutado → `lib/firebase_options.dart` generado
- [ ] App probada en desarrollo (`flutter run`)
- [ ] Build de producción generado (`flutter build <plataforma>`)
- [ ] (Web) Desplegado con `firebase deploy`

---

## Tecnologías

- **Flutter** 3.41.7 / **Dart** 3.11.5
- **Firebase Auth** 5.x — Autenticación con email/contraseña
- **Cloud Firestore** 5.x — Base de datos en tiempo real
- **Material Design 3**
