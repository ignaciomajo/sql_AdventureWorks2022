/*
==========================================================================================
    Script: 06_temp_tables_and_cte.sql
    Descripción: Consultas que usan tablas temporales y CTEs para manipulación avanzada
                 de datos y simplificación de consultas complejas.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-14]
==========================================================================================
*/

USE AdventureWorks2022;

-- 1. Clonar estructura y datos de los campos nombre, color y precio de lista de la tabla Production.Product en una tabla llamada #Productos.
-- Tablas: Production.Product
-- Campos: Name, ListPrice, Color








-- 2. Clonar solo estructura de los campos identificador, nombre y apellido de la tabla Person.Person en una tabla llamada #Personas.
-- Tablas: Person.Person
-- Campos: BusinessEntityID, FirstName, LastName








-- 3. Eliminar si existe la tabla #Productos.








-- 4. Eliminar si existe la tabla #Personas.








-- 5. Crear una CTE con las órdenes de venta.
-- Tablas: Sales.SalesOrderHeader
-- Campos: SalesPersonID, SalesOrderID, OrderDate








-- 6. Crear una tabla temporal #EmpleadosVentas con el ID y el nombre completo de los empleados que también son vendedores.
--Tablas: HumanResources.Employee, Sales.SalesPerson, Person.Person








-- 7. Crear una tabla temporal #PreciosProductos que almacene solo productos con precio mayor a $100, incluyendo nombre, color y precio.
--Tablas: Production.Product









-- 8. Crear una CTE que liste las órdenes realizadas en 2013 junto con el ID del vendedor.
--Tablas: Sales.SalesOrderHeader








-- 9. Crear una CTE que calcule el total vendido por producto.
--Tablas: Sales.SalesOrderDetail








-- 10. Crear una CTE que calcule la cantidad de productos vendidos por subcategoría.
-- Tablas: Production.Product, Sales.SalesOrderDetail








-- 11. Crear una CTE que calcule el total vendido por vendedor y luego mostrar sólo aquellos con ventas mayores a $1,000,000.
--Tablas: Sales.SalesOrderHeader








-- 12. Crear una tabla temporal #OrdenesGrandes que almacene las órdenes cuyo subtotal supera los $5000.
--Tablas: Sales.SalesOrderHeader









-- 13. Usar una CTE recursiva para mostrar una secuencia de fechas desde el 1/1/2011 al 1/1/2012.
--Tablas: No requiere tablas









-- 14. Crear una tabla temporal con los IDs de productos y su precio medio en todas las órdenes.
--Tablas: Sales.SalesOrderDetail








-- 15. Crear una CTE que devuelva el promedio de unidades vendidas por producto y listar aquellos que están por encima del promedio general.
--Tablas: Sales.SalesOrderDetail