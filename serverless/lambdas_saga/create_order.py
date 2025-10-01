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
    get_path_tpl = os.environ.get("GET_ORDER_PATH", "/orders/{id}")
    order_id = (event or {}).get("orderId")

    if not order_id:
        # nada a fazer – talvez a criação já aconteceu no passo anterior
        return {"ok": True, "step": "create_order", "note": "no-op (orderId ausente)"}

    url = f"{base}{get_path_tpl.replace('{id}', str(order_id))}"
    print("[create_order] GET", url)
    status, body = _http("GET", url)
    print("[create_order] resp:", status, body)

    return {"ok": status // 100 == 2, "step": "create_order", "orderId": order_id, "response": body}
