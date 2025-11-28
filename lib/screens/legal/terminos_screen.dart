import 'package:flutter/material.dart';

class TerminosScreen extends StatelessWidget {
  const TerminosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Términos y Condiciones')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Términos y Condiciones de Uso',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Bienvenido. Al utilizar la aplicación AdoPets aceptas estos términos y condiciones. '
            'Lee cuidadosamente este documento, ya que establece las reglas de uso, tus derechos y obligaciones.',
          ),
          SizedBox(height: 16),
          Text(
            '1. Cuenta y acceso',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Para acceder a determinadas funcionalidades, es necesario iniciar sesión. '
            'Eres responsable de mantener la confidencialidad de tus credenciales y de toda actividad realizada con tu cuenta.',
          ),
          SizedBox(height: 16),
          Text(
            '2. Uso permitido',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Te comprometes a utilizar la aplicación de forma lícita, evitando conductas que infrinjan derechos de terceros, '
            'incluyendo la publicación de contenido ofensivo, ilegal o que vulnere la privacidad.',
          ),
          SizedBox(height: 16),
          Text(
            '3. Contenido y propiedad intelectual',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'El contenido, marcas y elementos visuales de la aplicación están protegidos por las leyes de propiedad intelectual. '
            'No se permite su copia, distribución o modificación sin autorización.',
          ),
          SizedBox(height: 16),
          Text(
            '4. Privacidad y datos personales',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Tratamos tus datos conforme a nuestra Política de Privacidad. '
            'Recopilamos y procesamos información necesaria para prestar el servicio (por ejemplo, notificaciones y gestión de citas).',
          ),
          SizedBox(height: 16),
          Text(
            '5. Notificaciones y comunicaciones',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Podemos enviarte notificaciones relacionadas con la prestación del servicio. '
            'Puedes gestionar tus preferencias desde la configuración del dispositivo.',
          ),
          SizedBox(height: 16),
          Text(
            '6. Limitación de responsabilidad',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'La aplicación se ofrece “tal cual”. No garantizamos disponibilidad ininterrumpida ni ausencia total de errores. '
            'No seremos responsables por daños indirectos derivados del uso de la aplicación.',
          ),
          SizedBox(height: 16),
          Text(
            '7. Cambios en los términos',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Podemos actualizar estos términos para reflejar cambios legales o de producto. '
            'Te notificaremos las modificaciones relevantes a través de la aplicación.',
          ),
          SizedBox(height: 16),
          Text('8. Contacto', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            'Si tienes preguntas, contáctanos mediante los canales oficiales dentro de la aplicación.',
          ),
        ],
      ),
    );
  }
}
