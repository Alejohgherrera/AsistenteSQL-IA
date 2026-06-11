from conexion import obtener_conexion

def obtener_esquema():

    conexion = obtener_conexion()
    cursor = conexion.cursor()

    consulta = """
    SELECT
        TABLE_NAME,
        COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    ORDER BY TABLE_NAME, ORDINAL_POSITION
    """

    cursor.execute(consulta)

    filas = cursor.fetchall()

    esquema = {}

    for tabla, columna in filas:

        if tabla not in esquema:
            esquema[tabla] = []

        esquema[tabla].append(columna)

    conexion.close()

    return esquema