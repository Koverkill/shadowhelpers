# shadowhelpers
Bash wrapper for utilizing AWS CLI in thing management.
This was written to make it easier to assign a shadow to things within a Thing Group.
# Available functions (shadow_helper.sh)
``` Bash
# ./shadow_helper [function] [-o|--options]
# ./upload_to_S3
# ./update_thing_shadow
# ./update_group_shadow
# ./get_things_in_group

function upload_to_S3_usage() {
    echo "upload_to_S3"
    echo "  description: Upload a file to an S3 bucket."
    echo "  usage      : ./shadow_helper upload_to_S3 -f|--file <file> -b|--bucketname <S3bucketname>"
    echo "  example    : ./shadow_helper upload_to_S3 -f NewShadow.json -b ltem"
    echo
}

function update_thing_shadow_usage() {
    echo "update_thing_shadow"
    echo "  description: Assign a shadow to an AWS Thing."
    echo "  usage      : ./shadow_helper update_thing_shadow -s|--shadow <shadow> -t|--thing <AWS Thing>"
    echo "  example    : ./shadow_helper update_thing_shadow -s https://ltem.s3.amazonaws.com:443/NewShadow.json -t
    thing123"
    echo
}

function update_group_shadow_usage() {
    echo "update_group_shadow"
    echo "  description: Assign a shadow to be used by all AWS Things in a Group."
    echo "  usage      : ./shadow_helper update_group_shadow -s|--shadow <shadow> -g|--groupname <AWS Group Name>"
    echo "  example    : ./shadow_helper update_thing_shadow -s https://ltem.s3.amazonaws.com:443/NewShadow.json -g NewDeviceGroup"
    echo
}

function get_things_in_group_usage() {
    echo "get_things_in_group"
    echo "  description: Generate a text file containing all the Things in a Group."
    echo "  usage      : ./shadow_helper get_things_in_group -g|--group <AWS Group> -o|--output <Output File>"
    echo "  example    : ./shadow_helper get_things_in_group -g NewDeviceGroup -o NewDeviceThings.txt"
    echo
}
```
# Available functions (utils.sh)
A few wrappers that might be added to the shadow helper script later.
``` Bash
./add_thing_to_group
./delete_thing_from_group
./get_shadow
./update_shadow
```
