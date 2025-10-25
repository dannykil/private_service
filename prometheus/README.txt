1. 데이터 소스(Datasource) 확인 및 재설정
가장 먼저 그라파나가 프로메테우스 데이터 소스를 올바르게 사용하고 있는지 확인해야 합니다. 대시보드를 임포트할 때 실수로 데이터 소스를 잘못 지정했거나, 데이터 소스가 삭제되었을 수 있습니다.
그라파나에서 왼쪽 메뉴의 **Connections -> Data sources**로 이동합니다.
Prometheus 데이터 소스가 목록에 있는지 확인합니다. 만약 없다면 **Add new data source**를 눌러 Prometheus를 추가하세요.
URL 필드에 http://prometheus:9090를 입력합니다.
이는 도커 컴포즈 네트워크에서 그라파나 컨테이너가 프로메테우스 컨테이너를 찾을 수 있는 이름입니다.
Save & test 버튼을 눌러 연결이 성공하는지 확인합니다.

http://prometheus:9090
http://localhost:9090/targets
http://localhost:9100/metrics

RAM 사용량 (퍼센트) 쿼리:
100 * (1 - node_memory_free_bytes / node_memory_total_bytes)

AM 사용량 (퍼센트) 쿼리 (대안):
100 * (node_memory_active_bytes + node_memory_wired_bytes) / node_memory_total_bytes

# 100 * (1 - node_memory_swap_free_bytes / node_memory_swap_total_bytes)

100 * (node_memory_swap_used_bytes / node_memory_swap_total_bytes)


# /opt/prometheus_data 부분을 사용자의 실제 경로로 변경하세요.
# *** 데이터 restore 시 Permission Denied 발생함
sudo chown -R 65534:65534 /opt/prometheus_data