from conexion import obtener_conexion, obtener_tipo_base

def obtener_esquema():

    conexion = obtener_conexion()
    cursor = conexion.cursor()

    if obtener_tipo_base() == "sqlite":
        esquema = obtener_esquema_sqlite(cursor)
    else:
        esquema = obtener_esquema_sqlserver(cursor)

    conexion.close()

    return esquema


def obtener_esquema_sqlserver(cursor):
    cursor.execute(
        """
        SELECT
            TABLE_NAME,
            COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        ORDER BY TABLE_NAME, ORDINAL_POSITION
        """
    )

    filas = cursor.fetchall()

    esquema = {}

    for tabla, columna in filas:
        esquema.setdefault(tabla, []).append(columna)

    return esquema


def obtener_esquema_sqlite(cursor):
    cursor.execute(
        """
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
          AND name NOT LIKE 'sqlite_%'
        ORDER BY name
        """
    )

    tablas = [fila[0] for fila in cursor.fetchall()]

    esquema = {}

    for tabla in tablas:
        cursor.execute(f'PRAGMA table_info("{tabla}")')
        esquema[tabla] = [fila[1] for fila in cursor.fetchall()]

    return esquema


def obtener_relaciones():
    conexion = obtener_conexion()
    cursor = conexion.cursor()

    if obtener_tipo_base() == "sqlite":
        relaciones = obtener_relaciones_sqlite(cursor)
    else:
        relaciones = obtener_relaciones_sqlserver(cursor)

    conexion.close()

    return relaciones


def obtener_relaciones_sqlserver(cursor):
    cursor.execute(
        """
        SELECT
            tp.name AS tabla_origen,
            cp.name AS columna_origen,
            tr.name AS tabla_destino,
            cr.name AS columna_destino
        FROM sys.foreign_keys fk
        INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
        INNER JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
        INNER JOIN sys.columns cp
            ON fkc.parent_object_id = cp.object_id
           AND fkc.parent_column_id = cp.column_id
        INNER JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
        INNER JOIN sys.columns cr
            ON fkc.referenced_object_id = cr.object_id
           AND fkc.referenced_column_id = cr.column_id
        ORDER BY tp.name, cp.name
        """
    )

    return [
        f"{tabla_origen}.{columna_origen} = {tabla_destino}.{columna_destino}"
        for tabla_origen, columna_origen, tabla_destino, columna_destino in cursor.fetchall()
    ]


def obtener_relaciones_sqlite(cursor):
    relaciones = []

    cursor.execute(
        """
        SELECT name
        FROM sqlite_master
        WHERE type = 'table'
          AND name NOT LIKE 'sqlite_%'
        ORDER BY name
        """
    )
    tablas = [fila[0] for fila in cursor.fetchall()]

    for tabla in tablas:
        cursor.execute(f'PRAGMA foreign_key_list("{tabla}")')

        for fila in cursor.fetchall():
            tabla_destino = fila[2]
            columna_origen = fila[3]
            columna_destino = fila[4]
            relaciones.append(
                f"{tabla}.{columna_origen} = {tabla_destino}.{columna_destino}"
            )

    return relaciones
