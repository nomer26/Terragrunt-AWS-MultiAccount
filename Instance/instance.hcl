
locals {
    user_datas = jsondecode(file("${find_in_parent_folders("userdata.json")}"))
    confighcl = read_terragrunt_config("${get_terragrunt_dir()}/config.hcl")

    userdatas = local.user_datas.userdata
    user_groups = local.confighcl.locals.region_groups
    variables = local.user_groups["all"]["variables"]

    instances = {
        for user_type, user_spec in local.user_groups:
        user_type => flatten([
            for user in local.userdatas: [
                for ami in user_spec["amis"]:
                {
                    "username": user.username,
                    "password" : user.password,
                    "pemkey" : user.pemkey,
                    "region": user.region,
                    "ami" : ami
                    // "region": length(regexall(user_spec["account_filter_regex"], user.username)) > 0 ? "us-west-2" : "ap-northeast-2"
                    // "ami" : length(regexall(user_spec["account_filter_regex"], user.parent)) > 0 ? "ami-0c09c7eb16d3e8e70" : "ami-07d16c043aa8e5153"
                }
            ]
        ])
    }

    instance_template = file("${dirname(find_in_parent_folders())}/Instance/instance.tmpl")
    instance_usernames = flatten([ for k,v in local.instances: [ for e in v: e["username"]]])
    instance_amis = flatten([ for k,v in local.instances: [ for e in v: e["ami"]]])
    instance_types = flatten([ for i in range(length(local.instance_usernames)): local.variables["instance_type"]])
    instance_pemkeys = flatten([ for k,v in local.instances: [ for e in v: e["pemkey"]]])

    instance_blocks = formatlist(local.instance_template, 
                                local.instance_usernames,  
                                local.instance_usernames, 
                                local.instance_usernames,
                                local.instance_usernames,
                                local.instance_amis,
                                local.instance_types,  
                                local.instance_usernames, 
                                local.instance_usernames, 
                                local.instance_usernames, 
                                local.instance_usernames, 
                                local.instance_usernames, 
                                local.instance_usernames, 
                                local.instance_usernames, 
                                local.instance_usernames,
                                local.instance_usernames, 
                                local.instance_pemkeys,
                                local.instance_usernames,
                                local.instance_usernames,
                                local.instance_usernames,
                                local.instance_usernames)

    generated_instance = join("\n", local.instance_blocks)
}


generate "instances" {
    path = "${get_terragrunt_dir()}/instances.tf"
    if_exists = "overwrite_terragrunt"
    contents = local.generated_instance
}


