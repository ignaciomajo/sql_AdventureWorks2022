/*
==========================================================================================
    Script: 02_pattern_matching_and_text_filters.sql
    Descripción: Consultas que aplican filtros sobre texto usando operadores LIKE, patrones,
                 expresiones de coincidencia parcial, y condiciones complejas con nombres.
    Base de datos: AdventureWorks2022
    Autor: Ignacio Majo
    Fecha de creación: [YYYY-MM-DD]
==========================================================================================
*/


-- 1. Mostrar el nombre de los productos que tengan cualquier combinación de ‘mountain bike’.
--Tablas: Production.Product
--Campos: Name









-- 2. Mostrar las personas cuyo nombre comience con la letra “y”.
--Tablas: Person.Person
--Campos: FirstName









-- 3. Mostrar las personas que en la segunda letra de su apellido tienen una ‘s’.
--Tablas: Person.Person
--Campos: LastName









-- 4. Mostrar el nombre concatenado con el apellido de las personas cuyo apellido terminen en ‘ez’.
--Tablas: Person.Person
--Campos: FirstName, LastName









-- 5. Mostrar los nombres de los productos que terminen en un número.
--Tablas:  Production.Product
--Campos: Name









-- 6. Mostrar las personas cuyo nombre tenga una ‘C’ o ‘c’ como primer carácter, cualquier otro como segundo carácter, ni ‘d’ ni ‘e’ ni ‘f’ ni ‘g’ 
-- como tercer carácter, cualquiera entre ‘j’ y ‘r’ o entre ‘s’ y ‘w’ como cuarto carácter y el resto sin restricciones.
--Tablas: Person.Person
--Campos: FirstName