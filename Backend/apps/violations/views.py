from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

from .models import Violation, ViolationStatus
from .serializers import ViolationSerializer, ViolationCreateSerializer
from apps.notifications.tasks import send_fcm_alert


class ViolationViewSet(viewsets.ModelViewSet):
    """
    API để quản lý vi phạm
    """
    queryset = Violation.objects.select_related('driver', 'vehicle').all()
    serializer_class = ViolationSerializer
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'create':
            return ViolationCreateSerializer
        return ViolationSerializer
    
    def create(self, request, *args, **kwargs):
        """
        API nhận sự kiện vi phạm từ Camera AI
        POST /api/violations/
        Body: {
            "driver_id": 1,
            "vehicle_id": 1,
            "violation_type": "DROWSINESS",
            "latitude": 10.7769,
            "longitude": 106.7009,
            "snapshot": <file>,
            "confidence_score": 0.95
        }
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        violation = serializer.save()
        
        # Gửi cảnh báo real-time qua WebSocket
        self._broadcast_alert(violation)
        
        # Gửi push notification tới Mobile App
        send_fcm_alert.delay(violation.id)
        
        return Response(
            ViolationSerializer(violation).data,
            status=status.HTTP_201_CREATED
        )
    
    def _broadcast_alert(self, violation):
        """Gửi cảnh báo qua WebSocket"""
        channel_layer = get_channel_layer()
        
        # Gửi tới Web Admin
        async_to_sync(channel_layer.group_send)(
            'admin_alerts',
            {
                'type': 'violation_alert',
                'message': {
                    'id': violation.id,
                    'driver': violation.driver.name,
                    'vehicle': violation.vehicle.plate_number,
                    'type': violation.violation_type,
                    'snapshot': violation.snapshot.url if violation.snapshot else None,
                    'detected_at': violation.detected_at.isoformat(),
                }
            }
        )
        
        # Gửi tới Mobile App của tài xế
        async_to_sync(channel_layer.group_send)(
            f'driver_{violation.driver.id}',
            {
                'type': 'danger_alert',
                'message': {
                    'type': violation.violation_type,
                    'message': 'CẢNH BÁO: Tài xế đang nguy hiểm!',
                    'timestamp': violation.detected_at.isoformat(),
                }
            }
        )
    
    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        """Xác nhận vi phạm"""
        violation = self.get_object()
        violation.status = ViolationStatus.APPROVED
        violation.reviewed_by = request.user
        violation.reviewed_at = timezone.now()
        violation.save()
        
        return Response({'status': 'Đã xác nhận vi phạm'})
    
    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        """Từ chối vi phạm"""
        violation = self.get_object()
        violation.status = ViolationStatus.REJECTED
        violation.reviewed_by = request.user
        violation.reviewed_at = timezone.now()
        violation.save()
        
        return Response({'status': 'Đã từ chối vi phạm'})
    
    @action(detail=True, methods=['post'])
    def appeal(self, request, pk=None):
        """Gửi khiếu nại từ tài xế"""
        violation = self.get_object()
        violation.appeal_message = request.data.get('message', '')
        violation.appeal_date = timezone.now()
        violation.status = ViolationStatus.APPEALED
        violation.save()
        
        return Response({'status': 'Đã gửi khiếu nại'})
