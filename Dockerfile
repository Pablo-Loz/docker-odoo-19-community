FROM odoo:19.0

USER root

# Instalar dependencias del sistema necesarias para compilar paquetes Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Instalar click-odoo-contrib (incluye click-odoo-update y demás herramientas)
RUN pip3 install --no-cache-dir --break-system-packages click-odoo-contrib

# Clonar el tema MuK (interfaz estilo Enterprise para Community)
RUN git clone --depth 1 --branch 19.0 \
    https://github.com/muk-it/odoo-modules.git /opt/odoo/muk-modules

# =========================================
# Clonar repositorios OCA (rama 19.0)
# =========================================
RUN git clone --depth 1 --branch 19.0 https://github.com/OCA/web.git /opt/odoo/oca/web \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/server-tools.git /opt/odoo/oca/server-tools \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/server-ux.git /opt/odoo/oca/server-ux \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/reporting-engine.git /opt/odoo/oca/reporting-engine \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/partner-contact.git /opt/odoo/oca/partner-contact \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/account-financial-tools.git /opt/odoo/oca/account-financial-tools \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/queue.git /opt/odoo/oca/queue \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/social.git /opt/odoo/oca/social \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/stock-logistics-workflow.git /opt/odoo/oca/stock-logistics-workflow \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/bank-payment.git /opt/odoo/oca/bank-payment \
    && git clone --depth 1 --branch 19.0 https://github.com/OCA/server-brand.git /opt/odoo/oca/server-brand

# Instalar dependencias Python de los módulos OCA (si tienen requirements.txt)
RUN find /opt/odoo/oca -name 'requirements.txt' -exec pip3 install --no-cache-dir --break-system-packages -r {} \; 2>/dev/null || true

# Copiar la configuración personalizada de Odoo
COPY ./odoo.conf /etc/odoo/odoo.conf

# Crear directorio para addons propios y asegurar permisos
RUN mkdir -p /mnt/extra-addons \
    && chown -R odoo:odoo /mnt/extra-addons \
    && chown -R odoo:odoo /opt/odoo/muk-modules \
    && chown -R odoo:odoo /opt/odoo/oca

USER odoo
