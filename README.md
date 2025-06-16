# 🏋️‍♂️ Sistema de Gestión de Gimnasio – Base de Datos II

Este repositorio contiene el diseño e implementación de una base de datos para un sistema de gestión de gimnasio. Fue desarrollado como parte del Trabajo Práctico Integrador de la materia **Base de Datos II** (Tecnicatura Universitaria en Programación – UTN General Pacheco).

---

## 📌 Descripción del sistema

El sistema está orientado a administrar las operaciones fundamentales de un gimnasio, automatizando tareas y garantizando la integridad de los datos a través de validaciones, procedimientos y triggers.

Entre sus funcionalidades principales se incluyen:

- Gestión de usuarios, clientes y empleados.
- Registro de asistencias.
- Control de cuotas y pagos.
- Reportes parametrizados y vistas consultables.
- Validaciones automatizadas mediante triggers.

---

## 👥 Usuarios del sistema

El sistema está pensado para ser utilizado por tres tipos de perfiles:

- **Owner (dueño):** Tiene acceso completo. Puede consultar reportes, estadísticas de asistencia y estado de pagos.
- **Empleado:** Registra asistencias de clientes y empleados, valida el estado de cuota de los clientes y administra la actividad diaria.
- **Cliente:** Solo puede registrar su asistencia si posee una cuota activa.

La autenticación se basa en la tabla `usuarios`, que almacena:
- DNI
- Contraseña (64 caracteres encriptados)
- Rol (`owner`, `empleado`, `cliente`)
- Estado (activo/inactivo)

---

## 🗃️ Entidades del sistema

La base de datos contiene las siguientes entidades principales:

### 🔹 `usuarios`
- DNI, contraseña, rol y estado.
- Asociado con clientes y empleados.

### 🔹 `clientes`
- Datos personales (nombre, apellido, dirección, fecha de nacimiento, edad).
- Enlace con usuarios y cuotas.

### 🔹 `empleados`
- Nombre, apellido, fecha de ingreso.
- Cargo asociado y estado.
- Relacionado con usuarios.

### 🔹 `cargos`
- Descripción del rol y remuneración.

### 🔹 `tipo_cuota`
- Descripción, monto total, duración (en días).

### 🔹 `cuotas`
- Tipo de cuota, fecha de inicio y vencimiento, estado.
- Cliente relacionado.

### 🔹 `pagos`
- Fecha de pago, monto abonado, medio de pago, deuda restante.
- Cuota y cliente asociado.

### 🔹 `asistencias_clientes` y `asistencias_empleados`
- Registro de fecha y hora de ingreso.

---

## 🔧 Procedimientos almacenados (principales)

Incluye lógica encapsulada para las siguientes operaciones:

- `sp_AgregarUsuario`: crea un nuevo usuario.
- `sp_AgregarCliente`: registra cliente a partir de un usuario existente.
- `sp_AgregarEmpleado`: agrega un nuevo empleado y lo asocia a un cargo.
- `sp_AgregarCuotas`: crea una cuota si el cliente no tiene una activa.
- `sp_AgregarPagos`: registra pagos y actualiza estado de deuda.
- `sp_ReporteParametrizadoCliente`: permite filtrar clientes por múltiples criterios.
- `sp_ValidarCuotas`: desactiva automáticamente las cuotas vencidas.
- `sp_AgregarAsistenciaCliente`: registra asistencia si el cliente está al día.
- `sp_AgregarAsistenciasEmpleados`: valida y registra asistencia de empleados.

---

## ⚙️ Triggers implementados

- Validan existencia de datos antes de insertar (`tr_AgregarCliente`, `tr_AgregarCuotas`).
- Previenen inserciones inválidas y duplicadas.
- Realizan bajas lógicas en vez de físicas (`tr_EliminarUsuario`, `tr_EliminarEmpleado`, etc.).
- Controlan automáticamente el estado de cuotas y pagos (`tr_AgregarPagos`, `tr_EliminarPagos`).
- Verifican si un cliente está autorizado a ingresar (`tr_AsistenciasClientes`).

---

## 🔍 Vistas del sistema

Permiten consultas simplificadas y reportes:

- `vw_ClientesActivos`: lista clientes con usuario activo.
- `vw_AsistenciasClientes`: historial de asistencias por cliente.
- `vw_EstadoPagosClientes`: detalle de pagos, deudas y cuotas.
- `vw_EmpleadosActivos`: empleados habilitados y su cargo.
- `vw_AsistenciaEmpleados`: historial de asistencias del personal.
- `vw_HistorialPagosCliente`: historial completo de pagos realizados.

---

## 📈 Reportes disponibles

- Clientes con cuotas activas o vencidas.
- Pagos pendientes o completos.
- Asistencias diarias de clientes y empleados.
- Consulta filtrada por nombre, edad, dirección, cuota activa.

---

## 🧩 Modelo Entidad-Relación

![Bdd Gym (2)](https://github.com/user-attachments/assets/3909f4d2-8248-4e3d-a5c2-c5763642158b)


---

## ⚙️ Requisitos técnicos

- **Motor de base de datos:** SQL Server (compatible con PostgreSQL o MySQL con mínimas adaptaciones).
- **Lenguaje:** SQL (T-SQL).
- **IDE sugerido:** SSMS (SQL Server Management Studio) o Azure Data Studio.
- **Scripts:** divididos por módulos:
  - `Inicio.sql` – estructura y creación de tablas.
  - `Procedures.sql` – procedimientos almacenados.
  - `Triggers.sql` – validaciones automáticas.
  - `Vistas.sql` – vistas para consultas y reportes.
  - `Datos.sql` - insercion de datos en el sistema. 

---

## 📅 Estado del proyecto

- ✅ Modelado conceptual y lógico completo.
- ✅ Implementación física funcional.
- ✅ Validaciones y automatizaciones activas.
- ✅ Documentación técnica lista.
- 🧪 Pruebas de integración en curso.

---

## 👨‍💻 Autores

- **Luca Gauna**
- **Facundo Cuello**


Desarrollado como parte del Trabajo Práctico Integrador – UTN General Pacheco.

---

## 📄 Licencia

Este proyecto fue desarrollado con fines exclusivamente **educativos** para la materia **Base de Datos II**. No se autoriza su uso comercial. Uso académico libre con fines de aprendizaje.

---

