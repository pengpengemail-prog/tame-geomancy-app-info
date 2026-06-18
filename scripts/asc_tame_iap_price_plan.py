#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from decimal import Decimal, InvalidOperation


DEFAULT_BUNDLE_ID = "com.tame.geomancy"
DEFAULT_TERRITORY = "USA"
DEFAULT_LIFETIME_PRICE = Decimal("12.99")
PRODUCT_TARGETS = {
    "com.tame.geomancy.premium.lifetime": DEFAULT_LIFETIME_PRICE,
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Plan App Store Connect one-time unlock pricing for TAME Space Compass."
    )
    parser.add_argument("--bundle-id", default=DEFAULT_BUNDLE_ID)
    parser.add_argument("--territory", default=DEFAULT_TERRITORY)
    parser.add_argument("--lifetime-price", default=str(DEFAULT_LIFETIME_PRICE))
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Print an unsupported-action notice; one-time IAP prices must be configured in App Store Connect.",
    )
    parser.add_argument("--key-path", help="Accepted for compatibility; no longer used.")
    parser.add_argument("--key-id", help="Accepted for compatibility; no longer used.")
    parser.add_argument("--issuer-id", help="Accepted for compatibility; no longer used.")
    parser.add_argument("--start-date", help="Accepted for compatibility; no longer used.")
    return parser.parse_args()


def dec(value: str | Decimal) -> Decimal:
    if isinstance(value, Decimal):
        return value
    try:
        return Decimal(value)
    except InvalidOperation as exc:
        raise ValueError(f"Invalid decimal value: {value}") from exc


def qprice(value: Decimal) -> Decimal:
    return value.quantize(Decimal("0.01"))


def main() -> int:
    args = parse_args()
    lifetime_price = qprice(dec(args.lifetime_price))
    targets = [
        {
            "productId": product_id,
            "targetPrice": str(lifetime_price if product_id == "com.tame.geomancy.premium.lifetime" else price),
            "type": "nonConsumable",
            "note": "Set this one-time purchase price in App Store Connect. This workspace no longer schedules recurring billing price changes.",
        }
        for product_id, price in PRODUCT_TARGETS.items()
    ]

    print(
        json.dumps(
            {
                "mode": "unsupported" if args.apply else "plan",
                "bundleId": args.bundle_id,
                "territory": args.territory,
                "targets": targets,
                "results": [],
            },
            ensure_ascii=False,
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
