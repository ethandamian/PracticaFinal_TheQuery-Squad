/*Disparador que valida la insercion de una tupla en la tabla Ticket, si el descuento 
  proporcionado es menor a 10 y mayor a 50.*/

CREATE OR REPLACE FUNCTION validar_descuento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Descuento < 10 OR NEW.Descuento > 50 THEN
        RAISE EXCEPTION 'El descuento debe estar en el rango de 0 a 50';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_descuento_trigger
BEFORE INSERT ON Ticket
FOR EACH ROW
EXECUTE FUNCTION validar_descuento();

-- Inserción con descuento válido (por ejemplo, 20)
INSERT INTO Ticket (IDVisitante, Descuento, CostoUnitario, TipoServicio, Fecha) 
VALUES (1, 20, 50.00, 'tienda', '2023-01-01');

-- Intento de inserción con descuento no válido (por ejemplo, -10)
INSERT INTO Ticket (IDVisitante, Descuento, CostoUnitario, TipoServicio, Fecha) 
VALUES (2, -10, 75.00, 'baño', '2023-01-02');

----------------------------------------------------------------------------------------------------------------

/*Disparador que valida que un veterinario puede atender a un animal solo si son del mismo bioma*/
CREATE OR REPLACE FUNCTION validar_relacion_animal()
RETURNS TRIGGER AS $$
DECLARE
    v_bioma_veterinario INT;
    v_bioma_animal INT;
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Obtener el bioma del veterinario
        SELECT Trabajar.IDBioma INTO v_bioma_veterinario
        FROM Trabajar
        WHERE RFCVeterinario = NEW.RFCVeterinario;

        -- Obtener el bioma del animal
        SELECT IDBioma INTO v_bioma_animal
        FROM Animal
        WHERE IDAnimal = NEW.IDAnimal;

        -- Verificar si el bioma del veterinario y del animal coinciden
        IF v_bioma_veterinario IS DISTINCT FROM v_bioma_animal THEN
            RAISE EXCEPTION 'Un animal solo puede ser atendido por veterinarios de su mismo bioma.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validar_relacion_animal_trigger_atender
BEFORE INSERT ON Atender
FOR EACH ROW
EXECUTE FUNCTION validar_relacion_animal();

-- Insertamos dos veterinarios en la tabla Veterinario
INSERT INTO Veterinario (RFCVeterinario, Nombre, ApellidoPaterno, ApellidoMaterno,
Calle, NumInterior, NumExterior, Colonia, Estado, FechaInicioContrato, FechaFinContrato, 
FechaNacimiento, Genero, Salario, Especialidad) 
VALUES ('RXQX0035332S0', 'Lilllie','Dredge', 'Sharkey', 'Calle Zaragoza', 04, 34, 'Condesa', 
'Coahuila de Zaragoza', '2022-01-17', '2023-01-09', '2009-04-16', 'No-binario', 2681.46, 'Neurología');

INSERT INTO Veterinario (RFCVeterinario, Nombre, ApellidoPaterno, ApellidoMaterno,
Calle, NumInterior, NumExterior, Colonia, Estado, FechaInicioContrato, FechaFinContrato, 
FechaNacimiento, Genero, Salario, Especialidad) 
VALUES ('GHBM935884NED', 'Aron','Whipple', 'Krochmann', 'Boulevard Miguel Alemán', 06719, 7, 'Del Valle', 
'Nayarit', '2019-05-27', '2023-02-16', '1990-03-01', 'Hombre', 2033.4, 'Oftalmología');

-- Verificamos que la insercion se logro correctamente 
SELECT * FROM Veterinario WHERE rfcveterinario = 'RXQX0035332S0';

SELECT * FROM Veterinario WHERE rfcveterinario = 'GHBM935884NED';


-- Realizamos una insercion en la tabla trabajar, es donde los veterinarios trabajaran en un bioma en especifico


INSERT  INTO Trabajar(RFCVeterinario, IDBioma) VALUES('RXQX0035332S0',2);

INSERT  INTO Trabajar(RFCVeterinario, IDBioma) VALUES('GHBM935884NED',5);

-- Realizando una insercion valida en la tabla atender: esto es que el veterinario con RFC RXQX0035332S0 
-- atienda a algun animal con iDBioma = 2
SELECT * FROM animal WHERE idBioma =4;

INSERT INTO Atender(IDAnimal, IndicacionesMedicas, RFCVeterinario) VALUES(86, 'Come mucho', 'RXQX0035332S0');

-- Realizando una insercion invalida en la tabla atender: esto es que el veterinario con RFC GHBM935884NED 
-- atienda a algun animal con iDBioma diferente de 5
INSERT INTO Atender(IDAnimal, IndicacionesMedicas, RFCVeterinario) VALUES(53, 'Necesita cuidados intensivos', 'GHBM935884NED');

-----------------------------------------------------------------------------------------------------------------------------------\




