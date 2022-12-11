locals {
    region_groups = {
        all = {
            account_filter_regex = "username-00[0-9]"
            # group_filter_regex = "${basename(get_terragrunt_dir())}.*",  # 그룹별 폴더를 별도로 생성해 사용자를 지정할 수 있습니다.
            regions = ["ap-northeast-2","us-west-2"],
            amis = ["ami-07d16c043aa8e5153"]
            variables = {
                instance_type = "t2.micro"
            }
        }
    }
}