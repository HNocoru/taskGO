# 📱 Task Manager App - Flutter MVP

## 🎯 Descripción del Proyecto

Aplicación móvil de gestión de tareas desarrollada con **Flutter**, implementando **Clean Architecture**, **MVVM**, **Provider** y consumo de API REST con **HTTP**.

### ✨ Características Principales

- ✅ Autenticación completa (Login/Register)
- ✅ CRUD de tareas con filtros
- ✅ Sistema de prioridades (Low/Medium/High)
- ✅ Fechas límite
- ✅ Carga de imágenes
- ✅ Interfaz visualmente rica con animaciones
- ✅ Arquitectura Clean + MVVM + Vertical Slicing
- ✅ Gestión de estado con Provider
- ✅ HTTP client para consumo de API

---

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── error/                    # Manejo de errores
│   │   ├── failures.dart
│   │   └── exceptions.dart
│   ├── network/                  # Cliente HTTP
│   │   ├── api_client.dart
│   │   └── api_endpoints.dart
│   └── utils/                    # Utilidades
│       ├── constants.dart
│       └── helpers.dart
│
├── features/
│   ├── auth/                     # Feature de Autenticación
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_remote_datasource.dart
│   │   │   │   └── auth_local_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       └── register_usecase.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── register_page.dart
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       └── widgets/
│   │           └── auth_widgets.dart
│   │
│   └── tasks/                    # Feature de Tareas
│       ├── data/
│       │   ├── datasources/
│       │   │   └── task_remote_datasource.dart
│       │   ├── models/
│       │   │   └── task_model.dart
│       │   └── repositories/
│       │       └── task_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── task_entity.dart
│       │   ├── repositories/
│       │   │   └── task_repository.dart
│       │   └── usecases/
│       │       ├── get_tasks_usecase.dart
│       │       ├── create_task_usecase.dart
│       │       └── delete_task_usecase.dart
│       └── presentation/
│           ├── pages/
│           │   ├── home_page.dart
│           │   ├── create_task_page.dart
│           │   └── task_detail_page.dart
│           ├── providers/
│           │   └── task_provider.dart
│           └── widgets/
│               └── task_widgets.dart
│
└── main.dart                     # Entry point
```

---

## 🏗️ Arquitectura

### Clean Architecture + MVVM

El proyecto implementa **Clean Architecture** con **MVVM** en la capa de presentación:

#### 1. **Data Layer** (Capa de Datos)
- **DataSources**: Remote (API) y Local (SharedPreferences)
- **Models**: DTOs para serialización JSON
- **Repository Implementation**: Implementación concreta de repositorios

#### 2. **Domain Layer** (Capa de Dominio)
- **Entities**: Modelos de negocio puros
- **Repositories**: Contratos abstractos
- **UseCases**: Lógica de negocio específica

#### 3. **Presentation Layer** (Capa de Presentación - MVVM)
- **Pages** (Views): UI pura, sin lógica
- **Providers** (ViewModels): Gestión de estado con Provider
- **Widgets**: Componentes reutilizables

### Vertical Slicing

Cada feature es **autocontenida** con sus propias capas, facilitando:
- ✅ Escalabilidad
- ✅ Mantenibilidad
- ✅ Testing independiente
- ✅ Trabajo en equipo

---

## 🛠️ Tecnologías y Dependencias

### Principales

```yaml
dependencies:
  # Estado - OBLIGATORIO
  provider: ^6.1.1
  
  # HTTP Client - OBLIGATORIO
  http: ^1.1.0
  
  # Manejo de errores
  dartz: ^0.10.1
  
  # Persistencia local
  shared_preferences: ^2.2.2
  
  # Utilidades
  intl: ^0.18.1
  google_fonts: ^6.1.0
  
  # Funcionalidades
  image_picker: ^1.0.7
  flutter_local_notifications: ^16.3.0
```

---

## 🚀 Instalación y Configuración

### 1. Clonar el proyecto

```bash
git clone <repository-url>
cd task_manager_app
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar la URL del Backend

Editar `lib/core/network/api_endpoints.dart`:

```dart
class ApiEndpoints {
  // CAMBIAR SEGÚN TU CONFIGURACIÓN:
  
  // Para Android Emulator:
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  // Para iOS Simulator:
  // static const String baseUrl = 'http://localhost:3000';
  
  // Para dispositivo físico (usa tu IP local):
  // static const String baseUrl = 'http://192.168.1.XXX:3000';
  
  // ...
}
```

### 4. Levantar el Backend (Node.js)

```bash
# Desde la carpeta del backend
docker-compose up -d    # Levantar MongoDB
npm install             # Instalar dependencias
npm start              # Iniciar servidor
```

El backend correrá en `http://localhost:3000`

### 5. Ejecutar la app

```bash
flutter run
```

---

## 📡 API Endpoints Utilizados

### Autenticación

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/auth/register` | Registro de usuario |
| POST | `/api/auth/login` | Login |
| GET | `/api/auth/profile` | Obtener perfil |
| POST | `/api/auth/refresh` | Renovar token |

### Tareas

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/tasks` | Listar tareas (con filtros) |
| GET | `/api/tasks/:id` | Obtener tarea específica |
| POST | `/api/tasks` | Crear tarea |
| PATCH | `/api/tasks/:id` | Actualizar tarea |
| PATCH | `/api/tasks/:id/complete` | Completar tarea |
| DELETE | `/api/tasks/:id` | Eliminar tarea |

### Imágenes

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/tasks/:id/image` | Subir imagen |
| DELETE | `/api/tasks/:id/image` | Eliminar imagen |

---

## 🎨 Widgets y Animaciones

### Widgets Principales

1. **Card**: Para tareas individuales
2. **ListTile**: En menús y opciones
3. **GridView**: En estadísticas (opcional)
4. **Stack**: Overlays de imágenes
5. **CustomScrollView**: Scroll personalizado en detalles

### Animaciones Implementadas

1. **Hero**: Transiciones entre login/register
2. **FadeTransition**: Aparición de pantallas
3. **SlideTransition**: Movimiento de elementos
4. **AnimatedContainer**: Cambios de estado (checkboxes, chips)

---

## 🧪 Testing de la Aplicación

### Flujo de Prueba Completo

#### 1. Registro

```
1. Abrir app → Ver LoginPage
2. Tap en "Regístrate"
3. Llenar formulario:
   - Nombre: "Juan Pérez"
   - Email: "juan@test.com"
   - Password: "123456"
4. Tap "Crear Cuenta"
5. ✅ Redirección a HomePage
```

#### 2. Crear Tarea (POST)

```
1. En HomePage, tap en FAB "Nueva Tarea"
2. Llenar:
   - Título: "Comprar víveres"
   - Descripción: "Leche, pan, huevos"
   - Prioridad: High
   - Fecha: Mañana
3. Tap "Crear Tarea"
4. ✅ Tarea aparece en lista
```

#### 3. Ver Tareas (GET)

```
1. HomePage muestra lista de tareas
2. Stats cards actualizadas
3. Pull to refresh funciona
4. ✅ Filtros (Todas/Pendientes/Completadas)
```

#### 4. Completar Tarea

```
1. Tap en checkbox de tarea
2. ✅ Tarea marcada como completada
3. Aparece en tab "Completadas"
```

#### 5. Eliminar Tarea (DELETE)

```
1. Swipe tarea hacia la izquierda
2. Tap en icono delete
3. ✅ Tarea eliminada de lista
```

#### 6. Subir Imagen

```
1. Tap en tarea → Ver detalle
2. Tap en "Agregar imagen"
3. Seleccionar de galería
4. ✅ Imagen subida y mostrada
```

---

## 📊 Cumplimiento de Rúbrica

### ✅ Dominio Técnico (30%)

- [x] Arquitectura MVVM implementada correctamente
- [x] Clean Architecture con separación clara de capas
- [x] Screaming Architecture (features autocontenidas)
- [x] Vertical Slicing aplicado
- [x] Código limpio y bien estructurado

### ✅ Provider (20%)

- [x] AuthProvider para autenticación
- [x] TaskProvider para gestión de tareas
- [x] Separación View-ViewModel correcta
- [x] Estado reactivo con notifyListeners()
- [x] Sin lógica de negocio en las vistas

### ✅ HTTP Methods (20%)

- [x] **GET**: Obtener tareas, perfil
- [x] **POST**: Login, register, crear tareas, subir imagen
- [x] **DELETE**: Eliminar tareas
- [x] Manejo correcto de errores
- [x] Headers y autorización (Bearer token)

### ✅ Interfaz Rica (15%)

- [x] Diseño moderno con gradientes
- [x] Animaciones (Hero, Fade, Slide, AnimatedContainer)
- [x] Widgets variados (Card, ListTile, Stack, etc.)
- [x] Tipografía consistente (Google Fonts)
- [x] Sistema de colores profesional

### ✅ Informe PDF (15%)

- [x] Este README sirve como base
- [x] Arquitectura explicada
- [x] Justificación de Provider
- [x] Ejemplos de implementación
- [x] Capturas de pantalla recomendadas

---

## 📸 Capturas Recomendadas para el Informe

1. **Login Page**: Mostrar diseño con gradiente
2. **Register Page**: Hero animation del logo
3. **Home Page**: Stats cards y lista de tareas
4. **Create Task Page**: Formulario con prioridades
5. **Task Detail**: SliverAppBar con imagen
6. **Filtros**: Tabs de Todas/Pendientes/Completadas
7. **Código**: Provider implementation
8. **Código**: API Client con métodos HTTP

---

## 🔧 Troubleshooting

### Error de conexión al backend

```dart
// Verificar URL en api_endpoints.dart
static const String baseUrl = 'http://10.0.2.2:3000'; // Android
```

### Provider not found

```dart
// Verificar que main.dart tiene MultiProvider
runApp(
  MultiProvider(
    providers: [...],
    child: const MyApp(),
  ),
);
```

### Imagen no se sube

```dart
// Agregar permisos en AndroidManifest.xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

---

## 📝 Notas Adicionales

### Mejoras Futuras (Post-MVP)

- [ ] Sistema de recordatorios (CRUD de reminders)
- [ ] Notificaciones push
- [ ] Búsqueda de tareas
- [ ] Modo oscuro
- [ ] Internacionalización (i18n)
- [ ] Tests unitarios y de integración
- [ ] Cache offline con Hive/Drift
- [ ] Sincronización automática

### Buenas Prácticas Aplicadas

✅ Separación de responsabilidades  
✅ Principio DRY (Don't Repeat Yourself)  
✅ SOLID principles  
✅ Naming conventions de Flutter  
✅ Error handling robusto  
✅ Código documentado  

---

## 👨‍💻 Autor

**Tu Nombre**  
- Asignatura: Programación para Móviles II
- Profesor: Mtro. Alí Santiago López Zunún
- Período: sep – dic 2025

---

## 📄 Licencia

Este proyecto es parte de un trabajo académico.

---

## 🎓 Referencias

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [HTTP Package](https://pub.dev/packages/http)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [MVVM Pattern](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel)# taskGO
