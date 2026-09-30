import { useState, useEffect } from 'react';
import { Heart, Shield, Droplets, Utensils, Wallet, Landmark } from 'lucide-react';
import './HUD.css';

interface HUDData {
  health: number;
  armor: number;
  hunger: number;
  thirst: number;
  cash: number;
  bank: number;
  show: boolean;
}

const HUD = () => {
  const [data, setData] = useState<HUDData>({
    health: 100,
    armor: 50,
    hunger: 100,
    thirst: 100,
    cash: 0,
    bank: 0,
    show: false
  });

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      const { action, payload } = event.data;
      if (action === 'updateHUD') {
        setData(prev => ({ ...prev, ...payload, show: true }));
      } else if (action === 'hideHUD') {
        setData(prev => ({ ...prev, show: false }));
      }
    };

    window.addEventListener('message', handleMessage);
    
    // For local browser testing
    const isBrowser = !(window as any).invokeNative;
    if (isBrowser) {
      setTimeout(() => {
        setData({
          health: 75, armor: 50, hunger: 80, thirst: 90, cash: 1250, bank: 45000, show: true
        });
      }, 1000);
    }
    
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  if (!data.show) return null;

  return (
    <div className="hud-wrapper">
      <div className="money-container">
        <div className="money-item cash">
          <Wallet size={18} className="money-icon" />
          <span>${data.cash.toLocaleString()}</span>
        </div>
        <div className="money-item bank">
          <Landmark size={18} className="money-icon" />
          <span>${data.bank.toLocaleString()}</span>
        </div>
      </div>

      <div className="status-container">
        <div className="status-item health">
          <svg className="circular-chart" viewBox="0 0 36 36">
            <path className="circle-bg" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
            <path className="circle" strokeDasharray={`${data.health}, 100`} d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
          </svg>
          <Heart size={16} className="status-icon" fill="currentColor" />
        </div>

        {data.armor > 0 && (
          <div className="status-item armor">
            <svg className="circular-chart" viewBox="0 0 36 36">
              <path className="circle-bg" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
              <path className="circle" strokeDasharray={`${data.armor}, 100`} d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
            </svg>
            <Shield size={16} className="status-icon" fill="currentColor" />
          </div>
        )}

        <div className="status-item hunger">
          <svg className="circular-chart" viewBox="0 0 36 36">
            <path className="circle-bg" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
            <path className="circle" strokeDasharray={`${data.hunger}, 100`} d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
          </svg>
          <Utensils size={16} className="status-icon" />
        </div>

        <div className="status-item thirst">
          <svg className="circular-chart" viewBox="0 0 36 36">
            <path className="circle-bg" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
            <path className="circle" strokeDasharray={`${data.thirst}, 100`} d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831" />
          </svg>
          <Droplets size={16} className="status-icon" fill="currentColor" />
        </div>
      </div>
    </div>
  );
};

export default HUD;
