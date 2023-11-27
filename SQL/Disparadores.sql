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


