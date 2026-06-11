--LUIS ALEJANDRO HERRERA GALVIS
--CARLOS MARIO MONTES RUA


CREATE DATABASE RoyalCaribbean;
GO

USE RoyalCaribbean;
GO

CREATE TABLE Usuarios(
    id_usuario INT PRIMARY KEY,
    primer_nombre VARCHAR(50) NOT NULL,
    segundo_nombre VARCHAR(50) NULL,
    primer_apellido VARCHAR(50) NOT NULL,
    segundo_apellido VARCHAR(50) NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    pais VARCHAR(100) NOT NULL,
    tipo_usuario VARCHAR(50) NOT NULL,
    fecha_registro DATE NOT NULL
);
GO



CREATE TABLE Sellers(
    id_seller INT PRIMARY KEY,
    nombre_empresa VARCHAR(100) NOT NULL,
    pais_operacion VARCHAR(100) NOT NULL,
    correo_contacto VARCHAR(100) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado VARCHAR(20) NOT NULL
);
GO



CREATE TABLE Productos(
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    precio MONEY NOT NULL,
    id_seller INT NOT NULL,

    FOREIGN KEY(id_seller)
    REFERENCES Sellers(id_seller)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
GO

CREATE TABLE Ordenes(
    id_orden INT PRIMARY KEY,
    fecha_compra DATE NOT NULL,
    monto_total MONEY NOT NULL,
    estado_orden VARCHAR(50) NOT NULL,
    id_usuario INT NOT NULL,

    FOREIGN KEY(id_usuario)
    REFERENCES Usuarios(id_usuario)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
GO

CREATE TABLE Orden_Producto(
    id_orden INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad_vendida INT NOT NULL,

    PRIMARY KEY(id_orden,id_producto),

    FOREIGN KEY(id_orden)
    REFERENCES Ordenes(id_orden)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    FOREIGN KEY(id_producto)
    REFERENCES Productos(id_producto)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
GO

CREATE TABLE Cupones(
    id_cupon INT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_orden INT NOT NULL,
    codigo_cupon VARCHAR(100) NOT NULL UNIQUE,
    porcentaje_descuento INT NOT NULL,
    fecha_aplicacion DATE NOT NULL,

    FOREIGN KEY(id_usuario)
    REFERENCES Usuarios(id_usuario),

    FOREIGN KEY(id_orden)
    REFERENCES Ordenes(id_orden)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
GO
GO

CREATE TABLE Pagos(
    id_pago INT PRIMARY KEY,
    id_orden INT NOT NULL,
    referencia_pago VARCHAR(100) NOT NULL,
    fecha_pago DATE NOT NULL,
    monto_pagado MONEY NOT NULL,
    metodo_pago VARCHAR(100) NOT NULL,
    estado_pago VARCHAR(50) NOT NULL,

    FOREIGN KEY(id_orden)
    REFERENCES Ordenes(id_orden)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);
GO
-- INSERT USUARIOS

INSERT INTO Usuarios VALUES
(1,'Carlos','Andres','Alvarez','Gomez','carlos@gmail.com','Estados Unidos','premium','2025-01-10');

INSERT INTO Usuarios VALUES
(2,'Maria','Fernanda','Lopez','Ruiz','maria@gmail.com','Colombia','regular','2025-02-15');

INSERT INTO Usuarios VALUES
(3,'Ana','Sofia','Martinez','Perez','ana@gmail.com','Estados Unidos','premium','2025-03-12');

INSERT INTO Usuarios VALUES
(4,'Pedro','Antonio','Ramirez','Torres','pedro@gmail.com','Mexico','regular','2025-04-01');

INSERT INTO Usuarios VALUES
(5,'Laura','Camila','Anderson','Smith','laura@gmail.com','Estados Unidos','premium','2025-05-08');
GO

--INSERT SELLERS

INSERT INTO Sellers VALUES
(1,'TechWorld','China','tech@gmail.com','2021-01-01','inactivo');

INSERT INTO Sellers VALUES
(2,'ModaPlus','España','moda@gmail.com','2023-05-01','activo');

INSERT INTO Sellers VALUES
(3,'HomeStore','Mexico','home@gmail.com','2024-01-01','activo');

INSERT INTO Sellers VALUES
(4,'GamingZone','Japon','gaming@gmail.com','2020-06-01','inactivo');

INSERT INTO Sellers VALUES
(5,'SportFit','Colombia','sport@gmail.com','2025-01-01','activo');
GO

--INSERT PRODUCTOS

INSERT INTO Productos VALUES
(1,'Laptop Gamer','Laptop de alto rendimiento','Tecnologia',3000,1);

INSERT INTO Productos VALUES
(2,'Zapatos Deportivos','Zapatos running','Moda',500,2);

INSERT INTO Productos VALUES
(3,'Silla Ergonomica','Silla para oficina','Hogar',800,3);

INSERT INTO Productos VALUES
(4,'PlayStation 5','Consola de videojuegos','Gaming',2500,4);

INSERT INTO Productos VALUES
(5,'Bicicleta MTB','Bicicleta de montaña','Deportes',1500,5);
GO

--INSERT ORDENES

INSERT INTO Ordenes VALUES
(1,'2025-11-10',3500,'pendiente',1);

INSERT INTO Ordenes VALUES
(2,'2025-10-01',500,'completada',2);

INSERT INTO Ordenes VALUES
(3,'2025-11-15',2500,'pendiente',3);

INSERT INTO Ordenes VALUES
(4,'2025-09-20',800,'completada',4);

INSERT INTO Ordenes VALUES
(5,'2025-11-22',1500,'pendiente',5);
GO

--INSERT ORDEN_PRODUCTO

INSERT INTO Orden_Producto VALUES
(1,1,1);

INSERT INTO Orden_Producto VALUES
(2,2,2);

INSERT INTO Orden_Producto VALUES
(3,4,1);

INSERT INTO Orden_Producto VALUES
(4,3,1);

INSERT INTO Orden_Producto VALUES
(5,5,1);
GO

-- INSERT CUPONES

INSERT INTO Cupones VALUES
(1,1,1,'DESC30',30,'2025-11-10');

INSERT INTO Cupones VALUES
(2,2,2,'DESC10',10,'2025-10-01');

INSERT INTO Cupones VALUES
(3,3,3,'DESC25',25,'2025-11-15');

INSERT INTO Cupones VALUES
(4,4,4,'DESC5',5,'2025-09-20');

INSERT INTO Cupones VALUES
(5,5,5,'DESC40',40,'2025-11-22');
GO

--INSERT PAGOS

INSERT INTO Pagos VALUES
(1,1,'REF001','2025-11-10',2000,'Tarjeta de Credito','pendiente');

INSERT INTO Pagos VALUES
(2,2,'REF002','2025-10-01',500,'PSE','completado');

INSERT INTO Pagos VALUES
(3,3,'REF003','2025-11-15',1000,'Tarjeta de Credito','pendiente');

INSERT INTO Pagos VALUES
(4,4,'REF004','2025-09-20',800,'Efectivo','completado');

INSERT INTO Pagos VALUES
(5,5,'REF005','2025-11-22',1500,'Tarjeta de Credito','pendiente');
GO



-- 1. Productos comprados por usuarios de Estados unidos vendidos por sellers de otro pais

SELECT Productos.nombre_producto,
       Usuarios.pais,
       Sellers.pais_operacion
FROM Usuarios
INNER JOIN Ordenes
ON Usuarios.id_usuario = Ordenes.id_usuario
INNER JOIN Orden_Producto
ON Ordenes.id_orden = Orden_Producto.id_orden
INNER JOIN Productos
ON Orden_Producto.id_producto = Productos.id_producto
INNER JOIN Sellers
ON Productos.id_seller = Sellers.id_seller
WHERE Usuarios.pais = 'Estados Unidos'
AND Sellers.pais_operacion <> 'Estados Unidos';


-- 2. Usuarios que aplicaron cupones mayores al 20%

SELECT Usuarios.primer_nombre,
       Usuarios.primer_apellido,
       Cupones.porcentaje_descuento
FROM Usuarios
INNER JOIN Cupones
ON Usuarios.id_usuario = Cupones.id_usuario
WHERE Cupones.porcentaje_descuento > 20;


-- 3. Total de ordenes de usuarios premium cuyo apellido contenga la letra A

SELECT COUNT(*) AS TotalOrdenes
FROM Usuarios
INNER JOIN Ordenes
ON Usuarios.id_usuario = Ordenes.id_usuario
WHERE Usuarios.tipo_usuario = 'premium'
AND Usuarios.primer_apellido LIKE '%A%';


-- 4. Pagos realizados con tarjeta de credito y orden pendiente

SELECT *
FROM Pagos
INNER JOIN Ordenes
ON Pagos.id_orden = Ordenes.id_orden
WHERE Pagos.metodo_pago = 'Tarjeta de Credito'
AND Ordenes.estado_orden = 'pendiente';


-- 5. Todos los usuarios incluyendo los que no tengan cupones

SELECT Usuarios.primer_nombre,
       Usuarios.primer_apellido,
       Cupones.codigo_cupon
FROM Usuarios
LEFT JOIN Cupones
ON Usuarios.id_usuario = Cupones.id_usuario;


-- MODIFICACIONES

-- Eliminar productos de sellers inactivos antes de 2022

DELETE Productos
FROM Productos
INNER JOIN Sellers
ON Productos.id_seller = Sellers.id_seller
WHERE Sellers.estado = 'inactivo'
AND Sellers.fecha_ingreso < '2022-01-01';


-- Aumentar 10% a productos comprados en noviembre

UPDATE Productos
SET precio = precio * 1.10
WHERE id_producto IN(

    SELECT Productos.id_producto
    FROM Productos
    INNER JOIN Orden_Producto
    ON Productos.id_producto = Orden_Producto.id_producto
    INNER JOIN Ordenes
    ON Orden_Producto.id_orden = Ordenes.id_orden
    WHERE MONTH(Ordenes.fecha_compra) = 11
);
GO

SELECT Usuarios.id_usuario, Usuarios.primer_nombre, Usuarios.primer_apellido  
FROM Usuarios
INNER JOIN Ordenes
ON Usuarios.id_usuario = Ordenes.id_usuario 
INNER JOIN Pagos 
ON Pagos.id_orden = Ordenes.id_orden 
WHERE metodo_pago = 'PSE'
AND estado_pago = 'Completado' 

SELECT count(*) as Usuariospremium
FROM Usuarios
WHERE tipo_usuario = 'premium' 

SELECT *
from Pagos

SELECT Usuarios.primer_nombre,Pagos.metodo_pago as Pagos_con_tarjeta_de_credito
FROM Usuarios
INNER JOIN Ordenes
ON Usuarios.id_usuario = Ordenes.id_usuario
INNER JOIN Pagos
ON Ordenes.id_orden = Pagos.id_orden
WHERE metodo_pago = 'Tarjeta de Credito'

SELECT Productos.nombre_producto, Sellers.nombre_empresa as Producto_empresa
FROM Productos
INNER JOIN Sellers
ON Productos.id_seller = Sellers.id_seller
WHERE Sellers.estado = 'activo'

SELECT  count (*) as totalusuariospendientes
FROM Usuarios
INNER JOIN Ordenes
ON Usuarios.id_usuario = Ordenes.id_usuario
where estado_orden = 'pendiente' and Usuarios.tipo_usuario = 'premium'

SELECT Usuarios.primer_nombre, Productos.nombre_producto AS PRODUCTOS_PRECIO_MAYOR_A_1000
FROM Usuarios
INNER JOIN Ordenes
ON Usuarios.id_usuario = Ordenes.id_usuario
INNER JOIN Orden_Producto
ON Ordenes.id_orden = Orden_Producto.id_orden
INNER JOIN Productos
ON  Orden_Producto.id_producto = Productos.id_producto
WHERE Productos.precio > 1000

SELECT Usuarios.primer_nombre, Usuarios.primer_apellido,Ordenes.estado_orden AS USUARIOS_APELLIDO_A
FROM Usuarios
INNER JOIN Ordenes
ON Usuarios.id_usuario = Ordenes.id_usuario
WHERE Usuarios.primer_apellido LIKE 'A%'

SELECT Usuarios.primer_nombre, Productos.nombre_producto,Pagos.metodo_pago AS PAGOS_CON_TARJETA
FROM Usuarios
INNER JOIN Ordenes
ON Usuarios.id_usuario = Ordenes.id_usuario
INNER JOIN Orden_Producto
ON Ordenes.id_orden = Orden_Producto.id_orden
INNER JOIN Pagos
ON Ordenes.id_orden = Pagos.id_orden
INNER JOIN Productos
ON Orden_Producto.id_producto = Productos.id_producto
WHERE Productos.precio > 400 AND Pagos.metodo_pago = 'Tarjeta de Credito'

SELECT U.primer_nombre,PR.nombre_producto , C.porcentaje_descuento, P.metodo_pago AS USUARIOS_COMPLETADOS
FROM Usuarios U
INNER JOIN Cupones  C
ON U.id_usuario = C.id_usuario
INNER JOIN Ordenes O
ON C.id_orden = O.id_orden
INNER JOIN Pagos P
ON O.id_orden = P.id_orden
INNER JOIN Orden_Producto OP
ON O.id_orden = OP.id_orden
INNER JOIN Productos PR
ON OP.id_producto = PR.id_producto
WHERE U.tipo_usuario = 'premium' AND C.porcentaje_descuento > 20 AND P.estado_pago = 'completado'

SELECT U.primer_nombre, U.pais, P.nombre_producto,S.nombre_empresa, Pay.estado_pago
FROM Usuarios U
INNER JOIN  Ordenes O
ON U.id_usuario = O.id_usuario
INNER JOIN Pagos Pay
ON O.id_orden = Pay.id_orden
INNER JOIN Orden_Producto OP
ON O.id_orden = OP.id_orden
INNER JOIN Productos P
ON OP.id_producto = P.id_producto
INNER JOIN Sellers S
ON P.id_seller = S.id_seller
WHERE S.estado = 'activo' AND Pay.estado_pago = 'pendiente' AND U.pais = 'Estados Unidos'

SELECT U.primer_nombre, PR.nombre_producto, C.porcentaje_descuento, PA.metodo_pago, O.estado_orden
FROM Usuarios U
INNER JOIN Cupones C
ON U.id_usuario = C.id_usuario
INNER JOIN Ordenes O
ON C.id_orden = O.id_orden
INNER JOIN Orden_Producto OP
ON O.id_orden = OP.id_orden
INNER JOIN Pagos PA
ON OP.id_orden = PA.id_orden
INNER JOIN Productos PR
ON OP.id_producto = PR.id_producto
WHERE O.estado_orden = 'completada' AND PA.metodo_pago = 'PSE' AND C.porcentaje_descuento <= 10 AND PR.categoria = 'Moda'


SELECT U.primer_nombre, C.codigo_cupon  AS CODIGOS_DE_DESCUENTO
FROM Usuarios U
LEFT JOIN Cupones C
ON U.id_usuario = C.id_usuario


SELECT U.primer_nombre, C.codigo_cupon
FROM Usuarios U
LEFT JOIN Cupones C
ON U.id_usuario = C.id_usuario
WHERE C.codigo_cupon IS NULL

SELECT U.primer_nombre, O.estado_orden,PA.metodo_pago AS METODO_PAGO
FROM Usuarios U
LEFT JOIN Ordenes O
ON U.id_usuario = O.id_usuario
LEFT JOIN Pagos PA
ON O.id_orden = PA.id_orden

SELECT U.primer_nombre
FROM Usuarios U
LEFT JOIN Ordenes O
ON U.id_usuario = O.id_usuario
WHERE O.id_orden IS NULL

SELECT U.primer_nombre, O.estado_orden,C.codigo_cupon AS USUARIOS_ORDENES_Y_CUPONES
FROM Usuarios U
RIGHT JOIN Cupones C
ON U.id_usuario = C.id_usuario
RIGHT JOIN Ordenes O
ON C.id_usuario = O.id_usuario

SELECT U.primer_nombre, O.estado_orden
FROM Usuarios U
LEFT JOIN Ordenes O
ON U.id_usuario = O.id_usuario
LEFT JOIN Pagos P
ON O.id_orden = P.id_orden
WHERE P.estado_pago IS NULL


SELECT U.primer_nombre, PR.nombre_producto, P.metodo_pago AS METODOPAGO
FROM Usuarios U
LEFT JOIN Ordenes O
ON U.id_usuario = O.id_usuario
LEFT JOIN Pagos P
ON O.id_orden = P.id_orden
LEFT JOIN Orden_Producto OP
ON O.id_orden = OP.id_orden
LEFT JOIN Productos PR
ON OP.id_producto = PR.id_producto

UPDATE Pagos
SET estado_pago = 'COMPLETADO'
WHERE metodo_pago = 'PSE'

UPDATE Productos
SET precio = precio * 1.20
WHERE categoria = 'Tecnologia'

UPDATE O
SET estado_orden = 'completada'
FROM Ordenes O
INNER JOIN Pagos P
ON O.id_orden = P.id_orden
WHERE P.estado_pago = 'completado'

UPDATE SE
SET estado = 'inactivo'
FROM Sellers SE
INNER JOIN Productos P
ON SE.id_seller = P.id_seller
WHERE P.precio > 1000

UPDATE Usuarios
SET tipo_usuario = 'premium'
WHERE pais = 'Colombia' AND fecha_registro > '2025-01-01'


UPDATE P
SET estado_pago = 'revisado'
FROM Pagos P
INNER JOIN Ordenes O
ON P.id_orden = O.id_orden
WHERE O.estado_orden = 'pendiente'


DELETE Usuarios
FROM Usuarios
WHERE Usuarios.pais = 'Mexico'


DELETE P
FROM Productos P
INNER JOIN Sellers SE
ON P.id_seller = SE.id_seller
WHERE SE.estado = 'inactivo'

DELETE P
FROM Pagos P
INNER JOIN Ordenes O
ON P.id_orden = O.id_orden
WHERE O.estado_orden = 'completada' 


SELECT P.nombre_producto, P.precio
FROM Productos P
WHERE Ordenes.id_orden IN (
SELECT O.id_orden
FROM Ordenes O 
WHERE O.estado_orden = 'pendiente'


 

SELECT U.primer_nombre, O.estado_orden, P.metodo_pago
FROM Usuarios U
INNER JOIN Ordenes O
ON U.id_usuario = O.id_usuario
INNER JOIN Pagos P
ON O.id_orden = P.id_orden
WHERE P.estado_pago = 'completado' AND U.tipo_usuario = 'premium'


SELECT PR.nombre_producto, SE.nombre_empresa, PR.precio AS PRODUCTOS_SELLERS
FROM Usuarios U
INNER JOIN Ordenes O
ON U.id_usuario = O.id_usuario
INNER JOIN Orden_Producto OP
ON O.id_orden = OP.id_orden
INNER JOIN Productos PR
ON OP.id_producto = PR.id_producto
INNER JOIN Sellers SE
ON PR.id_seller = SE.id_seller
WHERE PR.precio > 1000 AND SE.estado = 'activo'


SELECT U.primer_nombre, O.estado_orden AS ESTADO_ORDENES_USUARIOS
FROM Usuarios U
LEFT JOIN Ordenes O
ON U.id_usuario = O.id_usuario


SELECT U.primer_nombre 
FROM Usuarios U
LEFT JOIN Cupones CU
ON U.id_usuario = CU.id_usuario
WHERE CU.codigo_cupon IS NULL

UPDATE P 
SET estado_pago = 'rechazado'
FROM Pagos P
INNER JOIN Ordenes O
ON P.id_orden = O.id_orden
WHERE O.estado_orden = 'pendiente'


DELETE Productos
FROM Productos
INNER JOIN Sellers
ON Productos.id_seller = Sellers.id_seller
WHERE Sellers.estado = 'inactivo'



SELECT Ordenes.estado_orden, COUNT (*) AS TOTAL_ORDENES
FROM Ordenes 
GROUP BY Ordenes.estado_orden

SELECT Pagos.metodo_pago, SUM (monto_pagado) AS SUMA_TOTAL_PAGADA
FROM Pagos 
GROUP BY Pagos.metodo_pago

SELECT Productos.categoria, AVG (precio) AS PROMEDIO_DE_PRECIOS
FROM Productos
GROUP BY Productos.categoria

SELECT U.primer_nombre, PR.nombre_producto, PR.precio AS PRECIO
FROM Usuarios U
INNER JOIN Ordenes O
ON U.id_usuario = O.id_usuario
INNER JOIN Orden_Producto OP
ON O.id_orden = OP.id_orden
INNER JOIN Productos PR
ON OP.id_producto = PR.id_producto
WHERE PR.precio > 1000
ORDER BY PR.precio DESC

SELECT U.primer_nombre, COUNT(O.id_orden) AS CANTIDAD_ORDENES
FROM Usuarios U
LEFT JOIN Ordenes O
ON U.id_usuario = O.id_usuario
GROUP BY U.primer_nombre


SELECT PR.nombre_producto, SE.nombre_empresa
FROM Productos PR
RIGHT JOIN Sellers SE
ON PR.id_seller = SE.id_seller


SELECT P.categoria, COUNT (P.id_producto)  AS CANTIDAD_PRODUCTO
FROM Productos P
INNER JOIN Orden_Producto OP
ON P.id_producto = OP.id_producto
GROUP BY P.categoria
ORDER BY CANTIDAD_VENDIDA DESC


SELECT U.primer_nombre, O.estado_orden
FROM Usuarios U
LEFT JOIN Ordenes O
ON U.id_usuario = O.id_usuario
ORDER BY U.primer_nombre ASC