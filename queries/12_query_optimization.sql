/*
==========================================================================================
    Script: 12_query_optimization.sql
    Descripci�n: Identificaci�n y aplicaci�n de mejoras en el rendimiento de consultas SQL,
				 an�lisis de planes de ejecuci�n, uso de �ndices, reducci�n de costos de 
				 CPU/I/O y reescritura de queries ineficientes.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creaci�n: 2025-07-21
==========================================================================================
*/


USE AdventureWorks2022;
SET STATISTICS TIME ON;


------------------------------------------------------------------------------------------------------------------------
-- 1. Mostrar todos los pedidos realizados en el a�o 2013.
-- Tabla: Sales.SalesOrderHeader
-- Campos: SalesOrderID, OrderDate, CustomerID
-- Objetivo: Evaluar impacto de filtros sobre columnas no indexadas.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

  Generaci�n de �ndice sobre la columna OrderDate. Esta columna es comunmente utilizada en filtros en consultas de negocio
  reales. Adem�s, el filtro por fechas es SARGable, lo que permite en aprovechamiento de indices, mejorando significativamente
  el desempe�o.

=======================================================================================================================*/

SELECT 
	SalesOrderID, OrderDate, CustomerID, SubTotal
FROM
	Sales.SalesOrderHeader
WHERE
	OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01';

/*
-- OBSERVACIONES

Tiempo de ejecuci�n sin �ndice
 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 150 ms.

Execution Plan
Clustered Index Scan
Cost 100%
0.016s

Index Assistant sugiere �ndice en OrderDate INCLUDE CustomerID y SubTotal
*/


CREATE NONCLUSTERED INDEX IX_SOH_OrderDate
ON Sales.SalesOrderHeader(OrderDate)
INCLUDE (CustomerID, SubTotal);

SELECT 
	SalesOrderID, OrderDate, CustomerID, SubTotal
FROM
	Sales.SalesOrderHeader
WHERE
	OrderDate >= '2013-01-01' AND OrderDate < '2014-01-01';

/*
-- OBSERVACIONES: CONSULTA INDEXADA

Tiempo de ejecuci�n:

 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 74 ms.

El tiempo total de CPU se reduce a 0 (o demasiado peque�o para ser medido) y el tiempo real transcurrido (elapsed time) se reduce a la mitad.

Execution Plan

Index Seek
Cost 100%
0.008s (tambi�n reducido a la mitad)
*/

------------------------------------------------------------------------------------------------------------------------
-- 2. Mostrar las �rdenes cuyo monto total supere los $10000.
-- Tabla: Sales.SalesOrderHeader
-- Campos: SalesOrderID, TotalDue
-- Objetivo: Analizar rendimiento de filtros sobre columnas num�ricas.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

El Index Assistant sugiere que la creaci�n de un �ndice sobre la columna TotalDue, generar�a un impacto de mejora del
95.50% en la consulta. Sin embargo, en Tablas de Hechos, tener demasiados �ndices resulta costoso de mantener y 
almacenar. Dado que, la cardinalidad en TotalDue ser� cercana a 1:1, se decide no crear un �ndice para esta columna.

=======================================================================================================================*/

SELECT
	SalesOrderID, TotalDue
FROM
	Sales.SalesOrderHeader
WHERE
	TotalDue > 10000;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n sin �ndice:
 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 45 ms.

Execution Plan:
Clustered Index Scan
Cost 99%
0.008s
*/

------------------------------------------------------------------------------------------------------------------------
-- 3. Mostrar los productos que contienen "Mountain" en el nombre.
-- Tabla: Production.Product
-- Campos: ProductID, Name
-- Objetivo: Observar impacto del uso de LIKE con comodines en el rendimiento.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

La base de datos ya contaba con un �ndice sobre el nombre de los productos (AK_Product_Name). Por esta raz�n, se hace
un Index Scan en vez de un Clustered Index Scan.
La consulta en s� no es SARGable ya que para encontrar realmente todos los productos que tengan la palabra 'Mountain'
en su nombre, es necesario utilizar el caracter comod�n (%) a ambos lados. Sin embargo, el motor utiliza el �ndice para
realizar la b�squeda en vez de escanear la tabla.

=======================================================================================================================*/

SELECT
	ProductID, Name
FROM
	Production.Product
WHERE
	Name LIKE '%Mountain%';

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 17 ms.

Execution Plan:
Index Scan [AK_Product_Name]
Cost 100%
0.000s
*/

------------------------------------------------------------------------------------------------------------------------
-- 4. Mostrar los 10 productos m�s caros.
-- Tabla: Production.Product
-- Campos: ProductID, Name, ListPrice
-- Objetivo: Analizar uso de TOP y ORDER BY en combinaci�n con �ndices.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

Se observa que el uso de TOP y ORDER BY, conllevan el 46% del costo de la consulta. Esto es prueba de que el ordenamiento
es una operaci�n costosa que solo debe ser utilizada en casos en los que realmente es necesaria.
El Index Assistant no sugiere ningun �ndice. Dado que no se est�n utilizando filtros, el motor necesita escanear toda
la tabla, a pesar de contar con el �ndice en el nombre, a diferencia de la consulta anterior, decide no utilizarlo.
=======================================================================================================================*/

SELECT TOP 10
	ProductID,
	Name,
	ListPrice
FROM
	Production.Product
ORDER BY
	ListPrice DESC;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 2 ms.

Execution Plan:
Clustered Index Scan
Cost 54%
0.001s

Sort (Top N Sort)
Cost 46%
0.001s
*/

------------------------------------------------------------------------------------------------------------------------
-- 5. Mostrar la cantidad de productos por categor�a.
-- Tablas: Production.Product, Production.ProductSubcategory, Production.ProductCategory
-- Objetivo: Revisi�n del uso de agregaciones e �ndices en columnas JOIN.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

Al crear �ndices sobre las claves for�neas, el tiempo de ejecuci�n var�a solo en 2ms (elapsed time).
La mayor diferencia se observa en la distribuci�n del costo de la consulta. En la primera (consulta sin �ndices)
el JOIN ocupaba el 31% del costo total de la consulta, mientras que, al utilizar indices, el costo se concentra en el 
escaneo de las tablas, y no en MATCH necesario para crear los JOINS, ya que para estos se utilizan los �ndices almacenados

=======================================================================================================================*/

SELECT
	pc.ProductCategoryID,
	COUNT(*) AS [Cantidad Productos]
FROM
	Production.Product p
JOIN
	Production.ProductSubcategory psc
ON
	p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN
	Production.ProductCategory pc
ON
	psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY
	pc.ProductCategoryID;


/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 17 ms.

Execution Plan:
Clustered Index Scan [ProductSubcategory]
Cost 5%
0.000s

Clustered Index Seek [ProductCategory]
Cost 13%
0.000s

Clustered Index Scan [Product]
Cost 30%
0.001s

Hash Match (Inner Join)
Cost 31%
0.003s

Sort
Cost 21%
0.003s
*/

SELECT TOP 1 * FROM Production.Product;

CREATE NONCLUSTERED INDEX IX_Product_ProdSubCatID
ON Production.Product(ProductSubcategoryID)
INCLUDE
	(Name, ProductNumber, ListPrice);

CREATE NONCLUSTERED INDEX IX_ProductSubcategory_CatID
ON Production.ProductSubcategory(ProductCategoryID)
INCLUDE
	(Name);


SELECT
	pc.ProductCategoryID,
	COUNT(*) AS [Cantidad Productos]
FROM
	Production.Product p
JOIN
	Production.ProductSubcategory psc
ON
	p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN
	Production.ProductCategory pc
ON
	psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY
	pc.ProductCategoryID;


/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 15 ms.

Execution Plan:
Index Seek [ProductSubcategory]
Cost 15%
0.000s

Clustered Index Scan [ProductCategory]
Cost 13%
0.001s

Index Seek [Product]
Cost 66%
0.001s

Nested Loops (Inner Join)
Cost 1%
0.001s

Nested Loops (Inner Join)
Cost 5%
0.001s

Stream Aggregate (Aggregate)
Cost 1%
0.001s
*/
------------------------------------------------------------------------------------------------------------------------
-- 6. Contar las �rdenes por territorio.
-- Tabla: Sales.SalesOrderHeader
-- Campos: TerritoryID
-- Objetivo: Optimizar COUNT(*) con GROUP BY.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

La creaci�n del �ndice sobre la clave for�nea TerritoryID, produjo una reducci�n del tiempo de ejecucion (elapsed time)
de aproximadamente 25%. Inicialmente, la agregaci�n ocupaba el 30% del costo, con un tiempo de CPU ejecucion de 0.021 s,
mientras que, al crear el indice, el costo de la consulta de concentra en el escaneo del �ndice (92%), dejando solo el
8% del costo en la agregaci�n.
Dado que evaluar las ventas seg�n el territorio es una operaci�n com�n de negocios, se conserva el indice creado.

=======================================================================================================================*/

SELECT
	TerritoryID,
	COUNT(*) AS [Cantidad Ventas]
FROM
	Sales.SalesOrderHeader
GROUP BY
	TerritoryID;


/*
--OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 42 ms.

Execution Plan:
Clustered Index Scan
Cost 70%
0.014s

Hash Match (Aggregate)
Cost 30%
0.021s
*/

SELECT TOP 1 * FROM Sales.SalesOrderHeader;

CREATE NONCLUSTERED INDEX IX_SOH_TerritoryID
ON Sales.SalesOrderHeader(TerritoryID)
INCLUDE
	(OrderDate, DueDate, ShipDate, Status, SalesPersonID, SubTotal, TotalDue);


SELECT
	TerritoryID,
	COUNT(*) AS [Cantidad Ventas]
FROM
	Sales.SalesOrderHeader
GROUP BY
	TerritoryID;

/*
--OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 15 ms,  elapsed time = 31 ms.

Execution Plan:
Index Scan
Cost 92%
0.008s

Stream Aggregate (Aggregate)
Cost 8%
0.011s
*/

------------------------------------------------------------------------------------------------------------------------
-- 7. Mostrar las 20 �rdenes m�s recientes realizadas por clientes de California.
-- Tablas: Sales.SalesOrderHeader, Sales.Customer, Person.Person, Person.StateProvince
-- Objetivo: Explorar subconsultas y filtros por regi�n.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

Se opt� por utilizar el campo PersonID como nexo entre la compra y la regi�n en la que esta se hizo. En cuanto a las
sugerencias del Index Assistant, se decidi� la creaci�n de un �ndice sobre PersonID de la tabla Sales.Customer debido
a que esta es una tabla dimensional, lo que permiti� acelerar los tiempos de consulta, sin incrementar excesivamente 
los costos de mantenimiento.

=======================================================================================================================*/

-- SELECT TOP 1 * FROM Sales.SalesOrderHeader;
-- SELECT PersonID FROM Sales.Customer;
-- SELECT TOP 1 * FROM Person.Person;
-- SELECT TOP 10 * FROM Person.StateProvince;
-- SELECT TOP 10 * FROM Person.BusinessEntityAddress;
-- SELECT TOP 10 * FROM Person.Address;

SELECT TOP 20
	soh.SalesOrderID,
	soh.OrderDate,
	soh.CustomerID,
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [Customer FullName],
	psp.Name AS [State Province],
	soh.TotalDue
FROM
	Sales.SalesOrderHeader soh
JOIN
	Sales.Customer sc
ON
	soh.CustomerID = sc.CustomerID
JOIN
	Person.BusinessEntityAddress bea
ON
	soh.BillToAddressID = bea.AddressID
JOIN
	Person.Address pa
ON
	pa.AddressID = bea.AddressID
JOIN
	Person.StateProvince psp
ON
	pa.StateProvinceID = psp.StateProvinceID
JOIN
	Person.Person pp
ON
	bea.BusinessEntityID = pp.BusinessEntityID
WHERE
	psp.StateProvinceID = 9
ORDER BY
	soh.OrderDate DESC;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 114 ms.

Execution Plan

Clustered Index Scan [SalesOrderHeader]
Cost 41%
0.017s

Sort
Cost 19%
0.051s


El Index Assistant sugiere la creaci�n de un �ndice sobre Sales.SalesOrderHeader en [BillToAddressID] INCLUDE (OrderDate, CustomerID, TotalDue)
con un impacto de 57.89%
*/


SELECT TOP 20
	soh.SalesOrderID,
	soh.OrderDate,
	soh.CustomerID,
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [Customer FullName],
	psp.Name AS [State Province],
	soh.TotalDue
FROM
	Sales.SalesOrderHeader soh
JOIN
	Sales.Customer sc
ON
	soh.CustomerID = sc.CustomerID
JOIN
	Person.Person pp
ON
	pp.BusinessEntityID = sc.PersonID
JOIN
	Person.BusinessEntityAddress bea
ON
	pp.BusinessEntityID = bea.BusinessEntityID
JOIN
	Person.Address pa
ON
	bea.AddressID = pa.AddressID
JOIN
	Person.StateProvince psp
ON
	pa.StateProvinceID = psp.StateProvinceID
WHERE
	psp.StateProvinceID = 9
ORDER BY
	soh.OrderDate DESC;


/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 47 ms,  elapsed time = 101 ms.

Execution Plan:

Clustered Index Scan [SalesOrderHeader]
Cost 27%
0.010s

Hash Match (Inner Join) - Previo a Sort
Cost 22%
0.061s

Sort
Cost 15%
0.067s

El Index Assistant sugiere la creaci�n de un �ndice en Sales.Customer sobre PersonID con un impacto de 16.16%
*/

CREATE NONCLUSTERED INDEX IX_Customer_PersonID
ON Sales.Customer(PersonID);

SELECT TOP 20
	soh.SalesOrderID,
	soh.OrderDate,
	soh.CustomerID,
	CONCAT(pp.FirstName, ' ', pp.LastName) AS [Customer FullName],
	psp.Name AS [State Province],
	soh.TotalDue
FROM
	Sales.SalesOrderHeader soh
JOIN
	Sales.Customer sc
ON
	soh.CustomerID = sc.CustomerID
JOIN
	Person.Person pp
ON
	pp.BusinessEntityID = sc.PersonID
JOIN
	Person.BusinessEntityAddress bea
ON
	pp.BusinessEntityID = bea.BusinessEntityID
JOIN
	Person.Address pa
ON
	bea.AddressID = pa.AddressID
JOIN
	Person.StateProvince psp
ON
	pa.StateProvinceID = psp.StateProvinceID
WHERE
	psp.StateProvinceID = 9
ORDER BY
	soh.OrderDate DESC;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 63 ms,  elapsed time = 89 ms.

Execution Plan:
Clustered Index Scan [SalesOrderHeader]
Cost 28%
0.010s

Hash Match (Inner Join) - Previo a Sort
Cost 22%
0.056s

Sort
Cost 16%
0.062s
*/

------------------------------------------------------------------------------------------------------------------------
-- 8. Mostrar el nombre del producto y su proveedor.
-- Tablas: Production.ProductVendor, Purchasing.Vendor, Production.Product
-- Objetivo: Revisi�n de JOINs sobre m�ltiples tablas y selecci�n de campos.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 9. Listar los productos que no tienen un SpecialOffer asignado.
-- Tabla: Sales.SpecialOfferProduct
-- Objetivo: Evaluar uso de NOT EXISTS vs LEFT JOIN.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 10. Mostrar el total vendido por a�o.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Revisar funciones de agregaci�n y DATEPART.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 11. Mostrar productos vendidos m�s de 500 veces.
-- Tabla: Sales.SalesOrderDetail
-- Objetivo: Optimizar agregaci�n con filtros y columnas en �ndices.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 12. Mostrar los empleados cuyo nombre empiece con "A".
-- Tablas: Person.Person
-- Objetivo: An�lisis de LIKE con comod�n al final vs al principio.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 13. Mostrar la cantidad de vendedores activos por territorio.
-- Tablas: Sales.SalesPerson
-- Objetivo: Filtrar NULLs, aplicar COUNT y evaluar �ndices en campos JOIN.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 14. Mostrar el total de ventas por producto.
-- Tablas: Sales.SalesOrderDetail
-- Objetivo: SUM, GROUP BY y columnas incluidas en �ndices.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 15. Mostrar el promedio de descuento por cliente.
-- Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
-- Objetivo: Uso de AVG, GROUP BY, JOIN y evaluaci�n de expresiones.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 16. Mostrar los clientes con m�s de 3 pedidos en los �ltimos 2 a�os.
-- Tablas: Sales.SalesOrderHeader
-- Objetivo: Filtros temporales + subqueries o HAVING.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 17. Detectar productos con m�ltiples proveedores.
-- Tabla: Production.ProductVendor
-- Objetivo: Agrupar y filtrar con COUNT.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 18. Calcular el total de ventas para cada combinaci�n de cliente y territorio.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Evaluar composici�n de claves y rendimiento de agregaciones m�ltiples.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 19. Mostrar las 5 categor�as con m�s productos.
-- Tablas: Production.Product, Production.ProductSubcategory, Production.ProductCategory
-- Objetivo: TOP y rendimiento sobre m�ltiples niveles de JOIN.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 20. Mostrar ventas por tipo de tarjeta de cr�dito.
-- Tablas: Sales.SalesOrderHeader, Sales.CreditCard
-- Objetivo: JOIN con condiciones simples y evaluaci�n de �ndices Foreign Key.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 21. Comparar el uso de CTE y subconsulta para calcular ventas totales por cliente.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Analizar diferencias de ejecuci�n entre estructuras.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 22. Mostrar productos sin ventas en 2014.
-- Tablas: Production.Product, Sales.SalesOrderDetail, Sales.SalesOrderHeader
-- Objetivo: Revisi�n de antijoins y fechas.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 23. Identificar cuellos de botella en una consulta con m�ltiples JOINs y filtros por fechas.
-- Objetivo: Ejecutar con STATISTICS IO y TIME y analizar plan de ejecuci�n.
-- Consulta: libre.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 24. Crear un �ndice adecuado para mejorar el rendimiento de una consulta de tu elecci�n.
-- Objetivo: Identificar columnas utilizadas en WHERE, JOIN y SELECT.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/



------------------------------------------------------------------------------------------------------------------------
-- 25. Comparar el uso de �ndices existentes con FORCESEEK y FORCESCAN.
-- Tabla: A elecci�n.
-- Objetivo: Experimentar con sugerencias al optimizador.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/





--======================================================================================================================