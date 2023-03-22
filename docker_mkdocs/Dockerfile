FROM python:3.12.0a6-alpine3.17

# Build-time flags
ARG WITH_PLUGINS=true

# Copy files necessary installation
COPY requirements.txt requirements.txt
COPY requirements-plugins.txt requirements-plugins.txt

# Needed for native module builds
RUN apk add build-base

# Perform mkdocs-material installation
RUN pip install --no-cache-dir -r requirements.txt \
  && \
    if [ "${WITH_PLUGINS}" = "true" ]; then \
      pip install --no-cache-dir -r requirements-plugins.txt; \
    fi

# Packages qui seront conservés
RUN set -eux \
 && apk add --no-cache \
      # For update dates
      git \
      # For PDF-EXPORT-PLUGIN
      libffi cairo pango gdk-pixbuf libstdc++ openjpeg

# Liste des dépendances / packages
COPY requirements-plugins.txt .

# Installation des composants Python (packages de dev seront retirés)
RUN set -eux \
 && apk add --no-cache --virtual .build-deps \
      tar \
      gzip \
      make \
      gcc g++ \
      libc-dev \
      musl-dev openjpeg-dev jpeg-dev zlib-dev libffi-dev cairo-dev pango-dev gdk-pixbuf-dev \
 && python -m pip install --upgrade pip \
 && python -m pip install -r requirements-plugins.txt \
 && apk del --no-cache .build-deps

# Pour le plugin date 
RUN git config --global --add safe.directory /docs


# Import Fonts (for PDF generator)

# COPY fonts/static /usr/share/fonts/Additional
RUN apk --update --upgrade --no-cache add fontconfig ttf-dejavu \ 
 && fc-cache -f \ 
 && fc-list | sort 


# Set working directory
WORKDIR /docs

# Expose MkDocs development server port
EXPOSE 8000

# Configuration pour versionning

# ENTRYPOINT ["mike"]
# CMD ["serve", "--dev-addr=0.0.0.0:8000", "--ignore"]

# Configuration globale en mode developpement

ENTRYPOINT [ "mkdocs" ]
CMD [ "serve", "--dev-addr=0.0.0.0:8000"]

