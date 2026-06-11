import json
import re
import sqlite3
import uuid
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
UPLOAD_DIR = BASE_DIR / "uploads"
CONFIG_PATH = UPLOAD_DIR / "base_activa.json"

SQL_SERVER_CONFIG = {
    "tipo": "sqlserver",
    "nombre": "AsistenteSQLIA",
    "server": "ALEJANDRO\\SQLEXPRESS",
    "database": "AsistenteSQLIA",
}


def leer_base_activa():
    if not CONFIG_PATH.exists():
        return SQL_SERVER_CONFIG

    with CONFIG_PATH.open("r", encoding="utf-8") as archivo:
        return json.load(archivo)


def guardar_base_activa(config):
    UPLOAD_DIR.mkdir(exist_ok=True)

    with CONFIG_PATH.open("w", encoding="utf-8") as archivo:
        json.dump(config, archivo, indent=2)


def activar_sqlite(nombre, ruta):
    config = {
        "tipo": "sqlite",
        "nombre": nombre,
        "ruta": str(ruta),
    }
    guardar_base_activa(config)
    return config


def importar_sql_a_sqlite(nombre, ruta_sql):
    db_path = UPLOAD_DIR / f"{Path(ruta_sql).stem}_{uuid.uuid4().hex[:8]}.sqlite"
    script = Path(ruta_sql).read_text(encoding="utf-8-sig")
    script = normalizar_tsql_para_sqlite(script)

    with sqlite3.connect(db_path) as conexion:
        conexion.execute("PRAGMA foreign_keys = ON")
        conexion.executescript(script)

    return activar_sqlite(nombre, db_path)


def normalizar_tsql_para_sqlite(script):
    script = re.sub(
        r"(?im)^\s*CREATE\s+DATABASE\s+[\[\]\w]+\s*;\s*$",
        "",
        script,
    )
    script = re.sub(
        r"(?im)^\s*USE\s+[\[\]\w]+\s*;\s*$",
        "",
        script,
    )
    script = re.sub(r"(?im)^\s*GO\s*;?\s*$", "", script)
    script = script.replace("[", "").replace("]", "")
    script = re.sub(r"\bdbo\.", "", script, flags=re.IGNORECASE)
    script = re.sub(r"\bMONEY\b", "NUMERIC", script, flags=re.IGNORECASE)
    script = re.sub(r"\bDATETIME\b", "TEXT", script, flags=re.IGNORECASE)
    script = re.sub(r"\bDATE\b", "TEXT", script, flags=re.IGNORECASE)
    script = re.sub(r"\bBIT\b", "INTEGER", script, flags=re.IGNORECASE)
    script = re.sub(r"\bNVARCHAR\s*\(([^)]*)\)", r"TEXT", script, flags=re.IGNORECASE)
    script = re.sub(r"\bVARCHAR\s*\(([^)]*)\)", r"TEXT", script, flags=re.IGNORECASE)
    script = re.sub(r"\bNCHAR\s*\(([^)]*)\)", r"TEXT", script, flags=re.IGNORECASE)
    script = re.sub(r"\bCHAR\s*\(([^)]*)\)", r"TEXT", script, flags=re.IGNORECASE)
    script = re.sub(
        r"\bIDENTITY\s*\(\s*\d+\s*,\s*\d+\s*\)",
        "",
        script,
        flags=re.IGNORECASE,
    )
    script = re.sub(r"\bGETDATE\s*\(\s*\)", "CURRENT_TIMESTAMP", script, flags=re.IGNORECASE)

    return script
