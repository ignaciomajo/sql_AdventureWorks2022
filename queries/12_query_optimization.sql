/*
==========================================================================================
    Script: 12_query_optimization.sql
    Descripción: Identificación y aplicación de mejoras en el rendimiento de consultas SQL,
				 análisis de planes de ejecución, uso de índices, reducción de costos de 
				 CPU/I/O y reescritura de queries ineficientes.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: 2025-07-21
==========================================================================================
*/


USE AdventureWorks2022;


------------------------------------------------------------------------------------------------------------------------
-- 1. Mostrar todos los pedidos realizados en el año 2013.
-- Tabla: Sales.SalesOrderHeader
-- Campos: SalesOrderID, OrderDate, CustomerID
-- Objetivo: Evaluar impacto de filtros sobre columnas no indexadas.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 2. Mostrar las órdenes cuyo monto total supere los $10000.
-- Tabla: Sales.SalesOrderHeader
-- Campos: SalesOrderID, TotalDue
-- Objetivo: Analizar rendimiento de filtros sobre columnas numéricas.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 3. Mostrar los productos que contienen "Mountain" en el nombre.
-- Tabla: Production.Product
-- Campos: ProductID, Name
-- Objetivo: Observar impacto del uso de LIKE con comodines en el rendimiento.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 4. Mostrar los 10 productos más caros.
-- Tabla: Production.Product
-- Campos: ProductID, Name, ListPrice
-- Objetivo: Analizar uso de TOP y ORDER BY en combinación con índices.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 5. Mostrar la cantidad de productos por categoría.
-- Tablas: Production.Product, Production.ProductSubcategory, Production.ProductCategory
-- Objetivo: Revisión del uso de agregaciones e índices en columnas JOIN.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 6. Contar las órdenes por territorio.
-- Tabla: Sales.SalesOrderHeader
-- Campos: TerritoryID
-- Objetivo: Optimizar COUNT(*) con GROUP BY.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 7. Mostrar las 20 órdenes más recientes realizadas por clientes de California.
-- Tablas: Sales.SalesOrderHeader, Sales.Customer, Person.Person, Person.StateProvince
-- Objetivo: Explorar subconsultas y filtros por región.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 8. Mostrar el nombre del producto y su proveedor.
-- Tablas: Production.ProductVendor, Purchasing.Vendor, Production.Product
-- Objetivo: Revisión de JOINs sobre múltiples tablas y selección de campos.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 9. Listar los productos que no tienen un SpecialOffer asignado.
-- Tabla: Sales.SpecialOfferProduct
-- Objetivo: Evaluar uso de NOT EXISTS vs LEFT JOIN.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 10. Mostrar el total vendido por año.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Revisar funciones de agregación y DATEPART.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 11. Mostrar productos vendidos más de 500 veces.
-- Tabla: Sales.SalesOrderDetail
-- Objetivo: Optimizar agregación con filtros y columnas en índices.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 12. Mostrar los empleados cuyo nombre empiece con "A".
-- Tablas: Person.Person
-- Objetivo: Análisis de LIKE con comodín al final vs al principio.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 13. Mostrar la cantidad de vendedores activos por territorio.
-- Tablas: Sales.SalesPerson
-- Objetivo: Filtrar NULLs, aplicar COUNT y evaluar índices en campos JOIN.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 14. Mostrar el total de ventas por producto.
-- Tablas: Sales.SalesOrderDetail
-- Objetivo: SUM, GROUP BY y columnas incluidas en índices.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 15. Mostrar el promedio de descuento por cliente.
-- Tablas: Sales.SalesOrderDetail, Sales.SalesOrderHeader
-- Objetivo: Uso de AVG, GROUP BY, JOIN y evaluación de expresiones.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 16. Mostrar los clientes con más de 3 pedidos en los últimos 2 años.
-- Tablas: Sales.SalesOrderHeader
-- Objetivo: Filtros temporales + subqueries o HAVING.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 17. Detectar productos con múltiples proveedores.
-- Tabla: Production.ProductVendor
-- Objetivo: Agrupar y filtrar con COUNT.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 18. Calcular el total de ventas para cada combinación de cliente y territorio.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Evaluar composición de claves y rendimiento de agregaciones múltiples.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 19. Mostrar las 5 categorías con más productos.
-- Tablas: Production.Product, Production.ProductSubcategory, Production.ProductCategory
-- Objetivo: TOP y rendimiento sobre múltiples niveles de JOIN.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 20. Mostrar ventas por tipo de tarjeta de crédito.
-- Tablas: Sales.SalesOrderHeader, Sales.CreditCard
-- Objetivo: JOIN con condiciones simples y evaluación de índices Foreign Key.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 21. Comparar el uso de CTE y subconsulta para calcular ventas totales por cliente.
-- Tabla: Sales.SalesOrderHeader
-- Objetivo: Analizar diferencias de ejecución entre estructuras.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 22. Mostrar productos sin ventas en 2014.
-- Tablas: Production.Product, Sales.SalesOrderDetail, Sales.SalesOrderHeader
-- Objetivo: Revisión de antijoins y fechas.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 23. Identificar cuellos de botella en una consulta con múltiples JOINs y filtros por fechas.
-- Objetivo: Ejecutar con STATISTICS IO y TIME y analizar plan de ejecución.
-- Consulta: libre.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 24. Crear un índice adecuado para mejorar el rendimiento de una consulta de tu elección.
-- Objetivo: Identificar columnas utilizadas en WHERE, JOIN y SELECT.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 25. Comparar el uso de índices existentes con FORCESEEK y FORCESCAN.
-- Tabla: A elección.
-- Objetivo: Experimentar con sugerencias al optimizador.
-- Insights/Justificación: 
--
--
------------------------------------------------------------------------------------------------------------------------






--======================================================================================================================