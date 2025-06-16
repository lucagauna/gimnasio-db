
use GimnasioBd



-- ===========================================
-- PRUEBAS DEL SISTEMA DE GIMNASIO - INSERT DATA
-- ===========================================

-- 1. Insertar roles
EXEC sp_AgregarRoles 'owner';
EXEC sp_AgregarRoles 'empleado';
EXEC sp_AgregarRoles 'cliente';

-- 2. Insertar cargos
EXEC sp_AgregarCargos 'Profesor de Musculaci�n', 450000;
EXEC sp_AgregarCargos 'Recepcionista', 350000;
EXEC sp_AgregarCargos 'Limpieza', 300000;

-- 3. Insertar usuarios
EXEC sp_AgregarUsuario '40111222', '123', 'cliente';   -- Cliente 1
EXEC sp_AgregarUsuario '45900927', '123', 'cliente';   -- Cliente 2
EXEC sp_AgregarUsuario '28042125', '123', 'empleado';  -- Empleado

-- 4. Insertar clientes
EXEC sp_AgregarCliente '40111222', 'Mar�a', 'G�mez', '1992-05-14', 'Calle Falsa 123';
EXEC sp_AgregarCliente '45900927', 'Carlos', 'P�rez', '2000-11-23', 'Av. Siempre Viva 456';

-- 5. Insertar empleado
EXEC sp_AgregarEmpleado 'Luc�a', 'Fern�ndez', '28042125', 'Profesor de Musculaci�n';

-- 6. Insertar tipo de cuota directamente (no hay par�metro para duraci�n en el SP)
INSERT INTO tipo_cuota (descripcion, monto_total, duracion)
VALUES 
('Mensual B�sica', 15000, 30),
('Trimestral Premium', 40000, 90);

-- 7. Asignar cuotas a clientes
EXEC sp_AgregarCuotas 'Mensual B�sica', '40111222';
EXEC sp_AgregarCuotas 'Mensual B�sica', '45905927';

-- 8. Pagos de cuotas
EXEC sp_AgregarPagos 15000, 'Efectivo', '40111222', 'Mensual B�sica';  -- Pago completo
EXEC sp_AgregarPagos 5000, 'D�bito', '45905927', 'Mensual B�sica';     -- Pago parcial

-- 9. Registrar asistencias
EXEC sp_AgregarAsistenciaCliente '40111222';    -- Deber�a funcionar
EXEC sp_AgregarAsistenciaCliente '45905927';    -- Deber�a rechazar: cuota no paga

EXEC sp_AgregarAsistenciasEmpleados '28042125'; -- Asistencia de empleado

-- 10. Validar vencimiento de cuotas
EXEC sp_ValidarCuotas;
SELECT * FROM cuotas
UPDATE cuotas SET fecha_vencimiento = GETDATE()
SELECT * FROM cuotas

-- 11. Ejemplo de reporte parametrizado
EXEC sp_ReporteParametrizadoCliente @edad_min = 20, @edad_max = 35;
EXEC sp_ReporteParametrizadoCliente @tiene_cuota_activa = 1;

-- ===========================================
-- CONSULTAS OPCIONALES DE VERIFICACI�N
-- ===========================================
-- SELECT * FROM usuarios;
-- SELECT * FROM clientes;
-- SELECT * FROM empleados;
-- SELECT * FROM tipo_cuota;
-- SELECT * FROM cuotas;
-- SELECT * FROM pagos;
-- SELECT * FROM asistencias_clientes;
-- SELECT * FROM asistencias_empleados;