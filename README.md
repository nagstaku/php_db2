In addition to installing the db2 extension through PECL, you will need development header files and libraries downloaded on the system before running `pecl install`. 

Here is a shell script that creates a Dockerfile, docker-compose.yml, and index.php example:
```
#! /bin/sh

cat << 'EOF' > docker-compose.yml
version: '3'
services:
  odb-web:
    build: .
    ports:
      - 3030:80
    volumes:
      - ./html:/var/www/html
  mydb2:
    image: ibmcom/db2
    ports:
      - 50000:50000
    volumes:
      - ./data:/database
    environment:
      LICENSE: accept
      DB2INST1_PASSWORD: ChangeMe!
      DBNAME: testdb
    privileged: true
EOF
cat << 'EOF' > Dockerfile
FROM php:7.3-apache

# To build the ibm_db2 extension, the DB2 application development header files and libraries must be installed on your system. 
# DB2 does not install these by default, so you may have to return to your DB2 installer and add this option. 
# The header files are included with the DB2 Application Development Client freely available for download from 
# the IBM DB2 Universal Database » support site: https://www.ibm.com/developerworks/downloads/im/db2express/index.html

# https://github.com/php/pecl-database-ibm_db2
# Download linuxx64_odbc_cli.tar.gz from https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/

## add header files and libraries
RUN mkdir -p /opt/ibm/ && curl https://public.dhe.ibm.com/ibmdl/export/pub/software/data/db2/drivers/odbc_cli/linuxx64_odbc_cli.tar.gz | tar -xz -C /opt/ibm/
# if you prefer to keep the file locally, download it and use:
# ADD odbc_cli/linuxx64_odbc_cli.tar.gz /opt/ibm/

## set env vars needed for PECL install
ENV IBM_DB_HOME=/opt/ibm/clidriver
ENV LD_LIBRARY_PATH=/opt/ibm/clidriver/lib

## install ibm_db2 drivers
RUN pecl install ibm_db2
RUN echo "extension=ibm_db2.so" > /usr/local/etc/php/conf.d/ibm_db2.ini
EOF
mkdir html && cat << 'EOF' > html/index.php
<?php
$database = 'testdb';
$user = 'db2inst1';
$password = 'ChangeMe!';
$hostname = 'host.docker.internal';
$port = 50000;

$conn_string = "DRIVER={IBM DB2 ODBC DRIVER};DATABASE=$database;" .
  "HOSTNAME=$hostname;PORT=$port;PROTOCOL=TCPIP;UID=$user;PWD=$password;";
$conn = db2_connect($conn_string, '', '');

if ($conn) {
    echo "Connection succeeded.\n";
    db2_close($conn);
}
else {
    echo "Connection failed.\n";
}
?>
EOF

```

upon running this script (or if on windows, copy pasting the file contents manually), 
you will have 3 files, and can run `docker-compose up -d` to bring up a working php 
project that will connect to an ibm db2 container.

Browsing to http://localhost:3030 you should see "Connection succeeded".

You can modify the html/index.php file as desired and refresh the page to test things out.