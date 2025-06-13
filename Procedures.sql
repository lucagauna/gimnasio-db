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

CREATE PROCEDURE sp_AgregarCliente(@dni VARCHAR(20), @nombre VARCHAR(100), @apellido VARCHAR(100), @fecha_nacimiento DATE, @direccion VARCHAR(255)) AS
	BEGIN
		DECLARE @usuario_id INT
		SET @usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = @dni)
		DECLARE @edad INT
		SET @edad = DATEDIFF(YEAR,@fecha_nacimiento, GETDATE())
		INSERT INTO clientes (usuario_id, dni, nombre, apellido, fecha_nacimiento, edad, direccion)
			VALUES (@usuario_id, @dni, @nombre, @apellido, @fecha_nacimiento, @edad, @direccion)
	END

GO

CREATE PROCEDURE sp_AgregarEmpleado(@nombre VARCHAR(100), @apellido VARCHAR(100), @dni VARCHAR(20), @nombre_cargo VARCHAR(25)) AS
	BEGIN
		DECLARE @usuario_id INT
		SET @usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = @dni)
		DECLARE @id_cargo INT
		SET @id_cargo = (SELECT id_cargo FROM cargos WHERE descripcion = @nombre_cargo)
		INSERT INTO empleados(usuario_id, nombre, apellido, dni, fecha_de_inicio,  id_cargo)
			VALUES (@usuario_id, @nombre, @apellido, @dni, GETDATE(), @id_cargo)
	END

GO

CREATE PROCEDURE sp_AgregarTipoCuota (@descripcion VARCHAR(100), @monto_total MONEY) AS
	BEGIN
		INSERT INTO tipo_cuota (descripcion, monto_total)
			VALUES (@descripcion, @monto_total)
	END

GO

CREATE PROCEDURE sp_AgregarCuotas(@nombre_cuota VARCHAR(100), @dni VARCHAR(20)) AS
	BEGIN
		DECLARE @id_tipo_cuota INT
		SET @id_tipo_cuota = (SELECT id_tipo_cuota FROM tipo_cuota WHERE descripcion = @nombre_cuota)
		DECLARE @cliente_id INT
		SET @cliente_id = (SELECT id_cliente FROM clientes WHERE dni = @dni)
		INSERT INTO cuotas(id_tipo_cuota, fecha_inicio, fecha_vencimiento, estado, cliente_id)
			VALUES (@id_tipo_cuota, GETDATE(), DATEADD(MONTH, 1, GETDATE()), 0, @cliente_id)
			---LAS CUOTAS PUEDEN DURAR 1 MES, 1 DIA, 1 SEMANA, ETC. VERIFICAR ESTO. COMO PUEDO SABER SI TENGO QUE AGREGAR UN MES, DIA O SEMANA?
	END

GO

CREATE PROCEDURE sp_AgregarPagos(@monto_pagado MONEY, @medio_pago VARCHAR(50), @dni VARCHAR(20), @nombre_cuota VARCHAR(100)) AS
	BEGIN
	-- IMAGINATE QUE SE AGREGA UN PAGO DE ALGUIEN QUE DEBIA PLATA. COMO LO HAGO? DEBERIA DE AGREGAR UN IF QUE VALIDE SI YA PAGO LA CUOTA Y QUEDO DEBIENDO... ENTONCES SE TENDRIA QUE HACER UN UPDATE Y QUEDAR PAGADO EN 1 Y DEBE EN 0
		DECLARE @cliente_id int
		SET @cliente_id = (SELECT id_cliente FROM clientes WHERE dni = @dni)
		DECLARE @cuota_id int
		SET @cuota_id = (SELECT id_cuota FROM cuotas WHERE id_tipo_cuota = (SELECT id_tipo_cuota FROM tipo_cuota WHERE descripcion = @nombre_cuota) AND cliente_id = @cliente_id)
		DECLARE @pagado BIT
		DECLARE @debe MONEY
		IF(@monto_pagado = (SELECT monto_total FROM tipo_cuota WHERE descripcion = @nombre_cuota)) BEGIN
			SET @pagado = 1
			SET @debe = 0
			UPDATE cuotas SET estado = 1
				WHERE cliente_id = @cliente_id
		END ELSE BEGIN
			SET @pagado = 0
			SET @debe = (SELECT monto_total FROM tipo_cuota WHERE descripcion = @nombre_cuota) - @monto_pagado
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

CREATE PROCEDURE sp_AgregarAsistenciaCliente (@dni VARCHAR(20)) AS
	BEGIN
		DECLARE @cliente_id int
		IF EXISTS (SELECT 1 FROM cuotas WHERE cliente_id = (SELECT id_cliente FROM clientes WHERE dni = @dni) AND estado = 1) 
		BEGIN
			SET @cliente_id = (SELECT id_cliente FROM clientes WHERE dni = @dni)
			INSERT INTO asistencias_clientes (fecha, hora, cliente_id)
				VALUES (GETDATE(), CAST(GETDATE() AS TIME), @cliente_id)
		END ELSE IF (@dni NOT IN (SELECT dni FROM clientes)) 
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

CREATE PROCEDURE sp_AgregarAsistenciasEmpleados (@dni VARCHAR(20)) AS
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

GO

CREATE or ALTER PROCEDURE sp_ReporteParametrizadoClientes 

    @nombre NVARCHAR(50) = NULL,
    @apellido NVARCHAR(50) = NULL,
    @dni VARCHAR(20) = NULL,
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
      AND (@dni IS NULL OR c.dni = @dni)
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

-- Agregar prodecimiento para un reporte parametrizado.
-- Agregar Vistas (3).
-- Agregar Triggers (Insercion, Eliminacion y opcional de Modificacion).