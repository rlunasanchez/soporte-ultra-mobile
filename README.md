# Sistema de Carga de OS - App Flutter

## 📱 Descripción

Aplicación móvil desarrollada en Flutter que se conecta al backend existente del Sistema de Carga de OS. Permite gestionar órdenes de servicio técnico, retiros de bodega y usuarios.

## 🔗 URLs de Producción

| Servicio | URL |
|----------|-----|
| **Frontend Web** | https://sistema-soporte-ultra-wngj.vercel.app |
| **Backend API** | https://sistema-soporte-ultra.onrender.com |
| **Base de datos** | Neon (PostgreSQL) |

## 🔐 Credenciales de Acceso

| Usuario | Password | Rol |
|---------|----------|-----|
| admin | Rluna6498 | admin |
| rodrigo | 123456 | tecnico |
| diego | 123456 | tecnico |

## 🛠️ Stack Tecnológico

- **Framework**: Flutter 3.41.6
- **Lenguaje**: Dart 3.11.4
- **Estado**: Provider
- **HTTP**: http ^1.2.2
- **Storage**: shared_preferences ^2.3.3
- **Fechas**: intl ^0.20.1

## 📁 Estructura del Proyecto

```
soporte_ultra_app/
├── lib/
│   ├── main.dart                    # App principal
│   ├── config/
│   │   └── api_config.dart          # URLs de la API
│   ├── models/
│   │   ├── orden.dart               # Modelo Orden
│   │   ├── usuario.dart             # Modelo Usuario
│   │   └── retiro.dart              # Modelo Retiro
│   ├── providers/
│   │   └── auth_provider.dart       # Gestión de autenticación
│   ├── services/
│   │   ├── auth_service.dart        # Login/logout
│   │   └── api_service.dart         # Conexión API con retry
│   └── screens/
│       ├── login_screen.dart        # Pantalla de login
│       ├── home_screen.dart         # Navegación principal
│       ├── ordenes_screen.dart       # Listado de órdenes
│       ├── formulario_orden_screen.dart  # Crear/editar orden
│       ├── retiros_screen.dart       # Listado de retiros
│       └── usuarios_screen.dart      # Gestión de usuarios
```

## 📦 Instalación de Dependencias

```bash
cd soporte_ultra_app
flutter pub get
```

## ▶️ Ejecutar en Desarrollo

```bash
flutter run
```

## 📱 Compilar APK Debug

```bash
cd soporte_ultra_app
flutter build apk --debug
```

El APK se genera en: `build/app/outputs/flutter-apk/app-debug.apk`

## 🔌 Endpoints de la API

### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/registrar` - Crear usuario (admin)
- `GET /api/auth/usuarios` - Listar usuarios

### Órdenes
- `GET /api/orden` - Listar órdenes (con paginación y filtros)
- `POST /api/orden` - Crear orden
- `PUT /api/orden/:id` - Actualizar orden
- `DELETE /api/orden/:id` - Eliminar orden
- `GET /api/orden/tecnicos` - Listar técnicos

### Retiros
- `GET /api/retiro` - Listar retiros
- `POST /api/retiro` - Crear retiro
- `PUT /api/retiro/:id` - Actualizar retiro
- `DELETE /api/retiro/:id` - Eliminar retiro

## ⚠️ Notas Importantes

1. **Error 502**: El backend de Render puede dar errores 502 cuando está hibernando. La app tiene retry automático (2 intentos).

2. **JWT**: El token se guarda en SharedPreferences y expira en 8 horas.

3. **Roles**:
   - `admin`: Acceso completo (gestión de usuarios, CRUD completo)
   - `tecnico`: Solo órdenes y retiros

4. **Paginación**: Órdenes y retiros tienen paginación (10 por página)

## 🔧 Pendientes / Mejoras Futuras

- [ ] Exportar a Excel/PDF
- [ ] Notificaciones push
- [ ] Cámaras para fotos de equipos
- [ ] Modo offline
- [ ] Tests unitarios

## 📝 Historial de Versiones

| Fecha | Versión | Cambios |
|-------|---------|---------|
| 2026-04-10 | 1.0.0 | Versión inicial - Login, Órdenes, Retiros, Usuarios |
| 2026-04-10 | 1.0.1 | Fix pagination (String to int) |
| 2026-04-10 | 1.0.2 | Fix dropdown técnico en editar orden |
| 2026-04-10 | 1.0.3 | Retry automático para errores 502 |
| 2026-04-10 | 1.0.4 | Agregar edición de retiros |

---

**Desarrollado por**: Rodrigo Luna  
**Última actualización**: Abril 2026