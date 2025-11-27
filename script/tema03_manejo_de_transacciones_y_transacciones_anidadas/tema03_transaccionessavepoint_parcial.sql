-- MySQL: Transacción con SAVEPOINT para rollback parcial
USE BD_proyecto;
SET autocommit = 0;

START TRANSACTION;

-- Paso A: insertar un registro de pedido preliminar
INSERT INTO pedidos(usuario_id, estado_pedido, estado_pago, monto_total, detalles, created_at)
VALUES (2, 'pendiente', 'no pagado', 50.00, 'Pedido con savepoint', NOW());
SET @pid_main = LAST_INSERT_ID();

-- Guardamos punto de recuperación
SAVEPOINT sp_after_header;

-- Paso B: intentamos agregar detalle y actualizar stock
BEGIN
    INSERT INTO detalles_pedido(pedido_id, producto_id, cantidad, precio)
    VALUES (@pid_main, 3, 1, 50.00);

    -- Forzamos error: si stock insuficiente, o se puede SIGNAL
    -- Ejemplo de comprobación: si stock < 1, forzar error
    SELECT stock INTO @s FROM productos WHERE producto_id = 3;
    IF @s < 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stock insuficiente para producto 3';
    END IF;

    -- Si llega bien, actualizamos stock
    UPDATE productos SET stock = stock - 1 WHERE producto_id = 3;
END;

-- Simulamos fallo y hacemos rollback parcial al savepoint (si fuera necesario)
-- PARA PROPÓSITOS DE DEMO: descomentar la siguiente línea para forzar rollback parcial
-- ROLLBACK TO SAVEPOINT sp_after_header;

-- Confirmamos transacción total (si no se hizo rollback parcial)
COMMIT;
SET autocommit = 1;

SELECT 'FIN' AS estado, @pid_main AS pedido_id;
