/*
==========================================================================================
    Script: 05_joins_and_relationships.sql
    Descripción: Consultas que involucran relaciones entre tablas, uso de JOINs y filtros
                 para combinar información relevante.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-14]
==========================================================================================
*/


USE AdventureWorks2022;


-- 1. Mostrar los empleados que también son vendedores.
-- Tablas: HumanResources.Employee, Sales.SalesPerson
-- Campos: BusinessEntityID








-- 2. Mostrar los empleados ordenados alfabéticamente por apellido y por nombre.
-- Tablas: HumanResources.Employee, Person.Person
-- Campos: BusinessEntityID, LastName, FirstName








-- 3. Mostrar el código de logueo, código de territorio y sueldo básico de los vendedores.
-- Tablas: HumanResources.Employee, Sales.SalesPerson
-- Campos: LoginID, TerritoryID, Bonus, BusinessEntityID








-- 4. Mostrar los productos que sean ruedas.
-- Tablas: Production.Product, Production.ProductSubcategory
-- Campos: Name, ProductSubcategoryID








-- 5. Mostrar los nombres de los productos que no son bicicletas.
-- Tablas: Production.Product, Production.ProductSubcategory
-- Campos: Name, ProductSubcategoryID








-- 6. Mostrar los precios de venta de aquellos productos donde el precio de venta sea inferior al precio de lista recomendado para ese producto ordenados por nombre de producto.
-- Tablas: Sales.SalesOrderDetail, Production.Product
-- Campos: ProductID, Name, ListPrice, UnitPrice








-- 7. Mostrar todos los productos que tengan igual precio. Se deben mostrar de a pares, código y nombre de cada uno de los dos productos y el precio de ambos. Ordenar por precio en forma descendente.
-- Tablas: Production.Product
-- Campos: ProductID, ListPrice, Name








-- 8. Mostrar el nombre de los productos y de los proveedores cuya subcategoría es 15 ordenados por nombre de proveedor.
-- Tablas: Production.Product, Purchasing.ProductVendor, Purchasing.Vendor
-- Campos: Name, ProductID, BusinessEntityID, ProductSubcategoryID







-- 9. Mostrar todas las personas (nombre y apellido) y en el caso de que sean empleados mostrar también el login ID, mostrar NULL.
-- Tablas: Person.Person, HumanResources.Employee
-- Campos: FirstName, LastName, LoginID






