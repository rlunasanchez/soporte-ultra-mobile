# Carga de OS - App Flutter

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
- **Compartir**: share_plus ^10.1.4

## 📁 Estructura del Proyecto

```
soporte_ultra_app/
├── lib/
│   ├── main.dart                    # App principal con localization
│   ├── config/
│   │   └── api_config.dart          # URLs de la API
│   ├── models/
│   │   ├── orden.dart               # Modelo Orden
│   │   ├── usuario.dart             # Modelo Usuario
│   │   └── retiro.dart              # Modelo Retiro
│   ├── providers/
│   │   └── auth_provider.dart       # Gestión auth + timeout inactividad
│   ├── services/
│   │   ├── auth_service.dart        # Login/logout
│   │   └── api_service.dart         # Conexión API con retry + downloads
│   └── screens/
│       ├── login_screen.dart        # Pantalla de login
│       ├── home_screen.dart         # Navegación principal (BottomNav)
│       ├── ordenes_screen.dart      # Informes con filtros + exportación
│       ├── formulario_orden_screen.dart  # Crear/editar informe técnico
│       ├── retiros_screen.dart      # Retiros bodega con filtros + exportación
│       └── usuarios_screen.dart     # Gestión de usuarios
```

## ✅ Funcionalidades Implementadas

### Autenticación
- Login con usuario/contraseña
- Logout automático por inactividad (10 minutos)
- Token JWT almacenado en SharedPreferences

### Informes (Órdenes de Servicio)
- Listado paginado con filtros:
  - OS, Cliente, Técnico, Estado, Equipo, Marca
  - Fechas de Asignación (Desde/Hasta)
  - Fechas de Reparación (Desde/Hasta)
- Búsqueda case-insensitive
- Crear nuevo informe técnico
- Editar informe existente
- Eliminar informe
- Exportar: Excel Carga, Excel Correo, Excel Respaldo, PDF

### Retiros de Bodega
- Listado paginado con filtros por fecha
- Crear nuevo retiro
- Editar retiro existente
- Eliminar retiro
- Exportar a Excel

### Configuración
- Timeout de inactividad: 10 minutos
- Localización: Español (Chile)
- Icono de app personalizado

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

### Órdenes (Informes)
- `GET /api/orden` - Listar con filtros y paginación
- `POST /api/orden` - Crear orden
- `PUT /api/orden/:id` - Actualizar orden
- `DELETE /api/orden/:id` - Eliminar orden
- `GET /api/orden/tecnicos` - Listar técnicos
- `GET /api/orden/filtros-valores` - Valores para filtros
- `GET /api/orden/valores-formulario` - Valores para formulario
- `GET /api/orden/excel` - Exportar Excel Carga
- `GET /api/orden/excel-correo` - Exportar Excel Correo
- `GET /api/orden/excel-respaldo` - Exportar Excel Respaldo
- `GET /api/orden/pdf` - Exportar PDF

### Retiros
- `GET /api/retiro` - Listar con filtros y paginación
- `POST /api/retiro` - Crear retiro
- `PUT /api/retiro/:id` - Actualizar retiro
- `DELETE /api/retiro/:id` - Eliminar retiro
- `GET /api/retiro/excel` - Exportar a Excel

## ⚠️ Notas Importantes

1. **Error 502**: El backend de Render puede dar errores 502 cuando está hibernando. La app tiene retry automático (2 intentos).

2. **JWT**: El token se guarda en SharedPreferences y expira en 8 horas.

3. **Roles**:
   - `admin`: Acceso completo (gestión de usuarios, CRUD completo)
   - `tecnico`: Solo órdenes y retiros

4. **Paginación**: Órdenes y retiros tienen paginación (10 por página)

5. **Timeout**: Sesión se cierra automáticamente después de 10 minutos sin actividad

6. **Exportaciones**: Los archivos se descargan y se comparten usando el menú nativo de Android

## 🔧 Pendientes / Mejoras Futuras

- [ ] Notificaciones push
- [ ] Cámaras para fotos de equipos
- [ ] Modo offline
- [ ] Tests unitarios
- [ ] Versión release del APK

## 📝 Historial de Versiones

| Fecha | Versión | Cambios |
|-------|---------|---------|
| 2026-04-10 | 1.0.0 | Versión inicial - Login, Órdenes, Retiros, Usuarios |
| 2026-04-10 | 1.0.1 | Fix pagination (String to int) |
| 2026-04-10 | 1.0.2 | Fix dropdown técnico en editar orden |
| 2026-04-10 | 1.0.3 | Retry automático para errores 502 |
| 2026-04-10 | 1.0.4 | Agregar edición de retiros |
| 2026-04-13 | 1.1.0 | Filtros avanzados, Exportar Excel/PDF, Timeout inactividad, Español |

---

**Desarrollado por**: Rodrigo Luna  
**Última actualización**: Abril 2026