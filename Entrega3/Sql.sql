DROP TABLE Transacciones CASCADE CONSTRAINTS;
DROP TABLE Facturas CASCADE CONSTRAINTS;
DROP TABLE Usuarios_Grupos CASCADE CONSTRAINTS;
DROP TABLE Grupos CASCADE CONSTRAINTS;
DROP TABLE Usuarios CASCADE CONSTRAINTS;
DROP TABLE Deudas CASCADE CONSTRAINTS;
DROP TABLE Notificaciones CASCADE CONSTRAINTS;



CREATE TABLE Usuarios (
    usuario_id INT PRIMARY KEY,
    nombre VARCHAR2(100), 
    correo VARCHAR2(100) UNIQUE,
    telefono VARCHAR2(20),
    paypal_id VARCHAR2(100),
    contrasena VARCHAR2(255),
    ultimo_acceso DATE, 
    imagen_url VARCHAR2(255) -- Almacena la URL de la imagen de la cuenta
);


CREATE TABLE Grupos (
    grupo_id INT PRIMARY KEY,
    nombre VARCHAR2(100),
    descripcion VARCHAR2(255),
    lider_id INT,
    fecha_creacion DATE,
    estado VARCHAR2(20) DEFAULT 'activo', 
    FOREIGN KEY (lider_id) REFERENCES Usuarios(usuario_id)
);


CREATE TABLE Usuarios_Grupos (
    usuario_id INT,
    grupo_id INT,
    rol VARCHAR2(10) DEFAULT 'miembro',
    fecha_union DATE,
    PRIMARY KEY (usuario_id, grupo_id),
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id),
    FOREIGN KEY (grupo_id) REFERENCES Grupos(grupo_id)
);


CREATE TABLE Facturas (
    factura_id INT PRIMARY KEY,
    grupo_id INT,
    usuario_creador_id INT, 
    titulo VARCHAR2(100),
    monto DECIMAL(10, 2),
    imagenUrl VARCHAR2(255),
    fecha_creacion DATE,
    FOREIGN KEY (grupo_id) REFERENCES Grupos(grupo_id),
    FOREIGN KEY (usuario_creador_id) REFERENCES Usuarios(usuario_id)
);


CREATE TABLE Transacciones (
    transaccion_id INT PRIMARY KEY,
    factura_id INT,
    usuario_deudor_id INT, 
    usuario_acreedor_id INT,
    monto DECIMAL(10, 2),
    fecha_transaccion DATE,
    medio_pago VARCHAR2(50), 
    estado VARCHAR2(20) DEFAULT 'pendiente', 
    aprobador_id INT, 
    FOREIGN KEY (factura_id) REFERENCES Facturas(factura_id),
    FOREIGN KEY (usuario_deudor_id) REFERENCES Usuarios(usuario_id),
    FOREIGN KEY (usuario_acreedor_id) REFERENCES Usuarios(usuario_id),
    FOREIGN KEY (aprobador_id) REFERENCES Usuarios(usuario_id)
);


CREATE TABLE Deudas (
    deuda_id INT PRIMARY KEY,
    usuario_id INT,
    acreedor_id INT,
    grupo_id INT,
    monto DECIMAL(10, 2),
    fecha_creacion DATE,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id),
    FOREIGN KEY (acreedor_id) REFERENCES Usuarios(usuario_id),
    FOREIGN KEY (grupo_id) REFERENCES Grupos(grupo_id)
);


CREATE TABLE Notificaciones (
    notificacion_id INT PRIMARY KEY,
    usuario_id INT,
    grupo_id INT,
    mensaje VARCHAR2(255),
    fecha_envio DATE,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id),
    FOREIGN KEY (grupo_id) REFERENCES Grupos(grupo_id)
);










INSERT INTO Usuarios (usuario_id, nombre, correo, telefono, paypal_id, contrasena, ultimo_acceso, imagen_url)  VALUES (1, 'Juan Pérez', 'juan@example.com', '3001234567', 'juan_paypal', 'password1', SYSDATE - 1, 'https://example.com/imagenes/juan.png');
INSERT INTO Usuarios (usuario_id, nombre, correo, telefono, paypal_id, contrasena, ultimo_acceso, imagen_url)  VALUES (2, 'María García', 'maria@example.com', '3107654321', 'maria_paypal', 'password2', SYSDATE, 'https://example.com/imagenes/maria.png');

INSERT INTO Grupos (grupo_id, nombre, descripcion, lider_id, fecha_creacion, estado) VALUES (1, 'Grupo A', 'Grupo de prueba A', 1, SYSDATE - 10, 'activo');
INSERT INTO Grupos (grupo_id, nombre, descripcion, lider_id, fecha_creacion, estado) VALUES (2, 'Grupo B', 'Grupo de prueba B', 2, SYSDATE - 20, 'disuelto');

INSERT INTO Usuarios_Grupos (usuario_id, grupo_id, rol, fecha_union) VALUES (1, 1, 'lider', SYSDATE - 9);
INSERT INTO Usuarios_Grupos (usuario_id, grupo_id, rol, fecha_union) VALUES (2, 1, 'miembro', SYSDATE - 5);

INSERT INTO Facturas (factura_id, grupo_id, usuario_creador_id, titulo, monto, fecha_creacion) VALUES (1, 1, 1, 'Alquiler de salón', 500.00, SYSDATE - 7);
INSERT INTO Facturas (factura_id, grupo_id, usuario_creador_id, titulo, monto, fecha_creacion) VALUES (2, 2, 2, 'Compra de materiales', 300.00, SYSDATE - 6);

INSERT INTO Transacciones (transaccion_id, factura_id, usuario_deudor_id, usuario_acreedor_id, monto, fecha_transaccion, medio_pago, estado, aprobador_id) VALUES (1, 1, 2, 1, 250.00, SYSDATE - 5, 'Paypal', 'aprobada', 1);
INSERT INTO Transacciones (transaccion_id, factura_id, usuario_deudor_id, usuario_acreedor_id, monto, fecha_transaccion, medio_pago, estado, aprobador_id) VALUES (2, 2, 1, 2, 300.00, SYSDATE - 4, 'Transferencia', 'rechazada', 2);

INSERT INTO Deudas (deuda_id, usuario_id, acreedor_id, grupo_id, monto, fecha_creacion) VALUES (1, 2, 1, 1, 250.00, SYSDATE - 8);
INSERT INTO Deudas (deuda_id, usuario_id, acreedor_id, grupo_id, monto, fecha_creacion) VALUES (2, 1, 2, 2, 300.00, SYSDATE - 6);

INSERT INTO Notificaciones (notificacion_id, usuario_id, grupo_id, mensaje, fecha_envio) VALUES (1, 1, 1, 'Se creó una nueva factura: Alquiler de salón', SYSDATE - 7);
INSERT INTO Notificaciones (notificacion_id, usuario_id, grupo_id, mensaje, fecha_envio) VALUES (2, 2, 2, 'Se rechazó la transacción: Compra de materiales', SYSDATE - 4);

--consulta 3.5.1 STEP 3
SELECT 
    u.nombre AS Usuario, 
    g.nombre AS Grupo, 
    CASE 
        WHEN d.monto IS NULL THEN 'No debes dinero'
        ELSE 'Debes $' || d.monto || ' a ' || a.nombre
    END AS Detalle_Deuda
FROM Usuarios u
JOIN Usuarios_Grupos ug ON u.usuario_id = ug.usuario_id
LEFT JOIN Deudas d ON d.usuario_id = u.usuario_id AND d.grupo_id = ug.grupo_id
LEFT JOIN Usuarios a ON a.usuario_id = d.acreedor_id
JOIN Grupos g ON g.grupo_id = ug.grupo_id
WHERE g.grupo_id = :grupo_id;
--consulta 3.6.1 step 1
SELECT 
    f.titulo AS Factura, 
    f.monto AS Monto, 
    f.fecha_creacion AS Fecha, 
    u.nombre AS Creador
FROM Facturas f
JOIN Usuarios u ON f.usuario_creador_id = u.usuario_id
WHERE f.grupo_id = :grupo_id
ORDER BY f.fecha_creacion DESC;
--consulta 3.7.1 step 2 
SELECT 
    g.nombre AS Grupo, 
    d.monto AS Monto_Deuda, 
    u.nombre AS Acreedor
FROM Deudas d
JOIN Grupos g ON d.grupo_id = g.grupo_id
JOIN Usuarios u ON u.usuario_id = d.acreedor_id
WHERE d.usuario_id = :usuario_id;
--consulta 3.10.1 step 2
SELECT 
    t.transaccion_id AS Transaccion, 
    f.titulo AS Factura, 
    u_deudor.nombre AS Deudor, 
    u_acreedor.nombre AS Acreedor, 
    t.monto AS Monto, 
    t.fecha_transaccion AS Fecha, 
    t.medio_pago AS Medio_Pago, 
    t.estado AS Estado, 
    u_aprobador.nombre AS Aprobador 
FROM Transacciones t
JOIN Facturas f ON t.factura_id = f.factura_id
JOIN Usuarios u_deudor ON t.usuario_deudor_id = u_deudor.usuario_id
JOIN Usuarios u_acreedor ON t.usuario_acreedor_id = u_acreedor.usuario_id
LEFT JOIN Usuarios u_aprobador ON t.aprobador_id = u_aprobador.usuario_id
WHERE f.grupo_id = :grupo_id
ORDER BY t.fecha_transaccion DESC;
--consulta 4.1.8 
INSERT INTO Transacciones (
    transaccion_id, factura_id, usuario_deudor_id, usuario_acreedor_id, monto, fecha_transaccion, medio_pago, estado) VALUES (:transaccion_id, :factura_id, :usuario_deudor_id, :usuario_acreedor_id, :monto, SYSDATE, :medio_pago, 'pendiente');
    
    


-- Eliminar los objetos existentes para evitar duplicados
-- Eliminación de secuencias, triggers y tablas

-- Eliminar el trigger de auditoría si existe
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_auditoria_usuarios';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN -- Código de error para "trigger does not exist"
            RAISE;
        END IF;
END;
/

-- Eliminar la tabla de auditoría si existe
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE auditoria_usuarios CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN -- Código de error para "table or view does not exist"
            RAISE;
        END IF;
END;
/

-- Eliminar la secuencia de auditoría si existe
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE auditoria_usuarios_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN -- Código de error para "sequence does not exist"
            RAISE;
        END IF;
END;
/

-- Eliminar otras secuencias (usuarios, facturas, grupos, transacciones) si existen
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE usuarios_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE facturas_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE grupos_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE transacciones_seq';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -2289 THEN
            RAISE;
        END IF;
END;
/

-- Crear la tabla de auditoría
CREATE TABLE AUDITORIA_USUARIOS (
    auditoria_id INT PRIMARY KEY,
    fecha_registro DATE DEFAULT SYSDATE,
    operacion VARCHAR2(10),       -- Tipo de operación: INSERT, UPDATE, DELETE
    usuario_id INT,               -- ID del usuario afectado
    nombre_ant VARCHAR2(100),     -- Valor anterior del nombre
    nombre_nuevo VARCHAR2(100),   -- Valor nuevo del nombre
    correo_ant VARCHAR2(100),     -- Valor anterior del correo
    correo_nuevo VARCHAR2(100),   -- Valor nuevo del correo
    telefono_ant VARCHAR2(20),    -- Valor anterior del teléfono
    telefono_nuevo VARCHAR2(20)   -- Valor nuevo del teléfono
);

-- Crear la secuencia de auditoría
CREATE SEQUENCE auditoria_usuarios_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Crear otras secuencias necesarias para las tablas del sistema
CREATE SEQUENCE usuarios_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE facturas_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE grupos_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE transacciones_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- Crear el trigger de auditoría
CREATE OR REPLACE TRIGGER trg_auditoria_usuarios
AFTER INSERT OR UPDATE OR DELETE ON Usuarios
FOR EACH ROW
DECLARE
    auditoria_id_seq INT; -- Variable para almacenar el ID secuencial de auditoría
BEGIN
    -- Generar un ID para la tabla de auditoría
    SELECT auditoria_usuarios_seq.NEXTVAL INTO auditoria_id_seq FROM dual;

    -- Auditoría para INSERT
    IF INSERTING THEN
        INSERT INTO AUDITORIA_USUARIOS (auditoria_id, fecha_registro, operacion, usuario_id, 
                                        nombre_nuevo, correo_nuevo, telefono_nuevo)
        VALUES (auditoria_id_seq, SYSDATE, 'INSERT', :NEW.usuario_id, 
                :NEW.nombre, :NEW.correo, :NEW.telefono);

    -- Auditoría para UPDATE
    ELSIF UPDATING THEN
        INSERT INTO AUDITORIA_USUARIOS (auditoria_id, fecha_registro, operacion, usuario_id, 
                                        nombre_ant, nombre_nuevo, 
                                        correo_ant, correo_nuevo, 
                                        telefono_ant, telefono_nuevo)
        VALUES (auditoria_id_seq, SYSDATE, 'UPDATE', :OLD.usuario_id, 
                :OLD.nombre, :NEW.nombre, 
                :OLD.correo, :NEW.correo, 
                :OLD.telefono, :NEW.telefono);

    -- Auditoría para DELETE
    ELSIF DELETING THEN
        INSERT INTO AUDITORIA_USUARIOS (auditoria_id, fecha_registro, operacion, usuario_id, 
                                        nombre_ant, correo_ant, telefono_ant)
        VALUES (auditoria_id_seq, SYSDATE, 'DELETE', :OLD.usuario_id, 
                :OLD.nombre, :OLD.correo, :OLD.telefono);
    END IF;
END;
/




--reporte bill
SELECT 
    AnioMes,
    NVL(grupo_1, 0) AS "Grupo 1",
    NVL(grupo_2, 0) AS "Grupo 2",
    NVL(grupo_3, 0) AS "Grupo 3",
    NVL(grupo_4, 0) AS "Grupo 4",  -- Agrega más columnas según sea necesario para cada grupo
    NVL(grupo_5, 0) AS "Grupo 5",  -- Agrega más columnas según sea necesario para cada grupo
    (NVL(grupo_1, 0) + NVL(grupo_2, 0) + NVL(grupo_3, 0) + NVL(grupo_4, 0) + NVL(grupo_5, 0)) AS "Monto Total"
FROM (
    SELECT 
        TO_CHAR(f.fecha_creacion, 'YYYY-MM') AS AnioMes,
        g.nombre AS grupo,
        f.monto AS monto
    FROM 
        Facturas f
    JOIN 
        Grupos g ON f.grupo_id = g.grupo_id
) 
PIVOT (
    SUM(monto) 
    FOR grupo IN ('Grupo A' AS grupo_1, 'Grupo B' AS grupo_2, 'Grupo C' AS grupo_3, 'Grupo D' AS grupo_4, 'Grupo E' AS grupo_5)
)
ORDER BY 
    AnioMes;
