/*
==========================================================================================
    Script: 04_case_when_and_data_transformation.sql
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


SELECT
	BusinessEntityID,
	Sexo = CASE Gender
				WHEN 'F' THEN 'Femenino'
				WHEN 'M' THEN 'Masculino'
		   END
FROM
	HumanResources.Employee;



-- 2. Mostrar el ID de los empleados. Si tiene salario deberá mostrarse descendente, de lo contrario ascendente.
--Tablas: HumanResources.Employee
--Campos: BusinessEntityID, SalariedFlag


SELECT
	BusinessEntityID,
	SalariedFlag
FROM
	HumanResources.Employee
ORDER BY
	CASE
		WHEN SalariedFlag = 1
		THEN BusinessEntityID END DESC,
	CASE
		WHEN SalariedFlag = 0
		THEN BusinessEntityID END ASC;


-- 3. Mostrar el ID y un indicador de antigüedad que diga ‘Reciente’ si ingresó a partir de 2015, y ‘Antiguo’ en caso contrario.
--Tabla: HumanResources.Employee
--Campos: BusinessEntityID, HireDate


SELECT
	BusinessEntityId,
	CASE
		WHEN YEAR(HireDate) >= 2015 THEN 'Reciente'
		ELSE 'Antiguo'
	END AS [Tenure]
FROM
	HumanResources.Employee;




-- 4. Mostrar el nombre de los productos, su precio, y una etiqueta que indique si el producto es ‘Económico’ (menos de $100), ‘Medio’ (entre $100 y $500), o ‘Premium’ (más de $500).
--Tabla: Production.Product
--Campos: Name, ListPrice


SELECT
	Name,
	ListPrice,
	CASE
		WHEN ListPrice < 100 THEN 'Económico'
		WHEN ListPrice BETWEEN 100 AND 500 THEN 'Medio'
		ELSE 'Premium'
	END AS [Label]
FROM
	Production.Product;





-- 5. Mostrar las órdenes de venta con su número, subtotal y una categoría de tamaño: ‘Pequeña’ si el subtotal es menor a $1000, ‘Mediana’ si está entre $1000 y $5000, y ‘Grande’ si es mayor a $5000.
--Tabla: Sales.SalesOrderHeader
--Campos: SalesOrderID, SubTotal

SELECT
	SalesOrderID,
	SubTotal,
	CASE
		WHEN SubTotal < 1000 THEN 'Pequeña'
		WHEN SubTotal BETWEEN 1000 AND 5000 THEN 'Mediana'
		ELSE 'Grande'
	END AS [Label]
FROM
	Sales.SalesOrderHeader;




--6. Mostrar los empleados y una columna que diga ‘Con vacaciones’ si tienen más de 0 horas disponibles, o ‘Sin vacaciones’ si tienen 0.
--Tabla: HumanResources.Employee
--Campos: BusinessEntityID, VacationHours


SELECT
	BusinessEntityID,
	CASE
		WHEN VacationHours = 0 THEN 'Sin Vacaciones'
		ELSE 'Con Vacaciones'
	END AS [HasVacations]
FROM
	HumanResources.Employee;





-- 7. Mostrar el número del producto, su nombre y una columna que indique ‘Discontinuado’ si tiene fecha de fin de venta, o ‘Disponible’ si aún se sigue vendiendo.
--Tabla: Production.Product
--Campos: ProductNumber, Name, SellEndDate


SELECT
	ProductNumber,
	Name,
	CASE
		WHEN SellEndDate IS NOT NULL THEN 'Descontinuado'
		ELSE 'Disponible'
	END AS [State]
FROM
	Production.Product;




-- 8. Mostrar los empleados y una columna que indique si nacieron en los años 1960s, 1970s, 1980s o 'Otro', según su año de nacimiento.
--Tabla: HumanResources.Employee
--Campos: BusinessEntityID, BirthDate


SELECT
	BusinessEntityId,
	CASE
		WHEN YEAR(BirthDate) BETWEEN 1960 AND 1969 THEN '60s'
		WHEN YEAR(BirthDate) BETWEEN 1970 AND 1979 THEN '70s'
		WHEN YEAR(BirthDate) BETWEEN 1980 AND 1989 THEN '80s'
		ELSE 'Otro'
	END AS [Period]
FROM
	HumanResources.Employee;