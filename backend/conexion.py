import pyodbc

def obtener_conexion():
    return pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=ALEJANDRO\\SQLEXPRESS;"
        "DATABASE=AsistenteSQLIA;"
        "Trusted_Connection=yes;"
        "TrustServerCertificate=yes;"
    )