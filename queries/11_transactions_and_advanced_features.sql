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


USE AdventureWorks2022;


-- Se clonará la tabla productos para poder hacer eliminaciones sin restricciones.

CREATE TABLE #ProductosTemp(
	ProductID INT PRIMARY KEY,
	Name NVARCHAR(100),
	ProductNumber NVARCHAR(50),
	MakeFlag SMALLINT,
	FinishedGoodsFlag SMALLINT,
	Color NVARCHAR(15),
	SafetyStockLevel INT,
	ReorderPoint INT,
	StandardCost MONEY,
	ListPrice MONEY,
	Size NVARCHAR(10),
	SizeUnitMeasureCode NCHAR(6),
	WeightUnitMeasureCode NCHAR(6),
	Weight DECIMAL(10, 2),
	DaysToManufacture INT,
	ProductLine NCHAR(4),
	Class NCHAR(4),
	Style NCHAR(4),
	ProductSubcategoryID INT,
	ProductModelID INT,
	SellStartDate DATETIME,
	SellEndDate DATETIME,
	DiscontinuedDate DATETIME,
	rowguid NVARCHAR(50) UNIQUE,
	ModifiedDate DATETIME
);

INSERT INTO #ProductosTemp
SELECT * FROM Production.Product;

EXEC sp_help 'Production.Product';
SELECT TOP 1 * FROM Production.Product;
------------------------------------------------------------------------------------------------------------------------
-- 1.  Borrar todos los productos que no se hayan vendido y luego revertir la operación.
-- Tablas: #ProductosTemp, Sales.SalesOrderDetail
-- Campos: ProductID
------------------------------------------------------------------------------------------------------------------------

BEGIN TRY
	BEGIN TRANSACTION
		DELETE FROM #ProductosTemp
		WHERE ProductID NOT IN (SELECT DISTINCT 
									ProductID 
								FROM
									Sales.SalesOrderDetail);
	ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH

SELECT * FROM #ProductosTemp;

------------------------------------------------------------------------------------------------------------------------
-- 2.  Incrementar el precio a 200 para todos los productos cuyo precio sea igual a cero y confirmar la transacción.
-- Tablas: #ProductosTemp
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------
BEGIN TRY
	BEGIN TRANSACTION
		UPDATE 
			#ProductosTemp
		SET
			ListPrice = 200
		WHERE
			ListPrice = 0;
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH

------------------------------------------------------------------------------------------------------------------------
-- 3.  Obtener el promedio del listado de precios y guardarlo en una variable llamada @Promedio. Incrementar todos 
--     los productos un 15%, pero si el precio mínimo no supera el promedio revertir toda la operación.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------

DECLARE @Promedio MONEY = (SELECT AVG(ListPrice) FROM #ProductosTemp)

BEGIN TRY
	BEGIN TRANSACTION
		UPDATE
			#ProductosTemp
		SET
			ListPrice =	ListPrice * 1.15

	IF
		@Promedio > (SELECT MIN(ListPrice) FROM #ProductosTemp)
		BEGIN
			RAISERROR('El precio de los productos no supera el umbral solicitado', 16, 1)
		END
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH

------------------------------------------------------------------------------------------------------------------------
-- 4.  Incrementar las comisiones un 10% de aquellos vendedores que superaron el promedio de venta 
--     de su territorio.
-- Tablas: Sales.SalesPerson, Sales.SalesTerritory
------------------------------------------------------------------------------------------------------------------------

BEGIN TRY
	BEGIN TRANSACTION
		UPDATE
			Sales.SalesPerson
		SET
			CommissionPct = CommissionPct + 0.1
		WHERE			
			SalesYTD > (SELECT AVG(SalesYTD) FROM Sales.SalesPerson GROUP BY TerritoryID)
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH;


SELECT * FROM Sales.SalesTerritory;
SELECT * FROM Sales.SalesPerson;

------------------------------------------------------------------------------------------------------------------------
-- 5.  Crear un cursor que recorra todos los productos con precio mayor a 500 y los copie a una tabla temporal 
--     solo si su peso no es NULL.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #ProductosConPeso(
	ProductID INT
);

DECLARE @id INT;
DECLARE @precio MONEY;
DECLARE @peso DECIMAL(10,2);

DECLARE Cursor_PesoProductos CURSOR
FOR
	SELECT
		ProductID, ListPrice, Weight
	FROM
		#ProductosTemp

OPEN Cursor_PesoProductos
FETCH NEXT FROM Cursor_PesoProductos
INTO @id, @precio, @peso
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @peso IS NOT NULL
		BEGIN
			INSERT INTO
				#ProductosConPeso
			SELECT @id
		END
		FETCH NEXT FROM Cursor_PesoProductos
		INTO @id, @precio, @peso
END
CLOSE Cursor_PesoProductos
DEALLOCATE Cursor_PesoProductos;
SELECT * FROM #ProductosConPeso;

------------------------------------------------------------------------------------------------------------------------
-- 6.  Utilizar un cursor para recorrer la tabla `Sales.SalesOrderHeader` y almacenar en una tabla temporal aquellos 
--     pedidos cuyo subtotal supere los 50000 y sean del año 2013.
--Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #HighValueSales2013(
	SalesOrderID INT,
	SubTotal MONEY);

DECLARE @orderid INT;
DECLARE @subtotal MONEY;
DECLARE @anio INT;
	
DECLARE Cursor_SalesHeader CURSOR
FOR
	SELECT 
		SalesOrderID, SubTotal, YEAR(OrderDate)
	FROM
		Sales.SalesOrderHeader

OPEN Cursor_SalesHeader
FETCH NEXT FROM Cursor_SalesHeader
INTO
	@orderid, @subtotal, @anio

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @anio = 2013 AND @subtotal > 50000
		BEGIN
			INSERT INTO #HighValueSales2013
			SELECT @orderid, @subtotal
		END
	FETCH NEXT FROM Cursor_SalesHeader
	INTO @orderid, @subtotal, @anio
END
CLOSE Cursor_SalesHeader
DEALLOCATE Cursor_SalesHeader;

SELECT * FROM #HighValueSales2013;

------------------------------------------------------------------------------------------------------------------------
-- 7.  Mostrar para cada empleado su salario, el promedio general y cuánto se desvía del mismo (usando OVER).
--Tablas: HumanResources.EmployeePayHistory
------------------------------------------------------------------------------------------------------------------------

SELECT
	BusinessEntityID,
	Rate,
	AVG(Rate) OVER() AS SalarioPromedio,
	Rate - AVG(Rate) OVER() AS Desviacion
FROM
	HumanResources.EmployeePayHistory;

SELECT TOP 1 * FROM HumanResources.EmployeePayHistory;

------------------------------------------------------------------------------------------------------------------------
-- 8.  Mostrar la suma acumulada de ventas por año y producto utilizando funciones OVER y PARTITION BY.
--Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

SELECT
	YEAR(soh.OrderDate) AS [Year],
	sod.ProductID,
	sod.LineTotal,
	SUM(sod.LineTotal) OVER (
							PARTITION BY sod.ProductID, YEAR(soh.OrderDate)
							ORDER BY soh.OrderDate ASC
							ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
							) AS [VentaAcumProducto]
FROM
	Sales.SalesOrderHeader soh
JOIN
	Sales.SalesOrderDetail sod
ON
	soh.SalesOrderID = sod.SalesOrderID;

------------------------------------------------------------------------------------------------------------------------
-- 9.  Pivotear los valores de los colores de los productos por categoría, mostrando la cantidad de productos en cada color.
--Tablas: Production.Product, Production.ProductSubcategory
------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT Color FROM Production.Product;

SELECT
	ProductCategoryID,
	[Black],
	[Blue],
	[Grey],
	[Metallic Red],
	[Multi],
	[Silver],
	[Silver/Black],
	[White],
	[Yellow]
FROM (SELECT 
		psc.ProductCategoryID,
		Color,
		COUNT(*) AS Cantidad
	  FROM
		Production.Product p
	  JOIN
		Production.ProductSubcategory psc
	  ON
		p.ProductSubcategoryID = psc.ProductSubcategoryID
	  WHERE
		p.Color IS NOT NULL
	 GROUP BY
		psc.ProductCategoryID, p.Color
) AS SourceColors
PIVOT
	(SUM(Cantidad)
	FOR Color IN ([Black],
				  [Blue],
				  [Grey],
				  [Metallic Red],
				  [Multi],
				  [Silver],
				  [Silver/Black],
				  [White],
				  [Yellow])) AS PivotTable
ORDER BY
	ProductCategoryID;

------------------------------------------------------------------------------------------------------------------------
-- 10. Realizar un UNPIVOT de una tabla temporal que contenga ventas por trimestre, para mostrar los datos en formato largo.
-- Tablas: tabla temporal simulada
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #VentasTrimestrales;

CREATE TABLE #VentasTrimestrales(
	[Year] INT,
	Q1 MONEY,
	Q2 MONEY,
	Q3 MONEY,
	Q4 MONEY
);

INSERT INTO
	#VentasTrimestrales ([Year], Q1, Q2, Q3, Q4)
SELECT
	YEAR(OrderDate) as [Year],
	SUM(CASE WHEN DATEPART(QUARTER, OrderDAte) = 1 THEN SUBTOTAL ELSE 0 END) AS Q1,
	SUM(CASE WHEN DATEPART(QUARTER, OrderDAte) = 2 THEN SUBTOTAL ELSE 0 END) AS Q2,
	SUM(CASE WHEN DATEPART(QUARTER, OrderDAte) = 3 THEN SUBTOTAL ELSE 0 END) AS Q3,
	SUM(CASE WHEN DATEPART(QUARTER, OrderDAte) = 4 THEN SUBTOTAL ELSE 0 END) AS Q4
FROM
	Sales.SalesOrderHeader
GROUP BY
	Year(OrderDate)
;

SELECT * FROM #VentasTrimestrales
ORDER BY [Year];

SELECT
	[Year],
	[Trimestre],
	[Total]
FROM
	#VentasTrimestrales
UNPIVOT(
	Total FOR Trimestre IN (Q1, Q2, Q3, Q4)
) AS unpvt
ORDER BY
 [Year], [Trimestre];

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