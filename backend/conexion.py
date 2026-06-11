import sqlite3

import pyodbc
from base_activa import leer_base_activa

def obtener_conexion():
    base = leer_base_activa()

    if base["tipo"] == "sqlite":
        return sqlite3.connect(base["ruta"])

    server = base.get("server", "ALEJANDRO\\SQLEXPRESS")
    database = base.get("database", "AsistenteSQLIA")

    return pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        f"SERVER={server};"
        f"DATABASE={database};"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )


def obtener_tipo_base():
    return leer_base_activa()["tipo"]
