from django.db import models
from apps.drivers.models import Driver
from apps.vehicles.models import Vehicle


class ViolationType(models.TextChoices):
    DROWSINESS = 'DROWSINESS', 'Ngủ gật'
    DISTRACTION = 'DISTRACTION', 'Mất tập trung'
    PHONE_USAGE = 'PHONE_USAGE', 'Sử dụng điện thoại'
    SMOKING = 'SMOKING', 'Hút thuốc'
    NO_SEATBELT = 'NO_SEATBELT', 'Không thắt dây an toàn'


class ViolationStatus(models.TextChoices):
    PENDING = 'PENDING', 'Chờ xử lý'
    APPROVED = 'APPROVED', 'Đã xác nhận'
    REJECTED = 'REJECTED', 'Đã từ chối'
    APPEALED = 'APPEALED', 'Đang khiếu nại'


class Violation(models.Model):
    """Model lưu trữ vi phạm từ Camera AI"""
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='violations')
    vehicle = models.ForeignKey(Vehicle, on_delete=models.CASCADE, related_name='violations')
    
    violation_type = models.CharField(max_length=20, choices=ViolationType.choices)
    status = models.CharField(max_length=20, choices=ViolationStatus.choices, default=ViolationStatus.PENDING)
    
    # Thông tin vi phạm
    detected_at = models.DateTimeField(auto_now_add=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    
    # Bằng chứng
    snapshot = models.ImageField(upload_to='violations/%Y/%m/%d/', null=True, blank=True)
    confidence_score = models.FloatField(default=0.0)  # Độ tin cậy từ AI (0-1)
    
    # Xử lý
    penalty_points = models.IntegerField(default=0)
    penalty_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    
    # Khiếu nại
    appeal_message = models.TextField(blank=True, null=True)
    appeal_date = models.DateTimeField(null=True, blank=True)
    
    # Metadata
    reviewed_by = models.ForeignKey('authentication.User', on_delete=models.SET_NULL, null=True, blank=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'violations'
        ordering = ['-detected_at']
        indexes = [
            models.Index(fields=['driver', 'detected_at']),
            models.Index(fields=['status']),
        ]
    
    def __str__(self):
        return f"{self.driver.name} - {self.get_violation_type_display()} - {self.detected_at}"
    
    @property
    def is_pending(self):
        return self.status == ViolationStatus.PENDING
