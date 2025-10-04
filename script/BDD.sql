 drop database if EXISTS `BD_proyecto`;
 CREATE DATABASE `BD_proyecto`;
USE `BD_proyecto`;

CREATE TABLE `usuarios` (
  `usuario_id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) DEFAULT NULL,
  `nombre_usuario` varchar(50) DEFAULT NULL,
  `estado` enum('activo','baneado','eliminado') DEFAULT NULL,
  `telefono` varchar(20) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `pass` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT (now()),
  PRIMARY KEY (`usuario_id`),
  UNIQUE KEY `nombre_usuario` (`nombre_usuario`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `usuarios` VALUES
  (1,'Juan','Pérez','juanp','activo','1122334455','juan@example.com','hashed_pass_1','2025-08-18 03:50:09'),
  (2,'María','González','mariag','activo','1199887766','maria@example.com','hashed_pass_2','2025-08-18 03:50:09'),
  (3,'Admin','Root','admin','activo','1100000000','admin@example.com','hashed_pass_3','2025-08-18 03:50:09');


CREATE TABLE `productos` (
  `producto_id` int NOT NULL AUTO_INCREMENT,
  `nombre_producto` varchar(100) NOT NULL,
  `descripcion_producto` text,
  `precio` decimal(10,2) NOT NULL,
  `categoria` smallint DEFAULT NULL,
  `stock` int NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `estado` smallint DEFAULT '1',
  `created_at` timestamp NULL DEFAULT (now()),
  PRIMARY KEY (`producto_id`),
  CONSTRAINT `productos_chk_1` CHECK ((`precio` >= 0)),
  CONSTRAINT `productos_chk_2` CHECK ((`stock` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `productos` VALUES
  (1,'Notebook Dell XPS','Ultrabook 13 pulgadas, 16GB RAM, SSD 512GB',1800.00,1,10,'https://cdn.example.com/dellxps.jpg',1,'2025-08-18 03:50:09'),
  (2,'Auriculares Sony WH-1000XM4','Noise cancelling, Bluetooth 5.0',350.00,2,30,'https://cdn.example.com/sonywh1000xm4.jpg',1,'2025-08-18 03:50:09'),
  (3,'Smartphone Samsung S22','128GB, 8GB RAM, Cámara 108MP',1200.00,1,25,'https://cdn.example.com/samsungs22.jpg',1,'2025-08-18 03:50:09');


CREATE TABLE `pedidos` (
  `pedido_id` int NOT NULL AUTO_INCREMENT,
  `usuario_id` int NOT NULL,
  `estado_pedido` enum('pendiente','enviado','en camino','cancelado') DEFAULT 'pendiente',
  `estado_pago` enum('no pagado','pagado','fallido','reembolsado') DEFAULT NULL,
  `monto_total` decimal(10,2) NOT NULL,
  `detalles` varchar(250) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`pedido_id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `pedidos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO `pedidos` VALUES
  (1,1,'pendiente','pagado',1800.00,'Compra online','2025-08-18 03:50:09'),
  (2,2,'pendiente','pagado',1550.00,'Compra auriculares y smartphone','2025-08-18 03:50:09');


CREATE TABLE `detalles_pedido` (
  `detalle_id` int NOT NULL AUTO_INCREMENT,
  `pedido_id` int NOT NULL,
  `producto_id` int NOT NULL,
  `cantidad` int NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  PRIMARY KEY (`detalle_id`),
  KEY `pedido_id` (`pedido_id`),
  KEY `producto_id` (`producto_id`),
  CONSTRAINT `detalles_pedido_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`pedido_id`),
  CONSTRAINT `detalles_pedido_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`producto_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `detalles_pedido` VALUES
  (1,1,1,1,1800.00),
  (2,2,2,1,350.00),
  (3,2,3,1,1200.00);

CREATE TABLE `pagos` (
  `pago_id` int NOT NULL AUTO_INCREMENT,
  `metodo` enum('mercadopago','efectivo') DEFAULT NULL,
  `monto` decimal(10,2) DEFAULT NULL,
  `estado` enum('iniciado','completado','fallido','reembolsado') DEFAULT NULL,
  `pedido_id` int DEFAULT NULL,
  `pago_id_provider` varchar(250) DEFAULT NULL,
  PRIMARY KEY (`pago_id`),
  UNIQUE KEY `pago_id_provider` (`pago_id_provider`),
  KEY `pedido_id` (`pedido_id`),
  CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`pedido_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
INSERT INTO `pagos` VALUES
  (1,'mercadopago',1800.00,'completado',1,'MP-TXN-001'),
  (2,'mercadopago',1550.00,'completado',2,'PP-TXN-002');




