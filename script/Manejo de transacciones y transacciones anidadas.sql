
USE TiendaEmprendedores;

/*
TEMA: Manejo de transacciones y transacciones anidadas

Consignas:
1) Insertar un registro en una tabla, luego otro en otra tabla y actualizar un registro,
   confirmando todo únicamente si no ocurre ningún error.

2) Provocar un error intencional y verificar que los datos queden consistentes (ROLLBACK total).

3) Implementar una transacción anidada mediante SAVEPOINT.
*/

/* ---------------------------------------------------------------------------------------------
   PASO 1: TRANSACCIÓN COMPLETA Y EXITOSA
----------------------------------------------------------------------------------------------*/
PRINT '--- PASO 1: TRANSACCIÓN EXITOSA ---';
BEGIN TRAN;

BEGIN TRY

    DECLARE @idFactura INT;
    SELECT @idFactura = ISNULL(MAX(id_factura),0) + 1
    FROM Factura WITH (UPDLOCK, HOLDLOCK);

    INSERT INTO Factura(id_factura, fecha, Total, id_usuarios)
    VALUES (@idFactura, GETDATE(), 0, 1);

    DECLARE @idProd INT = 10, @cant INT = 2, @precio FLOAT;
    SELECT @precio = precio FROM Producto WHERE id_producto = @idProd;

    INSERT INTO DetalleFactura(id_producto, id_factura, cantidad, precio_unitario)
    VALUES (@idProd, @idFactura, @cant, @precio);

    IF (SELECT stock FROM Producto WHERE id_producto = @idProd) < @cant
        THROW 50001, 'Stock insuficiente.', 1;

    UPDATE Producto
       SET stock = stock - @cant
     WHERE id_producto = @idProd;

    UPDATE Factura
       SET Total = (SELECT SUM(cantidad * precio_unitario)
                    FROM DetalleFactura WHERE id_factura = @idFactura)
     WHERE id_factura = @idFactura;

    COMMIT TRAN;
    PRINT 'Paso 1 COMPLETADO correctamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    PRINT 'ERROR en Paso 1 (se revierte todo)';
    PRINT ERROR_MESSAGE();
END CATCH;

/* ---------------------------------------------------------------------------------------------
   PASO 2: TRANSACCIÓN CON ERROR INTENCIONAL
----------------------------------------------------------------------------------------------*/
PRINT '--- PASO 2: TRANSACCIÓN CON ERROR INTENCIONAL ---';
BEGIN TRAN;

BEGIN TRY

    DECLARE @idFactura2 INT;
    SELECT @idFactura2 = ISNULL(MAX(id_factura),0) + 1
    FROM Factura WITH (UPDLOCK, HOLDLOCK);

    INSERT INTO Factura(id_factura, fecha, Total, id_usuarios)
    VALUES (@idFactura2, GETDATE(), 0, 1);

    INSERT INTO DetalleFactura(id_producto, id_factura, cantidad, precio_unitario)
    VALUES (9999, @idFactura2, 1, 100);

    COMMIT TRAN;
    PRINT 'Paso 2 OK (no debería ocurrir)';

END TRY
BEGIN CATCH

    ROLLBACK TRAN;
    PRINT 'Se ejecutó ROLLBACK en Paso 2 por error intencional.';
    PRINT ERROR_MESSAGE();

END CATCH;

/* ---------------------------------------------------------------------------------------------
   PASO 3: TRANSACCIÓN ANIDADA CON SAVEPOINT
----------------------------------------------------------------------------------------------*/
PRINT '--- PASO 3: TRANSACCIÓN CON SAVEPOINT ---';
BEGIN TRAN;

BEGIN TRY

    DECLARE @idFactura3 INT;
    SELECT @idFactura3 = ISNULL(MAX(id_factura),0) + 1
    FROM Factura WITH (UPDLOCK, HOLDLOCK);

    INSERT INTO Factura(id_factura, fecha, Total, id_usuarios)
    VALUES (@idFactura3, GETDATE(), 0, 2);

    DECLARE @idProd3 INT = 10, @cant3 INT = 60, @precio3 FLOAT;
    SELECT @precio3 = precio FROM Producto WHERE id_producto = @idProd3;

    INSERT INTO DetalleFactura(id_producto, id_factura, cantidad, precio_unitario)
    VALUES (@idProd3, @idFactura3, @cant3, @precio3);

    SAVE TRAN SP_Stock;

    IF (SELECT stock FROM Producto WHERE id_producto = @idProd3) < @cant3
    BEGIN
        ROLLBACK TRAN SP_Stock;
        THROW 51010, 'No se puede actualizar stock. SAVEPOINT ejecutado.', 1;
    END

    UPDATE Producto
       SET stock = stock - @cant3
     WHERE id_producto = @idProd3;

    UPDATE Factura
       SET Total = (SELECT SUM(cantidad * precio_unitario)
                    FROM DetalleFactura WHERE id_factura = @idFactura3)
     WHERE id_factura = @idFactura3;

    COMMIT TRAN;
    PRINT 'Paso 3 COMPLETADO.';

END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    PRINT 'ERROR en Paso 3 (rollback total).';
    PRINT ERROR_MESSAGE();
END CATCH;

/* ---------------------------------------------------------------------------------------------
   FIN DEL SCRIPT
----------------------------------------------------------------------------------------------*/
