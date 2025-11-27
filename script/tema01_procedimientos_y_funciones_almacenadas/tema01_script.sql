-- Procedimientos y funciones almacenadas adaptados a TiendaEmprendedores

USE TiendaEmprendedores;
GO

----------------------------------------------
-- PROCEDIMIENTO: Insertar Proveedor
----------------------------------------------
CREATE PROC SP_InsertarProveedor
    @nombre VARCHAR(200),
    @direccion VARCHAR(200),
    @telefono VARCHAR(200),
    @email VARCHAR(200),
    @web VARCHAR(200),
    @id_estado INT,
    @Mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET @Mensaje = '';

    IF EXISTS(SELECT 1 FROM Proveedor WHERE nombre = @nombre)
    BEGIN
        SET @Mensaje = 'El proveedor ya existe.';
        PRINT @Mensaje;
        RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Estado WHERE id_estado = @id_estado)
    BEGIN
        SET @Mensaje = 'El estado ingresado no existe.';
        PRINT @Mensaje;
        RETURN;
    END

    INSERT INTO Proveedor(nombre, direccion, telefono, email, web, id_estado)
    VALUES(@nombre, @direccion, @telefono, @email, @web, @id_estado);

    SET @Mensaje = 'Proveedor creado correctamente.';
    PRINT @Mensaje;
END
GO

----------------------------------------------
-- PROCEDIMIENTO: Modificar Proveedor
----------------------------------------------
CREATE PROC SP_ModificarProveedor
    @id_proveedor INT,
    @nombre VARCHAR(200),
    @direccion VARCHAR(200),
    @telefono VARCHAR(200),
    @email VARCHAR(200),
    @web VARCHAR(200),
    @id_estado INT,
    @Mensaje VARCHAR(200) OUTPUT
AS
BEGIN
    SET @Mensaje = '';

    IF NOT EXISTS(SELECT 1 FROM Proveedor WHERE id_proveedor = @id_proveedor)
    BEGIN
        SET @Mensaje = 'Proveedor no encontrado.';
        PRINT @Mensaje;
        RETURN;
    END

    IF NOT EXISTS(SELECT 1 FROM Estado WHERE id_estado = @id_estado)
    BEGIN
        SET @Mensaje = 'El estado proporcionado no existe.';
        PRINT @Mensaje;
        RETURN;
    END

    UPDATE Proveedor
    SET nombre = @nombre,
        direccion = @direccion,
        telefono = @telefono,
        email = @email,
        web = @web,
        id_estado = @id_estado
    WHERE id_proveedor = @id_proveedor;

    SET @Mensaje = 'Proveedor actualizado correctamente.';
    PRINT @Mensaje;
END
GO

----------------------------------------------
-- PROCEDIMIENTO: Eliminar Proveedor y Productos
----------------------------------------------
CREATE PROC SP_EliminarProveedor
    @id_proveedor INT
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM Proveedor WHERE id_proveedor = @id_proveedor)
    BEGIN
        PRINT 'El proveedor no existe.';
        RETURN;
    END

    DELETE FROM Producto WHERE id_proveedor = @id_proveedor;
    DELETE FROM Proveedor WHERE id_proveedor = @id_proveedor;

    PRINT 'Proveedor y productos asociados eliminados correctamente.';
END
GO

----------------------------------------------
-- FUNCIÓN: Calcular Edad
----------------------------------------------
CREATE FUNCTION F_CalcularEdad(@fecha DATE)
RETURNS INT
AS
BEGIN
    IF @fecha IS NULL RETURN NULL;
    RETURN DATEDIFF(YEAR, @fecha, GETDATE());
END
GO

----------------------------------------------
-- FUNCIÓN: Usuarios Activos e Inactivos
----------------------------------------------
CREATE FUNCTION F_UsuariosActivosInactivos()
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @a INT, @i INT;

    SELECT @a = COUNT(*) FROM Usuario WHERE id_estado = 1;
    SELECT @i = COUNT(*) FROM Usuario WHERE id_estado = 0;

    RETURN CONCAT('Activos: ', @a, ' - Inactivos: ', @i);
END
GO

----------------------------------------------
-- FUNCIÓN: Cantidad de Ventas por Cliente
----------------------------------------------
CREATE FUNCTION F_CantidadVentasCliente(@dni VARCHAR(20))
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @cant INT, @nom VARCHAR(200);

    SELECT @cant = COUNT(*) FROM Venta WHERE DNI_cliente = @dni;
    SELECT @nom = nombre FROM Cliente WHERE DNI_cliente = @dni;

    RETURN CONCAT(@nom, ' - ', @cant, ' venta(s)');
END
GO

----------------------------------------------
-- FUNCIÓN TABULAR: Productos de un Proveedor
----------------------------------------------
CREATE FUNCTION F_ProductosDeProveedor(@id_proveedor INT)
RETURNS TABLE
AS
RETURN
(
    SELECT p.id_producto, p.descripcion, p.stock
    FROM Producto p
    WHERE p.id_proveedor = @id_proveedor
);
GO
