locals {
    confighcl = read_terragrunt_config("${get_terragrunt_dir()}/config.hcl")
    user_groups = local.confighcl.locals.region_groups
    user_datas = jsondecode(file("${find_in_parent_folders("userdata.json")}"))
    userdatas = local.user_datas.userdata

    providers = {
        for user_type, user_spec in local.user_groups:
            user_type => flatten([
            for user in local.userdatas: [
                {
                    "alias": user.username,
                    "access_key": user.access_key,
                    "secret_key": user.secret_key,
                    "region": length(regexall(user_spec["account_filter_regex"], user.username)) > 0 ? "us-west-2" : "ap-northeast-2" 
                } 
            ]
        ])
    }

    provider_template = file(find_in_parent_folders("provider.tmpl"))
    provider_aliases = flatten([for k,v in local.providers: [ for e in v: e["alias"]]])
    provider_access_keys = flatten([for k,v in local.providers: [ for e in v: e["access_key"]]])
    provider_secret_keys = flatten([for k,v in local.providers: [ for e in v: e["secret_key"]]])
    provider_regions = flatten([for k,v in local.providers: [ for e in v: e["region"]]])

    provider_blocks = formatlist(local.provider_template,local.provider_aliases, local.provider_access_keys, local.provider_secret_keys, local.provider_regions, local.provider_aliases)
    generated_provider = join("\n", local.provider_blocks)
}

generate "providers" {
    path = "${get_terragrunt_dir()}/providers.tf"
    if_exists = "overwrite_terragrunt"
    contents = local.generated_provider
}
