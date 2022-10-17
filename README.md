# Terraform

## Terraform installation

## For Apple Silicon

[Reference](https://discuss.hashicorp.com/t/template-v2-2-0-does-not-have-a-package-available-mac-m1/35099/4)

- 1. Remove any existing Terraform binary (/usr/bin/terraform and/or /usr/local/bin/terraform)
- 2. Install [m1-terraform-provider-helper](https://github.com/kreuzwerker/m1-terraform-provider-helper)
  - 2.1. `brew install kreuzwerker/taps/m1-terraform-provider-helper`
- 3. Install Terraform
  - 3.1. `brew tap hashicorp/tap`
  - 3.2. `brew install hashicorp/tap/terraform`
- 4. Install the hashicorp/template version v2.2.0
  - 4.1. `m1-terraform-provider-helper install hashicorp/template -v v2.2.0`

```
➜  ~ terraform --version
Terraform v1.3.1
on darwin_arm64
+ provider registry.terraform.io/hashicorp/aws v4.33.0
+ provider registry.terraform.io/hashicorp/random v3.4.3
+ provider registry.terraform.io/hashicorp/template v2.2.0
```

## Initial setting state

- 초기에는 `default` workspace 를 사용한다.
- `terraform.tfstate`와 `.terraform.lock.hcl`을 Remote로 관리하기 위해 상태관리 인프라를 먼저 배포하고 Terraform을 backed 설정을 변경한다. => 아래 코드만 남기고 모두 주석 처리

```hcl
locals {
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

provider "aws" {
  region = var.region
}

module "terraform_state" {
  source                               = "./modules/terraform-state"
  s3_terraform_state_bucket_name       = "mystack-terraform-running-state"
  s3_terraform_state_key               = "global/s3/terraform.tfstate"
  dynamodb_terraform_state_locks_table = "mystack-terraform-running-locks"
}

```

- 이후 아래 Terraform backend 설정하고 `terraform init`으로 S3로 백엔드를 설정한다.

```hcl
 terraform {
   backend "s3" {
     bucket = "mystack-terraform-running-state"
     key    = "global/s3/terraform.tfstate"
     region = "ap-northeast-2"
     dynamodb_table = "mystack-terraform-running-locks"
     encrypt        = true
   }
 }
```

- 이후 `terraform_state` 모듈은 주석처리하고 Workspace를 생성하여 각 스테이징 환경에 따라 State를 나누는 과정을 한다. ex) `dev`

```
terraform workspace new dev
terraform apply
```

- Apple Silicon Mac의 경우 Lock을 다음으로 업데이트한다. `terraform providers lock -platform=linux_amd64`
- 이후 주석처리한 모든 module들을 해제하고 각 워크스페이스를 `terraform workspace select` 명령을 통해 체크아웃한 후 배포 한다.

## CodeStar Connection

GitHub 리포 연결을 위해서는 콘솔에서 직접 연결해야 함. CodePipeline 에서 Setting

`terraform apply` 이후

CodePipeline > Settings > Connections

Status = Pending 인 커넥션 선택 후 `Update pending connection` 으로 Github 연결

## Workspace Migration

<https://stackoverflow.com/questions/66979732/in-terraform-is-it-possible-to-move-to-state-from-one-workspace-to-another>

# Terraform Workspace

## Check workspace

```
terraform workspace list
```

- `dev`: 개발 인프라
- `staged`: E2E 테스트 인프라
- `prod`: Production 인프라

## Select workspace

- `dev` 워크스페이스 선택

```
terraform workspace select ${workspace name}
```
