**Tema 3 — Manejo de transacciones y transacciones anidadas (MySQL / BD_proyecto)**

En el contexto de un **sistema de reservas de productos**, donde múltiples usuarios generan pedidos de forma concurrente, resulta fundamental garantizar que todas las operaciones críticas mantengan la **integridad y consistencia** de los datos.  
Las transacciones en MySQL permiten asegurar las propiedades **ACID**, evitando inconsistencias como pedidos incompletos, pagos sin pedido asociado o decrementos incorrectos de stock durante procesos de compra.

A continuación se detallan los experimentos realizados para evaluar el comportamiento del sistema ante commits, fallos intencionales y escenarios que requieren rollback parcial.

**Scripts implementados**
- **01_tx_crear_pedido_completo.sql**  
  Transacción completa que realiza la creación del pedido, inserta detalles, descuenta stock y registra el pago.

- **02_tx_con_rollback_intencional.sql**  
  Transacción con error simulado utilizando `SIGNAL` o un `producto_id` inexistente, para demostrar la reversión completa del proceso.

- **03_tx_savepoint_parcial.sql**  
  Uso de **SAVEPOINT** y **ROLLBACK TO SAVEPOINT** para lograr un rollback parcial sin perder la cabecera del pedido.

- **04_pruebas_transacciones.sql**  
  Consultas de verificación para inspeccionar el estado final de las tablas después de cada prueba.

**Pruebas realizadas**
- Ejecución ordenada de los scripts en **MySQL Workbench**.  
- Verificación de que, tras el rollback intencional, **no persisten los pedidos ni sus detalles**.  
- Confirmación de que con `ROLLBACK TO SAVEPOINT`, solo se revierten las operaciones ejecutadas después del punto de guardado.  
- Evaluación del comportamiento del sistema bajo concurrencia, evitando inconsistencias en el stock o duplicación de operaciones.

 **Conclusión**
Las transacciones en **MySQL/InnoDB** proporcionan un mecanismo sólido para garantizar operaciones **atómicas y consistentes** dentro del sistema.  
El uso de **SAVEPOINT** añade flexibilidad al permitir recuperaciones parciales de una transacción compleja.  
En entornos con alta concurrencia, como sistemas de reservas de productos, se recomienda complementar estas técnicas con una adecuada configuración de **niveles de aislamiento** y manejo de errores desde la aplicación, logrando así un comportamiento estable y confiable en escenarios reale