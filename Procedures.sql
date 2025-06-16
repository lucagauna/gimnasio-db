USE GimnasioBd;

GO

CREATE PROCEDURE sp_AgregarUsuario(@dni VARCHAR(20), @contraseña CHAR(64), @rol_nombre varchar(8)) AS 
	BEGIN
		DECLARE @id_rol INT
		SET @id_rol = (SELECT id_rol FROM roles WHERE nombre_rol = @rol_nombre)
		INSERT INTO usuarios (dni, contraseña, rol_id, estado)
			VALUES (@dni, @contraseña, @id_rol, 1)
	END

GO

CREATE OR ALTER PROCEDURE sp_ActivarUsuario (@dni VARCHAR(20)) AS
	BEGIN
		IF EXISTS(SELECT 1 FROM usuarios WHERE dni = @dni AND estado = 0)
		BEGIN
			UPDATE usuarios SET estado = 1
				WHERE dni = @dni
			RETURN
		END ELSE IF EXISTS (SELECT 1 FROM usuarios WHERE dni = @dni AND estado = 1)
		BEGIN
			RAISERROR('El usuario ya se encuentra activo...', 16, 1)
			RETURN
		END
		RAISERROR('El usuario no existe...', 16, 1)
	END

GO

CREATE PROCEDURE sp_AgregarCliente(@dni VARCHAR(20), @nombre VARCHAR(100), @apellido VARCHAR(100), @fecha_nacimiento DATE, @direccion VARCHAR(255)) AS
	BEGIN
		DECLARE @usuario_id INT
		SET @usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = @dni)
		DECLARE @edad INT
		SET @edad = DATEDIFF(YEAR,@fecha_nacimiento, GETDATE())
		INSERT INTO clientes (usuario_id, nombre, apellido, fecha_nacimiento, edad, direccion)
			VALUES (@usuario_id, @nombre, @apellido, @fecha_nacimiento, @edad, @direccion)
	END

GO



CREATE PROCEDURE sp_AgregarEmpleado(@nombre VARCHAR(100), @apellido VARCHAR(100), @dni VARCHAR(20), @nombre_cargo VARCHAR(25)) AS
	BEGIN
		DECLARE @usuario_id INT
		SET @usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = @dni)
		DECLARE @id_cargo INT
		SET @id_cargo = (SELECT id_cargo FROM cargos WHERE descripcion = @nombre_cargo)
		INSERT INTO empleados(usuario_id, nombre, apellido,  fecha_de_inicio,  id_cargo)
			VALUES (@usuario_id, @nombre, @apellido, GETDATE(), @id_cargo)
	END

GO

CREATE PROCEDURE sp_AgregarTipoCuota (@descripcion VARCHAR(100), @monto_total MONEY, @duracion INT) AS
	BEGIN
		INSERT INTO tipo_cuota (descripcion, monto_total, duracion)
			VALUES (@descripcion, @monto_total, @duracion)
	END

GO

CREATE PROCEDURE sp_AgregarCuotas(@nombre_cuota VARCHAR(100), @dni VARCHAR(20)) AS
	BEGIN
		DECLARE @id_tipo_cuota INT
		SET @id_tipo_cuota = (SELECT id_tipo_cuota FROM tipo_cuota WHERE descripcion = @nombre_cuota)
		DECLARE @cliente_id INT
		SET @cliente_id = (SELECT id_cliente FROM clientes WHERE usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = @dni))
		DECLARE @fecha_vencimiento DATE
		SET @fecha_vencimiento = DATEADD(DAY, (SELECT duracion FROM tipo_cuota WHERE id_tipo_cuota = @id_tipo_cuota), GETDATE())
		INSERT INTO cuotas(id_tipo_cuota, fecha_inicio, fecha_vencimiento, estado, cliente_id)
			VALUES (@id_tipo_cuota, GETDATE(), @fecha_vencimiento, 0, @cliente_id)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarPagos(@monto_pagado MONEY, @medio_pago VARCHAR(50), @dni VARCHAR(20), @nombre_cuota VARCHAR(100)) AS
	BEGIN
		DECLARE @cliente_id int
		SET @cliente_id = (SELECT id_cliente FROM clientes WHERE usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = @dni))
		DECLARE @cuota_id int
		SET @cuota_id = (SELECT id_cuota FROM cuotas WHERE cliente_id = @cliente_id AND id_tipo_cuota = (SELECT id_tipo_cuota FROM tipo_cuota WHERE descripcion = @nombre_cuota))
		DECLARE @pagado BIT
		DECLARE @debe MONEY
		SET @debe = (SELECT monto_total FROM tipo_cuota WHERE descripcion = @nombre_cuota) - @monto_pagado
		IF EXISTS(SELECT 1 FROM pagos WHERE cuota_id = @cuota_id AND pagado = 0)
		BEGIN
			SET @debe = (SELECT TOP 1 debe FROM pagos WHERE cuota_id = @cuota_id ORDER BY fecha_pago DESC) - @monto_pagado
		END 
		IF(@debe = 0) 
		BEGIN
			SET @pagado = 1
		END ELSE
		BEGIN
			SET @pagado = 0
		END
		INSERT INTO pagos (fecha_pago, monto_pagado, medio_pago, cuota_id, pagado, cliente_id, debe)
			VALUES (GETDATE(), @monto_pagado, @medio_pago, @cuota_id, @pagado, @cliente_id, @debe)
	END

GO

CREATE PROCEDURE sp_AgregarRoles (@nombre_rol VARCHAR(50)) AS
	BEGIN
		INSERT INTO roles (nombre_rol)
			VALUES (@nombre_rol)
	END

GO

CREATE PROCEDURE sp_AgregarCargos (@descripcion VARCHAR(100), @remuneracion MONEY) AS
	BEGIN
		INSERT INTO cargos (descripcion, remuneracion)
			VALUES (@descripcion, @remuneracion)
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarAsistenciaCliente (@dni VARCHAR(20)) AS
	BEGIN
		DECLARE @cliente_id int
		IF EXISTS (SELECT 1 FROM cuotas WHERE cliente_id = (SELECT id_cliente FROM clientes WHERE usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = '46286380')) AND estado = 1) 
		BEGIN
			SET @cliente_id = (SELECT id_cliente FROM clientes WHERE usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = @dni))
			INSERT INTO asistencias_clientes (fecha, hora, cliente_id)
				VALUES (GETDATE(), CAST(GETDATE() AS TIME), @cliente_id)
		END ELSE IF (@dni NOT IN (SELECT dni FROM usuarios WHERE id_usuario IN (SELECT usuario_id FROM clientes)))
		BEGIN
			PRINT('Cliente inexistente.')
		END ELSE
		BEGIN
			PRINT('Cliente no pago cuota.') 
		END
	END

GO



-- Estaria bueno validar esto siempre al inicio del programa...
CREATE PROCEDURE sp_ValidarCuotas AS
	BEGIN
		UPDATE cuotas SET estado = 0 WHERE fecha_vencimiento <= GETDATE()
	END

GO

CREATE OR ALTER PROCEDURE sp_AgregarAsistenciasEmpleados (@dni VARCHAR(20)) AS
	BEGIN
		DECLARE @empleado_id INT
		DECLARE @estado INT
		DECLARE @usuario_id INT
			SELECT @usuario_id = id_usuario, @estado = estado FROM usuarios WHERE dni = @dni
				IF @usuario_id IS NULL
					BEGIN 
						RAISERROR('El DNI no existe en la tabla de usuarios',16,1)
						RETURN
						END
					
				IF @estado <> 1 
					BEGIN 
						RAISERROR('El usuario no esta activo.',16,1)
						RETURN
						END

				SELECT @empleado_id = id_empleado FROM empleados WHERE usuario_id = @usuario_id
					
				IF @empleado_id IS NULL
					BEGIN
						RAISERROR('El usuario no esta como empleado',16, 1)
							RETURN
							END
				
				INSERT INTO asistencias_empleados (fecha,hora,empleado_id)
				VALUES (GETDATE(), CAST(GETDATE()AS TIME), @empleado_id)
				END
							

GO



EXEC sp_AgregarAsistenciasEmpleados '28042125'
SELECT * FROM asistencias_empleados ORDER BY fecha DESC
SELECT id_usuario, estado FROM usuarios WHERE dni = '45905927'

go

CREATE or ALTER PROCEDURE sp_ReporteParametrizadoCliente

    @nombre NVARCHAR(50) = NULL,
    @apellido NVARCHAR(50) = NULL,
    @edad INT = NULL,
    @edad_min INT = NULL,
    @edad_max INT = NULL,
    @direccion NVARCHAR(100) = NULL,
    @fecha_nacimiento DATE = NULL,
    @tiene_cuota_activa BIT = NULL  
AS
BEGIN
    SELECT c.*
    FROM clientes c
    WHERE (@nombre IS NULL OR c.nombre LIKE '%' + @nombre + '%')
      AND (@apellido IS NULL OR c.apellido LIKE '%' + @apellido + '%')
      AND (@edad IS NULL OR c.edad = @edad)
      AND (@edad_min IS NULL OR c.edad >= @edad_min)
      AND (@edad_max IS NULL OR c.edad <= @edad_max)
      AND (@direccion IS NULL OR c.direccion LIKE '%' + @direccion + '%')
      AND (@fecha_nacimiento IS NULL OR c.fecha_nacimiento = @fecha_nacimiento)
      AND (
          @tiene_cuota_activa IS NULL
          OR @tiene_cuota_activa = 
             (SELECT CASE WHEN EXISTS (
                 SELECT 1 
                 FROM cuotas cu 
                 WHERE cu.cliente_id = c.id_cliente AND cu.estado = 1
             ) THEN 1 ELSE 0 END)
      )
END

go

--probar