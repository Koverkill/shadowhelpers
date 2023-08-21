# Other helpful functionss (wrapped)

function add_thing_to_group() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: (Add a thing to a thing group)"
        echo
        echo "  add-thing-to-group <THING> <GROUP_NAME>"
        return 1
    fi
    aws iot add-thing-to-thing-group --thing-name $1 --thing-group-name $2
}

function delete_thing_from_group() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: (Delete a thing from a thing group)"
        echo
        echo "  delete-thing-from-group <THING> <GROUP_NAME>"
        return 1
    fi
    aws iot remove-thing-from-thing-group --thing-name $1 --thing-group-name $2
}

function get_shadow () {
    if [ "$#" -ne 1 ]; then
        echo "Usage: (Get a thing's shadow)"
        echo
        echo "  get_shadow <THING>"
        return 1
    fi
    echo "Getting shadow for ${1}"
    if aws iot-data get-thing-shadow --thing-name ${1} ${1}_shadow.json --no-verify-ssl > /dev/null 2>&1; then
        echo "Got shadow for ${1}. See ${1}_shadow.json"
    else
        echo "Error downloading shadow for ${1}. You may need to manually review."
        return 1
    fi
}

function update_shadow() {
    if [[ "$#" -ne 2 ]] ; then
        echo  "Usage: (Update a thing's shadow)"
        echo
        echo  " update_shadow <Thing> <Shadow>"
        return 1
    fi
    # Supress warning for unverified HTTPS requests.
    outfile=${1}.tmp
    aws iot-data update-thing-shadow --thing-name ${1} --payload ${2} "${outfile}" --no-verify-ssl > /dev/null 2>&1
    echo "Assigned ${2} to ${1}."
    rm -rf $outfile
    return 0
}
