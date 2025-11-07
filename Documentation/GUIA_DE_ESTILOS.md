# Guía de Estilos - AdoPets

Esta guía documenta las convenciones de código, estilos y mejores prácticas utilizadas en el proyecto AdoPets.

## Tabla de Contenidos
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Convenciones de Nombres](#convenciones-de-nombres)
- [React y JSX](#react-y-jsx)
- [Estilos con Tailwind CSS](#estilos-con-tailwind-css)
- [Servicios y API](#servicios-y-api)
- [Hooks Personalizados](#hooks-personalizados)
- [Context API](#context-api)
- [Formularios](#formularios)
- [Manejo de Errores](#manejo-de-errores)
- [Configuración](#configuración)
- [ESLint](#eslint)

---

## Estructura del Proyecto

### Organización de Carpetas

```
src/
├── assets/          # Recursos estáticos (imágenes, fuentes, etc.)
├── components/      # Componentes reutilizables
├── config/          # Archivos de configuración
├── context/         # Context API de React
├── hooks/           # Hooks personalizados
├── pages/           # Componentes de páginas/vistas
└── services/        # Servicios para llamadas API
```

### Ubicación de Archivos

- **Componentes reutilizables**: `src/components/`
- **Páginas/Vistas**: `src/pages/`
- **Hooks personalizados**: `src/hooks/`
- **Contextos**: `src/context/`
- **Servicios de API**: `src/services/`
- **Configuración**: `src/config/`
- **Assets estáticos**: `public/img/`

---

## Convenciones de Nombres

### Archivos y Carpetas

- **Componentes React**: PascalCase con extensión `.jsx`
  ```
  ✅ Login.jsx
  ✅ Dashboard.jsx
  ✅ PrivateRoute.jsx
  ❌ login.jsx
  ❌ dashBoard.jsx
  ```

- **Servicios**: camelCase con sufijo `.service.js`
  ```
  ✅ auth.service.js
  ✅ usuario.service.js
  ✅ api.service.js
  ```

- **Hooks personalizados**: camelCase con prefijo `use` y extensión `.js`
  ```
  ✅ useAuth.js
  ✅ useForm.js
  ```

- **Archivos de configuración**: camelCase con sufijo `.config.js`
  ```
  ✅ api.config.js
  ✅ tailwind.config.js
  ✅ vite.config.js
  ```

- **Context**: PascalCase con sufijo `Context.jsx`
  ```
  ✅ AuthContext.jsx
  ✅ AuthContextValue.js
  ```

### Variables y Funciones

- **Variables**: camelCase
  ```javascript
  const userName = 'Juan';
  const isAuthenticated = true;
  ```

- **Constantes**: UPPER_SNAKE_CASE
  ```javascript
  const API_BASE_URL = 'http://localhost:5151';
  const MAX_RETRIES = 3;
  ```

- **Funciones**: camelCase, verbos descriptivos
  ```javascript
  const handleSubmit = () => {};
  const fetchUserData = () => {};
  const validateForm = () => {};
  ```

- **Componentes React**: PascalCase
  ```javascript
  const UserProfile = () => {};
  const LoginForm = () => {};
  ```

---

## React y JSX

### Importaciones

Organizar las importaciones en el siguiente orden:

```javascript
// 1. Bibliotecas de terceros
import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';

// 2. Hooks personalizados
import { useAuth } from '../hooks/useAuth';

// 3. Componentes
import Logo from '../components/Logo';

// 4. Servicios
import authService from '../services/auth.service';

// 5. Estilos (si aplica)
import './App.css';
```

### Estructura de Componentes

```javascript
import React, { useState } from 'react';

const ComponentName = ({ prop1, prop2 }) => {
  // 1. Hooks de estado
  const [state, setState] = useState(initialValue);

  // 2. Hooks de contexto/navegación
  const navigate = useNavigate();
  const { user } = useAuth();

  // 3. Funciones auxiliares
  const handleClick = () => {
    // lógica
  };

  // 4. Efectos
  useEffect(() => {
    // lógica
  }, []);

  // 5. Renderizado
  return (
    <div>
      {/* JSX */}
    </div>
  );
};

export default ComponentName;
```

### Props

- **Destructurar props** directamente en los parámetros
  ```javascript
  ✅ const Logo = ({ className = "", width = "auto", height = "40px" }) => {}
  ❌ const Logo = (props) => { const { className } = props; }
  ```

- **Valores por defecto** en la destructuración
  ```javascript
  const Loading = ({ message = 'Cargando...' }) => {
    return <p>{message}</p>;
  };
  ```

### JSX

- **Usar fragmentos** cuando sea necesario
  ```javascript
  return (
    <>
      <Header />
      <Main />
    </>
  );
  ```

- **Clases condicionales** con template strings
  ```javascript
  className={`base-class ${isActive ? 'active' : ''}`}
  ```

- **Evitar lógica compleja** en JSX
  ```javascript
  // ✅ Bueno
  const formattedDate = formatDate(date);
  return <p>{formattedDate}</p>;

  // ❌ Evitar
  return <p>{new Date(date).toLocaleDateString('es-ES', {...})}</p>;
  ```

---

## Estilos con Tailwind CSS

### Configuración de Colores

```javascript
// tailwind.config.js
colors: {
  primary: {
    DEFAULT: '#2B6CB0',  // Azul principal
    dark: '#0A2540',      // Azul oscuro
    light: '#87CEFA',     // Azul claro
  },
}
```

### Clases Personalizadas

Definir clases reutilizables en `index.css`:

```css
@layer components {
  .btn-primary {
    @apply bg-primary hover:bg-primary-dark text-white font-semibold py-2 px-4 rounded-lg transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed;
  }
  
  .input-field {
    @apply w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent;
  }

  .card {
    @apply bg-white rounded-lg shadow-md p-6;
  }
}
```

### Uso de Clases Tailwind

- **Orden de clases**: layout → espaciado → colores → tipografía → efectos
  ```javascript
  className="flex items-center justify-center px-4 py-2 bg-primary text-white font-semibold rounded-lg hover:bg-primary-dark transition-colors"
  ```

- **Responsive design**: mobile-first
  ```javascript
  className="w-full sm:w-auto md:w-1/2 lg:w-1/3"
  ```

- **Gradientes** para fondos
  ```javascript
  className="bg-gradient-to-br from-primary-dark via-primary to-primary-light"
  ```

### Componentes de UI Comunes

#### Botones
```javascript
// Primario
<button className="w-full btn-primary">
  Guardar
</button>

// Secundario
<button className="w-full btn-secondary">
  Cancelar
</button>

// Con loading
<button disabled={loading} className="w-full btn-primary flex items-center justify-center">
  {loading ? (
    <>
      <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white">
        {/* ... */}
      </svg>
      Cargando...
    </>
  ) : (
    'Enviar'
  )}
</button>
```

#### Inputs
```javascript
<input
  type="text"
  className="input-field"
  placeholder="Texto aquí"
/>
```

#### Cards
```javascript
<div className="bg-white rounded-2xl shadow-2xl p-8">
  {/* Contenido */}
</div>
```

#### Alertas de Error
```javascript
<div className="mb-6 bg-red-50 border border-red-200 rounded-lg p-4">
  <div className="flex">
    <svg className="w-5 h-5 text-red-400 mr-2">
      {/* icono */}
    </svg>
    <div className="text-sm text-red-800">
      <p>{error}</p>
    </div>
  </div>
</div>
```

---

## Servicios y API

### Estructura de Servicios

Usar **clases singleton** para servicios:

```javascript
import apiClient from './api.service';
import { ENDPOINTS } from '../config/api.config';

class AuthService {
  /**
   * Descripción del método
   * @param {Object} params - Descripción de parámetros
   * @returns {Promise<Object>} - Descripción del retorno
   */
  async methodName(params) {
    try {
      const response = await apiClient.post(ENDPOINTS.AUTH.LOGIN, params);
      
      if (response.data.success) {
        // Lógica de éxito
        return response.data;
      }
      
      return response.data;
    } catch (error) {
      throw this.handleError(error);
    }
  }

  /**
   * Manejar errores de la API
   */
  handleError(error) {
    if (error.response) {
      const { data, status } = error.response;
      return {
        message: data?.message || 'Error en la solicitud',
        errors: data?.errors || [],
        status,
      };
    } else if (error.request) {
      return {
        message: 'No se pudo conectar con el servidor',
        errors: ['Verifica que el backend esté corriendo'],
        status: 0,
      };
    } else {
      return {
        message: error.message || 'Error desconocido',
        errors: [],
        status: 0,
      };
    }
  }
}

export default new AuthService();
```

### Configuración de API

Centralizar configuración en `api.config.js`:

```javascript
export const API_CONFIG = {
  BASE_URL: import.meta.env.VITE_API_BASE_URL || 'http://localhost:5151/api/v1',
  TIMEOUT: parseInt(import.meta.env.VITE_API_TIMEOUT) || 30000,
  HEADERS: {
    'Content-Type': 'application/json',
  },
};

export const ENDPOINTS = {
  AUTH: {
    LOGIN: '/auth/login',
    REGISTER: '/auth/register',
    LOGOUT: '/auth/logout',
    ME: '/auth/me',
  },
  USUARIOS: {
    BASE: '/usuarios',
    BY_ID: (id) => `/usuarios/${id}`,
  },
};
```

### Documentación JSDoc

Usar JSDoc para documentar métodos:

```javascript
/**
 * Iniciar sesión
 * @param {Object} credentials - { email, password, rememberMe }
 * @returns {Promise<Object>} - Datos del usuario y tokens
 */
async login(credentials) {
  // implementación
}
```

---

## Hooks Personalizados

### Estructura de Hooks

```javascript
import { useContext } from 'react';
import { AuthContext } from '../context/AuthContextValue';

export const useAuth = () => {
  const context = useContext(AuthContext);
  
  if (!context) {
    throw new Error('useAuth debe ser usado dentro de un AuthProvider');
  }
  
  return context;
};
```

### Convenciones

- **Prefijo `use`**: Todos los hooks deben empezar con `use`
- **Validación de contexto**: Siempre validar que el contexto exista
- **Mensajes de error claros**: Indicar el Provider necesario

---

## Context API

### Estructura de Context

Separar la definición del contexto y el Provider:

**AuthContextValue.js** (solo el contexto)
```javascript
import { createContext } from 'react';

export const AuthContext = createContext(null);
```

**AuthContext.jsx** (el Provider)
```javascript
import React, { useState, useEffect } from 'react';
import authService from '../services/auth.service';
import { AuthContext } from './AuthContextValue';

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // Inicialización
  useEffect(() => {
    const storedUser = authService.getStoredUser();
    const token = localStorage.getItem('accessToken');

    if (storedUser && token) {
      setUser(storedUser);
      setIsAuthenticated(true);
    }
    setLoading(false);
  }, []);

  // Métodos del contexto
  const login = async (credentials) => {
    // implementación
  };

  const logout = async () => {
    // implementación
  };

  // Valor del contexto
  const value = {
    user,
    isAuthenticated,
    loading,
    login,
    logout,
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};
```

---

## Formularios

### Estado del Formulario

Usar un objeto de estado para todos los campos:

```javascript
const [formData, setFormData] = useState({
  email: '',
  password: '',
  rememberMe: false,
});

const handleChange = (e) => {
  const { name, value, type, checked } = e.target;
  setFormData((prev) => ({
    ...prev,
    [name]: type === 'checkbox' ? checked : value,
  }));
};
```

### Validación y Envío

```javascript
const [errors, setErrors] = useState([]);
const [loading, setLoading] = useState(false);

const handleSubmit = async (e) => {
  e.preventDefault();
  setErrors([]);
  setLoading(true);

  try {
    const result = await service.method(formData);

    if (result.success) {
      navigate('/success');
    } else {
      setErrors(result.errors || [result.message]);
    }
  } catch {
    setErrors(['Error al procesar. Por favor, intenta de nuevo.']);
  } finally {
    setLoading(false);
  }
};
```

---

## Manejo de Errores

### Mostrar Errores en UI

```javascript
{errors.length > 0 && (
  <div className="mb-6 bg-red-50 border border-red-200 rounded-lg p-4">
    <div className="flex">
      <svg className="w-5 h-5 text-red-400 mr-2" fill="currentColor" viewBox="0 0 20 20">
        {/* icono */}
      </svg>
      <div className="text-sm text-red-800">
        {errors.map((error, index) => (
          <p key={index}>{error}</p>
        ))}
      </div>
    </div>
  </div>
)}
```

### Try-Catch en Servicios

```javascript
try {
  const response = await apiClient.post(endpoint, data);
  return response.data;
} catch (error) {
  throw this.handleError(error);
}
```

---

## Configuración

### Variables de Entorno

Usar `import.meta.env` para variables de entorno con valores por defecto:

```javascript
const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5151/api/v1';
const TIMEOUT = parseInt(import.meta.env.VITE_API_TIMEOUT) || 30000;
```

### Archivo `.env`

```env
VITE_API_BASE_URL=http://localhost:5151/api/v1
VITE_API_TIMEOUT=30000
```

---

## ESLint

### Configuración

```javascript
export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{js,jsx}'],
    rules: {
      'no-unused-vars': ['error', { varsIgnorePattern: '^[A-Z_]' }],
    },
  },
])
```

### Reglas Principales

- **no-unused-vars**: Variables no utilizadas generan error (excepto constantes en mayúsculas)
- **ecmaVersion**: 2020 o superior
- **sourceType**: module

---

## Convenciones Generales

### Comentarios

- Usar comentarios solo cuando sea necesario para aclarar lógica compleja
- Preferir código auto-documentado con nombres descriptivos
- Usar JSDoc para funciones públicas de servicios

### Formato de Código

- **Indentación**: 2 espacios
- **Comillas**: Simples `'` para strings
- **Punto y coma**: Opcional (consistente con ESLint)
- **Línea máxima**: ~100 caracteres (flexible)

### Async/Await

Preferir `async/await` sobre promesas:

```javascript
// ✅ Bueno
const result = await fetchData();

// ❌ Evitar
fetchData().then(result => {});
```

---

## Ejemplos Completos

### Componente de Página Completo

```javascript
import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import Logo from '../components/Logo';

const Login = () => {
  const navigate = useNavigate();
  const { login } = useAuth();

  const [formData, setFormData] = useState({
    email: '',
    password: '',
    rememberMe: false,
  });

  const [errors, setErrors] = useState([]);
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErrors([]);
    setLoading(true);

    try {
      const result = await login(formData);

      if (result.success) {
        navigate('/dashboard');
      } else {
        setErrors(result.errors || [result.message]);
      }
    } catch {
      setErrors(['Error al iniciar sesión.']);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-dark via-primary to-primary-light flex items-center justify-center px-4">
      <div className="max-w-md w-full">
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <div className="text-center mb-8">
            <div className="mb-4 flex justify-center">
              <Logo height="80px" />
            </div>
            <h2 className="text-3xl font-bold text-gray-900">Bienvenido</h2>
          </div>

          {errors.length > 0 && (
            <div className="mb-6 bg-red-50 border border-red-200 rounded-lg p-4">
              <div className="text-sm text-red-800">
                {errors.map((error, index) => (
                  <p key={index}>{error}</p>
                ))}
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                Correo electrónico
              </label>
              <input
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
                className="input-field"
                placeholder="tu@email.com"
              />
            </div>

            <button
              type="submit"
              disabled={loading}
              className="w-full btn-primary"
            >
              {loading ? 'Cargando...' : 'Iniciar Sesión'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Login;
```

---

## Checklist de Calidad

Antes de hacer commit, verificar:

- [ ] Nombres de archivos y componentes siguen convenciones
- [ ] Importaciones están organizadas correctamente
- [ ] No hay console.log en producción
- [ ] Errores son manejados apropiadamente
- [ ] Componentes están documentados si es necesario
- [ ] Estilos Tailwind están en orden lógico
- [ ] No hay código duplicado
- [ ] Variables de entorno tienen valores por defecto
- [ ] ESLint no muestra errores

---

## Recursos

- [React Docs](https://react.dev/)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [React Router](https://reactrouter.com/)
- [Axios](https://axios-http.com/)
- [Vite](https://vitejs.dev/)

---

**Última actualización**: Octubre 2025
