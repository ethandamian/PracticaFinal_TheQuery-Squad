/*Disparador que valida la insercion de una tupla en la tabla Ticket, si el descuento 
  proporcionado es mayor a 50.*/

CREATE OR REPLACE FUNCTION validar_descuento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Descuento > 50 THEN
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

-- Crear la función que verifica que un cuidador no sea asignado a más de un animal del mismo bioma
CREATE OR REPLACE FUNCTION verificar_asignacion_cuidador()
RETURNS TRIGGER AS $$
DECLARE
    cantidad_asignaciones INTEGER;
BEGIN
    SELECT COUNT(*) INTO cantidad_asignaciones
    FROM Cuidar
    WHERE RFCCuidador = NEW.RFCCuidador AND IDBioma = NEW.IDBioma;

    IF cantidad_asignaciones > 1 THEN
        RAISE EXCEPTION 'Un cuidador no puede ser asignado a más de un animal del mismo bioma';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger
CREATE TRIGGER verificar_asignacion_cuidador_trigger
BEFORE INSERT ON Cuidar
FOR EACH ROW
EXECUTE FUNCTION verificar_asignacion_cuidador();


--------------- Verificar que un veterinario trabaje a lo más en dos biomas --------------------

CREATE OR REPLACE FUNCTION verificar_num_biomas_veterinario()
RETURNS TRIGGER AS $$
DECLARE
	num_Biomas INTEGER;
BEGIN
    -- Conteo del numero de biomas en los que trabaja el veterinario
    SELECT COUNT(*)
    INTO num_biomas
    FROM Trabajar
    WHERE RFCVeterinario = NEW.RFCVeterinario;

    IF num_biomas >= 2 THEN
        RAISE EXCEPTION 'El veterinario a insertar ya trabaja en dos biomas';
    END IF;
	
	--Verificar si el veterinario ya trabaja en el bioma que se quiere insertar
	IF EXISTS (
        SELECT 1
        FROM trabajar
        WHERE RFCVeterinario = NEW.RFCVeterinario
        AND idbioma = NEW.idbioma
    ) THEN
        RAISE EXCEPTION 'El veterinario ya está asignado a este bioma';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE or replace TRIGGER trigger_num_biomas_veterinario
BEFORE INSERT ON Trabajar
FOR EACH ROW
EXECUTE FUNCTION verificar_num_biomas_veterinario();


-------------------- Generar un ticket cada que se realice una compra de servicio ------------------------------------
-------------------- Cada que se haga una inseción en la tabla comprar, se debe hacer una inseción en ticket --------------

CREATE OR REPLACE FUNCTION generar_ticket() RETURNS TRIGGER AS $$
DECLARE
		tipo VARCHAR;
		CostoUnitario DECIMAL;
		DescuentoA INT;
BEGIN
	SELECT tiposervicio INTO tipo
    FROM Servicio
    WHERE IDServicio = NEW.IDServicio;
	
	SELECT costo INTO CostoUnitario
	FROM Servicio
	WHERE IDServicio = NEW.IDServicio;
	
	SELECT descuento INTO DescuentoA
	FROM Servicio
	WHERE IDServicio = NEW.IDServicio;
	
    INSERT INTO ticket (IDVisitante, Descuento, Costounitario, TipoServicio, Fecha)
	VALUES (NEW.IDVisitante, DescuentoA, CostoUnitario, tipo, CURRENT_DATE);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER compra_servicio
AFTER INSERT ON comprar
FOR EACH ROW
EXECUTE FUNCTION generar_ticket();




