# Review Readiness Matrix

Updated: 2026-06-05 01:12 +0800

Final readiness label: `已提交，等待审核`

| Gate | Status | Current Evidence | Remaining Blocker |
| --- | --- | --- | --- |
| Visual design gate | PASS | `mature-commerce-r3` batch generated and approved; uploaded public screenshot sets are the 6-frame zh-Hans/en-US campaign files. | None for current submission. |
| Metadata and screenshot copy | PASS via API | ASC API readback confirms optimized subtitle, keywords, promotional text, descriptions, review notes, support URL, marketing URL, and privacy URL. | None for current submission. |
| Screenshot files | PASS via API | Local validator passed; ASC API readback confirms zh-Hans/en-US each have 6 screenshots and all are `COMPLETE`. | None for current submission. |
| Legal URLs | PASS | Support, Privacy, Marketing, and Apple Standard EULA URLs are current. | None for current submission. |
| Readiness check | PASS | `python3 scripts/check_bilingual_localization.py TAMEGeomancy` passed on 2026-06-05; image validators passed for both upload locale folders. | None. |
| Release gate | PASS via API/MCP | App Store Connect MCP and local ASC API both report `WAITING_FOR_REVIEW`. | None for current submission. |
| ASC API live state | PASS | MCP `review_status` and ASC API both confirm version `1.0` is `WAITING_FOR_REVIEW`. Current evidence: `.build-cache/asc-live-audit/final-r3-waiting-review-readback-20260605.json`. | None for current queue state. |
| App Review submission | WAITING_FOR_REVIEW | Submitted date `2026-06-04T17:10:19.061Z`; reviewSubmission `905bf4ff-d287-404f-8326-2407735d0ea8`; app version `1.0` state `WAITING_FOR_REVIEW`; build `6` is `VALID`. | Wait for Apple review. |
| One-time unlock pricing | PASS via API | Product `com.tame.geomancy.premium.lifetime` is present and IAP state is `WAITING_FOR_REVIEW`. | None for current queue state. |
| Real-device fresh install | HISTORICAL PASS | Earlier fresh-install evidence exists; current session relied on live ASC build, local readiness checks, and App Store review queue confirmation. | Re-run only if Apple rejects for runtime behavior. |
