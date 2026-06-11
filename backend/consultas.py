from conexion import obtener_conexion

def obtener_productos():
    conexion = obtener_conexion()

    cursor = conexion.cursor()

    cursor.execute("""
        SELECT TOP 5 *
        FROM Productos
    """)

    resultados = cursor.fetchall()

    conexion.close()

    return resultados