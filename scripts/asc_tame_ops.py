#!/usr/bin/env python3

from __future__ import annotations

import argparse
import base64
import json
import pathlib
import re
import sys
import time
import ssl
import urllib.error
import urllib.parse
import urllib.request

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec, utils as asym_utils


API_BASE = "https://api.appstoreconnect.apple.com"


def infer_key_id(key_path: pathlib.Path) -> str:
    match = re.search(r"(?:ApiKey|AuthKey)_([A-Z0-9]+)\.p8$", key_path.name)
    if not match:
        raise ValueError(f"Unable to infer key id from filename: {key_path.name}")
    return match.group(1)


def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def encode_jwt_es256(payload: dict, key_id: str, private_key_pem: bytes) -> str:
    header = {"alg": "ES256", "kid": key_id, "typ": "JWT"}
    signing_input = ".".join(
        [
            b64url(json.dumps(header, separators=(",", ":")).encode("utf-8")),
            b64url(json.dumps(payload, separators=(",", ":")).encode("utf-8")),
        ]
    ).encode("ascii")
    private_key = serialization.load_pem_private_key(private_key_pem, password=None)
    if not isinstance(private_key, ec.EllipticCurvePrivateKey):
        raise TypeError("ASC API key is not an EC private key")
    der_signature = private_key.sign(signing_input, ec.ECDSA(hashes.SHA256()))
    r, s = asym_utils.decode_dss_signature(der_signature)
    raw_signature = r.to_bytes(32, "big") + s.to_bytes(32, "big")
    return signing_input.decode("ascii") + "." + b64url(raw_signature)


class ASCClient:
    def __init__(self, key_path: pathlib.Path, key_id: str | None, issuer_id: str | None) -> None:
        self.key_path = key_path.expanduser().resolve()
        self.key_id = key_id or infer_key_id(self.key_path)
        self.issuer_id = issuer_id
        self.private_key_pem = self.key_path.read_bytes()
        self.ssl_context = ssl.create_default_context(cafile="/Users/pengpeng/Library/Python/3.13/lib/python/site-packages/certifi/cacert.pem")
        self._token = ""
        self._token_exp = 0

    def token(self) -> str:
        now = int(time.time())
        if self._token and now < self._token_exp - 30:
            return self._token
        payload: dict[str, int | str] = {
            "aud": "appstoreconnect-v1",
            "iat": now,
            "exp": now + 600,
        }
        if self.issuer_id:
            payload["iss"] = self.issuer_id
        else:
            payload["sub"] = "user"
        self._token = encode_jwt_es256(payload, self.key_id, self.private_key_pem)
        self._token_exp = now + 600
        return self._token

    def request(self, method: str, path: str, *, params: dict | None = None, data: dict | None = None) -> dict:
        url = API_BASE + path
        if params:
            url += "?" + urllib.parse.urlencode(params, doseq=True)
        body = None
        headers = {"Authorization": f"Bearer {self.token()}"}
        if data is not None:
            body = json.dumps(data).encode("utf-8")
            headers["Content-Type"] = "application/json"
        request = urllib.request.Request(url, data=body, headers=headers, method=method)
        try:
            with urllib.request.urlopen(request, timeout=120, context=self.ssl_context) as response:
                raw = response.read()
        except urllib.error.HTTPError as error:
            detail = error.read().decode("utf-8", errors="replace")
            raise RuntimeError(f"{method} {url} failed with HTTP {error.code}: {detail}") from error
        if not raw:
            return {}
        return json.loads(raw.decode("utf-8"))


def first_data(payload: dict) -> dict | None:
    data = payload.get("data", [])
    return data[0] if data else None


def find_bundle_id(client: ASCClient, identifier: str) -> dict | None:
    return first_data(
        client.request(
            "GET",
            "/v1/bundleIds",
            params={
                "filter[identifier]": identifier,
                "fields[bundleIds]": "identifier,name,platform,seedId",
                "limit": "10",
            },
        )
    )


def find_app(client: ASCClient, bundle_id: str) -> dict | None:
    payload = client.request(
        "GET",
        "/v1/apps",
        params={
            "filter[bundleId]": bundle_id,
            "fields[apps]": "name,bundleId,sku,primaryLocale",
            "limit": "10",
        },
    )
    return first_data(payload)


def create_app(client: ASCClient, name: str, bundle_resource_id: str, sku: str, primary_locale: str) -> dict:
    payload = {
        "data": {
            "type": "apps",
            "attributes": {
                "name": name,
                "primaryLocale": primary_locale,
                "sku": sku,
            },
            "relationships": {
                "bundleId": {
                    "data": {
                        "type": "bundleIds",
                        "id": bundle_resource_id,
                    }
                }
            },
        }
    }
    return client.request("POST", "/v1/apps", data=payload)["data"]


def list_versions(client: ASCClient, app_id: str, version: str | None) -> list[dict]:
    params = {
        "filter[platform]": "IOS",
        "fields[appStoreVersions]": "platform,versionString,appStoreState,appVersionState,createdDate",
        "limit": "50",
    }
    if version:
        params["filter[versionString]"] = version
    payload = client.request("GET", f"/v1/apps/{app_id}/appStoreVersions", params=params)
    return payload.get("data", [])


def list_builds(client: ASCClient, app_id: str, build_number: str | None) -> list[dict]:
    params = {
        "filter[app]": app_id,
        "fields[builds]": "version,uploadedDate,processingState,expired,usesNonExemptEncryption",
        "limit": "50",
    }
    if build_number:
        params["filter[version]"] = build_number
    payload = client.request("GET", "/v1/builds", params=params)
    return payload.get("data", [])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="ASC status/create helper for TAME Space Compass.")
    parser.add_argument("--key-path", default="/Users/pengpeng/Desktop/ApiKey_L6Y9VYEJFJYS.p8")
    parser.add_argument("--key-id")
    parser.add_argument("--issuer-id")
    parser.add_argument("--bundle-id", default="com.tame.geomancy")
    parser.add_argument("--name", default="探觅·空间罗盘")
    parser.add_argument("--sku", default="com.tame.geomancy")
    parser.add_argument("--primary-locale", default="zh-Hans")
    parser.add_argument("--version", default="1.0.0")
    parser.add_argument("--build-number", default="1")
    parser.add_argument("--create-app", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    client = ASCClient(pathlib.Path(args.key_path), args.key_id, args.issuer_id)
    app = find_app(client, args.bundle_id)
    bundle = None
    created = False
    if not app and args.create_app:
        bundle = find_bundle_id(client, args.bundle_id)
        if not bundle:
            print(json.dumps({"bundle_id": args.bundle_id, "bundle_resource": None, "app": None}, ensure_ascii=False, indent=2))
            return 2
        app = create_app(client, args.name, bundle["id"], args.sku, args.primary_locale)
        created = True
    versions = list_versions(client, app["id"], args.version) if app else []
    builds = list_builds(client, app["id"], args.build_number) if app else []
    print(
        json.dumps(
            {
                "bundle_id": args.bundle_id,
                "bundle_resource": bundle,
                "app": app,
                "created_app": created,
                "versions": versions,
                "builds": builds,
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0 if app else 3


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(1)
