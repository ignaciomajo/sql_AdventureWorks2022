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

DROP INDEX IF EXISTS IX_SOH_OrderDate;

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

DROP INDEX IF EXISTS IX_Product_ProdSucbCatID;

CREATE NONCLUSTERED INDEX IX_Product_ProdSubCatID
ON Production.Product(ProductSubcategoryID)
INCLUDE
	(Name, ProductNumber, ListPrice);

DROP INDEX IF EXISTS IX_ProductSubcategory_CatID;

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

DROP INDEX IF EXISTS IX_SOH_TerritoryID;

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

DROP INDEX IF EXISTS IX_Customer_PersonID;

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
-- Tablas: Purchasing.ProductVendor, Purchasing.Vendor, Production.Product
-- Objetivo: Revisi�n de JOINs sobre m�ltiples tablas y selecci�n de campos.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	El motor se beneficia del �ndice creado previamente sobre la tabla Production.Product en la columna 
	ProductSubcategoryID a pesar de que esta no es utilizada en la consulta.
	La tabla Purchasing.ProductVendor ya contaba con �ndice sobre BusinessEntityID, por lo que no fue necesario generarlo
	Los costos m�s elevados de la consulta corresponden a los joins.
	El Index Assistant no devuelve ninguna sugerencia.
=======================================================================================================================*/

SELECT TOP 1 * FROM Purchasing.ProductVendor;
SELECT TOP 1 * FROM Purchasing.Vendor;

SELECT 
	p.Name, 
	pv.Name
FROM
	Production.Product p
JOIN
	Purchasing.ProductVendor ppv
ON
	p.ProductID = ppv.ProductID
JOIN
	Purchasing.Vendor pv
ON
	ppv.BusinessEntityID = pv.BusinessEntityID;


/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 60 ms.

Execution Plan:
Index Scan - IX_Product_ProdSubCatID
Cost 12%
0.0001s

Hash Match (Inner Join) 
Cost 40%
0.002s

Hash Match (Inner Join) - Previo al retorno de tabla
Cost 37%
0.003s

*/

------------------------------------------------------------------------------------------------------------------------
-- 9. Listar los productos que no tienen un SpecialOffer asignado.
-- Tabla: Sales.SpecialOfferProduct
-- Objetivo: Evaluar uso de NOT EXISTS vs LEFT JOIN.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	La principal diferencia entre ambas queries es que utilizando NOT EXISTS, el mayor coste de la consulta se concentra
	al hacer el MATCH, es decir, cuando se seleccionan las filas de Production.Product que no forman parte de 
	SpecialOfferProduct.
	Utilizando LEFT JOIN...IS NULL, el costo de la consulta esta enconcentrado al escanear las tablas, no en el filtrado.
	En este caso, el tiempo de reloj (elapsed time) es menor en la consulta NOT EXISTS, por lo que esta consulta muestra
	mejor rendimiento.
=======================================================================================================================*/

SELECT TOP 1 * FROM Sales.SpecialOfferProduct;

-- NOT EXISTS

SELECT 
	ProductID
FROM
	Production.Product p
WHERE
	NOT EXISTS (SELECT 1
				FROM Sales.SpecialOfferProduct sop
				WHERE p.ProductID = sop.ProductID);

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 30 ms

Execution Plan:
Index Scan - IX_SpecialOfferProduct_ProductID
Cost 12%
0.0000s

Index Scan - AK_Product_rowguid
Cost 16%
0.000s

Hash Match (Right Anti Semi Join) 
Cost 71%
0.001s

*/

-- LEFT JOIN

SELECT
	p.ProductID
FROM
	Production.Product p
LEFT JOIN
	Sales.SpecialOfferProduct sop
ON
	p.ProductID = sop.ProductID
WHERE
	sop.SpecialOfferID IS NULL;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 36 ms.

Execution Plan:
Clustered Index Scan - PK_Product_ProductID
Cost 64%
0.000s

Index Scan - IX_SpecialOfferProduct_ProductID
Cost 11%
0.000s

Merge Join (Left Outer Join)
Cost 23%
0.000s

*/
------------------------------------------------------------------------------------------------------------------------
-- 10. Mostrar el total vendido por a�o.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Revisar funciones de agregaci�n y DATEPART.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	Se observa que en ambas consultas, el coste esta distribuido de igual manera:
	48% para el escaneo de la tabla utilizando el �ndice creado en TerritoryID
	52% para realizar la funci�n de agregaci�n.
	Sin embargo, la consulta que utiliza DATEPART(YEAR, date) muestra mejor tiempo de ejecuci�n.
	DATEPART
	Index Scan = 0.007s
	Hash Match (Aggregate) = 0.017s
	YEAR
	Index Scan = 0.010s
	Hash Match (Aggregate) = 0.022s
=======================================================================================================================*/

SELECT
	DATEPART(YEAR, soh.OrderDate) AS [Year],
	SUM(soh.TotalDue) AS [Total]
FROM
	Sales.SalesOrderHeader soh
GROUP BY
	DATEPART(YEAR, soh.OrderDate);

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 15 ms,  elapsed time = 39 ms.

Execution Plan:
Index Scan - IX_SOH_TerritoryID
Cost 48%
0.007s


Hash Match (Aggregate)
Cost 52%
0.017s

*/

SELECT
	YEAR(soh.OrderDate) AS [Year],
	SUM(soh.TotalDue) AS [Total]
FROM
	Sales.SalesOrderHeader soh
GROUP BY
	YEAR(soh.OrderDate);

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 15 ms,  elapsed time = 36 ms.

Execution Plan:
Index Scan - IX_SOH_TerritoryID
Cost 48%
0.010s


Hash Match (Aggregate)
Cost 52%
0.022s


*/
------------------------------------------------------------------------------------------------------------------------
-- 11. Mostrar productos vendidos m�s de 500 veces.
-- Tabla: Sales.SalesOrderDetail
-- Objetivo: Optimizar agregaci�n con filtros y columnas en �ndices.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	Dado que el filtro debe hacerse de acuerdo a la agregaci�n, no es posible filtrar las filas antes de agrupar.
	El escaneo de la tabla corresponde al 83% del costo total, el cual utiliza el �ndice creado sobre
	Sales.SalesOrderDetail ProductID.
	La agregaci�n consume 17% del costo total, pero su tiempo de ejecuci�n es mayor al escaneo
	A su vez, el filtro no tiene un costo significativo, pero su tiempo de ejecuci�n es igual a la operaci�n de
	agregaci�n.
=======================================================================================================================*/

SELECT TOP 1 * FROM Sales.SalesOrderDetail;

SELECT
	ProductID,
	COUNT(*) AS [Veces Vendido]
FROM
	Sales.SalesOrderDetail
GROUP BY
	ProductID
HAVING
	COUNT(*) > 500;


/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 81 ms.

Execution Plan:
Index Scan - IX_SalesOrderDetail_ProductID
Cost 83%
0.036s


Stream Aggregate (Aggregate)
Cost 17%
0.045s

Filter
Cost 0%
0.045s

*/

------------------------------------------------------------------------------------------------------------------------
-- 12. Mostrar los empleados cuyo nombre empiece o terminen con "A".
-- Tablas: Person.Person
-- Objetivo: An�lisis de LIKE con comod�n al final vs al principio.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	Dado que ambas consultas devuelven un cantidad diferente de filas, su comparaci�n no estar� balanceada.
	Sin embargo, cabe destacar que el tiempo de ejecuci�n en CPU para la consulta que utiliza LIKE 'A%' es 0,
	mientras que aquella que usa el comod�n al principio: LIKE '%a' tiene un tiempo de ejecuci�n en CPU de 31ms
	Esto es un indicador de mayor costo de procesamiento debido a que la consulta LIKE '%a' no es SARGable.
	A pesar de esto, ambas se benefician del �ndice ya presente en la base de datos sobre la tabla Person.Person
	IX_Person_LastName_FirstName_MiddleName
=======================================================================================================================*/

SELECT
	pp.FirstName,
	pp.LastName
FROM
	Person.Person pp
JOIN
	HumanResources.Employee hr
ON
	pp.BusinessEntityID = hr.BusinessEntityID
WHERE
	pp.FirstName LIKE 'A%';

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:

(16 rows affected)
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 28 ms.

Execution Plan:
Index Scan - IX_Person_LastName
Cost 66%
0.004s

Hash Match (Inner Join)
Cost 31%
0.005s
*/

SELECT
	pp.FirstName,
	pp.LastName
FROM
	Person.Person pp
JOIN
	HumanResources.Employee hr
ON
	pp.BusinessEntityID = hr.BusinessEntityID
WHERE
	pp.FirstName LIKE '%a';

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:

(29 rows affected)
 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 69 ms.

Execution Plan:
Index Scan - IX_Person_LastName
Cost 64%
0.030s

Hash Match (Inner Join)
Cost 31%
0.032s
*/

------------------------------------------------------------------------------------------------------------------------
-- 13. Mostrar la cantidad de vendedores activos por territorio.
-- Tablas: Sales.SalesPerson
-- Objetivo: Filtrar NULLs, aplicar COUNT y evaluar �ndices.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	La consulta se beneficia del �ndice ya existente en la tabla Sales.SalesPerson sobre la columna BusinessEntityID
	El mayor costo corresponde al ordenamiento de las filas resultantes realizado por defecto, ya que no se incluye
	la cl�usula ORDER BY dentro de la consulta.
=======================================================================================================================*/

SELECT
	TerritoryID,
	COUNT(*) AS [Cantidad Vendedores]
FROM
	Sales.SalesPerson
WHERE
	TerritoryID IS NOT NULL
GROUP BY
	TerritoryID;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 23 ms

Execution Plan:
Clustered Index Scan - PK_SalesPerson_BusinessEntityID
Cost 22%
0.000s

Sort
Cost 78%
0.000s
*/

------------------------------------------------------------------------------------------------------------------------
-- 14. Mostrar el total de ventas por producto.
-- Tablas: Sales.SalesOrderDetail
-- Objetivo: SUM, GROUP BY y columnas incluidas en �ndices.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	Esta consulta resulta costosa ya que corresponde a una tabla de hechos.
	El mayor costo se concentra en el escaneo de la tabla, el cual utiliza el indice creado sobre ProductID
	No existe mayor optimizaci�n para esta consulta ya que crear un indice sobre LineTotal resultar�a en costo adicional
	de almacenamiento y mantenimiento, y en relentizaci�n al momento de escritura.
=======================================================================================================================*/

SELECT
	ProductID,
	SUM(LineTotal) AS [Total Vendido]
FROM
	Sales.SalesOrderDetail
GROUP BY
	ProductID;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 62 ms,  elapsed time = 97 ms.

Execution Plan:
Index Scan - PK_SalesPerson_BusinessEntityID
Cost 90%
0.035s

Stream Aggregate (Aggregate)
Cost 9%
0.059s
*/
------------------------------------------------------------------------------------------------------------------------
-- 15. Mostrar el promedio de descuento por cliente.
-- Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
-- Objetivo: Uso de AVG, GROUP BY, JOIN y evaluaci�n de expresiones.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	Se reduce la cantidad de filas devueltas a solo aquellas que cuenten con descuento distinto de 0.
	El uso de CTE produce un peor rendimiento que la consulta directa. 
=======================================================================================================================*/

SELECT TOP 1 * FROM Sales.SalesOrderDetail;
SELECT TOP 1 * FROM Sales.SalesOrderHeader;

SELECT
	soh.CustomerID,
	AVG(sod.UnitPriceDiscount) AS [Descuento Promedio]
FROM
	Sales.SalesOrderHeader soh
JOIN
	Sales.SalesOrderDetail sod
ON
	soh.SalesoRderID = sod.SalesOrderID
GROUP BY
	soh.CustomerID;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:

(19119 rows affected)
 SQL Server Execution Times:
   CPU time = 203 ms,  elapsed time = 283 ms.

Execution Plan:
Index Scan - IX_SOD_ProductID
Cost 28%
0.037s

Hash Match (Inner Join)
Cost 38%
0.101s

Hash Match (Aggregate)
Cost 31%
0.164s
*/

SELECT
	soh.CustomerID,
	AVG(sod.UnitPriceDiscount) AS [Descuento Promedio]
FROM
	Sales.SalesOrderHeader soh
JOIN
	Sales.SalesOrderDetail sod
ON
	soh.SalesoRderID = sod.SalesOrderID
GROUP BY
	soh.CustomerID
HAVING
	AVG(sod.UnitPriceDiscount) <> 0;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:

(351 rows affected)
 SQL Server Execution Times:
   CPU time = 156 ms,  elapsed time = 218 ms.

Execution Plan:
Index Scan - IX_SOD_ProductID
Cost 28%
0.038s

Hash Match (Inner Join)
Cost 38%
0.106s

Hash Match (Aggregate)
Cost 31%
0.164s

Filter
Cost 0%
0.170s
*/

WITH CTE_DescuentoPorCliente 
AS(
	SELECT
		soh.CustomerID,
		AVG(sod.UnitPriceDiscount) AS [Descuento Promedio]
	FROM
		Sales.SalesOrderHeader soh
	JOIN
		Sales.SalesOrderDetail sod
	ON
		soh.SalesoRderID = sod.SalesOrderID
	GROUP BY
		soh.CustomerID)

SELECT * 
FROM
	CTE_DescuentoPorCliente
WHERE
	[Descuento Promedio] <> 0;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:

(351 rows affected)
 SQL Server Execution Times:
   CPU time = 172 ms,  elapsed time = 224 ms.

Execution Plan:
Index Scan - IX_SOD_ProductID
Cost 28%
0.048s

Hash Match (Inner Join)
Cost 38%
0.118s

Hash Match (Aggregate)
Cost 31%
0.179s

Filter
Cost 0%
0.181s
*/

------------------------------------------------------------------------------------------------------------------------
-- 16. Mostrar los clientes con m�s de 3 pedidos en los �ltimos 2 a�os.
-- Tablas: Sales.SalesOrderHeader
-- Objetivo: Filtros temporales + subqueries o HAVING.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	Para una consulta SARGable se establecio una variable con la fecha de 2 a�os hacia atras desde la �ltima venta.
	La consulta al ser SARGable, se beneficia del �ndice creado sobre OrderDate, ya que los filtros de tiempo son habituales.
=======================================================================================================================*/

DECLARE @MaxDate DATE = (SELECT MAX(OrderDate) FROM Sales.SalesOrderHeader)
DECLARE @MinDate DATE = DATEADD(YEAR, -2, @MaxDate)

SELECT
	CustomerID,
	COUNT(*) AS [Cantidad Pedidos]
FROM
	Sales.SalesOrderHeader
WHERE
	OrderDate > @MinDate
GROUP BY
	CustomerID
HAVING
	COUNT(*) > 3;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:

(650 rows affected)
 SQL Server Execution Times:
   CPU time = 63 ms,  elapsed time = 164 ms.

Execution Plan:
Index Seek - IX_SOH_OrderDate
Cost 21%
0.007s


Hash Match (Aggregate)
Cost 77%
0.022s

Filter
Cost 2%
0.025s
*/

------------------------------------------------------------------------------------------------------------------------
-- 17. Detectar productos con m�ltiples proveedores.
-- Tabla: Production.ProductVendor
-- Objetivo: Agrupar y filtrar con COUNT.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	La consulta concentra la mayor parte de su costo en el escaneo de la tabla a trav�s del �ndice de su PK.
	El Index Assistant no sugiere ninguna modificaci�n.
=======================================================================================================================*/

SELECT
	ProductID,
	COUNT(*) AS [Cantidad Proveedores]
FROM
	Purchasing.ProductVendor
GROUP BY
	ProductID
HAVING
	COUNT(*) > 1;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 55 ms.

Execution Plan:
Clustered Index Scan - PK_ProductVendor_ProductID_BusinessEntityID
Cost 93%
0.000s


Stream Aggregate (Aggregate)
Cost 6%
0.000s

Filter
Cost 2%
0.000s
*/

------------------------------------------------------------------------------------------------------------------------
-- 18. Calcular el total de ventas para cada combinaci�n de cliente y territorio.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Evaluar composici�n de claves y rendimiento de agregaciones m�ltiples.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	La consulta ejecuta el escaneo de la tabla sobre la PK de SalesOrderHeader [SalesOrderID].
	Index Assistant no sugiere ning�n cambio, por lo que la consulta ya est� optimizada.
=======================================================================================================================*/

SELECT
	TerritoryID,
	CustomerID,
	SUM(TotalDue) AS Total
FROM
	Sales.SalesOrderHeader
GROUP BY
	CustomerID, TerritoryID;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 16 ms,  elapsed time = 174 ms.

Execution Plan:
Clustered Index Scan - PK_SalesOrderHeader_SalesOrderID
Cost 35%
0.016s


Hash Match (Aggregate)
Cost 65%
0.038s

*/
------------------------------------------------------------------------------------------------------------------------
-- 19. Mostrar las 5 subcategor�as con m�s productos.
-- Tablas: Production.Product, Production.ProductSubcategory
-- Objetivo: TOP y rendimiento sobre JOIN.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	La consulta ya se beneficia del �ndice previamente creado sobre la tabla Production.Product en la columna
	ProductSubcategoryID.
	El mayor costo se concentra en el ordenamiento de las filas para la selecci�n de TOP 5.
=======================================================================================================================*/

SELECT TOP 5
	psc.ProductSubcategoryID,
	COUNT(*) AS [Cantidad Productos]
FROM
	Production.ProductSubcategory psc
JOIN
	Production.Product p
ON
	psc.ProductSubcategoryID = p.ProductSubcategoryID
GROUP BY
	psc.ProductSubcategoryID
ORDER BY
	[Cantidad Productos]  DESC;


/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 25 ms.

Execution Plan:
Index Scan - IX_Product_ProdSubCatID
Cost 32%
0.000s

Clustered Index Scan - PK_ProductSubcategory_ProductSubcategoryID
Cost 17%
0.000s

Sort
Cost 49%
0.000s

*/
------------------------------------------------------------------------------------------------------------------------
-- 20. Mostrar ventas por tipo de tarjeta de cr�dito.
-- Tablas: Sales.SalesOrderHeader, Sales.CreditCard
-- Objetivo: JOIN con condiciones simples y evaluaci�n de �ndices Foreign Key.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/

SELECT TOP 1 * FROM Sales.SalesOrderHeader;
SELECT TOP 1 * FROM Sales.CreditCard;

SELECT
	cd.CardType,
	SUM(soh.TotalDue) AS [Total]
FROM
	Sales.CreditCard cd
JOIN
	Sales.SalesOrderHeader soh
ON
	cd.CreditCardID = soh.CreditCardID
GROUP BY
	cd.CardType;

------------------------------------------------------------------------------------------------------------------------
-- 21. Comparar el uso de CTE y subconsulta para calcular ventas totales por cliente.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Analizar diferencias de ejecuci�n entre estructuras.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	Ambas consultas utilizan el �ndice de PK en SalesOrderID.
	Sin embargo, el query que utiliza una subconsulta muestra un mejor desempe�o, especialmente en la operaci�n de
	agregaci�n y tiempo real de ejecuci�n.
	CTE: Hash Match (Aggregate) = 0.135s | elapsed time = 215ms
	Subconsulta: Hash Match (Aggregate) = 0.032s | elapsed time = 108ms

=======================================================================================================================*/

WITH CTE_TotalCliente
AS (
	SELECT
		CustomerID,
		SUM(TotalDue) AS [Total]
	FROM
		Sales.SalesOrderHeader
	GROUP BY
		CustomerID)

SELECT * FROM CTE_TotalCliente;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:

(19119 rows affected)
 SQL Server Execution Times:
   CPU time = 31 ms,  elapsed time = 215 ms.

Execution Plan:
Clustered Index Scan - PK_SalesOrderHeader_SalesOrderID
Cost 55%
0.016s

Hash Match (Aggregate)
Cost 44%
0.135s

*/

SELECT 
	CustomerID, Total
FROM
	(SELECT
		CustomerID,
		SUM(TotalDue) AS Total
	 FROM
		Sales.SalesOrderHeader
	 GROUP BY
		CustomerID) AS TotalCliente;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:

(19119 rows affected)
 SQL Server Execution Times:
   CPU time = 32 ms,  elapsed time = 108 ms.

Execution Plan:
Clustered Index Scan - PK_SalesOrderHeader_SalesOrderID
Cost 55%
0.013s

Hash Match (Aggregate)
Cost 44%
0.032s

*/
------------------------------------------------------------------------------------------------------------------------
-- 22. Mostrar productos sin ventas en 2014.
-- Tablas: Production.Product, Sales.SalesOrderDetail, Sales.SalesOrderHeader
-- Objetivo: Revisi�n de antijoins y fechas.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 

=======================================================================================================================*/

SELECT 
    p.ProductID,
    p.Name
FROM 
    Production.Product p
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM 
			Sales.SalesOrderDetail sod
        JOIN 
			Sales.SalesOrderHeader soh
        ON 
			sod.SalesOrderID = soh.SalesOrderID
        WHERE 
            sod.ProductID = p.ProductID
            AND soh.OrderDate BETWEEN '2014-01-01' AND '2014-12-31'
    );

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 62 ms,  elapsed time = 115 ms.

Execution Plan:
Index Seek - IX_SOH_OrderDate
Cost 4%
0.004s


Hash Match (Inner Join)
Cost 53%
0.066s


Hash Math (Left Anti Semi Join)
Cost 18%
0.077s

*/

------------------------------------------------------------------------------------------------------------------------
-- 23. Comparar el uso de �ndices existentes con FORCESEEK y FORCESCAN.
-- Tabla: A elecci�n.
-- Objetivo: Experimentar con sugerencias del optimizador.
------------------------------------------------------------------------------------------------------------------------
/* =====================================================================================================================
-- Insights/Justificaci�n: 
	Al usar FORCESCAN, SQL Server recorre toda la tabla ignorando los �ndices disponibles, lo cual es ineficiente si hay
	pocos registros que cumplen la condici�n de filtrado (WHERE).

	Al usar FORCESEEK, SQL Server aprovecha el �ndice sobre SalesOrderID (o clave primaria de la tabla consultada) para acceder 
	directamente a las filas relevantes, haciendo la b�squeda mucho m�s eficiente.
=======================================================================================================================*/

-- Consulta con FORCESCAN
SELECT 
	SalesOrderID, 
	ProductID, 
	OrderQty
FROM 
	Sales.SalesOrderDetail WITH (FORCESCAN)
WHERE 
	SalesOrderID = 43659;

/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 15 ms,  elapsed time = 32 ms.

Execution Plan:
Index Scan - IX_SOD_ProductID
Cost 100%
0.031s


*/

-- Consulta con FORCESEEK
SELECT 
	SalesOrderID, 
	ProductID, 
	OrderQty
FROM 
	Sales.SalesOrderDetail WITH (FORCESEEK)
WHERE 
	SalesOrderID = 43659;


/*
-- OBSERVACIONES

Tiempo de ejecuci�n:
 SQL Server Execution Times:
   CPU time = 0 ms,  elapsed time = 1 ms.

Execution Plan:
Clustered Index Seek - PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID
Cost 100%
0.001s


*/

--======================================================================================================================