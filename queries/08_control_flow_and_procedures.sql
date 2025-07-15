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



------------------------------------------------------------------------------------------------------------------------
-- 2. Obtener el promedio de ventas y guardarlo en @Promedio; luego mostrar todos los productos cuyo
--    ListPrice sea menor que @Promedio.
-- Tablas: Production.Product
-- Campos: ListPrice, ProductID
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 3. Usar la variable @Promedio (calculada antes) para
--    incrementar en 10% el ListPrice de los productos cuyo
--    ListPrice sea inferior a @Promedio.
--    Tabla: Production.Product | Campo: ListPrice
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 4. Crear una variable de tipo tabla que contenga las
--    categorias y subcategorias de productos y mostrarla.
--    Tablas: Production.ProductCategory, Production.ProductSubcategory
--    Campo: Name
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 5. Calcular el promedio del ListPrice de todos los
--    productos y:
--       Si es < 500 -> PRINT 'PROMEDIO BAJO'
--       Sino         -> PRINT 'PROMEDIO ALTO'
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 6. Crear un procedimiento almacenado
--    HumanResources.<NombreQueDecidas>
--    Parametro: @Inicial NVARCHAR(1)
--    Devuelve: BusinessEntityID, FirstName, LastName, EmailAddress
--    Fuente:   vista HumanResources.vEmployee
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 7. Crear un procedimiento almacenado llamado ProductoVendido
--    Parametro: @ProductID INT
--    Logica:
--    Si el producto existe en Sales.SalesOrderDetail
--         PRINT 'EL PRODUCTO HA SIDO VENDIDO'
--    Caso contrario
--         PRINT 'EL PRODUCTO NO HA SIDO VENDIDO'
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 8. Crear un procedimiento almacenado dbo.ActualizaPrecio
--    Parametros: @ProductID INT, @NuevoPrecio MONEY
--    Actualiza el ListPrice del producto indicado.
--    Tabla: Production.Product
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 9. Crear un procedimiento almacenado ProveedorProducto
--    Parametro: @ProductID INT
--    Devuelve: Nombre del proveedor, AccountNumber y UnitMeasureCode
--    Tablas: Purchasing.Vendor, Purchasing.ProductVendor, Production.Product
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 10. Crear un procedimiento almacenado EmpleadoSector
--     Parametro: @Nombre NVARCHAR(50)
--     Devuelve: FirstName, LastName, Department
--     Fuente:   vista HumanResources.vEmployeeDepartmentHistory
--     (No requiere coincidencia exacta en apellido)
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 11. Declarar una variable @NombreProducto y asignarle el nombre de un producto existente. Imprimir un
--     mensaje con su precio si existe, o "Producto no encontrado" en caso contrario.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 12. Crear un procedimiento almacenado llamado ListarEmpleadosPorDepartamento
--     Parametro: @Departamento NVARCHAR(50)
--     Devuelve: FirstName, LastName, Department
-- Vistas: HumanResources.vEmployeeDepartmentHistory
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 13. Crear un procedimiento almacenado llamado ActualizarColores
--     Parametros: @ColorOriginal NVARCHAR(15), @ColorNuevo NVARCHAR(15)
--     Actualiza todos los productos que tengan el color @ColorOriginal y lo reemplaza por @ColorNuevo
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 14. Declarar una variable de tabla @Top3Productos con campos: ProductID, Name, ListPrice.
--     Insertar en ella los 3 productos mas caros.
--     Luego imprimir su contenido.
-- Tabla: Production.Product
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 15. Crear un procedimiento almacenado dbo.RevisarDescuento
--     Parametro: @OrderID INT
--     Si la orden de venta tiene un descuento > 0, imprimir "La orden tiene descuento"
--     Si no, imprimir "La orden no tiene descuento"
-- Tablas: Sales.SalesOrderDetail
-- Campos: UnitPriceDiscount
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 16. Crear un procedimiento almacenado dbo.ProductosPorRangoPrecio
--     Parametros: @MinPrecio MONEY, @MaxPrecio MONEY
--     Devuelve: ProductID, Name, ListPrice de todos los productos cuyo precio este entre esos valores.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 17. Declarar una variable de tabla @VentasTotalesCliente con CustomerID y TotalVentas.
--     Insertar en ella los 5 clientes que mas han comprado.
-- Tablas: Sales.SalesOrderHeader
-- Campos: SubTotal
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 18. Crear un procedimiento almacenado llamado VerificarEmailEmpleado
--     Parametro: @Email NVARCHAR(50)
--     Devuelve: FirstName, LastName si el email existe.
--     De lo contrario, imprimir "Email no registrado".
-- Vistas: HumanResources.vEmployee
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 19. Crear un procedimiento almacenado que reciba una letra y devuelva todos los productos cuyo nombre comience con
--     esa letra. Si no hay productos, imprimir un mensaje apropiado.
-- Tablas: Production.Product
------------------------------------------------------------------------------------------------------------------------





-- =====================================================================================================================

