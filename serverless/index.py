import os, json, hmac, hashlib, boto3
sqs = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]
MP_SECRET  = os.environ.get("MP_WEBHOOK_SECRET", "")

def _ok(body): return {"statusCode": 200, "body": json.dumps(body)}

def _valid(sig, body):
    if not MP_SECRET: return True  # demo
    if not sig: return False
    expect = hmac.new(MP_SECRET.encode(), body.encode(), hashlib.sha256).hexdigest()
    return expect in sig

def handler(event, ctx):
    body = event.get("body") or ""
    headers = event.get("headers") or {}
    sig = headers.get("x-signature") or headers.get("X-Signature")
    if not _valid(sig, body):
        return {"statusCode": 403, "body": "invalid signature"}

    sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=body)
    return _ok({"ok": True})
