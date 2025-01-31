#!/bin/bash
# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.
# --------------------------------------------------------------------------------------------

set -ex

# libpq-dev is for PostgreSQL
apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        libexpat1 \
        curl \
        gnupg \
        libpq-dev \
        default-libmysqlclient-dev \
        unzip \
        libodbc1 \
        apt-transport-https \
        swig \
        # GIS libraries for GeoDjango (https://docs.djangoproject.com/en/3.2/ref/contrib/gis/install/geolibs/)
        binutils \
        libproj-dev \
        gdal-bin \
        libgdal-dev \
        python3-gdal \
    && rm -rf /var/lib/apt/lists/*
 
# Microsoft SQL Server 2017
# https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server
export ACCEPT_EULA=Y \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

if [ "${DEBIAN_FLAVOR}" != "bullseye" ]; then \
    curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list
elif [ "${DEBIAN_FLAVOR}" != "buster" ]; then \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list
elif [ "${DEBIAN_FLAVOR}" != "stretch" ]; then \
    curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list
fi

exit
apt-get update \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql18 \
    && ACCEPT_EULA=Y apt-get install -y mssql-tools18 \
    && echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc \
    && source ~/.bashrc \
    && apt-get install -y --no-install-recommends \
        unixodbc-dev \
        libgssapi-krb5-2

mkdir -p /etc/unixODBC
cat >/etc/unixODBC/odbcinst.ini <<EOL
[ODBC Driver 17 for SQL Server]
Description=Microsoft ODBC Driver 17 for SQL Server
Driver=/opt/microsoft/msodbcsql17/lib64/libmsodbcsql-17.2.so.0.1
Threading=1
UsageCount=1
EOL

# Clean up for apt. Keeping at the very end to make sure it runs after every apt-get install.
rm -rf /var/lib/apt/lists/*