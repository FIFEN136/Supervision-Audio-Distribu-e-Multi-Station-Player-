import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = "http://127.0.0.1:8000/api";

function App() {

  // --- ÉTATS ---
  const [players, setPlayers] = useState([]);
  const [tracks, setTracks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [plannings, setPlannings] = useState([]);

  // États d'ouverture des blocs
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [isPlanningOpen, setIsPlanningOpen] = useState(true);

  // États du formulaire
  const [selectedDay, setSelectedDay] = useState('Lundi');
  const [selectedTime, setSelectedTime] = useState('08:00');
  const [selectedSite, setSelectedSite] = useState('Toutes les gares');
  const [selectedTrack, setSelectedTrack] = useState('');
  const [selectedVolume, setSelectedVolume] = useState(60);

  // --- LOGIQUE DE RÉCUPÉRATION ---
  const fetchData = useCallback(async () => {
    try {
      const res = await axios.get(`${API_URL}/dashboard/`);

      setPlayers(res.data.players || []);
      setTracks(res.data.available_tracks || []);

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

      console.error(err);

    }
  }, []);

  useEffect(() => {

    fetchData();
    fetchPlannings();

    const i1 = setInterval(fetchData, 3000);
    const i2 = setInterval(fetchPlannings, 5000);

    return () => {
      clearInterval(i1);
      clearInterval(i2);
    };

  }, [fetchData, fetchPlannings]);

  // --- ACTIONS ---
  const handleAddPlanning = async () => {

    if (!selectedTrack)
      return alert("Veuillez sélectionner un son !");

    try {

      await axios.post(`${API_URL}/schedule-alert/`, {
        day: selectedDay,
        time: selectedTime,
        site: selectedSite,
        track_id: selectedTrack,
        volume: parseInt(selectedVolume, 10),
        is_active: true
      });

      fetchPlannings();

      alert("🚀 Programmation enregistrée !");

    } catch (err) {

      alert("Erreur d'enregistrement.");

    }
  };

  const updatePlayer = async (name, payload) => {
    try {

      setPlayers(prev =>
        prev.map(p =>
          p.name === name ? { ...p, ...payload } : p
        )
      );

      await axios.post(`${API_URL}/heartbeat/`, {
        name,
        ...payload
      });

    } catch (err) {

      console.error(err);

    }
  };

  const syncAll = async (trackId) => {
    try {

      await axios.post(`${API_URL}/sync-all/`, {
        track_id: trackId
      });

      fetchData();

      alert(
        trackId
          ? "▶️ Synchronisation globale lancée !"
          : "🛑 Arrêt global envoyé !"
      );

    } catch (err) {

      alert("Erreur de synchronisation.");

    }
  };

  // --- ÉCRAN DE CHARGEMENT ---
  if (loading && players.length === 0) {
    return (
      <div className="loading-screen">
        📡 INITIALISATION DU SYSTÈME...
      </div>
    );
  }

  return (

    <div className="App">

      <header className="App-header">

        <h1 className="glitch-text">
          🎯 SUPERVISION AUDIO DISTRIBUÉE
        </h1>

        {error && (
          <div className="error-banner">
            {error}
          </div>
        )}

      </header>

      {/* --- PLANIFICATEUR --- */}

      <section className={`cyber-panel ${isFormOpen ? 'open' : ''}`}>

        <div
          className="panel-header"
          onClick={() => setIsFormOpen(!isFormOpen)}
        >

          <h2>
            ⏰ PLANIFICATEUR DE LECTURE GLOBALE & LOCALE
          </h2>

          <span className="arrow-indicator">
            {isFormOpen ? '▲' : '▼'}
          </span>

        </div>

        {isFormOpen && (

          <div className="panel-content grid-form">

            <div className="form-group">
              <label>Jour</label>

              <select
                value={selectedDay}
                onChange={e => setSelectedDay(e.target.value)}
              >

                {[
                  'Lundi',
                  'Mardi',
                  'Mercredi',
                  'Jeudi',
                  'Vendredi',
                  'Samedi',
                  'Dimanche'
                ].map(d => (
                  <option key={d} value={d}>
                    {d}
                  </option>
                ))}

              </select>
            </div>

            <div className="form-group">
              <label>Heure</label>

              <input
                type="time"
                step="1"
                value={selectedTime}
                onChange={e => setSelectedTime(e.target.value)}
              />
            </div>

            <div className="form-group">
              <label>Gare / Site Cible</label>

              <select
                value={selectedSite}
                onChange={e => setSelectedSite(e.target.value)}
              >

                <option value="Toutes les gares">
                  🌍 Toutes les gares
                </option>

                {players.map(p => (
                  <option key={p.name} value={p.name}>
                    {p.name}
                  </option>
                ))}

              </select>
            </div>

            <div className="form-group">
              <label>Son d'alerte</label>

              <select
                value={selectedTrack}
                onChange={e => setSelectedTrack(e.target.value)}
              >

                <option value="">
                  -- Choisir le son --
                </option>

                {tracks.map(t => (
                  <option key={t.id} value={t.id}>
                    {t.title}
                  </option>
                ))}

              </select>
            </div>

            <div className="form-group">

              <label>
                Volume ({selectedVolume}%)
              </label>

              <input
                type="range"
                min="0"
                max="100"
                value={selectedVolume}
                onChange={e => setSelectedVolume(e.target.value)}
              />

            </div>

            <button
              className="cyber-button add-btn"
              onClick={handleAddPlanning}
            >
              + AJOUTER AU PLANNING
            </button>

          </div>

        )}

      </section>

      {/* --- CONTRÔLE GLOBAL --- */}

      <section className="cyber-panel global-controls-zone">

        <h3>
          🌐 CONTRÔLE GLOBAL (MULTI-DIFFUSEUR)
        </h3>

        <div className="global-buttons">

          <button
            className="sync-btn"
            onClick={() => syncAll(tracks[0]?.id || 1)}
          >
            ▶️ LANCER MUSIQUE COMMUNE
          </button>

          <button
            className="stop-all-btn"
            onClick={() => syncAll(null)}
          >
            🛑 ARRÊT GLOBAL
          </button>

        </div>

      </section>

      {/* --- TABLEAU PLANNING --- */}

      <section className={`cyber-panel ${isPlanningOpen ? 'open' : ''}`}>

        <div
          className="panel-header"
          onClick={() => setIsPlanningOpen(!isPlanningOpen)}
        >

          <h2>
            🗓️ PLANNING ACTUEL ({plannings.length} programmations)
          </h2>

          <span className="arrow-indicator">
            {isPlanningOpen ? '▲' : '▼'}
          </span>

        </div>

        {isPlanningOpen && (

          <div className="panel-content">

            <table className="cyber-table">

              <thead>
                <tr>
                  <th>JOUR</th>
                  <th>HEURE</th>
                  <th>SITE CIBLE</th>
                  <th>SON</th>
                  <th>VOLUME</th>
                  <th>STATUT</th>
                </tr>
              </thead>

              <tbody>

                {plannings.map(p => {

                  // --- CALCUL STATUT ---
                  const [pHours, pMinutes] =
                    p.time.split(':').map(Number);

                  const now = new Date();

                  const planningTime = new Date();

                  planningTime.setHours(
                    pHours,
                    pMinutes,
                    0
                  );

                  const isPast = now > planningTime;

                  return (

                    <tr
                      key={p.id}
                      className={
                        isPast
                          ? "row-inactive"
                          : "row-active"
                      }
                    >

                      <td>
                        <strong>{p.day}</strong>
                      </td>

                      <td className="neon-txt">
                        {p.time}
                      </td>

                      <td>
                        {p.site}
                      </td>

                      <td>
                        🎵 {p.track_name || p.track}
                      </td>

                      <td>

                        <div className="table-vol">

                          <div
                            className="table-vol-fill"
                            style={{
                              width: `${p.volume}%`
                            }}
                          ></div>

                          <span>
                            {p.volume}%
                          </span>

                        </div>

                      </td>

                      <td>

                        {isPast ? (

                          <span className="badge-inactive">
                            ✖ Inactif
                          </span>

                        ) : (

                          <span className="badge-active">
                            ✔ Actif
                          </span>

                        )}

                      </td>

                    </tr>

                  );
                })}

              </tbody>

            </table>

          </div>

        )}

      </section>

      {/* --- GRILLE LECTEURS --- */}

      <div className="player-grid">

        {players.map((p) => {

          const isOnline =
            p.status === 'ONLINE';

          return (

            <div
              key={p.name}
              className={`player-card ${isOnline ? 'online' : 'offline'}`}
            >

              <div className="card-header">

                <div
                  className={`led-indicator ${isOnline ? 'led-on' : 'led-off'}`}
                ></div>

                <h3>{p.name}</h3>

              </div>

              <div className="card-body">

                <p>
                  Statut :
                  <strong className={isOnline ? 'text-green' : 'text-red'}>
                    {" "}{p.status}
                  </strong> 
                </p>

                {/* --- LOGIQUE DE TRADUCTION DE IDLE ICI --- */}
                <p className="track-display">
                  🎵 {(!p.current_track || p.current_track.trim() === "" || p.current_track === "IDLE") ? (
                    <span className="text-idle">Lecture en cours</span>
                  ) : (
                    <span className="text-neon-play">{p.current_track}</span>
                  )}
                </p>

                <p className="ping-display">
                  ⏱️ Dernier ping : {p.last_ping}
                </p>

                <div className="controls">

                  <label>
                    Piste Locale
                  </label>

                  <select
                    value={p.required_track_id || ""}
                    onChange={e =>
                      updatePlayer(
                        p.name,
                        { track_id: e.target.value }
                      )
                    }
                  >

                    <option value="">
                      -- Arrêter --
                    </option>

                    {tracks.map(t => (
                      <option key={t.id} value={t.id}>
                        {t.title}
                      </option>
                    ))}

                  </select>

                  <label>
                    Volume: {p.volume}%
                  </label>

                  <input
                    type="range"
                    min="0"
                    max="100"
                    value={p.volume}
                    onChange={e =>
                      updatePlayer(
                        p.name,
                        { volume: e.target.value }
                      )
                    }
                  />

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
