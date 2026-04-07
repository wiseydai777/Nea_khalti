# NEA Payment — Khalti Integration (Flutter)

A pixel-faithful Flutter port of the NEA electricity payment UI, converted from the original dark-themed HTML prototype.

---

## Features

- **5-step payment flow**: Counters → Consumer Lookup → Bills → Service Charge → Payment
- **V1 / V2 API version toggle** (auto-selected from `migrated_to_v2` flag)
- **Responsive layout**: Sidebar + Main + API Log panel on wide screens; stacked on mobile
- **Mock API data** matching the original HTML prototype
- **Live API log panel** with collapsible request/response JSON

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app_theme.dart               # Dark theme + AppColors
├── models.dart                  # Data models (AppState, BillItem, NeatCounter, ApiLogEntry)
├── services.dart                # Mock API service layer
├── widgets.dart                 # Shared widgets (FormCard, Callout, AmountRow, etc.)
├── widgets/
│   └── api_log_panel.dart       # Right-side API log panel
├── screens/
│   └── nea_payment_screen.dart  # Root screen (TopBar, Sidebar, StepsBar, layout)
└── steps/
    ├── step0_counters.dart      # Step 0: Fetch & select counter
    ├── step1_consumer_lookup.dart # Step 1: V1/V2 consumer lookup
    ├── step2_bills.dart         # Step 2: Fetch and select bills
    ├── step3_service_charge.dart # Step 3: Calculate service charge
    └── step4_payment.dart       # Step 4: Confirm payment + success screen
```

---

## Setup

```bash
# Navigate to project folder
cd nea_payment

# Get dependencies
flutter pub get

# Run on your device / emulator
flutter run

# Build APK
flutter build apk --release
```

---

## Color Palette

| Token        | Value       |
|-------------|-------------|
| `bg`        | `#0D0F14`   |
| `surface`   | `#13161D`   |
| `surface2`  | `#1A1E28`   |
| `accent`    | `#4ADE80`   |
| `amber`     | `#FBBF24`   |
| `red`       | `#F87171`   |
| `blue`      | `#60A5FA`   |
| `muted`     | `#6B7280`   |
| `text`      | `#E8EAF0`   |

---

## Flow Summary

| Step | API Endpoint |
|------|-------------|
| 0. Counters | `POST /api/servicegroup/counters/nea-v2/` |
| 1. Consumer (V2) | `POST /api/servicegroup/user-info/nea-v2/` |
| 2. Bills (V2) | `POST /api/servicegroup/details/nea-v2/` |
| 2. Bills (V1) | `POST /api/servicegroup/details/nea/` |
| 3. Service charge (V1) | `POST /api/servicegroup/servicecharge/nea/` |
| 4. Payment (V2) | `POST /api/servicegroup/commit/nea-v2/` |
| 4. Payment (V1) | `POST /api/servicegroup/commit/nea/` |

> Replace mock responses in `lib/services.dart` with real `http` calls when integrating with the live Khalti API.
