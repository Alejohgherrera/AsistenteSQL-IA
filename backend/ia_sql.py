from ollama import chat
from conexion import obtener_tipo_base
from esquema import obtener_esquema, obtener_relaciones


def construir_contexto():

    esquema = obtener_esquema()
    relaciones = obtener_relaciones()

    contexto = ""

    for tabla, columnas in esquema.items():

        contexto += f"\nTabla: {tabla}\n"

        for columna in columnas:
            contexto += f"- {columna}\n"

    if relaciones:
        contexto += "\nRelaciones:\n"

        for relacion in relaciones:
            contexto += f"- {relacion}\n"

    return contexto


def generar_sql(pregunta):

    contexto = construir_contexto()
    motor = obtener_motor_sql()

    prompt = f"""
Eres un experto en {motor}.

Base de datos:

{contexto}

Reglas:
- Genera unicamente SQL.
- No expliques nada.
- No uses markdown.
- Usa sintaxis {motor}.
- Usa solamente las tablas y columnas listadas en el esquema.
- Cuando necesites columnas de varias tablas, usa JOIN con las relaciones indicadas.
- Califica las columnas con alias de tabla, por ejemplo p.precio o c.nombre.
- No inventes columnas.
- {regla_limite()}
- Si usas funciones de agregacion como SUM, COUNT o AVG, todas las columnas no agregadas deben estar en GROUP BY.
- No selecciones columnas que no esten en el GROUP BY cuando hay agregaciones.

Pregunta:
{pregunta}
"""

    respuesta = chat(
        model="llama3.2",
        options={
            "temperature": 0
        },
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ]
    )

    return limpiar_sql(respuesta.message.content)


def corregir_sql(pregunta, sql, error):
    contexto = construir_contexto()
    motor = obtener_motor_sql()

    prompt = f"""
Corrige esta consulta {motor}.

Base de datos:
{contexto}

Pregunta original:
{pregunta}

SQL con error:
{sql}

Error de SQL Server:
{error}

Reglas:
- Devuelve unicamente SQL corregido.
- No expliques nada.
- No uses markdown.
- Usa solamente tablas y columnas del esquema.
- Usa JOIN cuando combines tablas.
- {regla_limite()}
- Si usas agregaciones, respeta GROUP BY.
"""

    respuesta = chat(
        model="llama3.2",
        options={
            "temperature": 0
        },
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ]
    )

    return limpiar_sql(respuesta.message.content)


def limpiar_sql(sql):
    sql = sql.strip()
    sql = sql.replace("```sql", "").replace("```", "").strip()
    return sql


def obtener_motor_sql():
    if obtener_tipo_base() == "sqlite":
        return "SQLite"

    return "SQL Server"


def regla_limite():
    if obtener_tipo_base() == "sqlite":
        return "Para limitar resultados usa LIMIT N, no SELECT TOP."

    return "Para limitar resultados usa SELECT TOP N, no LIMIT. No uses TOP 100% ni TOP PERCENT."
