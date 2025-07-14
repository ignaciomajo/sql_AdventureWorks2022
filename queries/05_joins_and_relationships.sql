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


-- 10. Mostrar el nombre completo de todos los empleados junto con el nombre de su cargo (JobTitle).
--Tablas: HumanResources.Employee, Person.Person

SELECT
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [FullName],
	hr.JobTitle
FROM
	Person.Person pp
JOIN
	HumanResources.Employee hr
ON
	pp.BusinessEntityID = hr.BusinessEntityID
ORDER BY
	hr.JobTitle;





-- 11. Listar el nombre de los productos junto con el nombre de su subcategoría y categoría.
--Tablas: Production.Product, Production.ProductSubcategory, Production.ProductCategory


SELECT
	prodp.Name AS [Product],
	prodsbc.Name AS [SubCategory],
	prodc.Name AS [Category]
FROM
	Production.Product prodp
JOIN
	Production.ProductSubcategory prodsbc
ON
	prodp.ProductSubcategoryID = prodsbc.ProductSubcategoryID
JOIN
	Production.ProductCategory prodc
ON
	prodsbc.ProductCategoryID = prodc.ProductCategoryID;






-- 12. Mostrar el nombre de los vendedores, su territorio y la región a la que pertenece.
--Tablas: Sales.SalesPerson, Sales.SalesTerritory, Person.Person

SELECT
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [FullName],
	st.Name AS [Territory],
	cr.Name AS [Region]
FROM
	Person.Person pp
JOIN
	Sales.SalesPerson sp
ON
	pp.BusinessEntityID = sp.BusinessEntityID
JOIN
	Sales.SalesTerritory st
ON
	sp.TerritoryID = st.TerritoryID
JOIN
	Person.CountryRegion cr
ON
	st.CountryRegionCode = cr.CountryRegionCode;
	
	



-- 13. Mostrar el nombre de todos los empleados junto con su número de teléfono (si tienen).
--Tablas: HumanResources.Employee, Person.PersonPhone, Person.Person


SELECT
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [FullName],
	ppp.PhoneNumber
FROM
	HumanResources.Employee hr
JOIN
	Person.Person pp
ON 
	hr.BusinessEntityID = pp.BusinessEntityID
LEFT JOIN
	Person.PersonPhone ppp
ON
	pp.BusinessEntityID = ppp.BusinessEntityID;




-- 14. Mostrar los nombres de los productos junto con el nombre de su proveedor principal.
--Tablas: Production.Product, Purchasing.ProductVendor, Purchasing.Vendor



-- No lo completé porque si te fijas esta misma consulta la pedía el curso. Consigna 8



-- 15. Mostrar los nombres de los productos junto con la cantidad total vendida de cada uno.
-- Tablas: Production.Product, Sales.SalesOrderDetail


SELECT
	prodp.Name,
	SUM(sod.OrderQty) AS [TotalQty]
FROM
	Production.Product prodp
JOIN
	Sales.SalesOrderDetail sod
ON
	prodp.ProductID = sod.ProductID
GROUP BY
	prodp.Name;




-- 16. Mostrar todas las órdenes de venta junto con el nombre del empleado que las gestionó.
-- Tablas: Sales.SalesOrderHeader, Sales.SalesPerson, Person.Person


SELECT
	soh.SalesOrderNumber,
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [FullName]
FROM
	Person.Person pp
JOIN
	Sales.SalesPerson sp
ON
	pp.BusinessEntityID = sp.BusinessEntityID
JOIN
	Sales.SalesOrderHeader soh
ON
	soh.SalesPersonID = sp.BusinessEntityID
ORDER BY
	FullName;





-- 17. Mostrar todas las personas que no son empleados.
--Tablas: Person.Person, HumanResources.Employee


SELECT
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [FullName]
FROM
	Person.Person pp
WHERE
	pp.BusinessEntityID NOT IN (SELECT BusinessEntityID FROM HumanResources.Employee);

-- NO SE ME OCURRIÓ COMO HACERLO CON JOIN


-- 18. Mostrar los nombres de productos que tengan más de un proveedor asociado.
--Tablas: Production.Product, Purchasing.ProductVendor


SELECT
	prodp.Name
FROM
	Production.Product prodp
JOIN
	Purchasing.ProductVendor purpv
ON
	prodp.ProductID = purpv.ProductID
GROUP BY
	prodp.Name
HAVING
	COUNT(*) > 1;



-- 19. Mostrar todas las subcategorías de productos que no tienen productos asociados.
--Tablas: Production.ProductSubcategory, Production.Product

SELECT
	prodsbc.Name
FROM
	Production.ProductSubcategory prodsbc
LEFT JOIN
	Production.Product pp
ON
	prodsbc.ProductSubcategoryID = pp.ProductSubcategoryID
WHERE
	pp.ProductSubcategoryID IS NULL;



-- 20. Listar los nombres de empleados que han gestionado ventas en más de un territorio.
--Tablas: Sales.SalesPerson, Sales.SalesOrderHeader, Person.Person, Sales.SalesTerritory


SELECT
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [FullName]
FROM
	Person.Person pp
JOIN
	Sales.SalesPerson sp
ON
	pp.BusinessEntityID = sp.BusinessEntityID
JOIN
	Sales.SalesOrderHeader soh
ON
	sp.BusinessEntityID = soh.SalesPersonID
GROUP BY
	pp.FirstName, pp.LastName, sp.BusinessEntityID
HAVING
	COUNT(DISTINCT soh.TerritoryID) > 1;




-- 21. Mostrar los nombres de productos que tienen proveedores, pero ningún pedido registrado en SalesOrderDetail.
--Tablas: Production.Product, Purchasing.ProductVendor, Sales.SalesOrderDetail


SELECT
	prodp.Name,
	purpv.BusinessEntityID AS [VendorID],
	sod.SalesOrderID as [SalesOrderID]
FROM
	Production.Product prodp
JOIN
	Purchasing.ProductVendor purpv
ON
	prodp.ProductID = purpv.ProductID
LEFT JOIN
	Sales.SalesOrderDetail sod
ON
	prodp.ProductID = sod.ProductID
WHERE
	SalesOrderID IS NULL;





-- 22. Mostrar: nombre completo, JobTitle, HireDate de los empleados que comparten el mismo título de trabajo y fecha de contratación exacta.
--Tablas: HumanResources.Employee, Person.Person

SELECT
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [FullName],
	hr1.JobTitle,
	hr1.HireDate
FROM
	Person.Person pp
JOIN
	HumanResources.Employee hr1
ON
	pp.BusinessEntityID = hr1.BusinessEntityID
JOIN
	HumanResources.Employee hr2
ON
	hr1.JobTitle = hr2.JobTitle
AND
	hr1.HireDate = hr2.HireDate
AND
	hr1.BusinessEntityID != hr2.BusinessEntityID
ORDER BY
	hr1.HireDate;