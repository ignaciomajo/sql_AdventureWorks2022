/*
==========================================================================================
    Script: 09_user_defined_functions_and_triggers.sql
    Descripcion: Creación de funciones escalares y con valores de tabla, funciones 
                 multisentencia, triggers AFTER y validaciones. Incluye ejercicios 
                 teórico-prácticos de aplicación en la base AdventureWorks2022.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creacion: [2025-07-17]
==========================================================================================
*/


USE AdventureWorks2022;


------------------------------------------------------------------------------------------------------------------------
-- 01. Crear una función que devuelva el promedio del precio de todos los productos.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Production.fnPromedioPrecio', 'FN') IS NOT NULL
	DROP FUNCTION Production.fnPromedioPrecio;
ELSE
	PRINT 'Objeto no encontrado';
GO

CREATE FUNCTION Production.fnPromedioPrecio()
RETURNS MONEY
AS
BEGIN
	DECLARE @Promedio MONEY
	SELECT
		@Promedio = AVG(ListPrice)
	FROM
		Production.Product;
	
	RETURN @Promedio;
END;

GO

SELECT Production.fnPromedioPrecio();

GO

------------------------------------------------------------------------------------------------------------------------
-- 02. Crear una función que, dado un código de producto, devuelva el total de ventas para dicho producto. 
--     Luego, mediante una consulta, traer código y total de ventas.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, LineTotal
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Sales.ifVentaTotalProducto', 'IF') IS NOT NULL
	DROP FUNCTION Sales.ifVentaTotalProducto;
ELSE
	PRINT 'Objeto no encontrado';
GO

CREATE FUNCTION Sales.ifVentaTotalProducto(@ProductID INT)
RETURNS TABLE
AS
RETURN
	(SELECT
		ProductID,
		CAST(ROUND(SUM(LineTotal), 2) AS DECIMAL(12, 2)) AS VentaTotal
	FROM
		Sales.SalesOrderDetail
	WHERE
		ProductID = @ProductID
	GROUP BY
		ProductID);
GO

SELECT * FROM Sales.ifVentaTotalProducto(714)

GO

------------------------------------------------------------------------------------------------------------------------
-- 03. Crear una función que, dado un código, devuelva la cantidad de productos vendidos o cero si no se ha vendido.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, OrderQty
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Sales.tfQtyProdVendidos', 'TF') IS NOT NULL
	DROP FUNCTION Sales.tfQtyProdVendidos;
ELSE
	PRINT 'Objeto no encontrado';
GO

CREATE FUNCTION Sales.tfQtyProdVendidos(@ProductID INT)
RETURNS @CantidadVendida TABLE (ProductID INT, CantidadVendida INT)
AS
BEGIN
	DECLARE @CantidadProd INT
	SELECT 
		@CantidadProd = SUM(sod.OrderQty)
	FROM 
		Sales.SalesOrderDetail sod
	WHERE 
		ProductID = @ProductID;

	BEGIN
		IF @CantidadProd IS NOT NULL
			INSERT INTO @CantidadVendida(ProductID, CantidadVendida)
			VALUES (@ProductID, @CantidadProd);
		ELSE
			INSERT INTO @CantidadVendida(ProductID, CantidadVendida)
			VALUES (@ProductID, 0);
	END;
	RETURN;
END;

GO

SELECT * FROM Sales.tfQtyProdVendidos(714)

GO

------------------------------------------------------------------------------------------------------------------------
-- 04. Crear una función que devuelva el promedio de venta, luego obtener los productos cuyo precio sea inferior al promedio.
-- Tablas: Sales.SalesOrderDetail, Production.Product
-- Campos: LineTotal, ProductID, ListPrice
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Sales.fnPromedioVentas', 'FN') IS NOT NULL
	DROP FUNCTION Sales.fnPromedioVentas;
ELSE
	PRINT 'Objeto no encontrado';
GO

CREATE FUNCTION Sales.fnPromedioVentas()
RETURNS MONEY
AS
BEGIN
	DECLARE @PromedioVentas MONEY
	SELECT 
		@PromedioVentas = AVG(LineTotal)
	FROM
		Sales.SalesOrderDetail;

	RETURN @PromedioVentas;
END;

GO

SELECT 
	ProductID,
	ListPrice
FROM
	Production.Product
WHERE
	ListPrice < (SELECT Sales.fnPromedioVentas());

GO

------------------------------------------------------------------------------------------------------------------------
-- 05. Crear una función que, dado un año, devuelva nombre y apellido de los empleados que ingresaron ese año.
-- Tablas: Person.Person, HumanResources.Employee
-- Campos: FirstName, LastName, HireDate, BusinessEntityID
------------------------------------------------------------------------------------------------------------------------


IF OBJECT_ID('HumanResources.tfEmpleadosContratadosAnio', 'TF') IS NOT NULL
	DROP FUNCTION HumanResources.tfEmpleadosContratadosAnio;
ELSE
	PRINT 'Objeto no encontrado';
GO

CREATE FUNCTION  HumanResources.tfEmpleadosContratadosAnio (@Anio INT)
RETURNS @EmpleadosAnio TABLE (FirstName NVARCHAR(50), LastName NVARCHAR(50))
AS
BEGIN
	INSERT INTO @EmpleadosAnio
	SELECT
		p.FirstName,
		p.LastName
	FROM 
		Person.Person p
	JOIN
		HumanResources.Employee hr
	ON
		p.BusinessEntityID = hr.BusinessEntityID
	WHERE
		YEAR(hr.HireDate) = @Anio;
RETURN;
END;

GO

SELECT * FROM HumanResources.tfEmpleadosContratadosAnio(2009);

GO

------------------------------------------------------------------------------------------------------------------------
-- 06. Crear una función que reciba un parámetro correspondiente a un precio y que devuelva una tabla con código, 
--     nombre, color y precio de todos los productos cuyo precio sea inferior al parámetro ingresado.
-- Tablas: Production.Product
-- Campos: ProductID, Name, Color, ListPrice
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Production.ifProductosPrecioMax', 'IF') IS NOT NULL
	DROP FUNCTION Production.ifProductosPrecioMax;
ELSE
	PRINT 'Objeto no encontrado';;
GO

CREATE FUNCTION Production.ifProductosPrecioMax(@MaxPrecio DECIMAL(10,2))
RETURNS TABLE
AS
RETURN
	(SELECT
		ProductID,
		Name,
		Color,
		ListPrice
	FROM
		Production.Product
	WHERE
		ListPrice < @MaxPrecio
	);

GO

SELECT * FROM Production.ifProductosPrecioMax(100);

------------------------------------------------------------------------------------------------------------------------
-- 07. Realizar el mismo pedido que en el punto anterior pero utilizando una función multisentencia.
-- Tablas: Production.Product
-- Campos: ProductID, Name, Color, ListPrice
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Production.tfProductosPrecioMax', 'TF') IS NOT NULL
	DROP FUNCTION Production.tfProductosPrecioMax;
ELSE
	PRINT 'Objeto no encontrado';
GO

CREATE FUNCTION Production.tfProductosPrecioMax(@MaxPrecio DECIMAL(10,2))
RETURNS @ProductosPreciosMax TABLE (ProductID INT,
									Name NVARCHAR(50),
									Color NVARCHAR(15),
									ListPrice MONEY)
AS
BEGIN
	INSERT INTO @ProductosPreciosMax (ProductID, Name, Color, ListPrice)
	(SELECT
		ProductID,
		Name,
		Color,
		ListPrice
	FROM
		Production.Product
	WHERE
		ListPrice < @MaxPrecio
	);

	RETURN;
END

GO

SELECT * FROM Production.tfProductosPrecioMax(100);

GO

------------------------------------------------------------------------------------------------------------------------
-- 08. Clonar estructura (ProductID, ListPrice) y datos de la tabla Production.Product en una tabla llamada Productos.
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS dbo.Productos;

CREATE TABLE dbo.Productos(
	ProductID INT PRIMARY KEY,
	ListPrice MONEY
	);

INSERT INTO dbo.Productos(ProductID, ListPrice)
SELECT
	ProductID,
	ListPrice
FROM
	Production.Product;

GO

------------------------------------------------------------------------------------------------------------------------
-- 09. Crear un trigger sobre la tabla Productos llamado TR_ActualizaPrecios donde actualice la tabla #HistoricoPrecios 
--     con los cambios de precio.
-- Tablas: Productos
-- Campos: ProductID, ListPrice 
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #HistoricoPrecios;

CREATE TABLE #HistoricoPrecios(
	ProductID INT,
	ListPrice MONEY,
	ModifiedDate DATE
);

INSERT INTO #HistoricoPrecios(ProductID, ListPrice, ModifiedDate)
SELECT *, GETDATE() FROM dbo.Productos;

GO

IF OBJECT_ID('dbo.TR_ActualizarPrecio', 'TR') IS NOT NULL
	DROP TRIGGER dbo.TR_ActualizacionPrecio;
ELSE
	PRINT 'Objeto no encontrado';
GO 

CREATE TRIGGER dbo.TR_ActualizacionPrecio ON dbo.Productos
AFTER UPDATE
AS
BEGIN
	INSERT INTO #HistoricoPrecios(ProductID, ListPrice, ModifiedDate)
	SELECT *, GETDATE() FROM INSERTED;
END
;

UPDATE dbo.Productos
SET ListPrice = 1520.52
WHERE ProductID = 999;

SELECT * FROM #HistoricoPrecios
WHERE ProductID = 999;

GO

------------------------------------------------------------------------------------------------------------------------
-- 10. Adaptar el trigger del punto anterior donde valide que el precio no pueda ser negativo.
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.TR_ActualizacionPrecioNeg', 'TR') IS NOT NULL
	DROP TRIGGER dbo.TR_ActualizacionPrecioNeg;
ELSE
	PRINT 'Objeto no encontrado';
GO 

CREATE TRIGGER dbo.TR_ActualizacionPrecioNeg ON dbo.Productos
INSTEAD OF UPDATE
AS
BEGIN
	IF EXISTS(
			SELECT 1
			FROM INSERTED
			WHERE ListPrice < 0)
		BEGIN
			ROLLBACK TRANSACTION;
			RAISERROR('ListPrice no puede contener valores negativos', 16, 1);
		END
	ELSE
		BEGIN
			UPDATE 
				p
			SET 
				p.ListPrice = i.ListPrice
			FROM 
				dbo.Productos p
			JOIN
				INSERTED i
			ON
				p.ProductID = i.ProductID;

			INSERT INTO #HistoricoPrecios(ProductID, ListPrice, ModifiedDate)
			SELECT *, GETDATE() FROM INSERTED;
		END;
END;

GO

UPDATE dbo.Productos
SET ListPrice = 1520.52
WHERE ProductID = 999;

SELECT * FROM #HistoricoPrecios
WHERE ProductID = 999;

GO

------------------------------------------------------------------------------------------------------------------------
-- 11. Crear una función escalar que, dado un ProductID, devuelva el nombre del producto o 'No encontrado' si no existe.
-- Tablas: Production.Product
-- Campos: ProductID, Name
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Production.fnNombreProducto', 'FN') IS NOT NULL
	DROP FUNCTION Production.fnNombreProducto;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION Production.fnNombreProducto(@ProductID INT)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @NombreProducto NVARCHAR(50)
	SELECT @NombreProducto = Name FROM Production.Product WHERE ProductID = @ProductID

	IF @NombreProducto IS NULL
		BEGIN
			SET @NombreProducto = 'Producto no encontrado';
		END;
	
	RETURN @NombreProducto;
END;
GO

SELECT Production.fnNombreProducto(714)

GO

------------------------------------------------------------------------------------------------------------------------
-- 12. Crear una función que, dado un nombre de subcategoría, devuelva cuántos productos existen en ella.
-- Tablas: Production.Product, Production.ProductSubcategory
-- Campos: Name, ProductSubcategoryID
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Production.ifProductosSubcategoria', 'IF') IS NOT NULL
	DROP FUNCTION Production.ifProductosSubcategoria;
ELSE
	PRINT 'Objeto no encontrado';

GO


CREATE FUNCTION Production.ifProductosSubcategoria(@ProductSubcategoryID INT)
RETURNS TABLE
AS
RETURN
	(SELECT 
		p.ProductSubcategoryID, COUNT(*) AS [Cantidad Productos]
		FROM 
			Production.Product p
		WHERE 
			p.ProductSubcategoryID = @ProductSubcategoryID
		GROUP BY
			p.ProductSubcategoryID);

GO

SELECT * FROM Production.ifProductosSubcategoria(13)

------------------------------------------------------------------------------------------------------------------------
-- 13. Crear una función escalar que, dado un año, devuelva la cantidad total de órdenes de venta en ese año.
-- Tablas: Sales.SalesOrderHeader
-- Campos: OrderDate
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Sales.fnQtyAnualOrders', 'FN') IS NOT NULL
	DROP FUNCTION Sales.fnQtyAnualOrders;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION Sales.fnQtyAnualOrders(@Anio INT)
RETURNS INT
AS
BEGIN
	DECLARE @OrdersQty INT
	SELECT @OrdersQty = COUNT(*)
	FROM
		Sales.SalesOrderHeader
	WHERE
		YEAR(OrderDate) = @Anio;

	RETURN @OrdersQty;
END;

GO

SELECT Sales.fnQtyAnualOrders(2013);

GO

------------------------------------------------------------------------------------------------------------------------
-- 14. Crear una función que devuelva la cantidad de productos por color, como tabla.
-- Tablas: Production.Product
-- Campos: Color
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Production.ifQtyProductosColor', 'IF') IS NOT NULL
	DROP FUNCTION Production.ifQtyProductosColor;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION Production.ifQtyProductosColor()
RETURNS TABLE
AS
RETURN
	(SELECT
		Color,
		COUNT(*) AS QtyProductos
	 FROM
		Production.Product
	 GROUP BY
		Color);

GO

SELECT * FROM Production.ifQtyProductosColor();

GO

------------------------------------------------------------------------------------------------------------------------
-- 15. Crear una tabla #HistorialBonificaciones y un trigger que registre cualquier actualización en el campo Bonus 
--     de la tabla Sales.SalesPerson.
-- Tablas: Sales.SalesPerson
-- Campos: Bonus
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #HistorialBonificaciones;

CREATE TABLE #HistorialBonificaciones(
	BusinessEntityID INT,
	Bonus MONEY,
	ModifiedDate DATE
);

GO

IF OBJECT_ID('Sales.TR_ModificacionesBonus', 'TR') IS NOT NULL
	DROP TRIGGER Sales.TR_ModificacionesBonus;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE TRIGGER Sales.TR_ModificacionesBonus ON Sales.SalesPerson
AFTER UPDATE
AS
BEGIN
	INSERT INTO #HistorialBonificaciones(BusinessEntityID, Bonus, ModifiedDate)
	SELECT BusinessEntityID, Bonus, GETDATE() FROM INSERTED;
END;

GO

------------------------------------------------------------------------------------------------------------------------
-- 16. Crear una función multisentencia que devuelva los productos con más de 100 unidades en stock total.
-- Tablas: Production.ProductInventory
-- Campos: ProductID, Quantity
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Production.tfOver100StockProductos', 'TF') IS NOT NULL
	DROP FUNCTION Production.tfOver100StockProductos;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION Production.tfOver100StockProductos()
RETURNS @Over100StockProductos TABLE (ProductID INT,
									StockQty INT)
AS
BEGIN
	INSERT INTO @Over100StockProductos(ProductID, StockQty)
	SELECT
		ProductID,
		Quantity
	FROM
		Production.ProductInventory
	WHERE
		Quantity > 5;
	
	RETURN;

END;

GO

SELECT * FROM Production.tfOver100StockProductos();

GO

------------------------------------------------------------------------------------------------------------------------
-- 17. Crear un trigger que impida eliminar productos cuyo precio sea mayor a 1000.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Production.TR_ProductosAltoValor', 'TR') IS NOT NULL
	DROP TRIGGER Production.TR_ProductosAltoValor;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE TRIGGER Production.TR_ProductosAltoValor ON Production.Product
INSTEAD OF DELETE
AS
BEGIN
	IF EXISTS(SELECT 1
			  FROM INSERTED
			  WHERE ListPrice > 1000)
		BEGIN
			PRINT 'No es posible eliminar productos con ListPrice superior a 1000';
			ROLLBACK;
		END;
	ELSE
		BEGIN
			DELETE FROM Production.Product
			FROM Production.Product p 
			JOIN
			DELETED d
			ON
			p.ProductID	= d.ProductID;
		END;
END;

GO

------------------------------------------------------------------------------------------------------------------------
-- 18. Crear una función que reciba un año y un mes y devuelva la cantidad de empleados que ingresaron en ese período.
-- Tablas: HumanResources.Employee
-- Campos: HireDate
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('HumanResources.fnEmpleadosContratadosPeriodo', 'FN') IS NOT NULL
	DROP FUNCTION HumanResources.fnEmpleadosContratadosPeriodo;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION HumanResources.fnEmpleadosContratadosPeriodo(@Anio INT, @Mes INT)
RETURNS INT
AS
BEGIN
	DECLARE @CantidadEmpleadosContratados INT
	SELECT 
		@CantidadEmpleadosContratados = COUNT(*)
	FROM
		HumanResources.Employee
	WHERE
		YEAR(HireDate) = @Anio
		AND
		MONTH(HireDate) = @Mes;
	
	RETURN @CantidadEmpleadosContratados;
END;

GO

SELECT HumanResources.fnEmpleadosContratadosPeriodo(2009, 1);

GO

------------------------------------------------------------------------------------------------------------------------
-- 19. Crear una función de tabla que devuelva los productos que no han sido vendidos.
-- Tablas: Production.Product, Sales.SalesOrderDetail
-- Campos: ProductID
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Production.ifProductosNoVendidos', 'IF') IS NOT NULL
	DROP FUNCTION Production.ifProductosNoVendidos;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION Production.ifProductosNoVendidos()
RETURNS TABLE
AS
RETURN
	(SELECT 
		ProductID
	 FROM
		Production.Product
	 WHERE
		ProductID NOT IN (SELECT DISTINCT
							ProductID
						  FROM
							Sales.SalesOrderDetail));

GO

SELECT * FROM Production.ifProductosNoVendidos();

GO

------------------------------------------------------------------------------------------------------------------------
-- 20. Crear un trigger que registre en la tabla #Eliminaciones los productos eliminados de la tabla Productos, 
--     incluyendo la fecha de eliminación.
-- Tablas: Productos
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #Eliminaciones;

CREATE TABLE #Eliminaciones(
	ProductID INT,
	DeleteDate DATE
);

GO

IF OBJECT_ID('Production.TR_EliminacionProductos', 'TR') IS NOT NULL
	DROP TRIGGER Production.TR_EliminacionProductos;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE TRIGGER Production.TR_EliminacionProductos ON Production.Product
AFTER DELETE
AS
BEGIN
	INSERT INTO #Eliminaciones(ProductID, DeleteDate)
	SELECT ProductID, GETDATE() FROM DELETED;
END;

GO

------------------------------------------------------------------------------------------------------------------------
-- 21. Crear una función que reciba un BusinessEntityID y devuelva el nombre completo del contacto asociado 
--     (FirstName + LastName).
-- Tablas: Person.Person
-- Campos: BusinessEntityID, FirstName, LastName
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Person.fnBuscarNombreContacto', 'FN') IS NOT NULL
	DROP FUNCTION Person.fnBuscarNombreContacto;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION Person.fnBuscarNombreContacto(@BusinessEntityID INT)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @NombreCompleto NVARCHAR(100)
	SELECT
		@NombreCompleto = CONCAT(FirstName, ' ', LastName)
	FROM
		Person.Person
	WHERE
		BusinessEntityID = @BusinessEntityID;
	
	RETURN @NombreCompleto;
END;

GO

SELECT Person.fnBuscarNombreContacto(242);

GO

------------------------------------------------------------------------------------------------------------------------
-- 22. Crear una función escalar que devuelva el total de productos cuyo precio sea mayor al promedio general.
-- Tablas: Production.Product
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------


IF OBJECT_ID('Production.fnQtyProductosAltovalor', 'FN') IS NOT NULL
	DROP FUNCTION Production.fnQtyProductosAltovalor;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION Production.fnQtyProductosAltovalor()
RETURNS INT
AS
BEGIN
	DECLARE @QtyProductosAltovalor INT
	SELECT
		@QtyProductosAltoValor = COUNT(*)
	FROM
		Production.Product
	WHERE
		ListPrice > (SELECT AVG(ListPrice) FROM Production.Product);

	RETURN @QtyProductosAltoValor;
END;

GO

SELECT Production.fnQtyProductosAltovalor();

------------------------------------------------------------------------------------------------------------------------
-- 23. Crear una función que devuelva los cinco productos más vendidos.
-- Tablas: Sales.SalesOrderDetail
-- Campos: ProductID, OrderQty
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Sales.ifProductosMasVendidos', 'IF') IS NOT NULL
	DROP FUNCTION Sales.ifProductosMasVendidos;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION Sales.ifProductosMasVendidos()
RETURNS TABLE
AS
RETURN
	(SELECT TOP(5)
		ProductID,
		SUM(OrderQty) AS [Cantidad Vendida]
	FROM
		Sales.SalesOrderDetail
	GROUP BY
		ProductID
	ORDER BY
		SUM(OrderQty) DESC);

GO

SELECT * FROM Sales.ifProductosMasVendidos();

GO

------------------------------------------------------------------------------------------------------------------------
-- 24. Crear una función que reciba un valor de OrderQty y devuelva las órdenes con mayor cantidad que ese valor.
-- Tablas: Sales.SalesOrderDetail
-- Campos: OrderQty
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('Sales.ifSalesOverQty', 'IF') IS NOT NULL
	DROP FUNCTION Sales.ifSalesOverQty;
ELSE
	PRINT 'Objeto no encontrado';

GO

CREATE FUNCTION Sales.ifSalesOverQty(@MinQty INT)
RETURNS TABLE
AS
RETURN
	(SELECT
		sod.SalesOrderID
	FROM
		Sales.SalesOrderDetail sod
	WHERE
		OrderQty > @MinQty);

GO

SELECT * FROM Sales.ifSalesOverQty(35);

GO


-- =====================================================================================================================