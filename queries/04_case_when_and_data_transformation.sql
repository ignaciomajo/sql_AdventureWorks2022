/*
==========================================================================================
    Script: 05_case_when_and_data_transformation.sql
    Descripción: Consultas que aplican lógica condicional mediante CASE, transformaciones
                 legibles para el usuario, y ordenamiento condicional.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [2025-07-14]
==========================================================================================
*/


USE AdventureWorks2022;


-- 1. Obtener el ID y una columna denominada sexo cuyos valores disponibles sean “Masculino” y “Femenino”.
--Tablas: HumanResources.Employee
--Campos: BusinessEntityID, Gender










-- 2. Mostrar el ID de los empleados. Si tiene salario deberá mostrarse descendente, de lo contrario ascendente.
--Tablas: HumanResources.Employee
--Campos: BusinessEntityID, SalariedFlag










-- 3. Mostrar el precio más barato de todas las bicicletas.
--Tablas: Production.Product
--Campos: ListPrice, Name










-- 4. Mostrar la fecha de nacimiento del empleado más joven.
--Tablas: HumanResources.Employee
--Campos: BirthDate