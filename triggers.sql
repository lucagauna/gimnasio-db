USE GimnasioBd;

Go

CREATE OR ALTER TRIGGER tr_AgregarUsuario ON usuarios
	INSTEAD OF DELETE AS
	BEGIN
		UPDATE usuarios SET estado = 0 
			WHERE id_usuario IN (SELECT id_usuario FROM deleted) 
	END

GO

CREATE OR ALTER TRIGGER tr_AgregarCliente ON clientes
	INSTEAD OF INSERT AS
	BEGIN
		IF EXISTS (SELECT 1 FROM clientes WHERE dni = (SELECT dni FROM inserted))
		BEGIN
			RAISERROR('El usuario ingresado ya es un cliente...', 16, 1)
			RETURN
		END
		IF EXISTS (SELECT 1 FROM usuarios WHERE dni = (SELECT dni FROM inserted) AND rol_id = (SELECT id_rol FROM roles WHERE nombre_rol = 'Cliente'))
		BEGIN
			INSERT INTO clientes (usuario_id, dni, nombre, apellido, fecha_nacimiento, edad, direccion)
				SELECT usuario_id, dni, nombre, apellido, fecha_nacimiento, edad, direccion FROM inserted
		END ELSE IF EXISTS (SELECT 1 FROM usuarios WHERE dni = (SELECT dni FROM inserted))
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