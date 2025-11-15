-- Consultas de verificación después de ejecutar los scripts
USE BD_proyecto;

-- 1) Verificar pedidos recientes (ultimas 30 filas)
SELECT * FROM pedidos ORDER BY created_at DESC LIMIT 30;

-- 2) Verificar detalles de los pedidos creados en pruebas (por usuario/fecha)
SELECT * FROM detalles_pedido ORDER BY detalle_id DESC LIMIT 30;

-- 3) Verificar pagos recientes
SELECT * FROM pagos ORDER BY pago_id DESC LIMIT 30;

-- 4) Verificar stock de productos involucrados (ids 1,2,3 usados en scripts)
SELECT producto_id, nombre_producto, stock FROM productos WHERE producto_id IN (1,2,3);
