# ecs-grafana-loki-fluentbit

---

## Summary

---

ECS 컨테이너 오케스트레이션 환경 내 오픈소스 모니터링 환경(Grafana, Loki) 및 무중단 CI/CD 환경 구성
Terraform을 이용한 클라우드 인프라 관리 및 자동화

```
> grafana // Grafana 관련 terraform 파일
    > files // Grafana 대시보드 템플릿

> infrastructure // 클라우드 인프라, CI/CD 리소스 관련 terraform 파일
    > files // IAM json 파일

> loki // Loki 구성 yml, Docker 파일
```

## 기술 스택

---

#### IaC

- terraform
- terraform providers (aws, grafana)
- aws terraform modules
- custom terraform module

#### Infrastructure

- Amazon Elastic Container Service
- AWS Certificate Manager
- Application Load Balancer
- Amazon EC2 Auto Scaling
- AWS Identity and Access Management
- Amazon VPC
- Amazon Relational Database Service
- Amazon Route 53
- Amazon S3
- Amazon ECS Service Connect
- AWS Systems Manager

#### CI/CD

- Amazon Elastic Container Registry
- AWS CodeBuild
- AWS CodePipeline

#### Logging

- Grafana
- Loki
- FluentBit

## 개요

---

- 쿠버네티스보다 가벼운 컨테이너 오케스트레이션 서비스인 ECS를 선정. 쿠버네티스와 비교하여 AWS CSP에 종속된다는 단점이 있지만, 컨테이너 오케스트레이션 마스터 노드 추가 비용을 지불할 필요가 없다는 점과 비교적 가벼운 워커 노드(t4g.micro 등)를 무리없이 운영할 수 있는 장점이 있음.
- 가벼운 워커노드에서 운영가능하게 fluent bit, loki, grafana 스택을 이용하여 로깅 환경 구성
- S3, 로컬 인덱스(boltdb-shipper)를 이용해 loki 로깅 구성
- terraform 관리 통합 및 용이성을 고려하여 CI/CD를 aws code series로 구성
- terraform custom naming module을 제작하여 리소스 네이밍 컨벤션 관리

## 인프라 아키텍처 다이어그램

---

- public, application, database subnet 계층으로 분리
  - public -> Bastion Host, NAT, ALB 라우팅용 서브넷
  - application -> application instance private 서브넷 (NAT 통신 O)
  - database 서브넷 (NAT 통신 X)
- ECS Backend, Monitering Capacity Provider 분리
  - 모니터링 서버, 애플리케이션 서버 독립적 scale out
- host based routing을 위한 L7 application load balancer 구성
  ![ECS-archi drawio](https://github.com/junho100/ecs-grafana-loki-fluentbit/assets/55343124/bb180180-159d-4d63-929a-8347699af90f)

## 로깅 플로우 다이어그램

---

- fluent bit 컨테이너를 애플리케이션 서비스에 사이드카 패턴으로 구성
- ECS Service Connection을 이용한 내부 DNS 통신
  ![Log-archi drawio](https://github.com/junho100/ecs-grafana-loki-fluentbit/assets/55343124/a4e53b0a-db11-4957-a326-34b7d45d089f)

## CI/CD 플로우 다이어그램

---

- 롤링 업데이트 정책을 통한 무중단 배포
  ![CICD-archi drawio](https://github.com/junho100/ecs-grafana-loki-fluentbit/assets/55343124/3abe848e-365a-4a3f-896a-64b6dea22d09)
