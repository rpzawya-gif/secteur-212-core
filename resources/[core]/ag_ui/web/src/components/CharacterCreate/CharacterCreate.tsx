import { useState } from 'react';
import { UserPlus, ArrowLeft } from 'lucide-react';
import './CharacterCreate.css';

interface Props {
  onBack: () => void;
}

const CharacterCreate = ({ onBack }: Props) => {
  const [formData, setFormData] = useState({
    firstname: '',
    lastname: '',
    dob: '',
    gender: 'm',
    nationality: 'American'
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    fetch(`https://${(window as any).GetParentResourceName?.() || 'ag_ui'}/createCharacter`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData)
    }).catch(() => console.log('Mock: Create char', formData));
  };

  return (
    <div className="char-create-wrapper">
      <div className="create-glass">
        <button className="back-btn" onClick={onBack}>
          <ArrowLeft size={20} /> Back
        </button>
        
        <h2>Create New Identity</h2>
        <p className="subtitle">Forging documents in Los Santos...</p>
        
        <form onSubmit={handleSubmit} className="create-form">
          <div className="form-row">
            <div className="input-group">
              <label>First Name</label>
              <input 
                type="text" 
                required 
                maxLength={20}
                value={formData.firstname}
                onChange={e => setFormData({...formData, firstname: e.target.value})}
                placeholder="John"
              />
            </div>
            <div className="input-group">
              <label>Last Name</label>
              <input 
                type="text" 
                required 
                maxLength={20}
                value={formData.lastname}
                onChange={e => setFormData({...formData, lastname: e.target.value})}
                placeholder="Doe"
              />
            </div>
          </div>

          <div className="form-row">
            <div className="input-group">
              <label>Date of Birth</label>
              <input 
                type="date" 
                required 
                value={formData.dob}
                onChange={e => setFormData({...formData, dob: e.target.value})}
              />
            </div>
            <div className="input-group">
              <label>Gender</label>
              <select 
                value={formData.gender}
                onChange={e => setFormData({...formData, gender: e.target.value})}
              >
                <option value="m">Male</option>
                <option value="f">Female</option>
              </select>
            </div>
          </div>
          
          <div className="input-group full-width">
            <label>Nationality</label>
            <input 
              type="text" 
              required 
              maxLength={20}
              value={formData.nationality}
              onChange={e => setFormData({...formData, nationality: e.target.value})}
            />
          </div>

          <button type="submit" className="submit-btn">
            <UserPlus size={20} /> REGISTER CITIZEN
          </button>
        </form>
      </div>
    </div>
  );
};

export default CharacterCreate;
