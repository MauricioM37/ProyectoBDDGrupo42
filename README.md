# Universidad Nacional del Nordeste
## Facultad de Ciencias Exactas y Naturales y Agrimensura  
### Licenciatura en Sistemas de Información  
**Asignatura:** Bases de Datos I  
**Proyecto de Investigación:** Réplicas de Base de Datos  
**Alumnos:** Martinez Mauricio Marcelo – Herrera Matias  – Famular Antonela  – Falcon Mateo Alejo   
**Profesores:** Lic. Villegas Dario O. – Lic. Vallejos Walter O. – Exp. Cuzziol Juan J. – Lic. Badaracco Numa  
**Año:** 2025  

---

# Índice  
- [Capítulo I: Introducción](#capítulo-i-introducción)  
- [Capítulo II: Marco Conceptual](#capítulo-ii-marco-conceptual)  
- [Capítulo III: Metodología](#capítulo-iii-metodología)  
- [Capítulo IV: Desarrollo del tema / Resultados](#capítulo-iv-desarrollo-del-tema--resultados)  
- [Capítulo V: Conclusiones](#capítulo-v-conclusiones)  
- [Capítulo VI: Bibliografía](#capítulo-vi-bibliografía)  

---

# Capítulo I: Introducción
En los sistemas de información actuales, la disponibilidad y la confiabilidad de los datos constituyen un requisito esencial para el funcionamiento de aplicaciones críticas. El crecimiento exponencial de usuarios y la necesidad de realizar operaciones en tiempo real hacen que la base de datos, como núcleo del sistema, pueda convertirse en un cuello de botella.  
Frente a esta problemática, la **replicación de bases de datos** se presenta como una técnica fundamental que permite garantizar la continuidad del servicio, mejorar el rendimiento y asegurar mecanismos de recuperación ante desastres.  

El presente proyecto plantea un estudio teórico-práctico sobre la replicación de bases de datos, analizando sus fundamentos conceptuales y evaluando su implementación en un entorno de laboratorio.  
Se busca explorar los beneficios y las limitaciones de las distintas modalidades de replicación y comprender cómo impactan en la consistencia, la disponibilidad y el rendimiento de los sistemas.  

**Problema:** ¿Cómo garantizar disponibilidad, consistencia y rendimiento en un sistema de gestión de reservas con alta concurrencia de lecturas y escrituras críticas?  

**Objetivo general:** Comprender, implementar y evaluar réplicas de bases de datos en un entorno controlado, midiendo su impacto en escenarios de uso realista.  

**Objetivos específicos:**  
1. Analizar los diferentes tipos de replicación (lógica, física, síncrona, asíncrona, semi-síncrona).  
2. Implementar un entorno de laboratorio con instancias maestro y réplicas.  
3. Medir métricas clave como latencia de replicación, consistencia de datos y tiempo de recuperación ante fallos.  
4. Comparar los resultados obtenidos con la teoría y documentar hallazgos y recomendaciones.  

---

# Capítulo II: Marco Conceptual
La replicación de bases de datos consiste en mantener múltiples copias de un mismo conjunto de datos en distintas instancias de un sistema gestor, con el fin de aumentar la disponibilidad y la tolerancia a fallos.  
Este mecanismo permite que las consultas de lectura se distribuyan entre varias réplicas, aliviando la carga del nodo maestro, mientras que las operaciones de escritura se centralizan en un punto de control.  

**Principales enfoques de replicación:**  
- **Replicación transaccional:** asegura que los cambios confirmados se apliquen de forma consistente en las réplicas.  
- **Replicación lógica:** basada en eventos de alto nivel (instrucciones SQL).  
- **Replicación física:** propagación a nivel de bloques o logs binarios.  
- **Replicación síncrona:** garantiza consistencia fuerte pero añade latencia.  
- **Replicación asíncrona:** ofrece mejor rendimiento pero puede producir lecturas obsoletas.  
- **Replicación semi-síncrona:** equilibrio entre las dos anteriores.  

**Topologías comunes:**  
- Maestro con múltiples réplicas.  
- Replicación en cascada.  
- Clústeres con consenso.  

Cada modalidad se adecua a diferentes escenarios: sistemas de comercio electrónico con consultas intensivas, sistemas de telemetría con alta escritura o despliegues multi-región que buscan acercar los datos a los usuarios.  

---

# Capítulo III: Metodología
La metodología aplicada en este trabajo se divide en dos fases: **teórica** y **práctica**.  

- En la fase teórica se revisaron conceptos fundamentales de replicación mediante bibliografía académica y documentación oficial de motores de bases de datos como MySQL.  
- En la fase práctica se diseñara un laboratorio controlado que permitira implementar y probar distintos modos de replicación.

**Actividades a realizar:**  
1. Instalación de instancias Maestro y Réplica en contenedores Docker.  
2. Configuración de parámetros de replicación (binlogs, usuarios replicadores, permisos).  
3. Ejecución de scripts de carga con operaciones de lectura y escritura.  
4. Monitoreo de métricas como *lag de réplica*, tiempo de confirmación de transacciones y recuperación tras caídas.  
5. Análisis comparativo entre replicación asíncrona y semi-síncrona.

**Herramientas a utilizar:**  
- MySQL 8.4  
- Docker  
- Sysbench para benchmarking  
- Comandos internos (`SHOW SLAVE STATUS`) para supervisar la replicación  

Se documentaran también los errores encontrados y los pasos de resolución.  

---

# Capítulo IV: Desarrollo del tema / Resultados esperados
El caso de estudio seleccionado corresponde a un **sistema de reservas de productos**, similar a un e-commerce.  
Este sistema combina un alto volumen de consultas de lectura con operaciones críticas de escritura, como la generación de pedidos.  
Se probaran escenarios en los que el Maestro gestionara las escrituras mientras las réplicas responderan a las consultas de lectura concurrentes.

**Resultados esperados minimamente la primera:**  
- **Replicación asíncrona:** permitir una rápida confirmación de transacciones, con un lag de réplica que oscile entre 1 y 3 segundos bajo carga.
- **Replicación semi-síncrona:** reducir el riesgo de pérdida de datos al requerir confirmación de al menos una réplica antes de validar el commit. Sin que suba demasiado la latencia.
- **Recuperación ante fallos:** simular la caída del nodo maestro y probar las réplicas para consultas de lectura, garantizando disponibilidad parcial del sistema. 

Estos experimentos demostraran que la replicación puede mejorar significativamente la tolerancia a fallos y la capacidad de respuesta en sistemas con alta concurrencia, aunque requiere un diseño cuidadoso para equilibrar consistencia y rendimiento.  

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
En entornos con alta concurrencia, como sistemas de reservas de productos, se recomienda complementar estas técnicas con una adecuada configuración de **niveles de aislamiento** y manejo de errores desde la aplicación, logrando así un comportamiento estable y confiable en escenarios reales.


---

# Capítulo V: Conclusiones
El análisis realizado confirma que la replicación es una técnica indispensable para los sistemas de información que requieren alta disponibilidad, consistencia y bajo tiempo de respuesta. A lo largo del proyecto se comprobó que su correcta implementación permite mantener la continuidad del servicio ante fallos, distribuir la carga de trabajo y optimizar el rendimiento general del sistema. También se destacó la importancia de una buena configuración, el monitoreo constante y el diseño adecuado de la topología para garantizar estabilidad y recuperación ante fallas.

---

# Capítulo VI: Bibliografía
- Oracle. (2024). *MySQL 8.4 Reference Manual: Replication*. https://dev.mysql.com/doc/refman/8.4/en/replication.html  
- Material de cátedra: *Bases de Datos I*, Licenciatura en Sistemas de Información, UNNE.  
- Elmasri, R. & Navathe, S. (2017). *Sistemas de Bases de Datos*. Pearson.  
- Silberschatz, A., Korth, H., & Sudarshan, S. (2019). *Database System Concepts*. McGraw-Hill.  
Proyecto_investigacion_BD_GITHUB.md
9 KB
