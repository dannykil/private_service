# 1. node_exporter 설치(쿠버네티스 각각의 노드에서 진행)
sudo yum install wget tar -y
sudo yum install nano -y

# 각 노드에 SSH로 접속하여 다음 명령어 실행
# wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
# tar -xzvf node_exporter-1.7.0.linux-amd64.tar.gz
# sudo mv node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
# rm -rf node_exporter-1.7.0.linux-amd64.tar.gz node_exporter-1.7.0.linux-amd64
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-arm64.tar.gz
tar -xzvf node_exporter-1.7.0.linux-arm64.tar.gz
sudo mv node_exporter-1.7.0.linux-arm64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-1.7.0.linux-arm64.tar.gz node_exporter-1.7.0.linux-arm64

# node_exporter를 서비스로 등록 및 시작
sudo useradd -rs /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
# sudo nano /etc/systemd/system/node_exporter.service
sudo vi /etc/systemd/system/node_exporter.service

[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=":9100"

[Install]
WantedBy=multi-user.target

# 파일을 저장하고 서비스를 시작
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# 방화벽 포트 추가
# 1) firewalld 서비스 시작
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo systemctl status firewalld

# 2) 포트 추가
sudo firewall-cmd --permanent --add-port=9100/tcp
sudo firewall-cmd --permanent --add-port=30000/tcp
sudo firewall-cmd --reload

# VM에서 실행
sudo systemctl status node_exporter

# 2. 프로메테우스 설정 수정(로컬 머신)docker-compose down prometheus
docker-compose down prometheus
docker-compose up -d prometheus
