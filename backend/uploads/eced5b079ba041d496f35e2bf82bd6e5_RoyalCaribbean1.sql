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
WHERE id_producto IN (

    SELECT Productos.id_producto
    FROM Productos
    INNER JOIN Orden_Producto
    ON Productos.id_producto = Orden_Producto.id_producto
    INNER JOIN Ordenes
    ON Orden_Producto.id_orden = Ordenes.id_orden
    WHERE MONTH(Ordenes.fecha_compra) = 11
);
GO



