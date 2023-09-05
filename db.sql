--
-- Table structure for table `gangs`
--

CREATE TABLE `gangs` (
  `id` int(11) NOT NULL,
  `gang_name` varchar(255) NOT NULL,
  `money` int(16) NOT NULL DEFAULT 0,
  `black_money` int(16) NOT NULL DEFAULT 0,
  `weapons` longtext NOT NULL DEFAULT '{}',
  `items` longtext NOT NULL DEFAULT '{}',
  `user_limit` tinyint(4) UNSIGNED NOT NULL DEFAULT 4,
  `vehicle_limit` tinyint(3) UNSIGNED NOT NULL DEFAULT 2,
  `create_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gangs_member`
--

CREATE TABLE `gangs_member` (
  `id` int(11) NOT NULL,
  `identifier` varchar(60) NOT NULL,
  `gang_name` varchar(255) NOT NULL,
  `rank_name` varchar(255) NOT NULL,
  `salary` int(16) NOT NULL DEFAULT 0,
  `is_boss` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gang_account`
--

CREATE TABLE `gang_account` (
  `name` varchar(60) NOT NULL,
  `label` varchar(255) NOT NULL,
  `shared` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `gang_account_data`
--

CREATE TABLE `gang_account_data` (
  `id` int(11) NOT NULL,
  `gang_name` varchar(255) DEFAULT NULL,
  `money` double NOT NULL,
  `owner` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------