/*
==========================================================================================
    Script: 07_subqueries_and_dml.sql
    Descripción: Subconsultas y operaciones DML (INSERT, UPDATE, DELETE) sobre tablas 
                 existentes y creadas. Incluye ejercicios de lógica de negocio, 
                 manipulación de datos y análisis con subconsultas.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-16]
==========================================================================================
*/


USE AdventureWorks2022;

------------------------------------------------------------------------------------------------------------------------
-- 1. Clonar estructura y datos de los campos nombre, color y precio de lista de la tabla 
--    Production.Product en una tabla llamada Productos.
-- Tablas: Production.Product
-- Campos: ProductID, Name, Color, ListPrice
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #Productos;

CREATE TABLE #Productos(
	ProductID INT PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	Color NVARCHAR(15), 
	ListPrice MONEY NOT NULL
)


INSERT INTO #Productos (ProductID, Name, Color, ListPrice)
(SELECT
	ProductID,
	Name,
	Color,
	ListPrice
 FROM
	Production.Product);

------------------------------------------------------------------------------------------------------------------------
-- 2. Aumentar un 20% el precio de lista de todos los productos.
-- Tabla: Productos
-- Campo: ListPrice
------------------------------------------------------------------------------------------------------------------------

UPDATE 
	#Productos
SET
	ListPrice = ListPrice * 1.2;

------------------------------------------------------------------------------------------------------------------------
-- 3. Aumentar un 20% el precio de lista de los productos del proveedor 1540.
-- Tablas: Productos, Purchasing.ProductVendor
-- Campos: ProductID, ListPrice, BusinessEntityID
------------------------------------------------------------------------------------------------------------------------

UPDATE
	#Productos
SET
	ListPrice = ListPrice * 1.20
WHERE
	ProductID IN (SELECT
					ppv.ProductID
				  FROM
					Purchasing.ProductVendor ppv
				  WHERE
					ppv.BusinessEntityID = 1540)

------------------------------------------------------------------------------------------------------------------------
-- 4. Eliminar los productos cuyo precio sea igual a cero.
-- Tabla: Productos
-- Campo: ListPrice
------------------------------------------------------------------------------------------------------------------------

DELETE FROM #Productos
WHERE ListPrice = 0;

------------------------------------------------------------------------------------------------------------------------
-- 5. Insertar un producto dentro de la tabla Productos con:
-- Nombre: "bicicleta mountain bike", Color: "Rojo", Precio: $4000
------------------------------------------------------------------------------------------------------------------------

INSERT INTO
	#Productos (ProductID, Name, Color, ListPrice)
VALUES
	(9999, 'Bicycle Mountain Bike', 'Red', 4000);

------------------------------------------------------------------------------------------------------------------------
-- 6. Aumentar en un 15% el precio de los productos que en su nombre contengan "Pedal".
-- Tabla: Productos
------------------------------------------------------------------------------------------------------------------------

UPDATE #Productos
SET ListPrice = ListPrice * 1.15
WHERE
	Name LIKE '%pedal%';

------------------------------------------------------------------------------------------------------------------------
-- 7. Eliminar los productos cuyo nombre comience con la letra "M".
-- Tabla: Productos
------------------------------------------------------------------------------------------------------------------------

DELETE FROM #Productos
WHERE Name LIKE 'M%';

------------------------------------------------------------------------------------------------------------------------
-- 8. Insertar en una nueva tabla temporal #VentasTopProductos los productos que superan 
--    el precio promedio general, usando subconsulta.
-- Tablas: Production.Product
-- Campos: ProductID, Name, ListPrice
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #VentaTopProductos;


CREATE TABLE #VentaTopProductos(
	ProductID INT PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	ListPrice MONEY NOT NULL
)

INSERT INTO 
	#VentaTopProductos(ProductID, Name, ListPrice)
(SELECT
	ProductID,
	Name,
	ListPrice
 FROM
	Production.Product
 WHERE
	ListPrice > (SELECT AVG(ListPrice) FROM Production.Product)
);

------------------------------------------------------------------------------------------------------------------------
-- 9. Mostrar los productos cuyo precio es mayor al promedio de su subcategoría.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

SELECT
	p1.ProductSubcategoryID,
	p1.ProductID,
	p1.Name,
	p1.ListPrice
FROM
	Production.Product p1
WHERE
	p1.ListPrice > (SELECT
						AVG(p2.ListPrice)
					FROM 
						Production.Product p2
					GROUP BY
						p2.ProductSubcategoryID
					HAVING
						p2.ProductSubcategoryID = p1.ProductSubcategoryID)

------------------------------------------------------------------------------------------------------------------------
-- 10. Insertar en una tabla temporal #SinVentas los productos que no hayan sido vendidos 
--     nunca.
-- Tablas: Production.Product, Sales.SalesOrderDetail
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #SinVentas(
	ProductID INT PRIMARY KEY
);

INSERT INTO 
	#SinVentas (ProductID)
(SELECT
	ProductID
 FROM
	Production.Product
 WHERE
	ProductID NOT IN (SELECT
						ProductID
					  FROM
						Sales.SalesOrderDetail)
)

------------------------------------------------------------------------------------------------------------------------
-- 11. Aumentar un 10% el precio de los productos cuyo color sea igual al color del 
--     producto más caro.
-- Tablas: #Productos
------------------------------------------------------------------------------------------------------------------------
UPDATE #Productos
SET ListPrice = ListPrice * 1.10
WHERE Color = (SELECT TOP 1
					Color
			   FROM
					Production.Product
			   ORDER BY
				    ListPrice DESC);

------------------------------------------------------------------------------------------------------------------------
-- 12. Eliminar los productos cuyo precio esté por debajo del 30% del precio promedio 
--     de su subcategoría.
-- Tablas: Productos
------------------------------------------------------------------------------------------------------------------------

DELETE FROM #Productos
WHERE ListPrice < (SELECT
						AVG(ListPrice) * 0.3
					FROM
						#Productos)

------------------------------------------------------------------------------------------------------------------------
-- 13. Crear una tabla #Top10Costosos con los 10 productos más caros, usando TOP y 
-- subconsulta.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #Top10Costosos;

CREATE TABLE #Top10Costosos(
	ProductID INT PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	ListPrice MONEY NOT NULL
);

INSERT INTO
	#Top10Costosos(ProductID, Name, ListPrice)
SELECT TOP 10
	ProductID,
	Name,
	ListPrice
FROM
	Production.Product p
ORDER BY
	ListPrice DESC;

------------------------------------------------------------------------------------------------------------------------
-- 14. Insertar en una tabla #ProductosDuplicados aquellos productos cuyo nombre aparezca 
--     más de una vez (duplicados por nombre).
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #ProductosDuplicados;

CREATE TABLE #ProductosDuplicados(
	Name NVARCHAR(50) NOT NULL
)

INSERT INTO
	#ProductosDuplicados(Name)
(
SELECT
	p.Name
FROM
	Production.Product p
WHERE
	p.Name IN(SELECT
				p2.Name
			  FROM
				Production.Product p2
			  GROUP BY
				p2.Name
			  HAVING
				COUNT(*) > 1)
);

------------------------------------------------------------------------------------------------------------------------
-- 15. Actualizar el precio de los productos cuyo nombre contenga la palabra "Chain" para 
--     que sea igual al promedio de los productos de su subcategoría.
-- Tablas: Productos
------------------------------------------------------------------------------------------------------------------------
UPDATE #Productos
SET ListPrice = (SELECT
					AVG(ListPrice)
				 FROM
					Production.Product p
				 GROUP BY
					p.ProductSubcategoryID
				 HAVING
					p.ProductSubcategoryID = (SELECT
												psc.ProductSubcategoryID
											  FROM
												Production.ProductSubcategory psc
											  WHERE
												Name LIKE '%Chain%')
												)
WHERE Name LIKE '%Chain%';

------------------------------------------------------------------------------------------------------------------------
-- 16. Eliminar los productos cuyo precio sea mayor que el doble del precio promedio de 
-- todos los productos.
-- Tablas: Productos
------------------------------------------------------------------------------------------------------------------------

DELETE FROM #Productos
WHERE ListPrice > (SELECT
						AVG(ListPrice) * 2
					FROM
						#Productos);

------------------------------------------------------------------------------------------------------------------------
-- 17. Insertar productos en una tabla temporal #ProductosColorPromedio que tenga solo 
--     aquellos cuyo color tenga más de 10 productos asociados.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #ProductosColorPromedio;

CREATE TABLE #ProductosColorPromedio(
	ProductID INT PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL,
	Color NVARCHAR(15)
);

INSERT INTO 
	#ProductosColorPromedio(ProductID, Name, Color)
(
SELECT
	ProductID,
	Name,
	Color
FROM
	Production.Product
WHERE
	Color IN (SELECT
				Color
			  FROM
				Production.Product
			  WHERE 
				Color IS NOT NULL
			  GROUP BY
				Color
			  HAVING
				COUNT(*) > 10)
);
	
------------------------------------------------------------------------------------------------------------------------
-- 18. Insertar productos en una tabla Productos2022 desde la tabla original Production.Product 
--     pero solo aquellos creados (o modificados) en el año 2022.
-- Tablas: Production.Product (si hay campo de fecha relevante)
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #Productos2022(
	ProductID INT PRIMARY KEY,
	Name NVARCHAR(50) NOT NULL
);

INSERT INTO
	#Productos2022 (ProductID, Name)
(
SELECT
	ProductID,
	Name
FROM
	Production.Product
WHERE
	YEAR(ModifiedDate) = 2022);

------------------------------------------------------------------------------------------------------------------------
-- 19. Crear una tabla #VentasPorCliente que contenga el ID del cliente y la suma de 
--     todas sus órdenes, solo si esa suma supera el promedio de ventas general.
-- Tablas: Sales.SalesOrderHeader
------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #VentasPorCliente(
	CustomerID INT PRIMARY KEY,
	Total MONEY NOT NULL
);

INSERT INTO
	#VentasPorCliente(CustomerID, Total)
(
SELECT
	CustomerID,
	SUM(Subtotal) AS Total
FROM
	Sales.SalesOrderHeader
GROUP BY
	CustomerID
HAVING
	SUM(Subtotal) > (SELECT AVG(SubTotal) FROM Sales.SalesOrderHeader)
);

------------------------------------------------------------------------------------------------------------------------
-- 20. Eliminar de la tabla Productos todos los productos que no tienen proveedor 
-- asignado.
-- Tablas: Productos, Purchasing.ProductVendor
------------------------------------------------------------------------------------------------------------------------


DELETE FROM #Productos
WHERE ProductID NOT IN (SELECT
							ppv.ProductID
						FROM 
							Purchasing.ProductVendor ppv);
							
------------------------------------------------------------------------------------------------------------------------
-- 21. Borrar todo el contenido de la tabla Productos sin usar DELETE.
-- Tabla: Productos
------------------------------------------------------------------------------------------------------------------------

TRUNCATE TABLE #Productos;

------------------------------------------------------------------------------------------------------------------------
-- 22. Eliminar la tabla Productos.
-- Tabla: Productos
------------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS #Productos;



-- =====================================================================================================================