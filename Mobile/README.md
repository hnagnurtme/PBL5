# 🛡️ RoadSentinel - Hệ Thống Giám Sát Hành Vi Tài Xế & Quản Lý Đội Xe

Hệ thống IoT/AI tích hợp giúp doanh nghiệp vận tải giám sát an toàn tài xế theo thời gian thực, tự động chấm công và quản lý hiệu suất dựa trên hành vi lái xe.

## 🏗️ Kiến Trúc Hệ Thống

Hệ thống hoạt động theo mô hình: **Edge AI (Camera) → Backend (Django) → Clients (Web Admin & Mobile App)**.

### 1. ⚙️ Backend (Django REST Framework)
*Đóng vai trò là trung tâm xử lý dữ liệu và logic nghiệp vụ.*

* **API Gateway:** Tiếp nhận dữ liệu JSON (sự kiện vi phạm) và hình ảnh bằng chứng (Snapshot) từ **Camera AI** và dữ liệu cảm biến/GPS từ **Arduino**.
* **Real-time Socket (Django Channels):** Đẩy cảnh báo tức thì (Alert) từ thiết bị phần cứng tới Web Admin và Mobile App với độ trễ thấp.
* **Logic Nghiệp vụ:**
    * Xử lý chấm công tự động (kết hợp FaceID từ Camera và GPS).
    * Tính điểm an toàn tài xế (Driver Scoring) và tính lương thưởng/phạt tự động.
* **Quản trị dữ liệu:** Lưu trữ lịch sử hành trình, log vi phạm và bằng chứng media.

### 2. 🖥️ Frontend (ReactJS)
*Dành cho Quản lý / Nhà xe (Web Dashboard).*

* **Trung tâm Giám sát (Command Center):**
    * Hiển thị bản đồ GPS thời gian thực của toàn bộ đội xe.
    * **Live Alert Pop-up:** Hiển thị cảnh báo đỏ ngay lập tức khi tài xế ngủ gật/mất tập trung kèm âm thanh và hình ảnh.
* **Quản lý sự cố (Incident Management):** Xem lại, xác nhận (approve) hoặc hủy bỏ (reject) các lỗi do AI bắt được để làm cơ sở phạt.
* **Báo cáo & Thống kê:** Biểu đồ hiệu suất đội xe, bảng công, xuất báo cáo lương hàng tháng.

### 3. 📱 Mobile App (React Native / Flutter)
*Dành cho Tài xế (Driver Companion).*

* **Thiết bị nhận cảnh báo (Receiver):** Rung mạnh và phát âm thanh cảnh báo khi nhận tín hiệu "Nguy hiểm" từ Server (do Camera AI gửi về).
* **Chấm công:** Check-in/Check-out ca làm việc, xác thực vị trí (GPS).
* **Minh bạch thu nhập:**
    * Xem bảng lương tạm tính theo thời gian thực.
    * Xem lịch sử vi phạm và bằng chứng hình ảnh.
    * Gửi khiếu nại nếu bị phạt sai.

---

## 🛠️ Tech Stack

* **Hardware:** Camera AI (Edge Processing), Arduino (Sensors/GPS).
* **Backend:** Python, Django, Django REST Framework, Channels (WebSocket), PostgreSQL/MySQL, Redis.
* **Frontend:** ReactJS, Redux, Ant Design/Material UI, Leaflet/Google Maps API.
* **Mobile:** React Native (hoặc Flutter), Firebase Cloud Messaging (FCM).

## 🚀 Luồng Dữ Liệu Chính (Core Flow)

1.  **Phát hiện:** Camera AI phát hiện tài xế ngủ gật ➔ Gửi tín hiệu về Backend.
2.  **Xử lý:** Backend ghi nhận lỗi, trừ điểm an toàn ➔ Bắn Socket.
3.  **Cảnh báo:**
    * **Web Admin:** Hiện Pop-up cảnh báo kèm ảnh.
    * **Mobile App:** Rung và hú còi đánh thức tài xế.