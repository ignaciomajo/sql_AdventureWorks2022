/*
==========================================================================================
    Script: 05_joins_and_relationships.sql
    Descripción: Consultas que involucran relaciones entre tablas, uso de JOINs y filtros
                 para combinar información relevante.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-14]
==========================================================================================
*/


USE AdventureWorks2022;


-- 1. Mostrar los empleados que también son vendedores.
-- Tablas: HumanResources.Employee, Sales.SalesPerson
-- Campos: BusinessEntityID

SELECT
	hr.BusinessEntityID
FROM
	HumanResources.Employee hr
JOIN
	Sales.SalesPerson sp
ON hr.BusinessEntityID = sp.BusinessEntityID;




-- 2. Mostrar los empleados ordenados alfabéticamente por apellido y por nombre.
-- Tablas: HumanResources.Employee, Person.Person
-- Campos: BusinessEntityID, LastName, FirstName



SELECT
	hr.BusinessEntityID,
	pp.LastName,
	pp.FirstName
FROM
	HumanResources.Employee hr
JOIN
	Person.Person pp
ON
	hr.BusinessEntityID = pp.BusinessEntityID
ORDER BY
	LastName, FirstName;




-- 3. Mostrar el código de logueo, código de territorio y bono de los vendedores.
-- Tablas: HumanResources.Employee, Sales.SalesPerson
-- Campos: LoginID, TerritoryID, Bonus, BusinessEntityID

SELECT
	hr.LoginID, sp.TerritoryID, sp.Bonus
FROM
	HumanResources.Employee hr
JOIN
	Sales.SalesPerson sp
ON hr.BusinessEntityID = sp.BusinessEntityID;




-- 4. Mostrar los productos que sean ruedas.
-- Tablas: Production.Product, Production.ProductSubcategory
-- Campos: Name, ProductSubcategoryID


SELECT
	pp.Name
FROM
	Production.Product pp
JOIN
	Production.ProductSubcategory pps
ON
	pp.ProductSubcategoryID = pps.ProductSubcategoryID
WHERE
	pps.Name = 'Wheels';



-- 5. Mostrar los nombres de los productos que no son bicicletas.
-- Tablas: Production.Product, Production.ProductSubcategory
-- Campos: Name, ProductSubcategoryID


SELECT
	pp.Name
FROM
	Production.Product pp
JOIN
	Production.ProductSubcategory pps
ON
	pp.ProductSubcategoryID = pps.ProductSubcategoryID
WHERE
	pps.Name NOT LIKE '%Bikes';





-- 6. Mostrar los precios de venta de aquellos productos donde el precio de venta sea inferior al precio de lista recomendado para ese producto,
--    ordenados por nombre de producto.
-- Tablas: Sales.SalesOrderDetail, Production.Product
-- Campos: ProductID, Name, ListPrice, UnitPrice

SELECT
	pp.Name,
	pp.ListPrice,
	sod.UnitPrice
FROM
	Production.Product pp
JOIN 
	Sales.SalesOrderDetail sod
ON
	pp.ProductID = sod.ProductID
WHERE
	sod.UnitPrice < pp.ListPrice
ORDER BY
	pp.Name;





-- 7. Mostrar todos los productos que tengan igual precio. Se deben mostrar de a pares, código y nombre de cada uno de los dos productos y el precio de ambos. 
--    Ordenar por precio en forma descendente.
-- Tablas: Production.Product
-- Campos: ProductID, ListPrice, Name


SELECT 
	pp1.ProductID, 
	pp1.Name, 
	pp2.ProductID, 
	pp2.Name, 
	pp1.ListPrice
FROM
	Production.Product pp1
JOIN
	Production.Product pp2
ON
	pp1.ListPrice = pp2.ListPrice
WHERE
	pp1.ProductID < pp2.ProductID
ORDER BY
	ListPrice DESC;




-- 8. Mostrar el nombre de los productos y de los proveedores cuya subcategoría es 15 ordenados por nombre de proveedor.
-- Tablas: Production.Product, Purchasing.ProductVendor, Purchasing.Vendor
-- Campos: Name, ProductID, BusinessEntityID, ProductSubcategoryID


SELECT
	pp.Name as [ProductName],
	purv.Name [VendorName]
FROM
	Production.Product pp
JOIN
	Purchasing.ProductVendor purpv
ON
	pp.ProductID = purpv.ProductID
JOIN
	Purchasing.Vendor purv
ON
	purpv.BusinessEntityID = purv.BusinessEntityID
WHERE
	pp.ProductSubcategoryID = 15
ORDER BY
	VendorName;
		





-- 9. Mostrar todas las personas (nombre y apellido) y en el caso de que sean empleados mostrar también el login ID, caso contrario mostrar NULL.
-- Tablas: Person.Person, HumanResources.Employee
-- Campos: FirstName, LastName, LoginID


SELECT
	CONCAT(perp.FirstName, ' ', perp.LastName) as FullName,
	hr.LoginID
FROM
	Person.Person perp
LEFT JOIN
	HumanResources.Employee hr
ON
	perp.BusinessEntityID = hr.BusinessEntityID;



