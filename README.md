<div align="center">

# Práctica 5 — Programación en el SGBD
### Procedimientos Almacenados · Funciones · Cursores · Triggers

*UMB — Teoría de Bases de Datos · Guía No. 5 · Semanas 11–13 · MySQL 8.x*

</div>

---

## Índice

- [Sobre esta guía](#sobre-esta-guía)
- [Estado actual](#estado-actual)
- [Estructura de carpetas](#estructura-de-carpetas)
- [Sistema base — Guia_5](#sistema-base--guia_5)
- [Requisitos e instalación](#requisitos-e-instalación)
- [Orden de ejecución](#orden-de-ejecución)
- [Cómo ejecutar los scripts](#cómo-ejecutar-los-scripts)
  - [Opción A — MySQL Workbench](#opción-a--mysql-workbench)
  - [Opción B — Terminal Windows](#opción-b--terminal-windows)
  - [Opción C — Terminal Arch Linux](#opción-c--terminal-arch-linux)
- [Tarea previa — Parámetros IN/OUT/INOUT y SP básico](#tarea-previa--parámetros-ininoutinout-y-sp-básico)
- [Actividad 1 — SP de matrícula](#actividad-1--sp-de-matrícula)
- [Actividad 2 — SP de promedio y clasificación](#actividad-2--sp-de-promedio-y-clasificación)
- [Actividad 3 — Funciones (UDF)](#actividad-3--funciones-udf)
- [Actividad 4 — SP con cursor](#actividad-4--sp-con-cursor)
- [Actividad 5 — Triggers](#actividad-5--triggers)
- [Consultas útiles desde la terminal](#consultas-útiles-desde-la-terminal)
- [Errores comunes y solución](#errores-comunes-y-solución)
- [Convenciones del proyecto](#convenciones-del-proyecto)
- [Informe final](#informe-final)
- [Referencias](#referencias)

---

## Sobre esta guía

En esta práctica el estudiante es el **desarrollador de base de datos**: lleva la lógica de negocio al SGBD con procedimientos almacenados (SP), funciones definidas por el usuario (UDF), cursores y triggers. Se trabaja sobre el sistema académico de las prácticas 1–4, que en esta guía se llama `Guia_5`.

| | |
|---|---|
| **Resultado de aprendizaje** | Implementar SP y UDF en MySQL para automatizar lógica de negocio dentro del SGBD |
| **Actividades** | 1. SP de matrícula · 2. SP de promedio · 3. UDF · 4. SP con cursor · 5. Triggers |
| **SGBD** | MySQL 8.x o MariaDB 10.5+ (los mismos scripts sirven en ambos) |
| **Entregable final** | `Practica5_NombreEquipo.pdf` (vía Moodle UMB) |

### Preguntas orientadoras (respuesta corta)

| Pregunta | Respuesta |
|---|---|
| ¿SP vs. función? | Un SP se invoca con `CALL`, puede tener parámetros `OUT` y modificar datos. Una función devuelve **un** valor escalar y se usa dentro de un `SELECT`. |
| ¿Por qué centralizar la lógica en el SGBD? | Menos viajes cliente-servidor, la regla de negocio queda en un único sitio y el usuario puede ejecutar el SP sin tener permisos directos sobre las tablas. |
| ¿Cómo se usa un parámetro `OUT`? | Se pasa una variable de sesión: `CALL sp(..., @msg); SELECT @msg;` |
| ¿Cuándo conviene un cursor? | Cuando cada fila necesita una lógica propia que no se puede expresar en un solo `UPDATE`/`INSERT ... SELECT`. |

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
| Tarea previa — IN/OUT/INOUT + SP básico | [`00_TareaPrevia_SP.sql`](Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql) | 11 (`Actividad-tarea-previa/Imagenes/`) | Completo |
| Actividad 1 — SP de matrícula | [`01_Actividad1_SP_Matricula.sql`](Actividad-1/Script/01_Actividad1_SP_Matricula.sql) | 10 (`Actividad-1/Imagenes/`) | Completo |
| Actividad 2 — SP de promedio | [`02_Actividad2_SP_Promedio.sql`](Actividad-2/Script/02_Actividad2_SP_Promedio.sql) | 14 (`Actividad-2/Imagenes/`) | Completo |
| Actividad 3 — Funciones UDF | `Actividad-3/Script/03_Actividad3_Funciones.sql` | `Actividad-3/Imagenes/` | Pendiente |
| Actividad 4 — SP con cursor | `Actividad-4/Script/04_Actividad4_SP_Cursor.sql` | `Actividad-4/Imagenes/` | Pendiente |
| Actividad 5 — Triggers | `Actividad-5/Script/05_Actividad5_Triggers.sql` | `Actividad-5/Imagenes/` | Pendiente |
| Informe final | `Informe/Practica5_NombreEquipo.pdf` | — | Pendiente |

---

## Estructura de carpetas

```
Guia 5DB/
├── README.md                              ← este archivo
├── Tablas y datos/
│   ├── 01_Tablas.sql                      ← crea la BD Guia_5 y sus 6 tablas
│   └── 02_Datos.sql                       ← carga los datos base (5 por tabla, 13 matrículas)
├── Actividad-tarea-previa/
│   ├── Script/
│   │   └── 00_TareaPrevia_SP.sql          ← IN/OUT/INOUT + respuesta cursores + SP básico
│   └── Imagenes/                          ← TareaPrevia-1.png ... TareaPrevia-11.png
├── Actividad-1/
│   ├── Script/
│   │   └── 01_Actividad1_SP_Matricula.sql ← sp_registrar_matricula (OUT p_Mensaje)
│   └── Imagenes/                          ← Actividad1-1.png ... Actividad1-10.png
├── Actividad-2/
│   ├── Script/
│   │   └── 02_Actividad2_SP_Promedio.sql  ← sp_calcular_promedio + columnas de estado
│   └── Imagenes/
├── Actividad-3/                           ← (pendiente) funciones UDF
│   ├── Script/
│   └── Imagenes/
├── Actividad-4/                           ← (pendiente) SP con cursor
│   ├── Script/
│   └── Imagenes/
├── Actividad-5/                           ← (pendiente) triggers
│   ├── Script/
│   └── Imagenes/
└── Informe/                               ← PDF final para Moodle
```

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
```

| Tabla | Filas base | Notas |
|---|:-:|---|
| Programa | 5 | |
| Estudiante | 5 (+3 de prueba en Act. 2) | Act. 2 agrega `Promedio` y `EstadoAcademico` |
| Profesor | 5 | |
| Materia | 5 | `CreditosMateria` define el valor de la matrícula |
| Grupo | 5 | `Cupo` NULL = cupo ilimitado |
| Matricula | 13 | `IdMatricula` **no** es AUTO_INCREMENT: los SP calculan `MAX + 1` |

> **"Curso" = `Grupo`.** La guía habla de *IdCurso*, pero en este modelo el curso que se matricula es un **grupo** (materia + profesor + periodo). Por eso los SP reciben `IdGrupo`.

### Objetos programados (hasta ahora)

| Objeto | Tipo | Script |
|---|---|---|
| `sp_ejemplo_in` | SP | Tarea previa |
| `sp_ejemplo_out` | SP | Tarea previa |
| `sp_ejemplo_inout` | SP | Tarea previa |
| `sp_registrar_matricula_basico` | SP | Tarea previa |
| `sp_registrar_matricula` | SP | Actividad 1 |
| `sp_calcular_promedio` | SP | Actividad 2 |
| `fn_calcular_edad` | FUNCTION | Actividad 3 *(pendiente)* |
| `fn_formatear_nombre` | FUNCTION | Actividad 3 *(pendiente)* |
| `sp_actualizar_estado_curso` | SP + CURSOR | Actividad 4 *(pendiente)* |
| `trg_validar_nota` / `trg_auditoria_matricula` | TRIGGER | Actividad 5 *(pendiente)* |

---

## Requisitos e instalación

### Windows

1. Instala **MySQL Server 8.x** y **MySQL Workbench** con el *MySQL Installer*.
2. Para usar `mysql` desde cualquier terminal, agrega el `bin` al PATH (PowerShell):
   ```powershell
   # solo para la sesion actual
   $env:Path += ";C:\Program Files\MySQL\MySQL Server 8.4\bin"

   # permanente para tu usuario
   $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
   [Environment]::SetEnvironmentVariable("Path", "$userPath;C:\Program Files\MySQL\MySQL Server 8.4\bin", "User")

   # comprobar
   mysql --version
   ```
3. Iniciar o detener el servicio (PowerShell **como administrador**):
   ```powershell
   Get-Service MySQL*          # ver nombre y estado del servicio (normalmente MySQL84)
   Start-Service MySQL84
   Stop-Service  MySQL84
   ```
   Equivalente en `cmd`: `net start MySQL84` / `net stop MySQL84`.

### Arch Linux

Los repositorios oficiales de Arch traen **MariaDB**, que es compatible con estos scripts. MySQL 8 está en el AUR.

```bash
# Opcion 1: MariaDB (repositorio oficial)
sudo pacman -S mariadb
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
sudo systemctl enable --now mariadb
sudo mariadb-secure-installation

# Opcion 2: MySQL 8 desde el AUR (compila, tarda bastante)
yay -S mysql
sudo systemctl enable --now mysqld

# estado del servicio
systemctl status mariadb      # o mysqld
mysql --version
```

**Usuario root en MariaDB.** En Arch, `root` entra por *unix_socket*: `mysql -u root -p` falla, pero `sudo mariadb` funciona. Lo más cómodo es crear un usuario propio una sola vez:

```bash
sudo mariadb
```
```sql
CREATE USER 'joan'@'localhost' IDENTIFIED BY 'tu_clave';
GRANT ALL PRIVILEGES ON Guia_5.* TO 'joan'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Desde ahí usa `-u joan -p` en lugar de `-u root -p` en todos los comandos de este README.

> La guía pide **MySQL 8.x**. MariaDB sirve para trabajar en Arch, pero toma las capturas del informe en MySQL 8.

### Compatibilidad MySQL ↔ MariaDB

Todos los scripts corren igual en los dos motores. Estas son las decisiones que lo permiten:

| Punto | MySQL 8 | MariaDB | Qué hace el script |
|---|---|---|---|
| `ADD COLUMN IF NOT EXISTS` | No existe | Sí | Revisa `information_schema` y ejecuta el `ALTER` con `PREPARE` solo si falta la columna (Actividad 2) |
| Charset por defecto | utf8mb4 | latin1 en versiones < 11.6 | `CREATE DATABASE ... CHARACTER SET utf8mb4` explícito |
| `GET DIAGNOSTICS` | Sí | Sí (10.0.11+) | Se usa en los `EXIT HANDLER` |
| `SELECT ... INTO ... FOR UPDATE` | Sí | Sí | Bloqueo del cupo (Actividad 1) |
| Cliente | `mysql` | `mariadb` (`mysql` es alias obsoleto) | Mismos parámetros: `-u -p -t -e` |
| Guardar credenciales | `mysql_config_editor` | no existe | En Arch se usa `MYSQL_PWD` solo durante la sesión |
| Nombres de tablas | sin distinción de mayúsculas en Windows | **con distinción** en Linux | Los scripts escriben siempre `Estudiante`, `Matricula`, `Guia_5` igual |

> Si `Guia_5` ya existía antes de este cambio, el `IF NOT EXISTS` no le cambia el charset. Bórrala una vez con `DROP DATABASE Guia_5;` y ejecuta de nuevo los pasos 1 y 2.

---

## Orden de ejecución

Ejecuta los scripts **en este orden**. Cada uno depende del anterior.

| # | Script | Qué hace | Se puede repetir |
|:-:|---|---|:-:|
| 1 | `Tablas y datos/01_Tablas.sql` | Crea `Guia_5` y borra/crea las 6 tablas | Sí |
| 2 | `Tablas y datos/02_Datos.sql` | Vacía las tablas y carga los datos base | Sí |
| 3 | `Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql` | SP de ejemplo + SP básico (inserta matrícula 14) | Con cuidado: el caso válido pasa a ser duplicado |
| 4 | `Actividad-1/Script/01_Actividad1_SP_Matricula.sql` | `sp_registrar_matricula` + 7 pruebas (inserta 15 y 16) | Con cuidado: los casos válidos pasan a "ya está matriculado" |
| 5 | `Actividad-2/Script/02_Actividad2_SP_Promedio.sql` | Columnas de estado + `sp_calcular_promedio` + 9 pruebas | Sí (si las columnas ya existen, solo muestra un aviso) |
| 6 | `Actividad-3/...` | *(pendiente)* | |
| 7 | `Actividad-4/...` | *(pendiente)* | |
| 8 | `Actividad-5/...` | *(pendiente)* | |

**Para empezar desde cero** (por ejemplo, antes de tomar las capturas finales), vuelve a ejecutar los pasos **1 y 2**. Así la BD queda limpia y los pasos 3–5 producen exactamente los resultados que se documentan abajo.

---

## Cómo ejecutar los scripts

### Opción A — MySQL Workbench

1. Abre la conexión `root@localhost`.
2. `File → Open SQL Script...` y elige el script.
3. Ejecuta **todo el script** con el botón del rayo (`Ctrl + Shift + Enter`). No uses "ejecutar línea actual" (`Ctrl + Enter`) sobre un bloque `DELIMITER`: se rompe.
4. Cada `SELECT` abre una pestaña *Result*. Esas pestañas son las capturas.
5. Para refrescar los SP en el panel izquierdo: clic derecho en `Guia_5` → *Refresh All*.

### Opción B — Terminal Windows

Abre la terminal **en la carpeta `Guia 5DB`**.

**PowerShell** (no admite `<`, así que se usa una tubería):

```powershell
# 1 y 2: estructura y datos
Get-Content -Raw ".\Tablas y datos\01_Tablas.sql" | mysql -u root -p --default-character-set=utf8mb4
Get-Content -Raw ".\Tablas y datos\02_Datos.sql"  | mysql -u root -p --default-character-set=utf8mb4

# 3: tarea previa
Get-Content -Raw ".\Actividad-tarea-previa\Script\00_TareaPrevia_SP.sql" | mysql -u root -p -t --default-character-set=utf8mb4

# 4: actividad 1
Get-Content -Raw ".\Actividad-1\Script\01_Actividad1_SP_Matricula.sql" | mysql -u root -p -t --default-character-set=utf8mb4

# 5: actividad 2
Get-Content -Raw ".\Actividad-2\Script\02_Actividad2_SP_Promedio.sql" | mysql -u root -p -t --default-character-set=utf8mb4
```

> `-t` imprime los resultados como tabla (con bordes), igual que el cliente interactivo. Sirve para las capturas de terminal.

**Todo de una vez** sin escribir la contraseña en cada script. `mysql_config_editor` guarda la contraseña cifrada en tu perfil de usuario, nunca en texto plano dentro del código (recomendación 11 de la guía):

```powershell
# una sola vez: guarda la credencial cifrada
mysql_config_editor set --login-path=local --host=localhost --user=root --password

# ejecuta todos los scripts en orden
$scripts = @(
  ".\Tablas y datos\01_Tablas.sql",
  ".\Tablas y datos\02_Datos.sql",
  ".\Actividad-tarea-previa\Script\00_TareaPrevia_SP.sql",
  ".\Actividad-1\Script\01_Actividad1_SP_Matricula.sql",
  ".\Actividad-2\Script\02_Actividad2_SP_Promedio.sql"
)
foreach ($s in $scripts) {
  Write-Host "`n>>> $s" -ForegroundColor Cyan
  Get-Content -Raw $s | mysql --login-path=local -t --default-character-set=utf8mb4
}
```

**cmd** (sí admite `<`):

```bat
mysql -u root -p --default-character-set=utf8mb4 < "Tablas y datos\01_Tablas.sql"
mysql -u root -p --default-character-set=utf8mb4 < "Tablas y datos\02_Datos.sql"
mysql -u root -p -t < "Actividad-tarea-previa\Script\00_TareaPrevia_SP.sql"
mysql -u root -p -t < "Actividad-1\Script\01_Actividad1_SP_Matricula.sql"
mysql -u root -p -t < "Actividad-2\Script\02_Actividad2_SP_Promedio.sql"
```

**Desde el cliente interactivo** (funciona igual en Windows y en Linux):

```sql
-- entrar: mysql -u root -p
source Tablas y datos/01_Tablas.sql
source Tablas y datos/02_Datos.sql
source Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql
source Actividad-1/Script/01_Actividad1_SP_Matricula.sql
source Actividad-2/Script/02_Actividad2_SP_Promedio.sql
```

> `source` toma la ruta relativa a la carpeta desde donde abriste `mysql`. Abre la terminal en `Guia 5DB`.

### Opción C — Terminal Arch Linux

Abre la terminal **en la carpeta del proyecto** (`cd "Guia 5DB"`). Con MariaDB el cliente es `mariadb`. Si instalaste MySQL desde el AUR, cambia `mariadb` por `mysql` en todos los comandos. Los parámetros son los mismos.

```bash
# 1 y 2: estructura y datos
mariadb -u joan -p --default-character-set=utf8mb4 < "Tablas y datos/01_Tablas.sql"
mariadb -u joan -p --default-character-set=utf8mb4 < "Tablas y datos/02_Datos.sql"

# 3, 4 y 5: tarea previa y actividades
mariadb -u joan -p -t < "Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql"
mariadb -u joan -p -t < "Actividad-1/Script/01_Actividad1_SP_Matricula.sql"
mariadb -u joan -p -t < "Actividad-2/Script/02_Actividad2_SP_Promedio.sql"

# sin crear usuario propio: entrar como root por socket
sudo mariadb --default-character-set=utf8mb4 < "Tablas y datos/01_Tablas.sql"
```

**Todo de una vez** (pide la contraseña una sola vez):

```bash
read -rsp "Password MySQL: " MYSQL_PWD && echo && export MYSQL_PWD
for s in "Tablas y datos/01_Tablas.sql" \
         "Tablas y datos/02_Datos.sql" \
         "Actividad-tarea-previa/Script/00_TareaPrevia_SP.sql" \
         "Actividad-1/Script/01_Actividad1_SP_Matricula.sql" \
         "Actividad-2/Script/02_Actividad2_SP_Promedio.sql"; do
  printf '\n\e[36m>>> %s\e[0m\n' "$s"
  mariadb -u joan -t --default-character-set=utf8mb4 < "$s" || break
done
unset MYSQL_PWD
```

> La contraseña vive solo en la variable de la sesión y se borra con `unset` al terminar. Nunca la escribas dentro de un `.sql`.

**Guardar la salida en un archivo** (útil para el informe):

```bash
mariadb -u joan -p -t < "Actividad-1/Script/01_Actividad1_SP_Matricula.sql" | tee actividad1_salida.txt
```

```powershell
Get-Content -Raw ".\Actividad-1\Script\01_Actividad1_SP_Matricula.sql" | mysql -u root -p -t | Tee-Object actividad1_salida.txt
```

---

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

1. **Preparación:** agrega a `Estudiante` las columnas `Promedio DECIMAL(3,2)` y `EstadoAcademico VARCHAR(20) DEFAULT 'Sin calificar'`.
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

> **Pendiente.** Crear `Actividad-3/Script/03_Actividad3_Funciones.sql`.

Requisitos de la guía:
- `fn_calcular_edad(fecha DATE) RETURNS INT`: edad a partir de `FechaNacimiento` (pista: `TIMESTAMPDIFF(YEAR, fecha, CURDATE())`).
- `fn_formatear_nombre(...) RETURNS VARCHAR`: `"APELLIDO, NOMBRE"` en mayúsculas (pista: `UPPER(CONCAT_WS(...))`).
- Usar ambas dentro de un `SELECT`.

Plantilla:

```sql
-- Practica 5 - Actividad 3: Funciones definidas por el usuario
-- Sistema: Guia_5

USE Guia_5;

-- 1. FUNCION EDAD
DROP FUNCTION IF EXISTS fn_calcular_edad;
DELIMITER //
CREATE FUNCTION fn_calcular_edad(p_Fecha DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    -- ...
END //
DELIMITER ;

-- 2. FUNCION NOMBRE
-- ...

-- 3. USO EN SELECT (captura)
-- SELECT fn_formatear_nombre(...) AS Nombre, fn_calcular_edad(FechaNacimiento) AS Edad FROM Estudiante;
```

> Si sale el error **1418** al crear la función, decláralas `DETERMINISTIC` o `READS SQL DATA` (ver [errores comunes](#errores-comunes-y-solución)).

---

## Actividad 4 — SP con cursor

> **Pendiente.** Crear `Actividad-4/Script/04_Actividad4_SP_Cursor.sql`.

Requisitos de la guía:
- SP que recorra con un **cursor** todos los estudiantes de un curso (`IdGrupo`) y actualice su estado según la nota final.
- Capturas **ANTES/DESPUÉS** de la ejecución.

Idea: agregar a `Matricula` una columna `EstadoCurso` (Aprobado/Reprobado/Pendiente) y recorrerla con:

```sql
DECLARE v_Fin BOOLEAN DEFAULT FALSE;
DECLARE cur CURSOR FOR SELECT IdMatricula, NotaFinal FROM Matricula WHERE IdGrupo = p_IdGrupo;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Fin = TRUE;
OPEN cur;
bucle: LOOP
    FETCH cur INTO v_Id, v_Nota;
    IF v_Fin THEN LEAVE bucle; END IF;
    -- UPDATE segun v_Nota
END LOOP;
CLOSE cur;
```

---

## Actividad 5 — Triggers

> **Pendiente.** Crear `Actividad-5/Script/05_Actividad5_Triggers.sql`.

Requisitos de la guía:
- `BEFORE INSERT` en `Matricula`: rechazar notas fuera de `0–5.0` con `SIGNAL SQLSTATE '45000'`.
- `AFTER INSERT` en `Matricula`: registrar la matrícula en una tabla de auditoría (se puede reutilizar la idea de `auditoria_log` de la Práctica 4, agregando `'INSERT'` al ENUM).
- Capturas de las validaciones en acción (un insert válido, uno rechazado y la tabla de auditoría).

> Al crear el trigger de validación, `sp_registrar_matricula` (Actividad 1) también queda protegido. Si el trigger rechaza una fila, el `EXIT HANDLER` del SP devuelve el mensaje en `p_Mensaje`.

---

## Consultas útiles desde la terminal

Entrar al cliente y usar la base:

```bash
mysql -u root -p Guia_5            # Linux / cmd / PowerShell, entra directo a Guia_5
mysql --login-path=local Guia_5    # Windows, con mysql_config_editor configurado
```

Ejecutar una sola consulta sin entrar al cliente (`-e`):

```bash
mysql -u root -p -t Guia_5 -e "SELECT IdEstudiante, PrimerNombre, Promedio, EstadoAcademico FROM Estudiante;"
mysql -u root -p -t Guia_5 -e "CALL sp_registrar_matricula(1122151498, 2, @m); SELECT @m;"
mysql -u root -p -t Guia_5 -e "CALL sp_calcular_promedio(1031422990, @p, @c); SELECT @p, @c;"
```

### Inspeccionar los objetos programados

```sql
-- listar SP y funciones de Guia_5
SHOW PROCEDURE STATUS WHERE Db = 'Guia_5';
SHOW FUNCTION  STATUS WHERE Db = 'Guia_5';

-- lo mismo desde information_schema
SELECT ROUTINE_NAME, ROUTINE_TYPE, CREATED
FROM information_schema.ROUTINES
WHERE ROUTINE_SCHEMA = 'Guia_5'
ORDER BY ROUTINE_TYPE, ROUTINE_NAME;

-- ver el codigo de un SP
SHOW CREATE PROCEDURE sp_registrar_matricula\G
SHOW CREATE PROCEDURE sp_calcular_promedio\G

-- ver los parametros de un SP
SELECT PARAMETER_MODE, PARAMETER_NAME, DTD_IDENTIFIER
FROM information_schema.PARAMETERS
WHERE SPECIFIC_SCHEMA = 'Guia_5' AND SPECIFIC_NAME = 'sp_registrar_matricula'
ORDER BY ORDINAL_POSITION;

-- triggers (Actividad 5)
SHOW TRIGGERS FROM Guia_5;

-- estructura de las tablas modificadas
DESCRIBE Estudiante;
DESCRIBE Matricula;
```

### Consultas de verificación

```sql
-- matriculas con nombre de estudiante y curso
SELECT m.IdMatricula, CONCAT(e.PrimerNombre,' ',e.PrimerApellido) AS Estudiante,
       ma.NombreMateria, m.NotaFinal, m.ValorMatricula
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

-- resumen por clasificacion (despues de la Actividad 2)
SELECT EstadoAcademico, COUNT(*) AS Estudiantes
FROM Estudiante
GROUP BY EstadoAcademico;
```

### Borrar objetos (para rehacer una actividad)

```sql
DROP PROCEDURE IF EXISTS sp_registrar_matricula;
DROP PROCEDURE IF EXISTS sp_calcular_promedio;
DROP FUNCTION  IF EXISTS fn_calcular_edad;
DROP TRIGGER   IF EXISTS trg_validar_nota;

-- quitar las columnas de la Actividad 2
ALTER TABLE Estudiante DROP COLUMN Promedio, DROP COLUMN EstadoAcademico;
```

---

## Errores comunes y solución

| Error | Causa | Solución |
|---|---|---|
| `1049 Unknown database 'Guia_5'` | No se ejecutó `01_Tablas.sql` | Ejecutar los pasos 1 y 2 |
| `1060 Duplicate column name 'Promedio'` | Se ejecutó a mano un `ALTER TABLE` viejo (el script actual ya revisa si la columna existe) | Usar el script actual, o reiniciar con los pasos 1 y 2 |
| `1698 Access denied for user 'root'@'localhost'` (MariaDB) | `root` entra por *unix_socket* | Usar `sudo mariadb` o crear un usuario propio (ver [Arch Linux](#arch-linux)) |
| `mysql: Deprecated program name` (MariaDB) | MariaDB 11 renombró el cliente | Usar `mariadb` en lugar de `mysql` |
| `1146 Table 'Guia_5.estudiante' doesn't exist` (Linux) | En Linux los nombres distinguen mayúsculas | Escribir los nombres exactamente como en `01_Tablas.sql` |
| `1064 ... near 'DELIMITER'` | Se ejecutó el bloque por partes, o desde una herramienta que no entiende `DELIMITER` | En Workbench usar el botón del rayo (todo el script); en terminal usar `mysql < archivo` o `source` |
| `1305 PROCEDURE ... does not exist` | No se creó el SP o se está en otra BD | `USE Guia_5;` y volver a ejecutar el script |
| `1418 ... DETERMINISTIC, NO SQL, or READS SQL DATA` | Crear funciones con el binlog activo | Declarar la función `DETERMINISTIC`/`READS SQL DATA`, o `SET GLOBAL log_bin_trust_function_creators = 1;` |
| `1175 safe update mode` | Workbench bloquea UPDATE sin WHERE por PK | Los scripts ya filtran por PK; si pasa: *Edit → Preferences → SQL Editor* y desmarcar *Safe Updates* |
| `1045 Access denied` | Usuario o contraseña incorrectos | Revisar las credenciales; en Windows: `mysql_config_editor print --all` |
| `'mysql' no se reconoce como comando` | El `bin` no está en el PATH | Ver [Requisitos → Windows](#windows) |
| Tildes/ñ rotas en terminal | Codificación de la consola | Agregar `--default-character-set=utf8mb4`; en `cmd`: `chcp 65001` |
| Mensaje "ya esta matriculado" en casos válidos | Ya ejecutaste la Actividad 1 antes | Reiniciar con los pasos 1 y 2 |

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
| Capturas | `ActividadN-M.png` en `Imagenes/` | `Actividad1-3.png` |
| Comentarios | cortos, en una línea, encima de lo que explican | `-- esta parte crea la matricula` |
| Encabezado de script | 2–3 líneas: práctica/actividad, sistema, propósito | ver cualquier script |
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
- Oracle Corporation. (2024). *MySQL 8.0 reference manual: Stored objects*. https://dev.mysql.com/doc/refman/8.0/en/stored-objects.html
- Oracle Corporation. (2024). *MySQL 8.0 reference manual: mysql_config_editor*. https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html
- Silberschatz, A., Korth, H. F., & Sudarshan, S. (2019). *Database system concepts* (7th ed.). McGraw-Hill.
- Tahaghoghi, S., & Williams, H. E. (2007). *Learning MySQL*. O'Reilly Media.
