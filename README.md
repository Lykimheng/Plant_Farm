# Plant Farm

A native iOS plant shopping and plant-care companion app, built with SwiftUI (MVVM), backed by a Laravel REST API and a Filament admin dashboard.

## Tech Stack

- **iOS App:** Swift, SwiftUI, MVVM, Combine, async/await networking
- **Plant recognition & health check:** two Core ML image classifiers (Create ML) run on-device through Vision
- **Backend:** Laravel 13 (PHP 8.4) REST API
- **Admin dashboard:** Filament 5
- **Database:** MySQL 8 (via Docker), phpMyAdmin

## Prerequisites

- [Xcode](https://developer.apple.com/xcode/) (latest version recommended)
- [PHP 8.2+](https://www.php.net/) and [Composer](https://getcomposer.org/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) — runs MySQL

## Dependencies

**iOS** — resolved automatically by Swift Package Manager on first open
(File → Packages → Resolve Package Versions if it doesn't):

- [UIColor-Hex-Swift](https://github.com/yeahdongcn/UIColor-Hex-Swift)
- [Google Maps iOS SDK](https://github.com/googlemaps/ios-maps-sdk)

**Backend** — installed via `composer install` (see below).

## Installation

### 1. Start the database

```bash
cd PP-Backend
docker compose up -d
```

Starts MySQL on port `3307` and phpMyAdmin on port `8080`.

### 2. Set up the Laravel backend

```bash
cd PP-Backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
```

Migrations create every table and are safe to re-run — they skip anything that
already exists, so an existing database keeps its data.

Seed the plant catalog (only needed on a fresh database):

```bash
php artisan db:seed --class=PlantSeeder
```

### 3. Create an admin account

```bash
php artisan make:filament-user
```

Then mark that user as an admin so they can open the dashboard:

```bash
php artisan tinker --execute="App\Models\User::where('email','YOUR_EMAIL')->update(['is_admin' => true]);"
```

### 4. Run the API server

```bash
php artisan serve --host=0.0.0.0 --port=8001
```

`--host=0.0.0.0` is required for a physical iPhone to reach it.

Verify:

```bash
curl http://localhost:8001/api/plants
```

### 5. Point the iOS app at your machine

Find your Mac's LAN IP:

```bash
ipconfig getifaddr en0
```

Open [`PP/Frontend/Core/Networking/Endpoint.swift`](PP/Frontend/Core/Networking/Endpoint.swift) and set the
fallback host:

```swift
return URL(string: "http://<YOUR_LOCAL_IP>:8001")!
```

You can also override it at launch without editing code — handy when switching
between the simulator and a device. In Xcode, *Product → Scheme → Edit Scheme →
Run → Arguments*, add:

```
-APIBaseURL http://<YOUR_LOCAL_IP>:8001
```

(or set an `API_BASE_URL` environment variable to the same value).

> Your device/simulator must be on the **same Wi-Fi network** as your Mac.

### 6. Run the iOS app

Open `PP.xcodeproj`, pick a simulator or device, and press `Cmd + R`.

## Plant recognition & health check (Scan tab)

The Scan tab identifies a plant from the camera or a library photo, checks it
for common problems, and suggests matching products from the shop — all
on-device. Two Create ML image classifiers in `PP/Frontend/ML/` do the work
(each ~70 KB; they sit on top of iOS's built-in scenePrint feature extractor,
and Xcode compiles them into the app automatically):

| Model | Answers | Trained on | Labels |
|---|---|---|---|
| `PlantClassifier.mlmodel` | Which plant is this? | `PlantData/` | aloe vera, cactus, chinese evergreen, fiddle leaf fig, lucky bamboo, mango tree, monstera, peace lily, pothos, snake plant, spider plant, ZZ plant |
| `PlantHealthClassifier.mlmodel` | Does it look unwell? | `PlantSymptoms/` | healthy, yellow leaves, brown tips, leaf spots, wilting, pests, powdery mildew |

**Code:** [`ImageClassifier.swift`](PP/Frontend/Features/Scan/ImageClassifier.swift)
loads either model and runs it through Vision; [`PlantSpecies.swift`](PP/Frontend/Features/Scan/PlantSpecies.swift)
and [`PlantSymptom.swift`](PP/Frontend/Features/Scan/PlantSymptom.swift) map
each label to display text — care tips and catalog keywords for species
(`PlantsStore.plants(matching:)`), likely cause and what to do for symptoms;
[`ScanViewModel.swift`](PP/Frontend/Features/Scan/ScanViewModel.swift) runs
both models on the photo; [`ScanView.swift`](PP/Frontend/Features/Scan/ScanView.swift)
shows the top species candidates, the health verdict, care info and shop matches.

The result sheet always presents a *ranked guess*, never a verdict: a photo of
something outside the known classes still gets scores, so the sheet shows the
alternatives and flags low confidence. The health check is worded as a
"possible issue" with the usual cause and fix, not a diagnosis. If the health
model is missing from the bundle the card is simply not shown.

The health model is trained on real photos (about 5 per plant per symptom,
plus the 180 PlantData photos as `healthy`) and scores ~75–78% on held-out
photos. `wilting` has no photos yet, so it is not in the model. More real
photos per symptom is the way to improve it — see below.

> **Simulator:** Create ML image classifiers can't run in the iOS Simulator
> (Vision's scenePrint engine fails with "Failed to create espresso context").
> The Scan tab shows a message saying so; test recognition on a real iPhone.

### Training data layout

The label is always the **top-level folder name**, and it must match a raw value
of `PlantSpecies` / `PlantSymptom` in the app. No annotation file is needed;
Create ML labels by folder.

```
PlantData/                    one folder per species
├── aloe_vera/       aloe_vera_01.jpg …
├── cactus/
├── …
└── zz_plant/

PlantSymptoms/                one folder per symptom, sub-folders per plant
├── healthy/
│   ├── monstera/    …jpg
│   └── snake_plant/ …jpg
├── yellow_leaves/
│   ├── monstera/
│   └── pothos/
├── brown_tips/  leaf_spots/  wilting/  pests/  powdery_mildew/
└── README.txt
```

Symptoms are pooled across plants on purpose: yellowing, spots or mildew look
much the same on any houseplant, so one folder of "yellow_leaves" photos from
many plants teaches the model far more than a dozen tiny per-plant sets would.
The plant sub-folders are only there to keep photos organised — add any plant,
including ones the species model doesn't know. Aim for 20+ real photos per
symptom, from several plants, close enough to see the leaf surface.

### Retraining

From the repo root (about ten seconds each):

```bash
swift TrainPlantClassifier.swift /path/to/PlantData
```

```bash
swift TrainPlantClassifier.swift /path/to/PlantSymptoms
```

The script holds back every 5th photo of each class, prints the accuracy on
those unseen photos (and which classes were confused), then retrains on
everything and writes the model straight into `PP/Frontend/ML/` — the next
build of the app uses it. It also warns about synthetic `sample_` photos and
lists folders that have no photos yet (those classes are simply left out until
photos arrive). A model is a frozen file: it doesn't learn from new photos on
its own, so re-run the command whenever you add or change training photos.

The species model scores ~83–92% on held-out photos with 15 photos per species;
more photos per species — especially of the leafy green ones that get confused
(monstera / pothos / fiddle leaf fig) — is the most effective way to improve it.
The health model scores ~75–78%; its confusions are leaf spots vs pests and
yellowing vs brown tips, so close-up photos of those help most. The script
picks augmentation per dataset (none for PlantData's uniform studio shots,
crop + flip + exposure for PlantSymptoms' varied photos) — both were measured.

### Using the Create ML app instead

File → New Project → **Image Classification** (not *Multi-Label* — that
template wants loose images plus an `annotations.json` and won't accept a
folder of sub-folders). Drag the photo folder onto *Training Data*, set
Feature Extractor to *Image Feature Print V2*, leave augmentations off, press
Train, then *Output → Get* and save over the matching file in
`PP/Frontend/ML/`.

`PlantData` can be dragged in as-is. The Create ML app only looks at photos
**directly inside** each class folder, so `PlantSymptoms` (which has plant
sub-folders) needs a flattened copy first:

```bash
swift TrainPlantClassifier.swift --flatten /path/to/PlantSymptoms
```

That writes `PlantSymptoms-for-CreateML` next to it; drag that one in.

### Looking at a trained model

The Create ML app can't open a `.mlmodel` — it only produces them. Xcode can:
click either model in `PP/Frontend/ML/` to see its metadata and class labels,
and use the **Preview** tab to drop in photos and watch the predictions. That
runs on the Mac, so it's the quickest way to try photos without a phone.

To add a species: add its folder of photos, retrain, and add a case to
`PlantSpecies` with its display name, care tips and catalog keywords. To add a
symptom: same, with a case in `PlantSymptom` (display name, likely cause, what
to do).

## Admin Dashboard

Open **http://localhost:8001/admin** and sign in with your admin account.

| Section | What you can do |
|---|---|
| **Dashboard** | Revenue (total and this month), order count with pending backlog, customer count, catalog size and average rating. Plus a 30-day revenue line chart, an orders-by-status doughnut, and a best-sellers table. Cancelled and rejected orders are excluded from revenue. |
| **Plants** | Add, edit, and delete catalog products. Upload a product image, pick a category, set price/discount, and toggle "Show in Popular". Changes appear in the app on next refresh. |
| **Orders** | Review customer orders and their line items, and change order status. Setting a status to Confirmed / Cancelled / Rejected / Delivered automatically sends the customer an in-app notification. |
| **Reviews** | Moderate customer reviews — hide or unhide them. Hidden reviews disappear from the app and stop counting toward a plant's rating, but the text is kept and the author can still see it. Admins can't author or edit review text. |
| **Users** | View registered customers and their order counts. Create a new admin, or grant/revoke admin access with the "Admin access" toggle. |

Uploaded product images are written to `public/uploads/plants/` and served at
`/uploads/plants/<filename>`.

### Managing your own admin account

Click your avatar (top right) → **Profile** to change your own name, email, and
password. Only accounts with `is_admin = 1` can sign in to the panel at all.

To add another admin: **Users → New user**, fill in name/email/password and
switch on **Admin access**.

## Where data lives

Two separate places — a backup needs **both**:

| What | Where | Notes |
|---|---|---|
| Database (users, plants, orders, notifications) | Docker volume `pp-backend_pp_mysql_data` | Managed by Docker, not a folder you can browse on macOS. Survives `docker compose down`, but **`docker compose down -v` deletes it permanently.** |
| Images (plants, banners, categories, avatars) | `PP-Backend/public/uploads/` | Ordinary files on disk. Deleting the project folder deletes them. |

Because the two are independent, restoring one without the other leaves broken
image links (a plant row pointing at a file that no longer exists, or vice versa).

Back up the database:

```bash
docker exec pp_mysql mysqldump -uroot -proot pp_database > backup.sql
```

Restore it:

```bash
cat backup.sql | docker exec -i pp_mysql mysql -uroot -proot pp_database
```

> `docker-compose.yml` pins `name: pp-backend` so the volume name never changes.
> Without that, running compose from a renamed folder would create a new empty
> database and look like all the data disappeared.

## API Endpoints

All under `/api`. The old `<name>.php` paths still resolve, so older builds of
the app keep working.

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/register`, `/login`, `/forgot_password` | Authentication |
| `PUT` | `/update_profile` | Change display name |
| `POST` | `/upload_avatar` | Upload profile photo (base64) |
| `GET` | `/plants` | Plant catalog |
| `GET` `POST` `DELETE` | `/my_plants` | Personal plant tracker |
| `GET` `POST` `PUT` | `/orders` | Order history, checkout, status updates |
| `GET` `PUT` `DELETE` | `/notifications` | Notifications, mark read, clear |
| `GET` `POST` `DELETE` | `/reviews` | Plant reviews — read, post/edit, delete own |

Reviews are one-per-customer-per-plant: posting again edits the existing one
rather than stacking. A plant's `rating` and `counting` are a cache recomputed
from its visible reviews on every change, so they can't drift.

## Project Structure

```
Plant_Farm/
├── PP.xcodeproj
├── TrainPlantClassifier.swift   # Retrains either classifier (see above)
├── PP/
│   └── Frontend/            # SwiftUI app source
│       ├── App/             # Entry point, root view, tab shell, router
│       ├── Core/
│       │   ├── DesignSystem/    # Theme tokens, button styles, icon names
│       │   ├── Extensions/      # Small shared helpers
│       │   └── Networking/      # APIClient, endpoints, error type
│       ├── ML/              # PlantClassifier + PlantHealthClassifier (Create ML models)
│       ├── Models/          # Domain types + DTO/ (wire formats)
│       ├── Stores/          # ObservableObject app state (cart, orders, …)
│       ├── Components/      # Reusable views shared across features
│       ├── Features/        # One folder per screen area
│       │   ├── Auth/            # Sign in, sign up, reset password
│       │   ├── Home/            # Catalog, search, categories
│       │   ├── PlantDetail/     # Product page + reviews
│       │   ├── Cart/            # Cart
│       │   ├── Checkout/        # Checkout + order confirmation
│       │   ├── MyPlants/        # Personal plant tracker
│       │   ├── Scan/            # Camera capture, Core ML plant identification, results
│       │   └── Profile/         # Account, orders, wishlist, notifications
│       └── Platform/        # Camera, photo library, location, MapKit wrappers
└── PP-Backend/              # Laravel API + Filament admin
    ├── app/
    │   ├── Http/Controllers/Api/   # API endpoints
    │   ├── Models/                 # Eloquent models
    │   ├── Observers/              # Order → notification rules
    │   └── Filament/Resources/     # Admin dashboard
    ├── database/migrations/
    ├── public/uploads/             # Plant, banner, category, avatar images
    ├── routes/api.php
    └── docker-compose.yml
```

## Troubleshooting

- **App shows no plants** — confirm `php artisan serve` is running and that
  `baseURL` in `APIService.swift` matches your current LAN IP (it changes
  between networks).
- **Database connection refused** — check `docker ps` shows `pp_mysql` running,
  and that `.env` has `DB_PORT=3307`.
- **Physical device can't connect** — the server must be started with
  `--host=0.0.0.0`, and the phone must be on the same Wi-Fi.
- **Admin login says access denied** — the account needs `is_admin = 1`
  (see step 3).
- **Images 404 after adding a product** — confirm the file landed in
  `PP-Backend/public/uploads/plants/`.
