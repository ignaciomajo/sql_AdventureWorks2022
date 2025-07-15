/*
==========================================================================================
    Script: 03_aggregations_and_grouping.sql
    Descripción: Consultas con funciones de agregación como SUM, AVG, COUNT, y uso de 
                 GROUP BY y HAVING. Análisis de ventas, productos y facturación.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-14]
==========================================================================================
*/

USE AdventureWorks2022;


-- 1. Mostrar el promedio del listado de precios de productos.
--Tablas: Production.Product
--Campos: ListPrice

SELECT
	ROUND(AVG(ListPrice),2) AS AveragePrice
FROM
	Production.Product;




-- 2. Mostrar el precio más barato de todas las bicicletas.
--Tablas: Production.Product
--Campos: ListPrice, Name



SELECT
	MIN(ListPrice) as MinBikePrice
FROM
	Production.Product
WHERE
	ProductSubcategoryID IN (1, 2, 3);




-- 3. Mostrar la fecha de nacimiento del empleado más joven.
--Tablas: HumanResources.Employee
--Campos: BirthDate


SELECT
	MAX(BirthDate)
FROM
	HumanResources.Employee;


-- 4. Mostrar la fecha más reciente de venta.
--Tablas: Sales.SalesOrderHeader
--Campos: OrderDate

SELECT
	MAX(OrderDate)
FROM
	Sales.SalesOrderHeader;


-- 5. Mostrar la cantidad de ventas y el total vendido.
--Tablas: Sales.SalesOrderDetail
--Campos: LineTotal

SELECT 
	COUNT(*) AS SalesQuantity, 
	CAST(ROUND(SUM(LineTotal), 2) AS DECIMAL(12, 2)) AS SalesTotal
FROM
	Sales.SalesOrderDetail;




-- 6. Mostrar los productos y la cantidad total vendida de cada uno de ellos, ordenados por el total vendido.
--Tablas: Sales.SalesOrderDetail


SELECT
	ProductID, CAST(ROUND(SUM(LineTotal), 2) AS DECIMAL(12, 2)) AS SalesTotal
FROM
	Sales.SalesOrderDetail
GROUP BY
	ProductID
ORDER BY
	SalesTotal DESC;





-- 7. Mostrar el promedio vendido por factura.
--Tablas: Sales.SalesOrderDetail


SELECT
	CAST(ROUND(AVG(LineTotal), 2) AS DECIMAL(10, 2)) AS AverageOrder
FROM
	Sales.SalesOrderDetail;




-- 8. Mostrar todas las facturas realizadas y el total facturado de cada una de ellas, ordenado por número de factura,
--    pero sólo de aquellas órdenes que superen un total de $10.000.
--Tablas: Sales.SalesOrderDetail


SELECT
	SalesOrderID,
	CAST(ROUND(SUM(LineTotal), 2) AS DECIMAL(12, 2)) AS SalesTotal
FROM
	Sales.SalesOrderDetail
GROUP BY
	SalesOrderID
HAVING
	SUM(LineTotal) > 10000;




-- 9. Mostrar la cantidad de facturas que vendieron más de 20 unidades.
--Tablas: Sales.SalesOrderDetail


SELECT
	COUNT(*) AS HighQuantitySales
FROM
	(SELECT 
		SalesOrderID
	 FROM 
		Sales.SalesOrderDetail
	 GROUP BY
		SalesOrderID
	 HAVING
		SUM(OrderQty) > 20) AS HighSales;
	



-- 10. Mostrar todos los códigos de subcategorías existentes junto con la cantidad para los productos cuyo
--    precio de lista sea mayor a $70 y el precio promedio sea mayor a $300.
--Tablas: Production.Product


SELECT 
    ProductSubcategoryID,
    COUNT(*) AS QtyProducts
FROM 
    Production.Product
WHERE 
    ListPrice > 70
GROUP BY 
    ProductSubcategoryID
HAVING 
    AVG(ListPrice) > 300;




-- 11. Mostrar el código de subcategoría y el precio del producto más barato de cada una de ellas.
--Tablas: Production.Product


SELECT
	ProductSubcategoryID,
	MIN(ListPrice) AS LowerPriceProduct
FROM
	Production.Product
GROUP BY
	ProductSubcategoryID;



-- 12. Mostrar las subcategorías que tienen dos o más productos que cuestan menos de $150.
--Tablas: Production.Product

SELECT
	ProductSubcategoryID,
	NumProducts
FROM
	(SELECT
		ProductSubcategoryID,
		COUNT(*) AS NumProducts
	FROM
		Production.Product
	WHERE
		ListPrice < 150
	GROUP BY
		ProductSubcategoryID) AS Subcategories
WHERE
	NumProducts >= 2;



-- 13. Mostrar el número de factura, el monto vendido, y al final, totalizar la facturación.
--Tablas: Sales.SalesOrderDetail


SELECT
	1 as 'Order',
	CAST(SalesOrderID AS VARCHAR(20)) as SalesOrderID,
	CAST(ROUND(SUM(LineTotal), 2) AS DECIMAL(15,2)) AS Total
FROM
	Sales.SalesOrderDetail
GROUP BY
	SalesOrderID
UNION ALL
SELECT
	2 as 'Order',
	'SalesOrders Total',
	CAST(ROUND(SUM(LineTotal), 2) AS DECIMAL(15,2))
FROM
	Sales.SalesOrderDetail

ORDER BY
	'Order';

-- NOTA: Se agrega la columna 'Order' para garantizar que el total se encuentre al final.



-- 14. Mostrar las órdenes de venta que incluyen más de 3 productos distintos.
--Tablas: Sales.SalesOrderDetail
--Campos: SalesOrderID, ProductID

SELECT
	sod.SalesOrderID
FROM
	Sales.SalesOrderDetail sod
GROUP BY
	sod.SalesOrderID
HAVING
	COUNT(sod.ProductID) > 3;



-- 15. Mostrar los productos que han sido vendidos en más de 5 facturas diferentes, junto con la cantidad de facturas.
--Tablas: Sales.SalesOrderDetail
--Campos: ProductID, SalesOrderID

SELECT
	ProductID,
	COUNT(SalesOrderID) AS [OrdersQty]
FROM
	Sales.SalesOrderDetail
GROUP BY
	ProductID
HAVING
	COUNT(SalesOrderID) > 5
ORDER BY
	[OrdersQty] DESC;



-- 16. Listar todos los productos cuyo precio sea inferior al precio promedio de todos los productos.
-- Tablas: Production.Product
-- Campos: Name, ListPrice

SELECT
	ProductID, ListPrice
FROM
	Production.Product
WHERE
	ListPrice < (SELECT AVG(ListPrice) FROM Production.Product)



-- 17. Listar el nombre, precio de lista, precio promedio y diferencia de precios entre cada producto y el valor promedio general.
-- Tablas: Production.Product
-- Campos: Name, ListPrice

SELECT
	Name,
	ListPrice,
	(SELECT AVG(ListPrice) FROM Production.Product) AS AvgPrice,
	ListPrice - (SELECT AVG(ListPrice) FROM Production.Product)  AS Diff
FROM
	Production.Product;



-- 18. Mostrar el o los códigos del producto más caro.
-- Tablas: Production.Product
-- Campos: ProductID, ListPrice

SELECT
	p1.ProductID
FROM
	Production.Product p1
WHERE
	ListPrice = (SELECT
					MAX(p2.ListPrice)
				FROM
					Production.Product p2);



-- 19. Mostrar el producto más barato de cada subcategoría. Mostrar subcategoría, código de producto y el precio de lista más barato ordenado por subcategoría.
-- Tablas: Production.Product
-- Campos: ProductSubcategoryID, ProductID, ListPrice

SELECT 
    p1.ProductSubcategoryID,
    p1.ProductID,
    p1.ListPrice
FROM 
    Production.Product p1
WHERE 
    p1.ListPrice = (
        SELECT MIN(p2.ListPrice)
        FROM Production.Product p2
        WHERE p2.ProductSubcategoryID = p1.ProductSubcategoryID
    )
    AND p1.ProductSubcategoryID IS NOT NULL
ORDER BY 
    p1.ProductSubcategoryID;

						



-- 20. Mostrar todos los productos que no fueron vendidos.
-- Tablas: Production.Product, Sales.SalesOrderDetail
-- Campos: Name, ProductID

SELECT
	ProductID,
	Name
FROM
	Production.Product
WHERE
	ProductID NOT IN (SELECT
						DISTINCT ProductID
					  FROM
						Sales.SalesOrderDetail)



-- 21. Mostrar la cantidad de personas que no son vendedores.
-- Tablas: Person.Person, Sales.SalesPerson
-- Campos: BusinessEntityID


SELECT
	COUNT(p.BusinessEntityID) AS NonSalesPersons
FROM
	Person.Person p
WHERE
	p.BusinessEntityID NOT IN (SELECT
								BusinessEntityID
							 FROM
								Sales.SalesPerson)




-- 22. Mostrar todos los vendedores (nombre y apellido) que no tengan asignado un territorio de ventas.
-- Tablas: Person.Person, Sales.SalesPerson
-- Campos: BusinessEntityID, TerritoryID, LastName, FirstName


SELECT
	CONCAT(pp.FirstName, ' ', pp.LastName) AS FullName
FROM
	Person.Person pp
WHERE
	pp.BusinessEntityID IN (SELECT
								sp.BusinessEntityID
							FROM
								Sales.SalesPerson sp
							WHERE
								TerritoryID IS NULL);



-- 23. Mostrar las órdenes de venta que se hayan facturado en territorio de Estados Unidos únicamente (código: "US").
-- Tablas: Sales.SalesOrderHeader, Sales.SalesTerritory
-- Campos: CountryRegionCode, TerritoryID


SELECT
	soh.SalesOrderID
FROM
	Sales.SalesOrderHeader soh
WHERE
	soh.TerritoryID IN (SELECT
							st.TerritoryID
						FROM
							Sales.SalesTerritory st
						WHERE
							CountryRegionCode = 'US')




-- 24. Mostrar las órdenes de venta facturadas en territorios de Estados Unidos, Francia e Inglaterra.
-- Tablas: Sales.SalesOrderHeader, Sales.SalesTerritory
-- Campos: CountryRegionCode, TerritoryID


SELECT
	soh.SalesOrderID
FROM
	Sales.SalesOrderHeader soh
WHERE
	soh.TerritoryID IN (SELECT
							st.TerritoryID
						FROM
							Sales.SalesTerritory st
						WHERE
							CountryRegionCode IN ('US', 'FR', 'GB'));



-- 25. Mostrar los nombres de los diez productos más caros.
-- Tablas: Production.Product
-- Campos: Name, ListPrice


SELECT TOP 10
	p1.Name,
	p1.ListPrice
FROM
	Production.Product p1
ORDER BY
	ListPrice DESC;



-- 26. Mostrar los productos cuya cantidad total de pedidos de venta sea igual o superior a 20.
-- Tablas: Production.Product, Sales.SalesOrderDetail
-- Campos: Name, ProductID, OrderQty



SELECT
	ProductID,
	Name
FROM
	Production.Product
WHERE
	ProductID IN (SELECT
					ProductID
				  FROM
					Sales.SalesOrderDetail
				  GROUP BY
					ProductID
				  HAVING
					SUM(OrderQty) > 20)


-- 27. Mostrar los nombres de todos los productos relacionados con ruedas.
-- Tablas: Production.Product, Production.ProductSubcategory
-- Campos: Name, ProductSubcategoryID


SELECT
	pp.Name
FROM
	Production.Product pp
WHERE
	pp.ProductSubcategoryID IN (SELECT
									ppsc.ProductSubcategoryID
								FROM
									Production.ProductSubcategory ppsc
								WHERE
									ppsc.Name LIKE '%wheel%')



-- 28. Mostrar los clientes ubicados en un territorio no cubierto por ningún vendedor.
-- Tablas: Sales.Customer, Sales.SalesPerson
-- Campos: TerritoryID


SELECT
	sc.CustomerID
FROM
	Sales.Customer sc
WHERE
	sc.TerritoryID	NOT IN (SELECT DISTINCT
								sp.TerritoryID
							FROM
								Sales.SalesPerson sp)



-- 29. Listar los productos cuyos precios de venta sean mayores o iguales que el precio de venta máximo de cualquier subcategoría.
-- Tablas: Production.Product
-- Campos: Name, ListPrice, ProductSubcategoryID


SELECT
	pp.Name,
	pp.ListPrice
FROM
	Production.Product pp
WHERE
	pp.ListPrice >= ALL(SELECT
							MAX(pp2.ListPrice)
						FROM
							Production.Product pp2
						GROUP BY
							pp2.ProductSubcategoryID);