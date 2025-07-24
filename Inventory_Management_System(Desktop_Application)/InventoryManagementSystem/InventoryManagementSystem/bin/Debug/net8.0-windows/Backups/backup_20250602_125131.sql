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
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditlogs`
--

LOCK TABLES `auditlogs` WRITE;
/*!40000 ALTER TABLE `auditlogs` DISABLE KEYS */;
INSERT INTO `auditlogs` VALUES (1,2,'Load Users Failed','2025-06-01 12:35:39','Error: Could not find specified column in results: LastLogin'),(2,2,'Load Users Failed','2025-06-01 12:36:58','Error: Could not find specified column in results: LastLogin'),(3,2,'Load Users Failed','2025-06-01 12:47:51','Error: Could not find specified column in results: LastLogin'),(4,2,'Load Users Failed','2025-06-01 12:48:18','Error: Could not find specified column in results: LastLogin'),(5,2,'Load Users Failed','2025-06-01 12:48:27','Error: Could not find specified column in results: LastLogin'),(6,2,'Load Users Failed','2025-06-01 12:50:14','Error: Could not find specified column in results: LastLogin'),(7,2,'Load Users Failed','2025-06-01 13:05:05','Error: Unknown column \'LastLogin\' in \'field list\''),(8,2,'Load Users Failed','2025-06-01 13:06:54','Error: Unknown column \'LastLogin\' in \'field list\''),(9,2,'Viewed Users','2025-06-01 13:11:49','User list loaded in UserManagementView'),(10,2,'Viewed Users','2025-06-01 13:20:12','User list loaded in UserManagementView'),(11,2,'Viewed Users','2025-06-01 13:20:55','User list loaded in UserManagementView'),(12,2,'Edit User Failed','2025-06-01 13:21:19','Error: Data truncated for column \'Role\' at row 1'),(13,2,'Viewed Users','2025-06-01 13:23:39','User list loaded in UserManagementView'),(14,2,'Viewed Users','2025-06-01 13:24:32','User list loaded in UserManagementView'),(15,2,'Edit User Failed','2025-06-01 13:24:57','Error: Data truncated for column \'Role\' at row 1'),(16,2,'Password Reset','2025-06-01 13:25:47','Reset password for user as'),(17,2,'Viewed Users','2025-06-01 13:26:48','User list loaded in UserManagementView'),(18,2,'Viewed Users','2025-06-01 13:32:35','User list loaded in UserManagementView'),(19,2,'Viewed Users','2025-06-01 13:37:04','User list loaded in UserManagementView'),(20,2,'Viewed Users','2025-06-01 13:52:04','User list loaded in UserManagementView'),(21,2,'Add User Failed','2025-06-01 13:54:23','Error: Data truncated for column \'Role\' at row 1'),(22,2,'Viewed Users','2025-06-01 13:54:47','User list loaded in UserManagementView'),(23,2,'Viewed Users','2025-06-01 14:39:18','User list loaded in UserManagementView'),(24,2,'Add User Failed','2025-06-01 14:40:43','Error: Data truncated for column \'Role\' at row 1'),(25,2,'Viewed Users','2025-06-01 14:41:50','User list loaded in UserManagementView'),(26,2,'Viewed Users','2025-06-01 14:49:16','User list loaded in UserManagementView'),(27,2,'Add User Failed','2025-06-01 14:49:50','Error: Data truncated for column \'Role\' at row 1'),(28,2,'Add User Failed','2025-06-01 14:50:15','Error: Data truncated for column \'Role\' at row 1'),(29,2,'Viewed Users','2025-06-01 14:51:24','User list loaded in UserManagementView'),(30,2,'Add User Failed','2025-06-01 14:51:54','Error: Data truncated for column \'Role\' at row 1'),(31,2,'Viewed Users','2025-06-01 14:53:27','User list loaded in UserManagementView'),(32,2,'Add User Failed','2025-06-01 14:53:51','Error: Data too long for column \'Role\' at row 1'),(33,2,'Viewed Users','2025-06-01 14:58:22','User list loaded in UserManagementView'),(34,2,'Add User Failed','2025-06-01 14:58:46','Error: Data truncated for column \'Role\' at row 1'),(35,2,'Viewed Users','2025-06-01 15:05:38','User list loaded in UserManagementView'),(36,2,'Add User Failed','2025-06-01 15:06:07','Error: Data truncated for column \'Role\' at row 1'),(37,2,'Viewed Users','2025-06-01 15:09:04','User list loaded in UserManagementView'),(38,2,'User Added','2025-06-01 15:09:28','Added user user'),(39,2,'Viewed Users','2025-06-01 15:09:28','User list loaded in UserManagementView'),(40,2,'User Edited','2025-06-01 15:09:54','Edited user user'),(41,2,'Viewed Users','2025-06-01 15:09:54','User list loaded in UserManagementView'),(42,2,'Viewed Users','2025-06-01 15:15:11','User list loaded in UserManagementView'),(43,2,'Viewed Users','2025-06-02 09:06:14','User list loaded in UserManagementView'),(44,2,'Viewed Users','2025-06-02 09:06:52','User list loaded in UserManagementView'),(45,2,'Viewed Users','2025-06-02 10:55:52','User list loaded in UserManagementView'),(46,2,'Viewed Users','2025-06-02 11:10:53','User list loaded in UserManagementView'),(47,2,'Viewed Users','2025-06-02 11:12:25','User list loaded in UserManagementView'),(48,2,'Item Added','2025-06-02 11:13:26','Added item pens'),(49,2,'Item Updated','2025-06-02 11:13:48','Updated item pens'),(50,2,'Item Deleted','2025-06-02 11:14:27','Deleted item ID 1'),(51,2,'Item Added','2025-06-02 11:15:13','Added item pens'),(52,2,'Viewed Users','2025-06-02 11:27:17','User list loaded in UserManagementView'),(53,2,'Viewed Users','2025-06-02 11:34:27','User list loaded in UserManagementView'),(54,2,'Supplier Added','2025-06-02 11:35:12','Added supplier hassan ijaz'),(55,2,'Supplier Updated','2025-06-02 11:35:27','Updated supplier hassan ijaz'),(56,2,'Viewed Users','2025-06-02 11:36:07','User list loaded in UserManagementView'),(57,2,'Viewed Users','2025-06-02 11:36:30','User list loaded in UserManagementView'),(58,2,'Viewed Users','2025-06-02 12:09:23','User list loaded in UserManagementView'),(59,2,'Viewed Users','2025-06-02 12:12:48','User list loaded in UserManagementView'),(60,2,'Viewed Users','2025-06-02 12:13:41','User list loaded in UserManagementView'),(61,2,'Viewed Users','2025-06-02 12:36:31','User list loaded in UserManagementView'),(62,2,'Viewed Users','2025-06-02 12:38:00','User list loaded in UserManagementView'),(63,2,'Viewed Users','2025-06-02 12:50:25','User list loaded in UserManagementView');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventory`
--

LOCK TABLES `inventory` WRITE;
/*!40000 ALTER TABLE `inventory` DISABLE KEYS */;
INSERT INTO `inventory` VALUES (2,'pens','stationary ',120,10.00,NULL,'2025-06-02 11:15:12');
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
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES (1,'hassan ijaz','03337633986','kabirwala');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
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
  `TransactionType` enum('Add','Remove','Update') NOT NULL,
  `Quantity` int NOT NULL,
  `TransactionDate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Description` text,
  PRIMARY KEY (`TransactionID`),
  KEY `ItemID` (`ItemID`),
  KEY `UserID` (`UserID`),
  CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`ItemID`) REFERENCES `inventory` (`ItemID`) ON DELETE CASCADE,
  CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`UserID`) REFERENCES `users` (`UserID`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','$2a$11$K6hL9mP3qW5vT8xR2yU0aO.T9kJ4eN7iZ8bC5dF1gH3jQ2wX9vY0u','Admin','admin@example.com','Administrator','2025-05-31 12:39:48',NULL),(2,'ak','$2a$11$qPwUc5Zuf9.V2fGtSNy8T.s6AwrxEOl7ioYCKPVOEE2hseTnqV4w2','Admin','ak@gmail.com','asad','2025-06-01 04:25:30',NULL),(3,'tb','$2a$11$3WUG4qP6.mYyczEriITaAO9StLV3aNfHhk.XtVS462XwZP39qU47u','Manager','tb@gmail.com','taimoor','2025-06-01 05:51:25',NULL),(5,'as','$2a$11$VZ82iygjAKAuIQAwW9VfY.lo//mFbydzKK2CqTPTi134pCg6W1G/S','Staff','as@gmail.com','anas','2025-06-01 08:24:16',NULL);
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

-- Dump completed on 2025-06-02 12:51:34
