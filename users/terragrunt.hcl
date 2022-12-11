include "root" {
    path = find_in_parent_folders()
    expose = true
}
include "instance" {
    path = "${dirname(find_in_parent_folders())}/Instance/instance.hcl"
    expose = true
}