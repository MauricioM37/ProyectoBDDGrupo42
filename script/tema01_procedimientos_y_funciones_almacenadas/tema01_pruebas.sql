/* BASE DE DATOS I - 2025
   PROYECTO DE ESTUDIO - GRUPO 42
   Tema 1: Pruebas de Procedimientos y Funciones Almacenadas
   
   Descripción: Script de pruebas para validar el correcto funcionamiento
   de los stored procedures y funciones creados en tema01_script.sql
*/

USE BD_proyecto;

-- ========================================
-- SECCIÓN 1: PRUEBAS DE PROCEDIMIENTOS
-- ========================================

-- -----------------------------------------
-- Test 1.1: Inserción válida de producto
-- -----------------------------------------
SELECT '=== Test 1.1: Inserción válida de producto ===' AS test;

CALL SP_InsertarProducto(
    'Teclado Mecánico RGB',
    'Switches Cherry MX Red, iluminación RGB, reposamuñecas',
    150.00,
    25,
    2
);

-- Verificación
SELECT * FROM productos WHERE nombre_producto = 'Teclado Mecánico RGB';


-- -----------------------------------------
-- Test 1.2: Validación de precio negativo
-- -----------------------------------------
SELECT '=== Test 1.2: Validación de precio negativo ===' AS test;

-- Debe generar error
-- CALL SP_InsertarProducto('Producto Inválido', 'Test', -50.00, 10, 1);
-- Descomentar la línea anterior para ver el error


-- -----------------------------------------
-- Test 1.3: Validación de stock negativo
-- -----------------------------------------
SELECT '=== Test 1.3: Validación de stock negativo ===' AS test;

-- Debe generar error
-- CALL SP_InsertarProducto('Producto Inválido', 'Test', 50.00, -10, 1);


-- -----------------------------------------
-- Test 1.4: Validación de nombre duplicado
-- -----------------------------------------
SELECT '=== Test 1.4: Validación de nombre duplicado ===' AS test;

-- Debe generar error (producto ya existe)
-- CALL SP_InsertarProducto('Notebook Dell XPS', 'Duplicado', 1000.00, 5, 1);


-- -----------------------------------------
-- Test 2.1: Modificación de producto existente
-- -----------------------------------------
SELECT '=== Test 2.1: Modificación de producto ===' AS test;

-- Primero ver el estado actual
SELECT * FROM productos WHERE producto_id = 1;

-- Modificar
CALL SP_ModificarProducto(
    1,
    'Notebook Dell XPS 13 (Actualizado)',
    'Ultrabook 13 pulgadas, 32GB RAM, SSD 1TB - Versión 2025',
    2200.00,
    8
);

-- Verificación
SELECT * FROM productos WHERE producto_id = 1;


-- -----------------------------------------
-- Test 2.2: Modificación de producto inexistente
-- -----------------------------------------
SELECT '=== Test 2.2: Modificación de producto inexistente ===' AS test;

-- Debe generar error
-- CALL SP_ModificarProducto(9999, 'No existe', 'Test', 100.00, 10);


-- -----------------------------------------
-- Test 3.1: Eliminación lógica de producto
-- -----------------------------------------
SELECT '=== Test 3.1: Eliminación lógica de producto ===' AS test;

-- Ver estado antes de eliminar
SELECT producto_id, nombre_producto, estado FROM productos WHERE producto_id = 3;

-- Eliminar (baja lógica)
CALL SP_EliminarProducto(3);

-- Verificar que estado cambió a 0
SELECT producto_id, nombre_producto, estado FROM productos WHERE producto_id = 3;


-- -----------------------------------------
-- Test 4.1: Creación de pedido completo exitoso
-- -----------------------------------------
SELECT '=== Test 4.1: Creación de pedido completo ===' AS test;

-- Ver stock antes del pedido
SELECT producto_id, nombre_producto, stock FROM productos WHERE producto_id = 2;

-- Crear pedido de 2 unidades del producto 2
CALL SP_CrearPedidoCompleto(1, 2, 2, 'mercadopago');

-- Verificar stock después
SELECT producto_id, nombre_producto, stock FROM productos WHERE producto_id = 2;

-- Verificar que se creó el pedido
SELECT * FROM pedidos ORDER BY pedido_id DESC LIMIT 1;

-- Verificar detalles del pedido
SELECT * FROM detalles_pedido ORDER BY detalle_id DESC LIMIT 1;

-- Verificar pago registrado
SELECT * FROM pagos ORDER BY pago_id DESC LIMIT 1;


-- -----------------------------------------
-- Test 4.2: Creación de pedido con stock insuficiente
-- -----------------------------------------
SELECT '=== Test 4.2: Pedido con stock insuficiente ===' AS test;

-- Intentar pedir 1000 unidades (excede el stock)
-- Debe generar error
-- CALL SP_CrearPedidoCompleto(1, 1, 1000, 'efectivo');


-- -----------------------------------------
-- Test 4.3: Creación de pedido con usuario inexistente
-- -----------------------------------------
SELECT '=== Test 4.3: Pedido con usuario inexistente ===' AS test;

-- Debe generar error
-- CALL SP_CrearPedidoCompleto(9999, 1, 1, 'mercadopago');


-- -----------------------------------------
-- Test 4.4: Creación de pedido con producto inexistente
-- -----------------------------------------
SELECT '=== Test 4.4: Pedido con producto inexistente ===' AS test;

-- Debe generar error
-- CALL SP_CrearPedidoCompleto(1, 9999, 1, 'efectivo');


-- ========================================
-- SECCIÓN 2: PRUEBAS DE FUNCIONES
-- ========================================

-- -----------------------------------------
-- Test 5.1: Calcular antigüedad de usuarios
-- -----------------------------------------
SELECT '=== Test 5.1: Calcular antigüedad de usuarios ===' AS test;

SELECT 
    usuario_id,
    nombre,
    apellido,
    created_at,
    F_CalcularEdadUsuario(created_at) AS antiguedad_anios
FROM usuarios;


-- -----------------------------------------
-- Test 5.2: Resumen de usuarios por estado
-- -----------------------------------------
SELECT '=== Test 5.2: Resumen de usuarios por estado ===' AS test;

SELECT F_UsuariosActivosBaneados() AS resumen_estados;


-- -----------------------------------------
-- Test 5.3: Cantidad de pedidos por usuario
-- -----------------------------------------
SELECT '=== Test 5.3: Cantidad de pedidos por usuario ===' AS test;

SELECT F_CantidadPedidosUsuario(1) AS pedidos_usuario_1;
SELECT F_CantidadPedidosUsuario(2) AS pedidos_usuario_2;
SELECT F_CantidadPedidosUsuario(3) AS pedidos_usuario_3;


-- -----------------------------------------
-- Test 5.4: Listado de usuarios con sus pedidos
-- -----------------------------------------
SELECT '=== Test 5.4: Listado de usuarios con cantidad de pedidos ===' AS test;

SELECT 
    usuario_id,
    nombre,
    apellido,
    F_CantidadPedidosUsuario(usuario_id) AS detalle_pedidos
FROM usuarios
ORDER BY usuario_id;


-- -----------------------------------------
-- Test 6.1: Productos con bajo stock (umbral 15)
-- -----------------------------------------
SELECT '=== Test 6.1: Productos con stock menor a 15 ===' AS test;

CALL SP_ProductosBajoStock(15);


-- -----------------------------------------
-- Test 6.2: Productos con stock crítico (umbral 5)
-- -----------------------------------------
SELECT '=== Test 6.2: Productos con stock crítico (< 5) ===' AS test;

CALL SP_ProductosBajoStock(5);


-- ========================================
-- SECCIÓN 3: PRUEBAS DE INTEGRACIÓN
-- ========================================

-- -----------------------------------------
-- Test 7.1: Flujo completo - Crear producto y venderlo
-- -----------------------------------------
SELECT '=== Test 7.1: Flujo completo - Crear y vender producto ===' AS test;

-- Paso 1: Crear nuevo producto
CALL SP_InsertarProducto(
    'Monitor LG UltraWide 34"',
    '3440x1440, 144Hz, IPS, HDR400',
    650.00,
    10,
    1
);

-- Obtener el ID del producto recién creado
SET @nuevo_producto_id = LAST_INSERT_ID();

-- Paso 2: Verificar que se creó
SELECT * FROM productos WHERE producto_id = @nuevo_producto_id;

-- Paso 3: Crear pedido de 2 unidades
CALL SP_CrearPedidoCompleto(2, @nuevo_producto_id, 2, 'mercadopago');

-- Paso 4: Verificar stock actualizado (debe ser 8)
SELECT producto_id, nombre_producto, stock 
FROM productos 
WHERE producto_id = @nuevo_producto_id;


-- ========================================
-- SECCIÓN 4: CONSULTAS DE VERIFICACIÓN FINAL
-- ========================================

SELECT '=== VERIFICACIÓN FINAL: Estado del Sistema ===' AS test;

-- Resumen de productos
SELECT 
    COUNT(*) AS total_productos,
    SUM(CASE WHEN estado = 1 THEN 1 ELSE 0 END) AS productos_activos,
    SUM(CASE WHEN estado = 0 THEN 1 ELSE 0 END) AS productos_inactivos,
    SUM(stock) AS stock_total
FROM productos;

-- Resumen de pedidos
SELECT 
    COUNT(*) AS total_pedidos,
    SUM(monto_total) AS ventas_totales,
    AVG(monto_total) AS ticket_promedio
FROM pedidos;

-- Resumen de usuarios
SELECT F_UsuariosActivosBaneados() AS estado_usuarios;

-- Top 3 productos más vendidos
SELECT 
    p.nombre_producto,
    SUM(dp.cantidad) AS unidades_vendidas,
    SUM(dp.cantidad * dp.precio) AS ingresos_generados
FROM detalles_pedido dp
JOIN productos p ON dp.producto_id = p.producto_id
GROUP BY p.producto_id, p.nombre_producto
ORDER BY unidades_vendidas DESC
LIMIT 3;

SELECT '=== FIN DE PRUEBAS ===' AS test;
