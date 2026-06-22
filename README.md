# Plant Farm (PP)

A native iOS plant shopping and plant-care companion app, built with SwiftUI (MVVM) and a custom PHP + MySQL backend.

## Tech Stack

- **iOS App:** Swift, SwiftUI, MVVM, Combine, async/await networking
- **Backend:** PHP REST API, MySQL (via Docker)
- **Local web server:** MAMP (serves the PHP API over Apache)

## Prerequisites

Install these before setting up the project:

- [Xcode](https://developer.apple.com/xcode/) (latest version recommended)
- [MAMP](https://www.mamp.info/) — serves the PHP backend
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — runs the MySQL database

## Dependencies

The iOS app uses Swift Package Manager — **no manual install needed**. Xcode resolves these automatically the first time you open the project (requires an internet connection):

- [UIColor-Hex-Swift](https://github.com/yeahdongcn/UIColor-Hex-Swift)
- [Google Maps iOS SDK](https://github.com/googlemaps/ios-maps-sdk)

If Xcode doesn't fetch them automatically, go to **File → Packages → Resolve Package Versions**.

## Installation

### 1. Set up the backend

1. Copy the `PP-Backend` folder into MAMP's `htdocs` directory:
   ```
   /Applications/MAMP/htdocs/PP-Backend
   ```
2. Open **MAMP** and click **Start Servers** (this runs Apache on port `8888`, serving the PHP API).
3. Open **Docker Desktop**, then in a terminal:
   ```bash
   cd /Applications/MAMP/htdocs/PP-Backend
   docker compose up -d
   ```
   This starts MySQL (port `3307`) and phpMyAdmin (port `8080`). On the **first run only**, it automatically creates all database tables and seeds the plant catalog from `schema.sql` — no manual SQL needed.

4. Verify the backend is working:
   ```bash
   curl http://localhost:8888/PP-Backend/api/plants.php
   ```
   You should see a JSON response listing plants.

### 2. Configure the app to find your backend

The app needs to know your Mac's local network IP (not `localhost`, since it also needs to work from a physical device or simulator).

Find your IP:
```bash
ipconfig getifaddr en0
```

Then open [`PP/Utility/Api/APIService.swift`](PP/Utility/Api/APIService.swift) and update the `baseURL`:

```swift
let baseURL = "http://<YOUR_LOCAL_IP>:8888/PP-Backend/api"
```

> Your device/simulator must be on the **same Wi-Fi network** as the Mac running MAMP and Docker.

### 3. Run the iOS app

1. Open `PP.xcodeproj` in Xcode.
2. Wait for Swift Package Manager to finish resolving dependencies.
3. Select a simulator or a physical device.
4. Build and run (`Cmd + R`).

## Project Structure

```
PP/
├── Models/        # Data models & shared app state (ObservableObject stores)
├── Services/      # API client
├── Permissions/    # Camera, photo library, and location access
├── StartUp/       # Sign in, sign up, onboarding
├── Home/          # Plant catalog, search, categories
├── Cart/          # Cart & checkout flow
├── MyPlant/       # Personal plant tracker
├── Profile/       # Account management, orders, wishlist, notifications
├── Scan/          # Camera-based plant scanning UI
└── Utilities/     # Shared views, extensions, constants
```

## Troubleshooting

- **"Table doesn't exist" / data not loading** — make sure `docker compose up -d` finished and check `docker ps` shows `pp_mysql` running. If the database existed *before* `schema.sql` was added, run it manually:
  ```bash
  cat schema.sql | docker exec -i pp_mysql mysql -uroot -proot pp_database
  ```
- **Images not loading** — confirm MAMP's Apache is running (`Start Servers` in the MAMP app) and that `baseURL` in `APIService.swift` matches your current local IP (it can change between networks).
- **App can't reach the backend on a physical device** — confirm the device is on the same Wi-Fi network as your Mac.
