const BASE_URL = import.meta.env.VITE_API_BASE_URL;

export async function getIncidents() {
  const r = await fetch(`${BASE_URL}/incidents`);
  if (!r.ok) throw new Error(`GET /incidents failed: ${r.status}`);
  const data = await r.json();
  return data.incidents || data;
}

export async function createIncident(payload) {
  const r = await fetch(`${BASE_URL}/incidents`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  if (!r.ok) throw new Error(`POST /incidents failed: ${r.status}`);
  return r.json();
}