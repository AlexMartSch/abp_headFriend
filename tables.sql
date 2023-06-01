CREATE TABLE IF NOT EXISTS `abp_friends` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `friend_a` varchar(128) NOT NULL DEFAULT '',
  `friend_b` varchar(128) NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=armscii8 COLLATE=armscii8_bin;

CREATE TABLE IF NOT EXISTS `abp_friends_request` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `friend_a` varchar(128) NOT NULL DEFAULT '',
  `friend_b` varchar(128) NOT NULL DEFAULT '',
  `expires` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=armscii8 COLLATE=armscii8_bin;


