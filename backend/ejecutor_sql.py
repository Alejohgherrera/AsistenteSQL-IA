from conexion import obtener_conexion

def ejecutar_sql(sql):

    sql_limpio = sql.strip().upper()

    if not sql_limpio.startswith("SELECT"):
        raise Exception(
            "Solo se permiten consultas SELECT"
        )

    conexion = obtener_conexion()

    cursor = conexion.cursor()

    cursor.execute(sql)

    filas = cursor.fetchall()

    conexion.close()

    return filas