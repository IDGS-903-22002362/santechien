# 📱 Ejecutar AdoPets en tu Teléfono Android

## ✅ Configuración Completada

- **IP del backend**: `192.168.100.11:5151`
- **URL configurada**: `http://192.168.100.11:5151/api/v1`

---

## 🔧 Pasos para Ejecutar

### 1. **Configurar el Backend (.NET)**

Tu backend debe estar escuchando en todas las interfaces de red, no solo en `localhost`.

#### Verifica `appsettings.json` o `Program.cs`:

```csharp
// En Program.cs, asegúrate de que esté así:
builder.WebHost.UseUrls("http://0.0.0.0:5151");

// O en appsettings.json:
{
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://0.0.0.0:5151"
      }
    }
  }
}
```

#### Ejecuta el backend:

```powershell
cd ruta\a\tu\backend
dotnet run
```

Deberías ver algo como:
```
Now listening on: http://0.0.0.0:5151
```

### 2. **Verificar el Firewall de Windows**

El firewall debe permitir conexiones entrantes al puerto 5151:

```powershell
# Ejecutar como Administrador
New-NetFirewallRule -DisplayName "AdoPets Backend" -Direction Inbound -Protocol TCP -LocalPort 5151 -Action Allow
```

O manualmente:
1. Abre **Firewall de Windows Defender** → **Configuración avanzada**
2. Haz clic en **Reglas de entrada** → **Nueva regla**
3. Tipo: **Puerto** → Siguiente
4. TCP, puerto específico: **5151** → Siguiente
5. Permitir la conexión → Siguiente
6. Aplicar a todos los perfiles → Siguiente
7. Nombre: **AdoPets Backend** → Finalizar

### 3. **Probar la Conexión desde tu PC**

Abre un navegador y ve a:
```
http://192.168.100.11:5151/api/v1/auth/login
```

Deberías ver una respuesta (aunque sea un error 405 Method Not Allowed, significa que el servidor responde).

### 4. **Habilitar Depuración USB en tu Teléfono Android**

1. Ve a **Ajustes** → **Acerca del teléfono**
2. Toca **Número de compilación** 7 veces (activa opciones de desarrollador)
3. Ve a **Ajustes** → **Opciones de desarrollador**
4. Habilita **Depuración USB**

### 5. **Conectar tu Teléfono a la PC**

1. Conecta tu teléfono con un cable USB
2. Acepta la autorización de depuración USB en tu teléfono
3. Verifica la conexión:

```powershell
flutter devices
```

Deberías ver algo como:
```
Found 2 devices:
  SM G973F (mobile) • 1234567890ABCDEF • android-arm64 • Android 13 (API 33)
  Chrome (web)      • chrome           • web-javascript • Google Chrome 119.0
```

### 6. **Ejecutar la App en tu Teléfono**

```powershell
cd "c:\Users\dell\OneDrive\Escritorio\Trabajos 10\Android\P1\app_movil"

# Ejecutar en modo debug
flutter run

# O especificar el dispositivo si tienes varios
flutter run -d <device_id>
```

---

## 🐛 Solución de Problemas

### Error: "No se puede conectar al backend"

**Verificar:**
1. ✅ Backend ejecutándose en `http://0.0.0.0:5151`
2. ✅ Firewall permite conexiones al puerto 5151
3. ✅ Tu teléfono y PC están en la misma red WiFi
4. ✅ Puedes acceder a `http://192.168.100.11:5151` desde un navegador en tu PC

**Probar desde tu teléfono:**
1. Abre el navegador en tu Android
2. Ve a `http://192.168.100.11:5151/api/v1/auth/login`
3. Si ves respuesta, el backend está accesible

### Error: "flutter: SocketException: Connection refused"

**Causa**: El backend no está escuchando en todas las interfaces

**Solución**: Cambia `localhost` por `0.0.0.0` en la configuración del backend

### Error: "No devices found"

**Causa**: El teléfono no está conectado o no tiene depuración USB habilitada

**Solución**:
1. Verifica que el cable USB funcione (algunos solo cargan)
2. Acepta la autorización de depuración en el teléfono
3. Prueba con otro puerto USB

### Google Sign-In no funciona

**Causa**: Falta agregar el SHA-1 de tu certificado de depuración

**Solución**:
1. Obtén el SHA-1:
```powershell
cd "c:\Users\dell\OneDrive\Escritorio\Trabajos 10\Android\P1\app_movil\android"
.\gradlew signingReport
```

2. Copia el SHA-1 (ejemplo):
```
SHA-1: 42:94:92:75:F2:19:AA:89:4F:71:15:F4:25:95:53:20:07:8A:8D:2A
```

3. Ve a [Firebase Console](https://console.firebase.google.com/)
4. Selecciona tu proyecto → **Configuración del proyecto** (⚙️)
5. En la app Android, haz clic en **Agregar huella digital**
6. Pega el SHA-1 y guarda

---

## 📊 Configuración de Red

```
PC (Backend):     192.168.100.11:5151
Teléfono Android: 192.168.100.xxx (misma red)
Router:           192.168.100.1
```

### Asegúrate de que:
- ✅ Ambos dispositivos están conectados a la misma red WiFi
- ✅ El router no bloquea la comunicación entre dispositivos (algunos routers tienen "Aislamiento AP")

---

## 🚀 Comandos Rápidos

```powershell
# 1. Verificar dispositivos
flutter devices

# 2. Ejecutar en dispositivo físico
flutter run

# 3. Ejecutar con logs detallados
flutter run -v

# 4. Reinstalar app completamente
flutter run --uninstall-first

# 5. Ver logs en tiempo real
flutter logs
```

---

## 📝 Checklist de Verificación

- [ ] Backend ejecutándose en `http://0.0.0.0:5151`
- [ ] Firewall permite conexiones al puerto 5151
- [ ] Teléfono y PC en la misma red WiFi
- [ ] Depuración USB habilitada en el teléfono
- [ ] Teléfono conectado por USB a la PC
- [ ] `flutter devices` muestra tu dispositivo Android
- [ ] SHA-1 agregado en Firebase Console
- [ ] App configurada con IP `192.168.100.11:5151`

---

## ✅ Todo Listo

Una vez completados estos pasos, ejecuta:

```powershell
flutter run
```

Y la app se instalará y ejecutará en tu teléfono Android! 🎉
