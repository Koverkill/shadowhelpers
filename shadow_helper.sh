#!/bin/bash
#
# Script Name: shadow_helper.sh
#
# Author: Kellen Overvig
# Email : (kellen.overvig@gmail.com)
# Date  : 03-15-2023
#
# Description: The following script makes it easier to interact with device shadows
#   for AWS Thing(s) or Thing Groups using the AWS CLI.

VERSION="1.0"

function script_version() {
    echo "shadow_helper version: $VERSION"
}

function check_install() {
    if ! command -v aws &> /dev/null; then
        echo >&2 "Please install and configure AWS CLI before re-running shadow_helper.";
        echo -e "To do so run:\n"
        echo "sudo apt install awscli"
        echo "aws configure"
        echo "You will need your AWS Access Key ID and AWS Secret Access Key."
        exit 1
    fi
}

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

function script_usage() {
    echo -e "Usage: ./shadow_helper [function] [-o|--options]\n"
    echo -e "Functions:\n"

    upload_to_S3_usage
    update_thing_shadow_usage
    update_group_shadow_usage
    get_things_in_group_usage

    echo -e "Other Parameters:\n"
    echo "-h|--help"
    echo "  description: Show this script usage menu."
    echo
    echo "-v|--version"
    echo "  description: Show script version."
}

function upload_to_S3() {
    if [[ $# -ne 4 ]] ; then
        upload_to_S3_usage
        exit 1
    fi
    local param
    while [[ $# -gt 0 ]] ; do
        param="$1"
        shift
        case $param in
            -f | --file)
                filename="$(basename ${1})"
                ;;
            -b | --S3bucketname)
                bucketname="${1}"
                ;;
            *)
                echo -e "Error: Unexpected option ($param) provided.\n"
                upload_to_S3_usage
                exit 1
                ;;
        esac
        shift
    done
    echo "Checking if ${filename} already is hosted on ${bucketname}."
    if ! [[ $(aws s3 ls s3://${bucketname}/${filename}) ]] ; then
        echo "${filename} not found on "${bucketname}", uploading..."
        aws s3 cp ${filename} s3://${bucketname} --acl public-read
        echo "Successfully uploaded!"
    fi
    echo "Hosted at https://${bucketname}.s3.amazonaws.com:443/${filename}."
    echo "Use this link when assigning a shadow to a thing or group of things."
    exit 0
}

function update_thing_shadow() {
    if [[ $# -ne 4 ]] ; then
        update_thing_shadow_usage
        exit 1
    fi
    local param
    while [[ $# -gt 0 ]] ; do
        param="$1"
        shift
        case $param in
            -s | --shadow)
                shadow="${1}"
                ;;
            -t | --thing)
                thing="${1}"
                ;;
            *)
                echo -e "Error: Unexpected option ($param) provided.\n"
                update_thing_shadow_usage
                exit 1
                ;;
        esac
        shift
    done
    # Supress warning for unverified HTTPS requests.
    outfile=${thing}.tmp
    aws iot-data update-thing-shadow --thing-name $thing --payload $shadow "${outfile}" --no-verify-ssl > /dev/null 2>&1
    echo "Assigned ${shadow} to ${thing}."
    rm -rf $outfile
    exit 0
}

function update_group_shadow() {
    if [[ $# -ne 4 ]] ; then
        update_group_shadow_usage
        exit 1
    fi
    local param
    while [[ $# -gt 0 ]] ; do
        param="$1"
        shift
        case $param in
            -s | --shadow)
                shadow="${1}"
                ;;
            -g | --groupname)
                groupname="${1}"
                ;;
            *)
                echo -e "Error: Unexpected option ($param) provided.\n"
                update_group_shadow_usage
                exit 1
                ;;
        esac
        shift
    done

    thingfile=${groupname}_things
    touch $thingfile
    #each line will have the form, THINGS  THINGNAME, remove the first 7 characters
    aws iot list-things-in-thing-group --thing-group-name ${groupname} --output text | sed -r 's/.{7}//' > ${thingfile}
    while IFS= read -r line; do
        outfile=${line}.tmp
        aws iot-data update-thing-shadow --thing-name $line --payload $shadow "${outfile}" --no-verify-ssl > /dev/null 2>&1
        echo "Assigned ${shadow} to ${line}."
        rm -rf ${outfile}
    done < ${thingfile}
    rm -rf ${thingfile}
    echo "Done."
}

function get_things_in_group()
{
    if [[ $# -ne 4 ]] ; then
        get_things_in_group_usage
        exit 1
    fi
    local param
    while [[ $# -gt 0 ]] ; do
        param="$1"
        shift
        case $param in
            -o | --outfile)
                outfile="${1}"
                ;;
            -g | --groupname)
                groupname="${1}"
                ;;
            *)
                echo -e "Error: Unexpected option ($param) provided.\n"
                get_things_in_group_usage
                exit 1
                ;;
        esac
        shift
    done

    touch ${outfile}
    #each line will have the form, THINGS  THINGNAME, remove the first 7 characters
    aws iot list-things-in-thing-group --thing-group-name ${groupname} --output text | sed -r 's/.{7}//' > ${outfile}
    cat ${outfile}
    echo "Copied to ${outfile}."
}

function parse_params() {
    if [[ $# -eq 0 ]] ; then
        script_usage
        exit 1
    fi

    local function_name
    while [[ $# -gt 0 ]] ; do
        function_name="$1"
        shift
        case $function_name in
            upload_to_S3)
                upload_to_S3 "$@"
                exit 0
                ;;
            update_thing_shadow)
                update_thing_shadow "$@"
                exit 0
                ;;
            update_group_shadow)
                update_group_shadow "$@"
                exit 0
                ;;
            get_things_in_group)
                get_things_in_group "$@"
                exit 0
                ;;
            usage | -h | --help)
                script_usage
                exit 0
                ;;
            version | -v | --version)
                script_version
                exit 0
                ;;
            *)
                echo -e "Error: Unexpected option ($function_name) provided.\n"
                script_usage
                exit 1
                ;;
        esac
    done
}

function main() {
    check_install
    set -e -o pipefail # allow script to stop on exception or on pipefail
    parse_params "$@"
}

main "$@"
