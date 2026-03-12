import { useMemo, useState } from 'react';
import type { ChangeEvent } from 'react';

type ParsedItem = {
  descripcion: string;
  cantidad: number;
  atributos: Record<string, string | number>;
};

type ProposalLine = {
  requested_description: string;
  quantity: number;
  matched_product_name: string;
  brand: string;
  quality: string;
  unit_value: number;
  subtotal: number;
  match_score: number;
};

type ScenarioPayload = {
  items: ProposalLine[];
  total: number;
};

type GroupedProposalLine = {
  matched_product_name: string;
  brand: string;
  quality: string;
  unit_value: number;
  quantity: number;
  subtotal: number;
  source_descriptions: string[];
};

type ExtractResponse = {
  text: string;
  items: ParsedItem[];
  proposals: {
    proposals: {
      economico: ScenarioPayload;
      balanceado: ScenarioPayload;
      premium: ScenarioPayload;
    };
    unmatched_items: ParsedItem[];
  };
};

const API_BASE = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000';

function App() {
  const [file, setFile] = useState<File | null>(null);
  const [documentId, setDocumentId] = useState<string>('');
  const [documentNumericId, setDocumentNumericId] = useState<number | null>(null);
  const [result, setResult] = useState<ExtractResponse | null>(null);
  const [loadingUpload, setLoadingUpload] = useState(false);
  const [loadingExtract, setLoadingExtract] = useState(false);
  const [error, setError] = useState('');

  const activeIdentifier = useMemo(() => {
    if (documentId) return documentId;
    if (documentNumericId) return String(documentNumericId);
    return '';
  }, [documentId, documentNumericId]);

  const groupedScenarios = useMemo(() => {
    if (!result) return null;

    const groupScenario = (scenario: ScenarioPayload): GroupedProposalLine[] => {
      const grouped = new Map<string, GroupedProposalLine>();

      scenario.items.forEach((line) => {
        const key = [line.matched_product_name, line.brand, line.quality, line.unit_value.toFixed(2)].join('|');
        const existing = grouped.get(key);

        if (existing) {
          existing.quantity += line.quantity;
          existing.subtotal += line.subtotal;
          if (!existing.source_descriptions.includes(line.requested_description)) {
            existing.source_descriptions.push(line.requested_description);
          }
          return;
        }

        grouped.set(key, {
          matched_product_name: line.matched_product_name,
          brand: line.brand,
          quality: line.quality,
          unit_value: line.unit_value,
          quantity: line.quantity,
          subtotal: line.subtotal,
          source_descriptions: [line.requested_description]
        });
      });

      return Array.from(grouped.values()).sort((a, b) => b.subtotal - a.subtotal);
    };

    return {
      economico: groupScenario(result.proposals.proposals.economico),
      balanceado: groupScenario(result.proposals.proposals.balanceado),
      premium: groupScenario(result.proposals.proposals.premium)
    };
  }, [result]);

  const handleFileChange = (event: ChangeEvent<HTMLInputElement>) => {
    const selected = event.target.files?.[0] || null;
    setFile(selected);
  };

  const handleUpload = async () => {
    if (!file) return;
    setError('');
    setLoadingUpload(true);
    setResult(null);

    const formData = new FormData();
    formData.append('document[file]', file);

    try {
      const response = await fetch(`${API_BASE}/documents`, {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        throw new Error(`Upload failed (${response.status})`);
      }

      const data = await response.json();
      setDocumentNumericId(data.id || null);
      setDocumentId(data.public_uuid || '');
    } catch (uploadError) {
      setError(uploadError instanceof Error ? uploadError.message : 'Upload failed');
    } finally {
      setLoadingUpload(false);
    }
  };

  const handleExtract = async () => {
    if (!activeIdentifier) return;
    setError('');
    setLoadingExtract(true);

    try {
      const response = await fetch(`${API_BASE}/documents/${activeIdentifier}/extract`);
      if (!response.ok) {
        throw new Error(`Extraction failed (${response.status})`);
      }

      const data: ExtractResponse = await response.json();
      setResult(data);
    } catch (extractError) {
      setError(extractError instanceof Error ? extractError.message : 'Extraction failed');
    } finally {
      setLoadingExtract(false);
    }
  };

  return (
    <main className="app-shell">
      <section className="hero">
        <p className="kicker">DocReader QA Panel</p>
        <h1>Prueba Completa de Carga, Extraccion y Presupuestos</h1>
        <p className="subtitle">
          Sube un PDF de utiles, ejecuta OCR + parser + matching y revisa propuestas economica, balanceada y premium.
        </p>
      </section>

      <section className="control-panel">
        <div className="field-group">
          <label htmlFor="document-file">Archivo</label>
          <input id="document-file" type="file" accept="application/pdf,image/*" onChange={handleFileChange} />
        </div>

        <div className="actions">
          <button type="button" className="btn primary" onClick={handleUpload} disabled={loadingUpload || !file}>
            {loadingUpload ? 'Subiendo...' : 'Subir Archivo'}
          </button>
          <button type="button" className="btn" onClick={handleExtract} disabled={loadingExtract || !activeIdentifier}>
            {loadingExtract ? 'Extrayendo...' : 'Extraer y Proponer'}
          </button>
        </div>

        <div className="meta-row">
          <span>ID: {documentNumericId ?? '-'}</span>
          <span>UUID: {documentId || '-'}</span>
        </div>

        {error && <p className="error">{error}</p>}
      </section>

      {result && (
        <>
          <section className="card">
            <h2>Texto Extraido</h2>
            <pre>{result.text}</pre>
          </section>

          <section className="card">
            <h2>Items Parseados</h2>
            <table>
              <thead>
                <tr>
                  <th>Descripcion</th>
                  <th>Cantidad</th>
                  <th>Atributos</th>
                </tr>
              </thead>
              <tbody>
                {result.items.map((item, index) => (
                  <tr key={`${item.descripcion}-${index}`}>
                    <td>{item.descripcion}</td>
                    <td>{item.cantidad}</td>
                    <td>{Object.keys(item.atributos).length ? JSON.stringify(item.atributos) : '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </section>

          <section className="proposals-grid">
            {(['economico', 'balanceado', 'premium'] as const).map((scenarioKey) => {
              const scenario = result.proposals.proposals[scenarioKey];
              const groupedLines = groupedScenarios ? groupedScenarios[scenarioKey] : [];
              return (
                <article className="proposal-card" key={scenarioKey}>
                  <h3>{scenarioKey.toUpperCase()}</h3>
                  <p className="total">Total: S/ {scenario.total.toFixed(2)}</p>
                  <p className="grouping-note">{groupedLines.length} items consolidados</p>
                  <ul>
                    {groupedLines.map((line, index) => (
                      <li key={`${line.matched_product_name}-${line.brand}-${line.quality}-${line.unit_value}-${index}`}>
                        <strong>{line.quantity}x {line.matched_product_name}</strong>
                        <span>{line.brand} · {line.quality}</span>
                        <span>S/ {line.unit_value.toFixed(2)} c/u · Subtotal S/ {line.subtotal.toFixed(2)}</span>
                        {line.source_descriptions.length > 1 && (
                          <span className="source-count">{line.source_descriptions.length} lineas originales agrupadas</span>
                        )}
                      </li>
                    ))}
                  </ul>
                </article>
              );
            })}
          </section>

          <section className="card">
            <h2>Items Sin Match</h2>
            {result.proposals.unmatched_items.length === 0 ? (
              <p>Todo fue mapeado correctamente al catalogo.</p>
            ) : (
              <ul>
                {result.proposals.unmatched_items.map((item, index) => (
                  <li key={`${item.descripcion}-${index}`}>
                    {item.cantidad}x {item.descripcion}
                  </li>
                ))}
              </ul>
            )}
          </section>
        </>
      )}
    </main>
  );
}

export default App;
