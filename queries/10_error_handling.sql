/*
==========================================================================================
    Script: 10_error_handling.sql
    Descripción: Manejo de errores en transacciones utilizando variables de sistema,
                 bloques TRY...CATCH, y comandos como RAISERROR y THROW.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-18]
==========================================================================================
*/


USE AdventureWorks2022;


------------------------------------------------------------------------------------------------------------------------
-- 1.  Realizar una división por cero y atrapar el error utilizando variables de sistema (revertir la transacción).
------------------------------------------------------------------------------------------------------------------------

BEGIN TRY
	BEGIN TRANSACTION
		UPDATE Production.Product
		SET ListPrice = ListPrice / 0
		WHERE ListPrice > 500;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT ERROR_LINE() AS ErrorEnLinea, ERROR_MESSAGE() AS Error;
END CATCH


------------------------------------------------------------------------------------------------------------------------
-- 2.  Realizar una división por cero y atrapar el error sin utilizar variables de sistema (revertir la transacción).
------------------------------------------------------------------------------------------------------------------------

BEGIN TRY
	BEGIN TRANSACTION
		BEGIN TRY
			UPDATE Production.Product
			SET ListPrice = ListPrice / 0
			WHERE ListPrice > 500;
		END TRY
		BEGIN CATCH
			PRINT 'Actualización no ejecutada';
		END CATCH
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
END CATCH

------------------------------------------------------------------------------------------------------------------------
-- 3.  Agregar al ejercicio anterior el envío de un mensaje de error utilizando RAISERROR.
------------------------------------------------------------------------------------------------------------------------

BEGIN TRY
	BEGIN TRANSACTION
		UPDATE Production.Product
		SET ListPrice = ListPrice / 0
		WHERE ListPrice > 500;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	RAISERROR('No es posible dividir por 0', 16, 1);
END CATCH

------------------------------------------------------------------------------------------------------------------------
-- 4.  Realizar una copia del punto 3 y enviar un mensaje de error utilizando THROW.
------------------------------------------------------------------------------------------------------------------------

BEGIN TRY
	BEGIN TRANSACTION
		UPDATE Production.Product
		SET ListPrice = ListPrice / 0
		WHERE ListPrice > 500;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH


------------------------------------------------------------------------------------------------------------------------
-- 5.  Eliminar todos los empleados cuyo campo `JobTitle` sea NULL. Si ocurre algún error, revertir y mostrar 
--     mensaje personalizado.
-- Tablas: HumanResources.Employee
-- Campos: JobTitle
------------------------------------------------------------------------------------------------------------------------

BEGIN TRY
	BEGIN TRANSACTION
		DELETE FROM HumanResources.Employee
		WHERE JobTitle IS NULL;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH;

------------------------------------------------------------------------------------------------------------------------
-- 6.  Insertar 5 registros inválidos en la tabla `Person.EmailAddress`con valores repetidos en `EmailAddress`. 
--     Capturar la excepción y dejar constancia en una tabla de log.
-- Tablas: Person.EmailAddress, tabla temporal de log
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #log;

CREATE TABLE #log(
	LogID INT IDENTITY(1, 1) PRIMARY KEY ,
	ErrorNum INT NOT NULL,
	Error NVARCHAR(255),
	ErrorTimeStamp DATETIME
);

BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO 
			Person.EmailAddress (BusinessEntityID, EmailAddress, rowguid, ModifiedDate)
		VALUES 
			(20778, 'ignacio@adventure-works.com', '012BBEBE-FC99-4C4E-B4BC-1F21E2CF19D9', GETDATE()),
			(20779, 'ignacio@adventure-works.com', '012BBEBE-FC99-4C4E-B4BD-1F21E2CF19D9', GETDATE()),
			(20780, 'ignacio@adventure-works.com', '012BBEBE-FC99-4C4E-B4BE-1F21E2CF19D9', GETDATE()),
			(20781, 'ignacio@adventure-works.com', '012BBEBE-FC99-4C4E-B4BF-1F21E2CF19D9', GETDATE()),
			(20782, 'ignacio@adventure-works.com', '012BBEBE-FC99-4C4E-B4BG-1F21E2CF19D9', GETDATE())
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	INSERT INTO 
		#log (ErrorNum, Error, ErrorTimeStamp)
	VALUES
		(ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE());
	THROW;
END CATCH;

SELECT * FROM #log;

------------------------------------------------------------------------------------------------------------------------
-- 7.  Actualizar las fechas de contratación de todos los empleados sumándoles 1 año. Si alguna fecha queda futura 
--    al 2025, revertir y lanzar un error.
-- Tablas: HumanResources.Employee
-- Campos: HireDate
------------------------------------------------------------------------------------------------------------------------

BEGIN TRY
	BEGIN TRANSACTION
		UPDATE HumanResources.Employee
		SET HireDate = DATEADD(YEAR, 1, HireDate);
	IF EXISTS (SELECT 
					1
			   FROM 
					HumanResources.Employee
				WHERE 
					YEAR(HireDate) > YEAR(GETDATE())
				)
		BEGIN
			RAISERROR('Año de contratación no puede ser mayor al año actual', 16, 1);
		END
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH

------------------------------------------------------------------------------------------------------------------------
-- 8. Insertar un nuevo producto en `Production.Product` con un valor negativo de precio. Capturar el error y usar 
--    THROW para detener la ejecución.
--Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------

BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO 
			Production.Product(Name, ProductNumber, MakeFlag, FinishedGoodsFlag, SafetyStockLevel, ReorderPoint, StandardCost,
							   ListPrice, DaysToManufacture, SellStartDate)
		VALUES
			('Bicicleta Moderna', 'AR-9999', 0, 0, 1000, 800, 0, -10, 0, GETDATE());
		
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH;

------------------------------------------------------------------------------------------------------------------------
-- 9. Simular un proceso de backup lógico con múltiples INSERT y un DELETE sobre una tabla temporal. Si cualquiera de 
--    las operaciones falla, revertir todo y mostrar un mensaje con el error.
--Tablas: tabla temporal de prueba
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #ProductosBackUp;

CREATE TABLE #ProductosBackUp(
	ID INT PRIMARY KEY,
	Producto NVARCHAR(50) NOT NULL,
	Precio MONEY NOT NULL
);

BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO 
			#ProductosBackUp
		SELECT 
			ProductID,
			Name,
			ListPrice
		FROM
			Production.Product;
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	THROW;
END CATCH;


------------------------------------------------------------------------------------------------------------------------
-- 10. Realizar una operación entre varias tablas (INSERT + UPDATE). Si el número de filas afectadas no supera 5, 
--     revertir y notificar al usuario.
-- Tablas: a definir por el usuario
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #ProductosBackUp;

CREATE TABLE #ProductosBackUp(
	ID INT PRIMARY KEY,
	Producto NVARCHAR(50) NOT NULL,
	Precio MONEY NOT NULL
);
DECLARE @insertadas INT = 0;
DECLARE @preciosactualizados INT = 0;
DECLARE @nombresactualizados INT = 0;
DECLARE @total_afectadas INT = 0;

BEGIN TRY
	BEGIN TRANSACTION

		INSERT INTO 
			#ProductosBackUp
		SELECT
			ProductID,
			Name,
			ListPrice
		FROM
			Production.Product
		WHERE
			ListPrice < 5;

		SET @insertadas = @@ROWCOUNT;

		UPDATE 
			#ProductosBackUp
		SET
			Precio = Precio * 1.12
		WHERE
			Precio < 4;

		SET @preciosactualizados = @@ROWCOUNT;

		UPDATE
			#ProductosBackUp
		SET
			Producto = 'Descontinuado'
		WHERE
			Producto LIKE '%Bike';

		SET @nombresactualizados = @@ROWCOUNT;

		SET @total_afectadas = @insertadas + @preciosactualizados + @nombresactualizados;
		IF @total_afectadas <= 5
			BEGIN
				RAISERROR('Pocas filas fueron afectados: (%d), la transacción fue revertida', 16, 1, @total_afectadas)
			END
		ELSE
			BEGIN
				COMMIT TRANSACTION;
			END
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	INSERT INTO 
		#log (ErrorNum, Error, ErrorTimeStamp)
	VALUES
		(ERROR_NUMBER(), ERROR_MESSAGE(), GETDATE());
	THROW;
END CATCH



-- =====================================================================================================================
