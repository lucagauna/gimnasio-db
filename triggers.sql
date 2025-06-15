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

CREATE OR ALTER TRIGGER tr_AgregarCliente ON clientes
	INSTEAD OF INSERT AS
	BEGIN
		IF EXISTS (SELECT 1 FROM clientes WHERE usuario_id IN (SELECT usuario_id FROM inserted))
		BEGIN
			RAISERROR('El usuario ingresado ya es un cliente...', 16, 1)
			RETURN
		END
		IF EXISTS (SELECT 1 FROM usuarios WHERE dni IN (SELECT dni FROM inserted) AND rol_id IN (SELECT id_rol FROM roles WHERE nombre_rol = 'Cliente')) 
		BEGIN
			INSERT INTO clientes (usuario_id,nombre, apellido, fecha_nacimiento, edad, direccion)
				SELECT usuario_id, nombre, apellido, fecha_nacimiento, edad, direccion FROM inserted
		END ELSE IF EXISTS (SELECT 1 FROM usuarios WHERE dni IN (SELECT dni FROM inserted))
		BEGIN
			RAISERROR('El usuario ingresado no es un cliente...', 16, 1)
		END ELSE
		BEGIN
			RAISERROR('El usuario ingresado no existe...', 16, 1)
		END
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
		IF EXISTS (SELECT 1 FROM clientes WHERE usuario_id IN (SELECT usuario_id FROM inserted))
		BEGIN
			RAISERROR('El usuario ingresado ya está registrado como cliente.', 16, 1)
			RETURN
		END
		IF EXISTS (SELECT 1 FROM usuarios WHERE id_usuario IN (SELECT usuario_id FROM inserted) AND rol_id IN (SELECT id_rol FROM roles WHERE nombre_rol = 'cliente'))
		BEGIN
			INSERT INTO clientes (usuario_id, nombre, apellido, fecha_nacimiento, edad, direccion) SELECT usuario_id, nombre, apellido, fecha_nacimiento, edad, direccion FROM inserted
		END ELSE IF EXISTS (SELECT 1 FROM usuarios WHERE id_usuario IN (SELECT usuario_id FROM inserted))
		BEGIN
			RAISERROR('El usuario ingresado no tiene el rol de cliente.', 16, 1)
		END ELSE
		BEGIN
			RAISERROR('El usuario ingresado no existe.', 16, 1)
		END
	END

GO
CREATE OR ALTER TRIGGER tr_ModificarClientes ON clientes
INSTEAD OF UPDATE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM clientes WHERE usuario_id IN (SELECT usuario_id FROM inserted))
    BEGIN
        RAISERROR('El usuario que deseas modificar ya está en la tabla.', 16, 1)
        RETURN
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
		IF EXISTS (SELECT 1 FROM clientes WHERE id_cliente IN (SELECT cliente_id FROM inserted)) AND EXISTS (SELECT 1 FROM tipo_cuota WHERE id_tipo_cuota IN (SELECT id_tipo_cuota FROM inserted))
		BEGIN
			INSERT INTO cuotas (id_tipo_cuota, fecha_inicio, fecha_vencimiento, estado, cliente_id)
				SELECT id_tipo_cuota, fecha_inicio, fecha_vencimiento, estado, cliente_id FROM inserted
		END ELSE IF EXISTS (SELECT 1 FROM clientes WHERE id_cliente IN (SELECT cliente_id FROM inserted)) 
		BEGIN
			RAISERROR('La cuota ingresada no existe...', 16, 1)
		END ELSE
		BEGIN
			RAISERROR('El cliente ingresado no existe...', 16, 1)
		END
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
	AFTER INSERT AS
	BEGIN
		IF ((SELECT estado FROM cuotas WHERE id_cuota = (SELECT cuota_id FROM inserted)) = 1)
		BEGIN
			RAISERROR('Cliente ya pago la cuota...', 16, 1)
			ROLLBACK TRANSACTION
			RETURN
		END
		IF EXISTS (SELECT 1 FROM cuotas WHERE cliente_id IN (SELECT cliente_id FROM inserted) AND id_cuota IN (SELECT cuota_id FROM inserted))
		BEGIN
			IF ((SELECT pagado FROM inserted) = 1)
			BEGIN
				UPDATE cuotas SET estado = 1
					WHERE id_cuota = (SELECT cuota_id FROM inserted)
			END
		END ELSE IF EXISTS (SELECT 1 FROM clientes WHERE id_cliente IN (SELECT cliente_id FROM inserted))
		BEGIN 
			RAISERROR('No existe cliente con una cuota ingresada...', 16, 1)
			ROLLBACK TRANSACTION
		END ELSE
		BEGIN
			RAISERROR('No existe cliente ingresado...', 16, 1)
			ROLLBACK TRANSACTION
		END
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
			IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN cuotas c ON i.cliente_id = c.cliente_id AND c.estado = 1 WHERE c.cliente_id IS NULL)


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
					IF EXISTS (SELECT 1 FROM inserted i LEFT JOIN empleados e ON i.empleado_id = e.id_empleado WHERE e.id_empleado IS NULL)

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

	CREATE OR ALTER TRIGGER tr_EliminarEmpleado ON empleados
	INSTEAD OF DELETE AS
	BEGIN
		UPDATE usuarios SET estado = 0 
			WHERE id_usuario IN (SELECT usuario_id FROM deleted)
	END

GO



SELECT * FROM cuotas WHERE cliente_id = (SELECT id_cliente FROM clientes WHERE usuario_id = (SELECT id_usuario FROM usuarios WHERE dni = '45905927'))


GO




			



