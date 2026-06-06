-- MySQL dump 10.13  Distrib 8.0.42, for Linux (x86_64)
--
-- Host: localhost    Database: audio_supervision_db
-- ------------------------------------------------------
-- Server version	8.0.42-0ubuntu0.20.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `api_player`
--

DROP TABLE IF EXISTS `api_player`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_player` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `status` varchar(10) NOT NULL,
  `last_ping` datetime(6) DEFAULT NULL,
  `current_track` varchar(255) DEFAULT NULL,
  `volume` int NOT NULL,
  `last_alert_key` varchar(50) DEFAULT NULL,
  `required_playlist_id` bigint DEFAULT NULL,
  `required_track_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `fk_player_playlist` (`required_playlist_id`),
  KEY `fk_player_track` (`required_track_id`),
  CONSTRAINT `fk_player_playlist` FOREIGN KEY (`required_playlist_id`) REFERENCES `api_playlist` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_player_track` FOREIGN KEY (`required_track_id`) REFERENCES `api_track` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_player`
--

LOCK TABLES `api_player` WRITE;
/*!40000 ALTER TABLE `api_player` DISABLE KEYS */;
INSERT INTO `api_player` VALUES (1,'Lecteur_Gare_nord','OFFLINE','2026-06-04 21:46:45.122735','Mr Shyne - VAS-Y',42,'Jeudi_23:34',NULL,NULL),(2,'Lecteur_Gare_Grenoble','OFFLINE','2026-06-05 12:29:03.250167','Mr Shyne - VAS-Y',60,'Vendredi_14:12',3,8),(3,'Lecteur_Gare_Sud','OFFLINE','2026-06-04 21:46:45.098910','Maitre Gims',1,NULL,NULL,NULL),(4,'Lecteur_Gare_Lyon','OFFLINE','2026-06-04 21:46:44.984225','',60,'Jeudi_23:37',NULL,NULL);
/*!40000 ALTER TABLE `api_player` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_playlist`
--

DROP TABLE IF EXISTS `api_playlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_playlist` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_playlist`
--

LOCK TABLES `api_playlist` WRITE;
/*!40000 ALTER TABLE `api_playlist` DISABLE KEYS */;
INSERT INTO `api_playlist` VALUES (6,'Annonce_SNCF_Denier_Metro'),(7,'Annonce_SNCF_Interdit_Fumé'),(8,'Annonce_SNCF_Train_sans_arret'),(5,'Annonce_SNCF_Train_Suprimé'),(3,'Playlist Matin'),(9,'Playlist Soir');
/*!40000 ALTER TABLE `api_playlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_playlisttrack`
--

DROP TABLE IF EXISTS `api_playlisttrack`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_playlisttrack` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order` int unsigned NOT NULL,
  `playlist_id` bigint NOT NULL,
  `track_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `api_playlisttrack_chk_1` CHECK ((`order` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_playlisttrack`
--

LOCK TABLES `api_playlisttrack` WRITE;
/*!40000 ALTER TABLE `api_playlisttrack` DISABLE KEYS */;
INSERT INTO `api_playlisttrack` VALUES (17,1,3,6),(18,2,3,8),(19,3,3,7),(20,1,9,5),(21,2,9,4),(22,3,9,8),(23,1,6,12),(24,1,7,9),(25,1,8,10),(26,1,5,11);
/*!40000 ALTER TABLE `api_playlisttrack` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_schedule`
--

DROP TABLE IF EXISTS `api_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_schedule` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `day_of_week` int NOT NULL,
  `start_time` time(6) NOT NULL,
  `volume` int NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `player_id` bigint NOT NULL,
  `playlist_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `api_schedule_player_id_f3a40260_fk_api_player_id` (`player_id`),
  KEY `fk_schedule_playlist` (`playlist_id`),
  CONSTRAINT `api_schedule_player_id_f3a40260_fk_api_player_id` FOREIGN KEY (`player_id`) REFERENCES `api_player` (`id`),
  CONSTRAINT `fk_schedule_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `api_playlist` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_schedule`
--

LOCK TABLES `api_schedule` WRITE;
/*!40000 ALTER TABLE `api_schedule` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_schedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_scheduledalert`
--

DROP TABLE IF EXISTS `api_scheduledalert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_scheduledalert` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `day` varchar(20) NOT NULL,
  `time` time(6) NOT NULL,
  `site` varchar(100) NOT NULL,
  `volume` int NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `playlist_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_alert_playlist` (`playlist_id`),
  CONSTRAINT `fk_alert_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `api_playlist` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_scheduledalert`
--

LOCK TABLES `api_scheduledalert` WRITE;
/*!40000 ALTER TABLE `api_scheduledalert` DISABLE KEYS */;
INSERT INTO `api_scheduledalert` VALUES (9,'Samedi','23:49:40.000000','Lecteur_Gare_nord',60,0,5),(21,'Vendredi','09:43:00.000000','Lecteur_Gare_Grenoble',60,0,5),(22,'Vendredi','22:06:00.000000','Lecteur_Gare_Grenoble',60,1,5),(23,'Vendredi','10:07:00.000000','Lecteur_Gare_Grenoble',60,0,5),(24,'Vendredi','14:12:00.000000','Lecteur_Gare_Grenoble',60,0,5);
/*!40000 ALTER TABLE `api_scheduledalert` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_track`
--

DROP TABLE IF EXISTS `api_track`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_track` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `audio_file` varchar(100) NOT NULL,
  `uploaded_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_track`
--

LOCK TABLES `api_track` WRITE;
/*!40000 ALTER TABLE `api_track` DISABLE KEYS */;
INSERT INTO `api_track` VALUES (4,'Ambiance','tracks/ambiance.mp3','2026-05-30 14:57:44.911200'),(5,'Douce','tracks/douce.mp3','2026-05-30 14:57:44.915414'),(6,'Zen','tracks/zen.mp3','2026-05-30 14:57:44.921295'),(7,'Maitre Gims','tracks/Maître_Gims.mp3','2026-05-30 14:57:44.924414'),(8,'Mr Shyne - VAS-Y','tracks/Mr_Shyne_ft_Fanicko_-_VAS-Y_Official_video.mp3','2026-05-30 14:57:44.928715'),(9,'Interdiction Fumer','tracks/Annonce_SNCF_Interdiction_de_fumer_dans_la_gare.mp3','2026-05-30 14:57:44.931400'),(10,'Passage Train','tracks/Annonce_SNCF_Passage_dun_train.mp3','2026-05-30 14:57:44.934839'),(11,'Train Supprime','tracks/Annonce_SNCF_Train_supprimé1.mp3','2026-05-30 14:57:44.938253'),(12,'Dernier Metro','tracks/Dernier_métro_annonce_RATP_Ligne_14.mp3','2026-05-30 14:57:44.941186'),(13,'box','tracks/mp3_NRomLat','2026-05-30 15:10:35.680479');
/*!40000 ALTER TABLE `api_track` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add user',4,'add_user'),(14,'Can change user',4,'change_user'),(15,'Can delete user',4,'delete_user'),(16,'Can view user',4,'view_user'),(17,'Can add content type',5,'add_contenttype'),(18,'Can change content type',5,'change_contenttype'),(19,'Can delete content type',5,'delete_contenttype'),(20,'Can view content type',5,'view_contenttype'),(21,'Can add session',6,'add_session'),(22,'Can change session',6,'change_session'),(23,'Can delete session',6,'delete_session'),(24,'Can view session',6,'view_session'),(25,'Can add player',7,'add_player'),(26,'Can change player',7,'change_player'),(27,'Can delete player',7,'delete_player'),(28,'Can view player',7,'view_player'),(29,'Can add track',8,'add_track'),(30,'Can change track',8,'change_track'),(31,'Can delete track',8,'delete_track'),(32,'Can view track',8,'view_track'),(33,'Can add scheduled alert',9,'add_scheduledalert'),(34,'Can change scheduled alert',9,'change_scheduledalert'),(35,'Can delete scheduled alert',9,'delete_scheduledalert'),(36,'Can view scheduled alert',9,'view_scheduledalert'),(37,'Can add schedule',10,'add_schedule'),(38,'Can change schedule',10,'change_schedule'),(39,'Can delete schedule',10,'delete_schedule'),(40,'Can view schedule',10,'view_schedule'),(41,'Can add playlist',11,'add_playlist'),(42,'Can change playlist',11,'change_playlist'),(43,'Can delete playlist',11,'delete_playlist'),(44,'Can view playlist',11,'view_playlist'),(45,'Can add playlist track',12,'add_playlisttrack'),(46,'Can change playlist track',12,'change_playlisttrack'),(47,'Can delete playlist track',12,'delete_playlisttrack'),(48,'Can view playlist track',12,'view_playlisttrack');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user`
--

DROP TABLE IF EXISTS `auth_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user`
--

LOCK TABLES `auth_user` WRITE;
/*!40000 ALTER TABLE `auth_user` DISABLE KEYS */;
INSERT INTO `auth_user` VALUES (1,'pbkdf2_sha256$600000$pfOSZifjTQBAG7FpRiAGbj$qbEuX78+ilSV+WR3M1JOLa+yNFCXza7K04qwrFOHaHA=','2026-05-24 20:53:11.910568',1,'mathieu','','','elnzoya77@gmail.com',1,1,'2026-04-20 18:15:29.713322');
/*!40000 ALTER TABLE `auth_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_groups`
--

DROP TABLE IF EXISTS `auth_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`),
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_groups`
--

LOCK TABLES `auth_user_groups` WRITE;
/*!40000 ALTER TABLE `auth_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_user_user_permissions`
--

DROP TABLE IF EXISTS `auth_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_user_user_permissions`
--

LOCK TABLES `auth_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `auth_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=195 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
INSERT INTO `django_admin_log` VALUES (1,'2026-04-27 15:04:38.088464','1','test1',1,'[{\"added\": {}}]',8,1),(2,'2026-04-27 16:09:52.425621','1','test2',1,'[{\"added\": {}}]',8,1),(3,'2026-04-27 16:13:10.614776','2','zen',1,'[{\"added\": {}}]',8,1),(4,'2026-04-27 16:13:28.946259','1','test2',3,'',8,1),(5,'2026-04-27 16:14:13.639158','2','zen',2,'[]',8,1),(6,'2026-04-27 16:26:22.430431','3','douce',1,'[{\"added\": {}}]',8,1),(7,'2026-04-27 16:40:01.547282','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Required track\"]}}]',7,1),(8,'2026-04-27 16:41:05.189984','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Current track\"]}}]',7,1),(9,'2026-04-27 16:46:51.616602','2','Lecteur_Gare_Sud (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Current track\", \"Required track\"]}}]',7,1),(10,'2026-04-27 16:53:04.945664','4','ambiance',1,'[{\"added\": {}}]',8,1),(11,'2026-04-27 16:53:21.307365','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Required track\"]}}]',7,1),(12,'2026-04-27 16:55:39.930557','5','Lecteur_Gare_Grenoble (ONLINE)',1,'[{\"added\": {}}]',7,1),(13,'2026-04-27 16:59:47.250726','5','Lecteur_Gare_Grenoble (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Required track\"]}}]',7,1),(14,'2026-04-27 21:00:13.057745','1','ambiance',1,'[{\"added\": {}}]',8,1),(15,'2026-04-27 21:00:29.333388','2','douce',1,'[{\"added\": {}}]',8,1),(16,'2026-04-27 21:00:45.864009','3','zen',1,'[{\"added\": {}}]',8,1),(17,'2026-04-27 21:02:16.388844','3','Lecteur_Gare_Grenoble (ONLINE)',1,'[{\"added\": {}}]',7,1),(18,'2026-04-27 21:04:13.202648','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Current track\", \"Volume\", \"Required track\"]}}]',7,1),(19,'2026-04-27 21:04:49.286238','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Volume\"]}}]',7,1),(20,'2026-04-27 21:33:53.120445','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Volume\"]}}]',7,1),(21,'2026-04-27 21:36:00.455620','3','Lecteur_Gare_Grenoble (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Volume\"]}}]',7,1),(22,'2026-04-27 21:39:30.788068','2','Lecteur_Gare_Sud (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Required track\"]}}]',7,1),(23,'2026-04-27 21:46:19.380399','2','Lecteur_Gare_Sud (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Current track\"]}}]',7,1),(24,'2026-04-27 21:46:35.199690','2','Lecteur_Gare_Sud (ONLINE)',2,'[]',7,1),(25,'2026-04-27 21:49:18.108132','2','Lecteur_Gare_Sud (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Current track\"]}}]',7,1),(26,'2026-04-27 21:49:27.687143','2','Lecteur_Gare_Sud (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Current track\"]}}]',7,1),(27,'2026-04-27 22:01:56.186987','3','Lecteur_Gare_Grenoble (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Volume\"]}}]',7,1),(28,'2026-04-27 22:05:02.359389','2','Lecteur_Gare_Sud (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Required track\"]}}]',7,1),(29,'2026-04-27 22:05:19.990450','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Required track\"]}}]',7,1),(30,'2026-04-27 22:05:29.273236','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Required track\"]}}]',7,1),(31,'2026-04-27 22:18:36.638456','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Volume\"]}}]',7,1),(32,'2026-04-27 22:20:11.374858','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Current track\"]}}]',7,1),(33,'2026-04-27 22:21:21.946929','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Current track\"]}}]',7,1),(34,'2026-04-27 22:21:26.427007','1','Lecteur_Gare_nord (ONLINE)',2,'[]',7,1),(35,'2026-04-27 22:22:12.349269','1','Lecteur_Gare_nord (ONLINE)',2,'[{\"changed\": {\"fields\": [\"Current track\"]}}]',7,1),(36,'2026-04-28 01:15:54.066252','1','Lecteur_Gare_nord',2,'[]',7,1),(37,'2026-04-28 09:38:38.871997','1','Lecteur_Gare_nord',2,'[]',7,1),(38,'2026-05-10 11:51:46.488962','4','Lecteur_Gare_Lyon',2,'[{\"changed\": {\"fields\": [\"Name\"]}}]',7,1),(39,'2026-05-10 12:02:37.092057','5','[\'Lecteur_Gare_Nante',2,'[{\"changed\": {\"fields\": [\"Name\"]}}]',7,1),(40,'2026-05-10 12:03:12.285469','5','Lecteur_Gare_Nante',2,'[{\"changed\": {\"fields\": [\"Name\"]}}]',7,1),(41,'2026-05-14 16:59:54.000055','1','Vendredi à 18:49:16 - Toutes les gares',1,'[{\"added\": {}}]',9,1),(42,'2026-05-14 17:03:53.602433','1','Vendredi à 18:49:16 - Toutes les gares',3,'',9,1),(43,'2026-05-14 17:04:52.825751','2','Jeudi à 19:06:01 - Lecteur_Gare_nord',1,'[{\"added\": {}}]',9,1),(44,'2026-05-14 17:07:41.544045','2','Jeudi à 19:08:01 - Lecteur_Gare_nord',2,'[{\"changed\": {\"fields\": [\"Time\"]}}]',9,1),(45,'2026-05-14 17:08:57.127298','2','Jeudi à 19:09:01 - Lecteur_Gare_nord',2,'[{\"changed\": {\"fields\": [\"Time\", \"Track\"]}}]',9,1),(46,'2026-05-14 17:22:38.631905','2','Jeudi à 19:09:01 - Lecteur_Gare_nord',3,'',9,1),(47,'2026-05-14 17:32:26.769443','9','Jeudi à 19:33:01 - Lecteur_Gare_nord',1,'[{\"added\": {}}]',9,1),(48,'2026-05-15 13:45:48.174872','4','Train  supprimé',1,'[{\"added\": {}}]',8,1),(49,'2026-05-15 13:45:53.369477','4','Train  supprimé',2,'[]',8,1),(50,'2026-05-15 13:46:41.261211','5','Passage d\'un train',1,'[{\"added\": {}}]',8,1),(51,'2026-05-15 13:47:20.822232','6','interdition de fumé',1,'[{\"added\": {}}]',8,1),(52,'2026-05-15 13:48:22.587689','7','dernier metro',1,'[{\"added\": {}}]',8,1),(53,'2026-05-15 13:48:50.666996','8','misique-midi',1,'[{\"added\": {}}]',8,1),(54,'2026-05-15 14:20:23.408706','9','musique-soir',1,'[{\"added\": {}}]',8,1),(55,'2026-05-15 14:46:50.068691','19','Vendredi à 16:16:00 - Lecteur_Gare_nord',3,'',9,1),(56,'2026-05-15 14:46:50.074361','18','Vendredi à 16:37:00 - Lecteur_Gare_nord',3,'',9,1),(57,'2026-05-15 14:46:50.080727','17','Vendredi à 16:21:00 - Lecteur_Gare_nord',3,'',9,1),(58,'2026-05-15 14:46:50.084304','16','Vendredi à 16:18:00 - Lecteur_Gare_nord',3,'',9,1),(59,'2026-05-15 14:46:50.088514','15','Vendredi à 16:16:00 - Lecteur_Gare_nord',3,'',9,1),(60,'2026-05-15 14:46:50.094914','14','Vendredi à 16:12:00 - Lecteur_Gare_nord',3,'',9,1),(61,'2026-05-15 14:46:50.097862','13','Vendredi à 16:07:00 - Lecteur_Gare_nord',3,'',9,1),(62,'2026-05-15 14:46:50.102679','12','Vendredi à 16:01:00 - Lecteur_Gare_nord',3,'',9,1),(63,'2026-05-15 14:46:50.106649','11','Vendredi à 16:01:00 - Lecteur_Gare_nord',3,'',9,1),(64,'2026-05-15 14:46:50.112126','10','Vendredi à 15:51:00 - Lecteur_Gare_nord',3,'',9,1),(65,'2026-05-15 14:46:50.114836','9','Jeudi à 19:33:01 - Lecteur_Gare_nord',3,'',9,1),(66,'2026-05-15 14:46:50.117482','8','Jeudi à 07:31:00 - Lecteur_Gare_nord',3,'',9,1),(67,'2026-05-15 14:46:50.121555','7','Jeudi à 19:21:02 - Lecteur_Gare_nord',3,'',9,1),(68,'2026-05-15 14:46:50.125125','6','Jeudi à 07:20:00 - Lecteur_Gare_nord',3,'',9,1),(69,'2026-05-15 14:46:50.130192','5','Jeudi à 07:19:00 - Lecteur_Gare_nord',3,'',9,1),(70,'2026-05-15 14:46:50.133375','4','Lundi à 07:18:00 - Lecteur_Gare_nord',3,'',9,1),(71,'2026-05-15 14:46:50.136612','3','Lundi à 08:00:00 - Lecteur_Gare_nord',3,'',9,1),(72,'2026-05-15 16:08:57.740997','5','Lecteur_Gare_Nante',3,'',7,1),(73,'2026-05-19 14:33:02.159792','36','Mardi à 16:23:00 - Lecteur_Gare_nord',3,'',9,1),(74,'2026-05-19 14:33:02.166756','35','Mardi à 14:11:00 - Lecteur_Gare_nord',3,'',9,1),(75,'2026-05-19 14:33:02.171440','34','Mardi à 14:11:00 - Lecteur_Gare_nord',3,'',9,1),(76,'2026-05-19 14:33:02.176275','33','Vendredi à 18:00:00 - Lecteur_Gare_nord',3,'',9,1),(77,'2026-05-19 14:33:02.180383','32','Vendredi à 17:55:00 - Lecteur_Gare_nord',3,'',9,1),(78,'2026-05-19 14:33:02.184551','31','Vendredi à 17:53:00 - Lecteur_Gare_nord',3,'',9,1),(79,'2026-05-19 14:33:02.188644','30','Samedi à 17:52:00 - Lecteur_Gare_nord',3,'',9,1),(80,'2026-05-19 14:33:02.193858','29','Vendredi à 17:39:00 - Lecteur_Gare_nord',3,'',9,1),(81,'2026-05-19 14:33:02.200230','28','Vendredi à 17:34:00 - Lecteur_Gare_nord',3,'',9,1),(82,'2026-05-19 14:33:02.208660','27','Vendredi à 17:34:00 - Lecteur_Gare_nord',3,'',9,1),(83,'2026-05-19 14:33:02.215586','26','Vendredi à 17:34:00 - Lecteur_Gare_nord',3,'',9,1),(84,'2026-05-19 14:33:02.228116','25','Vendredi à 17:30:00 - Lecteur_Gare_nord',3,'',9,1),(85,'2026-05-19 14:33:02.233319','24','Vendredi à 17:24:00 - Lecteur_Gare_nord',3,'',9,1),(86,'2026-05-19 14:33:02.238922','23','Jeudi à 17:23:00 - Lecteur_Gare_nord',3,'',9,1),(87,'2026-05-19 14:33:02.246341','22','Vendredi à 17:13:03 - Lecteur_Gare_nord',3,'',9,1),(88,'2026-05-19 14:33:02.251756','21','Vendredi à 16:56:00 - Lecteur_Gare_nord',3,'',9,1),(89,'2026-05-19 14:33:02.256571','20','Vendredi à 16:48:00 - Lecteur_Gare_nord',3,'',9,1),(90,'2026-05-19 15:58:36.268798','43','Mardi à 17:06:15 - Lecteur_Gare_nord',3,'',9,1),(91,'2026-05-19 15:58:36.280140','42','Mardi à 17:05:15 - Lecteur_Gare_nord',3,'',9,1),(92,'2026-05-19 15:58:36.284293','41','Mardi à 17:01:00 - Lecteur_Gare_nord',3,'',9,1),(93,'2026-05-19 15:58:36.288298','40','Mardi à 17:01:00 - Lecteur_Gare_nord',3,'',9,1),(94,'2026-05-19 15:58:36.298053','39','Mardi à 16:59:00 - Lecteur_Gare_nord',3,'',9,1),(95,'2026-05-19 15:58:36.309809','38','Mardi à 16:35:00 - Lecteur_Gare_nord',3,'',9,1),(96,'2026-05-19 15:58:36.317219','37','Mardi à 08:00:00 - Lecteur_Gare_nord',3,'',9,1),(97,'2026-05-19 15:58:53.716499','6','Lecteur_Standard',3,'',7,1),(98,'2026-05-24 20:53:28.588025','12','python3',3,'',7,1),(99,'2026-05-24 20:54:15.043050','11','player_client.py',3,'',7,1),(100,'2026-05-27 21:05:56.217640','55','Lundi à 08:00:00 - Toutes les gares',3,'',9,1),(101,'2026-05-27 21:05:56.225629','56','Mercredi à 22:31:00 - Toutes les gares',3,'',9,1),(102,'2026-05-27 21:05:56.229383','58','Mercredi à 22:41:00 - Toutes les gares',3,'',9,1),(103,'2026-05-27 21:05:56.233839','57','Mercredi à 22:41:00 - Toutes les gares',3,'',9,1),(104,'2026-05-27 21:05:56.236806','59','Mercredi à 23:01:00 - Lecteur_Gare_nord',3,'',9,1),(105,'2026-05-27 21:06:18.672752','9','musique-soir',3,'',8,1),(106,'2026-05-27 21:06:18.679573','8','misique-midi',3,'',8,1),(107,'2026-05-27 21:06:18.688359','7','dernier metro',3,'',8,1),(108,'2026-05-27 21:06:18.693480','6','interdition de fumé',3,'',8,1),(109,'2026-05-27 21:06:18.698139','5','Passage d\'un train',3,'',8,1),(110,'2026-05-27 21:06:18.703277','4','Train  supprimé',3,'',8,1),(111,'2026-05-27 21:06:18.707457','3','zen',3,'',8,1),(112,'2026-05-27 21:06:18.712642','2','douce',3,'',8,1),(113,'2026-05-27 21:06:18.716371','1','ambiance',3,'',8,1),(114,'2026-05-27 21:06:27.811453','2','cool',3,'',11,1),(115,'2026-05-27 21:06:27.815152','1','hhdfs',3,'',11,1),(116,'2026-05-27 21:07:18.754390','10','music 1',1,'[{\"added\": {}}]',8,1),(117,'2026-05-27 21:07:49.127404','11','music 2',1,'[{\"added\": {}}]',8,1),(118,'2026-05-27 21:08:19.683461','12','music4',1,'[{\"added\": {}}]',8,1),(119,'2026-05-27 21:08:44.446375','13','music 4',1,'[{\"added\": {}}]',8,1),(120,'2026-05-27 21:09:22.687943','14','music 6',1,'[{\"added\": {}}]',8,1),(121,'2026-05-27 21:10:04.588053','15','music 7',1,'[{\"added\": {}}]',8,1),(122,'2026-05-27 21:11:19.644214','3','Playlist Matin',1,'[{\"added\": {}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Playlist Matin - 1: music 1\"}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Playlist Matin - 2: music 2\"}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Playlist Matin - 3: music4\"}}]',11,1),(123,'2026-05-27 21:11:34.572225','3','Playlist Matin',2,'[]',11,1),(124,'2026-05-27 21:12:08.043110','4','Playlist Soir',1,'[{\"added\": {}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 0: music4\"}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 1: music 6\"}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 2: music 7\"}}]',11,1),(125,'2026-05-27 21:13:14.044133','16','Annonce_SNCF_Train_Suprimé',1,'[{\"added\": {}}]',8,1),(126,'2026-05-27 21:13:46.867996','17','Annonce_SNCF_denier_Metro',1,'[{\"added\": {}}]',8,1),(127,'2026-05-27 21:14:23.014477','18','Annonce_SNCF_Train_sans_arret',1,'[{\"added\": {}}]',8,1),(128,'2026-05-27 21:15:05.866493','19','Annonce_SNCF_interdit_de_fumé',1,'[{\"added\": {}}]',8,1),(129,'2026-05-27 21:15:39.773035','5','Annonce_SNCF_Train_Suprimé',1,'[{\"added\": {}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Annonce_SNCF_Train_Suprim\\u00e9 - 0: Annonce_SNCF_Train_Suprim\\u00e9\"}}]',11,1),(130,'2026-05-27 21:16:10.680841','6','Annonce_SNCF_Denier_Metro',1,'[{\"added\": {}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Annonce_SNCF_Denier_Metro - 1: Annonce_SNCF_denier_Metro\"}}]',11,1),(131,'2026-05-27 21:16:45.197322','7','Annonce_SNCF_Interdit_Fumé',1,'[{\"added\": {}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Annonce_SNCF_Interdit_Fum\\u00e9 - 1: Annonce_SNCF_interdit_de_fum\\u00e9\"}}]',11,1),(132,'2026-05-27 21:17:15.934298','8','Annonce_SNCF_Train_sans_arret',1,'[{\"added\": {}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Annonce_SNCF_Train_sans_arret - 0: Annonce_SNCF_Train_sans_arret\"}}]',11,1),(133,'2026-05-27 21:23:16.317676','4','Playlist Soir',3,'',11,1),(134,'2026-05-27 21:23:36.741512','9','Playlist Soir',1,'[{\"added\": {}}, {\"added\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 1: music 7\"}}]',11,1),(135,'2026-05-27 21:24:45.870783','9','Playlist Soir',2,'[{\"added\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 2: music 6\"}}]',11,1),(136,'2026-05-27 21:30:30.561725','9','Playlist Soir',2,'[{\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 1: music 1\", \"fields\": [\"Track\"]}}, {\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 2: Annonce_SNCF_Train_Suprim\\u00e9\", \"fields\": [\"Track\"]}}]',11,1),(137,'2026-05-27 22:57:46.033758','8','Annonce_SNCF_Train_sans_arret',2,'[{\"added\": {\"name\": \"playlist track\", \"object\": \"Annonce_SNCF_Train_sans_arret - 1: Annonce_SNCF_denier_Metro\"}}]',11,1),(138,'2026-05-27 23:10:19.945440','8','Annonce_SNCF_Train_sans_arret',2,'[]',11,1),(139,'2026-05-27 23:12:04.166469','3','Playlist Matin',2,'[{\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Matin - 1: Annonce_SNCF_Train_Suprim\\u00e9\", \"fields\": [\"Track\"]}}, {\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Matin - 2: music 1\", \"fields\": [\"Track\"]}}]',11,1),(140,'2026-05-28 13:05:55.422331','87','Jeudi à 13:34:00 - Lecteur_Gare_nord',3,'',9,1),(141,'2026-05-28 13:05:55.433953','86','Jeudi à 13:12:00 - Lecteur_Gare_nord',3,'',9,1),(142,'2026-05-28 13:05:55.438473','85','Jeudi à 13:00:00 - Lecteur_Gare_nord',3,'',9,1),(143,'2026-05-28 13:05:55.442016','84','Jeudi à 12:56:00 - Lecteur_Gare_nord',3,'',9,1),(144,'2026-05-28 13:05:55.444797','83','Jeudi à 12:26:00 - Lecteur_Gare_nord',3,'',9,1),(145,'2026-05-28 13:05:55.449690','82','Jeudi à 12:09:00 - Lecteur_Gare_nord',3,'',9,1),(146,'2026-05-28 13:05:55.458153','81','Jeudi à 12:00:00 - Lecteur_Gare_nord',3,'',9,1),(147,'2026-05-28 13:05:55.462164','80','Jeudi à 11:50:00 - Lecteur_Gare_nord',3,'',9,1),(148,'2026-05-28 13:05:55.467530','79','Jeudi à 11:31:00 - Lecteur_Gare_nord',3,'',9,1),(149,'2026-05-28 13:05:55.470989','78','Jeudi à 11:18:00 - Lecteur_Gare_nord',3,'',9,1),(150,'2026-05-28 13:05:55.474643','77','Jeudi à 11:13:40 - Lecteur_Gare_nord',3,'',9,1),(151,'2026-05-28 13:05:55.477629','76','Jeudi à 11:12:01 - Lecteur_Gare_nord',3,'',9,1),(152,'2026-05-28 13:05:55.484343','75','Jeudi à 11:02:01 - Lecteur_Gare_nord',3,'',9,1),(153,'2026-05-28 13:05:55.488771','74','Jeudi à 10:59:01 - Lecteur_Gare_nord',3,'',9,1),(154,'2026-05-28 13:05:55.491999','73','Jeudi à 10:56:40 - Lecteur_Gare_nord',3,'',9,1),(155,'2026-05-28 13:05:55.498532','72','Jeudi à 10:48:40 - Lecteur_Gare_nord',3,'',9,1),(156,'2026-05-28 13:05:55.503527','71','Jeudi à 10:41:33 - Lecteur_Gare_nord',3,'',9,1),(157,'2026-05-28 13:05:55.506185','70','Jeudi à 10:34:33 - Lecteur_Gare_nord',3,'',9,1),(158,'2026-05-28 13:05:55.510283','69','Jeudi à 10:26:33 - Lecteur_Gare_nord',3,'',9,1),(159,'2026-05-28 13:05:55.514063','68','Jeudi à 10:26:33 - Lecteur_Gare_nord',3,'',9,1),(160,'2026-05-28 13:05:55.520636','67','Jeudi à 08:37:33 - Lecteur_Gare_nord',3,'',9,1),(161,'2026-05-28 13:05:55.524095','66','Jeudi à 02:12:00 - Lecteur_Gare_nord',3,'',9,1),(162,'2026-05-28 13:05:55.526637','65','Jeudi à 02:06:00 - Lecteur_Gare_nord',3,'',9,1),(163,'2026-05-28 13:05:55.530153','64','Jeudi à 01:57:00 - Lecteur_Gare_nord',3,'',9,1),(164,'2026-05-28 13:05:55.545178','63','Jeudi à 01:29:00 - Lecteur_Gare_nord',3,'',9,1),(165,'2026-05-28 13:05:55.551156','62','Jeudi à 00:56:00 - Lecteur_Gare_nord',3,'',9,1),(166,'2026-05-28 13:05:55.556002','61','Lundi à 08:00:00 - Toutes les gares',3,'',9,1),(167,'2026-05-28 13:05:55.558705','60','Lundi à 08:00:00 - Lecteur_Gare_nord',3,'',9,1),(168,'2026-05-30 13:24:56.517400','1','playlist matin',1,'[{\"added\": {}}]',8,1),(169,'2026-05-30 13:25:39.483927','2','playlist soir',1,'[{\"added\": {}}]',8,1),(170,'2026-05-30 13:26:02.390227','3','alerte train off',1,'[{\"added\": {}}]',8,1),(171,'2026-05-30 15:10:35.682602','13','box',1,'[{\"added\": {}}]',8,1),(172,'2026-05-30 15:14:24.899438','3','Playlist Matin',2,'[{\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Matin - 1: Zen\", \"fields\": [\"Track\"]}}, {\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Matin - 2: Mr Shyne - VAS-Y\", \"fields\": [\"Track\"]}}, {\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Matin - 3: Maitre Gims\", \"fields\": [\"Track\"]}}]',11,1),(173,'2026-05-30 15:19:05.194232','9','Playlist Soir',2,'[{\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 1: Douce\", \"fields\": [\"Track\"]}}, {\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 2: Ambiance\", \"fields\": [\"Track\"]}}, {\"changed\": {\"name\": \"playlist track\", \"object\": \"Playlist Soir - 3: Mr Shyne - VAS-Y\", \"fields\": [\"Track\"]}}]',11,1),(174,'2026-05-30 15:33:52.561630','4','Samedi à 17:01:00 - Lecteur_Gare_nord',3,'',9,1),(175,'2026-05-30 15:33:52.620002','3','Samedi à 16:47:00 - Lecteur_Gare_nord',3,'',9,1),(176,'2026-05-30 15:33:52.637837','2','Samedi à 16:35:00 - Lecteur_Gare_nord',3,'',9,1),(177,'2026-05-30 15:33:52.657488','1','Samedi à 15:27:00 - Toutes les gares',3,'',9,1),(178,'2026-06-04 18:32:31.821378','8','Samedi à 23:33:00 - Lecteur_Gare_nord',3,'',9,1),(179,'2026-06-04 18:32:31.836788','7','Samedi à 23:32:00 - Lecteur_Gare_nord',3,'',9,1),(180,'2026-06-04 18:32:31.847611','6','Samedi à 17:47:00 - Lecteur_Gare_nord',3,'',9,1),(181,'2026-06-04 18:32:31.881442','5','Samedi à 17:07:00 - Toutes les gares',3,'',9,1),(182,'2026-06-04 19:22:01.937428','11','Jeudi à 20:30:00 - Lecteur_Gare_Grenoble',3,'',9,1),(183,'2026-06-04 19:22:01.957880','10','Samedi à 23:54:40 - Lecteur_Gare_nord',3,'',9,1),(184,'2026-06-04 19:22:13.968915','15','Vendredi à 21:22:00 - Lecteur_Gare_Grenoble',3,'',9,1),(185,'2026-06-04 21:23:28.942097','6','[\'Lecteur_Gare_nord\', \'Lecteur_Gare_Sud\']',3,'',7,1),(186,'2026-06-04 21:28:56.938928','5','[\'Lecteur_Gare_nord\', \'Lecteur_Gare_nord\']',3,'',7,1),(187,'2026-06-05 08:08:43.702960','20','Jeudi à 23:37:00 - Lecteur_Gare_Lyon',3,'',9,1),(188,'2026-06-05 08:08:43.723586','19','Jeudi à 23:36:00 - Toutes les gares',3,'',9,1),(189,'2026-06-05 08:08:43.730471','18','Jeudi à 23:35:00 - Lecteur_Gare_Grenoble',3,'',9,1),(190,'2026-06-05 08:08:43.737252','17','Jeudi à 23:34:00 - Toutes les gares',3,'',9,1),(191,'2026-06-05 08:08:43.742770','16','Jeudi à 21:23:00 - Lecteur_Gare_Grenoble',3,'',9,1),(192,'2026-06-05 08:08:43.748597','14','Lundi à 21:20:00 - Lecteur_Gare_Grenoble',3,'',9,1),(193,'2026-06-05 08:08:43.754738','13','Jeudi à 21:00:00 - Lecteur_Gare_Lyon',3,'',9,1),(194,'2026-06-05 08:08:43.760079','12','Jeudi à 20:34:00 - Lecteur_Gare_Grenoble',3,'',9,1);
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(7,'api','player'),(11,'api','playlist'),(12,'api','playlisttrack'),(10,'api','schedule'),(9,'api','scheduledalert'),(8,'api','track'),(3,'auth','group'),(2,'auth','permission'),(4,'auth','user'),(5,'contenttypes','contenttype'),(6,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2026-04-20 18:01:28.235851'),(2,'auth','0001_initial','2026-04-20 18:01:29.097902'),(3,'admin','0001_initial','2026-04-20 18:01:29.366857'),(4,'admin','0002_logentry_remove_auto_add','2026-04-20 18:01:29.389556'),(5,'admin','0003_logentry_add_action_flag_choices','2026-04-20 18:01:29.409666'),(7,'contenttypes','0002_remove_content_type_name','2026-04-20 18:01:29.672129'),(8,'auth','0002_alter_permission_name_max_length','2026-04-20 18:01:29.811176'),(9,'auth','0003_alter_user_email_max_length','2026-04-20 18:01:29.875488'),(10,'auth','0004_alter_user_username_opts','2026-04-20 18:01:29.896746'),(11,'auth','0005_alter_user_last_login_null','2026-04-20 18:01:29.967800'),(12,'auth','0006_require_contenttypes_0002','2026-04-20 18:01:29.974211'),(13,'auth','0007_alter_validators_add_error_messages','2026-04-20 18:01:29.993108'),(14,'auth','0008_alter_user_username_max_length','2026-04-20 18:01:30.090990'),(15,'auth','0009_alter_user_last_name_max_length','2026-04-20 18:01:30.183720'),(16,'auth','0010_alter_group_name_max_length','2026-04-20 18:01:30.226256'),(17,'auth','0011_update_proxy_permissions','2026-04-20 18:01:30.245699'),(18,'auth','0012_alter_user_first_name_max_length','2026-04-20 18:01:30.380064'),(19,'sessions','0001_initial','2026-04-20 18:01:30.472698'),(26,'api','0002_playlist_remove_schedule_track_and_more','2026-05-27 19:08:21.737751'),(30,'api','0001_initial','2026-05-30 13:21:47.654428'),(31,'api','0002_alter_player_last_ping','2026-05-30 13:21:47.736614'),(33,'api','0002_player_last_alert_key','2026-05-30 14:40:19.348161'),(34,'api','0003_remove_player_last_alert_key','2026-05-30 14:40:19.381981'),(35,'api','0004_player_last_alert_key_alter_player_last_ping','2026-05-30 14:40:19.490859');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('1rj9n5tybntrzsxxfpu57wficgbc4p28','.eJxVjDkOwjAUBe_iGlle8r1Q0ucM1veGA8iW4qRC3B1HSgHtm5n3Jg73rbi9p9UtkVwJJ5ffzWN4pnqA-MB6bzS0uq2Lp4dCT9rp3GJ63U7376BgL6O20kwMpOUmK8HUCKX2IqDNATEDT1pnbv0QvAbFotEQGUyQFQqdQZHPF8xmN1I:1wEtDb:NwHg25uid7KUX_vRNXQzaVZwgmfiiZiR3qHOFQzrhv0','2026-05-04 18:19:35.979801'),('ko6nzv31rorrvdp69lelfj0vcmjgyqxg','.eJxVjDkOwjAUBe_iGlle8r1Q0ucM1veGA8iW4qRC3B1HSgHtm5n3Jg73rbi9p9UtkVwJJ5ffzWN4pnqA-MB6bzS0uq2Lp4dCT9rp3GJ63U7376BgL6O20kwMpOUmK8HUCKX2IqDNATEDT1pnbv0QvAbFotEQGUyQFQqdQZHPF8xmN1I:1wRFot:-FV4qBWBX7N6PMSmNvPSfMxKI9CFxeLbaxZI90ZQXlI','2026-06-07 20:53:11.918630'),('qnsf4u8balf53r7y7oj46sge9h3rybna','.eJxVjDkOwjAUBe_iGlle8r1Q0ucM1veGA8iW4qRC3B1HSgHtm5n3Jg73rbi9p9UtkVwJJ5ffzWN4pnqA-MB6bzS0uq2Lp4dCT9rp3GJ63U7376BgL6O20kwMpOUmK8HUCKX2IqDNATEDT1pnbv0QvAbFotEQGUyQFQqdQZHPF8xmN1I:1wM2Ly:DfTopdmIN9tkPj7QLi7YYIksGkV4qKz7_ofwlO52HCk','2026-05-24 11:29:46.319354');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-05 14:46:20
