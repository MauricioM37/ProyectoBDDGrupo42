-- MySQL: Transacción completa que crea pedido + detalles + pago + actualiza stock
USE BD_proyecto;
SET autocommit = 0;

START TRANSACTION;

-- Variables de ejemplo (puede ejecutarse tal cual o parametrizarse según cliente)
-- Pedido para usuario_id = 1 con 2 items (producto_id 1 y 2)
-- Ajustar valores si no existen esos ids en tu BD de pruebas

INSERT INTO pedidos(usuario_id, estado_pedido, estado_pago, monto_total, detalles, created_at)
VALUES (1, 'pendiente', 'no pagado', 2150.00, 'Pedido desde script tx', NOW());

-- obtener id del pedido insertado
SET @pedido_id = LAST_INSERT_ID();

-- Detalles (dos productos)
INSERT INTO detalles_pedido(pedido_id, producto_id, cantidad, precio)
VALUES
  (@pedido_id, 1, 1, 1800.00),
  (@pedido_id, 2, 1, 350.00);

-- Actualizar stock de los productos (verificar stock suficiente)
-- Ejemplo simple: descontar la cantidad
UPDATE productos
SET stock = stock - 1
WHERE producto_id = 1;

UPDATE productos
SET stock = stock - 1
WHERE producto_id = 2;

-- Insertar registro de pago (simulado)
INSERT INTO pagos(metodo, monto, estado, pedido_id, pago_id_provider)
VALUES ('mercadopago', 2150.00, 'completado', @pedido_id, CONCAT('MP-TXN-', @pedido_id));

COMMIT;
SET autocommit = 1;

-- Resultado para verificación (opcional al final)
SELECT 'OK' AS estado, @pedido_id AS pedido_creado;
