<div align="center">

# Práctica 5 — Programación en el SGBD
### Procedimientos Almacenados · Funciones · Cursores · Triggers

*UMB — Teoría de Bases de Datos · Guía No. 5 · Semanas 11–13 · MySQL 8.x / MariaDB 10.5+*

</div>

---

## Índice

**Parte 1 — Proyecto y comandos**
- [Sobre el proyecto](#sobre-el-proyecto)
- [Estado actual](#estado-actual)
- [Estructura de carpetas](#estructura-de-carpetas)
- [Sistema base — Guia_5](#sistema-base--guia_5)
- [Objetos programados](#objetos-programados)
- [Orden de ejecución](#orden-de-ejecución)
- [Comandos — Arch Linux (bash)](#comandos--arch-linux-bash)
- [Comandos — Windows (cmd)](#comandos--windows-cmd)
- [Comandos — Windows (PowerShell)](#comandos--windows-powershell)
- [Comandos — MySQL Workbench](#comandos--mysql-workbench)
- [Consultas SQL para cada cosa](#consultas-sql-para-cada-cosa)

**Parte 2 — Actividades**
- [Tarea previa — IN/OUT/INOUT y SP básico](#tarea-previa--parámetros-ininoutinout-y-sp-básico)
- [Actividad 1 — SP de matrícula](#actividad-1--sp-de-matrícula)
- [Actividad 2 — SP de promedio y clasificación](#actividad-2--sp-de-promedio-y-clasificación)
- [Actividad 3 — Funciones (UDF)](#actividad-3--funciones-udf)
- [Actividad 4 — SP con cursor](#actividad-4--sp-con-cursor)
- [Actividad 5 — Triggers](#actividad-5--triggers)

**Parte 3 — Referencia**
- [Compatibilidad MySQL ↔ MariaDB](#compatibilidad-mysql--mariadb)
- [Errores comunes y solución](#errores-comunes-y-solución)
- [Convenciones del proyecto](#convenciones-del-proyecto)
- [Informe final](#informe-final)
- [Referencias](#referencias)

---

# Parte 1 — Proyecto y comandos

## Sobre el proyecto

En esta práctica el estudiante es el **desarrollador de base de datos**: lleva la lógica de negocio al SGBD con procedimientos almacenados (SP), funciones definidas por el usuario (UDF), cursores y triggers. Se trabaja sobre el sistema académico de las prácticas 1–4, que en esta guía se llama `Guia_5`.

| | |
|---|---|
| **Resultado de aprendizaje** | Implementar SP y UDF en MySQL para automatizar lógica de negocio dentro del SGBD |
| **Actividades** | Tarea previa · 1. SP de matrícula · 2. SP de promedio · 3. UDF · 4. SP con cursor · 5. Triggers |
| **SGBD** | MySQL 8.x (Windows) o MariaDB 10.5+ (Arch Linux). Los mismos scripts sirven en ambos |
| **Probado en** | MySQL 8.4.9 en Windows 11 (los 8 scripts en orden, y los scripts 2–5 ejecutados dos veces seguidas) |
| **Entregable final** | `Practica5_NombreEquipo.pdf` (vía Moodle UMB) |

### Preguntas orientadoras (respuesta corta)

| Pregunta | Respuesta |
|---|---|
| ¿SP vs. función? | Un SP se invoca con `CALL`, puede tener parámetros `OUT` y modificar datos. Una función devuelve **un** valor escalar y se usa dentro de un `SELECT` o un `WHERE`. |
| ¿Por qué centralizar la lógica en el SGBD? | Menos viajes cliente-servidor, la regla de negocio queda en un único sitio y el usuario puede ejecutar el SP sin tener permisos directos sobre las tablas. |
| ¿Cómo se usa un parámetro `OUT`? | Se pasa una variable de sesión: `CALL sp(..., @msg); SELECT @msg;` |
| ¿Cuándo conviene un cursor? | Cuando cada fila necesita una lógica propia que no se puede expresar en un solo `UPDATE`/`INSERT ... SELECT`. |
| ¿Para qué sirve un trigger? | Para que una regla se cumpla **siempre**, venga el `INSERT` de un SP, de Workbench o de otra aplicación. |

### Rúbrica (ponderación)

| Criterio | % | Qué evalúa |
|---|:-:|---|
| Procedimental | 35% | Organización y precisión de los resultados |
| Cognitiva | 35% | Aplicación de conceptos, relación teoría-práctica |
| Socio-afectiva | 10% | Participación y responsabilidad |
| Comunicativa | 10% | Calidad del informe |
| Investigativa | 10% | Fuentes citadas (APA 7) |

---

## Estado actual

| Bloque | Script | Capturas | Estado |
|---|---|:-:|:-:|
| Preparación (tablas + datos) | [`01_Tablas.sql`](Tablas%20y%20datos/01_Tablas.sql), [`02_Datos.sql`](Tablas%20y%20datos/02_Datos.sql) | — | Completo |
| Tarea previa — IN/OUT/INOUT + SP básico | [`00_TareaPrevia_SP.sql`](Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql) | 11 | Completo |
| Actividad 1 — SP de matrícula | [`01_Actividad1_SP_Matricula.sql`](Actividad-1/Script/01_Actividad1_SP_Matricula.sql) | 10 | Completo |
| Actividad 2 — SP de promedio | [`02_Actividad2_SP_Promedio.sql`](Actividad-2/Script/02_Actividad2_SP_Promedio.sql) | 14 | Completo |
| Actividad 3 — Funciones UDF | [`03_Actividad3_Funciones.sql`](Actividad-3/Script/03_Actividad3_Funciones.sql) | 1 | Script completo · capturas por rehacer |
| Actividad 4 — SP con cursor | [`04_Actividad4_SP_Cursor.sql`](Actividad-4/Script/04_Actividad4_SP_Cursor.sql) | 2 | Script completo · capturas por rehacer |
| Actividad 5 — Triggers | [`05_Actividad5_Triggers.sql`](Actividad-5/Script/05_Actividad5_Triggers.sql) | 2 | Script completo · capturas por rehacer |
| Informe final | `Informe/Practica5_NombreEquipo.pdf` | — | Pendiente |

> Las capturas de las actividades 3–5 se tomaron con la versión anterior de los scripts (otros nombres de funciones, triggers y columnas). Hay que volver a tomarlas con los scripts actuales y nombrarlas `ActividadN-M.png`.

---

## Estructura de carpetas

```
Guia5DB/
├── README.md                              ← este archivo
├── Tablas y datos/
│   ├── 01_Tablas.sql                      ← crea la BD Guia_5 y sus tablas
│   └── 02_Datos.sql                       ← carga los datos base (5 por tabla, 13 matrículas)
├── Actividad-tarea-previa/
│   ├── Script/00_TareaPrevia_SP.sql       ← IN/OUT/INOUT + respuesta cursores + SP básico
│   └── Imagenes/                          ← TareaPrevia-1.png ... TareaPrevia-11.png
├── Actividad-1/
│   ├── Script/01_Actividad1_SP_Matricula.sql  ← sp_registrar_matricula (OUT p_Mensaje)
│   └── Imagenes/                          ← Actividad1-1.png ... Actividad1-10.png
├── Actividad-2/
│   ├── Script/02_Actividad2_SP_Promedio.sql   ← sp_calcular_promedio + columnas de estado
│   └── Imagenes/                          ← Actividad2-1.png ... Actividad2-14.png
├── Actividad-3/
│   ├── Script/03_Actividad3_Funciones.sql ← fn_calcular_edad + fn_formatear_nombre
│   └── Imagenes/
├── Actividad-4/
│   ├── Script/04_Actividad4_SP_Cursor.sql ← sp_actualizar_estado_curso (cursor)
│   └── Imagenes/
├── Actividad-5/
│   ├── Script/05_Actividad5_Triggers.sql  ← trg_validar_nota + trg_auditoria_matricula
│   ├── Script/Prueba_rechazada.sql        ← INSERT con nota 5.5: captura del error del trigger
│   └── Imagenes/
└── Informe/                               ← PDF final para Moodle
```

Todos los comandos de este README se ejecutan **desde la carpeta raíz del proyecto** (la que contiene este `README.md`).

---

## Sistema base — Guia_5

Es la misma base de las prácticas anteriores (antes se llamaba `Guia_3`), ahora con el nombre **`Guia_5`**.

```
Programa (IdPrograma PK)
   └── Materia (IdMateria PK, IdPrograma FK)
          └── Grupo (IdGrupo PK, IdMateria FK, IdProfesor FK)  ← el "curso" de la guía
                 └── Matricula (IdMatricula PK, IdEstudiante FK, IdGrupo FK, NotaFinal)
Profesor (IdProfesor PK) ──┘                       │
Estudiante (IdEstudiante PK) ──────────────────────┘

AuditoriaMatricula (IdAuditoria PK AUTO_INCREMENT)  ← la llena el trigger de la Act. 5
```

| Tabla | Filas base | Notas |
|---|:-:|---|
| Programa | 5 | |
| Estudiante | 5 (+3 de prueba en Act. 2) | Act. 2 agrega `Promedio` y `EstadoAcademico` |
| Profesor | 5 | |
| Materia | 5 | `CreditosMateria` define el valor de la matrícula |
| Grupo | 5 | `Cupo` NULL = cupo ilimitado |
| Matricula | 13 | `IdMatricula` **no** es AUTO_INCREMENT: los SP calculan `MAX + 1`. Act. 4 agrega `EstadoCurso` |
| AuditoriaMatricula | 0 | Se crea en Act. 5. Sin FK a `Matricula`, para que el registro se conserve |

> **"Curso" = `Grupo`.** La guía habla de *IdCurso*, pero en este modelo el curso que se matricula es un **grupo** (materia + profesor + periodo). Por eso los SP reciben `IdGrupo`.

## Objetos programados

| Objeto | Tipo | Script | Qué hace |
|---|---|---|---|
| `sp_ejemplo_in` | SP | Tarea previa | Muestra un estudiante (parámetro `IN`) |
| `sp_ejemplo_out` | SP | Tarea previa | Devuelve el total de estudiantes (`OUT`) |
| `sp_ejemplo_inout` | SP | Tarea previa | Aplica un 10% de descuento a un valor (`INOUT`) |
| `sp_registrar_matricula_basico` | SP | Tarea previa | Matrícula simple con validación de existencia |
| `sp_registrar_matricula` | SP | Actividad 1 | Matrícula con validaciones, cupo y transacción |
| `sp_calcular_promedio` | SP | Actividad 2 | Promedio + clasificación + `UPDATE Estudiante` |
| `fn_calcular_edad` | FUNCTION | Actividad 3 | Edad en años a partir de una fecha |
| `fn_formatear_nombre` | FUNCTION | Actividad 3 | `"APELLIDOS, NOMBRES"` en mayúsculas |
| `sp_actualizar_estado_curso` | SP + CURSOR | Actividad 4 | Recorre las matrículas de un curso y pone `EstadoCurso` |
| `trg_validar_nota` | TRIGGER `BEFORE INSERT` | Actividad 5 | Rechaza notas fuera de 0.0–5.0 |
| `trg_auditoria_matricula` | TRIGGER `AFTER INSERT` | Actividad 5 | Registra cada matrícula en `AuditoriaMatricula` |
| `sp_probar_nota` | SP | Actividad 5 | Auxiliar de prueba: inserta con una nota y atrapa el error del trigger |

---

## Orden de ejecución

Ejecuta los scripts **en este orden**. Cada uno depende del anterior.

| # | Script | Qué hace | Se puede repetir |
|:-:|---|---|:-:|
| 1 | `Tablas y datos/01_Tablas.sql` | Crea `Guia_5` y borra/crea las tablas (incluye `AuditoriaMatricula`) | Sí |
| 2 | `Tablas y datos/02_Datos.sql` | Vacía las tablas y carga los datos base | Solo justo después del paso 1 |
| 3 | `Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql` | SP de ejemplo + SP básico (inserta matrícula 14) | Con cuidado: inserta otra matrícula |
| 4 | `Actividad-1/Script/01_Actividad1_SP_Matricula.sql` | `sp_registrar_matricula` + 7 pruebas (inserta 15 y 16) | Con cuidado: los válidos pasan a "ya está matriculado" |
| 5 | `Actividad-2/Script/02_Actividad2_SP_Promedio.sql` | Columnas de estado + `sp_calcular_promedio` + 9 pruebas | Sí |
| 6 | `Actividad-3/Script/03_Actividad3_Funciones.sql` | 2 funciones + 4 consultas de uso | Sí |
| 7 | `Actividad-4/Script/04_Actividad4_SP_Cursor.sql` | Columna `EstadoCurso` + SP con cursor + pruebas ANTES/DESPUÉS | Sí |
| 8 | `Actividad-5/Script/05_Actividad5_Triggers.sql` | Tabla de auditoría + 2 triggers + pruebas | Sí (cada vez agrega 2 matrículas válidas) |
| 9 | `Actividad-5/Script/Prueba_rechazada.sql` | `INSERT` directo con nota 5.5 | Sí (siempre falla igual) |

> **El paso 9 falla a propósito** con `ERROR 1644 (45000): ERROR: la nota final debe estar entre 0.0 y 5.0`. Es la captura del trigger rechazando un `INSERT` directo. Va en un archivo aparte para que los scripts 1–8 terminen sin errores.

**Para empezar desde cero** (por ejemplo, antes de tomar las capturas finales), vuelve a ejecutar los pasos **1 y 2**. Así la BD queda limpia y los pasos 3–8 producen exactamente los resultados que se documentan abajo.

---

## Comandos — Arch Linux (bash)

En Arch el motor es **MariaDB** (repositorio oficial). El cliente se llama `mariadb`; si instalaste MySQL desde el AUR, cambia `mariadb` por `mysql` en todos los comandos (los parámetros son los mismos).

### Instalación y servicio

```bash
# Opcion 1: MariaDB (repositorio oficial, recomendado)
sudo pacman -S mariadb
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mariadb
sudo mariadb-secure-installation

# Opcion 2: MySQL 8 desde el AUR (compila, tarda bastante)
yay -S mysql
sudo systemctl enable --now mysqld

# controlar el servicio
systemctl status mariadb          # estado (o mysqld)
sudo systemctl start mariadb      # iniciar
sudo systemctl stop mariadb       # detener
sudo systemctl restart mariadb    # reiniciar
journalctl -u mariadb -n 50       # ultimas lineas del log si no arranca

# version del cliente y del servidor
mariadb --version
mariadb -u joan -p -e "SELECT VERSION();"
```

### Crear un usuario propio (una sola vez)

En Arch, `root` entra por *unix_socket*: `mariadb -u root -p` falla, pero `sudo mariadb` funciona. Lo más cómodo es crear un usuario propio:

```bash
sudo mariadb
```
```sql
CREATE USER 'joan'@'localhost' IDENTIFIED BY 'tu_clave';
GRANT ALL PRIVILEGES ON Guia_5.* TO 'joan'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Desde ahí usa `-u joan -p` en todos los comandos. Si prefieres no crear usuario, cambia `mariadb -u joan -p` por `sudo mariadb`.

### Ejecutar los scripts uno por uno

```bash
cd ~/ruta/al/proyecto/Guia5DB

# 1 y 2: estructura y datos
mariadb -u joan -p --default-character-set=utf8mb4 < "Tablas y datos/01_Tablas.sql"
mariadb -u joan -p --default-character-set=utf8mb4 < "Tablas y datos/02_Datos.sql"

# 3: tarea previa
mariadb -u joan -p -t --default-character-set=utf8mb4 < "Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql"

# 4 y 5: actividades 1 y 2
mariadb -u joan -p -t --default-character-set=utf8mb4 < "Actividad-1/Script/01_Actividad1_SP_Matricula.sql"
mariadb -u joan -p -t --default-character-set=utf8mb4 < "Actividad-2/Script/02_Actividad2_SP_Promedio.sql"

# 6, 7 y 8: actividades 3, 4 y 5
mariadb -u joan -p -t --default-character-set=utf8mb4 < "Actividad-3/Script/03_Actividad3_Funciones.sql"
mariadb -u joan -p -t --default-character-set=utf8mb4 < "Actividad-4/Script/04_Actividad4_SP_Cursor.sql"
mariadb -u joan -p -t --default-character-set=utf8mb4 < "Actividad-5/Script/05_Actividad5_Triggers.sql"

# 9: captura del error del trigger (falla a proposito con ERROR 1644)
mariadb -u joan -p -t --default-character-set=utf8mb4 < "Actividad-5/Script/Prueba_rechazada.sql"

# sin usuario propio (root por socket)
sudo mariadb -t --default-character-set=utf8mb4 < "Tablas y datos/01_Tablas.sql"
```

> `-t` imprime los resultados como tabla con bordes (sirve para las capturas). `-v` además muestra cada sentencia antes de su resultado: `mariadb -u joan -p -t -v < archivo.sql`.

### Ejecutar todo de una vez

Pide la contraseña una sola vez; la guarda solo en la variable de la sesión:

```bash
read -rsp "Password MariaDB: " MYSQL_PWD && echo && export MYSQL_PWD
for s in "Tablas y datos/01_Tablas.sql" \
         "Tablas y datos/02_Datos.sql" \
         "Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql" \
         "Actividad-1/Script/01_Actividad1_SP_Matricula.sql" \
         "Actividad-2/Script/02_Actividad2_SP_Promedio.sql" \
         "Actividad-3/Script/03_Actividad3_Funciones.sql" \
         "Actividad-4/Script/04_Actividad4_SP_Cursor.sql" \
         "Actividad-5/Script/05_Actividad5_Triggers.sql"; do
  printf '\n\e[36m>>> %s\e[0m\n' "$s"
  mariadb -u joan -t --default-character-set=utf8mb4 < "$s" || break
done

# captura del error del trigger (falla a proposito)
mariadb -u joan -t --default-character-set=utf8mb4 < "Actividad-5/Script/Prueba_rechazada.sql"
unset MYSQL_PWD
```

> `Prueba_rechazada.sql` va fuera del bucle a propósito: si estuviera dentro, el `|| break` lo trataría como un fallo real.

Alternativa permanente: un archivo `~/.my.cnf` que solo tu usuario puede leer (la contraseña nunca va dentro de un `.sql`):

```bash
cat > ~/.my.cnf <<'EOF'
[client]
user=joan
password=tu_clave
default-character-set=utf8mb4
EOF
chmod 600 ~/.my.cnf

# desde ahi, sin -u ni -p
mariadb -t Guia_5 < "Actividad-3/Script/03_Actividad3_Funciones.sql"
```

### Reiniciar la base (antes de las capturas finales)

```bash
mariadb -u joan -p < "Tablas y datos/01_Tablas.sql" && \
mariadb -u joan -p < "Tablas y datos/02_Datos.sql"

# o borrar la BD completa y volver a crearla
mariadb -u joan -p -e "DROP DATABASE IF EXISTS Guia_5;"
```

> Para `DROP DATABASE` / `CREATE DATABASE` el usuario `joan` necesita permisos globales; si no los tiene, usa `sudo mariadb -e "DROP DATABASE IF EXISTS Guia_5;"`.

### Consultas rápidas sin entrar al cliente (`-e`)

```bash
# datos
mariadb -u joan -p -t Guia_5 -e "SELECT * FROM Estudiante;"
mariadb -u joan -p -t Guia_5 -e "SELECT * FROM Matricula ORDER BY IdMatricula;"
mariadb -u joan -p -t Guia_5 -e "SHOW TABLES;"

# tarea previa
mariadb -u joan -p -t Guia_5 -e "CALL sp_ejemplo_in(1031422990);"
mariadb -u joan -p -t Guia_5 -e "CALL sp_ejemplo_out(@t); SELECT @t;"
mariadb -u joan -p -t Guia_5 -e "SET @v = 1200000; CALL sp_ejemplo_inout(@v); SELECT @v;"

# actividad 1
mariadb -u joan -p -t Guia_5 -e "CALL sp_registrar_matricula(1122151498, 2, @m); SELECT @m;"

# actividad 2
mariadb -u joan -p -t Guia_5 -e "CALL sp_calcular_promedio(1031422990, @p, @c); SELECT @p, @c;"

# actividad 3
mariadb -u joan -p -t Guia_5 -e "SELECT fn_formatear_nombre(PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido) AS Nombre, fn_calcular_edad(FechaNacimiento) AS Edad FROM Estudiante;"

# actividad 4
mariadb -u joan -p -t Guia_5 -e "CALL sp_actualizar_estado_curso(1, @m); SELECT @m;"
mariadb -u joan -p -t Guia_5 -e "SELECT IdMatricula, IdGrupo, NotaFinal, EstadoCurso FROM Matricula WHERE IdGrupo = 1;"

# actividad 5
mariadb -u joan -p -t Guia_5 -e "CALL sp_probar_nota(1011765342, 5, 5.5, @m); SELECT @m;"
mariadb -u joan -p -t Guia_5 -e "SELECT * FROM AuditoriaMatricula;"
mariadb -u joan -p -t Guia_5 -e "SHOW TRIGGERS FROM Guia_5;"
```

> En bash usa comillas dobles alrededor de `-e "..."`. Las variables `@m` no se expanden (no llevan `$`).

### Cliente interactivo

```bash
mariadb -u joan -p Guia_5          # entra directo a Guia_5
```
```sql
-- dentro del cliente: source toma la ruta relativa a la carpeta desde donde abriste mariadb
source Tablas y datos/01_Tablas.sql
source Tablas y datos/02_Datos.sql
source Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql
source Actividad-1/Script/01_Actividad1_SP_Matricula.sql
source Actividad-2/Script/02_Actividad2_SP_Promedio.sql
source Actividad-3/Script/03_Actividad3_Funciones.sql
source Actividad-4/Script/04_Actividad4_SP_Cursor.sql
source Actividad-5/Script/05_Actividad5_Triggers.sql

-- utilidades del cliente
status;                        -- servidor, usuario, BD actual, charset
tee salida.txt;                -- empieza a copiar todo lo que sale a un archivo
notee;                         -- deja de copiar
pager less -S;                 -- tablas anchas con scroll horizontal
nopager;
exit;
```

### Guardar la salida y respaldar

```bash
# salida de un script a archivo (para el informe)
mariadb -u joan -p -t < "Actividad-4/Script/04_Actividad4_SP_Cursor.sql" | tee actividad4_salida.txt

# respaldo completo: tablas, datos, SP, funciones y triggers
mariadb-dump -u joan -p --routines --triggers Guia_5 > Guia_5_respaldo.sql

# restaurar el respaldo
mariadb -u joan -p Guia_5 < Guia_5_respaldo.sql
```

---

## Comandos — Windows (cmd)

En Windows el motor es **MySQL Server 8.x** (instalado con *MySQL Installer*, junto con MySQL Workbench).

### PATH y servicio

```bat
:: agregar el cliente al PATH solo para esta ventana
set PATH=%PATH%;C:\Program Files\MySQL\MySQL Server 8.4\bin

:: agregarlo de forma permanente para tu usuario (abre una ventana nueva despues)
setx PATH "%PATH%;C:\Program Files\MySQL\MySQL Server 8.4\bin"

:: comprobar
where mysql
mysql --version

:: servicio (cmd como ADMINISTRADOR)
sc query MySQL84
net start MySQL84
net stop MySQL84
```

> Si tu versión es otra, cambia `8.4` y `MySQL84` (ver con `sc query type= service state= all | findstr MySQL`).

### Tildes y ñ en la consola

```bat
chcp 65001
```

Y agrega siempre `--default-character-set=utf8mb4` al comando `mysql`.

### Ejecutar los scripts uno por uno

```bat
cd C:\ruta\al\proyecto\Guia5DB

:: 1 y 2: estructura y datos
mysql -u root -p --default-character-set=utf8mb4 < "Tablas y datos\01_Tablas.sql"
mysql -u root -p --default-character-set=utf8mb4 < "Tablas y datos\02_Datos.sql"

:: 3: tarea previa
mysql -u root -p -t --default-character-set=utf8mb4 < "Actividad-tarea-previa\Script\00_TareaPrevia_SP.sql"

:: 4 y 5: actividades 1 y 2
mysql -u root -p -t --default-character-set=utf8mb4 < "Actividad-1\Script\01_Actividad1_SP_Matricula.sql"
mysql -u root -p -t --default-character-set=utf8mb4 < "Actividad-2\Script\02_Actividad2_SP_Promedio.sql"

:: 6, 7 y 8: actividades 3, 4 y 5
mysql -u root -p -t --default-character-set=utf8mb4 < "Actividad-3\Script\03_Actividad3_Funciones.sql"
mysql -u root -p -t --default-character-set=utf8mb4 < "Actividad-4\Script\04_Actividad4_SP_Cursor.sql"
mysql -u root -p -t --default-character-set=utf8mb4 < "Actividad-5\Script\05_Actividad5_Triggers.sql"

:: 9: captura del error del trigger (falla a proposito con ERROR 1644)
mysql -u root -p -t --default-character-set=utf8mb4 < "Actividad-5\Script\Prueba_rechazada.sql"
```

> El paso 9 termina en `ERROR 1644` a propósito (ver [Actividad 5](#actividad-5--triggers)).

### Guardar la contraseña cifrada (una sola vez)

`mysql_config_editor` guarda la credencial cifrada en tu perfil de usuario, nunca en texto plano dentro del código (recomendación 11 de la guía):

```bat
mysql_config_editor set --login-path=local --host=localhost --user=root --password
mysql_config_editor print --all
mysql_config_editor remove --login-path=local
```

Desde ahí usa `--login-path=local` en lugar de `-u root -p`.

### Ejecutar todo de una vez

Escrito directo en la consola `cmd` (con `%f`):

```bat
for %f in ("Tablas y datos\01_Tablas.sql" "Tablas y datos\02_Datos.sql" "Actividad-tarea-previa\Script\00_TareaPrevia_SP.sql" "Actividad-1\Script\01_Actividad1_SP_Matricula.sql" "Actividad-2\Script\02_Actividad2_SP_Promedio.sql" "Actividad-3\Script\03_Actividad3_Funciones.sql" "Actividad-4\Script\04_Actividad4_SP_Cursor.sql" "Actividad-5\Script\05_Actividad5_Triggers.sql") do @echo. & @echo ^>^>^> %f & mysql --login-path=local -t --default-character-set=utf8mb4 < %f
```

Como archivo `ejecutar_todo.bat` (dentro de un `.bat` se escribe `%%f`):

```bat
@echo off
chcp 65001 > nul
for %%f in (
  "Tablas y datos\01_Tablas.sql"
  "Tablas y datos\02_Datos.sql"
  "Actividad-tarea-previa\Script\00_TareaPrevia_SP.sql"
  "Actividad-1\Script\01_Actividad1_SP_Matricula.sql"
  "Actividad-2\Script\02_Actividad2_SP_Promedio.sql"
  "Actividad-3\Script\03_Actividad3_Funciones.sql"
  "Actividad-4\Script\04_Actividad4_SP_Cursor.sql"
  "Actividad-5\Script\05_Actividad5_Triggers.sql"
) do (
  echo.
  echo ^>^>^> %%f
  mysql --login-path=local -t --default-character-set=utf8mb4 < %%f
)
echo.
echo ^>^>^> Prueba_rechazada.sql (falla a proposito)
mysql --login-path=local -t --default-character-set=utf8mb4 < "Actividad-5\Script\Prueba_rechazada.sql"
pause
```

Con la línea de consola, ejecuta después la prueba rechazada por separado:

```bat
mysql --login-path=local -t --default-character-set=utf8mb4 < "Actividad-5\Script\Prueba_rechazada.sql"
```

### Reiniciar la base

```bat
mysql --login-path=local < "Tablas y datos\01_Tablas.sql" && mysql --login-path=local < "Tablas y datos\02_Datos.sql"

:: o borrar la BD completa
mysql --login-path=local -e "DROP DATABASE IF EXISTS Guia_5;"
```

### Consultas rápidas sin entrar al cliente (`-e`)

```bat
:: datos
mysql --login-path=local -t Guia_5 -e "SELECT * FROM Estudiante;"
mysql --login-path=local -t Guia_5 -e "SELECT * FROM Matricula ORDER BY IdMatricula;"
mysql --login-path=local -t Guia_5 -e "SHOW TABLES;"

:: tarea previa
mysql --login-path=local -t Guia_5 -e "CALL sp_ejemplo_in(1031422990);"
mysql --login-path=local -t Guia_5 -e "CALL sp_ejemplo_out(@t); SELECT @t;"
mysql --login-path=local -t Guia_5 -e "SET @v = 1200000; CALL sp_ejemplo_inout(@v); SELECT @v;"

:: actividad 1
mysql --login-path=local -t Guia_5 -e "CALL sp_registrar_matricula(1122151498, 2, @m); SELECT @m;"

:: actividad 2
mysql --login-path=local -t Guia_5 -e "CALL sp_calcular_promedio(1031422990, @p, @c); SELECT @p, @c;"

:: actividad 3
mysql --login-path=local -t Guia_5 -e "SELECT fn_formatear_nombre(PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido) AS Nombre, fn_calcular_edad(FechaNacimiento) AS Edad FROM Estudiante;"

:: actividad 4
mysql --login-path=local -t Guia_5 -e "CALL sp_actualizar_estado_curso(1, @m); SELECT @m;"
mysql --login-path=local -t Guia_5 -e "SELECT IdMatricula, IdGrupo, NotaFinal, EstadoCurso FROM Matricula WHERE IdGrupo = 1;"

:: actividad 5
mysql --login-path=local -t Guia_5 -e "CALL sp_probar_nota(1011765342, 5, 5.5, @m); SELECT @m;"
mysql --login-path=local -t Guia_5 -e "SELECT * FROM AuditoriaMatricula;"
mysql --login-path=local -t Guia_5 -e "SHOW TRIGGERS FROM Guia_5;"
```

> En `cmd` el texto de `-e` va **siempre entre comillas dobles**; las comillas simples no agrupan.

### Cliente interactivo, salida y respaldo

```bat
:: entrar
mysql --login-path=local Guia_5

:: dentro del cliente (mismas sentencias que en Linux)
::   source Actividad-4/Script/04_Actividad4_SP_Cursor.sql
::   tee salida.txt;   notee;   status;   exit;

:: salida de un script a archivo
mysql --login-path=local -t < "Actividad-4\Script\04_Actividad4_SP_Cursor.sql" > actividad4_salida.txt

:: respaldo completo y restauracion
mysqldump --login-path=local --routines --triggers Guia_5 > Guia_5_respaldo.sql
mysql --login-path=local Guia_5 < Guia_5_respaldo.sql
```

---

## Comandos — Windows (PowerShell)

PowerShell **no admite `<`**, así que se usa una tubería con `Get-Content -Raw`.

```powershell
# PATH solo para la sesion actual
$env:Path += ";C:\Program Files\MySQL\MySQL Server 8.4\bin"

# PATH permanente para tu usuario
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
[Environment]::SetEnvironmentVariable("Path", "$userPath;C:\Program Files\MySQL\MySQL Server 8.4\bin", "User")

# servicio (PowerShell como ADMINISTRADOR)
Get-Service MySQL*
Start-Service MySQL84
Stop-Service  MySQL84

# un script
Get-Content -Raw ".\Actividad-3\Script\03_Actividad3_Funciones.sql" | mysql -u root -p -t --default-character-set=utf8mb4

# todos en orden (con mysql_config_editor configurado)
$scripts = @(
  ".\Tablas y datos\01_Tablas.sql",
  ".\Tablas y datos\02_Datos.sql",
  ".\Actividad-tarea-previa\Script\00_TareaPrevia_SP.sql",
  ".\Actividad-1\Script\01_Actividad1_SP_Matricula.sql",
  ".\Actividad-2\Script\02_Actividad2_SP_Promedio.sql",
  ".\Actividad-3\Script\03_Actividad3_Funciones.sql",
  ".\Actividad-4\Script\04_Actividad4_SP_Cursor.sql",
  ".\Actividad-5\Script\05_Actividad5_Triggers.sql"
)
foreach ($s in $scripts) {
  Write-Host "`n>>> $s" -ForegroundColor Cyan
  Get-Content -Raw $s | mysql --login-path=local -t --default-character-set=utf8mb4
}

# captura del error del trigger (falla a proposito)
Get-Content -Raw ".\Actividad-5\Script\Prueba_rechazada.sql" | mysql --login-path=local -t --default-character-set=utf8mb4

# guardar la salida
Get-Content -Raw ".\Actividad-4\Script\04_Actividad4_SP_Cursor.sql" | mysql --login-path=local -t | Tee-Object actividad4_salida.txt

# consulta rapida
mysql --login-path=local -t Guia_5 -e "CALL sp_actualizar_estado_curso(1, @m); SELECT @m;"
```

---

## Comandos — MySQL Workbench

1. Abre la conexión `root@localhost`.
2. `File → Open SQL Script...` y elige el script.
3. Ejecuta **todo el script** con el botón del rayo (`Ctrl + Shift + Enter`). No uses "ejecutar línea actual" (`Ctrl + Enter`) sobre un bloque `DELIMITER`: se rompe.
4. Cada `SELECT` abre una pestaña *Result*. Esas pestañas son las capturas.
5. Para refrescar SP, funciones y triggers en el panel izquierdo: clic derecho en `Guia_5` → *Refresh All*.
6. Al ejecutar `Prueba_rechazada.sql`, el `INSERT` aparece en rojo en *Output*: es la captura del error del trigger.

---

## Consultas SQL para cada cosa

Estas sentencias funcionan igual en MySQL y MariaDB, desde Workbench, el cliente interactivo o `-e "..."`.

### Ver los datos

```sql
USE Guia_5;
SHOW TABLES;

SELECT * FROM Programa;
SELECT * FROM Estudiante;
SELECT * FROM Profesor;
SELECT * FROM Materia;
SELECT * FROM Grupo;
SELECT * FROM Matricula ORDER BY IdMatricula;
SELECT * FROM AuditoriaMatricula ORDER BY IdAuditoria;

-- estructura de las tablas que cambian en la practica
DESCRIBE Estudiante;          -- Promedio, EstadoAcademico (Act. 2)
DESCRIBE Matricula;           -- EstadoCurso (Act. 4)
DESCRIBE AuditoriaMatricula;  -- Act. 5
```

### Tarea previa

```sql
CALL sp_ejemplo_in(1031422990);
CALL sp_ejemplo_out(@total);        SELECT @total;
SET @valor = 1200000;
CALL sp_ejemplo_inout(@valor);      SELECT @valor;
CALL sp_registrar_matricula_basico(1122151498, 1);
```

### Actividad 1 — matrícula

```sql
CALL sp_registrar_matricula(1030281186, 1, @msg);  SELECT @msg;   -- valido
CALL sp_registrar_matricula(999, 1, @msg);         SELECT @msg;   -- estudiante no existe
CALL sp_registrar_matricula(1030281186, 99, @msg); SELECT @msg;   -- curso no existe
CALL sp_registrar_matricula(NULL, 1, @msg);        SELECT @msg;   -- parametro nulo
```

### Actividad 2 — promedio

```sql
CALL sp_calcular_promedio(1031422990, @p, @c);
SELECT @p AS Promedio, @c AS Clasificacion;

SELECT IdEstudiante, PrimerNombre, Promedio, EstadoAcademico FROM Estudiante ORDER BY Promedio DESC;

SELECT EstadoAcademico, COUNT(*) AS Estudiantes
FROM Estudiante
GROUP BY EstadoAcademico;
```

### Actividad 3 — funciones

```sql
SELECT fn_calcular_edad('2007-12-18');
SELECT fn_formatear_nombre('Joan', 'Sebastian', 'Romagna', 'Taverna');

SELECT fn_formatear_nombre(PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido) AS Estudiante,
       fn_calcular_edad(FechaNacimiento) AS Edad
FROM Estudiante
WHERE fn_calcular_edad(FechaNacimiento) >= 18;
```

### Actividad 4 — cursor

```sql
CALL sp_actualizar_estado_curso(1, @msg);  SELECT @msg;

SELECT IdMatricula, IdEstudiante, IdGrupo, NotaFinal, EstadoCurso
FROM Matricula
WHERE IdGrupo = 1;

-- volver todas a "Sin evaluar" para repetir la captura ANTES
UPDATE Matricula SET EstadoCurso = 'Sin evaluar' WHERE IdMatricula > 0;
```

### Actividad 5 — triggers

```sql
-- por el SP auxiliar (no detiene el script)
CALL sp_probar_nota(1011765342, 5, 4.9, @msg); SELECT @msg;   -- aceptada
CALL sp_probar_nota(1011765342, 5, 5.5, @msg); SELECT @msg;   -- rechazada

-- INSERT directo: muestra el error 1644 del trigger (lo mismo que Prueba_rechazada.sql)
INSERT INTO Matricula (IdMatricula, IdEstudiante, IdGrupo, FechaMatricula, NotaFinal, ValorMatricula)
VALUES (9999, 1031422990, 2, CURDATE(), 5.5, 950000);

SELECT * FROM AuditoriaMatricula ORDER BY IdAuditoria;
SHOW TRIGGERS FROM Guia_5;
```

### Inspeccionar los objetos programados

```sql
-- listar SP y funciones
SHOW PROCEDURE STATUS WHERE Db = 'Guia_5';
SHOW FUNCTION  STATUS WHERE Db = 'Guia_5';

-- lo mismo desde information_schema
SELECT ROUTINE_NAME, ROUTINE_TYPE, CREATED
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'Guia_5'
ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

-- triggers
SHOW TRIGGERS FROM Guia_5;
SELECT TRIGGER_NAME, ACTION_TIMING, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
FROM information_schema.TRIGGERS
WHERE TRIGGER_SCHEMA = 'Guia_5';

-- ver el codigo (en el cliente de terminal, \G muestra el resultado en vertical)
SHOW CREATE PROCEDURE sp_registrar_matricula\G
SHOW CREATE PROCEDURE sp_calcular_promedio\G
SHOW CREATE PROCEDURE sp_actualizar_estado_curso\G
SHOW CREATE FUNCTION  fn_calcular_edad\G
SHOW CREATE FUNCTION  fn_formatear_nombre\G
SHOW CREATE TRIGGER   trg_validar_nota\G
SHOW CREATE TRIGGER   trg_auditoria_matricula\G

-- parametros de un SP
SELECT PARAMETER_MODE, PARAMETER_NAME, DTD_IDENTIFIER
FROM information_schema.PARAMETERS
WHERE SPECIFIC_SCHEMA = 'Guia_5' AND SPECIFIC_NAME = 'sp_registrar_matricula'
ORDER BY ORDINAL_POSITION;
```

> En Workbench quita el `\G` y termina la sentencia con `;`.

### Consultas de verificación

```sql
-- matriculas con nombre de estudiante, curso y estado
SELECT m.IdMatricula, CONCAT(e.PrimerNombre,' ',e.PrimerApellido) AS Estudiante,
       ma.NombreMateria, m.NotaFinal, m.ValorMatricula, m.EstadoCurso
FROM Matricula m
JOIN Estudiante e ON e.IdEstudiante = m.IdEstudiante
JOIN Grupo g      ON g.IdGrupo      = m.IdGrupo
JOIN Materia ma   ON ma.IdMateria   = g.IdMateria
ORDER BY m.IdMatricula;

-- ocupacion de cada curso frente a su cupo
SELECT g.IdGrupo, ma.NombreMateria, COUNT(m.IdMatricula) AS Inscritos, g.Cupo
FROM Grupo g
JOIN Materia ma ON ma.IdMateria = g.IdMateria
LEFT JOIN Matricula m ON m.IdGrupo = g.IdGrupo
GROUP BY g.IdGrupo, ma.NombreMateria, g.Cupo;
```

### Borrar objetos (para rehacer una actividad)

```sql
DROP PROCEDURE IF EXISTS sp_registrar_matricula;
DROP PROCEDURE IF EXISTS sp_calcular_promedio;
DROP PROCEDURE IF EXISTS sp_actualizar_estado_curso;
DROP PROCEDURE IF EXISTS sp_probar_nota;
DROP FUNCTION  IF EXISTS fn_calcular_edad;
DROP FUNCTION  IF EXISTS fn_formatear_nombre;
DROP TRIGGER   IF EXISTS trg_validar_nota;
DROP TRIGGER   IF EXISTS trg_auditoria_matricula;
DROP TABLE     IF EXISTS AuditoriaMatricula;

-- quitar las columnas agregadas
ALTER TABLE Estudiante DROP COLUMN Promedio, DROP COLUMN EstadoAcademico;   -- Act. 2
ALTER TABLE Matricula  DROP COLUMN EstadoCurso;                             -- Act. 4
```

---

# Parte 2 — Actividades

## Tarea previa — Parámetros IN/OUT/INOUT y SP básico

Script: [`Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql`](Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql)

| Punto | Contenido |
|:-:|---|
| 1 | Tres SP de ejemplo, uno por tipo de parámetro |
| 2 | Respuesta sobre cursores (comentario, ≤ 100 palabras) |
| 3 | `sp_registrar_matricula_basico(IdEstudiante, IdGrupo)`: verifica que existan e inserta con `CURDATE()` |

### Diferencia IN / OUT / INOUT

| Tipo | Dirección | Ejemplo en el script | Llamada | Resultado |
|---|---|---|---|---|
| `IN` | entra, solo lectura | `sp_ejemplo_in(p_IdEstudiante)` | `CALL sp_ejemplo_in(1031422990);` | fila de Juan Gamez |
| `OUT` | sale, el SP la escribe | `sp_ejemplo_out(p_Total)` | `CALL sp_ejemplo_out(@total); SELECT @total;` | `5` |
| `INOUT` | entra, se modifica y sale | `sp_ejemplo_inout(p_Valor)` | `SET @valor = 1200000; CALL sp_ejemplo_inout(@valor); SELECT @valor;` | `1080000` |

### Pruebas del SP básico

| Llamada | Resultado esperado |
|---|---|
| `CALL sp_registrar_matricula_basico(1122151498, 1);` | `Matricula 14 registrada` |
| `CALL sp_registrar_matricula_basico(999, 1);` | `Error: el estudiante no existe` |
| `CALL sp_registrar_matricula_basico(1122151498, 99);` | `Error: el curso no existe` |

---

## Actividad 1 — SP de matrícula

Script: [`Actividad-1/Script/01_Actividad1_SP_Matricula.sql`](Actividad-1/Script/01_Actividad1_SP_Matricula.sql)

```sql
sp_registrar_matricula(
    IN  p_IdEstudiante INT,
    IN  p_IdGrupo      INT,
    OUT p_Mensaje      VARCHAR(200)
)
```

### Flujo del SP

```
¿parámetros NULL? ──sí──► ERROR: obligatorios
        │no
¿existe estudiante? ─no─► ERROR: estudiante no existe
        │sí
¿existe curso? ──────no─► ERROR: curso no existe
        │sí
¿ya matriculado? ────sí─► ERROR: ya está matriculado
        │no
START TRANSACTION
¿cupo lleno? ────────sí─► ROLLBACK + ERROR: sin cupo
        │no
IdMatricula = MAX + 1
Valor = 200.000 + 250.000 × créditos
INSERT ... CURDATE(), NotaFinal NULL
COMMIT ─────────────────► EXITO: matrícula N registrada

(cualquier error SQL) ──► EXIT HANDLER: ROLLBACK + "ERROR SQL: ..."
```

**Conceptos aplicados:** parámetro `OUT`, `IF/ELSEIF`, `EXISTS`, `DECLARE EXIT HANDLER FOR SQLEXCEPTION`, `GET DIAGNOSTICS`, transacción (`START TRANSACTION / COMMIT / ROLLBACK`) y bloqueo `SELECT ... FOR UPDATE` sobre el grupo para que dos matrículas simultáneas no se salten el cupo.

**Valor de la matrícula:** sale de los créditos de la materia, con el mismo patrón que siguen los datos base (1 crédito = 450.000, 2 = 700.000, 3 = 950.000, 4 = 1.200.000).

### Pruebas y resultado esperado

| # | Tipo | Llamada | `@msg` esperado |
|:-:|---|---|---|
| 1 | Válido | `CALL sp_registrar_matricula(1030281186, 1, @msg);` | `EXITO: matricula 15 registrada ...` |
| 2 | Válido | `CALL sp_registrar_matricula(1028886975, 3, @msg);` | `EXITO: matricula 16 registrada ...` |
| 3 | Inválido: estudiante | `CALL sp_registrar_matricula(999, 1, @msg);` | `ERROR: el estudiante 999 no existe` |
| 4 | Inválido: curso | `CALL sp_registrar_matricula(1030281186, 99, @msg);` | `ERROR: el curso 99 no existe` |
| 5 | Inválido: nulo | `CALL sp_registrar_matricula(NULL, 1, @msg);` | `ERROR: estudiante y curso son obligatorios` |
| 6 | Inválido: duplicado | `CALL sp_registrar_matricula(1031422990, 1, @msg);` | `ERROR: el estudiante ya esta matriculado en ese curso` |
| 7 | Inválido: sin cupo | cupo del grupo 2 bajado a 3 → `CALL sp_registrar_matricula(1030281186, 2, @msg);` | `ERROR: el curso 2 no tiene cupo (3/3)` |

> Los números 15 y 16 suponen que antes se ejecutó la tarea previa (matrícula 14).

**Capturas sugeridas:** `SELECT` ANTES · cada `SELECT @msg` · `SELECT` DESPUÉS (solo deben aparecer las 2 matrículas válidas nuevas, con `NotaFinal` NULL).

---

## Actividad 2 — SP de promedio y clasificación

Script: [`Actividad-2/Script/02_Actividad2_SP_Promedio.sql`](Actividad-2/Script/02_Actividad2_SP_Promedio.sql)

```sql
sp_calcular_promedio(
    IN  p_IdEstudiante  INT,
    OUT p_Promedio      DECIMAL(3,2),
    OUT p_Clasificacion VARCHAR(40)
)
```

### Qué hace

1. **Preparación:** agrega a `Estudiante` las columnas `Promedio DECIMAL(3,2)` y `EstadoAcademico VARCHAR(20) DEFAULT 'Sin calificar'` (solo si no existen).
2. **Datos de prueba:** con los datos base solo salen "Bueno" y "Aprobado", así que agrega 3 estudiantes (Excelente, Reprobado y sin notas) con `INSERT IGNORE`.
3. **SP:** calcula `ROUND(AVG(NotaFinal), 2)` (AVG ignora las notas NULL), clasifica con `CASE` y hace `UPDATE Estudiante` dentro de una transacción.

### Escala

| Promedio | Clasificación |
|---|---|
| ≥ 4.5 | Excelente |
| ≥ 4.0 | Bueno |
| ≥ 3.0 | Aprobado |
| < 3.0 | Reprobado |
| sin notas | Sin calificar |

### Resultado esperado

| IdEstudiante | Estudiante | Notas | Promedio | Estado |
|---|---|---|:-:|---|
| 1000000001 | Laura Rojas | 4.8, 4.6 | 4.70 | **Excelente** |
| 1122151498 | Andres Viafara | 4.3 | 4.30 | **Bueno** |
| 1031422990 | Juan Gamez | 4.5, 4.2, 3.9, 4.8, 4.0 | 4.28 | **Bueno** |
| 1028886975 | Joan Romagna | 3.8, 4.1, 4.6 | 4.17 | **Bueno** |
| 1011765342 | Esteban Salvador | 3.5, 4.0, 4.7 | 4.07 | **Bueno** |
| 1030281186 | Andres Dueñas | 3.7 | 3.70 | **Aprobado** |
| 1000000002 | Carlos Mejia | 2.5, 2.9 | 2.70 | **Reprobado** |
| 1000000003 | Sofia Castro | — | NULL | **Sin calificar** |
| 999 | (no existe) | — | NULL | `ERROR: el estudiante no existe` |

**Capturas sugeridas:** `SELECT` ANTES (todos en "Sin calificar") · el resultado de cada `CALL` · `SELECT` DESPUÉS con el estado actualizado.

---

## Actividad 3 — Funciones (UDF)

Script: [`Actividad-3/Script/03_Actividad3_Funciones.sql`](Actividad-3/Script/03_Actividad3_Funciones.sql)

```sql
fn_calcular_edad(p_Fecha DATE) RETURNS INT
fn_formatear_nombre(p_PrimerNombre, p_SegundoNombre, p_PrimerApellido, p_SegundoApellido) RETURNS VARCHAR(210)
```

### Qué hace

| Función | Lógica | Características |
|---|---|---|
| `fn_calcular_edad` | `TIMESTAMPDIFF(YEAR, p_Fecha, CURDATE())`; si la fecha es NULL devuelve NULL | `NOT DETERMINISTIC` (depende del día actual) · `NO SQL` |
| `fn_formatear_nombre` | `UPPER(CONCAT_WS(', ', apellidos, nombres))`; `CONCAT_WS` + `NULLIF(TRIM(...), '')` saltan los nombres vacíos o NULL | `DETERMINISTIC` · `NO SQL` |

> Declarar `NO SQL` (no leen tablas) evita el error **1418** cuando el binlog está activo, sin tener que cambiar `log_bin_trust_function_creators`.

### Pruebas del script

| # | Consulta | Qué muestra |
|:-:|---|---|
| 1 | Llamadas sueltas | `fn_calcular_edad('2007-12-18')`, `fn_calcular_edad(NULL)` → NULL, nombre con y sin segundo nombre |
| 2 | `SELECT` sobre `Estudiante` | nombre formateado + edad de todos los estudiantes |
| 3 | `SELECT` sobre `Profesor` | la misma función sirve con otras columnas |
| 4 | Función en `WHERE` | estudiantes con 18 años o más |

### Resultado esperado (al 2026-10-26)

| IdEstudiante | Estudiante | FechaNacimiento | Edad |
|---|---|---|:-:|
| 1000000003 | CASTRO LEON, SOFIA | 2007-01-25 | 19 |
| 1030281186 | DUEÑAS MARTINEZ, ANDRES FELIPE | 2007-07-19 | 19 |
| 1031422990 | GAMEZ NIETO, JUAN MANUEL | 2007-11-10 | 18 |
| 1000000002 | MEJIA RUIZ, CARLOS | 2005-08-02 | 21 |
| 1000000001 | ROJAS PINTO, LAURA | 2006-03-14 | 20 |
| 1028886975 | ROMAGNA TAVERNA, JOAN SEBASTIAN | 2007-12-18 | 18 |
| 1011765342 | SALVADOR GUZMAN, ESTEBAN | 1991-05-24 | 35 |
| 1122151498 | VIAFARA MARCHENA, ANDRES EDUARDO | 2007-09-07 | 19 |

> La edad cambia con la fecha en que se ejecute. Los profesores 504 y 505 tienen fechas de nacimiento de 1901 y 1575 en los datos base, por eso salen con 125 y 451 años.

**Capturas sugeridas:** la consulta 1 (llamadas sueltas) · la consulta 2 sobre `Estudiante` · la consulta 4 con la función en el `WHERE`.

---

## Actividad 4 — SP con cursor

Script: [`Actividad-4/Script/04_Actividad4_SP_Cursor.sql`](Actividad-4/Script/04_Actividad4_SP_Cursor.sql)

```sql
sp_actualizar_estado_curso(
    IN  p_IdGrupo INT,
    OUT p_Mensaje VARCHAR(200)
)
```

### Qué hace

1. **Preparación:** agrega a `Matricula` la columna `EstadoCurso VARCHAR(20) DEFAULT 'Sin evaluar'`, solo si no existe (misma técnica de `information_schema` + `PREPARE` que la Actividad 2).
2. **SP:** valida el curso, abre un **cursor** sobre las matrículas de ese grupo y, fila por fila, decide el estado y hace `UPDATE ... WHERE IdMatricula = v_IdMatricula`. Todo va dentro de una transacción con `EXIT HANDLER`.
3. Devuelve en `p_Mensaje` cuántas matrículas quedaron aprobadas, reprobadas y pendientes.

### Regla

| NotaFinal | EstadoCurso |
|---|---|
| ≥ 3.0 | Aprobado |
| < 3.0 | Reprobado |
| NULL | Pendiente |

### Estructura del cursor

```
DECLARE variables → DECLARE CURSOR → DECLARE CONTINUE HANDLER FOR NOT FOUND → DECLARE EXIT HANDLER
OPEN cur
LOOP
   FETCH cur INTO v_IdMatricula, v_Nota
   ¿no hay más filas? → LEAVE
   IF / ELSEIF → v_Estado
   UPDATE Matricula SET EstadoCurso = v_Estado WHERE IdMatricula = v_IdMatricula
END LOOP
CLOSE cur
```

### Resultado esperado — curso 1 (Teoría de bases de datos)

| IdMatricula | Estudiante | NotaFinal | ANTES | DESPUÉS |
|:-:|---|:-:|---|---|
| 1 | Juan Gamez | 4.50 | Sin evaluar | Aprobado |
| 6 | Joan Romagna | 3.80 | Sin evaluar | Aprobado |
| 9 | Esteban Salvador | 3.50 | Sin evaluar | Aprobado |
| 14 | Andres Viafara | NULL | Sin evaluar | Pendiente |
| 15 | Andres Dueñas | NULL | Sin evaluar | Pendiente |
| 101 | Laura Rojas | 4.80 | Sin evaluar | Aprobado |
| 103 | Carlos Mejia | 2.50 | Sin evaluar | Reprobado |

`@msg` = `EXITO: curso 1 -> 7 matriculas (4 aprobadas, 1 reprobadas, 2 pendientes)`

| Llamada | `@msg` esperado |
|---|---|
| `CALL sp_actualizar_estado_curso(99, @msg);` | `ERROR: el curso 99 no existe` |
| `CALL sp_actualizar_estado_curso(NULL, @msg);` | `ERROR: el curso es obligatorio` |

**Capturas sugeridas:** `SELECT` ANTES del curso 1 · `SELECT @msg` · `SELECT` DESPUÉS del curso 1 · resumen general por curso.

> Si vuelves a ejecutar el script, el ANTES ya no sale en "Sin evaluar". Para repetir la captura: `UPDATE Matricula SET EstadoCurso = 'Sin evaluar' WHERE IdMatricula > 0;` o reinicia con los pasos 1 y 2.

---

## Actividad 5 — Triggers

Scripts:
- [`Actividad-5/Script/05_Actividad5_Triggers.sql`](Actividad-5/Script/05_Actividad5_Triggers.sql): tabla, triggers y pruebas. Termina sin errores.
- [`Actividad-5/Script/Prueba_rechazada.sql`](Actividad-5/Script/Prueba_rechazada.sql): `INSERT` directo con nota 5.5. Falla a propósito: es la captura del error del trigger.

### Qué hace

| Objeto | Momento | Lógica |
|---|---|---|
| `AuditoriaMatricula` | — | Tabla con `IdAuditoria` AUTO_INCREMENT, `IdMatricula`, `Accion ENUM('INSERT','UPDATE','DELETE')`, `Usuario`, `FechaHora`, `Detalle` |
| `trg_validar_nota` | `BEFORE INSERT ON Matricula` | Si `NotaFinal` no es NULL y está fuera de 0.0–5.0 → `SIGNAL SQLSTATE '45000'` y el `INSERT` se cancela |
| `trg_auditoria_matricula` | `AFTER INSERT ON Matricula` | Inserta una fila en `AuditoriaMatricula` con `USER()`, `NOW()` y el detalle de la matrícula |
| `sp_probar_nota` | — | SP auxiliar: inserta con la nota recibida y atrapa el `SIGNAL` con un `EXIT HANDLER`, para que el script no se detenga en los casos inválidos |

> Se usa `USER()` (quien ejecuta el `INSERT`) y no `CURRENT_USER()`, que dentro de un trigger devuelve el **definidor** del trigger.

### Pruebas y resultado esperado

| # | Llamada | Resultado |
|:-:|---|---|
| 1 | `CALL sp_probar_nota(1011765342, 5, 4.9, @msg);` | `ACEPTADA: matricula 105 con nota 4.90` |
| 2 | `CALL sp_probar_nota(1030281186, 5, 0.0, @msg);` | `ACEPTADA: matricula 106 con nota 0.00` (límite) |
| 3 | `CALL sp_probar_nota(1122151498, 5, 5.5, @msg);` | `RECHAZADA (nota 5.50): ERROR: la nota final debe estar entre 0.0 y 5.0` |
| 4 | `CALL sp_probar_nota(1122151498, 5, -1, @msg);` | `RECHAZADA (nota -1.00): ERROR: ...` |
| 5 | `CALL sp_registrar_matricula(1122151498, 3, @msg);` | `EXITO: matricula 107 ...` (el SP de la Act. 1 también dispara la auditoría) |
| 6 | `Prueba_rechazada.sql`: `INSERT` directo con nota 5.5 | `ERROR 1644 (45000): ERROR: la nota final debe estar entre 0.0 y 5.0` |

`AuditoriaMatricula` después del script (solo las inserciones aceptadas):

| IdAuditoria | IdMatricula | Accion | Usuario | Detalle |
|:-:|:-:|---|---|---|
| 1 | 105 | INSERT | root@localhost | Estudiante 1011765342, curso 5, nota 4.90 |
| 2 | 106 | INSERT | root@localhost | Estudiante 1030281186, curso 5, nota 0.00 |
| 3 | 107 | INSERT | root@localhost | Estudiante 1122151498, curso 3, nota pendiente |

> Los números 105–107 suponen que se ejecutaron antes todos los scripts desde una BD limpia. Si vuelves a ejecutar el script, la prueba 5 responde "ya está matriculado" y las matrículas aceptadas toman los siguientes números.

**Capturas sugeridas:** cada `SELECT @msg` (aceptadas y rechazadas) · últimas matrículas · tabla `AuditoriaMatricula` · `SHOW TRIGGERS` · el error 1644 de `Prueba_rechazada.sql`.

> Después del error, `SELECT COUNT(*) FROM AuditoriaMatricula;` da el mismo número que antes del intento: el `BEFORE INSERT` cancela la fila y el `AFTER INSERT` nunca se dispara.

---

# Parte 3 — Referencia

## Compatibilidad MySQL ↔ MariaDB

Todos los scripts corren igual en los dos motores. Estas son las decisiones que lo permiten:

| Punto | MySQL 8 (Windows) | MariaDB (Arch) | Qué hace el script |
|---|---|---|---|
| `ADD COLUMN IF NOT EXISTS` | No existe | Sí | Revisa `information_schema` y ejecuta el `ALTER` con `PREPARE` solo si falta la columna (Act. 2 y 4) |
| `DELIMITER` | Sí | Sí | Siempre `DELIMITER //` … `END //` … `DELIMITER ;` (con espacio antes del `;`) |
| Charset por defecto | utf8mb4 | latin1 en versiones < 11.6 | `CREATE DATABASE ... CHARACTER SET utf8mb4` explícito |
| `GET DIAGNOSTICS` | Sí | Sí (10.0.11+) | Se usa en los `EXIT HANDLER` |
| `SIGNAL SQLSTATE '45000'` | Sí | Sí | Trigger de validación (Act. 5) |
| `SELECT ... INTO ... FOR UPDATE` | Sí | Sí | Bloqueo del cupo (Act. 1) |
| Funciones y binlog (error 1418) | Pide característica | Pide característica | Las funciones se declaran `NO SQL` |
| `INSERT` sin lista de columnas | — | — | Los scripts que corren después de agregar columnas usan lista explícita |
| Cliente | `mysql` | `mariadb` (`mysql` es alias obsoleto) | Mismos parámetros: `-u -p -t -e -v` |
| Respaldo | `mysqldump` | `mariadb-dump` | Mismos parámetros: `--routines --triggers` |
| Guardar credenciales | `mysql_config_editor` | no existe | En Arch: `MYSQL_PWD` en la sesión o `~/.my.cnf` con `chmod 600` |
| Nombres de tablas | sin distinción de mayúsculas | **con distinción** en Linux | Los scripts escriben siempre `Estudiante`, `Matricula`, `Guia_5` igual |

> Si `Guia_5` ya existía antes del cambio de charset, el `IF NOT EXISTS` no lo cambia. Bórrala una vez con `DROP DATABASE Guia_5;` y ejecuta de nuevo los pasos 1 y 2.

---

## Errores comunes y solución

| Error | Causa | Solución |
|---|---|---|
| `1049 Unknown database 'Guia_5'` | No se ejecutó `01_Tablas.sql` | Ejecutar los pasos 1 y 2 |
| `1644 (45000) ... la nota final debe estar entre 0.0 y 5.0` en `Prueba_rechazada.sql` | Es **a propósito**: captura del trigger | Nada; es el resultado esperado |
| `1136 Column count doesn't match` en `02_Datos.sql` | Se ejecutó el paso 2 sin el 1, y la tabla ya tenía columnas extra (Act. 2/4) | Ejecutar siempre el paso 1 antes del 2 |
| `1060 Duplicate column name` | Se ejecutó a mano un `ALTER TABLE` viejo | Usar los scripts actuales (revisan si la columna existe) o reiniciar con los pasos 1 y 2 |
| `1064 ... near 'DELIMITER'` | Se ejecutó el bloque por partes, o desde una herramienta que no entiende `DELIMITER` | En Workbench usar el botón del rayo (todo el script); en terminal usar `< archivo` o `source` |
| `1064` cerca de `DELIMITER;` o `/ /` | Un formateador automático juntó o separó el delimitador | Debe quedar `DELIMITER //` y `DELIMITER ;` (con espacio). Desactivar el formateo automático de `.sql` |
| `1305 PROCEDURE/FUNCTION ... does not exist` | No se creó el objeto o se está en otra BD | `USE Guia_5;` y volver a ejecutar el script |
| `1418 ... DETERMINISTIC, NO SQL, or READS SQL DATA` | Crear funciones con el binlog activo | Las funciones ya declaran `NO SQL`; en último caso `SET GLOBAL log_bin_trust_function_creators = 1;` |
| `1175 safe update mode` | Workbench bloquea UPDATE sin WHERE por PK | *Edit → Preferences → SQL Editor* y desmarcar *Safe Updates*, o agregar `WHERE IdMatricula > 0` |
| `1698 Access denied for user 'root'@'localhost'` (MariaDB) | `root` entra por *unix_socket* | Usar `sudo mariadb` o crear un usuario propio |
| `1045 Access denied` | Usuario o contraseña incorrectos | Revisar las credenciales; en Windows: `mysql_config_editor print --all` |
| `mysql: Deprecated program name` (MariaDB) | MariaDB 11 renombró el cliente | Usar `mariadb` en lugar de `mysql` |
| `1146 Table 'Guia_5.estudiante' doesn't exist` (Linux) | En Linux los nombres distinguen mayúsculas | Escribir los nombres exactamente como en `01_Tablas.sql` |
| `'mysql' no se reconoce como comando` | El `bin` no está en el PATH | Ver [PATH y servicio](#path-y-servicio) |
| `El token '<' no es válido` (PowerShell) | PowerShell no admite `<` | Usar `Get-Content -Raw archivo | mysql ...` o abrir `cmd` |
| Tildes/ñ rotas en terminal | Codificación de la consola | Agregar `--default-character-set=utf8mb4`; en `cmd`: `chcp 65001` |
| Mensaje "ya esta matriculado" en casos válidos | Ya ejecutaste la Actividad 1 antes | Reiniciar con los pasos 1 y 2 |
| El ANTES de la Act. 4 no sale en "Sin evaluar" | Ya ejecutaste la Actividad 4 antes | `UPDATE Matricula SET EstadoCurso = 'Sin evaluar' WHERE IdMatricula > 0;` |

---

## Convenciones del proyecto

| Elemento | Convención | Ejemplo |
|---|---|---|
| Base de datos | `Guia_5` | |
| Scripts | `NN_ActividadN_Tema.sql` | `03_Actividad3_Funciones.sql` |
| Procedimientos | `sp_verbo_objeto` | `sp_registrar_matricula` |
| Funciones | `fn_verbo_objeto` | `fn_calcular_edad` |
| Triggers | `trg_accion_tabla` | `trg_validar_nota` |
| Parámetros | prefijo `p_` | `p_IdEstudiante` |
| Variables locales | prefijo `v_` | `v_NuevoId` |
| Delimitador | `DELIMITER //` … `END //` … `DELIMITER ;` | |
| Capturas | `ActividadN-M.png` en `Imagenes/` | `Actividad1-3.png` |
| Comentarios | muy cortos, una línea, solo en las partes clave (validaciones, cursor, trigger, cálculo, captura) | `-- valida la nota` |
| Encabezado de script | 1 línea: actividad y propósito | `-- Actividad 4: SP con cursor ...` |
| Secciones | `-- N. TITULO` en una sola línea | `-- 1. CREACION DEL SP` |

---

## Informe final

Archivo: **`Informe/Practica5_NombreEquipo.pdf`**, entregado en Moodle dentro del plazo.

1. Portada (institución, asignatura, guía No. 5, integrantes, fecha).
2. Introducción.
3. Descripción del caso de estudio (sistema académico `Guia_5`).
4. Desarrollo: capturas de cada actividad **con su explicación** (no solo la imagen).
5. Resultados de la Actividad de Aula Invertida (tarea previa firmada y con fecha anterior a la sesión + reflexión en clase).
6. Conclusiones y análisis crítico.
7. Código SQL completo y comentado (los scripts de este repositorio).
8. Referencias en APA 7.ª ed.

---

## Referencias

- Beaulieu, A. (2020). *Learning SQL* (3rd ed.). O'Reilly Media.
- Elmasri, R., & Navathe, S. B. (2016). *Fundamentals of database systems* (7th ed.). Pearson.
- MariaDB Foundation. (2024). *MariaDB documentation: Stored routines*. https://mariadb.com/kb/en/stored-routines/
- Oracle Corporation. (2024). *MySQL 8.0 reference manual: Stored objects*. https://dev.mysql.com/doc/refman/8.0/en/stored-objects.html
- Oracle Corporation. (2024). *MySQL 8.0 reference manual: mysql_config_editor*. https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html
- Silberschatz, A., Korth, H. F., & Sudarshan, S. (2019). *Database system concepts* (7th ed.). McGraw-Hill.
- Tahaghoghi, S., & Williams, H. E. (2007). *Learning MySQL*. O'Reilly Media.
