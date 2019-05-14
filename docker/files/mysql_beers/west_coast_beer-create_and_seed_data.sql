CREATE DATABASE IF NOT EXISTS `data`;

CREATE TABLE IF NOT EXISTS `data`.`beers` (
	`id` INTEGER(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`brewery` VARCHAR(255),
	`style`	VARCHAR(255),
	`price`	DECIMAL(13, 2),
	`name`	VARCHAR(255),
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO `data`.`beers`
	(brewery, style, price, name)
VALUES
	('New Belgium Brewing', 'Red Ale - American Amber / Red', 4.50, 'Fat Tire'),
	('Lagunitas Brewing Company', 'Pale Wheat Ale - American', 6.50, 'Little Sumpin'),
	('Lagunitas Brewing Company', 'IPA - Imperical / Double', 6.90, 'Lagunitas IPA'),
	('Ballast Point Brewing Company', 'IPA - American', 6.95, 'Grapefruit Sculpin'),
	('Ballast Point Brewing Company', 'IPA - American', 6.95, 'Pineapple Sculpin'),
	('Russian River Brewing Company', 'IPA - Imperial / Double', 6.95, 'Pliny the Elder'),
	('Aric Brewing', 'Hefeweizen', 5.95, 'AricDay Hefe'),
