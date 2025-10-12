administrator password 
1) 컨테이너 접속
docker exec -it 8f36fe788643 /bin/bash
2) 비밀번호 파일 조회
cat /var/jenkins_home/secrets/initialAdminPassword