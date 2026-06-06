import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = "http://127.0.0.1:8000/api";

// ============================================================
// IDENTIFIANTS — modifiez ici si besoin
// ============================================================
const LOGIN_USER = "maketing";
const LOGIN_PASS = "0000";
// ============================================================

// --- ÉCRAN DE CONNEXION ---
function LoginScreen({ onLogin }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = () => {
    if (username === LOGIN_USER && password === LOGIN_PASS) {
      onLogin();
    } else {
      setError("❌ Identifiants incorrects");
    }
  };

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: '#0a0a0f',
    }}>
      <div style={{
        background: '#111118',
        border: '1px solid rgba(0,200,255,0.2)',
        borderRadius: '12px',
        padding: '2.5rem',
        width: '100%',
        maxWidth: '380px',
        textAlign: 'center',
        boxShadow: '0 0 40px rgba(0,200,255,0.05)',
      }}>
        <h1 style={{ color: '#00c8ff', fontSize: '1.4rem', marginBottom: '0.5rem', letterSpacing: '2px' }}>
           SUPERVISION AUDIO
        </h1>
        <p style={{ color: '#666', marginBottom: '2rem', fontSize: '0.9rem' }}>
          Accès sécurisé
        </p>

        {error && (
          <div style={{
            background: 'rgba(220,50,50,0.15)',
            border: '1px solid rgba(220,50,50,0.4)',
            color: '#ff6b6b',
            padding: '0.6rem',
            borderRadius: '6px',
            marginBottom: '1rem',
            fontSize: '0.85rem',
          }}>
            {error}
          </div>
        )}

        <div style={{ marginBottom: '1rem', textAlign: 'left' }}>
          <label style={{ color: '#aaa', fontSize: '0.8rem', display: 'block', marginBottom: '4px' }}>
            Nom d'utilisateur
          </label>
          <input
            type="text"
            value={username}
            onChange={e => { setUsername(e.target.value); setError(''); }}
            placeholder="maketing"
            autoFocus
            style={{
              width: '100%',
              background: '#1a1a2e',
              border: '1px solid #333',
              color: '#fff',
              padding: '10px',
              borderRadius: '6px',
              fontSize: '0.95rem',
              boxSizing: 'border-box',
            }}
          />
        </div>

        <div style={{ marginBottom: '1.5rem', textAlign: 'left' }}>
          <label style={{ color: '#aaa', fontSize: '0.8rem', display: 'block', marginBottom: '4px' }}>
            Mot de passe
          </label>
          <input
            type="password"
            value={password}
            onChange={e => { setPassword(e.target.value); setError(''); }}
            placeholder="••••"
            onKeyDown={e => e.key === 'Enter' && handleLogin()}
            style={{
              width: '100%',
              background: '#1a1a2e',
              border: '1px solid #333',
              color: '#fff',
              padding: '10px',
              borderRadius: '6px',
              fontSize: '0.95rem',
              boxSizing: 'border-box',
            }}
          />
        </div>

        <button
          onClick={handleLogin}
          style={{
            width: '100%',
            background: 'linear-gradient(90deg, #00c8ff, #0070ff)',
            color: '#fff',
            border: 'none',
            padding: '12px',
            borderRadius: '6px',
            fontSize: '1rem',
            fontWeight: 'bold',
            cursor: 'pointer',
            letterSpacing: '1px',
          }}
        >
          SE CONNECTER
        </button>
      </div>
    </div>
  );
}

// ============================================================
// APPLICATION PRINCIPALE (votre code original intact)
// ============================================================
function App() {

  // --- AUTHENTIFICATION ---
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // --- ÉTATS ---
  const [players, setPlayers] = useState([]);
  const [tracks, setTracks] = useState([]);
  const [playlists, setPlaylists] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [plannings, setPlannings] = useState([]);

  // États d'ouverture des panels
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [isPlanningOpen, setIsPlanningOpen] = useState(true);
  const [isPlaylistCreatorOpen, setIsPlaylistCreatorOpen] = useState(false);

  // États du formulaire de planification
  const [selectedDay, setSelectedDay] = useState('Lundi');
  const [selectedTime, setSelectedTime] = useState('08:00');
  const [selectedSite, setSelectedSite] = useState('Toutes les gares');
  const [selectedPlaylistAlert, setSelectedPlaylistAlert] = useState('');
  const [selectedVolume, setSelectedVolume] = useState(60);

  // États du créateur de playlist
  const [newPlaylistName, setNewPlaylistName] = useState('');
  const [selectedTracksForPlaylist, setSelectedTracksForPlaylist] = useState([]);
  const [tempTrackId, setTempTrackId] = useState('');

  // --- RÉCUPÉRATION DES DONNÉES ---
  const fetchData = useCallback(async () => {
    try {
      const res = await axios.get(`${API_URL}/dashboard/`);
      setPlayers(res.data.players || []);
      setTracks(res.data.available_tracks || []);
      setPlaylists(res.data.available_playlists || []);
      setError(null);
    } catch (err) {
      setError("⚠️ Liaison interrompue avec le serveur");
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchPlannings = useCallback(async () => {
    try {
      const res = await axios.get(`${API_URL}/get-alerts/`);
      setPlannings(res.data || []);
    } catch (err) {
      console.error("Erreur chargement planning :", err);
    }
  }, []);

  useEffect(() => {
    if (!isAuthenticated) return;
    fetchData();
    fetchPlannings();
    const i1 = setInterval(fetchData, 3000);
    const i2 = setInterval(fetchPlannings, 5000);
    return () => { clearInterval(i1); clearInterval(i2); };
  }, [isAuthenticated, fetchData, fetchPlannings]);

  // --- CRÉATEUR DE PLAYLIST ---
  const addTrackToTempList = () => {
    if (!tempTrackId) return;
    const trackObj = tracks.find(t => t.id === parseInt(tempTrackId, 10));
    if (!trackObj) return;
    const nextOrder = selectedTracksForPlaylist.length + 1;
    setSelectedTracksForPlaylist([...selectedTracksForPlaylist, {
      track_id: trackObj.id,
      title: trackObj.title,
      order: nextOrder,
    }]);
    setTempTrackId('');
  };

  const clearTempTracks = () => setSelectedTracksForPlaylist([]);

  const handleCreatePlaylist = async () => {
    if (!newPlaylistName.trim()) return alert("Donnez un nom à la playlist !");
    if (selectedTracksForPlaylist.length === 0) return alert("Ajoutez au moins un morceau !");
    try {
      await axios.post(`${API_URL}/playlists/`, {
        name: newPlaylistName,
        tracks: selectedTracksForPlaylist.map(t => ({ track_id: t.track_id, order: t.order })),
      });
      setNewPlaylistName('');
      setSelectedTracksForPlaylist([]);
      fetchData();
      alert("🎵 Playlist enregistrée avec succès !");
    } catch (err) {
      alert("Erreur lors de la création de la playlist.");
    }
  };

  // --- PLANIFICATEUR D'ALERTES ---
  const handleAddPlanning = async () => {
    if (!selectedPlaylistAlert) return alert("Veuillez sélectionner une playlist d'alerte !");
    try {
      await axios.post(`${API_URL}/schedule-alert/`, {
        day: selectedDay,
        time: selectedTime,
        site: selectedSite,
        playlist_id: selectedPlaylistAlert,
        volume: parseInt(selectedVolume, 10),
        is_active: true,
      });
      fetchPlannings();
      alert("🚀 Programmation enregistrée !");
    } catch (err) {
      alert("Erreur d'enregistrement.");
    }
  };

  // --- MISE À JOUR D'UN LECTEUR ---
  const updatePlayer = async (name, payload) => {
    setPlayers(prev => prev.map(p => p.name === name ? { ...p, ...payload } : p));
    try {
      if (payload.playlist_id !== undefined) {
        await axios.post(`${API_URL}/set-playlist/`, { name, playlist_id: payload.playlist_id });
      }
      if (payload.volume !== undefined) {
        await axios.post(`${API_URL}/set-volume/`, { name, volume: parseInt(payload.volume, 10) });
      }
    } catch (err) {
      console.error("Erreur serveur :", err);
      fetchData();
    }
  };

  // --- SYNCHRONISATION GLOBALE ---
  const syncAll = async (playlistId) => {
    try {
      await axios.post(`${API_URL}/sync-all/`, { playlist_id: playlistId });
      fetchData();
      alert(playlistId ? " Synchronisation globale lancée !" : "🛑 Arrêt global envoyé !");
    } catch (err) {
      alert("Erreur de synchronisation.");
    }
  };

  // --- ÉCRAN DE LOGIN ---
  if (!isAuthenticated) {
    return <LoginScreen onLogin={() => setIsAuthenticated(true)} />;
  }

  // --- CHARGEMENT INITIAL ---
  if (loading && players.length === 0) {
    return <div className="loading-screen">📡 INITIALISATION DU SYSTÈME...</div>;
  }

  return (
    <div className="App">

      <header className="App-header">
        <h1 className="glitch-text"> SUPERVISION AUDIO DISTRIBUÉE</h1>
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
          {error && <div className="error-banner">{error}</div>}
          <button
            onClick={() => setIsAuthenticated(false)}
            style={{
              background: 'rgba(220,50,50,0.2)',
              border: '1px solid rgba(220,50,50,0.4)',
              color: '#ff6b6b',
              padding: '4px 14px',
              borderRadius: '6px',
              cursor: 'pointer',
              fontSize: '0.8rem',
            }}
          >
             Déconnexion
          </button>
        </div>
      </header>

      {/* --- CRÉATEUR DE PLAYLISTS --- */}
      <section className={`cyber-panel ${isPlaylistCreatorOpen ? 'open' : ''}`}>
        <div className="panel-header" onClick={() => setIsPlaylistCreatorOpen(!isPlaylistCreatorOpen)}>
          <h2> GESTIONNAIRE &amp; CRÉATEUR DE PLAYLISTS</h2>
          <span className="arrow-indicator">{isPlaylistCreatorOpen ? '▲' : '▼'}</span>
        </div>
        {isPlaylistCreatorOpen && (
          <div className="panel-content grid-form">
            <div className="form-group">
              <label>Nom de la Playlist</label>
              <input type="text" placeholder="Ex: Ambiance Matin, Alerte Incendie..." value={newPlaylistName} onChange={e => setNewPlaylistName(e.target.value)} />
            </div>
            <div className="form-group">
              <label>Sélectionner un morceau à ajouter</label>
              <div style={{ display: 'flex', gap: '10px' }}>
                <select value={tempTrackId} onChange={e => setTempTrackId(e.target.value)}>
                  <option value="">-- Choisir un son --</option>
                  {tracks.map(t => <option key={t.id} value={t.id}>{t.title}</option>)}
                </select>
                <button type="button" className="cyber-button text-neon-play" onClick={addTrackToTempList}>➕ Insérer</button>
              </div>
            </div>
            <div className="form-group full-width" style={{ gridColumn: '1 / -1' }}>
              <label>Structure de la playlist actuelle :</label>
              {selectedTracksForPlaylist.length === 0 ? (
                <p className="text-idle" style={{ margin: '5px 0' }}>Aucun morceau dans cette playlist pour le moment.</p>
              ) : (
                <ul style={{ listStyleType: 'none', paddingLeft: 0, margin: '5px 0' }}>
                  {selectedTracksForPlaylist.map((t, index) => (
                    <li key={index} style={{ padding: '4px 0', borderBottom: '1px solid #333' }}>
                      <span className="neon-txt">#{t.order}</span> - 🎵 {t.title}
                    </li>
                  ))}
                </ul>
              )}
            </div>
            <div style={{ gridColumn: '1 / -1', display: 'flex', gap: '15px', marginTop: '10px' }}>
              <button className="cyber-button add-btn" onClick={handleCreatePlaylist}> ENREGISTRER LA PLAYLIST</button>
              <button className="cyber-button stop-all-btn" onClick={clearTempTracks}>🗑️ VIDER LA LISTE</button>
            </div>
          </div>
        )}
      </section>

      {/* --- PLANIFICATEUR D'ALERTES --- */}
      <section className={`cyber-panel ${isFormOpen ? 'open' : ''}`}>
        <div className="panel-header" onClick={() => setIsFormOpen(!isFormOpen)}>
          <h2>⏰ PLANIFICATEUR DE LECTURE GLOBALE &amp; LOCALE</h2>
          <span className="arrow-indicator">{isFormOpen ? '▲' : '▼'}</span>
        </div>
        {isFormOpen && (
          <div className="panel-content grid-form">
            <div className="form-group">
              <label>Jour</label>
              <select value={selectedDay} onChange={e => setSelectedDay(e.target.value)}>
                {['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'].map(d => <option key={d} value={d}>{d}</option>)}
              </select>
            </div>
            <div className="form-group">
              <label>Heure</label>
              <input type="time" step="1" value={selectedTime} onChange={e => setSelectedTime(e.target.value)} />
            </div>
            <div className="form-group">
              <label>Gare / Site Cible</label>
              <select value={selectedSite} onChange={e => setSelectedSite(e.target.value)}>
                <option value="Toutes les gares">🌍 Toutes les gares</option>
                {players.map(p => <option key={p.name} value={p.name}>{p.name}</option>)}
              </select>
            </div>
            <div className="form-group">
              <label>Playlist d'alerte cible</label>
              <select value={selectedPlaylistAlert} onChange={e => setSelectedPlaylistAlert(e.target.value)}>
                <option value="">-- Choisir la playlist --</option>
                {playlists.map(pl => <option key={pl.id} value={pl.id}>📁 {pl.name}</option>)}
              </select>
            </div>
            <div className="form-group">
              <label>Volume ({selectedVolume}%)</label>
              <input type="range" min="0" max="100" value={selectedVolume} onChange={e => setSelectedVolume(e.target.value)} />
            </div>
            <button className="cyber-button add-btn" onClick={handleAddPlanning}>+ AJOUTER AU PLANNING</button>
          </div>
        )}
      </section>

      {/* --- CONTRÔLE GLOBAL --- */}
      <section className="cyber-panel global-controls-zone">
        <h3> CONTRÔLE GLOBAL (MULTI-DIFFUSEUR)</h3>
        <div className="global-buttons">
          <button className="sync-btn" onClick={() => syncAll(playlists[0]?.id || "")} disabled={playlists.length === 0}>
             LANCER PLAYLIST COMMUNE
          </button>
          <button className="stop-all-btn" onClick={() => syncAll(null)}>🛑 ARRÊT GLOBAL</button>
        </div>
      </section>

      {/* --- TABLEAU PLANNING --- */}
      <section className={`cyber-panel ${isPlanningOpen ? 'open' : ''}`}>
        <div className="panel-header" onClick={() => setIsPlanningOpen(!isPlanningOpen)}>
          <h2>🗓️ PLANNING ACTUEL ({plannings.length} programmations)</h2>
          <span className="arrow-indicator">{isPlanningOpen ? '▲' : '▼'}</span>
        </div>
        {isPlanningOpen && (
          <div className="panel-content">
            <table className="cyber-table">
              <thead>
                <tr><th>JOUR</th><th>HEURE</th><th>SITE CIBLE</th><th>PLAYLIST D'ALERTE</th><th>VOLUME</th><th>STATUT</th></tr>
              </thead>
              <tbody>
                {plannings.length === 0 ? (
                  <tr><td colSpan="6" style={{ textAlign: 'center', padding: '20px', opacity: 0.5 }}>Aucune programmation enregistrée</td></tr>
                ) : (
                  plannings.map(p => (
                    <tr key={p.id} className={p.is_active ? "row-active" : "row-inactive"}>
                      <td><strong>{p.day}</strong></td>
                      <td className="neon-txt">{p.time}</td>
                      <td>{p.site}</td>
                      <td>📁 {p.playlist}</td>
                      <td>
                        <div className="table-vol">
                          <div className="table-vol-fill" style={{ width: `${p.volume}%` }}></div>
                          <span>{p.volume}%</span>
                        </div>
                      </td>
                      <td>{p.is_active ? <span className="badge-active">✔ Actif</span> : <span className="badge-inactive">✖ Inactif</span>}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        )}
      </section>

      {/* --- GRILLE LECTEURS --- */}
      <div className="player-grid">
        {players.map((p) => {
          const isOnline = p.status === 'ONLINE';
          return (
            <div key={p.name} className={`player-card ${isOnline ? 'online' : 'offline'}`}>
              <div className="card-header">
                <div className={`led-indicator ${isOnline ? 'led-on' : 'led-off'}`}></div>
                <h3>{p.name}</h3>
              </div>
              <div className="card-body">
                <p>Statut : <strong className={isOnline ? 'text-green' : 'text-red'}>{" "}{p.status}</strong></p>
                <p className="track-display">
                  🎵 {(!p.current_track || p.current_track.trim() === "" || p.current_track === "IDLE") ? (
                    <span className="text-idle">Lecture en cours</span>
                  ) : (
                    <span className="text-neon-play">{p.current_track}</span>
                  )}
                </p>
                <p className="ping-display">
                  ⏱️ Dernier ping : {p.last_ping ? new Date(p.last_ping).toLocaleTimeString() : '—'}
                </p>
                <div className="controls">
                  <label>Playlist d'Ambiance</label>
                  <select value={p.required_playlist_id || ""} onChange={e => updatePlayer(p.name, { playlist_id: e.target.value })}>
                    <option value="">-- Arrêter la diffusion --</option>
                    {playlists.map(pl => <option key={pl.id} value={pl.id}>📁 {pl.name}</option>)}
                  </select>
                  <label>Volume: {p.volume}%</label>
                  <input type="range" min="0" max="100" value={p.volume} onChange={e => updatePlayer(p.name, { volume: e.target.value })} />
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
