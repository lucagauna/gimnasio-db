USE GimnasioBd;

GO

CREATE OR ALTER TRIGGER tr_AgregarUsuario ON usuarios
	INSTEAD OF INSERT AS
	BEGIN
		IF EXISTS (SELECT 1 FROM roles WHERE id_rol IN (SELECT id_rol FROM inserted))
		BEGIN
			INSERT INTO usuarios (dni, contraseña, rol_id, estado)
				SELECT dni, contraseña, rol_id, estado FROM inserted
		END
	END

GO

CREATE OR ALTER TRIGGER tr_EliminarUsuario ON usuarios
	INSTEAD OF DELETE AS
	BEGIN
		UPDATE usuarios SET estado = 0 
			WHERE id_usuario IN (SELECT id_usuario FROM deleted) 
	END

GO

CREATE OR ALTER TRIGGER tr_EliminarCliente ON clientes
	INSTEAD OF DELETE AS
	BEGIN
		UPDATE usuarios SET estado = 0 
			WHERE id_usuario IN (SELECT usuario_id FROM deleted)
	END

GO

CREATE OR ALTER TRIGGER tr_AgregarCliente ON clientes
	INSTEAD OF INSERT AS
	BEGIN
		IF ((SELECT edad FROM inserted) < 1 OR (SELECT edad FROM inserted) > 100)
		BEGIN
			RAISERROR('La fecha de nacimiento ingresada es incoherente.', 16, 1)
			RETURN
		END
		IF EXISTS (SELECT 1 FROM clientes WHERE usuario_id IN (SELECT usuario_id FROM inserted))
		BEGIN
			RAISERROR('El usuario ingresado ya está registrado como cliente.', 16, 1)
			RETURN
		END
		IF EXISTS (SELECT 1 FROM usuarios WHERE id_usuario IN (SELECT usuario_id FROM inserted) AND rol_id IN (SELECT id_rol FROM roles WHERE nombre_rol = 'cliente') AND estado = 1)
		BEGIN
			INSERT INTO clientes (usuario_id, nombre, apellido, fecha_nacimiento, edad, direccion) SELECT usuario_id, nombre, apellido, fecha_nacimiento, edad, direccion FROM inserted
			RETURN
		END ELSE IF EXISTS (SELECT 1 FROM usuarios WHERE id_usuario IN (SELECT usuario_id FROM inserted) AND estado = 1)
		BEGIN
			RAISERROR('El usuario ingresado no tiene el rol de cliente.', 16, 1)
			RETURN
		END ELSE IF EXISTS (SELECT 1 FROM usuarios WHERE id_usuario IN (SELECT usuario_id FROM inserted))
		BEGIN
			RAISERROR('El usuario ingresado no esta activo en el sistema.', 16, 1)
			RETURN
		END
		RAISERROR('El usuario ingresado no existe.', 16, 1)
	END

GO
CREATE OR ALTER TRIGGER tr_ModificarClientes ON clientes
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i  JOIN clientes c ON i.usuario_id = c.usuario_id  WHERE c.id_cliente <> i.id_cliente)
    BEGIN
        RAISERROR('El usuario que deseas modificar ya está en la tabla.', 16, 1)
        RETURN
    END

	IF EXISTS (SELECT 1 FROM inserted WHERE edad < 1 OR edad > 100 )
    BEGIN
        RAISERROR('La fecha de nacimiento ingresada es incoherente.', 16, 1);
        RETURN;
    END

    UPDATE c SET c.usuario_id = i.usuario_id, c.nombre = i.nombre, c.apellido = i.apellido, c.fecha_nacimiento = i.fecha_nacimiento, c.edad = i.edad
    FROM clientes c JOIN inserted i ON c.id_cliente = i.id_cliente
END
		

GO

CREATE OR ALTER TRIGGER tr_AgregarCuotas ON cuotas
	INSTEAD OF INSERT AS
	BEGIN
		IF EXISTS (SELECT 1 FROM cuotas WHERE cliente_id IN (SELECT cliente_id FROM inserted) AND estado = 1)
		BEGIN
			RAISERROR('Cliente ya tiene una cuota activa...', 16, 1)
			RETURN
		END
		IF EXISTS (SELECT 1 FROM cuotas WHERE cliente_id IN (SELECT cliente_id FROM inserted) AND id_tipo_cuota = (SELECT id_tipo_cuota FROM inserted))
			BEGIN
				RAISERROR('Cliente ya tiene esa cuota en el sistema...', 16, 1)
				RETURN
			END
		IF EXISTS (SELECT 1 FROM inserted i
						INNER JOIN clientes c ON i.cliente_id = c.id_cliente
							INNER JOIN tipo_cuota tc ON i.id_tipo_cuota = tc.id_tipo_cuota
								INNER JOIN usuarios u ON c.usuario_id = u.id_usuario
									WHERE u.estado = 1) 
		BEGIN
			INSERT INTO cuotas (id_tipo_cuota, fecha_inicio, fecha_vencimiento, estado, cliente_id)
				SELECT id_tipo_cuota, fecha_inicio, fecha_vencimiento, estado, cliente_id FROM inserted
			RETURN
		END ELSE IF EXISTS (SELECT 1 FROM inserted i
								INNER JOIN clientes c ON i.cliente_id = c.id_cliente
										INNER JOIN usuarios u ON c.usuario_id = u.id_usuario
											WHERE u.estado = 1)
		BEGIN
			RAISERROR('La cuota ingresada no existe...', 16, 1)
			RETURN
		END ELSE IF EXISTS (SELECT 1 FROM inserted i
								INNER JOIN clientes c ON i.cliente_id = c.id_cliente
										INNER JOIN usuarios u ON c.usuario_id = u.id_usuario)
		BEGIN
			RAISERROR('El cliente no esta activo en el sistema...', 16, 1)
			RETURN
		END
		RAISERROR('El cliente ingresado no existe...', 16, 1)
	END

GO

CREATE OR ALTER TRIGGER tr_EliminarCuotas ON cuotas
	INSTEAD OF DELETE AS
	BEGIN
		UPDATE cuotas SET estado = 0
			WHERE cliente_id IN (SELECT cliente_id FROM deleted)
	END

GO

CREATE OR ALTER TRIGGER tr_AgregarPagos ON pagos
	INSTEAD OF INSERT AS
	BEGIN
		BEGIN TRANSACTION
		IF ((SELECT estado FROM cuotas WHERE id_cuota = (SELECT cuota_id FROM inserted)) = 1) -- Si paga la cuota  a medias ya la toma como pagada y no entra.
		BEGIN
			RAISERROR('Cliente ya pago la cuota...', 16, 1)
			ROLLBACK TRANSACTION
			RETURN
		END
		IF EXISTS (SELECT 1 FROM inserted i
						INNER JOIN cuotas C ON i.cuota_id = c.id_cuota
							INNER JOIN clientes CL ON CL.id_cliente = i.cliente_id
								INNER JOIN usuarios U ON CL.usuario_id = U.id_usuario
									WHERE u.estado = 1)
		BEGIN
			IF ((SELECT pagado FROM inserted) = 1)
			BEGIN
				UPDATE cuotas SET estado = 1
					WHERE id_cuota = (SELECT cuota_id FROM inserted)
			END
			INSERT INTO pagos (fecha_pago, monto_pagado, medio_pago, pagado, debe, cliente_id, cuota_id)
				SELECT fecha_pago, monto_pagado, medio_pago, pagado, debe, cliente_id, cuota_id FROM inserted
			COMMIT
			RETURN
		END ELSE IF EXISTS (SELECT 1 FROM inserted i
								INNER JOIN clientes CL ON CL.id_cliente = i.cliente_id
									INNER JOIN usuarios U ON CL.usuario_id = U.id_usuario
											WHERE u.estado = 1)
		BEGIN 
			RAISERROR('No existe cliente con una cuota ingresada...', 16, 1)
			ROLLBACK TRANSACTION
			RETURN
		END ELSE IF EXISTS (SELECT 1 FROM inserted i
								INNER JOIN clientes CL ON CL.id_cliente = i.cliente_id
									INNER JOIN usuarios U ON CL.usuario_id = U.id_usuario
										WHERE u.estado = 0)
		BEGIN
			RAISERROR('El cliente no se encuentra activo en el sistema...', 16, 1)
			ROLLBACK TRANSACTION
			RETURN
		END
		RAISERROR('No existe cliente ingresado...', 16, 1)
		ROLLBACK TRANSACTION
	END

GO

CREATE OR ALTER TRIGGER tr_EliminarPagos ON pagos
	INSTEAD OF DELETE AS
	BEGIN
		UPDATE cuotas SET estado = 0
			WHERE cliente_id IN (SELECT cliente_id FROM deleted)
		DELETE FROM pagos 
			WHERE cliente_id IN (SELECT cliente_id FROM deleted)
	END

GO


CREATE OR ALTER TRIGGER tr_AsistenciasClientes ON asistencias_clientes
	INSTEAD OF INSERT
		AS
			BEGIN
			BEGIN TRANSACTION
			IF EXISTS (SELECT 1 FROM inserted i 
						LEFT JOIN cuotas c ON i.cliente_id = c.cliente_id AND c.estado = 1 
							LEFT JOIN clientes CL ON CL.id_cliente = i.cliente_id 
								LEFT JOIN usuarios U ON U.id_usuario = CL.usuario_id 
									WHERE c.cliente_id IS NULL AND u.estado = 1)
			BEGIN
				RAISERROR('El cliente no tiene una cuota activa o no existe.', 16, 1)
				ROLLBACK
			RETURN
			END


		INSERT INTO asistencias_clientes (fecha, hora, cliente_id)
		SELECT fecha, hora, cliente_id FROM inserted

		COMMIT
		END
		
		GO


		

CREATE OR ALTER TRIGGER tr_AsistenciasEmpleados ON asistencias_empleados
			INSTEAD OF INSERT
				AS 
				BEGIN 
				BEGIN TRANSACTION 
					IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN empleados e ON i.empleado_id = e.id_empleado LEFT JOIN usuarios u ON e.usuario_id = u.id_usuario WHERE e.id_empleado IS NULL OR u.estado <> 1) --Falta agregar validacion de estado

					BEGIN 
					RAISERROR('El empleado no existe.', 16, 1)
					ROLLBACK
						RETURN
						END

					INSERT INTO asistencias_empleados (fecha, hora, empleado_id)
					SELECT fecha, hora, empleado_id FROM inserted
					COMMIT
					END



		GO

CREATE OR ALTER TRIGGER tr_AgregarEmpleado ON empleados
	INSTEAD OF INSERT AS
	BEGIN
		BEGIN TRANSACTION
		IF EXISTS(SELECT 1 FROM empleados WHERE id_empleado = (SELECT id_empleado FROM inserted))
		BEGIN
			RAISERROR('El empleado ya esta ingresado...', 16, 1)
			ROLLBACK
			RETURN;
		END
		IF EXISTS(SELECT 1 FROM usuarios WHERE id_usuario = (SELECT usuario_id FROM inserted) AND rol_id = (SELECT id_rol FROM roles WHERE nombre_rol = 'Empleado') AND estado = 1)
		BEGIN
			INSERT INTO empleados (usuario_id, nombre, apellido, fecha_de_inicio, id_cargo)
				SELECT usuario_id, nombre, apellido, fecha_de_inicio, id_cargo FROM inserted
			COMMIT
			RETURN;
		END ELSE IF EXISTS (SELECT 1 FROM usuarios WHERE id_usuario = (SELECT usuario_id FROM inserted) AND rol_id = (SELECT id_rol FROM roles WHERE nombre_rol = 'Empleado'))
		BEGIN
			RAISERROR('El empleado no se encuentra activo en el sistema...', 16, 1)
			ROLLBACK
			RETURN
		END ELSE IF EXISTS (SELECT 1 FROM usuarios WHERE id_usuario = (SELECT usuario_id FROM inserted) AND estado = 1)
		BEGIN
			--RAISERROR('El usuario ingresado no es un Empleado...', 16, 1)
			ROLLBACK
			RETURN
		END ELSE
		BEGIN
			RAISERROR('El usuario ingresado no existe en el sistema...', 16, 1)
			ROLLBACK
			RETURN
		END
	END

GO

	CREATE OR ALTER TRIGGER tr_EliminarEmpleado ON empleados
	INSTEAD OF DELETE AS
	BEGIN
		UPDATE usuarios SET estado = 0 
			WHERE id_usuario IN (SELECT usuario_id FROM deleted)
	END

GO


CREATE OR ALTER TRIGGER tr_ModificarEmpleado ON empleados
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM inserted i JOIN empleados e ON i.usuario_id = e.usuario_id  WHERE e.id_empleado <> i.id_empleado)
    BEGIN
        RAISERROR('El ID de Usuario ya tiene datos asignados.', 16, 1)
        RETURN
    END

    UPDATE c SET c.usuario_id = i.usuario_id, c.nombre = i.nombre, c.apellido = i.apellido, c.fecha_de_inicio = i.fecha_de_inicio, c.id_cargo = i.id_cargo
    FROM empleados c JOIN inserted i ON c.id_empleado = i.id_empleado
	END




GO


			



