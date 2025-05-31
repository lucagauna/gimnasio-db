CREATE DATABASE GimnasioBd;

GO

USE GimnasioBd;
GO

-- Tabla: Roles
CREATE TABLE roles (
	id_rol int PRIMARY KEY,
	nombre_rol varchar(50) NOT NULL CHECK (nombre_rol IN ('owner','empleado','cliente'))

);
-- Tabla: Usuarios
CREATE TABLE usuarios (
	id_usuario int IDENTITY(1,1) PRIMARY KEY,
	dni VARCHAR(20) UNIQUE NOT NULL,
	contraseña CHAR(64) NOT NULL,
	rol_id int not null,
	FOREIGN KEY (rol_id) REFERENCES roles (id_rol)

);
-- Tabla: clientes
CREATE TABLE clientes (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    usuario_id INT  NOT NULL,
    dni VARCHAR(20) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    edad INT,
    direccion VARCHAR(255),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id_usuario)
);

-- Tabla: tipo_cuota
CREATE TABLE tipo_cuota (
    id_tipo_cuota INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL,
    monto_total MONEY NOT NULL
);

-- Tabla: cuotas
CREATE TABLE cuotas (
    id_cuota INT IDENTITY(1,1) PRIMARY KEY,
    id_tipo_cuota INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    estado BIT NOT NULL,
    cliente_id INT NOT NULL,
    FOREIGN KEY (id_tipo_cuota) REFERENCES tipo_cuota(id_tipo_cuota),
    FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente)
);

-- Tabla: pagos
CREATE TABLE pagos (
    id_pago INT IDENTITY(1,1) PRIMARY KEY,
    fecha_pago DATE NOT NULL,
    monto_pagado MONEY NOT NULL,
    medio_pago VARCHAR(50),
    cuota_id INT NOT NULL,
    FOREIGN KEY (cuota_id) REFERENCES cuotas(id_cuota)
);

-- Tabla: asistencias_clientes
CREATE TABLE asistencias_clientes (
    id_asistencia INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    cliente_id INT NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente)
);

-- Tabla: cargos
CREATE TABLE cargos (
    id_cargo INT IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL,
    renumeracion MONEY NOT NULL
);

-- Tabla: empleados
CREATE TABLE empleados (
    id_empleado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    dni VARCHAR(20) NOT NULL,
    fecha_de_inicio DATE NOT NULL,
    estado BIT NOT NULL,
    id_cargo INT NOT NULL,
    FOREIGN KEY (id_cargo) REFERENCES cargos(id_cargo)
);

-- Tabla: asistencias_empleados
CREATE TABLE asistencias_empleados (
    id_asistencia INT IDENTITY(1,1) PRIMARY KEY,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    empleado_id INT NOT NULL,
    FOREIGN KEY (empleado_id) REFERENCES empleados(id_empleado)
);
GO

