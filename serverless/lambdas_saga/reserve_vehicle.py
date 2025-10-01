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
    create_path = os.environ.get("CREATE_ORDER_PATH", "/orders")
    url = f"{base}{create_path}"

    payload = {
        "customerId": (event or {}).get("customerId"),
        "vehicleId":  (event or {}).get("vehicleId"),
    }

    print("[reserve_vehicle] POST", url, "payload=", payload)
    status, body = _http("POST", url, body=payload, headers={"Content-Type":"application/json"})
    print("[reserve_vehicle] resp:", status, body)

    if status // 100 != 2:
        return {"ok": False, "step": "reserve_vehicle", "http": status, "body": body}

    # tente pegar id do pedido do corpo
    order_id = None
    if isinstance(body, dict):
        order_id = body.get("id") or body.get("orderId")

    return {"ok": True, "step": "reserve_vehicle", "orderId": order_id, "response": body}
