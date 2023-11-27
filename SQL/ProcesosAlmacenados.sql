/* Un SP que se encarga de eliminar un proveedor a traves de su RFC, en este SP, se eliminan todas
las referencias del proveedor de las demas tablas.*/


CREATE OR REPLACE PROCEDURE eliminarProveedor(IN RFCProveedorBuscado VARCHAR(13)) AS 
$$
BEGIN
  -- Verifica si el RFC del proveedor existe en la tabla Proveedor
  IF NOT EXISTS (SELECT 1 FROM Proveedor WHERE RFCProveedor = RFCProveedorBuscado) THEN
    RAISE EXCEPTION 'El proveedor con RFC % no existe en la base de datos', RFCProveedorBuscado
    USING hint = 'Verifica que el RFC ingresado sea el correcto';
   
  ELSE
  	 -- Elimina de Proveedor, por el mantenimiento de llaves foraneas, las tablas que contengan
  	-- a ese Proveedor se eliminaran tambien
    DELETE FROM Proveedor WHERE RFCProveedor = RFCProveedorBuscado;
   	
  END IF;
	 
     
END;
$$
LANGUAGE plpgsql;

-- Obtenemos la informacion de la tabla proveedor con un RFC que si existe 
SELECT * FROM Proveedor WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM ProveerMedicina WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM ProveerAlimento WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM TelefonoProveedor WHERE RFCProveedor = 'JDMW8923470EB';

-- Llamamos al SP con ese RFC
CALL eliminarProveedor('JDMW8923470EB');

-- Verificamos que no se encuentre en la tabla Proveedor o en cualquiera donde se encuentra el RFC
SELECT * FROM Proveedor WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM ProveerMedicina WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM ProveerAlimento WHERE RFCProveedor = 'JDMW8923470EB';
SELECT * FROM TelefonoProveedor WHERE RFCProveedor = 'JDMW8923470EB';

------------------------------------------------------------------------------------------------------------------

/*Proceso almacenado que regresa la cantidad de animales que estan en un bioma */
CREATE OR REPLACE FUNCTION cantidad_animales_en_bioma(p_IDBioma INT)
RETURNS INT AS $$
DECLARE
    cantidad_animales INT;
BEGIN
    SELECT COUNT(*) INTO cantidad_animales
    FROM Animal
    WHERE IDBioma = p_IDBioma;

    RETURN cantidad_animales;
END;
$$ 
LANGUAGE plpgsql;

-- Ejemplo de llamada al procedimiento para obtener la cantidad de animales en el bioma con IDBioma = 1: desierto
SELECT IDBioma, TipoBioma, cantidad_animales_en_bioma(1) FROM Bioma WHERE IDBioma =1;

----------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION cantidad_cuidadores_veterinarios_en_bioma(p_IDBioma INT)
RETURNS TABLE (cantidad_cuidadores INT, cantidad_veterinarios INT) AS $$
DECLARE
    v_cantidad_cuidadores INT;
    v_cantidad_veterinarios INT;
BEGIN
    SELECT COUNT(*) INTO v_cantidad_cuidadores
    FROM Cuidador
    WHERE IDBioma = p_IDBioma;

    SELECT COUNT(*) INTO v_cantidad_veterinarios
    FROM Trabajar
    WHERE IDBioma = p_IDBioma;

    RETURN QUERY SELECT v_cantidad_cuidadores, v_cantidad_veterinarios;
END;
$$ LANGUAGE plpgsql;


-- Ejemplo de llamada al procedimiento para obtener la cantidad de veterinarios y cuidadores 
-- que trabajan en el bioma con IDBioma = 2: desierto
SELECT IDBioma, TipoBioma, cantidad_cuidadores_veterinarios_en_bioma(3) FROM Bioma 
WHERE IDBioma = 3 ;

SELECT * FROM cantidad_cuidadores_veterinarios_en_bioma(3);
