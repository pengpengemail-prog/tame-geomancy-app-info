# App Privacy Questionnaire Draft

Updated: 2026-05-24 20:54 +0800

This file is a local App Store Connect privacy-answer draft for `TAME Space Compass / 探觅·空间罗盘`. Final answers must still be checked against the exact binary and the live App Store Connect privacy form before submission.

## Tracking

- Tracking: No
- Third-party advertising: No evidence found in current source scan
- Cross-app tracking or fingerprinting: No evidence found in current source scan
- App Tracking Transparency prompt: Not used

## Account And Identity

- Account required: No
- Login required for reviewer path: No
- User profile collected: No evidence found in current source scan

## Data Handling Summary

| Data Type | Collected By Developer | Linked To User | Used For Tracking | Notes |
| --- | --- | --- | --- | --- |
| Location | No | No | No | Used on device for optional true-north correction. No server upload is documented in current source scan. |
| Photos or Videos | No | No | No | User may import a floor plan from Photos and save report images locally. Current implementation appears local-only. |
| User Content | No | No | No | Local floor plan images, notes, and reports are handled on device according to current code and review notes. |
| Identifiers | No | No | No | No analytics/ad SDK identifier collection found in current source scan. |
| Purchases | Apple handles transaction data | Not collected by developer in app code | No | StoreKit is used for one-time unlock purchase and restore. |
| Diagnostics | No custom collection found | No | No | No custom crash/analytics SDK found in current source scan. |

## Permissions Declared In The App

- `NSLocationWhenInUseUsageDescription`: Used to calibrate true north for higher compass accuracy, optional.
- `NSMotionUsageDescription`: Used for compass orientation measurement.
- `NSCameraUsageDescription`: Used to capture floor plans for spatial reference analysis.
- `NSPhotoLibraryUsageDescription`: Used to import floor plans and access user-selected images.
- `NSPhotoLibraryAddUsageDescription`: Used to save report images to Photos.

## Local Processing Statement

The app does not require an account. Spatial readings, floor plan images, notes, saved records, and generated report images are intended to stay on device unless the user explicitly exports or shares them through iOS system features.

## Final Live ASC Checks Required

- Confirm App Store Connect App Privacy answers match the latest binary.
- Confirm no analytics, ads, crash-reporting, or attribution SDK has been added before submission.
- Confirm public Privacy Policy URL points to the current `TAME Space Compass / 探觅·空间罗盘` legal page.
- Confirm the support/legal pages do not claim collection practices that differ from this questionnaire.
