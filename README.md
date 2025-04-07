# 🚀 TempMail Optimizado

TempMail Optimizado es un script en **Bash** que te permite generar direcciones de correo temporal utilizando **Mail.tm**. Monitorea en tiempo real los correos recibidos y los muestra en un servidor web local para una mejor visualización.

---

## 📌 Características

✅ Genera automáticamente una dirección de correo temporal.
✅ Registra la cuenta y obtiene un token de autenticación.
✅ Monitorea la bandeja de entrada en tiempo real.
✅ Almacena y muestra los correos en un servidor local.
✅ Diseño optimizado para reducir tiempos de espera.

---

## ⚡ Instalación

### 1️⃣ Requisitos Previos
Asegúrate de tener instalados los siguientes paquetes:

- **curl**
- **jq**
- **python3** (para ejecutar el servidor web)

Instálalos con:
```bash
sudo apt update && sudo apt install curl jq python3 -y
```

### 2️⃣ Clonar el Repositorio
```bash
git clone https://github.com/Bilalbel04/tempmail.git
cd tempmail-optimizado
```

### 3️⃣ Dar Permisos de Ejecución
```bash
chmod +x tempmail.sh
```

### 4️⃣ Ejecutar el Script
```bash
./tempmail.sh
```

---

## 🌍 Acceso a los Correos
Los correos recibidos se guardan y pueden visualizarse en:
```bash
http://localhost:5555/
```
Cada correo se guarda como un archivo HTML dentro del directorio `emails/`.

---

## 🛠 Tecnologías Usadas
- **Bash Scripting** 🖥️
- **API de Mail.tm** 📩
- **cURL & jq** 📡
- **Python HTTP Server** 🌍

---

## 🏴‍☠️ Autor
Creado por **Bily** ⚡

Si te gusta este proyecto, ¡dale una ⭐ en GitHub y sígueme para más herramientas útiles!

🔗 [GitHub](https://github.com/tu-usuario) | ✉️ [Contacto](mailto:tu-email@example.com)

---

⚠️ **Aviso:** Este script se proporciona tal cual, sin garantías. Úsalo bajo tu propio riesgo.

