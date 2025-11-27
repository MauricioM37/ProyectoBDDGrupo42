/* BASE DE DATOS I - 2024 
   PROYECTO DE ESTUDIO - GRUPO 42
   Tema 2: Optimización de consultas a través de índices
*/

USE BD_proyecto;

--------------------------------------------------------------
-- 1) Carga masiva de datos (1 millón de registros)
--------------------------------------------------------------

-- Creación de tablas de prueba
-- Pedidos1 → sin índices adicionales
-- Pedidos2 → se usarán para pruebas con índices

CREATE TABLE Pedidos1 (
    id_pedido INT IDENTITY(1,1),
    id_usuario INT,
    status VARCHAR(30),
    total DECIMAL(10,2),
    created_at DATE,
    CONSTRAINT PK_Pedidos1 PRIMARY KEY (id_pedido)
);

CREATE TABLE Pedidos2 (
    id_pedido INT IDENTITY(1,1),
    id_usuario INT,
    status VARCHAR(30),
    total DECIMAL(10,2),
    created_at DATE,
    CONSTRAINT PK_Pedidos2 PRIMARY KEY (id_pedido)
);

-- Variables
DECLARE @FechaFin DATETIME = '2024-12-31';
DECLARE @FechaInicio DATETIME = DATEADD(DAY, -1825, @FechaFin); -- últimos 5 años
DECLARE @NumRegistros INT = 1000000;

-- Tabla temporal
CREATE TABLE #TempPedidos (
    created_at DATETIME,
    id_usuario INT,
    status VARCHAR(30),
    total DECIMAL(10,2)
);

-- Generación de registros
DECLARE @i INT = 1;

WHILE @i <= @NumRegistros
BEGIN
    DECLARE @RandomDays INT = FLOOR(RAND() * DATEDIFF(DAY, @FechaInicio, @FechaFin));
    DECLARE @FechaPedido DATETIME = DATEADD(DAY, @RandomDays, @FechaInicio);

    DECLARE @TotalPedido DECIMAL(10,2) = ROUND(RAND() * 50000, 2);
    DECLARE @Usuario INT = ABS(CHECKSUM(NEWID())) % 50000 + 1;

    INSERT INTO #TempPedidos (created_at, id_usuario, status, total)
    VALUES (@FechaPedido, @Usuario, 'completado', @TotalPedido);

    SET @i = @i + 1;
END;

-- Inserción final
INSERT INTO Pedidos1 (created_at, id_usuario, status, total)
SELECT created_at, id_usuario, status, total FROM #TempPedidos;

INSERT INTO Pedidos2 (created_at, id_usuario, status, total)
SELECT created_at, id_usuario, status, total FROM #TempPedidos;

DROP TABLE #TempPedidos;

--------------------------------------------------------------
-- 2) Consulta sin índice (TABLE SCAN)
--------------------------------------------------------------

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT *
FROM Pedidos1
WHERE created_at BETWEEN '2024-01-01' AND '2024-02-01'
ORDER BY created_at ASC;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

--------------------------------------------------------------
-- 3) Crear índice agrupado por fecha y repetir consulta
--------------------------------------------------------------

-- A) Eliminar PK (clustered actual)
ALTER TABLE Pedidos2 DROP CONSTRAINT PK_Pedidos2;

-- B) Crear índice agrupado
CREATE CLUSTERED INDEX IDX_Pedidos2_CreatedAt
ON Pedidos2(created_at);

-- C) Crear PK como índice no agrupado
ALTER TABLE Pedidos2 ADD CONSTRAINT PK_Pedidos2 
PRIMARY KEY NONCLUSTERED (id_pedido);

-- D) Ejecutar consulta nuevamente
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT *
FROM Pedidos2
WHERE created_at BETWEEN '2024-01-01' AND '2024-02-01'
ORDER BY created_at ASC;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

--------------------------------------------------------------
-- 4) Borrar el índice creado
--------------------------------------------------------------

DROP INDEX IDX_Pedidos2_CreatedAt ON Pedidos2;

--------------------------------------------------------------
-- 5) Crear índice no agrupado con INCLUDE
--------------------------------------------------------------

CREATE NONCLUSTERED INDEX IDX_Pedidos2_CreatedAt_Include
ON Pedidos2(created_at)
INCLUDE (id_pedido, total, id_usuario, status);

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

SELECT *
FROM Pedidos2
WHERE created_at BETWEEN '2024-01-01' AND '2024-02-01'
ORDER BY created_at ASC;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

--------------------------------------------------------------
-- 6) Comparación final entre tabla sin índice y con índice
--------------------------------------------------------------

SELECT *
FROM Pedidos1
WHERE created_at BETWEEN '2024-01-01' AND '2024-02-01'
ORDER BY created_at ASC;

SELECT *
FROM Pedidos2
WHERE created_at BETWEEN '2024-01-01' AND '2024-02-01'
ORDER BY created_at ASC;
