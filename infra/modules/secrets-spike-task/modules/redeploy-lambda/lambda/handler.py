import json
import os

import boto3

ecs = boto3.client("ecs")

WATCHED = set()
try:
    WATCHED = set(json.loads(os.environ.get("WATCHED_SECRETS", "[]")))
except Exception:
    WATCHED = set()

CLUSTER = os.environ["TARGET_CLUSTER_ARN"]
SERVICE = os.environ["TARGET_SERVICE_ARN"]


def extract_secret_id(event):
    d = event.get("detail", {})
    rp = d.get("requestParameters", {})
    sid = rp.get("secretId")
    if not sid:
        re = d.get("responseElements", {})
        sid = re.get("arn") or re.get("secretId")
    return sid


def lambda_handler(event, context):
    evt = event or {}
    name = evt.get("detail", {}).get("eventName")
    secret_id = extract_secret_id(evt)
    truncated = (
        (secret_id[:60] + "...") if secret_id and len(secret_id) > 60 else secret_id
    )
    print(
        json.dumps(
            {
                "message": "secrets spike event",
                "eventName": name,
                "secretId": truncated,
                "cluster": CLUSTER,
                "service": SERVICE,
            }
        )
    )

    if not secret_id or secret_id not in WATCHED:
        return {"matched": False}

    ecs.update_service(cluster=CLUSTER, service=SERVICE, forceNewDeployment=True)
    return {"matched": True}
