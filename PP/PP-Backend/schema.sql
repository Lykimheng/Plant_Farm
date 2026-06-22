-- Plant Farm (PP) database schema + catalog seed data
-- Run this once after `docker compose up` to create all tables.

CREATE TABLE IF NOT EXISTS users (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    location   VARCHAR(100) DEFAULT '',
    avatar     VARCHAR(255) DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    user_id          INT NOT NULL,
    order_number     VARCHAR(50) NOT NULL UNIQUE,
    status           ENUM('pending','confirmed','preparing','inTransit','delivered','cancelled','rejected') DEFAULT 'pending',
    total            DECIMAL(10,2) NOT NULL,
    delivery_address VARCHAR(255) NOT NULL,
    created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    order_id   INT NOT NULL,
    plant_id   VARCHAR(50) NOT NULL,
    plant_name VARCHAR(100) NOT NULL,
    price      DECIMAL(10,2) NOT NULL,
    quantity   INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notifications (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL,
    title      VARCHAR(150) NOT NULL,
    message    VARCHAR(255) NOT NULL,
    type       VARCHAR(50) NOT NULL,
    is_read    BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS my_plants (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    image         VARCHAR(255) NOT NULL DEFAULT '',
    name          VARCHAR(255) NOT NULL,
    species       VARCHAR(255) NOT NULL DEFAULT '',
    care_level    ENUM('easy', 'moderate', 'expert') NOT NULL DEFAULT 'easy',
    next_watering VARCHAR(100) NOT NULL DEFAULT '',
    sunlight      VARCHAR(100) NOT NULL DEFAULT '',
    added_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS plants (
    id             INT AUTO_INCREMENT PRIMARY KEY,
    image          VARCHAR(255) NOT NULL,
    name           VARCHAR(255) NOT NULL,
    type           VARCHAR(100) NOT NULL,
    type_plant     VARCHAR(50) NOT NULL,
    price          DECIMAL(10,2) NOT NULL,
    description    TEXT NOT NULL,
    rating         DECIMAL(2,1) NOT NULL DEFAULT 0,
    counting       INT NOT NULL DEFAULT 0,
    is_popular     TINYINT(1) NOT NULL DEFAULT 0,
    discount_price DECIMAL(10,2) DEFAULT NULL
);

-- Catalog seed data (only inserted if the table is empty, so re-running this
-- file is safe and won't duplicate rows on an already-seeded database)
INSERT INTO plants (image, name, type, type_plant, price, description, rating, counting, is_popular, discount_price)
SELECT * FROM (SELECT
    'Cactus.png' AS image, 'Cactus' AS name, 'Indoor Plant' AS type, 'indoorPlant' AS type_plant,
    5.00 AS price, 'Adapted to arid environments...' AS description, 5.0 AS rating, 39 AS counting, 1 AS is_popular, 3.50 AS discount_price
    UNION ALL SELECT 'Cactus.png','Cactus','Indoor Plant','indoorPlant',5.00,'Adapted to arid environments...',5.0,39,0,NULL
    UNION ALL SELECT 'Cactus.png','Cactus','Indoor Plant','indoorPlant',5.00,'Adapted to arid environments...',5.0,39,0,NULL
    UNION ALL SELECT 'Cactus.png','Cactus','Indoor Plant','indoorPlant',5.00,'Adapted to arid environments...',5.0,39,0,NULL
    UNION ALL SELECT 'Cactus.png','Cactus','Indoor Plant','indoorPlant',5.00,'Adapted to arid environments...',5.0,39,0,NULL
    UNION ALL SELECT 'Cactus.png','Cactus','Indoor Plant','indoorPlant',5.00,'Adapted to arid environments...',5.0,39,0,NULL
    UNION ALL SELECT 'Showy Spindletree Euonymus japonicus.png','Showy Spindletree Euonymus japonicus','Outdoor Plant','outdoorPlant',7.00,'Aromatic flowering plant...',4.9,45,1,5.00
    UNION ALL SELECT 'Showy Spindletree Euonymus japonicus.png','Showy Spindletree Euonymus japonicus','Outdoor Plant','outdoorPlant',7.00,'Aromatic flowering plant...',4.9,45,0,6.00
    UNION ALL SELECT 'Showy Spindletree Euonymus japonicus.png','Showy Spindletree Euonymus japonicus','Outdoor Plant','outdoorPlant',7.00,'Aromatic flowering plant...',4.9,45,0,NULL
    UNION ALL SELECT 'Showy Spindletree Euonymus japonicus.png','Showy Spindletree Euonymus japonicus','Outdoor Plant','outdoorPlant',7.00,'Aromatic flowering plant...',4.9,45,0,NULL
    UNION ALL SELECT 'Showy Spindletree Euonymus japonicus.png','Showy Spindletree Euonymus japonicus','Outdoor Plant','outdoorPlant',7.00,'Aromatic flowering plant...',4.9,45,0,NULL
    UNION ALL SELECT 'Maianthemum.png','Maianthemum','Aquatic Plant','aquaticPlant',9.00,'Sacred aquatic flower...',4.9,22,1,NULL
    UNION ALL SELECT 'Maianthemum.png','Maianthemum','Aquatic Plant','aquaticPlant',9.00,'Sacred aquatic flower...',4.9,22,0,5.00
    UNION ALL SELECT 'Maianthemum.png','Maianthemum','Aquatic Plant','aquaticPlant',9.00,'Sacred aquatic flower...',4.9,22,0,NULL
    UNION ALL SELECT 'Maianthemum.png','Maianthemum','Aquatic Plant','aquaticPlant',9.00,'Sacred aquatic flower...',4.9,22,0,NULL
    UNION ALL SELECT 'Maianthemum.png','Maianthemum','Aquatic Plant','aquaticPlant',9.00,'Sacred aquatic flower...',4.9,22,0,NULL
    UNION ALL SELECT 'Maianthemum.png','Maianthemum','Aquatic Plant','aquaticPlant',9.00,'Sacred aquatic flower...',4.9,22,0,NULL
    UNION ALL SELECT 'Mango.png','Mango','Big Tree','bigTree',45.00,'Majestic deciduous tree...',5.0,12,1,10.00
    UNION ALL SELECT 'Mango.png','Mango','Big Tree','bigTree',45.00,'Majestic deciduous tree...',5.0,12,0,12.00
    UNION ALL SELECT 'Mango.png','Mango','Big Tree','bigTree',45.00,'Majestic deciduous tree...',5.0,12,0,NULL
    UNION ALL SELECT 'Mango.png','Mango','Big Tree','bigTree',45.00,'Majestic deciduous tree...',5.0,12,0,NULL
    UNION ALL SELECT 'Mango.png','Mango','Big Tree','bigTree',45.00,'Majestic deciduous tree...',5.0,12,0,NULL
    UNION ALL SELECT 'Mango.png','Mango','Big Tree','bigTree',45.00,'Majestic deciduous tree...',5.0,12,0,NULL
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM plants LIMIT 1);
