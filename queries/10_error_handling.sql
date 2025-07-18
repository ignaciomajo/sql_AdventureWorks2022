/*
==========================================================================================
    Script: 10_error_handling.sql
    Descripci�n: Manejo de errores en transacciones utilizando variables de sistema,
                 bloques TRY...CATCH, y comandos como RAISERROR y THROW.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creaci�n: [2025-07-18]
==========================================================================================
*/


USE AdventureWorks2022;


------------------------------------------------------------------------------------------------------------------------
-- 1.  Realizar una divisi�n por cero y atrapar el error utilizando variables de sistema (revertir la transacci�n).
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 2.  Realizar una divisi�n por cero y atrapar el error sin utilizar variables de sistema (revertir la transacci�n).
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 3.  Agregar al ejercicio anterior el env�o de un mensaje de error utilizando RAISERROR.
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 4.  Realizar una copia del punto 3 y enviar un mensaje de error utilizando THROW.
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 5.  Eliminar todos los empleados cuyo campo `JobTitle` sea NULL. Si ocurre alg�n error, revertir y mostrar 
--     mensaje personalizado.
-- Tablas: HumanResources.Employee
-- Campos: JobTitle
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 6.  Insertar 5 registros inv�lidos en la tabla `Person.EmailAddress`con valores repetidos en `EmailAddress`. 
--     Capturar la excepci�n y dejar constancia en una tabla de log.
-- Tablas: Person.EmailAddress, tabla temporal de log
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 7.  Actualizar las fechas de contrataci�n de todos los empleados sum�ndoles 1 a�o. Si alguna fecha queda futura 
--    al 2025, revertir y lanzar un error.
-- Tablas: HumanResources.Employee
-- Campos: HireDate
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 8. Insertar un nuevo producto en `Production.Product` con un valor negativo de precio. Capturar el error y usar 
--    THROW para detener la ejecuci�n.
--Campos: ListPrice
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 9. Simular un proceso de backup l�gico con m�ltiples INSERT y un DELETE sobre una tabla temporal. Si cualquiera de 
--    las operaciones falla, revertir todo y mostrar un mensaje con el error.
--Tablas: tabla temporal de prueba
------------------------------------------------------------------------------------------------------------------------



------------------------------------------------------------------------------------------------------------------------
-- 10. Realizar una operaci�n entre varias tablas (INSERT + UPDATE). Si el n�mero de filas afectadas no supera 5, 
--     revertir y notificar al usuario.
-- Tablas: a definir por el usuario
------------------------------------------------------------------------------------------------------------------------





-- =====================================================================================================================
