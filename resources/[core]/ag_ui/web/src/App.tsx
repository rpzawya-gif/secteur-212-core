import { useState, useEffect } from 'react';
import CharacterSelect from './components/CharacterSelect/CharacterSelect';
import CharacterCreate from './components/CharacterCreate/CharacterCreate';
import HUD from './components/HUD/HUD';
import './App.css';

export interface Character {
  citizenid: string;
  firstname: string;
  lastname: string;
  dob: string;
  gender: string;
  cash: number;
  bank: number;
}

function App() {
  const [activeApp, setActiveApp] = useState<string | null>(null);
  const [characterData, setCharacterData] = useState<Character[]>([]);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const { action, data } = event.data;
      
      if (action === 'openCharacterSelect') {
        setCharacterData(data || []);
        setActiveApp('characterSelect');
      } else if (action === 'closeUI') {
        setActiveApp(null);
      }
    };

    window.addEventListener('message', handleMessage);
    
    // For local browser testing
    const isBrowser = !(window as any).invokeNative;
    if (isBrowser) {
      setTimeout(() => {
        setCharacterData([
          { citizenid: 'ZXC12345', firstname: 'Marcus', lastname: 'Vance', dob: '1992-04-12', gender: 'm', cash: 500, bank: 125000 },
          { citizenid: 'ABC98765', firstname: 'Elena', lastname: 'Russo', dob: '1996-08-22', gender: 'f', cash: 1200, bank: 4500 }
        ]);
        setActiveApp('characterSelect');
      }, 500);
    }

    return () => window.removeEventListener('message', handleMessage);
  }, []);

  return (
    <div className="app-container">
      <HUD />
      {activeApp === 'characterSelect' && (
        <CharacterSelect 
          characters={characterData} 
          onCreateNew={() => setActiveApp('characterCreate')} 
        />
      )}
      {activeApp === 'characterCreate' && (
        <CharacterCreate onBack={() => setActiveApp('characterSelect')} />
      )}
    </div>
  );
}

export default App;
