/*
==========================================================================================
    Script: 09_user_defined_functions_and_triggers.sql
    Descripcion: Creación de funciones escalares y con valores de tabla, funciones 
                 multisentencia, triggers AFTER y validaciones. Incluye ejercicios 
                 teórico-prácticos de aplicación en la base AdventureWorks2022.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creacion: [2025-07-17]
==========================================================================================
*/


USE AdventureWorks2022;


------------------------------------------------------------------------------------------------------------------------
-- 01. Crear una función que devuelva el promedio del precio de todos los productos.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 02. Crear una función que, dado un código de producto, devuelva el total de ventas para dicho producto. 
--     Luego, mediante una consulta, traer código y total de ventas.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, LineTotal
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 03. Crear una función que, dado un código, devuelva la cantidad de productos vendidos o cero si no se ha vendido.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, OrderQty
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 04. Crear una función que devuelva el promedio de venta, luego obtener los productos cuyo precio sea inferior al promedio.
-- Tablas: Sales.SalesOrderDetail, Production.Product
-- Campos: LineTotal, ProductID, ListPrice
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 05. Crear una función que, dado un año, devuelva nombre y apellido de los empleados que ingresaron ese año.
-- Tablas: Person.Person, HumanResources.Employee
-- Campos: FirstName, LastName, HireDate, BusinessEntityID
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 06. Crear una función que reciba un parámetro correspondiente a un precio y que devuelva una tabla con código, 
--     nombre, color y precio de todos los productos cuyo precio sea inferior al parámetro ingresado.
-- Tablas: Production.Product
-- Campos: ProductID, Name, Color, ListPrice
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 07. Realizar el mismo pedido que en el punto anterior pero utilizando una función multisentencia.
-- Tablas: Production.Product
-- Campos: ProductID, Name, Color, ListPrice
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 08. Clonar estructura (ProductID, ListPrice) y datos de la tabla Production.Product en una tabla llamada Productos.
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 09. Crear un trigger sobre la tabla Productos llamado TR_ActualizaPrecios donde actualice la tabla #HistoricoPrecios 
--     con los cambios de precio.
-- Tablas: Productos
-- Campos: ProductID, ListPrice 
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 10. Adaptar el trigger del punto anterior donde valide que el precio no pueda ser negativo.
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 11. Crear una función escalar que, dado un ProductID, devuelva el nombre del producto o 'No encontrado' si no existe.
-- Tablas: Production.Product
-- Campos: ProductID, Name
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 12. Crear una función que, dado un nombre de subcategoría, devuelva cuántos productos existen en ella.
-- Tablas: Production.Product, Production.ProductSubcategory
-- Campos: Name, ProductSubcategoryID
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 13. Crear una función escalar que, dado un año, devuelva la cantidad total de órdenes de venta en ese año.
-- Tablas: Sales.SalesOrderHeader
-- Campos: OrderDate
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 14. Crear una función que devuelva la cantidad de productos por color, como tabla.
-- Tablas: Production.Product
-- Campos: Color
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 15. Crear una tabla #HistorialBonificaciones y un trigger que registre cualquier actualización en el campo Bonus 
--     de la tabla HumanResources.EmployeePayHistory.
-- Tablas: HumanResources.EmployeePayHistory
-- Campos: Bonus
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 16. Crear una función multisentencia que devuelva los productos con más de 5 unidades en stock total.
-- Tablas: Production.ProductInventory
-- Campos: ProductID, Quantity
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 17. Crear un trigger que impida eliminar productos cuyo precio sea mayor a 1000.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 18. Crear una función que reciba un año y un mes y devuelva la cantidad de empleados que ingresaron en ese período.
-- Tablas: HumanResources.Employee
-- Campos: HireDate
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 19. Crear una función de tabla que devuelva los productos que no han sido vendidos.
-- Tablas: Production.Product, Sales.SalesOrderDetail
-- Campos: ProductID
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 20. Crear un trigger que registre en la tabla #Eliminaciones los productos eliminados de la tabla Productos, 
--     incluyendo la fecha de eliminación.
-- Tablas: Productos
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 21. Crear una función que reciba un BusinessEntityID y devuelva el nombre completo del contacto asociado 
--     (FirstName + LastName).
-- Tablas: Person.Person
-- Campos: BusinessEntityID, FirstName, LastName
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 22. Crear una función escalar que devuelva el total de productos cuyo precio sea mayor al promedio general.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 23. Crear una función que devuelva los cinco productos más vendidos.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, OrderQty
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 24. Crear una función que reciba un valor de OrderQty y devuelva las órdenes con mayor cantidad que ese valor.
-- Tablas: Sales.SalesOrderDetail
-- Campos: OrderQty
------------------------------------------------------------------------------------------------------------------------





-- =====================================================================================================================
