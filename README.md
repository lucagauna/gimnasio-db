# Sistema de Gestión de Gimnasio - Base de Datos II 🏋️‍♂️

Este repositorio contiene el diseño y modelado de la base de datos para un sistema de gestión de gimnasio, desarrollado como parte del Trabajo Práctico Integrador de la materia **Base de Datos II**.

## 📌 Descripción del sistema

El sistema está orientado a administrar las operaciones clave del gimnasio, incluyendo el control de clientes, registros de asistencia y gestión de pagos.

### 👥 Usuarios del sistema:
- **Clientes:** registran su asistencia diaria.
- **Empleados:** validan el ingreso de los clientes.
- **Dueño del gimnasio:** accede a reportes de asistencia y estado de pagos.

---

## 🗃️ Información almacenada en la base de datos

- **Clientes:** DNI, nombre, apellido, edad, dirección.
- **Cuotas:** tipo de cuota, fecha de inicio y vencimiento, estado de pago.
- **Pagos:** fecha, monto pagado, medio de pago.
- **Asistencias:** registros de fecha y hora tanto de clientes como de empleados.
- **Empleados:** nombre, apellido, DNI, fecha de ingreso, estado y cargo.
- **Cargos:** descripción del rol y remuneración.
- **Tipos de cuota:** descripción y monto.

---

## 🔑 Funcionalidades principales

- Registrar asistencias de clientes y empleados.
- Verificar si el cliente está habilitado para ingresar según su cuota.
- Identificar pagos vencidos, pendientes o próximos a vencer.
- Consultar la actividad y el flujo de personas en el gimnasio.

---

## 🧩 Modelo Entidad-Relación (DER)


![Bdd Gym](https://github.com/user-attachments/assets/43b0b883-5670-4cb4-8281-4e84cfde4ebc)


---


## ⚙️ Requisitos técnicos

- Motor de base de datos: PostgreSQL / MySQL / SQLite (según el caso)


---

## 📅 Estado del proyecto

✅ Modelado completo  
🛠️ Implementación en desarrollo

---

## ✍️ Autores


- Tomas Vudi
- Luca Gauna
- Facundo Cuello

---

## 📄 Licencia

Este proyecto fue desarrollado con fines educativos para la materia **Base de Datos II**. Uso académico.
