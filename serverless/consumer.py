import os, json, urllib.request
ORDERS_URL = os.environ["ORDERS_WEBHOOK_URL"]

def handler(event, ctx):
    for rec in event.get("Records", []):
        data = rec["body"].encode("utf-8")
        req = urllib.request.Request(ORDERS_URL, data=data, headers={"Content-Type":"application/json"}, method="POST")
        with urllib.request.urlopen(req) as resp:
            resp.read()
    return {"statusCode": 200}
