#!/bin/bash

# Aprovisionamiento para server2

# Agregar repositorio de Hashi Corp
echo "Agregando repositorio de Hashi Corp..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Actualizar los paquetes
echo "Actualizando paquetes..."
apt update

# Instalación de Consul
echo "Instalando Consul..."
apt install consul -y

# Verificación de instalación de Consul
echo "Verificación de instalación de Consul..."
consul -v

# Instalar Node.js desde los repositorios de Ubuntu
echo "Instalando Node.js..."
sudo apt-get install -y nodejs

# Verificar la instalación de Node.js
echo "Verificando la instalación de Node.js..."
node -v

# Instalar npm (Node Package Manager)
echo "Instalando npm..."
sudo apt-get install -y npm

# Verificar la instalación de npm
echo "Verificando la instalación de npm..."
npm -v

# Instalar herramientas adicionales (opcional)
echo "Instalando herramientas adicionales..."
sudo apt-get install -y build-essential


echo "Iniciando agente de Consul..."
nohup consul agent -ui -node=node-two -bind=192.168.100.4 -client=0.0.0.0 -data-dir=. -enable-script-checks=true -retry-join=192.168.100.3 &
sleep 5
 
# Creación de archivo index.js
echo "Creando archivo index.js..."
mkdir app
touch app/index.js

# Escribir archivo index.js
echo "Escribiendo archivo index.js..."
sudo tee app/index.js << EOF
const Consul = require('consul');
const express = require('express');

const SERVICE_NAME = 'mymicroservice';
const SERVICE_ID = 'm' + process.argv[2];
const SCHEME = 'http';
const HOST = '192.168.100.4';
const PORT = process.argv[2] * 1;
const PID = process.pid;

/* Inicializacion del server */
const app = express();
const consul = new Consul();

app.get('/health', function (req, res) {
  console.log('Health check!');
  res.end("Ok.");
});

app.get('/', (req, res) => {
  console.log('GET /', Date.now());
  res.json({
    data: Math.floor(Math.random() * 89999999 + 10000000),
    data_pid: PID,
    data_service: SERVICE_ID,
    data_host: HOST
  });
});

app.listen(PORT, function () {
  console.log('Servicio iniciado en:' + SCHEME + '://' + HOST + ':' + PORT + '!');
});

/* Registro del servicio */
var check = {
  id: SERVICE_ID,
  name: SERVICE_NAME,
  address: HOST,
  port: PORT,
  check: {
    http: SCHEME + '://' + HOST + ':' + PORT + '/health',
    ttl: '5s',
    interval: '5s',
    timeout: '5s',
    deregistercriticalserviceafter: '1m'
  }
};

consul.agent.service.register(check, function (err) {
  if (err) throw err;
});
EOF

# Instalación de paquetes
echo "Instalación de paquetes para index.js..."
(cd app && npm i express consul)

# Creación de carpetas de logs
echo "Creación de carpetas de logs..."
mkdir logs

# Inicialización de múltiples servicios
echo "Inicialización de múltiples servicios..."
nohup node app/index.js 3003 &>logs/service1.log &
nohup node app/index.js 3004 &>logs/service2.log &
nohup node app/index.js 3005 &>logs/service3.log &
