# 🐘 Odoo 19 Community — Guía de Despliegue con Docker

Entorno contenedorizado de **Odoo 19 Community Edition** con PostgreSQL 16, tema MuK (interfaz estilo Enterprise), módulos OCA y herramientas de mantenimiento (`click-odoo-contrib`).

---

## 📋 Índice

1. [Requisitos previos](#-requisitos-previos)
2. [Estructura del proyecto](#-estructura-del-proyecto)
3. [Instalación paso a paso](#-instalación-paso-a-paso)
4. [Configuración](#-configuración)
5. [Operaciones habituales](#-operaciones-habituales)
6. [Módulos incluidos](#-módulos-incluidos)
7. [Herramientas de mantenimiento](#-herramientas-de-mantenimiento)
8. [Solución de problemas](#-solución-de-problemas)
9. [Notas de seguridad](#-notas-de-seguridad)

---

## 🔧 Requisitos previos

| Herramienta      | Versión mínima | Verificar con             |
|------------------|----------------|---------------------------|
| Docker           | 24+            | `docker --version`        |
| Docker Compose   | v2+            | `docker compose version`  |
| Git              | 2.x            | `git --version`           |

> **Nota:** Docker Desktop (Windows/Mac) ya incluye Docker Compose v2.

---

## 📁 Estructura del proyecto

```
docker-odoo-19-community/
├── docker-compose.yml       # Orquestación de servicios (Odoo + PostgreSQL)
├── Dockerfile               # Imagen personalizada de Odoo 19
├── odoo.conf                # Configuración completa de Odoo
├── odoo.conf.example        # Plantilla de configuración (referencia)
├── .env                     # Variables de entorno (NO se versiona)
├── .env.example             # Plantilla de variables de entorno
├── custom-addons/           # Tus módulos/addons personalizados
├── odoo-data/               # Filestore de Odoo (adjuntos, sesiones)
├── postgres-data/           # Datos de PostgreSQL
└── .gitignore               # Exclusiones de Git
```

### Servicios definidos en `docker-compose.yml`

| Servicio | Imagen           | Puerto | Descripción                      |
|----------|------------------|--------|----------------------------------|
| `db`     | `postgres:16`    | 5432   | Base de datos PostgreSQL         |
| `odoo`   | Build local      | 8069   | Servidor Odoo 19                 |
|          |                  | 8072   | Longpolling (websocket/live chat)|

---

## 🚀 Instalación paso a paso

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/docker-odoo-19-community.git
cd docker-odoo-19-community
```

### 2. Configurar las variables de entorno

```bash
# Copiar la plantilla
cp .env.example .env
```

Edita `.env` con tus valores:

```env
# PostgreSQL
POSTGRES_DB=postgres
POSTGRES_USER=odoo
POSTGRES_PASSWORD=tu_contraseña_segura

# Odoo
ODOO_ADMIN_PASSWD=tu_master_password_segura
```

> ⚠️ **Importante:** Nunca subas el archivo `.env` al repositorio. Ya está incluido en `.gitignore`.

### 3. Construir y levantar los contenedores

```bash
docker compose up -d --build
```

La primera vez tardará varios minutos porque:
- Descarga la imagen base de Odoo 19
- Clona los repositorios de MuK y OCA
- Instala dependencias Python

### 4. Verificar que todo está funcionando

```bash
# Estado de los contenedores
docker compose ps

# Logs en tiempo real
docker compose logs -f
```

Deberías ver algo como:
```
docker_postgres_19_community   Up (healthy)   5432/tcp
docker_odoo_19_community       Up             8069/tcp, 8072/tcp
```

### 5. Acceder a Odoo

Abre en tu navegador: **http://localhost:8069**

En el primer arranque, Odoo mostrará el formulario de creación de base de datos:

| Campo              | Valor                                  |
|--------------------|----------------------------------------|
| Master Password    | La que pusiste en `ODOO_ADMIN_PASSWD`  |
| Database Name      | El nombre que quieras (ej: `mi_empresa`) |
| Email              | Tu email de administrador              |
| Password           | Contraseña del usuario admin de Odoo   |
| Language           | Español                                |
| Country            | Tu país                                |
| Demo data          | Marcar solo para pruebas               |

---

## ⚙️ Configuración

### `odoo.conf` — Parámetros principales

El archivo `odoo.conf` contiene la configuración completa de Odoo. Los parámetros más importantes:

| Parámetro        | Valor por defecto   | Descripción                              |
|------------------|---------------------|------------------------------------------|
| `db_host`        | `db`                | Hostname del servicio PostgreSQL (nombre del servicio en Docker Compose) |
| `db_port`        | `5432`              | Puerto de PostgreSQL                     |
| `db_user`        | `odoo`              | Usuario de la base de datos              |
| `db_maxconn`     | `64`                | Conexiones máximas a la BD               |
| `http_port`      | `8069`              | Puerto del servidor HTTP                 |
| `proxy_mode`     | `True`              | Activar si usas un reverse proxy (Nginx/Traefik) |
| `log_level`      | `info`              | Nivel de logging                         |
| `data_dir`       | `/var/lib/odoo`     | Directorio del filestore                 |
| `list_db`        | `True`              | Permitir listar bases de datos           |

### Rutas de addons

El `addons_path` en `odoo.conf` incluye:

```
/mnt/extra-addons          → custom-addons/ (tus módulos)
/opt/odoo/muk-modules      → Tema MuK
/opt/odoo/oca/*            → Módulos OCA
/usr/lib/python3/dist-packages/odoo/addons → Módulos oficiales de Odoo
```

### Volúmenes montados

| Local                  | Contenedor                | Modo | Propósito                          |
|------------------------|---------------------------|------|------------------------------------|
| `./odoo-data`          | `/var/lib/odoo`           | rw   | Filestore (adjuntos, sesiones)     |
| `./custom-addons`      | `/mnt/extra-addons`       | rw   | Addons personalizados              |
| `./odoo.conf`          | `/etc/odoo/odoo.conf`     | ro   | Configuración (solo lectura)       |
| `./postgres-data`      | `/var/lib/postgresql/data/pgdata` | rw | Datos de PostgreSQL          |

---

## 🔄 Operaciones habituales

### Iniciar los servicios

```bash
docker compose up -d
```

### Parar los servicios

```bash
# Parar sin borrar datos
docker compose down

# ⚠️ Parar y BORRAR todos los volúmenes (perderás datos)
docker compose down -v
```

### Reiniciar solo Odoo (sin tocar la BD)

```bash
docker compose restart odoo
```

### Reconstruir la imagen (tras cambios en Dockerfile)

```bash
docker compose up -d --build
```

### Ver logs

```bash
# Todos los servicios
docker compose logs -f

# Solo Odoo
docker compose logs -f odoo

# Solo PostgreSQL
docker compose logs -f db

# Últimas 50 líneas
docker compose logs --tail 50 odoo
```

### Acceder al contenedor de Odoo

```bash
docker exec -it docker_odoo_19_community bash
```

### Acceder a la consola de PostgreSQL

```bash
docker exec -it docker_postgres_19_community psql -U odoo -d postgres
```

---

## 🎨 Módulos incluidos

### MuK Web Theme — Interfaz Enterprise para Community

Se clona automáticamente desde [muk-it/odoo-modules](https://github.com/muk-it/odoo-modules) (rama `19.0`).

Incluye:
- **`muk_web_theme`** — Tema backend estilo Enterprise
- **`muk_web_enterprise_theme`** — Mejoras adicionales de interfaz
- **`muk_web_chatter`** — Mejoras en el chatter
- **`muk_web_dialog`** — Mejoras en diálogos
- Y otros módulos de la suite MuK

**Para activar el tema:**
1. Entra en Odoo → **Ajustes** → **Modo Desarrollador** (activar)
2. Ve a **Apps** → **Actualizar lista de aplicaciones**
3. Busca `MuK Backend Theme` e instálalo

### Módulos OCA (Odoo Community Association)

Se clonan automáticamente desde [github.com/OCA](https://github.com/OCA) (rama `19.0`):

| Repositorio                | Descripción                                 |
|----------------------------|---------------------------------------------|
| `web`                      | Módulos web y mejoras de interfaz           |
| `server-tools`             | Herramientas del servidor                   |
| `server-ux`                | Mejoras de experiencia de usuario           |
| `reporting-engine`         | Motor de reportes avanzado                  |
| `partner-contact`          | Gestión de contactos y socios               |
| `account-financial-tools`  | Herramientas financieras y contables        |
| `queue`                    | Sistema de colas para tareas en background  |
| `social`                   | Módulos de comunicación social              |
| `stock-logistics-workflow` | Flujos de trabajo de inventario             |
| `bank-payment`             | Gestión de pagos bancarios                  |
| `server-brand`             | Personalización de marca del servidor       |

### Tus módulos personalizados

Coloca tus addons en la carpeta `custom-addons/`. Se montan automáticamente en `/mnt/extra-addons` dentro del contenedor.

Para que Odoo los detecte:
1. Reinicia Odoo: `docker compose restart odoo`
2. En Odoo → **Apps** → **Actualizar lista de aplicaciones**
3. Busca e instala tu módulo

---

## 🛠️ Herramientas de mantenimiento

### click-odoo-contrib

Instalado dentro del contenedor de Odoo. Para usarlo:

```bash
# 1. Entrar al contenedor
docker exec -it docker_odoo_19_community bash

# 2. Actualizar módulos de una base de datos
click-odoo-update -c /etc/odoo/odoo.conf -d nombre_bd

# 3. Shell interactivo de Odoo (acceso a la API)
click-odoo -c /etc/odoo/odoo.conf -d nombre_bd
```

### Backup de la base de datos

```bash
# Desde fuera del contenedor
docker exec docker_postgres_19_community pg_dump -U odoo nombre_bd > backup_$(date +%Y%m%d).sql

# Restaurar
docker exec -i docker_postgres_19_community psql -U odoo -d nombre_bd < backup.sql
```

---

## 🔥 Solución de problemas

### ❌ `could not translate host name "db" to address`

**Causa:** El contenedor de PostgreSQL no está en la misma red Docker que Odoo. Esto ocurre cuando se reinicia un contenedor individual con `docker start` en lugar de `docker compose`.

**Solución:**
```bash
docker compose down
docker compose up -d
```

> **Regla de oro:** Usa siempre `docker compose` para gestionar los servicios. Nunca uses `docker start/stop` directamente con los nombres de contenedor.

---

### ❌ `password authentication failed for user "odoo"`

**Causa:** Las credenciales en `.env` no coinciden con las almacenadas en `postgres-data/`.

**Solución:**
```bash
# Opción 1: Resetear la base de datos (⚠️ PIERDES DATOS)
docker compose down
rm -rf postgres-data/
docker compose up -d

# Opción 2: Cambiar la contraseña del usuario en PostgreSQL
docker exec -it docker_postgres_19_community psql -U postgres
ALTER USER odoo WITH PASSWORD 'nueva_contraseña';
```

---

### ❌ `database system was not ready for connections / starting up`

**Causa:** Odoo intentó conectarse antes de que PostgreSQL terminara de iniciar.

**Solución:** El `docker-compose.yml` ya incluye un `healthcheck` que previene esto. Si sigue ocurriendo:
```bash
docker compose restart odoo
```

---

### ❌ `invalid addons directory '/mnt/extra-addons', skipped`

**Causa:** La carpeta `custom-addons/` está vacía. Es un warning inofensivo — Odoo simplemente ignora el directorio.

**Solución:** No se requiere acción. El warning desaparece cuando añadas tu primer módulo personalizado a `custom-addons/`.

---

### ❌ Odoo no detecta mi módulo personalizado

1. Verifica que el módulo tiene un archivo `__manifest__.py` válido
2. Reinicia Odoo: `docker compose restart odoo`
3. En Odoo → Ajustes → Modo Desarrollador (activar)
4. Apps → Actualizar lista de aplicaciones
5. Busca tu módulo por nombre técnico

---

## 🔒 Notas de seguridad

- El archivo `.env` contiene contraseñas y **no se versiona** (está en `.gitignore`)
- Usa `.env.example` como plantilla de referencia
- En producción:
  - Desactiva `list_db = False` en `odoo.conf` para ocultar el listado de BDs
  - Configura un `admin_passwd` robusto
  - Usa un reverse proxy (Nginx/Traefik) con HTTPS
  - Configura workers para mejor rendimiento: `workers = (nº CPUs × 2) + 1`
  - Cambia `proxy_mode = True` solo si usas un reverse proxy
  - Restringe el puerto `5432` de PostgreSQL (elimina la sección `ports` del servicio `db`)

---

## 📜 Licencia

Odoo Community Edition está licenciado bajo [LGPL-3.0](https://www.gnu.org/licenses/lgpl-3.0.html).
