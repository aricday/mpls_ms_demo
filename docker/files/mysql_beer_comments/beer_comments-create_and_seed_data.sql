CREATE DATABASE IF NOT EXISTS `data`;

CREATE TABLE `data`.`beer_comments` (
	`id` INTEGER(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`author` VARCHAR(255),
	`beer_id` INTEGER(10) UNSIGNED,
	`description` VARCHAR(255),
	`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	`updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO `data`.`beer_comments`
	(author, beer_id, description)
VALUES
	('John Smith', 1, 'This is my favorite beer'),
	('John Smith', 2, 'This beer is too bitter'),
	('Jane Doe', 1, 'This beer is on the top of my list'),
	('Jane Doe', 4, 'I like to have fish with this beer'),
	('Homer Simpson', 1, 'Ah, good ol’ trustworthy beer. My love for you will never die'),
	('Homer Simpson', 3, 'Here’s to alcohol: the cause of, and solution to, all of life’s problems')



