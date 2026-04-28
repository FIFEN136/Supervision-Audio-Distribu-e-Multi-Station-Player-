import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = "http://127.0.0.1:8000/api";

function App() {
  const [players, setPlayers] = useState([]);
  const [tracks, setTracks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Utilisation de useCallback pour stabiliser la fonction
  const fetchData = useCallback(async () => {
    try {
      const res = await axios.get(`${API_URL}/dashboard/`);
      
      // On compare les données pour éviter de déclencher un rendu si rien n'a changé
      const newData = res.data.players || [];
      setPlayers(prev => {
        if (JSON.stringify(prev) === JSON.stringify(newData)) return prev;
        return newData;
      });

      setTracks(res.data.available_tracks || []);
      setError(null);
    } catch (err) {
      console.error("Erreur de rafraîchissement");
      setError("Liaison interrompue avec le serveur");
    } finally {
      setLoading(false);
    }
  }, []);

  const updatePlayer = async (name, payload) => {
    try {
      // Mise à jour optimiste locale immédiate
      setPlayers(prev => prev.map(p => 
        p.name === name ? { ...p, ...payload } : p
      ));
      
      await axios.post(`${API_URL}/heartbeat/`, { name, ...payload });
      // On ne rappelle pas fetchData immédiatement pour éviter un double rendu
    } catch (err) { 
      console.error("Erreur commande", err); 
    }
  };

  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 3000);
    return () => clearInterval(interval);
  }, [fetchData]);

  if (loading && players.length === 0) {
    return (
      <div className="loading-screen">
        <div className="spinner"></div>
        <p>📡 Connexion au système audio...</p>
      </div>
    );
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>🎯 Supervision Audio Distribuée</h1>
        {error && <div className="error-banner">{error}</div>}
      </header>

      <div className="player-grid">
        {players.map((p) => {
          const isOnline = p.status === 'ONLINE';

          return (
            <div key={p.name} className={`player-card ${isOnline ? 'online' : 'offline'}`}>
              <div className="card-header">
                <span className="status-dot"></span>
                <h3>{p.name}</h3>
              </div>

              <div className="card-body">
                <p>Statut : <strong className={isOnline ? 'text-green' : 'text-red'}>{p.status}</strong></p>
                <p className="track-info">🎵 {p.current_track}</p>
                <p className="ping">Dernier ping : {p.last_ping}</p>

                <div className="controls">
                  <label>Piste</label>
                  <select 
                    value={p.required_track_id || ""} 
                    onChange={(e) => updatePlayer(p.name, { track_id: e.target.value })}
                  >
                    <option value="">-- Arrêter --</option>
                    {tracks.map(t => <option key={t.id} value={t.id}>{t.title}</option>)}
                  </select>

                  <div className="vol-slider">
                    <div className="vol-header">
                      <label>Volume</label>
                      <span>{p.volume}%</span>
                    </div>
                    <input 
                      type="range" min="0" max="100" value={p.volume} 
                      onChange={(e) => updatePlayer(p.name, { volume: e.target.value })} 
                    />
                  </div>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default App;
