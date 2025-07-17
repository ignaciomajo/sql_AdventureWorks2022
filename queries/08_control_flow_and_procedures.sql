/*
==========================================================================================
    Script: 08_control_flow_and_procedures.sql
    Descripcion: Variables locales y de sistema, control de flujo (IF, WHILE), lotes (GO) y
                 creacion/ejecucion de procedimientos almacenados con parametros.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creacion: [2025-07-15]
==========================================================================================
*/


USE AdventureWorks2022;


------------------------------------------------------------------------------------------------------------------------
-- 1. Obtener el total de ventas del año 2014 y guardarlo en una variable @TotalVentas; luego imprimir el valor.
-- Tablas: Sales.SalesOrderDetail
-- Campos: LineTotal
------------------------------------------------------------------------------------------------------------------------

DECLARE @TotalVentas DECIMAL(14,2)
SET @TotalVentas = (SELECT SUM(LineTotal) FROM Sales.SalesOrderDetail);
SELECT @TotalVentas;

------------------------------------------------------------------------------------------------------------------------
-- 2. Obtener el promedio de ventas y guardarlo en @Promedio; luego mostrar todos los productos cuyo
--    ListPrice sea menor que @PromedioVentas.
-- Tablas: Production.Product
-- Campos: ListPrice, ProductID
------------------------------------------------------------------------------------------------------------------------

DECLARE @PromedioVentas DECIMAL(12,2)
SET @PromedioVentas = (SELECT AVG(sod.LineTotal) FROM Sales.SalesOrderDetail sod);
SELECT
	ProductId,
	ListPrice
FROM
	Production.Product
WHERE
	ListPrice < @PromedioVentas;

------------------------------------------------------------------------------------------------------------------------
-- 3. Usar la variable @Promedio (calculada antes) para incrementar en 10% el ListPrice de los productos cuyo
--    ListPrice sea inferior a @Promedio.
-- Tablas: Production.Product 
-- Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------

UPDATE 
	Production.Product
SET 
	ListPrice = ListPrice * 1.10
WHERE 
	ListPrice < @PromedioVentas;

GO

------------------------------------------------------------------------------------------------------------------------
-- 4. Crear una variable de tipo tabla que contenga las categorias y subcategorias de productos y mostrarla.
-- Tablas: Production.ProductCategory, Production.ProductSubcategory
-- Campo: Name
------------------------------------------------------------------------------------------------------------------------

DECLARE @Cats_and_Subcats TABLE(
	Category NVARCHAR(50) NOT NULL,
	SubCategory NVARCHAR(50) NOT NULL
);
INSERT INTO @Cats_and_Subcats
SELECT
	c.Name, sc.Name
FROM
	Production.ProductCategory c 
JOIN
	Production.ProductSubcategory sc
ON
	c.ProductCategoryID=sc.ProductCategoryID;

SELECT * FROM @Cats_and_Subcats;

------------------------------------------------------------------------------------------------------------------------
-- 5. Calcular el promedio del ListPrice de todos los
--    productos y:
--       Si es < 500 -> PRINT 'PROMEDIO BAJO'
--       Sino         -> PRINT 'PROMEDIO ALTO'
------------------------------------------------------------------------------------------------------------------------

DECLARE @PromedioPrecio DECIMAL(12,2)
SET @PromedioPrecio = (SELECT AVG(ListPrice) FROM Production.Product)
BEGIN
	IF @PromedioPrecio < 500
		PRINT 'Promedio Bajo'
	ELSE
		PRINT 'Promedio Alto'
END
;
GO

------------------------------------------------------------------------------------------------------------------------
-- 6. Crear un procedimiento almacenado HumanResources.<NombreQueDecidas>
--    Parametro: @Inicial NVARCHAR(1)
--    Devuelve: BusinessEntityID, FirstName, LastName, EmailAddress
--    Fuente:   vista HumanResources.vEmployee
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_InicialFirstName', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_InicialFirstName;
GO

CREATE PROCEDURE dbo.STPR_InicialFirstName
	@Inicial NVARCHAR(1)
AS
BEGIN
	DECLARE @Results TABLE(
		BusinessEntityID INT NOT NULL,
		FirstName NVARCHAR(50),
		LastName NVARCHAR(50),
		EmailAddress NVARCHAR(100));

	INSERT INTO @Results
	SELECT
		BusinessEntityID,
		FirstName,
		LastName,
		EmailAddress
	FROM
		HumanResources.vEmployee
	WHERE
		FirstName LIKE @Inicial + '%';

	SELECT * FROM @Results;
END;

EXEC dbo.STPR_InicialFirstName 'A';

GO

------------------------------------------------------------------------------------------------------------------------
-- 7. Crear un procedimiento almacenado llamado ProductoVendido
--    Parametro: @ProductID INT
--    Si el producto existe en Sales.SalesOrderDetail
--         PRINT 'EL PRODUCTO HA SIDO VENDIDO'
--    Caso contrario
--         PRINT 'EL PRODUCTO NO HA SIDO VENDIDO'
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_ProductoVendido', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_ProductoVendido;
GO

CREATE PROCEDURE dbo.STPR_ProductoVendido
	@ProductID INT
AS
BEGIN
	IF EXISTS(
			  SELECT 
				ProductID
			  FROM
				Sales.SalesOrderDetail
			  WHERE
				@ProductID = ProductID
			)
		PRINT 'EL PRODUCTO HA SIDO VENDIDO';
	ELSE
		PRINT 'EL PRODUCTO NO HA SIDO VENDIDO';
END;

GO

EXEC dbo.STPR_ProductoVendido @ProductID = 999;

GO

------------------------------------------------------------------------------------------------------------------------
-- 8. Crear un procedimiento almacenado dbo.ActualizarPrecio
--    Parametros: @ProductID INT, @NuevoPrecio MONEY
--    Actualiza el ListPrice del producto indicado.
--    Tabla: Production.Product
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_ActualizarPrecio', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_ActualizarPrecio;
GO

CREATE PROCEDURE dbo.STPR_ActualizarPrecio
	@ProductID INT,
	@NuevoPrecio MONEY
AS
BEGIN
	UPDATE 
		Production.Product
	SET 
		ListPrice = @NuevoPrecio
	WHERE
		ProductID = @ProductID
END;

GO

EXEC dbo.STPR_ActualizarPrecio @ProductID = 999, @NuevoPrecio = 1520.52;

GO

------------------------------------------------------------------------------------------------------------------------
-- 9. Crear un procedimiento almacenado ProveedorProducto
--    Parametro: @ProductID INT
--    Devuelve: Nombre del proveedor, AccountNumber y UnitMeasureCode
--    Tablas: Purchasing.Vendor, Purchasing.ProductVendor, Production.Product
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_ProveedorProducto', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_ProveedorProducto;
GO

CREATE PROCEDURE dbo.STPR_ProveedorProducto
	@ProductID INT
AS
BEGIN
	SELECT
		v.Name,
		v.AccountNumber,
		pv.UnitMeasureCode
	FROM
		Purchasing.Vendor v
	JOIN
		Purchasing.ProductVendor pv
	ON
		pv.BusinessEntityID = v.BusinessEntityID
	JOIN
		Production.Product p
	ON
		pv.ProductID = p.ProductID
	WHERE
		p.ProductID = @ProductID
END;

GO

EXEC dbo.STPR_ProveedorProducto @ProductID = 711;


------------------------------------------------------------------------------------------------------------------------
-- 10. Crear un procedimiento almacenado EmpleadoSector
--     Parametro: @Nombre NVARCHAR(50)
--     Devuelve: FirstName, LastName, Department
--     Fuente:   vista HumanResources.vEmployeeDepartmentHistory
--     (No requiere coincidencia exacta en apellido)
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_EmpleadoSector', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_EmpleadoSector;
GO

CREATE PROCEDURE dbo.STPR_EmpleadoSector
	@Nombre NVARCHAR(50)
AS
BEGIN
	SELECT
		FirstName,
		LastName,
		Department
	FROM
		HumanResources.vEmployeeDepartmentHistory
	WHERE
		FirstName = @Nombre;
END;

GO

EXEC dbo.STPR_EmpleadoSector @Nombre = 'John';

GO

------------------------------------------------------------------------------------------------------------------------
-- 11. Declarar una variable @NombreProducto y asignarle el nombre de un producto existente. Imprimir un
--     mensaje con su precio si existe, o "Producto no encontrado" en caso contrario.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

DECLARE @NombreProducto NVARCHAR(50) = 'ML Bottom Bracket'
DECLARE @Precio MONEY

SELECT 
	@Precio = ListPrice
FROM
	Production.Product
WHERE
	Name = @NombreProducto

BEGIN
	IF @Precio IS NOT NULL
		PRINT @Precio
	ELSE
		PRINT 'Producto no encontrado'
END;

GO



------------------------------------------------------------------------------------------------------------------------
-- 12. Crear un procedimiento almacenado llamado ListarEmpleadosPorDepartamento
--     Parametro: @Departamento NVARCHAR(50)
--     Devuelve: FirstName, LastName, Department
-- Vistas: HumanResources.vEmployeeDepartmentHistory
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_ListarEmpleadosDpto', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_ListarEmpleadosDpto;
GO

CREATE PROCEDURE dbo.STPR_ListarEmpleadosDpto
	@Departamento NVARCHAR(50)
AS
BEGIN
	SELECT
		FirstName,
		LastName,
		Department
	FROM
		HumanResources.vEmployeeDepartmentHistory
	WHERE
		Department = @Departamento;
END;

GO

EXEC dbo.STPR_ListarEmpleadosDpto @Departamento = 'Production';

GO

------------------------------------------------------------------------------------------------------------------------
-- 13. Crear un procedimiento almacenado llamado ActualizarColores
--     Parametros: @ColorOriginal NVARCHAR(15), @ColorNuevo NVARCHAR(15)
--     Actualiza todos los productos que tengan el color @ColorOriginal y lo reemplaza por @ColorNuevo
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_ActualizarColores', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_ActualizarColores;
GO

CREATE PROCEDURE dbo.STPR_ActualizarColores
	@ColorOriginal NVARCHAR(15),
	@ColorNuevo NVARCHAR(15)
AS
BEGIN
	UPDATE 
		Production.Product
	SET
		Color = @ColorNuevo
	WHERE
		Color = @ColorOriginal;
END;

GO

EXEC dbo.STPR_ActualizarColores @ColorOriginal = 'Red', @ColorNuevo = 'Metallic Red';

GO

------------------------------------------------------------------------------------------------------------------------
-- 14. Declarar una variable de tabla @Top3Productos con campos: ProductID, Name, ListPrice.
--     Insertar en ella los 3 productos mas caros.
--     Luego imprimir su contenido.
-- Tabla: Production.Product
------------------------------------------------------------------------------------------------------------------------

DECLARE @Top3Productos TABLE(
	ProductID INT NOT NULL,
	Name NVARCHAR(50) NOT NULL,
	ListPrice MONEY NOT NULL
);

INSERT INTO @Top3Productos (ProductID, Name, ListPrice)
SELECT TOP(3)
	ProductID,
	Name,
	ListPrice
FROM
	Production.Product
ORDER BY
	ListPrice DESC;

SELECT * FROM @Top3Productos;

GO 

------------------------------------------------------------------------------------------------------------------------
-- 15. Crear un procedimiento almacenado dbo.RevisarDescuento
--     Parametro: @OrderID INT
--     Si la orden de venta tiene un descuento > 0, imprimir "La orden tiene descuento"
--     Si no, imprimir "La orden no tiene descuento"
-- Tablas: Sales.SalesOrderDetail
-- Campos: UnitPriceDiscount
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_RevisarDescuento', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_RevisarDescuento;
GO

CREATE PROCEDURE dbo.STPR_RevisarDescuento
	@OrderID INT
AS
BEGIN
	DECLARE @Descuento DECIMAL(5, 2)
	SELECT
		@Descuento = SUM(UnitPriceDiscount)
	FROM
		Sales.SalesOrderDetail sod
	WHERE
		sod.SalesOrderID = @OrderID
	GROUP BY
		sod.SalesOrderID;

	BEGIN
		IF @Descuento > 0
			PRINT 'La orden tiene descuento'
		ELSE
			PRINT 'La orden no tiene descuento'
	END;
END;

GO


EXEC dbo.STPR_RevisarDescuento @OrderID = 69408;
------------------------------------------------------------------------------------------------------------------------
-- 16. Crear un procedimiento almacenado dbo.ProductosPorRangoPrecio
--     Parametros: @MinPrecio MONEY, @MaxPrecio MONEY
--     Devuelve: ProductID, Name, ListPrice de todos los productos cuyo precio este entre esos valores.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_ProductosPorRangoPrecio', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_ProductosPorRangoPrecio;
GO

CREATE PROCEDURE dbo.STPR_ProductosPorRangoPrecio
	@MinPrecio MONEY,
	@MaxPrecio MONEY
AS
BEGIN
	SELECT
		ProductID,
		Name,
		ListPrice
	FROM
		Production.Product
	WHERE
		ListPrice BETWEEN @MinPrecio AND @MaxPrecio;
END;

GO

EXEC dbo.STPR_ProductosPorRangoPrecio @MinPrecio = 300, @MaxPrecio = 450;

GO

------------------------------------------------------------------------------------------------------------------------
-- 17. Declarar una variable de tabla @VentasTotalesCliente con CustomerID y TotalVentas.
--     Insertar en ella los 5 clientes que mas han comprado.
-- Tablas: Sales.SalesOrderHeader
-- Campos: SubTotal
------------------------------------------------------------------------------------------------------------------------

DECLARE @VentasTotalesClientes TABLE(
	CustomerID INT NOT NULL,
	TotalVentas MONEY
)

INSERT INTO @VentasTotalesClientes
SELECT TOP 5
	CustomerID,
	SUM(SubTotal)
FROM
	Sales.SalesOrderHeader
GROUP BY
	CustomerID
ORDER BY
	SUM(SubTotal) DESC;

SELECT * FROM @VentasTotalesClientes;

GO

------------------------------------------------------------------------------------------------------------------------
-- 18. Crear un procedimiento almacenado llamado VerificarEmailEmpleado
--     Parametro: @Email NVARCHAR(50)
--     Devuelve: FirstName, LastName si el email existe.
--     De lo contrario, imprimir "Email no registrado".
-- Vistas: HumanResources.vEmployee
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_VerificarEmailEmpleado', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_VerificarEmailEmpleado;
GO

CREATE PROCEDURE STPR_VerificarEmailEmpleado
	@Email NVARCHAR(50)
AS
BEGIN
	IF EXISTS (SELECT EmailAddress FROM HumanResources.vEmployee WHERE EmailAddress = @Email)
		SELECT
			FirstName,
			LastName
		FROM
			HumanResources.vEmployee
		WHERE
			EmailAddress = @Email
	ELSE
		PRINT 'Email no registrado'
END;

GO

EXEC dbo.STPR_VerificarEmailEmpleado @Email = 'rebecca0@adventure-works.com';
	
GO

------------------------------------------------------------------------------------------------------------------------
-- 19. Crear un procedimiento almacenado que reciba una letra y devuelva todos los productos cuyo nombre comience con
--     esa letra. Si no hay productos, imprimir un mensaje apropiado.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_BuscarProductoInicial', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_BuscarProductoInicial;
GO

CREATE PROCEDURE dbo.STPR_BuscarProductoInicial
	@Inicial NVARCHAR(1)
AS
BEGIN
	IF EXISTS(
		SELECT ProductID FROM Production.Product WHERE Name LIKE @Inicial + '%'
		)
		SELECT
			ProductID,
			Name,
			ListPrice
		FROM
			Production.Product	
		WHERE
			Name LIKE @Inicial + '%'
	ELSE
		PRINT 'No se han encontrado productos con esa letra: ' + @Inicial;
END;

GO

EXEC dbo.STPR_BuscarProductoInicial @Inicial = 'W';

GO

------------------------------------------------------------------------------------------------------------------------
-- 20. Declarar una variable @NombreProducto y validar si existe un producto con ese nombre.
--     Si existe, imprimir su ProductNumber; si no, imprimir "Producto no encontrado".
--     Tabla: Production.Product
------------------------------------------------------------------------------------------------------------------------

DECLARE @NombreProducto NVARCHAR(50) = 'Adjustable Race'
BEGIN	
	DECLARE @ProductNumber NVARCHAR(15)
	IF EXISTS(
		SELECT 
			Name
		FROM 
			Production.Product
		WHERE
			Name = @NombreProducto)
	SELECT
		ProductNumber
	FROM
		Production.Product
	WHERE
		Name = @NombreProducto;

	ELSE
		PRINT 'Producto no encontrado';
END;

GO


------------------------------------------------------------------------------------------------------------------------
-- 21. Crear un procedimiento almacenado ProductoDisponible
--     Parámetro: @ProductID INT
--     Devuelve: Un mensaje que indique si el producto está o no en stock.
--     Tabla: Production.ProductInventory
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_ProductoDisponible', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_ProductoDisponible;
GO

CREATE PROCEDURE dbo.STPR_ProductoDisponible
	@ProductID INT
AS
BEGIN
	DECLARE @Stock INT
	SELECT
		@Stock = Quantity
	FROM
		Production.ProductInventory
	WHERE
		ProductID = @ProductID;

	BEGIN
		IF @Stock > 0
			PRINT 'Producto disponible. Stock: ' + CAST(@Stock AS NVARCHAR(10));
		ELSE
			PRINT 'Producto no disponible en stock.';
	END;
END;

GO

EXEC dbo.STPR_ProductoDisponible @ProductID = 999;

GO

------------------------------------------------------------------------------------------------------------------------
-- 22. Declarar una variable de tabla @VentasAnuales con los campos ProductID y TotalVendido
--     Insertar en ella los productos vendidos en el año 2013, junto con el total de unidades vendidas.
--     Tablas: Sales.SalesOrderHeader, Sales.SalesOrderDetail
------------------------------------------------------------------------------------------------------------------------

DECLARE @VentasAnuales2013 TABLE(
	ProductID INT,
	UnidadesVendidas INT,
	TotalVendido MONEY
);

INSERT INTO @VentasAnuales2013 (ProductID, UnidadesVendidas, TotalVendido)
SELECT
	sod.ProductID,
	SUM(sod.OrderQty),
	CAST(SUM(sod.LineTotal) AS DECIMAL(12, 2))
FROM
	Sales.SalesOrderHeader soh
JOIN
	Sales.SalesOrderDetail sod
ON
	soh.SalesOrderID = sod.SalesOrderID
WHERE
	soh.OrderDate BETWEEN CAST('2013-01-01' AS DATE) AND CAST('2013-12-31' AS DATE)
GROUP BY
	sod.ProductID;

SELECT * FROM @VentasAnuales2013
ORDER BY TotalVendido DESC;

GO

------------------------------------------------------------------------------------------------------------------------
-- 23. Crear un procedimiento almacenado BuscarEmpleadoPorNombre
--     Parámetro: @Nombre NVARCHAR(50)
--     Devuelve: BusinessEntityID, FirstName, LastName y JobTitle de empleados cuyo FirstName contenga el parámetro.
--     Fuente: vista HumanResources.vEmployee
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_BuscarEmpleadoPorNombre', 'P') IS NOT  NULL
	DROP PROCEDURE dbo.STPR_BuscarEmpleadoPorNombre;
GO

CREATE PROCEDURE dbo.STPR_BuscarEmpleadoPorNombre
	@Nombre NVARCHAR(50)
AS
BEGIN
	SELECT
		BusinessEntityID,
		FirstName,
		LastName,
		JobTitle
	FROM
		HumanResources.vEmployee
	WHERE
		FirstName LIKE '%' + @Nombre + '%'
END;

GO

EXEC dbo.STPR_BuscarEmpleadoPorNombre @Nombre = 'Al';

GO

------------------------------------------------------------------------------------------------------------------------
-- 24. Declarar una variable @CategoriaNombre con el nombre de una categoría (ej: 'Bikes').
--     Mostrar la cantidad de productos activos en esa categoría.
--     Tablas: Production.Product, Production.ProductSubcategory, Production.ProductCategory
------------------------------------------------------------------------------------------------------------------------

DECLARE @CategoriaNombre NVARCHAR(20) = 'Bikes'

SELECT
	COUNT(*) AS ProductosDisponibles,
	@CategoriaNombre AS Categoria
FROM
	Production.Product p
JOIN
	Production.ProductSubcategory psc
ON
	p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN
	Production.ProductCategory as pc
ON
	psc.ProductCategoryID = pc.ProductCategoryID
WHERE
	pc.Name = @CategoriaNombre
	AND
	p.SellEndDate IS NULL;	

GO

------------------------------------------------------------------------------------------------------------------------
-- 25. Crear un procedimiento almacenado ResumenVentasCliente
--     Parámetro: @CustomerID INT
--     Devuelve: Total de pedidos, Total vendido y Fecha del último pedido.
--     Tabla: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

IF OBJECT_ID('dbo.STPR_ResumenVentasCliente', 'P') IS NOT NULL
	DROP PROCEDURE dbo.STPR_ResumenVentasCliente;
GO

CREATE PROCEDURE dbo.STPR_ResumenVentasCliente
	@CustomerID INT
AS
BEGIN
	SELECT
		CustomerID,
		COUNT(*) AS TotalPedidos,
		SUM(SubTotal) AS TotalVendido,
		MAX(OrderDate) AS FechaUltimoPedido
	FROM
		Sales.SalesOrderHeader
	WHERE
		CustomerID = @CustomerID
	GROUP BY
		CustomerID;
END;

GO

EXEC dbo.STPR_ResumenVentasCliente @CustomerID = 11019;

GO

-- =====================================================================================================================
