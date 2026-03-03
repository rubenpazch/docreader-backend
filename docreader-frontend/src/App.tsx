
import { useState } from 'react';
import type { ChangeEvent } from 'react';

function App() {
  const [file, setFile] = useState<File | null>(null);
  const [uploadId, setUploadId] = useState<number | null>(null);
  const [extractedText, setExtractedText] = useState('');
  const [loading, setLoading] = useState(false);

  const handleFileChange = (e: ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0]);
    }
  };

  const handleUpload = async () => {
    if (!file) return;
    setLoading(true);
    const formData = new FormData();
    formData.append('document[file]', file);
    try {
          const res = await fetch('http://localhost:3000/documents', {
        method: 'POST',
        body: formData,
      });
      const data = await res.json();
      setUploadId(data.id);
      setLoading(false);
    } catch (err) {
      setLoading(false);
      alert('Upload failed');
    }
  };

  const handleExtract = async () => {
    if (!uploadId) return;
    setLoading(true);
    try {
          const res = await fetch(`http://localhost:3000/documents/${uploadId}/extract`);
      const data = await res.json();
      setExtractedText(data.text);
      setLoading(false);
    } catch (err) {
      setLoading(false);
      alert('Extraction failed');
    }
  };

  return (
    <div style={{ padding: 40 }}>
      <h2>Document Upload & Extractor</h2>
      <input type="file" accept="application/pdf,image/*" onChange={handleFileChange} />
      <button onClick={handleUpload} disabled={loading || !file} style={{ marginLeft: 10 }}>
        Upload
      </button>
      {uploadId && (
        <button onClick={handleExtract} disabled={loading} style={{ marginLeft: 10 }}>
          Extract Text
        </button>
      )}
      {loading && <p>Loading...</p>}
      {extractedText && (
        <div style={{ marginTop: 20 }}>
          <h4>Extracted Text:</h4>
          <pre style={{ background: '#f4f4f4', padding: 10 }}>{extractedText}</pre>
        </div>
      )}
    </div>
  );
}

export default App;
