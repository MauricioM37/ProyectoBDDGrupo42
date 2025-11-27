/* BASE DE DATOS I - 2025
   PROYECTO DE ESTUDIO - GRUPO 42
   Tema 1: Procedimientos y Funciones Almacenadas (MySQL)
   
   Descripción: Implementación de stored procedures y funciones para gestión
   de productos, usuarios y pedidos en el sistema de reservas BD_proyecto.
*/

USE BD_proyecto;

-- Configuración inicial
DELIMITER $$

----------------------------------------------
-- PROCEDIMIENTO 1: Insertar Producto
----------------------------------------------
DROP PROCEDURE IF EXISTS SP_InsertarProducto$$
CREATE PROCEDURE SP_InsertarProducto(
    IN p_nombre_producto VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_stock INT,
    IN p_categoria SMALLINT
)
BEGIN
    DECLARE v_mensaje VARCHAR(200);
    
    -- Validación: precio y stock no negativos
    IF p_precio < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio no puede ser negativo';
    END IF;
    
    IF p_stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El stock no puede ser negativo';
    END IF;
    
    -- Validación: nombre único
    IF EXISTS(SELECT 1 FROM productos WHERE nombre_producto = p_nombre_producto) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto ya existe con ese nombre';
    END IF;
    
    -- Inserción
    INSERT INTO productos(nombre_producto, descripcion_producto, precio, stock, categoria, estado, created_at)
    VALUES(p_nombre_producto, p_descripcion, p_precio, p_stock, p_categoria, 1, NOW());
    
    SELECT CONCAT('Producto creado correctamente con ID: ', LAST_INSERT_ID()) AS mensaje;
END$$

----------------------------------------------
-- PROCEDIMIENTO 2: Modificar Producto
----------------------------------------------
DROP PROCEDURE IF EXISTS SP_ModificarProducto$$
CREATE PROCEDURE SP_ModificarProducto(
    IN p_producto_id INT,
    IN p_nombre_producto VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_precio DECIMAL(10,2),
    IN p_stock INT
)
BEGIN
    -- Validación: producto existe
    IF NOT EXISTS(SELECT 1 FROM productos WHERE producto_id = p_producto_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Producto no encontrado';
    END IF;
    
    -- Validación: precio y stock válidos
    IF p_precio < 0 OR p_stock < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Precio y stock deben ser valores positivos';
    END IF;
    
    -- Actualización
    UPDATE productos
    SET nombre_producto = p_nombre_producto,
        descripcion_producto = p_descripcion,
        precio = p_precio,
        stock = p_stock
    WHERE producto_id = p_producto_id;
    
    SELECT 'Producto actualizado correctamente' AS mensaje;
END$$

----------------------------------------------
-- PROCEDIMIENTO 3: Eliminar Producto (Baja Lógica)
----------------------------------------------
DROP PROCEDURE IF EXISTS SP_EliminarProducto$$
CREATE PROCEDURE SP_EliminarProducto(
    IN p_producto_id INT
)
BEGIN
    IF NOT EXISTS(SELECT 1 FROM productos WHERE producto_id = p_producto_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El producto no existe';
    END IF;
    
    -- Baja lógica (no eliminación física para mantener integridad referencial)
    UPDATE productos
    SET estado = 0
    WHERE producto_id = p_producto_id;
    
    SELECT 'Producto dado de baja correctamente' AS mensaje;
END$$

----------------------------------------------
-- PROCEDIMIENTO 4: Crear Pedido Completo
-- (Integra creación de pedido, detalle, pago y actualización de stock)
----------------------------------------------
DROP PROCEDURE IF EXISTS SP_CrearPedidoCompleto$$
CREATE PROCEDURE SP_CrearPedidoCompleto(
    IN p_usuario_id INT,
    IN p_producto_id INT,
    IN p_cantidad INT,
    IN p_metodo_pago ENUM('mercadopago', 'efectivo')
)
BEGIN
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_stock_actual INT;
    DECLARE v_monto_total DECIMAL(10,2);
    DECLARE v_pedido_id INT;
    
    -- Validación: usuario existe
    IF NOT EXISTS(SELECT 1 FROM usuarios WHERE usuario_id = p_usuario_id) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuario no encontrado';
    END IF;
    
    -- Validación: producto existe y está activo
    SELECT precio, stock INTO v_precio, v_stock_actual
    FROM productos
    WHERE producto_id = p_producto_id AND estado = 1;
    
    IF v_precio IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Producto no encontrado o inactivo';
    END IF;
    
    -- Validación: stock suficiente
    IF v_stock_actual < p_cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock insuficiente para completar el pedido';
    END IF;
    
    -- Calcular monto total
    SET v_monto_total = v_precio * p_cantidad;
    
    -- Iniciar transacción
    START TRANSACTION;
    
    -- 1. Crear pedido
    INSERT INTO pedidos(usuario_id, estado_pedido, estado_pago, monto_total, detalles, created_at)
    VALUES(p_usuario_id, 'pendiente', 'no pagado', v_monto_total, 'Pedido creado vía SP', NOW());
    
    SET v_pedido_id = LAST_INSERT_ID();
    
    -- 2. Insertar detalle
    INSERT INTO detalles_pedido(pedido_id, producto_id, cantidad, precio)
    VALUES(v_pedido_id, p_producto_id, p_cantidad, v_precio);
    
    -- 3. Actualizar stock
    UPDATE productos
    SET stock = stock - p_cantidad
    WHERE producto_id = p_producto_id;
    
    -- 4. Registrar pago
    INSERT INTO pagos(metodo, monto, estado, pedido_id, pago_id_provider)
    VALUES(p_metodo_pago, v_monto_total, 'completado', v_pedido_id, CONCAT('SP-TXN-', v_pedido_id));
    
    COMMIT;
    
    SELECT CONCAT('Pedido creado exitosamente. ID: ', v_pedido_id) AS mensaje,
           v_pedido_id AS pedido_id,
           v_monto_total AS monto_total;
END$$

----------------------------------------------
-- FUNCIÓN 1: Calcular Antigüedad de Usuario (en años)
----------------------------------------------
DROP FUNCTION IF EXISTS F_CalcularEdadUsuario$$
CREATE FUNCTION F_CalcularEdadUsuario(p_fecha_creacion TIMESTAMP)
RETURNS INT
DETERMINISTIC
BEGIN
    IF p_fecha_creacion IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN TIMESTAMPDIFF(YEAR, p_fecha_creacion, NOW());
END$$

----------------------------------------------
-- FUNCIÓN 2: Resumen de Usuarios por Estado
----------------------------------------------
DROP FUNCTION IF EXISTS F_UsuariosActivosBaneados$$
CREATE FUNCTION F_UsuariosActivosBaneados()
RETURNS VARCHAR(200)
READS SQL DATA
BEGIN
    DECLARE v_activos INT;
    DECLARE v_baneados INT;
    DECLARE v_eliminados INT;
    
    SELECT COUNT(*) INTO v_activos FROM usuarios WHERE estado = 'activo';
    SELECT COUNT(*) INTO v_baneados FROM usuarios WHERE estado = 'baneado';
    SELECT COUNT(*) INTO v_eliminados FROM usuarios WHERE estado = 'eliminado';
    
    RETURN CONCAT('Activos: ', v_activos, ' - Baneados: ', v_baneados, ' - Eliminados: ', v_eliminados);
END$$

----------------------------------------------
-- FUNCIÓN 3: Cantidad de Pedidos por Usuario
----------------------------------------------
DROP FUNCTION IF EXISTS F_CantidadPedidosUsuario$$
CREATE FUNCTION F_CantidadPedidosUsuario(p_usuario_id INT)
RETURNS VARCHAR(200)
READS SQL DATA
BEGIN
    DECLARE v_cantidad INT;
    DECLARE v_nombre VARCHAR(100);
    
    SELECT COUNT(*) INTO v_cantidad FROM pedidos WHERE usuario_id = p_usuario_id;
    SELECT CONCAT(nombre, ' ', apellido) INTO v_nombre FROM usuarios WHERE usuario_id = p_usuario_id;
    
    IF v_nombre IS NULL THEN
        RETURN 'Usuario no encontrado';
    END IF;
    
    RETURN CONCAT(v_nombre, ' - ', v_cantidad, ' pedido(s)');
END$$

----------------------------------------------
-- FUNCIÓN TABULAR: Productos con Bajo Stock
----------------------------------------------
DROP FUNCTION IF EXISTS F_ProductosBajoStock$$
CREATE FUNCTION F_ProductosBajoStock(p_umbral INT)
RETURNS TABLE
RETURN
(
    SELECT 
        producto_id,
        nombre_producto,
        stock,
        precio
    FROM productos
    WHERE stock < p_umbral AND estado = 1
    ORDER BY stock ASC
)$$

DELIMITER ;

----------------------------------------------
-- VERIFICACIÓN: Mostrar procedimientos y funciones creados
----------------------------------------------
SELECT 'Procedimientos y funciones creados exitosamente' AS status;

SHOW PROCEDURE STATUS WHERE Db = 'BD_proyecto';
SHOW FUNCTION STATUS WHERE Db = 'BD_proyecto';
