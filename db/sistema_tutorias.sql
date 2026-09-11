-- =========================================================
-- SISTEMA WEB DE APOYO ACADÉMICO PARA TUTORÍAS
-- Script de creación de tablas (MariaDB/MySQL) - sobre testdb
-- =========================================================

USE testdb;

-- ---------------------------------------------------------
-- Roles del sistema
-- ---------------------------------------------------------
CREATE TABLE roles (
  id_rol INT AUTO_INCREMENT PRIMARY KEY,
  nombre_rol VARCHAR(30) NOT NULL UNIQUE  -- administrador, tutor, estudiante
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Usuarios (tabla base para el login)
-- ---------------------------------------------------------
CREATE TABLE usuarios (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  id_rol INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  correo VARCHAR(150) NOT NULL UNIQUE,
  usuario VARCHAR(50) NOT NULL UNIQUE,
  contrasena_hash VARCHAR(255) NOT NULL,     -- generar con password_hash() en PHP, nunca texto plano
  telefono VARCHAR(20),
  estado ENUM('activo','inactivo') NOT NULL DEFAULT 'activo',
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Carreras (para clasificar estudiantes y materias)
-- ---------------------------------------------------------
CREATE TABLE carreras (
  id_carrera INT AUTO_INCREMENT PRIMARY KEY,
  nombre_carrera VARCHAR(150) NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Estudiantes (extiende usuarios)
-- ---------------------------------------------------------
CREATE TABLE estudiantes (
  id_estudiante INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL UNIQUE,
  id_carrera INT NOT NULL,
  semestre TINYINT NOT NULL,
  registro_universitario VARCHAR(30) UNIQUE,
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
  FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Tutores (extiende usuarios)
-- ---------------------------------------------------------
CREATE TABLE tutores (
  id_tutor INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL UNIQUE,
  especialidad VARCHAR(150),
  biografia TEXT,
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Materias que pueden ser tutoradas
-- ---------------------------------------------------------
CREATE TABLE materias (
  id_materia INT AUTO_INCREMENT PRIMARY KEY,
  nombre_materia VARCHAR(150) NOT NULL,
  id_carrera INT,
  FOREIGN KEY (id_carrera) REFERENCES carreras(id_carrera)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Relación N:M: materias que domina cada tutor
-- ---------------------------------------------------------
CREATE TABLE tutor_materia (
  id_tutor INT NOT NULL,
  id_materia INT NOT NULL,
  PRIMARY KEY (id_tutor, id_materia),
  FOREIGN KEY (id_tutor) REFERENCES tutores(id_tutor) ON DELETE CASCADE,
  FOREIGN KEY (id_materia) REFERENCES materias(id_materia) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Disponibilidad horaria de cada tutor
-- ---------------------------------------------------------
CREATE TABLE disponibilidad_tutor (
  id_disponibilidad INT AUTO_INCREMENT PRIMARY KEY,
  id_tutor INT NOT NULL,
  dia_semana ENUM('Lunes','Martes','Miercoles','Jueves','Viernes','Sabado') NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME NOT NULL,
  FOREIGN KEY (id_tutor) REFERENCES tutores(id_tutor) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Tutorías (sesiones agendadas)
-- ---------------------------------------------------------
CREATE TABLE tutorias (
  id_tutoria INT AUTO_INCREMENT PRIMARY KEY,
  id_estudiante INT NOT NULL,
  id_tutor INT NOT NULL,
  id_materia INT NOT NULL,
  fecha DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME NOT NULL,
  modalidad ENUM('presencial','virtual') NOT NULL DEFAULT 'presencial',
  lugar_o_enlace VARCHAR(200),
  estado ENUM('pendiente','confirmada','realizada','cancelada') NOT NULL DEFAULT 'pendiente',
  observaciones TEXT,
  fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante),
  FOREIGN KEY (id_tutor) REFERENCES tutores(id_tutor),
  FOREIGN KEY (id_materia) REFERENCES materias(id_materia),
  INDEX idx_tutoria_fecha (fecha),
  INDEX idx_tutoria_estado (estado)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Evaluación/retroalimentación de la tutoría (insumo para reportes)
-- ---------------------------------------------------------
CREATE TABLE evaluaciones_tutoria (
  id_evaluacion INT AUTO_INCREMENT PRIMARY KEY,
  id_tutoria INT NOT NULL UNIQUE,
  calificacion TINYINT NOT NULL CHECK (calificacion BETWEEN 1 AND 5),
  comentario TEXT,
  fecha_evaluacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_tutoria) REFERENCES tutorias(id_tutoria) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Registro de accesos (auditoría de login, apoya el criterio de seguridad)
-- ---------------------------------------------------------
CREATE TABLE registro_accesos (
  id_acceso INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
  ip_origen VARCHAR(45),
  resultado ENUM('exitoso','fallido') NOT NULL,
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Datos semilla
-- ---------------------------------------------------------
INSERT INTO roles (nombre_rol) VALUES ('administrador'), ('tutor'), ('estudiante');

INSERT INTO carreras (nombre_carrera) VALUES ('Ingeniería de Sistemas');

-- Reemplaza el hash por uno real generado con password_hash('tu_clave', PASSWORD_DEFAULT)
INSERT INTO usuarios (id_rol, nombre, apellido, correo, usuario, contrasena_hash)
VALUES (1, 'Admin', 'Sistema', 'admin@tutorias.local', 'admin', '$2y$10$REEMPLAZAR_CON_HASH_REAL');

INSERT INTO materias (nombre_materia, id_carrera) VALUES
  ('Base de Datos I', 1),
  ('Programación I', 1),
  ('Tecnología Web I', 1);