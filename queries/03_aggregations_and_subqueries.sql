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