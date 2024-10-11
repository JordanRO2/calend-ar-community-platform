# **Calend.ar: Plataforma Comunitaria de Gestión de Eventos**

## **Descripción**
`Calend.ar` es una plataforma web para la organización, descubrimiento y gestión de eventos en diversas comunidades. Los administradores de comunidades pueden gestionar sus eventos de manera autónoma, mientras que los usuarios pueden explorar, personalizar eventos según sus intereses y generar calendarios personalizados. La plataforma ofrece soporte para notificaciones en tiempo real, recordatorios, comentarios en eventos y más.

Este proyecto es parte de un **trabajo escolar** cuyo objetivo es aplicar conceptos de desarrollo web, gestión de bases de datos, autenticación segura y comunicación en tiempo real en una plataforma funcional.

## **Características Clave**
- **Gestión de Comunidades:** Los administradores pueden crear, editar y gestionar sus comunidades y eventos.
- **Exploración de Eventos:** Los usuarios pueden descubrir eventos filtrando por comunidad, tipo de evento, fecha, etc.
- **Generación de Calendarios Personalizados:** Los usuarios pueden personalizar sus calendarios con eventos seleccionados y exportarlos en PDF.
- **Notificaciones en Tiempo Real:** Los usuarios reciben notificaciones sobre nuevos eventos, actualizaciones y recordatorios de eventos próximos.
- **Soporte Multimedia:** Posibilidad de agregar imágenes y descripciones detalladas en eventos y comunidades.

## **Tecnologías Utilizadas**
- **Frontend:** Flutter
- **Backend:** Flask (Python)
- **Base de Datos:** MongoDB
- **Autenticación:** JWT (JSON Web Tokens)
- **Notificaciones en Tiempo Real:** Flask-SocketIO
- **Contenerización:** Docker

## **Instalación y Configuración**

### **Requisitos Previos**
- Docker instalado (opcional para contenerización).
- Python 3.8+.
- Node.js y Flutter instalados.

### **Pasos de Instalación**

1. **Clona este repositorio:**
    ```bash
    git clone https://github.com/tu_usuario/calend-ar-community-platform.git
    cd calend-ar-community-platform
    ```

2. **Instala las dependencias del backend:**
    ```bash
    pip install -r requirements.txt
    ```

3. **Configura el archivo `.env`:**
    Crea un archivo `.env` en el directorio raíz con las siguientes variables:
    ```
    SECRET_KEY=tu_clave_secreta
    MONGODB_URI=mongodb://localhost:27017/calendars
    JWT_SECRET_KEY=tu_clave_jwt_secreta
    SOCKETIO_CORS_ALLOWED_ORIGINS=*
    ```

4. **Inicializa la base de datos:**
    ```bash
    flask db init
    flask db migrate
    flask db upgrade
    ```

5. **Ejecuta el servidor de Flask:**
    ```bash
    flask run
    ```

6. **Levanta el frontend (Flutter):**
    ```bash
    cd frontend
    flutter run
    ```

## **Uso de la Aplicación**
1. **Registro e Inicio de Sesión:** Los usuarios deben registrarse y autenticarse con JWT.
2. **Exploración de Eventos:** Accede a la página de eventos y utiliza los filtros para buscar eventos específicos.
3. **Gestión de Calendarios:** Añade eventos a tu calendario personal y personalízalo con colores y formatos.
4. **Notificaciones:** Recibe notificaciones en tiempo real sobre nuevos eventos y cambios en los existentes.

## **API Endpoints**

| Método | Endpoint                        | Descripción                                  |
|--------|----------------------------------|----------------------------------------------|
| POST   | `/api/auth/register`             | Registra un nuevo usuario.                   |
| POST   | `/api/auth/login`                | Inicia sesión y genera un token JWT.         |
| GET    | `/api/communities`               | Obtiene todas las comunidades disponibles.   |
| POST   | `/api/communities`               | Crea una nueva comunidad (admin).            |
| GET    | `/api/events`                    | Obtiene todos los eventos disponibles.       |
| POST   | `/api/events`                    | Crea un nuevo evento en una comunidad.       |
| GET    | `/api/calendars/<id>`            | Obtiene un calendario personalizado por ID.  |
| POST   | `/api/calendars`                 | Crea un calendario personalizado.            |
| POST   | `/api/notifications`             | Crea una notificación para un usuario.       |

Para más detalles, consulta la documentación completa de la API.

## **Licencia**
Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más información.
