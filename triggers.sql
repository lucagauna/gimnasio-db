USE GimnasioBd;

GO

CREATE OR ALTER TRIGGER tr_AgregarUsuario ON usuarios
	INSTEAD OF INSERT AS
	BEGIN
		IF EXISTS (SELECT 1 FROM roles WHERE id_rol IN (SELECT id_rol FROM inserted))
		BEGIN
			INSERT INTO usuarios (dni, contrase�a, rol_id, estado)
				SELECT dni, contrase�a, rol_id, estado FROM inserted
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
		IF EXISTS (SELECT 1 FROM clientes WHERE dni IN (SELECT dni FROM inserted))
		BEGIN
			RAISERROR('El usuario ingresado ya es un cliente...', 16, 1)
			RETURN
		END
		IF EXISTS (SELECT 1 FROM usuarios WHERE dni IN (SELECT dni FROM inserted) AND rol_id IN (SELECT id_rol FROM roles WHERE nombre_rol = 'Cliente')) -- ESTO ES RARO TMB, QUE PASA SI TENDRIA OTRO NOMBRE????
		BEGIN
			INSERT INTO clientes (usuario_id, dni, nombre, apellido, fecha_nacimiento, edad, direccion)
				SELECT usuario_id, dni, nombre, apellido, fecha_nacimiento, edad, direccion FROM inserted
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

--Modificar Cliente
--CREATE OR ALTER TRIGGER tr_ModificarClientes ON clientes
--	INSTEAD OF UPDATE AS
--	BEGIN
--		UPDATE 
--	END

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
	INSTEAD OF INSERT AS
	BEGIN
		IF ((SELECT estado FROM cuotas WHERE cliente_id IN (SELECT cliente_id FROM inserted)) = 1)
		BEGIN
			RAISERROR('Cliente ya pago la cuota...', 16, 1)
			RETURN
		END
		IF EXISTS (SELECT 1 FROM cuotas WHERE cliente_id IN (SELECT cliente_id FROM inserted) AND id_cuota IN (SELECT cuota_id FROM inserted))
		BEGIN
			INSERT INTO pagos (fecha_pago, monto_pagado, medio_pago, pagado, debe, cliente_id, cuota_id)
				SELECT fecha_pago, monto_pagado, medio_pago, pagado, debe, cliente_id, cuota_id FROM inserted
		END ELSE IF EXISTS (SELECT 1 FROM clientes WHERE id_cliente IN (SELECT cliente_id FROM inserted))
		BEGIN 
			RAISERROR('No existe cliente con una cuota ingresada...', 16, 1)
		END ELSE
		BEGIN
			RAISERROR('No existe cliente ingresado...', 16, 1)
		END
	END

DELETE FROM pagos
SELECT * FROM cuotas
SELECT * FROM pagos
EXEC sp_AgregarPagos 50, 'Efectivo', '46286381', 'Mensual' --Esto de poner 'Mensual' es medio raro, habria que chequearlo...

GO

CREATE OR ALTER TRIGGER tr_EliminarPagos ON pagos
	INSTEAD OF DELETE AS
	BEGIN
		UPDATE cuotas SET estado = 0
			WHERE cliente_id IN (SELECT cliente_id FROM deleted)
		DELETE FROM pagos 
			WHERE cliente_id IN (SELECT cliente_id FROM deleted)
	END
