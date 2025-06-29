USE GimnasioBd;

GO

CREATE VIEW vw_ClientesActivos AS
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    u.dni,
    c.edad,
    c.direccion,                        -- Clientes que estan al dia con el pago.
    u.estado
FROM clientes c
JOIN usuarios u ON c.usuario_id = u.id_usuario
WHERE u.estado = 1;

GO

CREATE VIEW vw_AsistenciasClientes AS
SELECT
    c.id_cliente,
    u.dni,
    c.nombre,
    c.apellido,
    a.fecha,												-- Historial asistencias clientes.
    a.hora
FROM clientes c
JOIN asistencias_clientes a ON c.id_cliente = a.cliente_id
JOIN usuarios u ON c.usuario_id = u.id_usuario;

GO

CREATE or ALTER VIEW  vw_AsistenciasEmpleados AS
	SELECT 
	e.id_empleado,
	u.dni,
	e.nombre,
	e.apellido,
	c.descripcion,
	a.fecha,
	a.hora as Hora_Entrada
	FROM empleados e
	JOIN asistencias_empleados a ON e.id_empleado = a.empleado_id
	JOIN usuarios u ON e.id_empleado = u.id_usuario
	JOIN cargos c ON e.id_cargo = c.id_cargo



GO



GO

CREATE VIEW vw_EstadoPagosClientes AS
SELECT
    u.dni,
    c.nombre,
    c.apellido,
    cu.id_cuota,                     -- Estado de pagos de cada cliente.
    cu.fecha_inicio,
    cu.fecha_vencimiento,
    p.monto_pagado,
    p.pagado,
    p.debe
FROM clientes c
JOIN cuotas cu ON c.id_cliente = cu.cliente_id
JOIN pagos p ON cu.id_cuota = p.cuota_id
JOIN usuarios u ON c.usuario_id = u.id_usuario;

GO

CREATE VIEW vw_EmpleadosActivos AS
SELECT
    e.id_empleado,
    e.nombre,
    e.apellido,									-- Empleados Activos.
    u.dni,
    e.fecha_de_inicio,
    c.descripcion AS cargo,
    c.remuneracion
FROM empleados e
JOIN cargos c ON e.id_cargo = c.id_cargo
JOIN usuarios u ON e.usuario_id = u.id_usuario
WHERE u.estado = 1;

GO 


CREATE VIEW vw_HistorialPagosCliente AS
SELECT
    c.id_cliente,												-- Pagos Clientes.
    u.dni,
    c.nombre,
    c.apellido,
    p.fecha_pago,
    p.monto_pagado,
    p.medio_pago,
    p.pagado,
    p.debe
FROM clientes c
JOIN pagos p ON c.id_cliente = p.cliente_id
JOIN usuarios u ON c.usuario_id = u.id_usuario;


