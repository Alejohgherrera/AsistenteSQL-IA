import shutil
import uuid
from datetime import date, datetime
from decimal import Decimal
from pathlib import Path

from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from tabulate import tabulate

from base_activa import (
    UPLOAD_DIR,
    activar_sqlite,
    importar_sql_a_sqlite,
    leer_base_activa,
)
from ejecutor_sql import ejecutar_sql
from ia_sql import corregir_sql, generar_sql


app = FastAPI(title="AsistenteSQL IA")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ConsultaRequest(BaseModel):
    pregunta: str


EXTENSIONES_PERMITIDAS = {".bak", ".mdf", ".sql", ".sqlite", ".sqlite3", ".db"}


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/bases-datos/activa")
def obtener_base_activa():
    base = leer_base_activa()

    return {
        "tipo": base["tipo"],
        "nombre": base["nombre"],
        "activa": True,
    }


@app.post("/consultar")
def consultar(payload: ConsultaRequest):
    pregunta = payload.pregunta.strip()

    if not pregunta:
        raise HTTPException(status_code=400, detail="La pregunta no puede estar vacia.")

    sql = ""

    try:
        sql = generar_sql(pregunta)

        try:
            resultado = ejecutar_sql(sql)
        except Exception as primer_error:
            sql = corregir_sql(pregunta, sql, primer_error)
            resultado = ejecutar_sql(sql)
    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail={
                "mensaje": str(exc),
                "sql": sql,
            },
        ) from exc

    return {
        "pregunta": pregunta,
        "sql": sql,
        "columnas": resultado["columnas"],
        "resultado": [
            [serializar_valor(valor) for valor in fila]
            for fila in resultado["filas"]
        ],
    }


@app.post("/bases-datos/upload")
def adjuntar_base_datos(archivo: UploadFile = File(...)):
    nombre = Path(archivo.filename or "").name
    extension = Path(nombre).suffix.lower()

    if extension not in EXTENSIONES_PERMITIDAS:
        raise HTTPException(
            status_code=400,
            detail="Formato no permitido. Adjunta .bak, .mdf, .sql, .sqlite o .db.",
        )

    UPLOAD_DIR.mkdir(exist_ok=True)
    nombre_seguro = f"{uuid.uuid4().hex}_{nombre}"
    destino = UPLOAD_DIR / nombre_seguro

    with destino.open("wb") as buffer:
        shutil.copyfileobj(archivo.file, buffer)

    if extension in {".sqlite", ".sqlite3", ".db"}:
        base = activar_sqlite(nombre, destino)
        return {
            "nombre": nombre,
            "archivo_guardado": nombre_seguro,
            "tipo": base["tipo"],
            "activa": True,
            "mensaje": "Base de datos adjuntada y activada correctamente.",
        }

    if extension == ".sql":
        try:
            base = importar_sql_a_sqlite(nombre, destino)
        except Exception as exc:
            raise HTTPException(
                status_code=400,
                detail=f"El archivo SQL se guardo, pero no se pudo importar como SQLite: {exc}",
            ) from exc

        return {
            "nombre": nombre,
            "archivo_guardado": nombre_seguro,
            "tipo": base["tipo"],
            "activa": True,
            "mensaje": "Script SQL importado y activado correctamente.",
        }

    return {
        "nombre": nombre,
        "archivo_guardado": nombre_seguro,
        "tipo": "sqlserver",
        "activa": False,
        "mensaje": "Archivo guardado. Para consultar .bak o .mdf primero hay que restaurarlo o adjuntarlo en SQL Server.",
    }


def serializar_valor(valor):
    if isinstance(valor, Decimal):
        return float(valor)

    if isinstance(valor, (date, datetime)):
        return valor.isoformat()

    return valor


def ejecutar_consola():
    while True:
        pregunta = input("\nPregunta: ")

        if pregunta.lower() == "salir":
            break

        sql = generar_sql(pregunta)

        print("\nSQL generado:")
        print(sql)

        try:
            resultado = ejecutar_sql(sql)
        except Exception as primer_error:
            print("\nCorrigiendo SQL por error de ejecucion...")
            sql = corregir_sql(pregunta, sql, primer_error)
            print("\nSQL corregido:")
            print(sql)
            resultado = ejecutar_sql(sql)

        print(tabulate(resultado["filas"], headers=resultado["columnas"], tablefmt="grid"))


if __name__ == "__main__":
    ejecutar_consola()
