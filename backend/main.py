from ia_sql import generar_sql
from ejecutor_sql import ejecutar_sql
from tabulate import tabulate

pregunta = input("Pregunta: ")

sql = generar_sql(pregunta)

print("\nSQL generado:\n")
print(sql)

resultado = ejecutar_sql(sql)

print(
    tabulate(
        resultado,
        tablefmt="grid"
    )
)

pregunta = input("Pregunta: ")
while True:

    pregunta = input("\nPregunta: ")

    if pregunta.lower() == "salir":
        break

    sql = generar_sql(pregunta)

    print("\nSQL generado:")
    print(sql)

    resultado = ejecutar_sql(sql)

    for fila in resultado:
        print(fila)