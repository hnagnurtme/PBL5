# Frontend - ReactJS Admin Dashboard

## 📁 Cấu Trúc Thư Mục

```
Frontend/
├── public/
│   ├── index.html
│   └── favicon.ico
│
├── src/
│   ├── assets/                  # Static resources
│   │   ├── images/
│   │   ├── icons/
│   │   └── sounds/             # Alert sounds
│   │       └── alert.mp3
│   │
│   ├── components/              # Reusable components
│   │   ├── common/
│   │   │   ├── Header.jsx
│   │   │   ├── Sidebar.jsx
│   │   │   ├── Button.jsx
│   │   │   ├── Table.jsx
│   │   │   └── Modal.jsx
│   │   │
│   │   ├── dashboard/
│   │   │   ├── StatsCard.jsx
│   │   │   ├── VehicleStatus.jsx
│   │   │   └── RecentViolations.jsx
│   │   │
│   │   ├── map/
│   │   │   ├── LiveMap.jsx      # Bản đồ GPS real-time
│   │   │   ├── VehicleMarker.jsx
│   │   │   └── RouteHistory.jsx
│   │   │
│   │   └── alerts/
│   │       ├── AlertPopup.jsx   # Pop-up cảnh báo đỏ
│   │       └── AlertSound.jsx   # Audio player
│   │
│   ├── pages/                   # Page components
│   │   ├── Dashboard/
│   │   │   └── index.jsx       # Command Center
│   │   │
│   │   ├── Drivers/
│   │   │   ├── DriverList.jsx
│   │   │   ├── DriverDetail.jsx
│   │   │   └── DriverScoring.jsx
│   │   │
│   │   ├── Vehicles/
│   │   │   ├── VehicleList.jsx
│   │   │   └── VehicleDetail.jsx
│   │   │
│   │   ├── Violations/
│   │   │   ├── ViolationList.jsx
│   │   │   ├── ViolationDetail.jsx  # Xem ảnh bằng chứng
│   │   │   └── IncidentManagement.jsx # Approve/Reject
│   │   │
│   │   ├── Reports/
│   │   │   ├── Dashboard.jsx
│   │   │   ├── SalaryReport.jsx
│   │   │   └── PerformanceReport.jsx
│   │   │
│   │   └── Attendance/
│   │       └── AttendanceLog.jsx
│   │
│   ├── services/                # API services
│   │   ├── api.js              # Axios instance
│   │   ├── authService.js
│   │   ├── driverService.js
│   │   ├── vehicleService.js
│   │   ├── violationService.js
│   │   ├── trackingService.js
│   │   └── websocket.js        # WebSocket connection
│   │
│   ├── redux/                   # State management
│   │   ├── store.js
│   │   └── slices/
│   │       ├── authSlice.js
│   │       ├── driverSlice.js
│   │       ├── vehicleSlice.js
│   │       ├── violationSlice.js
│   │       └── alertSlice.js
│   │
│   ├── utils/                   # Utilities
│   │   ├── dateFormatter.js
│   │   ├── validators.js
│   │   └── constants.js
│   │
│   ├── hooks/                   # Custom hooks
│   │   ├── useWebSocket.js     # WebSocket hook
│   │   ├── useAuth.js
│   │   └── useNotification.js
│   │
│   ├── styles/                  # Global styles
│   │   ├── global.css
│   │   └── variables.css
│   │
│   ├── App.jsx
│   ├── index.jsx
│   └── routes.jsx              # React Router
│
├── package.json
├── .env                         # Environment variables
├── .gitignore
└── README.md
```

## 🎯 Tính Năng Chính

### 1. Command Center (Dashboard)
- **Live Map:** Hiển thị toàn bộ đội xe trên bản đồ (Leaflet/Google Maps)
- **Real-time Alerts:** Pop-up cảnh báo đỏ + âm thanh khi phát hiện vi phạm
- **Stats Cards:** Tổng số xe đang chạy, vi phạm hôm nay, điểm an toàn trung bình

### 2. Incident Management
- Danh sách vi phạm với filter (ngày, tài xế, loại lỗi)
- Xem ảnh bằng chứng từ Camera AI
- **Approve/Reject:** Xác nhận hoặc hủy vi phạm

### 3. Reports & Analytics
- Biểu đồ hiệu suất (Chart.js/Recharts)
- Bảng công tài xế
- Xuất báo cáo lương (Excel/PDF)

## 🛠️ Tech Stack
- **Framework:** React 18+
- **State Management:** Redux Toolkit
- **UI Library:** Ant Design / Material-UI
- **Maps:** Leaflet / Google Maps API
- **Charts:** Recharts / Chart.js
- **WebSocket:** Socket.io-client / native WebSocket
- **HTTP Client:** Axios
- **Routing:** React Router v6

## 🚀 Setup & Run

```bash
# Install dependencies
npm install

# Start dev server
npm start

# Build production
npm run build
```

## 📡 WebSocket Integration

```javascript
// src/services/websocket.js
import { io } from 'socket.io-client';

const socket = io(process.env.REACT_APP_WS_URL);

socket.on('violation_alert', (data) => {
  // Hiển thị popup + phát âm thanh
  playAlertSound();
  showAlertPopup(data);
});
```
