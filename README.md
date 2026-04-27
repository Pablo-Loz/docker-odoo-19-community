# SPL Gestión - Odoo 19 Community (Docker)

## 📦 Contenido

| Archivo              | Descripción                                                        |
|----------------------|--------------------------------------------------------------------|
| `docker-compose.yml` | Orquestación de Odoo 19 + PostgreSQL 16                            |
| `Dockerfile`         | Imagen personalizada con click-odoo-contrib y MuK Web Theme        |
| `odoo.conf`          | Configuración de Odoo                                              |
| `custom-addons/`     | Carpeta para tus módulos/addons personalizados                     |

## 🚀 Inicio rápido

```bash
# 1. Construir y levantar los contenedores
docker compose up -d --build

# 2. Acceder a Odoo
# Abre http://localhost:8069 en tu navegador
```

En el primer arranque, Odoo te pedirá crear la base de datos. Usa estos datos:
- **Master Password**: `admin_master_password` (cámbiala en `odoo.conf`)
- **Database Name**: el que quieras (ej: `spl_gestion`)

## 🎨 Tema MuK Web Theme (Interfaz Enterprise para Community)

El repo [muk-it/odoo-modules](https://github.com/muk-it/odoo-modules) se clona automáticamente dentro de la imagen. Incluye:

- **`muk_web_theme`** - Tema backend estilo Enterprise
- **`muk_web_enterprise_theme`** - Mejoras adicionales de interfaz
- **`muk_web_chatter`** - Mejoras en el chatter
- **`muk_web_dialog`** - Mejoras en diálogos
- Y muchos más módulos útiles

**Para activar el tema:**
1. Entra en Odoo → Ajustes → Modo Desarrollador (activar)
2. Ve a Apps → Actualizar lista de aplicaciones
3. Busca "MuK Backend Theme" e instálalo

## 🔧 click-odoo-contrib (Herramientas de mantenimiento)

Las herramientas de click-odoo están instaladas dentro del contenedor. Úsalas así:

```bash
# Actualizar módulos de una BD
docker exec -u 0 spl_gestion_odoo click-odoo-update -c /etc/odoo/odoo.conf -d <nombre_bd>

# Inicializar una BD nueva con módulos
docker exec -u 0 spl_gestion_odoo click-odoo-initdb -c /etc/odoo/odoo.conf -n <nombre_bd>

# Ejecutar un script Python en contexto Odoo
docker exec -u 0 spl_gestion_odoo click-odoo -c /etc/odoo/odoo.conf -d <nombre_bd> < script.py

# Shell interactivo de Odoo
docker exec -it -u 0 spl_gestion_odoo click-odoo -c /etc/odoo/odoo.conf -d <nombre_bd>
```

## 📂 Añadir addons personalizados

1. Coloca tus módulos dentro de la carpeta `custom-addons/`
2. Reinicia el contenedor: `docker compose restart odoo`
3. En Odoo → Apps → Actualizar lista de aplicaciones
4. Busca e instala tu módulo

## 📁 Datos persistentes

| Ruta local         | Descripción                              |
|--------------------|------------------------------------------|
| `./postgres-data/` | Datos de PostgreSQL (ficheros de la BD)  |
| `./odoo-data/`     | Filestore de Odoo (adjuntos, sesiones)   |
| `./custom-addons/` | Tus módulos personalizados               |

## ⚙️ Configuración

Edita `odoo.conf` para cambiar:
- Contraseñas (`db_password`, `admin_passwd`)
- Workers para producción
- Niveles de log
- Etc.

> **⚠️ IMPORTANTE**: Cambia las contraseñas por defecto antes de usar en producción.

## 🛑 Parar los contenedores

```bash
docker compose down          # Parar (mantiene datos)
docker compose down -v       # Parar y BORRAR volúmenes (¡pierdes datos!)
```
