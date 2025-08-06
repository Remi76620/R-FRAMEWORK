/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

CREATE TABLE `rm_players` (
    `rmId`        int(11) NOT NULL AUTO_INCREMENT,
    `identifier`     varchar(80) NOT NULL,
    `rankId`         varchar(50) NOT NULL DEFAULT 'user',
    `identity`       text        NOT NULL,
    `cash`           int(11) NOT NULL DEFAULT 0,
    `skin`           text        NOT NULL,
    `outfits`        text        NOT NULL,
    `selectedOutfit` varchar(80) NOT NULL DEFAULT 'default',
    `accessories`    text        NOT NULL,
    PRIMARY KEY (`rmId`),
    UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `rm_players_identifiers` (
    `rmId`      int(11) NOT NULL,
    `license`   varchar(150) NOT NULL,
    `steam`     varchar(150) NOT NULL,
    `live`      varchar(150) NOT NULL,
    `xbl`       varchar(150) NOT NULL,
    `discord`   varchar(150) NOT NULL,
    `endpoint`  varchar(150) NOT NULL,
    PRIMARY KEY (`rmId`),
    FOREIGN KEY (`rmId`) REFERENCES `rm_players`(`rmId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `rm_players_positions` (
    `rmId`      int(11) NOT NULL,
    `position`  text NOT NULL,
    PRIMARY KEY (`rmId`),
    FOREIGN KEY (`rmId`) REFERENCES `rm_players`(`rmId`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;