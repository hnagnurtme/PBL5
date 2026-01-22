import io from 'socket.io-client';

class WebSocketService {
  constructor() {
    this.socket = null;
    this.listeners = new Map();
  }

  connect(token) {
    const WS_URL = process.env.REACT_APP_WS_URL || 'ws://localhost:8000';
    
    this.socket = io(WS_URL, {
      auth: { token },
      reconnection: true,
      reconnectionAttempts: 5,
      reconnectionDelay: 1000,
    });

    this.socket.on('connect', () => {
      console.log('✅ WebSocket connected');
      this.joinAdminRoom();
    });

    this.socket.on('disconnect', () => {
      console.log('❌ WebSocket disconnected');
    });

    this.socket.on('violation_alert', (data) => {
      this.handleViolationAlert(data);
    });

    this.socket.on('gps_update', (data) => {
      this.handleGPSUpdate(data);
    });
  }

  joinAdminRoom() {
    this.socket.emit('join_admin', {});
  }

  handleViolationAlert(data) {
    console.log('🚨 Violation Alert:', data);
    
    // Phát âm thanh cảnh báo
    this.playAlertSound();
    
    // Trigger listeners
    this.notifyListeners('violation_alert', data);
  }

  handleGPSUpdate(data) {
    console.log('📍 GPS Update:', data);
    this.notifyListeners('gps_update', data);
  }

  playAlertSound() {
    const audio = new Audio('/sounds/alert.mp3');
    audio.play().catch(err => console.error('Audio play failed:', err));
  }

  on(event, callback) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event).push(callback);
  }

  off(event, callback) {
    if (!this.listeners.has(event)) return;
    const callbacks = this.listeners.get(event);
    const index = callbacks.indexOf(callback);
    if (index > -1) {
      callbacks.splice(index, 1);
    }
  }

  notifyListeners(event, data) {
    if (!this.listeners.has(event)) return;
    this.listeners.get(event).forEach(callback => callback(data));
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }
}

export default new WebSocketService();
