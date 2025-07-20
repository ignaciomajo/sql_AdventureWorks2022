/*
==========================================================================================
    Script: 11_transactions_and_advanced_features.sql
    Descripción: Uso de transacciones, cursores, funciones OVER, PIVOT y UNPIVOT para 
                 realizar consultas avanzadas y operaciones de control de flujo en SQL.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-20]
==========================================================================================
*/




------------------------------------------------------------------------------------------------------------------------
-- 1.  Borrar todos los productos que no se hayan vendido y luego revertir la operación.
-- Tablas: Production.Product, Sales.SalesOrderDetail
-- Campos: ProductID
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 2.  Incrementar el precio a 200 para todos los productos cuyo precio sea igual a cero y confirmar la transacción.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------------------------------------
-- 3.  Obtener el promedio del listado de precios y guardarlo en una variable llamada @Promedio. Incrementar todos 
--     los productos un 15%, pero si el precio mínimo no supera el promedio revertir toda la operación.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 4.  Incrementar las comisiones un 10% de aquellos vendedores que superaron el promedio de venta 
--     y que pertenezcan a un territorio.
-- Tablas: Sales.SalesPerson, Sales.SalesTerritory
------------------------------------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------------------------------------
-- 5.  Crear un cursor que recorra todos los productos con precio mayor a 500 y los copie a una tabla temporal 
--     solo si su peso no es NULL.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 6.  Utilizar un cursor para recorrer la tabla `Sales.SalesOrderHeader` y almacenar en una tabla temporal aquellos 
--     pedidos cuyo subtotal supere los 5000 y sean del año 2021.
--Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 7.  Mostrar para cada empleado su salario, el promedio general y cuánto se desvía del mismo (usando OVER).
--Tablas: HumanResources.EmployeePayHistory
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 8.  Mostrar la suma acumulada de ventas por año y producto utilizando funciones OVER y PARTITION BY.
--Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 9.  Pivotear los valores de los colores de los productos por categoría, mostrando la cantidad de productos en cada color.
--Tablas: Production.Product, Production.ProductSubcategory
------------------------------------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------------------------------------
-- 10. Realizar un UNPIVOT de una tabla temporal que contenga ventas por trimestre, para mostrar los datos en formato largo.
-- Tablas: tabla temporal simulada
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 11. Crear una transacción que inserte un nuevo cliente, cree una orden y sus líneas.
--     Revertir todo si alguna inserción falla.
-- Tablas: Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 12. Utilizar un cursor para actualizar las cantidades pedidas en las órdenes que tengan productos descontinuados.
-- Tablas: Sales.SalesOrderDetail, Production.Product
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 13. Calcular el ranking de productos más vendidos por año utilizando funciones OVER con RANK o DENSE_RANK.
-- Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 14. Mostrar por cada territorio el total vendido y su porcentaje respecto del total general usando OVER.
--Tablas: Sales.SalesTerritory, Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 15. Crear un PIVOT dinámico que muestre la suma de ventas por país y año.
--Tablas: Sales.SalesOrderHeader, Person.CountryRegion
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 16. Simular un rollback parcial dentro de una transacción, registrando en una tabla temporal los registros no insertados.
--Tablas: a definir por el usuario
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 17. Usar UNPIVOT para convertir columnas de contacto (Email, Phone, etc.) en filas para facilitar su análisis.
--Tablas: Person.Person, Person.EmailAddress
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 18. Usar funciones OVER para calcular la media móvil de los subtotales de orden en una ventana de 3 registros.
-- Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 19. Crear un cursor que recorra los empleados y les asigne un bono según sus años de servicio. 
--     Insertar los resultados en una tabla temporal.
-- Tablas: HumanResources.Employee
------------------------------------------------------------------------------------------------------------------------








-- =====================================================================================================================