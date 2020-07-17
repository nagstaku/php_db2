FROM php:7.3-apache

# To build the ibm_db2 extension, the DB2 application development header files and libraries must be installed on your system. 
# DB2 does not install these by default, so you may have to return to your DB2 installer and add this option. 
# The header files are included with the DB2 Application Development Client freely available for download from 
# the IBM DB2 Universal Database » support site: https://www.ibm.com/developerworks/downloads/im/db2express/index.html

# https://github.com/php/pecl-database-ibm_db2
# Download linuxx64_odbc_cli.tar.gz from https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/

## add header files and libraries
# RUN mkdir -p /opt/ibm/ && curl https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/linuxx64_odbc_cli.tar.gz | tar -xz -C /opt/ibm/
# if you prefer to keep the file locally:
ADD linuxx64_odbc_cli.tar.gz /opt/ibm/

## set env vars needed for PECL install
ENV IBM_DB_HOME=/opt/ibm/clidriver
ENV LD_LIBRARY_PATH=/opt/ibm/clidriver/lib

## install ibm_db2 drivers
RUN pecl install ibm_db2
RUN echo "extension=ibm_db2.so" > /usr/local/etc/php/conf.d/ibm_db2.ini
