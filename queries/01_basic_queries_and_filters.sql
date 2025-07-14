/*
==========================================================================================
    Script: 01_basic_queries_and_filters.sql
    Descripción: Consultas básicas con SELECT, filtros con WHERE, operadores lógicos,
                 manipulación de fechas, y funciones como ROUND y CAST.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-14]
==========================================================================================
*/



USE AdventureWorks2022;



--1. Mostrar el ID de los empleados que tienen más de 90 horas de vacaciones.
--Tablas: HumanResources.Employee
--Campos: VacationHours, BusinessEntityID


SELECT 
	BusinessEntityID, 
	VacationHours
FROM 
	HumanResources.Employee
WHERE
	VacationHours > 90
ORDER BY 
	VacationHours DESC;




--2. Mostrar el nombre, precio de lista y precio de lista con IVA de los productos con precio distinto de cero.
--Tablas: Production.Product
--Campos: Name, ListPrice


SELECT 
	Name, 
	ListPrice, 
	CAST(ROUND(ListPrice * 1.21, 2) AS DECIMAL(10, 2)) AS [ListPrice + IVA]
FROM
	Production.Product;





--3. Mostrar precio de lista y nombre de los productos 776, 777, 778
--Tablas: Production.Product
--Campos: ProductID, Name, ListPrice

SELECT 
	Name, 
	ListPrice
FROM
	Production.Product
WHERE
	ProductID IN (776, 777, 778);





-- 4. Mostrar el nombre concatenado con el apellido de las personas cuyo apellido sea Johnson.
--Tablas: Person.Person
--Campos: FirstName, LastName

SELECT 
	CONCAT(FirstName, ' ', LastName) AS FullName
FROM
	Person.Person
WHERE 
	LastName = 'Johnson';





-- 5. Mostrar todos los productos cuyo precio de lista sea inferior a $150 de color rojo o cuyo precio de lista sea mayor a $500 de color negro.
--Tablas: Production.Product
--Campos: ProductID, ListPrice, Color 

SELECT
	ProductID,
	ListPrice, 
	Color
FROM
	Production.Product
WHERE
	(Color = 'Red' AND ListPrice < 150)
	OR
	(Color = 'Black' AND ListPrice > 500)
ORDER BY
	Color DESC;





-- 6. Mostrar el ID, fecha de ingreso y horas de vacaciones de los empleados que ingresaron a partir del año 2000.
--Tablas: HumanResources.Employee
--Campos: BusinessEntityID, HireDate, VacationHours

SELECT
	BusinessEntityID,
	HireDate,
	VacationHours
FROM
	HumanResources.Employee
WHERE
	YEAR(HireDate) >= 2000
ORDER BY
	HireDate;






-- 7. Mostrar el nombre, número de producto, precio de lista y el precio de lista incrementado en un 10% de los productos 
-- cuya fecha de fin de venta sea anterior al día de hoy
--Tablas: Production.Product
--Campos: Name, ProductNumber, ListPrice, SellEndDate

SELECT
	ProductNumber,
	Name,
	ListPrice,
	CAST(ROUND(ListPrice * 1.10, 2) AS DECIMAL(10, 2)) AS [ListPrice + 10%]
FROM
	Production.Product
WHERE
	SellEndDate < GETDATE();






-- 8. Mostrar los representantes de ventas (vendedores) que no tienen definido el número de territorio.
--Tablas: Sales.SalesPerson
--Campos: BusinessEntityID, TerritoryID 


SELECT
	BusinessEntityID
FROM
	Sales.SalesPerson
WHERE
	TerritoryID IS NULL;





-- 9. Mostrar el peso de todos los artículos. Si el peso no estuviese definido, reemplazar por cero.
--Tablas: Production.Product
--Campos: ProductID, Weight

SELECT
	ProductID,
	COALESCE(Weight, 0) AS Weight
FROM
	Production.Product;






-- 10. Mostrar el nombre, precio y color de los accesorios para asientos de las bicicletas cuyo precio sea mayor a 100 dólares.
--Tablas: Production.Product
--Campos: Name, ListPrice, Color

SELECT
	Name, 
	ListPrice, 
	Color
FROM
	Production.Product
WHERE
	Name LIKE '%seat%'
	AND ListPrice > 100;





-- 11. Mostrar todos los productos cuyo precio de lista esté entre 200 y 300.
--Tablas: Production.Product
--Campos: ListPrice 

SELECT
	ProductID,
	ListPrice
FROM
	Production.Product
WHERE
	ListPrice BETWEEN 200 AND 300;





-- 12. Mostrar todos los empleados que nacieron entre 1970 y 1985.
--Tablas: HumanResources.Employee
--Campos: BirthDate


SELECT
	BusinessEntityID,
	BirthDate
FROM
	HumanResources.Employee
WHERE
	YEAR(BirthDate) BETWEEN 1970 AND 1985
ORDER BY
	BirthDate;




-- 13. Mostrar la fecha, número de cuenta y subtotal de las órdenes de venta efectuadas en los años 2011 y 2012.
--Tablas: Sales.SalesOrderHeader
--Campos: OrderDate, AccountNumber, SubTotal


SELECT
	OrderDate,
	AccountNumber,
	SubTotal
FROM
	Sales.SalesOrderHeader
WHERE
	YEAR(OrderDate) IN (2011, 2012)
ORDER BY
	OrderDate;





-- 14.  Mostrar todas las órdenes de venta cuyo Subtotal no esté entre 50 y 70.
--Tablas: Sales.SalesOrderHeader
--Campos: OrderDate, AccountNumber, SubTotal


SELECT
	OrderDate,
	AccountNumber,
	SubTotal
FROM
	Sales.SalesOrderHeader
WHERE
	SubTotal NOT BETWEEN 50 AND 70;




-- 15. Mostrar los códigos de orden de venta, código de producto, cantidad vendida y precio unitario de los productos 750, 753 y 770.
--Tablas: Sales.SalesOrderDetail
--Campos: SalesOrderID, OrderQty, ProductID, UnitPrice 


SELECT
	SalesOrderId,
	ProductID,
	OrderQty,
	UnitPrice
FROM
	Sales.SalesOrderDetail
WHERE
	ProductID IN (750, 753, 770)
ORDER BY
	ProductID;




-- 16. Mostrar todos los productos cuyo color sea verde, blanco o azul.
--Tablas: Production.Product
--Campos: Color


SELECT
	ProductID,
	Name,
	Color
FROM
	Production.Product
WHERE
	Color IN ('Green', 'White', 'Blue')
ORDER BY
	Color;






-- 17. Mostrar las personas ordenadas, primero por su apellido y luego por su nombre.
--Tablas: Person.Person
--Campos: Firstname, Lastname 

SELECT
	FirstName,
	LastName
FROM
	Person.Person
ORDER BY
	LastName, FirstName;




-- 18. Mostrar los cinco productos más caros y su nombre, ordenados en forma alfabética.
--Tablas: Production.Product
--Campos: Name, ListPrice


SELECT TOP 5
	Name,
	ListPrice
FROM
	Production.Product
ORDER BY
	ListPrice DESC, Name ASC;