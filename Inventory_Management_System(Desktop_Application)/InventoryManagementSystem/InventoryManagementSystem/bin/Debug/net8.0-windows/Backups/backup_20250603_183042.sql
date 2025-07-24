-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: localhost    Database: InventoryDB
-- ------------------------------------------------------
-- Server version	8.0.40

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
-- Table structure for table `auditlogs`
--

DROP TABLE IF EXISTS `auditlogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auditlogs` (
  `LogID` int NOT NULL AUTO_INCREMENT,
  `UserID` int DEFAULT NULL,
  `Action` varchar(100) NOT NULL,
  `Timestamp` datetime DEFAULT CURRENT_TIMESTAMP,
  `Details` text,
  PRIMARY KEY (`LogID`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `auditlogs_ibfk_1` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=166 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditlogs`
--

LOCK TABLES `auditlogs` WRITE;
/*!40000 ALTER TABLE `auditlogs` DISABLE KEYS */;
INSERT INTO `auditlogs` VALUES (1,2,'Load Users Failed','2025-06-01 12:35:39','Error: Could not find specified column in results: LastLogin'),(2,2,'Load Users Failed','2025-06-01 12:36:58','Error: Could not find specified column in results: LastLogin'),(3,2,'Load Users Failed','2025-06-01 12:47:51','Error: Could not find specified column in results: LastLogin'),(4,2,'Load Users Failed','2025-06-01 12:48:18','Error: Could not find specified column in results: LastLogin'),(5,2,'Load Users Failed','2025-06-01 12:48:27','Error: Could not find specified column in results: LastLogin'),(6,2,'Load Users Failed','2025-06-01 12:50:14','Error: Could not find specified column in results: LastLogin'),(7,2,'Load Users Failed','2025-06-01 13:05:05','Error: Unknown column \'LastLogin\' in \'field list\''),(8,2,'Load Users Failed','2025-06-01 13:06:54','Error: Unknown column \'LastLogin\' in \'field list\''),(9,2,'Viewed Users','2025-06-01 13:11:49','User list loaded in UserManagementView'),(10,2,'Viewed Users','2025-06-01 13:20:12','User list loaded in UserManagementView'),(11,2,'Viewed Users','2025-06-01 13:20:55','User list loaded in UserManagementView'),(12,2,'Edit User Failed','2025-06-01 13:21:19','Error: Data truncated for column \'Role\' at row 1'),(13,2,'Viewed Users','2025-06-01 13:23:39','User list loaded in UserManagementView'),(14,2,'Viewed Users','2025-06-01 13:24:32','User list loaded in UserManagementView'),(15,2,'Edit User Failed','2025-06-01 13:24:57','Error: Data truncated for column \'Role\' at row 1'),(16,2,'Password Reset','2025-06-01 13:25:47','Reset password for user as'),(17,2,'Viewed Users','2025-06-01 13:26:48','User list loaded in UserManagementView'),(18,2,'Viewed Users','2025-06-01 13:32:35','User list loaded in UserManagementView'),(19,2,'Viewed Users','2025-06-01 13:37:04','User list loaded in UserManagementView'),(20,2,'Viewed Users','2025-06-01 13:52:04','User list loaded in UserManagementView'),(21,2,'Add User Failed','2025-06-01 13:54:23','Error: Data truncated for column \'Role\' at row 1'),(22,2,'Viewed Users','2025-06-01 13:54:47','User list loaded in UserManagementView'),(23,2,'Viewed Users','2025-06-01 14:39:18','User list loaded in UserManagementView'),(24,2,'Add User Failed','2025-06-01 14:40:43','Error: Data truncated for column \'Role\' at row 1'),(25,2,'Viewed Users','2025-06-01 14:41:50','User list loaded in UserManagementView'),(26,2,'Viewed Users','2025-06-01 14:49:16','User list loaded in UserManagementView'),(27,2,'Add User Failed','2025-06-01 14:49:50','Error: Data truncated for column \'Role\' at row 1'),(28,2,'Add User Failed','2025-06-01 14:50:15','Error: Data truncated for column \'Role\' at row 1'),(29,2,'Viewed Users','2025-06-01 14:51:24','User list loaded in UserManagementView'),(30,2,'Add User Failed','2025-06-01 14:51:54','Error: Data truncated for column \'Role\' at row 1'),(31,2,'Viewed Users','2025-06-01 14:53:27','User list loaded in UserManagementView'),(32,2,'Add User Failed','2025-06-01 14:53:51','Error: Data too long for column \'Role\' at row 1'),(33,2,'Viewed Users','2025-06-01 14:58:22','User list loaded in UserManagementView'),(34,2,'Add User Failed','2025-06-01 14:58:46','Error: Data truncated for column \'Role\' at row 1'),(35,2,'Viewed Users','2025-06-01 15:05:38','User list loaded in UserManagementView'),(36,2,'Add User Failed','2025-06-01 15:06:07','Error: Data truncated for column \'Role\' at row 1'),(37,2,'Viewed Users','2025-06-01 15:09:04','User list loaded in UserManagementView'),(38,2,'User Added','2025-06-01 15:09:28','Added user user'),(39,2,'Viewed Users','2025-06-01 15:09:28','User list loaded in UserManagementView'),(40,2,'User Edited','2025-06-01 15:09:54','Edited user user'),(41,2,'Viewed Users','2025-06-01 15:09:54','User list loaded in UserManagementView'),(42,2,'Viewed Users','2025-06-01 15:15:11','User list loaded in UserManagementView'),(43,2,'Viewed Users','2025-06-02 09:06:14','User list loaded in UserManagementView'),(44,2,'Viewed Users','2025-06-02 09:06:52','User list loaded in UserManagementView'),(45,2,'Viewed Users','2025-06-02 10:55:52','User list loaded in UserManagementView'),(46,2,'Viewed Users','2025-06-02 11:10:53','User list loaded in UserManagementView'),(47,2,'Viewed Users','2025-06-02 11:12:25','User list loaded in UserManagementView'),(48,2,'Item Added','2025-06-02 11:13:26','Added item pens'),(49,2,'Item Updated','2025-06-02 11:13:48','Updated item pens'),(50,2,'Item Deleted','2025-06-02 11:14:27','Deleted item ID 1'),(51,2,'Item Added','2025-06-02 11:15:13','Added item pens'),(52,2,'Viewed Users','2025-06-02 11:27:17','User list loaded in UserManagementView'),(53,2,'Viewed Users','2025-06-02 11:34:27','User list loaded in UserManagementView'),(54,2,'Supplier Added','2025-06-02 11:35:12','Added supplier hassan ijaz'),(55,2,'Supplier Updated','2025-06-02 11:35:27','Updated supplier hassan ijaz'),(56,2,'Viewed Users','2025-06-02 11:36:07','User list loaded in UserManagementView'),(57,2,'Viewed Users','2025-06-02 11:36:30','User list loaded in UserManagementView'),(58,2,'Viewed Users','2025-06-02 12:09:23','User list loaded in UserManagementView'),(59,2,'Viewed Users','2025-06-02 12:12:48','User list loaded in UserManagementView'),(60,2,'Viewed Users','2025-06-02 12:13:41','User list loaded in UserManagementView'),(61,2,'Viewed Users','2025-06-02 12:36:31','User list loaded in UserManagementView'),(62,2,'Viewed Users','2025-06-02 12:38:00','User list loaded in UserManagementView'),(63,2,'Viewed Users','2025-06-02 12:50:25','User list loaded in UserManagementView'),(64,2,'Viewed Users','2025-06-02 12:51:41','User list loaded in UserManagementView'),(65,2,'Item Added','2025-06-02 12:52:29','Added item bags'),(66,2,'Item Added','2025-06-02 12:53:50','Added item I-phones'),(67,2,'Supplier Added','2025-06-02 12:54:56','Added supplier aryan rao'),(68,2,'Supplier Added','2025-06-02 12:55:32','Added supplier saifi'),(69,2,'Supplier Added','2025-06-02 12:56:04','Added supplier shamsi'),(70,2,'Supplier Added','2025-06-02 12:56:34','Added supplier sidhu'),(71,2,'Item Added','2025-06-02 12:57:37','Added item mobile_covers'),(72,2,'Viewed Users','2025-06-02 12:57:41','User list loaded in UserManagementView'),(73,2,'Viewed Users','2025-06-02 12:58:01','User list loaded in UserManagementView'),(74,2,'Item Added','2025-06-02 13:00:39','Added item I_phone charger'),(75,2,'Item Added','2025-06-02 13:01:20','Added item android_charger'),(76,2,'Item Added','2025-06-02 13:02:58','Added item DEL-Laptops,core i-5,gen,5'),(77,2,'Item Added','2025-06-02 13:04:09','Added item HP-Laptops, core i-5,gen-7'),(78,2,'Viewed Users','2025-06-02 13:05:26','User list loaded in UserManagementView'),(79,2,'Viewed Users','2025-06-02 15:30:20','User list loaded in UserManagementView'),(80,2,'Viewed Users','2025-06-02 15:45:50','User list loaded in UserManagementView'),(81,2,'Viewed Users','2025-06-02 16:24:05','User list loaded in UserManagementView'),(82,2,'Viewed Users','2025-06-02 16:24:59','User list loaded in UserManagementView'),(83,2,'Viewed Users','2025-06-02 16:26:31','User list loaded in UserManagementView'),(84,2,'Viewed Users','2025-06-02 16:36:54','User list loaded in UserManagementView'),(85,7,'Transaction Add Failed','2025-06-02 20:54:54','Error adding transaction: Data truncated for column \'TransactionType\' at row 1'),(86,7,'Transaction Add Failed','2025-06-02 20:55:06','Error adding transaction: Data truncated for column \'TransactionType\' at row 1'),(87,7,'Transaction Add Failed','2025-06-02 20:55:21','Error adding transaction: Data truncated for column \'TransactionType\' at row 1'),(88,7,'Support Request Submitted','2025-06-02 20:55:57','Request ID 0 submitted by User ID 7'),(89,7,'Transaction Add Failed','2025-06-02 20:57:43','Error adding transaction: Data truncated for column \'TransactionType\' at row 1'),(90,7,'Transaction Add Failed','2025-06-02 21:04:24','MySQL Error: 1265 - Data truncated for column \'TransactionType\' at row 1'),(91,7,'Transaction Add Failed','2025-06-02 21:04:29','MySQL Error: 1265 - Data truncated for column \'TransactionType\' at row 1'),(92,7,'Transaction Add Failed','2025-06-02 21:26:43','MySQL Error: 1265 - Data truncated for column \'TransactionType\' at row 1'),(93,7,'Transaction Add Failed','2025-06-02 21:27:31','MySQL Error: 1265 - Data truncated for column \'TransactionType\' at row 1'),(94,7,'Transaction Add Failed','2025-06-02 21:33:51','MySQL Error: 1265 - Data truncated for column \'TransactionType\' at row 1'),(95,7,'Transaction Add Failed','2025-06-02 21:38:02','MySQL Error: 1265 - Data truncated for column \'TransactionType\' at row 1'),(96,7,'Transaction Added','2025-06-02 21:46:57','Added Transfer for ItemID 5, Quantity: 5'),(97,7,'Item Updated','2025-06-02 21:46:57','Updated item mobile_covers'),(98,7,'Transaction Added','2025-06-02 21:48:22','Added Stock In for ItemID 4, Quantity: 5'),(99,7,'Item Updated','2025-06-02 21:48:22','Updated item I-phones'),(100,7,'Transaction Added','2025-06-02 21:48:57','Added Stock Out for ItemID 2, Quantity: 10'),(101,7,'Item Updated','2025-06-02 21:48:57','Updated item pens'),(102,7,'Transaction Added','2025-06-02 21:49:44','Added Stock In for ItemID 7, Quantity: 15'),(103,7,'Item Updated','2025-06-02 21:49:44','Updated item android_charger'),(104,7,'Transaction Added','2025-06-02 21:50:16','Added Transfer for ItemID 9, Quantity: 19'),(105,7,'Item Updated','2025-06-02 21:50:16','Updated item HP-Laptops, core i-5,gen-7'),(106,7,'Support Request Submitted','2025-06-02 21:50:47','Request ID 0 submitted by User ID 7'),(107,2,'Viewed Users','2025-06-02 21:54:34','User list loaded in UserManagementView'),(108,7,'Transaction Added','2025-06-02 22:35:22','Added Stock In for ItemID 9, Quantity: 15'),(109,7,'Item Updated','2025-06-02 22:35:22','Updated item HP-Laptops, core i-5,gen-7'),(110,2,'Viewed Users','2025-06-02 22:39:03','User list loaded in UserManagementView'),(111,2,'User Added','2025-06-02 22:40:45','Added user aa'),(112,2,'Viewed Users','2025-06-02 22:40:45','User list loaded in UserManagementView'),(113,2,'Viewed Users','2025-06-02 22:49:37','User list loaded in UserManagementView'),(114,2,'User Added','2025-06-02 22:50:10','Added user aa'),(115,2,'Viewed Users','2025-06-02 22:50:10','User list loaded in UserManagementView'),(116,2,'User Deleted','2025-06-02 22:50:17','Deleted user aa'),(123,7,'Support Request Submitted','2025-06-02 23:49:06','Request ID 0 submitted by User ID 7'),(124,2,'Viewed Users','2025-06-03 09:00:46','User list loaded in UserManagementView'),(125,2,'Viewed Users','2025-06-03 09:09:43','User list loaded in UserManagementView'),(126,2,'Viewed Users','2025-06-03 09:17:40','User list loaded in UserManagementView'),(127,2,'Viewed Users','2025-06-03 09:56:10','User list loaded in UserManagementView'),(128,2,'Viewed Users','2025-06-03 09:56:15','User list loaded in UserManagementView'),(129,2,'Viewed Users','2025-06-03 10:53:58','User list loaded in UserManagementView'),(130,7,'Transaction Added','2025-06-03 10:56:36','Added Stock In for ItemID 7, Quantity: 12'),(131,7,'Item Updated','2025-06-03 10:56:36','Updated item android_charger'),(132,2,'Viewed Users','2025-06-03 13:31:40','User list loaded in UserManagementView'),(133,2,'Viewed Users','2025-06-03 13:32:39','User list loaded in UserManagementView'),(134,2,'Viewed Users','2025-06-03 13:39:53','User list loaded in UserManagementView'),(135,2,'Viewed Users','2025-06-03 13:44:06','User list loaded in UserManagementView'),(136,2,'Viewed Users','2025-06-03 14:55:03','User list loaded in UserManagementView'),(137,2,'Viewed Users','2025-06-03 15:04:41','User list loaded in UserManagementView'),(138,2,'Viewed Users','2025-06-03 15:15:50','User list loaded in UserManagementView'),(139,2,'Viewed Users','2025-06-03 15:17:32','User list loaded in UserManagementView'),(140,2,'Viewed Users','2025-06-03 15:18:49','User list loaded in UserManagementView'),(141,2,'Viewed Users','2025-06-03 15:18:53','User list loaded in UserManagementView'),(142,2,'Viewed Users','2025-06-03 15:31:12','User list loaded in UserManagementView'),(143,2,'Viewed Users','2025-06-03 15:34:52','User list loaded in UserManagementView'),(144,2,'Viewed Users','2025-06-03 15:40:22','User list loaded in UserManagementView'),(145,2,'Viewed Users','2025-06-03 15:41:06','User list loaded in UserManagementView'),(146,2,'Viewed Users','2025-06-03 15:46:00','User list loaded in UserManagementView'),(147,2,'Viewed Users','2025-06-03 15:46:28','User list loaded in UserManagementView'),(148,2,'Viewed Users','2025-06-03 15:52:38','User list loaded in UserManagementView'),(149,2,'Viewed Users','2025-06-03 15:56:14','User list loaded in UserManagementView'),(150,2,'Viewed Users','2025-06-03 15:59:04','User list loaded in UserManagementView'),(151,2,'Viewed Users','2025-06-03 15:59:14','User list loaded in UserManagementView'),(152,2,'Viewed Users','2025-06-03 16:05:00','User list loaded in UserManagementView'),(153,2,'Viewed Users','2025-06-03 16:10:29','User list loaded in UserManagementView'),(154,2,'Viewed Users','2025-06-03 16:10:52','User list loaded in UserManagementView'),(155,2,'Viewed Users','2025-06-03 16:21:25','User list loaded in UserManagementView'),(156,2,'Viewed Users','2025-06-03 16:23:00','User list loaded in UserManagementView'),(157,2,'Viewed Users','2025-06-03 16:37:50','User list loaded in UserManagementView'),(158,2,'Viewed Users','2025-06-03 17:57:31','User list loaded in UserManagementView'),(159,2,'Viewed Users','2025-06-03 17:57:49','User list loaded in UserManagementView'),(160,2,'Viewed Users','2025-06-03 17:59:21','User list loaded in UserManagementView'),(161,2,'Viewed Users','2025-06-03 18:00:14','User list loaded in UserManagementView'),(162,2,'Viewed Users','2025-06-03 18:04:46','User list loaded in UserManagementView'),(163,2,'Viewed Users','2025-06-03 18:27:33','User list loaded in UserManagementView'),(164,2,'Viewed Users','2025-06-03 18:27:40','User list loaded in UserManagementView'),(165,2,'Viewed Users','2025-06-03 18:28:58','User list loaded in UserManagementView');
/*!40000 ALTER TABLE `auditlogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventory`
--

DROP TABLE IF EXISTS `inventory`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inventory` (
  `ItemID` int NOT NULL AUTO_INCREMENT,
  `ItemName` varchar(100) NOT NULL,
  `Category` varchar(50) DEFAULT NULL,
  `Quantity` int NOT NULL,
  `UnitPrice` decimal(10,2) DEFAULT NULL,
  `SupplierID` int DEFAULT NULL,
  `LastUpdated` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ItemID`),
  KEY `SupplierID` (`SupplierID`),
  CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`SupplierID`) REFERENCES `suppliers` (`SupplierID`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (2,'pens','stationary ',110,10.00,NULL,'2025-06-02 21:48:57'),(3,'bags','stationary',20,300.00,1,'2025-06-02 12:52:29'),(4,'I-phones','mobiles',45,200000.00,1,'2025-06-02 21:48:22'),(5,'mobile_covers','pouches',500,200.00,3,'2025-06-02 21:46:57'),(6,'I_phone charger','charger',300,300.00,2,'2025-06-02 13:00:39'),(7,'android_charger','chargers',627,400.00,4,'2025-06-03 10:56:36'),(8,'DEL-Laptops,core i-5,gen,5','Laptops ',50,50000.00,5,'2025-06-02 13:02:58'),(9,'HP-Laptops, core i-5,gen-7','hp',55,60000.00,4,'2025-06-02 22:35:22');
/*!40000 ALTER TABLE `inventory` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `SupplierID` int NOT NULL AUTO_INCREMENT,
  `SupplierName` varchar(100) NOT NULL,
  `ContactInfo` varchar(100) DEFAULT NULL,
  `Address` text,
  PRIMARY KEY (`SupplierID`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'hassan ijaz','03337633986','kabirwala'),(2,'aryan rao','030033333584','mulatan'),(3,'saifi','032547347334','lahore'),(4,'shamsi','0334445657373','islamabad'),(5,'sidhu','03335550705707','Karachi');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supportrequest`
--

DROP TABLE IF EXISTS `supportrequest`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supportrequest` (
  `RequestID` int NOT NULL AUTO_INCREMENT,
  `Description` text NOT NULL,
  `Priority` enum('Low','Medium','High') NOT NULL,
  `Status` enum('Pending','In Progress','Resolved') NOT NULL DEFAULT 'Pending',
  `SubmittedBy` int NOT NULL,
  `SubmittedDate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`RequestID`),
  KEY `SubmittedBy` (`SubmittedBy`),
  CONSTRAINT `supportrequest_ibfk_1` FOREIGN KEY (`SubmittedBy`) REFERENCES `users` (`UserID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supportrequest`
--

LOCK TABLES `supportrequest` WRITE;
/*!40000 ALTER TABLE `supportrequest` DISABLE KEYS */;
/*!40000 ALTER TABLE `supportrequest` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `supportrequests`
--

DROP TABLE IF EXISTS `supportrequests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `supportrequests` (
  `RequestID` int NOT NULL AUTO_INCREMENT,
  `Description` text NOT NULL,
  `Priority` varchar(50) NOT NULL,
  `Status` varchar(50) NOT NULL,
  `SubmittedBy` int NOT NULL,
  `SubmittedDate` datetime NOT NULL,
  PRIMARY KEY (`RequestID`),
  KEY `SubmittedBy` (`SubmittedBy`),
  CONSTRAINT `supportrequests_ibfk_1` FOREIGN KEY (`SubmittedBy`) REFERENCES `users` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `supportrequests`
--

LOCK TABLES `supportrequests` WRITE;
/*!40000 ALTER TABLE `supportrequests` DISABLE KEYS */;
INSERT INTO `supportrequests` VALUES (6,'high demand of mobile covers ....','Medium','Pending',7,'2025-06-02 23:49:06');
/*!40000 ALTER TABLE `supportrequests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `TransactionID` int NOT NULL AUTO_INCREMENT,
  `ItemID` int NOT NULL,
  `UserID` int NOT NULL,
  `TransactionType` varchar(50) NOT NULL,
  `Quantity` int NOT NULL,
  `TransactionDate` datetime NOT NULL,
  `Description` text,
  PRIMARY KEY (`TransactionID`),
  KEY `ItemID` (`ItemID`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`ItemID`) REFERENCES `inventory` (`ItemID`),
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,5,7,'Transfer',5,'2025-06-02 21:46:58','transferring items recorded...'),(2,4,7,'Stock In',5,'2025-06-02 21:48:22','adding item in record stock'),(3,2,7,'Stock Out',10,'2025-06-02 21:48:57','low stock items'),(4,7,7,'Stock In',15,'2025-06-02 21:49:44','adding in stock record....'),(5,9,7,'Transfer',19,'2025-06-02 21:50:17','transferring stock ....'),(6,9,7,'Stock In',15,'2025-06-02 22:35:23','RECORD added'),(7,7,7,'Stock In',12,'2025-06-03 10:56:37','adding stock in the record');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `UserID` int NOT NULL AUTO_INCREMENT,
  `Username` varchar(50) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Role` varchar(20) DEFAULT NULL,
  `Email` varchar(100) NOT NULL,
  `FullName` varchar(100) NOT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `LastLogin` datetime DEFAULT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE KEY `Username` (`Username`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2a$11$K6hL9mP3qW5vT8xR2yU0aO.T9kJ4eN7iZ8bC5dF1gH3jQ2wX9vY0u','Admin','admin@example.com','Administrator','2025-05-31 12:39:48',NULL),(2,'ak','$2a$11$qPwUc5Zuf9.V2fGtSNy8T.s6AwrxEOl7ioYCKPVOEE2hseTnqV4w2','Admin','ak@gmail.com','asad','2025-06-01 04:25:30',NULL),(3,'tb','$2a$11$3WUG4qP6.mYyczEriITaAO9StLV3aNfHhk.XtVS462XwZP39qU47u','Manager','tb@gmail.com','taimoor','2025-06-01 05:51:25',NULL),(7,'as','$2a$11$mvVqD/hbWHGPOINNeKW86er6sefLzuZBiwR5hPLkU.FYYsfzhsCjW','Staff','as@gamil.com','anas saleem','2025-06-02 11:27:59',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-06-03 18:32:37
