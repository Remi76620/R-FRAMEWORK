-- ========================================
-- RM-FRAMEWORK SIMPLE DATABASE SCHEMA
-- ========================================

-- Tables Bancaires
CREATE TABLE `rm_bankaccounts`
(
    `accountId` int(11) NOT NULL,
    `type`      int(11) NOT NULL,
    `owner`     varchar(50)  NOT NULL,
    `label`     varchar(255) NOT NULL,
    `pin`       int(11) NOT NULL,
    `balance`   int(11) NOT NULL,
    `state`     int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `rm_bankaccounts_transaction`
(
    `accountId` int(11) NOT NULL,
    `type`      int(11) NOT NULL,
    `label`     varchar(255) NOT NULL,
    `amount`    int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tables Rangs/Administration
CREATE TABLE `rm_ranks`
(
    `position`  int(11) NOT NULL,
    `id`        varchar(50)  NOT NULL,
    `label`     varchar(255) NOT NULL,
    `weight`    int(11) NOT NULL DEFAULT 0,
    `baseColor` varchar(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `rm_ranks` (`position`, `id`, `label`, `weight`, `baseColor`)
VALUES (4, 'fonda', 'Fondateur', 90000000, '~r~'),
       (1, 'member', 'Membre', 0, '~m~');

CREATE TABLE `rm_ranks_permissions`
(
    `id`         int(50) NOT NULL,
    `rankId`     varchar(50)  NOT NULL,
    `permission` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `rm_ranks_permissions` (`id`, `rankId`, `permission`)
VALUES (1, 'fonda', 'admin.open'),
       (3, 'fonda', 'admin.vehdelete'),
       (4, 'fonda', 'admin.giveitem'),
       (5, 'fonda', 'admin.giveweapon'),
       (6, 'fonda', 'admin.kickplayer'),
       (7, 'fonda', 'admin.removeplayeritem'),
       (8, 'fonda', 'admin.removeplayerweapon'),
       (9, 'fonda', 'admin.vehspawn'),
       (10, 'fonda', 'admin.teleport'),
       (11, 'fonda', 'admin.ban'),
       (12, 'fonda', 'admin.unban'),
       (13, 'fonda', 'admin.banlist'),
       (14, 'fonda', 'admin.noclip'),
       (15, 'fonda', 'admin.report'),
       (16, 'fonda', 'admin.names'),
       (17, 'fonda', 'admin.blips'),
       (18, 'fonda', 'admin.tpwaypoint'),
       (20, 'fonda', 'admin.playerinv'),
       (21, 'fonda', 'admin.organisation'),
       (22, 'fonda', 'admin.openOrgaGrade'),
       (23, 'fonda', 'admin.moveOrgaPoint'),
       (24, 'fonda', 'admin.deleteOrga'),
       (25, 'fonda', 'admin.accessRankManagerAndManageRank'),
       (26, 'fonda', 'admin.createGroup'),
       (79, 'fonda', 'admin.teleport'),
       (80, 'fonda', 'admin.teleport'),
       (85, 'fonda', 'admin.deleteRank'),
       (86, 'fonda', 'admin.playerList'),
       (87, 'fonda', 'admin.deleteGrade'),
       (106, 'fonda', 'admin.createOrganisation');

-- Tables Modération
CREATE TABLE `rm_bans`
(
    `identifier` varchar(55) NOT NULL,
    `name`       varchar(75) NOT NULL,
    `date`       varchar(65) NOT NULL,
    `time`       varchar(65) NOT NULL,
    `reason`     longtext    NOT NULL,
    `moderator`  varchar(75) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index et contraintes
ALTER TABLE `rm_bankaccounts`
    ADD PRIMARY KEY (`accountId`);

ALTER TABLE `rm_ranks`
    ADD PRIMARY KEY (`id`),
    ADD UNIQUE KEY `id` (`id`);

ALTER TABLE `rm_ranks_permissions`
    ADD PRIMARY KEY (`id`),
    ADD UNIQUE KEY `id` (`id`);

ALTER TABLE `rm_bans`
    ADD PRIMARY KEY (`identifier`),
    ADD UNIQUE KEY `identifier` (`identifier`);

ALTER TABLE `rm_ranks_permissions`
    MODIFY `id` int(50) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=107;

COMMIT; 