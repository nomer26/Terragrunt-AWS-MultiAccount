# Terragrunt-AWS-MultiAccount

![image](https://user-images.githubusercontent.com/101347968/210550623-6430f4cd-9c83-4a0d-9de3-74b3739a93ab.png)


How to provision independent resources for multiple AWS accounts

terragrunt는 코드를 템플릿으로 관리하여 중복된 코드와 작업을 최소화하여 프로비저닝 시간을 단축할 수 있습니다. <br>
또한, 그룹화 및 단일화가 가능하며 사용자의 요구 조건에 따라 세부적인 제어가 가능합니다.
terragrunt를 활용하여 여러 AWS에 독립된 리소스를 프로비저닝하는 방법을 소개하겠습니다. <br>



기본적인 동작방식은 <br>
상위 폴더에 *.hcl 확장자의 파일들을 선언하여, Python의 Import와 유사한 방식으로 사용합니다. 

즉, 상위 항목에 공통 템플릿을 작성한 후 각 사용자의 요구사항값을 대입하여 사용자마다의 리소스 코드를 작성하는 방식입니다.
<pre>
Terragrunt-aws-ma
├── Instance
│   ├── <b>instance.hcl</b>
│   └── instance.tmpl
├── provider.tmpl
├── <b>terragrunt.hcl</b>
├── userdata.json
└── users
    ├── config.hcl
    └── <i>terragrunt.hcl</i> <-
</pre>

여기서는 users > terragrunt.hcl 이 상위 항목의 **terragrunt.chl** 와 Instance > **instance.hcl** 을 참조합니다.
~~~
# user > terragrunt.hcl
include "root" {                           <- terragrunt.chl
    path = find_in_parent_folders()
    expose = true
}
include "instance" {                       <- instance.hcl
    path = "${dirname(find_in_parent_folders())}/Instance/instance.hcl"
    expose = true
}
~~~
user의 항목에는 아래와 같이 사용자마다의 리소스가 생성됩니다.

![image](https://user-images.githubusercontent.com/101347968/206885476-a4ea1ed4-bd39-4a15-a26e-1c0d97aa79d4.png)

해당 레포지토리의 코드는 <br>
- Ubuntu 20.04 
- T2.mirco 
- gp2) EBS 100GB  (Root Volume)  <br>
상기 스펙의 단일 인스턴스를 생성합니다. 

_**세부적인 사용자 조건분기를 위한 변수정의는 users > config.hcl 항목에서 할 수 있습니다.**_
