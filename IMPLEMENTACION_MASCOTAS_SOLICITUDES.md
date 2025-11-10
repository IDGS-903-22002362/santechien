# 🐾 AdoPets - Registro de Mascotas y Solicitud de Citas

## ✨ Nuevas Funcionalidades Implementadas

### 1. Registro de Mascotas Propias 🐶🐱

Los adoptantes ahora pueden registrar sus propias mascotas en el sistema para solicitar citas veterinarias.

#### Características:
- **Formulario completo de registro** con validaciones
- **Campos incluidos:**
  - Nombre (requerido)
  - Especie (Perro, Gato, Ave, Roedor, Reptil, Otro)
  - Raza (opcional)
  - Sexo (Macho/Hembra)
  - Fecha de nacimiento (opcional, con cálculo automático de edad)
  - Personalidad (opcional)
  - Estado de salud (opcional)
  - Notas adicionales (opcional)

#### Pantallas:
- `/registrar-mascota` - Formulario de registro
- `/mis-mascotas` - Lista de mascotas registradas

### 2. Solicitud de Citas con Pago Integrado 💳

Sistema completo de solicitud de citas veterinarias con pago del 50% de anticipo mediante PayPal.

#### Flujo Completo:
1. **Selección de mascota**: El usuario selecciona una de sus mascotas registradas
2. **Selección de servicio**: Elige el servicio veterinario deseado
3. **Fecha y hora**: Selecciona la fecha y hora preferida (validación de horario laboral 8 AM - 6 PM)
4. **Motivo de consulta**: Describe el motivo de la cita
5. **Revisión de costos**: 
   - Muestra el costo total
   - Calcula automáticamente el anticipo del 50%
   - Muestra el saldo a pagar el día de la cita
6. **Confirmación**: Diálogo de confirmación con resumen completo
7. **Pago con PayPal**: 
   - Crea orden de PayPal automáticamente
   - Abre WebView con formulario de pago de PayPal
   - Captura el pago una vez aprobado
8. **Confirmación final**: Notifica al usuario que su solicitud está en revisión

#### Estados de Solicitud:
- `Pendiente` - Recién creada, esperando revisión
- `En Revisión` - Personal está revisando
- `Pendiente Pago` - Requiere pago del anticipo
- `Pagada - Pendiente Confirmación` - Pago recibido, esperando confirmación final
- `Confirmada` - Cita confirmada y creada
- `Rechazada` - Solicitud rechazada
- `Cancelada` - Cancelada por el usuario
- `Expirada` - Tiempo de pago expirado

#### Pantallas:
- `/solicitar-cita` - Formulario de solicitud con integración de pago
- `/mis-solicitudes` - Lista de todas las solicitudes
- Detalle de solicitud - Vista completa con opción de pagar si está pendiente

### 3. Sistema de Pagos PayPal 💰

Integración completa con PayPal para procesar pagos de anticipos.

#### Características:
- **Creación de orden**: Genera orden de PayPal con el monto del anticipo
- **WebView seguro**: Abre formulario de pago de PayPal en WebView
- **Captura automática**: Captura el pago una vez aprobado por el usuario
- **Manejo de errores**: Gestión completa de cancelaciones y errores
- **Deep linking**: Redirección automática después del pago

## 📁 Estructura de Archivos

```
lib/
├── models/
│   ├── solicitud_cita.dart         # Modelos de solicitud de cita
│   ├── mascota.dart                # Modelo de mascota (actualizado)
│   └── pago.dart                   # Modelos de pago (actualizado)
│
├── services/
│   ├── solicitud_cita_service.dart # Servicio para solicitudes
│   ├── mascota_service.dart        # Servicio de mascotas (actualizado)
│   └── pago_service.dart           # Servicio de pagos (existente)
│
├── screens/
│   ├── mascotas/
│   │   ├── mis_mascotas_screen.dart         # Lista de mascotas
│   │   └── registrar_mascota_screen.dart    # Formulario de registro
│   │
│   └── solicitudes/
│       ├── solicitud_cita_screen.dart       # Solicitud con pago integrado
│       ├── mis_solicitudes_screen.dart      # Lista de solicitudes
│       └── solicitud_detalle_screen.dart    # Detalle con opción de pago
```

## 🔧 Configuración Requerida

### Dependencias Agregadas

```yaml
dependencies:
  webview_flutter: ^4.10.0    # Para WebView de PayPal
  image_picker: ^1.1.2        # Para futuras fotos de mascotas
```

### Ejecutar

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run
```

## 🚀 Uso

### Para Registrar una Mascota:

1. Inicia sesión en la aplicación
2. Ve al menú lateral y selecciona "Mis Mascotas"
3. Presiona el botón flotante "Registrar Mascota"
4. Completa el formulario con los datos de tu mascota
5. Presiona "Registrar Mascota"

### Para Solicitar una Cita:

1. Asegúrate de tener al menos una mascota registrada
2. Ve al menú lateral y selecciona "Solicitar Cita"
3. Selecciona la mascota, servicio, fecha y hora
4. Describe el motivo de la consulta
5. Revisa el resumen de costos y confirma
6. Serás redirigido a PayPal para pagar el anticipo del 50%
7. Completa el pago en PayPal
8. Recibirás confirmación y tu solicitud estará en revisión

### Para Ver Tus Solicitudes:

1. Ve al menú lateral y selecciona "Mis Solicitudes"
2. Verás todas tus solicitudes con su estado actual
3. Puedes ver el detalle de cada solicitud
4. Si una solicitud requiere pago, podrás pagarla desde el detalle

## 📝 Notas Importantes

### Validaciones:
- **Horario laboral**: Las citas solo pueden solicitarse entre 8:00 AM y 6:00 PM
- **Mascota requerida**: Debes tener al menos una mascota registrada para solicitar citas
- **Pago del 50%**: Es obligatorio pagar el 50% de anticipo para confirmar la cita
- **Saldo restante**: El 50% restante se paga el día de la cita

### Flujo de Pago:
1. Se crea la solicitud en estado "Pendiente Pago"
2. Se genera una orden de PayPal automáticamente
3. El usuario completa el pago en PayPal
4. El sistema captura el pago y actualiza el estado a "Pagada - Pendiente Confirmación"
5. El personal revisa y confirma la cita

### Estados de Solicitud:
- Las solicitudes se ordenan de más reciente a más antigua
- Los colores indican el estado actual:
  - 🟠 Naranja: Pendiente/En Revisión
  - 🔴 Rojo: Pendiente Pago
  - 🟣 Morado: Pagada - Pendiente Confirmación
  - 🟢 Verde: Confirmada
  - ⚫ Gris: Cancelada/Expirada

## 🐛 Troubleshooting

### Problema: "No tienes mascotas registradas"
**Solución**: Registra al menos una mascota antes de solicitar una cita

### Problema: El pago no se procesa
**Solución**: 
1. Verifica tu conexión a internet
2. Asegúrate de completar el proceso de pago en PayPal
3. Si el problema persiste, intenta nuevamente

### Problema: La WebView de PayPal no se abre
**Solución**:
1. Asegúrate de tener las dependencias actualizadas: `flutter pub get`
2. Verifica que `webview_flutter` esté instalado correctamente

## 📱 Pantallas Principales

### Home Screen (Actualizado)
- Nuevo botón: "Mis Mascotas"
- Nuevo botón: "Solicitar Cita"
- Menú lateral actualizado con nuevas opciones

### Mis Mascotas
- Lista de mascotas registradas
- Avatar con color por especie
- Información completa de cada mascota
- Botón flotante para registrar nueva mascota

### Solicitar Cita
- Selector de mascota
- Selector de servicio con precio
- Selector de fecha y hora
- Campo de motivo de consulta
- Resumen de costos (total, anticipo, saldo)
- Integración de pago PayPal

### Mis Solicitudes
- Lista de solicitudes ordenadas por fecha
- Estados visuales con colores
- Botón para pagar si está pendiente
- Navegación a detalle

### Detalle de Solicitud
- Información completa de la solicitud
- Estado visual con icono
- Datos de la mascota y servicio
- Resumen de costos
- Botón de pago si está pendiente

## 🔐 Seguridad

- **Autenticación requerida**: Todas las operaciones requieren usuario autenticado
- **Tokens JWT**: Se usa el token del usuario para todas las peticiones
- **PayPal seguro**: Los pagos se procesan a través de PayPal oficial
- **Validación de datos**: Todos los formularios tienen validaciones

## 📚 Endpoints Utilizados

### Mascotas:
- `GET /api/mismascotas` - Obtener mis mascotas
- `POST /api/mismascotas` - Registrar nueva mascota
- `POST /api/mismascotas/{id}/fotos` - Agregar fotos (preparado para futuro)

### Servicios:
- `GET /api/servicios` - Obtener servicios disponibles

### Solicitudes de Cita:
- `GET /api/solicitudescitasdigitales/usuario/{userId}` - Mis solicitudes
- `GET /api/solicitudescitasdigitales/{id}` - Detalle de solicitud
- `POST /api/solicitudescitasdigitales` - Crear solicitud
- `POST /api/solicitudescitasdigitales/verificar-disponibilidad` - Verificar disponibilidad (preparado)

### Pagos PayPal:
- `POST /api/pagos/paypal/create-order` - Crear orden
- `POST /api/pagos/paypal/capture` - Capturar pago

## ✅ Testing

Para probar las nuevas funcionalidades:

1. **Registro de Mascota**:
   - Registra una mascota con datos válidos
   - Verifica que aparezca en "Mis Mascotas"

2. **Solicitud de Cita**:
   - Selecciona una mascota y servicio
   - Verifica que el cálculo del anticipo sea correcto (50%)
   - Confirma la solicitud

3. **Pago PayPal**:
   - Usa credenciales de sandbox de PayPal
   - Completa el pago
   - Verifica que la solicitud cambie a "Pagada - Pendiente Confirmación"

## 🎯 Próximas Mejoras

- [ ] Agregar fotos a las mascotas
- [ ] Notificaciones push cuando cambia el estado
- [ ] Historial completo de citas
- [ ] Calificación de servicios
- [ ] Recordatorios de citas
- [ ] Chat con veterinario

---

**Versión**: 2.0.0
**Fecha**: Noviembre 2025
**Autor**: Equipo AdoPets
