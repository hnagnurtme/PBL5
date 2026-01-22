# Backend - Django REST Framework

## 📁 Cấu Trúc Thư Mục

```
Backend/
├── config/                      # Cấu hình Django project
│   ├── __init__.py
│   ├── settings.py             # Settings chính
│   ├── urls.py                 # URL routing chính
│   ├── asgi.py                 # ASGI config cho WebSocket
│   └── wsgi.py                 # WSGI config
│
├── apps/                        # Django apps
│   ├── authentication/          # Xác thực người dùng
│   │   ├── models.py           # User, Role models
│   │   ├── views.py            # Login, Register, JWT
│   │   ├── serializers.py
│   │   └── urls.py
│   │
│   ├── drivers/                 # Quản lý tài xế
│   │   ├── models.py           # Driver profile, safety score
│   │   ├── views.py
│   │   ├── serializers.py
│   │   └── urls.py
│   │
│   ├── vehicles/                # Quản lý phương tiện
│   │   ├── models.py           # Vehicle info, GPS tracker
│   │   ├── views.py
│   │   ├── serializers.py
│   │   └── urls.py
│   │
│   ├── violations/              # Xử lý vi phạm
│   │   ├── models.py           # Violation events, snapshots
│   │   ├── views.py            # API nhận từ Camera AI
│   │   ├── consumers.py        # WebSocket consumer
│   │   ├── serializers.py
│   │   └── urls.py
│   │
│   ├── attendance/              # Chấm công
│   │   ├── models.py           # Check-in/out, Face recognition
│   │   ├── views.py
│   │   ├── serializers.py
│   │   └── urls.py
│   │
│   ├── tracking/                # GPS tracking
│   │   ├── models.py           # Route history, GPS logs
│   │   ├── views.py            # Real-time location API
│   │   ├── consumers.py        # WebSocket cho live map
│   │   ├── serializers.py
│   │   └── urls.py
│   │
│   ├── notifications/           # Hệ thống thông báo
│   │   ├── models.py           # Notification, Alert
│   │   ├── views.py
│   │   ├── consumers.py        # Real-time alerts
│   │   ├── tasks.py            # Celery tasks (FCM push)
│   │   ├── serializers.py
│   │   └── urls.py
│   │
│   ├── reports/                 # Báo cáo & thống kê
│   │   ├── models.py
│   │   ├── views.py            # Dashboard analytics
│   │   ├── serializers.py
│   │   └── urls.py
│   │
│   └── payroll/                 # Tính lương
│       ├── models.py           # Salary, bonus, penalty
│       ├── views.py            # Auto calculate
│       ├── serializers.py
│       └── urls.py
│
├── core/                        # Core utilities
│   ├── middleware/              # Custom middleware
│   │   ├── auth.py
│   │   └── logging.py
│   └── utils/                   # Helper functions
│       ├── datetime.py
│       ├── validators.py
│       └── scoring.py          # Driver scoring algorithm
│
├── media/                       # Media files
│   ├── violations/              # Ảnh vi phạm từ Camera
│   └── faces/                   # Ảnh khuôn mặt FaceID
│
├── static/                      # Static files
├── logs/                        # Application logs
├── manage.py
├── requirements.txt             # Python dependencies
├── .env                         # Environment variables
├── Dockerfile
└── docker-compose.yml
```

## 🔑 Chức Năng Chính

### 1. API Gateway
- **POST** `/api/violations/event/` - Nhận sự kiện vi phạm từ Camera AI
- **POST** `/api/tracking/gps/` - Nhận dữ liệu GPS từ Arduino
- **POST** `/api/attendance/face-recognition/` - Xác thực khuôn mặt

### 2. WebSocket Endpoints
- `ws/violations/` - Real-time violation alerts
- `ws/tracking/` - Live GPS tracking
- `ws/notifications/` - Instant notifications

### 3. Admin APIs
- `/api/drivers/` - CRUD tài xế
- `/api/vehicles/` - CRUD xe
- `/api/reports/dashboard/` - Dashboard data
- `/api/payroll/calculate/` - Tính lương tự động

## 🛠️ Tech Stack
- Python 3.10+
- Django 4.2+
- Django REST Framework
- Django Channels (WebSocket)
- PostgreSQL / MySQL
- Redis (cache & Channels layer)
- Celery (background tasks)
- Firebase Admin SDK (FCM)
