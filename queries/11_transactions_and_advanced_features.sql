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

-- Eliminar Trigger creado en otra instancia del proyecto a modo de prueba
IF OBJECT_ID('Sales.TR_ModificacionesBonus', 'TR') IS NOT NULL
	DROP TRIGGER Sales.TR_ModificacionesBonus;

-- SELECT TOP 1 * FROM Sales.Customer;
-- SELECT TOP 1 * FROM Sales.SalesOrderHeader;
-- SELECT TOP 1 * FROM Sales.SalesOrderDetail;


BEGIN TRY
	BEGIN TRANSACTION

		-- Generar nuevo cliente
		INSERT INTO Sales.Customer(StoreID, TerritoryID,  rowguid)
		VALUES (NULL, 1, NEWID());

		-- Obtener el UNIQUEIDENTIFIER creado
		DECLARE @NewCustomerID INT = SCOPE_IDENTITY();

		-- Obtener IDs validos para generar la orden de venta
		DECLARE @BillAddressID INT = (SELECT TOP 1 AddressID FROM Person.Address);
		DECLARE @ShipMethodID INT = (SELECT TOP 1 ShipMethodID FROM Purchasing.ShipMethod);


		-- Insertar un nuevo registro de orden de compra
		INSERT INTO
			Sales.SalesOrderHeader(RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, CustomerID,
									BillToAddressID, ShipToAddressID, ShipMethodID, SubTotal, TaxAmt, Freight, rowguid, ModifiedDate)
		VALUES 
			(8, GETDATE(), DATEADD(DAY, 5, GETDATE()), GETDATE(), 5, 0, @NewCustomerID, @BillAddressID, @BillAddressID, @ShipMethodID, 
			20000, 1916, 604.4, NEWID(), GETDATE());

		-- Obtener IDs y precios validos para el registro de los detalles de la orden de compra
		DECLARE @SalesOrderID INT = SCOPE_IDENTITY()
		DECLARE @ProductID INT;
		DECLARE @SpecialOfferID INT;
		DECLARE @UnitPrice MONEY;

		SELECT TOP 1
			@ProductID = p.ProductID,
			@UnitPrice = p.ListPrice,
			@SpecialOfferID = sop.SpecialOfferID
		FROM
			Production.Product p
		JOIN
			Sales.SpecialOfferProduct sop
		ON
			p.ProductID = sop.ProductID
		WHERE
			ListPrice > 0;

		-- Insertar nuevo registro en detalles de ordenes de compra
		INSERT INTO 
			Sales.SalesOrderDetail(SalesOrderID, CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID, UnitPrice, UnitPriceDiscount,
									rowguid, ModifiedDate)
		VALUES 
			(@SalesOrderID, '9999-999C-99', 10, @ProductID, @SpecialOfferID, @UnitPrice, 0, NEWID(), GETDATE());

		COMMIT TRANSACTION;
		PRINT 'Transacción completada exitosamente';
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH;

------------------------------------------------------------------------------------------------------------------------
-- 12. Utilizar un cursor para eliminar las órdenes que tengan productos descontinuados.
-- Tablas: Sales.SalesOrderHeader, Sales.SalesOrderDetail, Production.Product
------------------------------------------------------------------------------------------------------------------------

DECLARE @CurrSalesOrderID INT;
DECLARE @Qty INT;
DECLARE @SellEndDate DATETIME;
DECLARE @OrderDate DATETIME;
DECLARE @OrderProductID INT;

DECLARE Cursor_ProductosDescontinuados CURSOR
FOR
	SELECT 
		sod.SalesOrderID, sod.OrderQty, soh.OrderDate, sod.ProductID, p.SellEndDate
	FROM
		Sales.SalesOrderDetail sod
	JOIN
		Sales.SalesOrderHeader soh
	ON
		sod.SalesOrderID = soh.SalesOrderID
	JOIN
		Production.Product p
	ON
		sod.ProductID = p.ProductID;

OPEN Cursor_ProductosDescontinuados
FETCH NEXT FROM Cursor_ProductosDescontinuados
INTO @CurrSalesOrderID, @Qty, @OrderDate, @OrderProductID, @SellEndDate

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @OrderDate > @SellEndDate
		BEGIN
			DELETE FROM Sales.SalesOrderDetail
			WHERE SalesOrderID = @CurrSalesOrderID AND ProductID = @OrderProductID
		END
	FETCH NEXT FROM Cursor_ProductosDescontinuados
	INTO @CurrSalesOrderID, @Qty, @OrderDate, @OrderProductID, @SellEndDate
END

CLOSE Cursor_ProductosDescontinuados;
DEALLOCATE Cursor_ProductosDescontinuados;

------------------------------------------------------------------------------------------------------------------------
-- 13. Calcular el ranking de productos más vendidos por año utilizando funciones OVER con RANK o DENSE_RANK.
-- Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

SELECT
	YEAR(soh.OrderDate) AS [Year],
	sod.ProductID,
	SUM(sod.LineTotal) AS [Total Vendido],
	RANK() OVER (PARTITION BY YEAR(soh.OrderDate) ORDER BY SUM(sod.LineTotal) DESC) AS [Ranking]
FROM
	Sales.SalesOrderHeader soh
JOIN
	Sales.SalesOrderDetail sod
ON
	soh.SalesOrderID = sod.SalesOrderID
GROUP BY
	YEAR(soh.OrderDate), sod.ProductID
ORDER BY
	[Year], [Ranking];

------------------------------------------------------------------------------------------------------------------------
-- 14. Mostrar por cada territorio el total vendido y su porcentaje respecto del total general usando OVER.
--Tablas: Sales.SalesTerritory, Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

SELECT
	TerritoryID,
	Name,
	SalesYTD AS [Venta Total],
	SalesYTD / SUM(SalesYTD)  OVER() * 100 AS [Porcentaje Ventas]
FROM
	Sales.SalesTerritory
ORDER BY
	[Porcentaje Ventas] DESC;

------------------------------------------------------------------------------------------------------------------------
-- 15. Simular un rollback parcial dentro de una transacción, registrando en una tabla temporal los registros no insertados.
--Tablas: a definir por el usuario
------------------------------------------------------------------------------------------------------------------------

SELECT * FROM Productos;

CREATE TABLE #NuevosProductosNoInsertados(
	ProductID INT,
	Error NVARCHAR(1000),
	ErrorTimestamp DATETIME)
	
BEGIN TRY
	BEGIN TRANSACTION

	BEGIN TRY
		INSERT INTO 
			Productos(ProductID, ListPrice)
		VALUES
			(999, 1511.13);
		SAVE TRANSACTION CHKPT1
	END TRY
	BEGIN CATCH
		INSERT INTO #NuevosProductosNoInsertados
		VALUES (999, ERROR_MESSAGE(), GETDATE())
	END CATCH

	BEGIN TRY
		INSERT INTO
			Productos(ProductID, ListPrice)
		VALUES
			(1000, 899.31)
		SAVE TRANSACTION CHKPT2
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION CHKPT1;
		INSERT INTO #NuevosProductosNoInsertados
		VALUES (1000, ERROR_MESSAGE(), GETDATE());
	END CATCH
		
	BEGIN TRY
		INSERT INTO
			Productos(ProductID, ListPrice)
		VALUES
			(714, 1000)
		SAVE TRANSACTION CHKPT3;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION CHKPT2;
		INSERT INTO #NuevosProductosNoInsertados
		VALUES (714, ERROR_MESSAGE(), GETDATE())
	END CATCH
COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	RAISERROR('No se pudo insertar ningún registro', 16, 1)
END CATCH;

SELECT * FROM #NuevosProductosNoInsertados;

------------------------------------------------------------------------------------------------------------------------
-- 16. Usar funciones OVER para calcular la media móvil de los subtotales de orden en una ventana de 3 registros.
-- Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

SELECT
	SalesOrderID,
	OrderDate,
	SubTotal,
	AVG(SubTotal) OVER (ORDER BY OrderDate
						ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS [Moving Average (3)]
FROM
	Sales.SalesOrderHeader

------------------------------------------------------------------------------------------------------------------------
-- 17. Crear un cursor que recorra los empleados y les asigne un bono según sus años de servicio. 
--     Insertar los resultados en una tabla temporal.
-- Tablas: HumanResources.Employee
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS  #BonoEmpleados;

CREATE TABLE #BonoEmpleados(
	BusinessEntityID INT,
	[Tenure (Years)] INT,
	Bono MONEY)

DECLARE @EmployeeID INT;
DECLARE @Years INT;
DECLARE @MaxDate DATE = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader)


DECLARE Cursor_EmployeeTenure CURSOR
FOR
	SELECT 
		BusinessEntityID, 
		DATEDIFF(YEAR, HireDate, @MaxDate)
	FROM
		HumanResources.Employee;

OPEN Cursor_EmployeeTenure
FETCH NEXT FROM Cursor_EmployeeTenure
INTO @EmployeeID, @Years

WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT INTO #BonoEmpleados (BusinessEntityID, [Tenure (Years)], Bono)
	SELECT
		@EmployeeID,
		@Years,
		(CASE WHEN @Years < 10 THEN 100
			  WHEN @Years BETWEEN 10 AND 15 THEN 200
			  ELSE 350 END);
	FETCH NEXT FROM Cursor_EmployeeTenure
	INTO @EmployeeID, @Years
END
CLOSE Cursor_EmployeeTenure
DEALLOCATE Cursor_EmployeeTenure;

SELECT * FROM #BonoEmpleados;


-- =====================================================================================================================