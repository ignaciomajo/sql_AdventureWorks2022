/*
==========================================================================================
    Script: 01_basic_queries_and_filters.sql
    Descripci�n: Consultas b�sicas con SELECT, filtros con WHERE, operadores l�gicos,
                 manipulaci�n de fechas, y funciones como ROUND y CAST.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creaci�n: [2025-07-14]
==========================================================================================
*/



--1. Mostrar el ID de los empleados que tienen m�s de 90 horas de vacaciones.
--Tablas: HumanResources.Employee
--Campos: VacationHours, BusinessEntityID









--2. Mostrar el nombre, precio de lista y precio de lista con IVA de los productos con precio distinto de cero.
--Tablas: Production.Product
--Campos: Name, ListPrice









--3. Mostrar precio de lista y nombre de los productos 776, 777, 778
--Tablas: Production.Product
--Campos: ProductID, Name, ListPrice










-- 4. Mostrar el nombre concatenado con el apellido de las personas cuyo apellido sea Johnson.
--Tablas: Person.Person
--Campos: FirstName, LastName










-- 5. Mostrar todos los productos cuyo precio de lista sea inferior a $150 de color rojo o cuyo precio de lista sea mayor a $500 de color negro.
--Tablas: Production.Product
--Campos: ProductID, ListPrice, Color 









-- 6. Mostrar el ID, fecha de ingreso y horas de vacaciones de los empleados que ingresaron a partir del a�o 2000.
--Tablas: HumanResources.Employee
--Campos: BusinessEntityID, HireDate, VacationHours








-- 7. Mostrar el nombre, n�mero de producto, precio de lista y el precio de lista incrementado en un 10% de los productos 
-- cuya fecha de fin de venta sea anterior al d�a de hoy
--Tablas: Production.Product
--Campos: Name, ProductNumber, ListPrice, SellEndDate









-- 8. Mostrar los representantes de ventas (vendedores) que no tienen definido el n�mero de territorio.
--Tablas: Sales.SalesPerson
--Campos: BusinessEntityID, TerritoryID 









-- 9. Mostrar el peso de todos los art�culos. Si el peso no estuviese definido, reemplazar por cero.
--Tablas: Production.Product
--Campos: ProductID, Weight









-- 10. Mostrar el nombre, precio y color de los accesorios para asientos, las bicicletas cuyo precio sea mayor a 100 d�lares.
--Tablas: Production.Product
--Campos: Name, ListPrice, Color









-- 11. Mostrar todos los productos cuyo precio de lista est� entre 200 y 300.
--Tablas: Production.Product
--Campos: ListPrice 









-- 12. Mostrar todos los empleados que nacieron entre 1970 y 1985.
--Tablas: HumanResources.Employee
--Campos: BirthDate









-- 13. Mostrar la fecha, n�mero de cuenta y subtotal de las �rdenes de venta efectuadas en los a�os 2005 y 2006.
--Tablas: Sales.SalesOrderHeader
--Campos: OrderDate, AccountNumber, SubTotal









-- 14.  Mostrar todas las �rdenes de venta cuyo Subtotal no est� entre 50 y 70.
--Tablas: Sales.SalesOrderHeader
--Campos: OrderDate, AccountNumber, SubTotal









-- 15. Mostrar los c�digos de orden de venta, c�digo de producto, cantidad vendida y precio unitario de los productos 750, 753 y 770.
--Tablas: Sales.SalesOrderDetail
--Campos: SalesOrderID, OrderQty, ProductID, UnitPrice 









-- 16. Mostrar todos los productos cuyo color sea verde, blanco y azul.
--Tablas: Production.Product
--Campos: Color









-- 17. Mostrar las personas ordenadas, primero por su apellido y luego por su nombre.
--Tablas: Person.Person
--Campos: Firstname, Lastname 









-- 18. Mostrar los cinco productos m�s caros y su nombre, ordenados en forma alfab�tica.
--Tablas: Production.Product
--Campos: Name, ListPrice