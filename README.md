# Plant Farm (PP)

A native iOS plant shopping and plant-care companion app, built with SwiftUI (MVVM) and a custom PHP + MySQL backend.

## Tech Stack

- iOS App: Swift, SwiftUI, MVVM, Combine, async/await networking
- Backend: PHP REST API, MySQL (via Docker)
- Local web server: MAMP (serves the PHP API over Apache)

## Prerequisites

Install these before setting up the project:

- [Xcode](https://developer.apple.com/xcode/) (latest version recommended)
- [MAMP](https://www.mamp.info/) — serves the PHP backend
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — runs the MySQL database

## Dependencies

- [UIColor-Hex-Swift](https://github.com/yeahdongcn/UIColor-Hex-Swift)
- [Google Maps iOS SDK](https://github.com/googlemaps/ios-maps-sdk)

If Xcode doesn't fetch them automatically, go to File -> Packages -> Resolve Package Versions.

## Installation

### 1. Set up the backend

1. Copy the `PP-Backend` folder into MAMP's `htdocs` directory
2. Open MAMP and click Start Servers.
3. Open PP-Backend in Visual Studio then in a terminal:
```bash
cd /Applications/MAMP/htdocs/PP-Backend
docker compose up -d
```
4. vertify the backend is working: curl ```http://localhost:8888/PP-Backend/api/plants.php```
   
### 2. Configure the app to find your backend

1. Check your IP: ```ipconfig getifaddr en0``` then copy them
2. Then open PP/Frontend/Sservices/APIService.swift and update the baseURL
 
### 3. Run the iOS app
1. Open PP.xcodeproj in Xcode.
2. Wait for Swift Package Manager to finish resolving dependencies.
3. Select a simulator or a physical device.
4. Build and run (Cmd + R)

