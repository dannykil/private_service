### 관리자 계정
1) 초기 계정 
root
2) 초기 패스워드
docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
docker logs gitlab | grep 'Password'

### 비밀번호 재설정 방법
1) 컨테이너 내부로 접속
docker exec -it gitlab /bin/bash
2) GitLab Rails 콘솔 실행
gitlab-rails console
3) 새 비밀번호 설정
user = User.find_by_username('root')
user.password = 'P@ssw0rd12#$'
4) 변경 내용 저장(아래 입력해야함)
user.save!
5) 콘솔 종료
exit


### 사용자 invite
1) group 및 project 생성
2) admin area에서 user 등록
3) 사용자 invite
4) 신규 사용자로 로그인 및 패스워드 변경
* 신규 사용자가 invite mail을 받기 위해서는 gitlab에 smtp서버 설정이 되어있어야함(docker-compose.yml)

### 새로운 원격 저장소 생성 및 사용
git init
git branch -M master
git add .
git commit -m "first commit"
1)  새로운 원격 저장소 추가
1.1) origin 
1.2) gitlab
1.3) github
git remote add <새로운_원격저장소_이름> <원격저장소_URL>
git remote add origin https://github.com/dannykil/private_service.git
git remote set-url --push --delete origin https://bitbucket.hist.co.kr/scm/hx-us/private_service.git
git remote add personal git@localhost:personal/private_service.git
git remote add origin git@gitlab.hanjingroup.co.kr:pjt-search/search-iac
git remote add personal git@localhost:pjt-search/search-iac
git remote add company git@bitbucket.hist.co.kr/scm/hx-us/private_service
2) 특정 원격 저장소로 푸시
git push <원격저장소_이름> <브랜치_이름>
git push origin master
git push personal master
git push --set-upstream personal master
3) 현재 등록된 원격 저장소 확인
git remote -v
* 여러 repository 동시에 push 하기
1) 새로운 원격 저장소 추가
git remote add company-repo [회사_리포지토리_URL]
2) 한 번에 푸시하도록 설정
# 첫 번째 푸시 URL(개인 리포지토리)
git remote set-url --add --push origin [개인_리포지토리_URL]
# 두 번째 푸시 URL(회사 리포지토리)
git remote set-url --add --push origin [회사_리포지토리_URL]
git remote set-url --add --push origin https://github.com/dannykil/private_service.git
git remote set-url --add --push origin git@localhost:personal/private_service.git
git remote set-url --add --push origin https://bitbucket.hist.co.kr/scm/hx-us/private_service.git

git remote set-url --add --push origin 
* 실패하는 경우 강제로 push
git push origin master --force
3) 삭제할 푸시 URL 지정
git remote set-url --delete --push origin git@localhost:personal/private_service.git


### ssh key 생성
1) SSH 키가 있는지 확인
ls -al ~/.ssh
2) SSH 키 생성
ssh-keygen -t ed25519 -C "your_email@example.com"
ssh-keygen -t ed25519 -C "danniel.kil@gmail.com"
* -t ed25519: 최신 암호화 방식인 ed25519 키 타입을 사용하도록 지정합니다.
* -C "your_email@example.com": 키에 주석(comment)을 추가하여 어떤 용도로 생성된 키인지 식별할 수 있게 합니다.
* 명령어를 실행하면 저장 위치를 묻는데, 기본 경로(~/.ssh/id_ed25519)를 그대로 사용하려면 엔터를 누릅니다. 이후 암호(passphrase)를 설정할 수 있는데, 이는 선택 사항입니다.
3) 공개 키 내용 복사
cat ~/.ssh/id_ed25519.pub
* 문자열 전체를 복사
4) GitLab에 공개 키 등록
5) Git Push 재시도
