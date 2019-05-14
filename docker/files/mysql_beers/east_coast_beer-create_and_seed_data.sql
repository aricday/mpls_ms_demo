CREATE DATABASE IF NOT EXISTS `data`;

CREATE TABLE IF NOT EXISTS `data`.`beers` (
	`id` INTEGER(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`brewery` VARCHAR(255),
	`style`	VARCHAR(255),
	`price`	DECIMAL(13, 2),
	`name` VARCHAR(255),
	`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO `data`.`beers`
	(brewery, style, price, name)
VALUES
	('Dogfish Head', 'Strong Ale - American', 5.95, 'American Beauty'),
	('Fat Tire', 'IPA - American', 6.95, 'Single Track IPA'),
	('Surley', 'Strong Ale', 5.95, 'Furious Ale'),
	('Carton Brewing Company', 'Other', 4.85, 'Boat Beer'),
	('Tired Hands Brewing Company', 'Pale Ale - American', 5.99, 'HopHands'),
	('Maine Beer Company', 'Pale Ale - American', 5.50, 'Peeper Ale'),
	('Bell\'s Brewery', 'IPA - American', 6.25, 'Two Hearted Ale'),
	('Fat Head\'s Brewery', 'IPA - American', 5.85, 'Head Hunter IPA')
