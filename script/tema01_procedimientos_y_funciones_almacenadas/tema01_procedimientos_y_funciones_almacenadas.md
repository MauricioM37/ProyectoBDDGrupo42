# Tema 1 — Procedimientos y Funciones Almacenadas

## Introducción

Los **procedimientos almacenados** y **funciones** son bloques de código SQL que se almacenan en el servidor de base de datos y pueden ser invocados múltiples veces. Estos objetos permiten encapsular lógica de negocio compleja, mejorar el rendimiento y facilitar el mantenimiento del sistema.

En el contexto de **BD_proyecto** (sistema de reservas de productos), implementamos procedimientos y funciones para gestionar operaciones críticas como la creación de productos, generación de pedidos completos y consultas de información agregada.

---

## Conceptos Fundamentales

### Procedimientos Almacenados (Stored Procedures)

Un **procedimiento almacenado** es un conjunto de instrucciones SQL que se compilan y almacenan en el servidor. Pueden:

- Aceptar parámetros de entrada y salida
- Ejecutar operaciones de lectura/escritura (SELECT, INSERT, UPDATE, DELETE)
- Contener lógica condicional y transaccional
- Retornar múltiples conjuntos de resultados

**Ventajas:**

- Reducción del tráfico de red (una sola llamada ejecuta múltiples operaciones)
- Reutilización de código
- Mejora en la seguridad (control de permisos granular)
- Mantenimiento centralizado de lógica de negocio

**Sintaxis básica en MySQL:**

```sql
DELIMITER $$
CREATE PROCEDURE NombreProcedimiento(
    IN parametro1 tipo,
    OUT parametro2 tipo
)
BEGIN
    -- Lógica del procedimiento
END$$
DELIMITER ;
```

### Funciones (Functions)

Una **función** es similar a un procedimiento pero está diseñada para retornar un único valor. Se utilizan típicamente en consultas SELECT, WHERE o expresiones.

**Diferencias con procedimientos:**

- Siempre retornan un valor
- No pueden modificar el estado de la base de datos (en funciones deterministas)
- Se usan como expresiones dentro de consultas

**Tipos de funciones:**

- **Funciones escalares**: Retornan un único valor (INT, VARCHAR, etc.)
- **Funciones tabulares**: Retornan una tabla (disponible en MySQL 8.0+)

**Sintaxis básica:**

```sql
DELIMITER $$
CREATE FUNCTION NombreFuncion(parametro tipo)
RETURNS tipo_retorno
DETERMINISTIC
BEGIN
    DECLARE variable tipo;
    -- Lógica
    RETURN variable;
END$$
DELIMITER ;
```

---

## Implementación en BD_proyecto

### Caso de Uso 1: Gestión de Productos

**Problema**: Necesitamos validar datos antes de insertar productos y mantener consistencia.

**Solución**: `SP_InsertarProducto`

Este procedimiento valida:

- Precios y stocks no negativos
- Nombres únicos de productos
- Datos completos antes de inserción

```sql
CALL SP_InsertarProducto('Mouse Gamer', 'RGB 16000 DPI', 75.50, 30, 2);
```

**Beneficio**: La aplicación cliente no necesita implementar estas validaciones, reduciendo código duplicado.

---

### Caso de Uso 2: Creación Transaccional de Pedidos

**Problema**: Crear un pedido requiere múltiples operaciones atómicas:

1. Insertar registro en `pedidos`
2. Insertar detalle en `detalles_pedido`
3. Descontar stock en `productos`
4. Registrar pago en `pagos`

Si alguna operación falla, todas deben revertirse.

**Solución**: `SP_CrearPedidoCompleto`

Este procedimiento implementa:

- Validación de stock disponible
- Transacciones ACID (START TRANSACTION / COMMIT)
- Cálculo automático de montos
- Manejo de errores con SIGNAL

```sql
CALL SP_CrearPedidoCompleto(1, 2, 3, 'mercadopago');
-- Crea pedido para usuario 1, 3 unidades del producto 2, pago por MercadoPago
```

**Beneficio**: Garantiza integridad de datos incluso bajo alta concurrencia.

---

### Caso de Uso 3: Consultas de Información Agregada

**Problema**: Necesitamos reportes frecuentes sobre usuarios y pedidos.

**Solución**: Funciones escalares

- `F_UsuariosActivosBaneados()`: Resumen de estados de usuarios
- `F_CantidadPedidosUsuario(usuario_id)`: Total de pedidos por usuario

```sql
SELECT F_UsuariosActivosBaneados();
-- Resultado: "Activos: 15 - Baneados: 2 - Eliminados: 1"

SELECT nombre, F_CantidadPedidosUsuario(usuario_id)
FROM usuarios WHERE usuario_id = 1;
-- Resultado: "Juan Pérez - 5 pedido(s)"
```

**Beneficio**: Consultas más legibles y lógica centralizada para reportes.

---

### Caso de Uso 4: Productos con Stock Crítico

**Problema**: Alertar sobre productos que requieren reposición.

**Solución**: `F_ProductosBajoStock(umbral)` (Función tabular)

```sql
SELECT * FROM F_ProductosBajoStock(10);
-- Retorna productos con menos de 10 unidades
```

**Beneficio**: Filtrado dinámico para sistemas de alertas de inventario.

---

## Ventajas de Esta Implementación

### 1. **Rendimiento Mejorado**

- Compilación única del código SQL
- Reducción de round-trips entre aplicación y base de datos
- Aprovechamiento del plan de ejecución cacheado

### 2. **Seguridad Reforzada**

- Control de acceso granular (permisos EXECUTE)
- Prevención de inyección SQL (parámetros validados)
- Ocultamiento de estructura de tablas a aplicaciones

### 3. **Mantenimiento Simplificado**

- Cambios en lógica de negocio sin recompilar aplicaciones
- Debugging centralizado
- Versionado de procedimientos

### 4. **Integridad de Datos**

- Validaciones consistentes en un solo lugar
- Transacciones atómicas para operaciones complejas
- Prevención de estados inconsistentes

---

## Mejores Prácticas Aplicadas

### ✅ Nomenclatura Clara

- Prefijo `SP_` para procedimientos
- Prefijo `F_` para funciones
- Nombres descriptivos en español

### ✅ Validación Exhaustiva

- Verificación de existencia de registros
- Validación de rangos de valores
- Manejo explícito de errores con `SIGNAL`

### ✅ Uso de Transacciones

- `START TRANSACTION` en operaciones críticas
- `COMMIT` explícito tras validaciones exitosas
- Rollback automático en caso de error

### ✅ Documentación Inline

- Comentarios descriptivos en cada sección
- Explicación de parámetros y retornos
- Ejemplos de uso en encabezados

---

## Comparación: Procedimientos vs Funciones

| Característica            | Procedimiento                   | Función                                      |
| ------------------------- | ------------------------------- | -------------------------------------------- |
| **Retorno**               | Opcional (múltiples resultados) | Obligatorio (un valor)                       |
| **Modificación de datos** | Sí (INSERT, UPDATE, DELETE)     | No (solo lectura en funciones deterministas) |
| **Uso en SELECT**         | No                              | Sí                                           |
| **Transacciones**         | Sí                              | Limitado                                     |
| **Parámetros OUT**        | Sí                              | No                                           |
| **Caso de uso típico**    | Operaciones complejas CRUD      | Cálculos y transformaciones                  |

---

## Relación con Otros Temas del Proyecto

### **Tema 2: Optimización con Índices**

Los procedimientos se benefician de índices en columnas frecuentemente consultadas:

- `producto_id` en `productos` (Primary Key)
- `usuario_id` en `pedidos` (Foreign Key)
- `estado` en `productos` para filtrados

### **Tema 3: Transacciones**

`SP_CrearPedidoCompleto` implementa control transaccional similar al estudiado en:

- `tema03_transacciones_crear_pedido_completo.sql`
- Uso de COMMIT y manejo de errores

### **Proyecto de Réplicas**

- Procedimientos se replican automáticamente en arquitectura maestro-esclavo
- Llamadas a procedimientos en maestro aseguran consistencia en réplicas

---

## Limitaciones y Consideraciones

### ⚠️ Portabilidad Reducida

- Sintaxis específica de MySQL (no compatible con PostgreSQL/SQL Server sin adaptaciones)
- Funciones tabulares (`RETURNS TABLE`) requieren MySQL 8.0+

### ⚠️ Debugging Complejo

- Errores menos visibles que en código de aplicación
- Requiere herramientas especializadas para debugging (MySQL Workbench)

### ⚠️ Versioning Desafiante

- No existe control de versiones nativo
- Cambios requieren `DROP` y `CREATE` (permisos administrativos)

### ⚠️ Sobrecarga del Servidor

- Lógica compleja puede consumir recursos del servidor de BD
- Balance necesario entre lógica en BD vs. capa de aplicación

---

## Ejemplos de Pruebas

### Test 1: Inserción Válida

```sql
CALL SP_InsertarProducto('Teclado Mecánico', 'Switches Blue', 120.00, 15, 2);
-- Esperado: "Producto creado correctamente con ID: X"
```

### Test 2: Validación de Precio Negativo

```sql
CALL SP_InsertarProducto('Producto Test', 'Inválido', -50.00, 10, 1);
-- Esperado: Error 1644 - "El precio no puede ser negativo"
```

### Test 3: Creación de Pedido con Stock Insuficiente

```sql
-- Producto 1 tiene stock = 10
CALL SP_CrearPedidoCompleto(1, 1, 20, 'efectivo');
-- Esperado: Error - "Stock insuficiente para completar el pedido"
```

### Test 4: Consulta de Usuarios Activos

```sql
SELECT F_UsuariosActivosBaneados();
-- Resultado esperado según datos iniciales: "Activos: 3 - Baneados: 0 - Eliminados: 0"
```

---

## Conclusiones

La implementación de **procedimientos y funciones almacenadas** en `BD_proyecto` demuestra cómo encapsular lógica de negocio crítica dentro del motor de base de datos, logrando:

1. **Mayor consistencia**: Validaciones centralizadas evitan datos corruptos
2. **Mejor rendimiento**: Reducción significativa de latencia de red
3. **Seguridad mejorada**: Control granular de acceso a operaciones sensibles
4. **Facilidad de mantenimiento**: Actualizaciones sin modificar código cliente

En sistemas de reservas con alta concurrencia como el implementado, estas técnicas son fundamentales para garantizar **integridad transaccional** y **escalabilidad** del sistema.

---

## Referencias

- MySQL 8.4 Reference Manual: Stored Programs
- Elmasri & Navathe (2017): "Sistemas de Bases de Datos" - Capítulo 10
- Material de Cátedra: Bases de Datos I, UNNE 2025
