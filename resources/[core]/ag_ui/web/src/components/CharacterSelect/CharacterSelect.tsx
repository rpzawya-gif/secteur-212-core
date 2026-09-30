import { useState } from 'react';
import { Play, Plus, User, Wallet, Landmark, Calendar, MapPin } from 'lucide-react';
import type { Character } from '../../App';
import './CharacterSelect.css';

interface Props {
  characters: Character[];
  onCreateNew: () => void;
}

const CharacterSelect = ({ characters, onCreateNew }: Props) => {
  const [selectedChar, setSelectedChar] = useState<Character | null>(
    characters.length > 0 ? characters[0] : null
  );

  const handlePlay = () => {
    if (selectedChar) {
      // Send NUI callback to client
      fetch(`https://${(window as any).GetParentResourceName?.() || 'ag_ui'}/selectCharacter`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ citizenid: selectedChar.citizenid })
      }).catch(() => console.log('Mock: Selected character', selectedChar.citizenid));
    }
  };

  const handleCreate = () => {
    onCreateNew();
  };

  return (
    <div className="char-select-wrapper">
      <div className="char-select-sidebar">
        <div className="sidebar-header">
          <h1 className="title">SECTEUR <span>212</span></h1>
          <p className="subtitle">Select your identity</p>
        </div>

        <div className="char-list">
          {characters.map((char) => (
            <div 
              key={char.citizenid}
              className={`char-card ${selectedChar?.citizenid === char.citizenid ? 'active' : ''}`}
              onClick={() => setSelectedChar(char)}
            >
              <div className="char-avatar">
                <User size={24} />
              </div>
              <div className="char-info-short">
                <h3>{char.firstname} {char.lastname}</h3>
                <span className="citizenid">ID: {char.citizenid}</span>
              </div>
            </div>
          ))}

          {characters.length < 4 && (
            <div className="char-card create-new" onClick={handleCreate}>
              <div className="char-avatar create-icon">
                <Plus size={24} />
              </div>
              <div className="char-info-short">
                <h3>Create Identity</h3>
                <span className="citizenid">Available Slot</span>
              </div>
            </div>
          )}
        </div>
      </div>

      {selectedChar && (
        <div className="char-details-panel">
          <div className="details-glass">
            <div className="details-header">
              <h2>{selectedChar.firstname} {selectedChar.lastname}</h2>
              <div className="badge">Active Citizen</div>
            </div>

            <div className="stats-grid">
              <div className="stat-box">
                <Wallet className="stat-icon text-green" />
                <div className="stat-text">
                  <span className="label">Cash</span>
                  <span className="value">${selectedChar.cash.toLocaleString()}</span>
                </div>
              </div>
              <div className="stat-box">
                <Landmark className="stat-icon text-blue" />
                <div className="stat-text">
                  <span className="label">Bank</span>
                  <span className="value">${selectedChar.bank.toLocaleString()}</span>
                </div>
              </div>
              <div className="stat-box">
                <Calendar className="stat-icon text-purple" />
                <div className="stat-text">
                  <span className="label">Date of Birth</span>
                  <span className="value">{selectedChar.dob}</span>
                </div>
              </div>
              <div className="stat-box">
                <MapPin className="stat-icon text-red" />
                <div className="stat-text">
                  <span className="label">Last Location</span>
                  <span className="value">Los Santos</span>
                </div>
              </div>
            </div>

            <button className="play-button" onClick={handlePlay}>
              <Play size={20} className="play-icon" />
              <span>ENTER WORLD</span>
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default CharacterSelect;
