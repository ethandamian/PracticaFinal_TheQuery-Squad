
/*1. Encontrar los proveedores que han suministrado medicina a biomas donde hay mas de 3 animales.
 Mostrar la siguiente informacion en la consulta: nombre y apellidos del proveedor, 
 la medicina suministrada, el tipo del bioma al que se le suministra, y la cantidad 
 de animales que hay en el bioma*/ 

SELECT P.Nombre, P.ApellidoPaterno, M.Nombre AS MedicinaSuministrada, B.TipoBioma, 
COUNT(A.IDAnimal) AS CantidadAnimales
FROM Proveedor P
JOIN ProveerMedicina PM ON P.RFCProveedor = PM.RFCProveedor
JOIN Medicina M ON PM.IDInsumoMedicina = M.IDInsumoMedicina
JOIN DistribuirMedicina DM ON M.IDInsumoMedicina = DM.IDInsumoMedicina
JOIN Bioma B ON DM.IDBioma = B.IDBioma
LEFT JOIN Animal A ON B.IDBioma = A.IDBioma
GROUP BY P.RFCProveedor, M.Nombre, B.TipoBioma
HAVING COUNT(A.IDAnimal) > 3;



/*2. Obtener la cantidad total gastada por cada visitante en tickets, considerando descuentos.
  Esta consulta suma el costo total de los tickets en la tabla Visitante, y considera si se 
  aplico algun descuento*/

SELECT IDVisitante, SUM(CostoUnitario - (CostoUnitario * Descuento / 100)) AS TotalGastado
FROM Ticket
GROUP BY IDVisitante;

/*3. Mostrar que tipos de servicios se han adquirido, es decir, la cantidad de tickets generados en los servicios,
 hay que ordenarlos en forma descendiente*/

SELECT T.TipoServicio, COUNT(T.NumTicket) AS CantidadTicketsVendidos
FROM Visitante V
JOIN Ticket T ON V.IDVisitante = T.IDVisitante
GROUP BY T.TipoServicio
ORDER BY CantidadTicketsVendidos DESC;


/*4. Obtener toda la informacion del visitante donde se cumpla: la cantidad de servicios vendidos por cada visitante, 
 sin tomar en cuenta los servicios de baño, los visitantes tuvieron que haber comprado este servicio mas 
 2 o mas veces. ordenar por fecha de nacimiento de forma ascendente*/

SELECT * FROM visitante WHERE idVisitante IN (
	SELECT
	C.IDVisitante
	FROM Comprar C
	JOIN Servicio S ON C.IDServicio = S.IDServicio
	WHERE S.TipoServicio <> 'Baño'
	GROUP BY C.IDVisitante, S.TipoServicio 
	HAVING COUNT(S.TipoServicio) >= 2
) ORDER BY fechanacimiento  ASC;





-- Seleccionar el tipo de bioma, la especie y contar la cantidad de animales por especie en cada bioma
SELECT b.TipoBioma, a.Especie, COUNT(*) AS CantidadAnimales
FROM Animal a
JOIN Bioma b ON a.IDBioma = b.IDBioma
GROUP BY b.TipoBioma, a.Especie;

-- Calcular la edad promedio de los visitantes por género
SELECT Genero, AVG(EXTRACT(YEAR FROM AGE(FechaNacimiento))) AS EdadPromedio
FROM Visitante
GROUP BY Genero;

-- Calcular el salario promedio de los cuidadores por especie de animal a cargo
SELECT c.Especie, AVG(tc.Salario) AS SalarioPromedio
FROM Cuidar c
JOIN Cuidador tc ON c.RFCCuidador = tc.RFCCuidador
GROUP BY c.Especie;

-- El tipo de evento y el id de los visitantes de entre 20 y 24 años que han asistido a al menos un evento y la cantidad de asistentes al evento que asistieron ordenado de mayor a menor (por tipo de evento)
SELECT tipoevento, count(tipoevento) as cantidad, idvisitante
FROM (SELECT *
      FROM Visitante NATURAL JOIN Visitar
      WHERE AGE(FechaNacimiento) BETWEEN interval '20 years' and interval '24 years')
	  NATURAL JOIN evento
GROUP BY tipoevento, idvisitante
ORDER BY tipoevento, cantidad DESC;


-- Obtener la cantidad se tickets de servicios de comida generados por año y por trimestre, ordenados por año y trimestre

SELECT count(numticket), EXTRACT('year' FROM fecha) AS año,
       EXTRACT('quarter' from fecha) as trimestre
FROM ticket
WHERE LOWER(tiposervicio) = 'comida'
GROUP BY año, trimestre
ORDER BY año;

--Obtener el directorio (nombre, apellidos, teléfono y correo) de los cuidadores cuyo nombre o apellidos contengan la cadena "or" y que trabajen en el aviario
SELECT nombre, apellidopaterno, apellidomaterno, telefono, correo
FROM
(SELECT idbioma, nombre, apellidopaterno, apellidomaterno, telefono, correo
FROM Cuidador NATURAL JOIN TelefonoCuidador NATURAL JOIN CorreoCuidador
WHERE (LOWER(nombre) LIKE '%or%' OR LOWER(apellidopaterno) LIKE '%or%'
      OR LOWER(apellidomaterno) LIKE '%or%')) NATURAL JOIN Bioma
WHERE LOWER(tipobioma) = 'aviario';

--Obtener la cantidad de animales y la cantidad de cuidadores por bioma:

SELECT b.TipoBioma,
       COUNT(a.IDAnimal) AS CantidadAnimales,
       COUNT(c.RFCCuidador) AS CantidadCuidadores
FROM Bioma b
LEFT JOIN Animal a ON b.IDBioma = a.IDBioma
LEFT JOIN Cuidar c ON a.IDAnimal = c.IDAnimal
GROUP BY b.TipoBioma;

--Obtener el salario promedio de los veterinarios por especialidad:
SELECT v.Especialidad,
       AVG(v.Salario) AS SalarioPromedio
FROM Veterinario v
GROUP BY v.Especialidad;

--Encontrar los cuidadores que trabajan en jaulas con más de un animal:

SELECT cu.Nombre, cu.ApellidoPaterno, cu.ApellidoMaterno, COUNT(a.IDAnimal) AS CantidadAnimales
FROM Cuidador cu
JOIN Cuidar c ON cu.RFCCuidador = c.RFCCuidador
JOIN Animal a ON c.IDAnimal = a.IDAnimal
GROUP BY cu.RFCCuidador
HAVING COUNT(a.IDAnimal) > 1;


-- Obtener la cantidad de animales por bioma cuya altura sea mayor al promedio de altura de todos los animales en ese bioma:
WITH PromedioAltura AS (
    SELECT IDBioma, AVG(Altura) AS PromedioAlturaBioma
    FROM Animal
    GROUP BY IDBioma
)

SELECT 
    a.IDBioma,
    b.TipoBioma,
    COUNT(a.IDAnimal) AS CantidadAnimales
FROM Animal a
JOIN Bioma b ON a.IDBioma = b.IDBioma
JOIN PromedioAltura pa ON a.IDBioma = pa.IDBioma AND a.Altura > pa.PromedioAlturaBioma
GROUP BY a.IDBioma, b.TipoBioma;

-- Obtener la tabla de cada animal con sus cuidadores y su veterinario. Ordenado por idAnimal.

SELECT a.IDAnimal, a.Especie, a.NombreAnimal, a.IDBioma, c.RFCCuidador, v.RFCVeterinario
FROM Animal a
JOIN Cuidar c ON a.IDAnimal = c.IDAnimal
JOIN Atender v ON a.IDAnimal = v.IDAnimal
ORDER BY a.IDAnimal;
