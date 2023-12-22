.resources[]
| select(.mode == "managed")
| select(.module | startswith("module.engineer_access"))
| . as $resource
| .instances
| to_entries
| .[]
|
    ([
        $resource.module,
        $resource.type,
        $resource.name + "" + (if (.value|has("index_key")) then "[" + (.value.index_key|tostring) + "]" else "" end)
    ]
    |join(".")) as $to
| ($to| gsub("\""; "'")) as $id
| (
    if ($resource.type == "aws_iam_role_policy_attachment") then
        .value.attributes.role + "/" + .value.attributes.policy_arn
    else
        .value.attributes.id
    end
) as $value
| (
    ["import{",
    "to = " + $to,
    "id = \"" + $value + "\"",
    "}"
    ]
  | join("\n")
  )