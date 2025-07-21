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


------------------------------------------------------------------------------------------------------------------------
-- 1. Mostrar todos los pedidos realizados en el a�o 2013.
-- Tabla: Sales.SalesOrderHeader
-- Campos: SalesOrderID, OrderDate, CustomerID
-- Objetivo: Evaluar impacto de filtros sobre columnas no indexadas.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 2. Mostrar las �rdenes cuyo monto total supere los $10000.
-- Tabla: Sales.SalesOrderHeader
-- Campos: SalesOrderID, TotalDue
-- Objetivo: Analizar rendimiento de filtros sobre columnas num�ricas.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 3. Mostrar los productos que contienen "Mountain" en el nombre.
-- Tabla: Production.Product
-- Campos: ProductID, Name
-- Objetivo: Observar impacto del uso de LIKE con comodines en el rendimiento.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 4. Mostrar los 10 productos m�s caros.
-- Tabla: Production.Product
-- Campos: ProductID, Name, ListPrice
-- Objetivo: Analizar uso de TOP y ORDER BY en combinaci�n con �ndices.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 5. Mostrar la cantidad de productos por categor�a.
-- Tablas: Production.Product, Production.ProductSubcategory, Production.ProductCategory
-- Objetivo: Revisi�n del uso de agregaciones e �ndices en columnas JOIN.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 6. Contar las �rdenes por territorio.
-- Tabla: Sales.SalesOrderHeader
-- Campos: TerritoryID
-- Objetivo: Optimizar COUNT(*) con GROUP BY.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 7. Mostrar las 20 �rdenes m�s recientes realizadas por clientes de California.
-- Tablas: Sales.SalesOrderHeader, Sales.Customer, Person.Person, Person.StateProvince
-- Objetivo: Explorar subconsultas y filtros por regi�n.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 8. Mostrar el nombre del producto y su proveedor.
-- Tablas: Production.ProductVendor, Purchasing.Vendor, Production.Product
-- Objetivo: Revisi�n de JOINs sobre m�ltiples tablas y selecci�n de campos.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 9. Listar los productos que no tienen un SpecialOffer asignado.
-- Tabla: Sales.SpecialOfferProduct
-- Objetivo: Evaluar uso de NOT EXISTS vs LEFT JOIN.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 10. Mostrar el total vendido por a�o.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Revisar funciones de agregaci�n y DATEPART.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 11. Mostrar productos vendidos m�s de 500 veces.
-- Tabla: Sales.SalesOrderDetail
-- Objetivo: Optimizar agregaci�n con filtros y columnas en �ndices.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 12. Mostrar los empleados cuyo nombre empiece con "A".
-- Tablas: Person.Person
-- Objetivo: An�lisis de LIKE con comod�n al final vs al principio.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 13. Mostrar la cantidad de vendedores activos por territorio.
-- Tablas: Sales.SalesPerson
-- Objetivo: Filtrar NULLs, aplicar COUNT y evaluar �ndices en campos JOIN.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 14. Mostrar el total de ventas por producto.
-- Tablas: Sales.SalesOrderDetail
-- Objetivo: SUM, GROUP BY y columnas incluidas en �ndices.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 15. Mostrar el promedio de descuento por cliente.
-- Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
-- Objetivo: Uso de AVG, GROUP BY, JOIN y evaluaci�n de expresiones.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 16. Mostrar los clientes con m�s de 3 pedidos en los �ltimos 2 a�os.
-- Tablas: Sales.SalesOrderHeader
-- Objetivo: Filtros temporales + subqueries o HAVING.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 17. Detectar productos con m�ltiples proveedores.
-- Tabla: Production.ProductVendor
-- Objetivo: Agrupar y filtrar con COUNT.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 18. Calcular el total de ventas para cada combinaci�n de cliente y territorio.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Evaluar composici�n de claves y rendimiento de agregaciones m�ltiples.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 19. Mostrar las 5 categor�as con m�s productos.
-- Tablas: Production.Product, Production.ProductSubcategory, Production.ProductCategory
-- Objetivo: TOP y rendimiento sobre m�ltiples niveles de JOIN.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 20. Mostrar ventas por tipo de tarjeta de cr�dito.
-- Tablas: Sales.SalesOrderHeader, Sales.CreditCard
-- Objetivo: JOIN con condiciones simples y evaluaci�n de �ndices Foreign Key.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 21. Comparar el uso de CTE y subconsulta para calcular ventas totales por cliente.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Analizar diferencias de ejecuci�n entre estructuras.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 22. Mostrar productos sin ventas en 2014.
-- Tablas: Production.Product, Sales.SalesOrderDetail, Sales.SalesOrderHeader
-- Objetivo: Revisi�n de antijoins y fechas.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 23. Identificar cuellos de botella en una consulta con m�ltiples JOINs y filtros por fechas.
-- Objetivo: Ejecutar con STATISTICS IO y TIME y analizar plan de ejecuci�n.
-- Consulta: libre.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 24. Crear un �ndice adecuado para mejorar el rendimiento de una consulta de tu elecci�n.
-- Objetivo: Identificar columnas utilizadas en WHERE, JOIN y SELECT.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 25. Comparar el uso de �ndices existentes con FORCESEEK y FORCESCAN.
-- Tabla: A elecci�n.
-- Objetivo: Experimentar con sugerencias al optimizador.
-- Insights/Justificaci�n: 
--
--
------------------------------------------------------------------------------------------------------------------------






--======================================================================================================================