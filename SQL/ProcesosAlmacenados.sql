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