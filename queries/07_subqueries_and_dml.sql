/*
==========================================================================================
    Script: 07_subqueries_and_dml.sql
    Descripción: Subconsultas y operaciones DML (INSERT, UPDATE, DELETE) sobre tablas 
                 existentes y creadas. Incluye ejercicios de lógica de negocio, 
                 manipulación de datos y análisis con subconsultas.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-16]
==========================================================================================
*/


USE AdventureWorks2022;


-- 1. Clonar estructura y datos de los campos nombre, color y precio de lista de la tabla 
--    Production.Product en una tabla llamada Productos.
-- Tablas: Production.Product
-- Campos: ProductID, Name, Color, ListPrice









-- 2. Aumentar un 20% el precio de lista de todos los productos.
-- Tabla: Productos
-- Campo: ListPrice









-- 3. Aumentar un 20% el precio de lista de los productos del proveedor 1540.
-- Tablas: Productos, Purchasing.ProductVendor
-- Campos: ProductID, ListPrice, BusinessEntityID









-- 4. Eliminar los productos cuyo precio sea igual a cero.
-- Tabla: Productos
-- Campo: ListPrice









-- 5. Insertar un producto dentro de la tabla Productos con:
-- Nombre: "bicicleta mountain bike", Color: "Rojo", Precio: $4000










-- 6. Aumentar en un 15% el precio de los productos que en su nombre contengan "Pedal".
-- Tabla: Productos











-- 7. Eliminar los productos cuyo nombre comience con la letra "M".
-- Tabla: Productos










-- 8. Borrar todo el contenido de la tabla Productos sin usar DELETE.
-- Tabla: Productos










-- 9. Eliminar la tabla Productos.
-- Tabla: Productos










-- 10. Insertar en una nueva tabla temporal #VentasTopProductos los productos que superan 
-- el precio promedio general, usando subconsulta.
-- Tablas: Production.Product
-- Campos: ProductID, Name, ListPrice











-- 11. Crear una tabla ProductosPremium con los productos cuyo precio sea mayor al 
-- precio máximo de su subcategoría.
-- Tablas: Production.Product










-- 12. Insertar en una tabla temporal #SinVentas los productos que no hayan sido vendidos 
-- nunca.
-- Tablas: Production.Product, Sales.SalesOrderDetail












-- 13. Aumentar un 10% el precio de los productos cuyo color sea igual al color del 
-- producto más caro.
-- Tablas: Productos (requiere subconsulta)











-- 14. Eliminar los productos cuyo precio esté por debajo del 30% del precio promedio 
-- de su subcategoría.
-- Tablas: Productos











-- 15. Crear una tabla #Top10Costosos con los 10 productos más caros, usando TOP y 
-- subconsulta.
-- Tablas: Production.Product











-- 16. Insertar en una tabla #ProductosDuplicados aquellos productos cuyo nombre aparezca 
-- más de una vez (duplicados por nombre).
-- Tablas: Production.Product











-- 17. Actualizar el precio de los productos cuyo nombre contenga la palabra "Chain" para 
-- que sea igual al promedio de los productos de su subcategoría.
-- Tablas: Productos











-- 18. Eliminar los productos cuyo precio sea mayor que el doble del precio promedio de 
-- todos los productos.
-- Tablas: Productos










-- 19. Insertar productos en una tabla temporal #ProductosColorPromedio que tenga solo 
-- aquellos cuyo color tenga más de 10 productos asociados.
-- Tablas: Production.Product









-- 20. Insertar productos en una tabla Productos2022 desde la tabla original Production.Product 
-- pero solo aquellos creados (o modificados) en el año 2022.
-- Tablas: Production.Product (si hay campo de fecha relevante)









-- 21. Crear una tabla #VentasPorCliente que contenga el ID del cliente y la suma de 
-- todas sus órdenes, solo si esa suma supera el promedio de ventas general.
-- Tablas: Sales.SalesOrderHeader










-- 22. Eliminar de la tabla Productos todos los productos que no tienen proveedor 
-- asignado.
-- Tablas: Productos, Purchasing.ProductVendor