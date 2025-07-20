/*
==========================================================================================
    Script: 11_transactions_and_advanced_features.sql
    Descripci�n: Uso de transacciones, cursores, funciones OVER, PIVOT y UNPIVOT para 
                 realizar consultas avanzadas y operaciones de control de flujo en SQL.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creaci�n: [2025-07-20]
==========================================================================================
*/




------------------------------------------------------------------------------------------------------------------------
-- 1.  Borrar todos los productos que no se hayan vendido y luego revertir la operaci�n.
-- Tablas: Production.Product, Sales.SalesOrderDetail
-- Campos: ProductID
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 2.  Incrementar el precio a 200 para todos los productos cuyo precio sea igual a cero y confirmar la transacci�n.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------------------------------------
-- 3.  Obtener el promedio del listado de precios y guardarlo en una variable llamada @Promedio. Incrementar todos 
--     los productos un 15%, pero si el precio m�nimo no supera el promedio revertir toda la operaci�n.
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
--     pedidos cuyo subtotal supere los 5000 y sean del a�o 2021.
--Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 7.  Mostrar para cada empleado su salario, el promedio general y cu�nto se desv�a del mismo (usando OVER).
--Tablas: HumanResources.EmployeePayHistory
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 8.  Mostrar la suma acumulada de ventas por a�o y producto utilizando funciones OVER y PARTITION BY.
--Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 9.  Pivotear los valores de los colores de los productos por categor�a, mostrando la cantidad de productos en cada color.
--Tablas: Production.Product, Production.ProductSubcategory
------------------------------------------------------------------------------------------------------------------------




------------------------------------------------------------------------------------------------------------------------
-- 10. Realizar un UNPIVOT de una tabla temporal que contenga ventas por trimestre, para mostrar los datos en formato largo.
-- Tablas: tabla temporal simulada
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 11. Crear una transacci�n que inserte un nuevo cliente, cree una orden y sus l�neas.
--     Revertir todo si alguna inserci�n falla.
-- Tablas: Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 12. Utilizar un cursor para actualizar las cantidades pedidas en las �rdenes que tengan productos descontinuados.
-- Tablas: Sales.SalesOrderDetail, Production.Product
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 13. Calcular el ranking de productos m�s vendidos por a�o utilizando funciones OVER con RANK o DENSE_RANK.
-- Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 14. Mostrar por cada territorio el total vendido y su porcentaje respecto del total general usando OVER.
--Tablas: Sales.SalesTerritory, Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 15. Crear un PIVOT din�mico que muestre la suma de ventas por pa�s y a�o.
--Tablas: Sales.SalesOrderHeader, Person.CountryRegion
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 16. Simular un rollback parcial dentro de una transacci�n, registrando en una tabla temporal los registros no insertados.
--Tablas: a definir por el usuario
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 17. Usar UNPIVOT para convertir columnas de contacto (Email, Phone, etc.) en filas para facilitar su an�lisis.
--Tablas: Person.Person, Person.EmailAddress
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 18. Usar funciones OVER para calcular la media m�vil de los subtotales de orden en una ventana de 3 registros.
-- Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 19. Crear un cursor que recorra los empleados y les asigne un bono seg�n sus a�os de servicio. 
--     Insertar los resultados en una tabla temporal.
-- Tablas: HumanResources.Employee
------------------------------------------------------------------------------------------------------------------------








-- =====================================================================================================================