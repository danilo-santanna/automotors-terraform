import json, logging, os, urllib.request

logger = logging.getLogger()
logger.setLevel(os.getenv("LOG_LEVEL", "INFO"))
ORDERS_URL = os.getenv("ORDERS_WEBHOOK_URL")

def lambda_handler(event, context):
    body = event.get("body") or ""
    headers_in = event.get("headers") or {}

    # TODO: validar assinatura do MP (ex.: header x-signature) antes de repassar

    if ORDERS_URL:
        try:
            req = urllib.request.Request(
                ORDERS_URL,
                data=body.encode("utf-8"),
                headers={"Content-Type": "application/json"},
                method="POST",
            )
            with urllib.request.urlopen(req, timeout=5) as resp:
                logger.info("Forwarded to Orders: status=%s", resp.status)
        except Exception as e:
            logger.exception("Forward to Orders failed")

    return {"statusCode": 200, "headers": {"Content-Type": "application/json"}, "body": json.dumps({"ok": True})}
