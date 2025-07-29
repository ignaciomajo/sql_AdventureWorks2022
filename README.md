# Proyecto: Fundamentos y Técnicas Avanzadas de SQL con AdventureWorks2022

<img width="680" height="504" alt="sql_adventureworks2022" src="https://github.com/user-attachments/assets/76db255b-a8a0-4d0b-ab74-0c06225dc34f" />


## Índice 📋

1.  Descripción del proyecto.
2.  Acceso al proyecto.
3.  Estructura de los scripts.
4.  Base de datos utilizada.
5.  Habilidades SQL Demostradas.
6.  Tecnologías utilizadas.
7.  Desarrollador del proyecto.

## 1. Descripción del proyecto 📚

* El presente repositorio contiene una colección de 12 scripts SQL diseñados para demostrar un amplio rango de habilidades en SQL, desde consultas básicas hasta técnicas avanzadas.
* Los scripts están construidos sobre la base de datos `AdventureWorks2022` de Microsoft SQL Server, lo que permite trabajar con un esquema de datos realista y complejo, comúnmente utilizado en entornos empresariales.
* Cada script aborda un tema específico de SQL, proporcionando ejemplos claros y prácticos para ilustrar la sintaxis y los casos de uso de diversas funcionalidades. El objetivo es ofrecer un portafolio robusto que muestre la capacidad para manipular,
  transformar, analizar y optimizar datos utilizando SQL.

## 2. Acceso al proyecto 📂

Para obtener los scripts de este proyecto, tienes dos opciones:

1.  Clonar el repositorio utilizando la línea de comandos. Solo debes dirigirte al directorio donde deseas clonar el mismo e ingresar el comando:<br>
    `git clone https://github.com/ignaciomajo/sql_AdventureWorks2022`

2.  O puedes descargarlo directamente desde el repositorio en GitHub en el siguiente enlace:
    <p><a href="https://github.com/tu_usuario/tu_repositorio_sql">https://github.com/ignaciomajo/sql_AdventureWorks2022</a></p>

    Esto te llevará a la siguiente pantalla, donde deberás seguir los pasos para descargar el archivo comprimido `.zip`.

    <img width="1738" height="896" alt="image" src="https://github.com/user-attachments/assets/d911d920-7da8-47e7-ba8b-690fda33420b" />


## 3. Estructura de los scripts 📝

El proyecto está organizado en 12 scripts, cada uno centrado en un conjunto específico de funcionalidades SQL, de complejidad creciente:

* **`01_basic_queries_and_filters.sql`**: Consultas fundamentales (`SELECT`, `WHERE`), operadores lógicos, manipulación de fechas y funciones básicas (`ROUND`, `CAST`).
* **`02_pattern_matching_and_text_filters.sql`**: Uso de `LIKE` y patrones para filtrado de texto, y manejo de concatenaciones.
* **`03_aggregations_and_subqueries.sql`**: Funciones de agregación (`SUM`, `AVG`, `COUNT`), agrupamiento (`GROUP BY`, `HAVING`) y subconsultas básicas.
* **`04_case_when_and_data_transformation.sql`**: Lógica condicional (`CASE WHEN`), transformaciones de datos y ordenamiento condicional.
* **`05_joins_and_relationships.sql`**: Uniones de tablas (`INNER JOIN`, `LEFT JOIN`, `SELF JOIN`) y manejo de relaciones entre entidades.
* **`06_temp_tables_and_cte.sql`**: Creación y uso de tablas temporales y Common Table Expressions (CTEs) para organizar y simplificar consultas complejas.
* **`07_subqueries_and_dml.sql`**: Combinación de subconsultas con operaciones de manipulación de datos (`INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`).
* **`08_control_flow_and_procedures.sql`**: Declaración de variables, control de flujo (`IF`, `WHILE`) y creación/ejecución de procedimientos almacenados.
* **`09_user_defined_functions_and_triggers.sql`**: Creación de funciones definidas por el usuario (escalares y de tabla) y triggers para automatizar acciones en la base de datos.
* **`10_error_handling.sql`**: Implementación de manejo de errores con `TRY...CATCH`, `RAISERROR` y `THROW` para robustecer las transacciones.
* **`11_transactions_and_advanced_features.sql`**: Gestión de transacciones (`BEGIN TRAN`, `COMMIT`, `ROLLBACK`), uso de cursores y funciones de ventana (`OVER`). Utilización de `PIVOT/UNPIVOT`.
* **`12_query_optimization.sql`**: Análisis de rendimiento, uso de índices, interpretación de planes de ejecución y estrategias para optimizar consultas.

Cada script incluye comentarios detallados explicando las consultas, las tablas y campos utilizados, y el objetivo de cada ejercicio.

## 4. Base de datos utilizada 📊

Todos los scripts de este proyecto utilizan la base de datos `AdventureWorks2022`, una base de datos de ejemplo proporcionada por Microsoft SQL Server. Esta base de datos simula las operaciones de una empresa manufacturera ficticia, incluyendo datos de productos, ventas, empleados, clientes y mucho más.

Para poder ejecutar los scripts, necesitarás tener instalado:
* **Microsoft SQL Server** (cualquier versión compatible con `AdventureWorks2022`).
* La base de datos **`AdventureWorks2022`** restaurada en tu instancia de SQL Server. Puedes descargar el archivo de respaldo (`.bak`) desde el sitio oficial de Microsoft.

<p><a href="https://learn.microsoft.com/es-es/sql/samples/adventureworks-install-configure?view=sql-server-ver17&tabs=ssms">Bases de datos de ejemplo AdventureWorks</a></p>

## 5. Habilidades SQL Demostradas ✍️

Este proyecto te permitirá observar y comprender el dominio en las siguientes áreas clave de SQL:

* **Consultas de Datos:** `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`, `DISTINCT`, `TOP`.
* **Filtrado Avanzado:** Operadores lógicos (`AND`, `OR`, `NOT`), `LIKE`, `IN`, `EXISTS`, `ANY`/`ALL`, `BETWEEN`.
* **Manipulación de Texto y Fechas:** Funciones como `CONCAT`, `YEAR`, `DATEADD`, `DATEDIFF`.
* **Transformación de Datos:** Uso de `CASE WHEN` para lógica condicional y `CAST`/`CONVERT` para cambio de tipos de datos.
* **Combinación de Datos:** `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL OUTER JOIN`, `SELF JOIN`.
* **Agregaciones y Subconsultas:** Aplicación de funciones agregadas (`SUM`, `AVG`, `COUNT`, `MIN`, `MAX`) y diversas formas de subconsultas correlacionadas e independientes.
* **Modularización y Reutilización:** Implementación de tablas temporales, Common Table Expressions (CTEs), procedimientos almacenados y funciones definidas por el usuario (UDFs).
* **Control de Flujo:** Uso de variables, `IF` y `WHILE` para lógica programática dentro de SQL.
* **Automatización y Restricciones:** Creación y gestión de triggers.
* **Manejo de Transacciones:** Implementación de `BEGIN TRANSACTION`, `COMMIT TRANSACTION`, `ROLLBACK TRANSACTION` para asegurar la integridad de los datos.
* **Manejo de Errores:** Uso de `TRY...CATCH`, `RAISERROR`, `THROW` para construir código SQL robusto.
* **Optimización de Consultas:** Análisis de planes de ejecución, uso de índices y reescritura de consultas para mejorar el rendimiento.


## 6. Tecnologías utilizadas 🛠️

* **Microsoft SQL Server** (incluyendo SQL Server Management Studio)
* `T-SQL` (Transact-SQL)
* `Git` y `GitHub`


## 7. Desarrollador del proyecto 👷

![imagen-readme](https://github.com/user-attachments/assets/133bc743-0424-4120-a7a6-7245d2f28f8c)

**| Ignacio Majo | Data Scientist Junior |**

📫 Contacto: ignacio.majoo@gmail.com | 💻[LinkedIn](https://www.linkedin.com/in/ignacio-majo/)
