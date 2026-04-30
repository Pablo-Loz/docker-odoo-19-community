# Odoo 19 Community (Docker)

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

## 🎨 OCA Modules

El repo [OCA](https://github.com/OCA) se clona automáticamente dentro de la imagen. Incluye:

- **`server-tools`** - Herramientas del servidor
- **`web`** - Módulos web
- **`server-ux`** - Experiencia de usuario del servidor
- **`reporting-engine`** - Motor de reportes
- **`partner-contact`** - Módulos de contacto y socios
- **`account-financial-tools`** - Herramientas financieras
- **`queue`** - Módulos de cola
- **`social`** - Módulos sociales
- **`stock-logistics-workflow`** - Flujos de trabajo de inventario
- **`bank-payment`** - Módulos de pago bancario
- **`server-brand`** - Módulos de marca
- Y muchos más módulos útiles


**Para activar el tema:**
1. Entra en Odoo → Ajustes → Modo Desarrollador (activar)
2. Ve a Apps → Actualizar lista de aplicaciones
3. Busca "MuK Backend Theme" e instálalo

## 🔧 click-odoo-contrib (Herramientas de mantenimiento)

Las herramientas de click-odoo están instaladas dentro del contenedor.
# Shell interactivo de Odoo
```bash

docker exec -it -u odoo  nombre_contenedor bash 
```

```docker
click-odoo-update -c /etc/odoo/odoo.conf -d <nombre_bd>
```

## 🛑 Parar los contenedores

```bash
docker compose down -v       # Parar y BORRAR volúmenes
```
