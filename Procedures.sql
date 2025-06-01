USE GimnasioBd

GO

CREATE OR ALTER PROCEDURE sp_AgregarUsuario(@dni VARCHAR(20), @contraseña CHAR(64), @rol_nombre varchar(8)) AS 
	BEGIN
		DECLARE @id_rol INT
		SET @id_rol = (SELECT id_rol FROM roles WHERE nombre_rol = @rol_nombre)
		INSERT INTO usuarios (dni, contraseña, rol_id)
			VALUES (@dni, @contraseña, @id_rol)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarCliente(@dni VARCHAR(20), @nombre VARCHAR(100), @apellido VARCHAR(100), @edad INT, @direccion VARCHAR(255)) AS
	BEGIN
		DECLARE @usuario_id INT
		SET @usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = @dni)
		INSERT INTO clientes (usuario_id, dni, nombre, apellido, edad, direccion)
			VALUES (@usuario_id, @dni, @nombre, @apellido, @edad, @direccion)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarEmpleado(@nombre VARCHAR(100), @apellido VARCHAR(100), @dni VARCHAR(20), @nombre_cargo VARCHAR(25)) AS
	BEGIN
		DECLARE @usuario_id INT
		SET @usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = @dni)
		DECLARE @id_cargo INT
		SET @id_cargo = (SELECT id_cargo FROM cargos WHERE descripcion = @nombre_cargo)
		INSERT INTO empleados(usuario_id, nombre, apellido, dni, fecha_de_inicio, estado, id_cargo)
			VALUES (@usuario_id, @nombre, @apellido, @dni, GETDATE(), 1, @id_cargo)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarTipoCuota (@descripcion VARCHAR(100), @monto_total MONEY) AS
	BEGIN
		INSERT INTO tipo_cuota (descripcion, monto_total)
			VALUES (@descripcion, @monto_total)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarCuotas(@nombre_cuota VARCHAR(100), @dni VARCHAR(20)) AS
	BEGIN
		DECLARE @id_tipo_cuota INT
		SET @id_tipo_cuota = (SELECT id_tipo_cuota FROM tipo_cuota WHERE descripcion = @nombre_cuota)
		DECLARE @cliente_id INT
		SET @cliente_id = (SELECT id_cliente FROM clientes WHERE dni = @dni)
		INSERT INTO cuotas(id_tipo_cuota, fecha_inicio, fecha_vencimiento, estado, cliente_id)
			VALUES (@id_tipo_cuota, GETDATE(), DATEADD(MONTH, 1, GETDATE()), 1, @cliente_id)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarPagos(@monto_pagado MONEY, @medio_pago VARCHAR(50)) AS
	BEGIN
		DECLARE @cuota_id int
		SET @cuota_id = 
	END