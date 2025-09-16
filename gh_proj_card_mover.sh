#!/bin/bash

# Move a card (issue or pr) from one project board to another, preserving column (status)

org="prommis"
src_proj_numb=16
dest_proj_numb=18
item_numb=$1

# ToDo: error check on if inputs (org, proj numbs, item numbs) are wrong

# FixMe: If the item_numb is the sole way to identify an item on a board, it can be wrong if there
# are 2 items from different repos with the same item_numb

echo "Getting source project info..."
# Get the source project's internal ID and title
src_proj_json=$(gh project --owner ${org} list --format json)
src_proj_id=$(echo ${src_proj_json} | jq -r ".projects[]|select(.number == ${src_proj_numb}).id")
src_proj_title=$(echo ${src_proj_json} | jq -r ".projects[]|select(.number == ${src_proj_numb}).title")
echo ${src_proj_title}

echo "Getting destitnation project info..."
# Get the destination project's internal ID and title
dest_proj_json=$(gh project --owner ${org} list --format json)
dest_proj_id=$(echo ${dest_proj_json} | jq -r ".projects[]|select(.number == ${dest_proj_numb}).id")
dest_proj_title=$(echo ${dest_proj_json} | jq -r ".projects[]|select(.number == ${dest_proj_numb}).title")
echo ${dest_proj_title}
dest_proj_field_list_json=$(gh project --owner ${org} field-list ${dest_proj_numb} --format json)
dest_proj_status_field_id=$(echo ${dest_proj_field_list_json} | jq -r '.fields[]|select(.name == "Status").id')

echo "Getting item info..."
# Get details on the item
src_proj_item_list_json=$(gh project --owner ${org} item-list ${src_proj_numb} --format json)
src_proj_item_id=$(echo ${src_proj_item_list_json} | jq -r ".items[]|select(.content.number == ${item_numb}).id")
item_title=$(echo ${src_proj_item_list_json} | jq -r ".items[]|select(.content.number == ${item_numb}).title")
item_type=$(echo ${src_proj_item_list_json} | jq -r ".items[]|select(.content.number == ${item_numb}).content.type")
item_repo=$(echo ${src_proj_item_list_json} | jq -r ".items[]|select(.content.number == ${item_numb}).content.repository")
item_status=$(echo ${src_proj_item_list_json} | jq -r ".items[]|select(.content.number == ${item_numb}).status")

echo "Moving ${item_status} ${item_type} #${item_numb} \"${item_title}\" (${src_proj_item_id}) in ${item_repo} from: \"${src_proj_title}\" (${src_proj_id}) to \"${dest_proj_title}\" (${dest_proj_id})"

# Get the gh command to move the issue or pr
if [[ ${item_type} == "Issue" ]]; then
    gh_comm="issue"
elif [[ ${item_type} == "PullRequest" ]]; then
    gh_comm="pr"
else
    echo "Unknown item type: ${item_type}"
    exit -1
fi

echo "Moving item between boards..."
gh ${gh_comm} -R ${item_repo} edit ${item_numb} --remove-project "${src_proj_title}" --add-project "${dest_proj_title}"
ret=$?
if [[ ${ret} -ne 0 ]]; then
    echo "Moving item failed"
    exit ${ret}
fi

# Get the id for the status/column on the dest project
dest_proj_status_value_id=$(echo ${dest_proj_field_list_json} | jq -r ".fields[]|select(.name == \"Status\")|.options[]|select(.name == \"${item_status}\").id")

# Get the id for the item just moved, from the destination project, as it changes when moved
# Note: this can't happen immediately after the above move.  Seems it takes a tiny moment after the
#       move for this project item-list to be updated.
sleep 3
set -x
dest_proj_item_list_json=$(gh project --owner ${org} item-list ${dest_proj_numb} --format json)
dest_proj_item_id=$(echo ${dest_proj_item_list_json} | jq -r ".items[]|select(.content.number == ${item_numb}).id")
".items[]|select(.content.number == ${item_numb}).id"
# Putting it all together to change the status (the column) of an item on the new project
gh project item-edit --project-id ${dest_proj_id} --id ${dest_proj_item_id} --field-id ${dest_proj_status_field_id} --single-select-option-id ${dest_proj_status_value_id}
