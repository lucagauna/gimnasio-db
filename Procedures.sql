USE Bd_Gym

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

CREATE OR ALTER PROCEDURE sp_AgregarPagos(@monto_pagado MONEY, @medio_pago VARCHAR(50), @dni VARCHAR(20)) AS
	BEGIN
		DECLARE @cliente_id int
		SET @cliente_id = (SELECT id_cliente FROM clientes WHERE dni = @dni)
		DECLARE @cuota_id int
		SET @cuota_id = (SELECT id_cuota FROM cuotas WHERE estado = 1 AND cliente_id = @cliente_id)
		DECLARE @pagado BIT
		DECLARE @debe MONEY
		IF(@monto_pagado = (SELECT monto_total FROM tipo_cuota WHERE id_tipo_cuota = (SELECT id_tipo_cuota FROM cuotas WHERE cliente_id = @cliente_id AND estado = 1))) BEGIN
			SET @pagado = 1
			SET @debe = 0
		END ELSE BEGIN
			SET @pagado = 0
			SET @debe = (SELECT monto_total FROM tipo_cuota WHERE id_tipo_cuota = (SELECT id_tipo_cuota FROM cuotas WHERE cliente_id = @cliente_id AND estado = 1)) - @monto_pagado
		END
		INSERT INTO pagos (fecha_pago, monto_pagado, medio_pago, cuota_id, pagado, cliente_id, debe)
			VALUES (GETDATE(), @monto_pagado, @medio_pago, @cuota_id, @pagado, @cliente_id, @debe)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarRoles (@nombre_rol VARCHAR(50)) AS
	BEGIN
		INSERT INTO roles (nombre_rol)
			VALUES (@nombre_rol)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarCargos (@descripcion VARCHAR(100), @remuneracion MONEY) AS
	BEGIN
		INSERT INTO cargos (descripcion, remuneracion)
			VALUES (@descripcion, @remuneracion)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarAsistenciaCliente (@dni VARCHAR(20)) AS
	BEGIN
		DECLARE @cliente_id int
		IF EXISTS (SELECT 1 FROM cuotas WHERE cliente_id = (SELECT id_cliente FROM clientes WHERE dni = @dni) AND estado = 1) 
		BEGIN
			SET @cliente_id = (SELECT id_cliente FROM clientes WHERE dni = @dni)
			INSERT INTO asistencias_clientes (fecha, hora, cliente_id)
				VALUES (GETDATE(), CAST(GETDATE() AS TIME), @cliente_id)
		END ELSE 
		BEGIN
			PRINT('Cliente no pago cuota.')
		END
	END

GO

-- Estaria bueno validar esto siempre al inicio del programa...
CREATE OR ALTER PROCEDURE sp_ValidarCuotas AS
	BEGIN
		UPDATE cuotas SET estado = 0 WHERE fecha_vencimiento <= GETDATE()
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarAsistenciasEmpleados (@dni VARCHAR(20)) AS
	BEGIN
		DECLARE @empleado_id INT
		IF EXISTS (SELECT 1 FROM empleados WHERE estado = 1 AND dni = @dni)
		BEGIN
			SET @empleado_id = (SELECT id_empleado FROM empleados WHERE @dni = dni)
			INSERT INTO asistencias_empleados (fecha, hora, empleado_id)
				VALUES (GETDATE(), CAST(GETDATE() AS TIME), @empleado_id)
		END ELSE
		BEGIN
			PRINT(@dni + ' No es un empleado...')
		END
	END