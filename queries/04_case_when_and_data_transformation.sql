/*
==========================================================================================
    Script: 04_case_when_and_data_transformation.sql
    Descripci�n: Consultas que aplican l�gica condicional mediante CASE, transformaciones
                 legibles para el usuario, y ordenamiento condicional.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creaci�n: [2025-07-14]
==========================================================================================
*/


USE AdventureWorks2022;


-- 1. Obtener el ID y una columna denominada sexo cuyos valores disponibles sean �Masculino� y �Femenino�.
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



-- 2. Mostrar el ID de los empleados. Si tiene salario deber� mostrarse descendente, de lo contrario ascendente.
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


-- 3. Mostrar el ID y un indicador de antig�edad que diga �Reciente� si ingres� a partir de 2015, y �Antiguo� en caso contrario.
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




-- 4. Mostrar el nombre de los productos, su precio, y una etiqueta que indique si el producto es �Econ�mico� (menos de $100), �Medio� (entre $100 y $500), o �Premium� (m�s de $500).
--Tabla: Production.Product
--Campos: Name, ListPrice


SELECT
	Name,
	ListPrice,
	CASE
		WHEN ListPrice < 100 THEN 'Econ�mico'
		WHEN ListPrice BETWEEN 100 AND 500 THEN 'Medio'
		ELSE 'Premium'
	END AS [Label]
FROM
	Production.Product;





-- 5. Mostrar las �rdenes de venta con su n�mero, subtotal y una categor�a de tama�o: �Peque�a� si el subtotal es menor a $1000, �Mediana� si est� entre $1000 y $5000, y �Grande� si es mayor a $5000.
--Tabla: Sales.SalesOrderHeader
--Campos: SalesOrderID, SubTotal

SELECT
	SalesOrderID,
	SubTotal,
	CASE
		WHEN SubTotal < 1000 THEN 'Peque�a'
		WHEN SubTotal BETWEEN 1000 AND 5000 THEN 'Mediana'
		ELSE 'Grande'
	END AS [Label]
FROM
	Sales.SalesOrderHeader;




--6. Mostrar los empleados y una columna que diga �Con vacaciones� si tienen m�s de 0 horas disponibles, o �Sin vacaciones� si tienen 0.
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





-- 7. Mostrar el n�mero del producto, su nombre y una columna que indique �Discontinuado� si tiene fecha de fin de venta, o �Disponible� si a�n se sigue vendiendo.
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




-- 8. Mostrar los empleados y una columna que indique si nacieron en los a�os 1960s, 1970s, 1980s o 'Otro', seg�n su a�o de nacimiento.
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