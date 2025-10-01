import json, os, urllib.request, urllib.error

def _http(method, url, body=None, headers=None, timeout=10):
    data = None if body is None else json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url, data=data, method=method)
    for k, v in (headers or {}).items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            raw = resp.read().decode("utf-8") if resp.length != 0 else ""
            return resp.status, json.loads(raw) if raw else None
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8")
        return e.code, {"error": "http_error", "status": e.code, "body": raw, "url": url}
    except Exception as e:
        return 599, {"error": "exception", "message": str(e), "url": url}

def handler(event, context):
    base = os.environ.get("ORDERS_API_URL", "").rstrip("/")
    pay_path_tpl  = os.environ.get("PAY_CARD_PATH", "/orders/{id}/pay-card")
    order_id = (event or {}).get("orderId")

    if not order_id:
        return {"ok": False, "step": "take_payment", "error": "orderId ausente no input"}

    url = f"{base}{pay_path_tpl.replace('{id}', str(order_id))}"

    card = (event or {}).get("card") or {
        "cardNumber": "5031433215406351",      # MP teste
        "cardholderName": "APRO",
        "cardExpirationMonth": 12,
        "cardExpirationYear": 2030,
        "securityCode": "123",
        "installments": 1,
        "email": "test_user@example.com",
        "docType": "CPF",
        "docNumber": "19119119100"
    }

    print("[take_payment] PUT", url, "card=", {k: card[k] for k in card if k != "cardNumber"})
    status, body = _http("PUT", url, body=card, headers={"Content-Type":"application/json"})
    print("[take_payment] resp:", status, body)

    return {"ok": status // 100 == 2, "step": "take_payment", "orderId": order_id, "response": body}
