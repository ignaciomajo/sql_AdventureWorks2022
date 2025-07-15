/*
==========================================================================================
    Script: 06_temp_tables_and_cte.sql
    Descripción: Consultas que usan tablas temporales y CTEs para manipulación avanzada
                 de datos y simplificación de consultas complejas.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-15]
==========================================================================================
*/


USE AdventureWorks2022;


------------------------------------------------------------------------------------------------------------------------
-- 1. Clonar estructura y datos de los campos nombre, color y precio de lista de la tabla Production.Product 
--    en una tabla llamada #Productos.
-- Tablas: Production.Product
-- Campos: Name, ListPrice, Color
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #Productos;

CREATE TABLE #Productos(
	Name NVARCHAR(50) NOT NULL,
	Color NVARCHAR(15),
	ListPrice MONEY NOT NULL
);

INSERT INTO #Productos(Name, Color, ListPrice)
	(SELECT 
		Name,
		Color,
		ListPrice
	 FROM
		Production.Product);



SELECT * FROM #Productos;

------------------------------------------------------------------------------------------------------------------------
-- 2. Clonar solo estructura de los campos identificador, nombre y apellido de la tabla Person.Person en una tabla 
--    llamada #Personas.
-- Tablas: Person.Person
-- Campos: BusinessEntityID, FirstName, LastName
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #Personas;

CREATE TABLE #Personas(
	BusinessEntityID INT PRIMARY KEY,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL
)

------------------------------------------------------------------------------------------------------------------------
-- 3. Eliminar si existe la tabla #Productos.
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID (N'tempdb..#Productos', N'U') IS NOT NULL
	DROP TABLE #Productos;

------------------------------------------------------------------------------------------------------------------------
-- 4. Eliminar si existe la tabla #Personas.
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID (N'tempdb..#Personas', N'U') IS NOT NULL
	DROP TABLE #Personas;

------------------------------------------------------------------------------------------------------------------------
-- 5. Crear una CTE con las órdenes de venta.
-- Tablas: Sales.SalesOrderHeader
-- Campos: SalesPersonID, SalesOrderID, OrderDate
------------------------------------------------------------------------------------------------------------------------

WITH SalesOrders_CTE (SalesOrderID, OrderDate, SalesPersonID)
AS
	(
	SELECT 
		SalesOrderID, 
		OrderDate, 
		SalesPersonID
	FROM
		Sales.SalesOrderHeader
)
SELECT * FROM SalesOrders_CTE 
WHERE
	YEAR(OrderDate) < 2012;

------------------------------------------------------------------------------------------------------------------------
-- 6. Crear una tabla temporal #EmpleadosVentas con el ID y el nombre completo de los empleados que también son vendedores.
--Tablas: HumanResources.Employee, Sales.SalesPerson, Person.Person
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #EmpleadosVentas(
	BusinessEntityID INT PRIMARY KEY, 
	FullName NVARCHAR(100)
);

WITH Vendedores_CTE (BusinessEntityID)
AS
	(SELECT BusinessEntityID
	 FROM Sales.SalesPerson)

INSERT INTO #EmpleadosVentas (BusinessEntityID, FullName)
(SELECT
	vcte.BusinessEntityID,
	CONCAT(pp.FirstName, ' ', pp.LastName)
 FROM 
	Vendedores_CTE vcte
 JOIN
	Person.Person pp
 ON
	vcte.BusinessEntityID = pp.BusinessEntityID);

------------------------------------------------------------------------------------------------------------------------
-- 7. Crear una tabla temporal #PreciosProductos que almacene solo productos con precio mayor a $100, 
--    incluyendo nombre, color y precio.
--Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #PrecioProductos(
	Name NVARCHAR(50) NOT NULL,
	Color NVARCHAR(15),
	ListPrice MONEY NOT NULL
);

INSERT INTO #PrecioProductos (Name, Color, ListPrice)
(SELECT
	Name,
	Color,
	ListPrice
 FROM
	Production.Product
 WHERE
	ListPrice > 100);

------------------------------------------------------------------------------------------------------------------------
-- 8. Crear una CTE que liste las órdenes realizadas en 2013 junto con el ID del vendedor.
--Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

WITH SalesOrder2013_CTE (SalesOrderID, SalesPersonID)
AS
(
	SELECT
		SalesOrderID,
		SalesPersonID
	FROM
		Sales.SalesOrderHeader
	WHERE
		YEAR(OrderDate) = 2013
)
SELECT * FROM SalesOrder2013_CTE
ORDER BY SalesPersonID;

------------------------------------------------------------------------------------------------------------------------
-- 9. Crear una CTE que calcule el total vendido por producto.
--Tablas: Sales.SalesOrderDetail
------------------------------------------------------------------------------------------------------------------------

WITH TotalProducto_CTE (ProductID, Total)
AS
(
	SELECT
		ProductID,
		CAST(ROUND(SUM(LineTotal), 2) AS DECIMAL(12, 2))
	FROM
		Sales.SalesOrderDetail
	GROUP BY
		ProductID
)
SELECT * FROM TotalProducto_CTE
ORDER BY Total DESC;

------------------------------------------------------------------------------------------------------------------------
-- 10. Crear una CTE que calcule la cantidad de productos vendidos por subcategoría.
-- Tablas: Production.Product, Sales.SalesOrderDetail
------------------------------------------------------------------------------------------------------------------------

WITH QtySold_CTE (ProductSubcategoryID, Qty)
AS
(
	SELECT
		prodp.ProductSubcategoryID,
		SUM(sod.OrderQty)
	FROM
		Production.Product prodp
	JOIN
		Sales.SalesOrderDetail sod
	ON
		prodp.ProductID = sod.ProductID
	GROUP BY
		prodp.ProductSubcategoryID
)

SELECT * FROM QtySold_CTE
ORDER BY ProductSubcategoryID;

------------------------------------------------------------------------------------------------------------------------
-- 11. Crear una CTE que calcule el total vendido por vendedor y luego mostrar sólo aquellos con ventas mayores a $1,000,000.
--Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

WITH SalesAmount_CTE (SalesPersonID, Total)
AS
(
	SELECT
		SalesPersonID,
		SUM(SubTotal)
	FROM
		Sales.SalesOrderHeader
	GROUP BY
		SalesPersonID
)
SELECT * FROM SalesAmount_CTE
WHERE Total > 1000000
ORDER BY Total DESC;

------------------------------------------------------------------------------------------------------------------------
-- 12. Crear una tabla temporal #OrdenesGrandes que almacene las órdenes cuyo subtotal supera los $5000.
--Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #OrdenesGrandes(
	SalesOrderID INT PRIMARY KEY, 
	Subtotal MONEY NOT NULL
);

INSERT INTO #OrdenesGrandes (SalesOrderID, Subtotal)
(
SELECT
	SalesOrderID,
	Subtotal
FROM
	Sales.SalesOrderHeader
WHERE
	SubTotal > 5000
);

------------------------------------------------------------------------------------------------------------------------
-- 13. Usar una CTE recursiva para mostrar una secuencia de fechas desde el 1/1/2011 al 1/1/2012.
--Tablas: No requiere tablas
------------------------------------------------------------------------------------------------------------------------

WITH Fechas_CTE (Fecha)
AS
(
	SELECT
		CAST('2011/1/1' AS DATE) as Fecha
	UNION ALL
	SELECT
		DATEADD(Day, 1, Fecha)
	FROM 
		Fechas_CTE
	WHERE
		Fecha < '2012/1/1'
)

SELECT * FROM Fechas_CTE
OPTION (MAXRECURSION 400);

------------------------------------------------------------------------------------------------------------------------
-- 14. Crear una tabla temporal con los IDs de productos y su precio medio en todas las órdenes.
--Tablas: Sales.SalesOrderDetail
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #AvgPrices;

CREATE TABLE #AvgPrices (
	ProductID INT PRIMARY KEY, 
	AvgPrice MONEY NOT NULL
);

INSERT INTO #AvgPrices (ProductID, AvgPrice)
(
SELECT
	ProductID,
	CAST(ROUND(AVG(UnitPrice), 2) AS DECIMAL(12, 2))
FROM
	Sales.SalesOrderDetail
GROUP BY
	ProductID
);

SELECT * FROM #AvgPrices;

------------------------------------------------------------------------------------------------------------------------
-- 15. Crear una CTE que devuelva el promedio de unidades vendidas por producto y listar aquellos que están por encima 
--     del promedio general.
--Tablas: Sales.SalesOrderDetail
------------------------------------------------------------------------------------------------------------------------

WITH AvgQtySold_CTE (ProductID, AvgQty)
AS
(
	SELECT
		ProductID,
		AVG(OrderQty)
	FROM
		Sales.SalesOrderDetail
	GROUP BY
		ProductID
)

SELECT * 
FROM 
	AvgQtySold_CTE
WHERE
	AvgQty > (SELECT AVG(AvgQty) FROM AvgQtySold_CTE);

------------------------------------------------------------------------------------------------------------------------
-- 16. Crear una tabla temporal #VentasMensuales que contenga el total de ventas (SubTotal) por mes del año 2013.
--Tablas: Sales.SalesOrderHeader
--Campos: OrderDate, SubTotal
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #VentasMensuales2013 (
	Mes INT NOT NULL,
	Total MONEY NOT NULL
);
WITH MesVentas_CTE(Mes, SubTotal)
AS
(
	SELECT
		MONTH(OrderDate),
		SubTotal
	FROM
		Sales.SalesOrderHeader
)

INSERT INTO #VentasMensuales2013(Mes, Total)
(
SELECT
	Mes,
	SUM(SubTotal)
FROM
	MesVentas_CTE
GROUP BY
	Mes);

SELECT * FROM #VentasMensuales2013
ORDER BY Mes;

------------------------------------------------------------------------------------------------------------------------
-- 17. Crear una CTE que calcule la cantidad total vendida por categoría de producto.
--Tablas: Production.Product, Production.ProductSubcategory, Production.ProductCategory, Sales.SalesOrderDetail
------------------------------------------------------------------------------------------------------------------------

WITH CategoryAmount_CTE (ProductCategoryID, Category, Total)
AS
(
SELECT
	ppc.ProductCategoryID,
	ppc.Name,
	CAST(ROUND(SUM(sod.LineTotal), 2) AS DECIMAL(12, 2))
FROM
	Sales.SalesOrderDetail sod
JOIN
	Production.Product pp
ON
	sod.ProductID = pp.ProductID
JOIN
	Production.ProductSubcategory ppsc
ON
	pp.ProductSubcategoryID = ppsc.ProductSubcategoryID
JOIN
	Production.ProductCategory as ppc
ON
	ppsc.ProductCategoryID = ppc.ProductCategoryID
GROUP BY
	ppc.ProductCategoryID, ppc.Name
)

SELECT * FROM CategoryAmount_CTE
ORDER BY ProductCategoryID;

------------------------------------------------------------------------------------------------------------------------
--18. Crear una CTE que calcule el precio promedio por subcategoría de productos, y luego listar solo las subcategorías 
--    con precio promedio mayor a $500.
--Tablas: Production.Product, Production.ProductSubcategory
------------------------------------------------------------------------------------------------------------------------

WITH SubcategoryAvgPrice_CTE (ProductSubcategoryID, AvgPrice)
AS
(
SELECT
	ProductSubcategoryID,
	AVG(ListPrice)
FROM
	Production.Product
GROUP BY
	ProductSubcategoryID
)

SELECT * FROM SubcategoryAvgPrice_CTE
WHERE AvgPrice > 500;

------------------------------------------------------------------------------------------------------------------------
-- 19. Crear una tabla temporal #TopVendedores2013 que contenga los IDs y nombres completos de los vendedores que 
--     realizaron más de $1,000,000 en ventas en 2013.
--Tablas: Sales.SalesOrderHeader, Sales.SalesPerson, Person.Person
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #TopVendedores2013 (
	SalesPersonID INT PRIMARY KEY, 
	FullName NVARCHAR(100) NOT NULL,
	Total MONEY NOT NULL
);

WITH FullNames_CTE (BusinessEntityID, FullName)
AS
(
SELECT
	BusinessEntityID,
	CONCAT(FirstName, ' ', LastName)
FROM
	Person.Person
)


INSERT INTO #TopVendedores2013 (SalesPersonID, FullName, TOTAL)
(
SELECT
	soh.SalesPersonID,
	fn.FullName,
	SUM(soh.SubTotal)
FROM
	Sales.SalesOrderHeader soh
JOIN
	FullNames_CTE fn
ON
	soh.SalesPersonID = fn.BusinessEntityID
GROUP BY
	soh.SalesPersonID, fn.FullName
);

SELECT * FROM #TopVendedores2013
ORDER BY Total DESC;
	
------------------------------------------------------------------------------------------------------------------------
-- 20. Crear una tabla temporal con los productos cuyo precio se encuentra por encima del promedio global de 
--     todos los productos.
--Tablas: Production.Product
--Campos: Name, ListPrice
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #HighValueProducts (
	ProductID INT PRIMARY KEY,
	Name NVARCHAR(100) NOT NULL,
	ListPrice MONEY NOT NULL
);

INSERT INTO #HighValueProducts (ProductID, Name, ListPrice)
(
SELECT
	ProductID,
	Name,
	ListPrice
FROM
	Production.Product
WHERE
	ListPrice > (SELECT AVG(ListPrice) FROM Production.Product)
);



-- =====================================================================================================================