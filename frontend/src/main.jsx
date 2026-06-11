import React, { useEffect, useMemo, useRef, useState } from "react";
import { createRoot } from "react-dom/client";
import {
  ArrowUpRight,
  Bot,
  CheckCircle2,
  ChevronDown,
  Cloud,
  Database,
  FileCheck2,
  FileUp,
  Loader2,
  MessageSquareText,
  Search,
  ShieldCheck,
  Sparkles,
  Table2,
  UploadCloud,
} from "lucide-react";
import "./styles.css";

const API_URL = import.meta.env.VITE_API_URL ?? "http://127.0.0.1:8000";

const examples = [
  "Cuales son los 5 productos mas caros?",
  "Muestrame las ventas por cliente",
  "Que productos tienen bajo stock?",
  "Cual fue el total vendido por categoria?",
];

function App() {
  const [question, setQuestion] = useState(examples[0]);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState("");
  const [uploadError, setUploadError] = useState("");
  const [answer, setAnswer] = useState(null);
  const [databaseFile, setDatabaseFile] = useState(null);
  const [activeDatabase, setActiveDatabase] = useState(null);
  const [showSql, setShowSql] = useState(false);
  const fileInputRef = useRef(null);

  const rows = answer?.resultado ?? [];
  const columns = answer?.columnas ?? [];
  const hasRows = rows.length > 0;

  const summary = useMemo(() => {
    if (!answer) return "Aun no hay consulta activa.";
    if (!hasRows) return "La consulta se ejecuto sin filas para mostrar.";
    return `${rows.length} registros encontrados`;
  }, [answer, hasRows, rows.length]);

  useEffect(() => {
    fetch(`${API_URL}/bases-datos/activa`)
      .then((response) => response.json())
      .then((data) => setActiveDatabase(data))
      .catch(() => {
        setActiveDatabase({
          nombre: "Conexion por defecto",
          tipo: "sqlserver",
          activa: true,
        });
      });
  }, []);

  async function handleSubmit(event) {
    event.preventDefault();

    if (!question.trim()) {
      setError("Escribe una pregunta para analizar tu base de datos.");
      return;
    }

    setLoading(true);
    setError("");
    setShowSql(false);

    try {
      const response = await fetch(`${API_URL}/consultar`, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ pregunta: question }),
      });

      const data = await response.json();

      if (!response.ok) {
        const detail = data.detail;
        const message =
          typeof detail === "string"
            ? detail
            : detail?.mensaje ?? "No se pudo procesar la consulta.";

        if (detail?.sql) {
          setAnswer({
            pregunta: question,
            sql: detail.sql,
            columnas: [],
            resultado: [],
          });
        }

        throw new Error(message);
      }

      setAnswer(data);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleUpload(event) {
    const file = event.target.files?.[0];

    if (!file) return;

    const formData = new FormData();
    formData.append("archivo", file);

    setUploading(true);
    setUploadError("");

    try {
      const response = await fetch(`${API_URL}/bases-datos/upload`, {
        method: "POST",
        body: formData,
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.detail ?? "No se pudo adjuntar la base de datos.");
      }

      setDatabaseFile({
        name: data.nombre,
        message: data.mensaje,
        active: data.activa,
      });

      if (data.activa) {
        setActiveDatabase({
          nombre: data.nombre,
          tipo: data.tipo,
          activa: true,
        });
        setAnswer(null);
      }
    } catch (err) {
      setUploadError(err.message);
      setDatabaseFile(null);
    } finally {
      setUploading(false);
      event.target.value = "";
    }
  }

  return (
    <main className="workspace">
      <aside className="sidebar" aria-label="Configuracion de datos">
        <div className="brand">
          <span className="brand-mark">
            <Database size={22} />
          </span>
          <div>
            <strong>DataPilot IA</strong>
            <span>{activeDatabase?.nombre ?? "Asistente de datos"}</span>
          </div>
        </div>

        <section className="source-panel">
          <div className="source-header">
            <Cloud size={21} />
            <div>
              <h2>Base de datos</h2>
              <p>Conecta o adjunta el archivo del cliente.</p>
            </div>
          </div>

          <button
            className="upload-drop"
            type="button"
            onClick={() => fileInputRef.current?.click()}
            disabled={uploading}
          >
            {uploading ? (
              <Loader2 className="spin" size={30} />
            ) : (
              <UploadCloud size={34} />
            )}
            <strong>
              {uploading ? "Adjuntando archivo..." : "Adjuntar base de datos"}
            </strong>
            <span>.bak, .mdf, .sql, .sqlite, .db</span>
          </button>

          <input
            ref={fileInputRef}
            className="file-input"
            type="file"
            accept=".bak,.mdf,.sql,.sqlite,.sqlite3,.db"
            onChange={handleUpload}
          />

          {databaseFile && (
            <div className="file-status success">
              <FileCheck2 size={18} />
              <div>
                <strong>{databaseFile.name}</strong>
                <span>{databaseFile.message}</span>
              </div>
            </div>
          )}

          {activeDatabase && (
            <div className="active-db">
              <span>Consultando ahora</span>
              <strong>{activeDatabase.nombre}</strong>
              <small>{activeDatabase.tipo}</small>
            </div>
          )}

          {uploadError && (
            <div className="file-status danger">
              <FileUp size={18} />
              <span>{uploadError}</span>
            </div>
          )}
        </section>

        <section className="sidebar-note">
          <ShieldCheck size={19} />
          <p>
            El asistente consulta datos en lenguaje natural y mantiene visible
            el SQL solo como respaldo tecnico.
          </p>
        </section>
      </aside>

      <section className="main-view">
        <header className="app-header">
          <div>
            <span className="eyebrow">
              <Sparkles size={16} />
              Analisis inmediato
            </span>
            <h1>Haz preguntas sobre tus datos y recibe respuestas listas.</h1>
          </div>
          <div className="connection-pill">
            <span className="live-dot" />
            {activeDatabase?.tipo === "sqlite" ? "Base adjunta activa" : "SQL Server activo"}
          </div>
        </header>

        <section className="ask-card" aria-label="Consulta principal">
          <div className="assistant-chip">
            <Bot size={18} />
            Asistente listo para consultar
          </div>

          <form onSubmit={handleSubmit} className="ask-form">
            <label htmlFor="question">Que quieres saber?</label>
            <div className="ask-row">
              <div className="input-wrap">
                <Search size={21} />
                <input
                  id="question"
                  value={question}
                  onChange={(event) => setQuestion(event.target.value)}
                  placeholder="Ej: cuales son los productos mas vendidos?"
                />
              </div>
              <button type="submit" disabled={loading}>
                {loading ? (
                  <>
                    <Loader2 className="spin" size={19} />
                    Analizando
                  </>
                ) : (
                  <>
                    Preguntar
                    <ArrowUpRight size={19} />
                  </>
                )}
              </button>
            </div>
          </form>

          <div className="quick-prompts" aria-label="Preguntas sugeridas">
            {examples.map((example) => (
              <button
                type="button"
                key={example}
                onClick={() => setQuestion(example)}
              >
                {example}
              </button>
            ))}
          </div>

          {error && <div className="error-box">{error}</div>}
        </section>

        <section className="insights-grid">
          <article className="result-card">
            <div className="card-heading">
              <div>
                <span>Respuesta</span>
                <h2>{summary}</h2>
              </div>
              <MessageSquareText size={24} />
            </div>

            {!answer && (
              <div className="empty-state">
                Realiza una pregunta para ver aqui los resultados principales.
              </div>
            )}

            {answer && !hasRows && (
              <div className="empty-state">
                No se encontraron registros para esta consulta.
              </div>
            )}

            {hasRows && (
              <div className="table-wrap">
                <table>
                  <thead>
                    <tr>
                      {columns.map((column) => (
                        <th key={column}>{formatLabel(column)}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {rows.map((row, rowIndex) => (
                      <tr key={rowIndex}>
                        {columns.map((column, index) => (
                          <td key={`${column}-${index}`}>
                            {formatValue(row[index])}
                          </td>
                        ))}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </article>

          <article className="detail-card">
            <div className="card-heading compact">
              <div>
                <span>Confianza</span>
                <h2>Consulta verificable</h2>
              </div>
              <CheckCircle2 size={23} />
            </div>

            <div className="check-list">
              <div>
                <Table2 size={18} />
                Resultados ordenados para lectura de negocio.
              </div>
              <div>
                <ShieldCheck size={18} />
                Solo se permiten consultas SELECT.
              </div>
              <div>
                <Database size={18} />
                Preparado para trabajar con bases adjuntas.
              </div>
            </div>

            <button
              className="sql-toggle"
              type="button"
              onClick={() => setShowSql((current) => !current)}
              disabled={!answer?.sql}
            >
              Ver detalle tecnico
              <ChevronDown className={showSql ? "open" : ""} size={18} />
            </button>

            {showSql && (
              <pre>
                <code>{answer.sql}</code>
              </pre>
            )}
          </article>
        </section>
      </section>
    </main>
  );
}

function formatLabel(label) {
  return label.replaceAll("_", " ");
}

function formatValue(value) {
  if (value === null || value === undefined) return "";

  if (typeof value === "number") {
    return new Intl.NumberFormat("es-CO").format(value);
  }

  return String(value);
}

createRoot(document.getElementById("root")).render(<App />);
