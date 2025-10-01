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
    sync_path_tpl = os.environ.get("SYNC_PAYMENT_PATH", "/orders/{id}/sync-payment")
    get_path_tpl  = os.environ.get("GET_ORDER_PATH", "/orders/{id}")

    order_id = (event or {}).get("orderId")
    if not order_id:
        return {"ok": False, "step": "mark_sold", "error": "orderId ausente no input"}

    sync_url = f"{base}{sync_path_tpl.replace('{id}', str(order_id))}"
    get_url  = f"{base}{get_path_tpl.replace('{id}', str(order_id))}"

    print("[mark_sold] PUT", sync_url)
    s1, b1 = _http("PUT", sync_url)
    print("[mark_sold] sync resp:", s1, b1)

    print("[mark_sold] GET", get_url)
    s2, b2 = _http("GET", get_url)
    print("[mark_sold] get resp:", s2, b2)

    ok = (s1 // 100 == 2) and (s2 // 100 == 2)
    return {"ok": ok, "step": "mark_sold", "orderId": order_id, "sync": b1, "order": b2}
