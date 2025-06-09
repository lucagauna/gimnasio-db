CREATE VIEW vw_ClientesActivos AS
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    c.dni,
    c.edad,
    c.direccion,                        -- Clientes que estan al dia con el pago.
    cu.fecha_vencimiento,
    cu.estado
FROM clientes c
JOIN cuotas cu ON c.id_cliente = cu.cliente_id
WHERE cu.estado = 1;

GO
CREATE VIEW vw_AsistenciasClientes AS
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    a.fecha,												-- Historial asistencias clientes.
    a.hora
FROM clientes c
JOIN asistencias_clientes a ON c.id_cliente = a.cliente_id;
GO
CREATE VIEW vw_EstadoPagosClientes AS
SELECT
    c.id_cliente,
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
JOIN pagos p ON cu.id_cuota = p.cuota_id;

GO

CREATE VIEW vw_EmpleadosActivos AS
SELECT
    e.id_empleado,
    e.nombre,
    e.apellido,									-- Empleados Activos.
    e.dni,
    e.fecha_de_inicio,
    c.descripcion AS cargo,
    c.remuneracion
FROM empleados e
JOIN cargos c ON e.id_cargo = c.id_cargo
WHERE e.estado = 1;

GO 

CREATE VIEW vw_AsistenciaEmpleados AS
SELECT
    e.nombre,
    e.apellido,
    a.fecha,								-- Asistencia Empleados.
  a.hora AS hora_entrada
FROM empleados e
JOIN asistencias_empleados a ON e.id_empleado = a.empleado_id;