# Inventora — Inventory Management System

An iOS inventory management app built with **SwiftUI** and **Core Data**. It provides an admin-facing dashboard to manage products, stock levels, categories, suppliers, and orders.

> **Inventora** — *Precision in Every Count.*

---

## Features

- **Splash screen** with animated branding that transitions into the app.
- **Authentication** with login and registration forms (email, password, name, contact no.).
- **Dashboard** screen with:
  - Metric cards: Total Products, Low Stock, Out of Stock, Orders Today.
  - Monthly revenue summary with a bar chart and month-over-month comparison.
  - Recent orders section.
- **Core Data** persistence for storing inventory entities.
- **Logout** flow returning the user to the login screen.

---

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Persistence:** Core Data
- **Platform:** iOS

---

## Project Structure

```
InventoryManagementSystem/
├── InventoryManagementSystemApp.swift   # App entry point, injects Core Data context
├── ContentView.swift                    # Root content placeholder
├── Persistence.swift                    # Core Data NSPersistentContainer setup
├── View/
│   ├── SplashScreen/                    # SplashScreenView
│   ├── Authentication/                  # AuthView (login / register)
│   └── DashboardScreen/                 # DashboardScreenView + metric/revenue cards
├── InventoryManagementSystem.xcdatamodeld  # Core Data model
└── Assets.xcassets                      # App icon and splash image
```

---

## Core Data Entities

| Entity    | Purpose                                          | Key Attributes /
Relationships |
|-----------|--------------------------------------------------|--------------------------------------------------|
| `Admin`   | System administrator / owner                       | name, email, password, contact; categories, products, suppliers, orders, stack logs |
| `Category`| Product classification                            | name; products, suppliers, admin |
| `Product` | Inventory item with details & image               | name, price, quantity, detail, imageData; category, supplier, admin |
| `Supplier`| Vendor supplying products                         | name, contact, address, gstNumber; products, categories |
| `Order`   | Purchase / sales order record                     | orderNumber, orderType, status, totalAmount, orderDate |
| `StackLog`| Stock-level change history                        | previousQuantity, newQuantity, quantityChanged, transactionType |

---

## Getting Started

### Requirements

- **Xcode 15+**
- **iOS 17+**
- A Mac running macOS capable of running the Xcode version above.

### Run the App

1. Clone or open the project:

   ```bash
   git clone <repository-url>
   cd InventoryManagementSystem
   open InventoryManagementSystem.xcodeproj
   ```

2. In Xcode, select a target simulator or device.
3. Press `Cmd + R` to build and run.

Alternatively, build from the command line:

```bash
xcodebuild -project InventoryManagementSystem.xcodeproj \
  -scheme InventoryManagementSystem \
  -destination 'generic/platform=iOS Simulator' \
  build
```

---

## Roadmap (Planned)

- Wire authentication to Core Data `Admin` records (currently UI-only).
- Persistent login session.
- Product, category, supplier, and order management screens.
- Dashboard metrics driven by live Core Data.
```