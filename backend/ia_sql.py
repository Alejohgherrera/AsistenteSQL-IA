from ollama import chat
from esquema import obtener_esquema


def construir_contexto():

    esquema = obtener_esquema()

    contexto = ""

    for tabla, columnas in esquema.items():

        contexto += f"\nTabla: {tabla}\n"

        for columna in columnas:
            contexto += f"- {columna}\n"

    return contexto


def generar_sql(pregunta):

    contexto = construir_contexto()

    prompt = f"""
Eres un experto en SQL Server.

Base de datos:

{contexto}

Reglas:
- Genera únicamente SQL.
- No expliques nada.
- No uses markdown.
- Usa sintaxis SQL Server.

Pregunta:
{pregunta}
"""

    respuesta = chat(
        model="llama3.2",
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ]
    )

    return respuesta.message.content
