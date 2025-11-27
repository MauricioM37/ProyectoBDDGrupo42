-- MySQL: Transacción que fuerza rollback con SIGNAL
USE BD_proyecto;
SET autocommit = 0;

START TRANSACTION;

BEGIN
    -- Insert pedido
    INSERT INTO pedidos(usuario_id, estado_pedido, estado_pago, monto_total, detalles, created_at)
    VALUES (1, 'pendiente', 'no pagado', 100.00, 'Pedido rollback demo', NOW());
    SET @pid = LAST_INSERT_ID();

    -- Insert detalle
    INSERT INTO detalles_pedido(pedido_id, producto_id, cantidad, precio)
    VALUES (@pid, 999999, 1, 100.00); -- producto_id inexistente para provocar FK error o fuerza de signal

    -- Force manual error (alternative if FK doesn't fail)
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error simulado: probando rollback intencional';
END;

-- Si se llega aquí sin errores, commit (raro)
COMMIT;
SET autocommit = 1;

SELECT 'FIN' AS estado, @pid_main AS pedido_id;
