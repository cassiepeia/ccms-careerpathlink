-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.30 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for final_careercoaching
CREATE DATABASE IF NOT EXISTS `final_careercoaching` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `final_careercoaching`;

-- Dumping structure for table final_careercoaching.appointments
CREATE TABLE IF NOT EXISTS `appointments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `student_name` varchar(100) NOT NULL,
  `date_requested` date NOT NULL,
  `time_requested` time DEFAULT NULL,
  `status` enum('Pending','Accepted','Declined','Completed','Cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'Pending',
  `coach_id` int NOT NULL,
  `service_type` enum('Career Coaching','Mock Interview','CV Review') DEFAULT NULL,
  `wdt_user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_request_appointments_student_name` (`student_name`),
  KEY `idx_date_requested` (`date_requested`),
  KEY `idx_time_requested` (`time_requested`),
  KEY `fk_appointments_coach` (`coach_id`),
  KEY `fk_appointments_wdt` (`wdt_user_id`),
  CONSTRAINT `fk_appointments_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaches` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_appointments_wdt` FOREIGN KEY (`wdt_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_request_appointments_student_name` FOREIGN KEY (`student_name`) REFERENCES `student_profiles` (`student_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.appointments: ~16 rows (approximately)
INSERT INTO `appointments` (`id`, `student_name`, `date_requested`, `time_requested`, `status`, `coach_id`, `service_type`, `wdt_user_id`) VALUES
	(1, 'Cassiopeia D. Obelidor', '2025-05-19', '14:30:00', 'Cancelled', 1, 'Career Coaching', 2),
	(2, 'Cassiopeia D. Obelidor', '2025-05-23', '11:00:00', 'Declined', 1, 'Career Coaching', 2),
	(3, 'Cassiopeia D. Obelidor', '2025-05-16', '12:30:00', 'Completed', 1, 'Mock Interview', 2),
	(4, 'Cassiopeia D. Obelidor', '2025-05-23', '11:30:00', 'Completed', 1, 'Mock Interview', 2),
	(5, 'Cassiopeia D. Obelidor', '2025-05-21', '12:00:00', 'Completed', 1, 'Mock Interview', 2),
	(6, 'Cassiopeia D. Obelidor', '2025-05-20', '11:30:00', 'Completed', 1, 'CV Review', 2),
	(7, 'Cassiopeia D. Obelidor', '2025-05-22', '11:30:00', 'Completed', 1, 'CV Review', 2),
	(8, 'Cassiopeia D. Obelidor', '2025-05-16', '12:00:00', 'Completed', 1, 'Career Coaching', 2),
	(9, 'Cassiopeia D. Obelidor', '2025-05-23', '10:30:00', 'Cancelled', 1, 'Mock Interview', 2),
	(10, 'Cassiopeia D. Obelidor', '2025-05-26', '11:30:00', 'Accepted', 1, 'CV Review', 2),
	(11, 'Cassiopeia D. Obelidor', '2025-05-21', '11:30:00', 'Pending', 1, 'CV Review', 2),
	(12, 'Cassiopeia D. Obelidor', '2025-05-23', '12:00:00', 'Declined', 1, 'Mock Interview', 2),
	(13, 'Cassiopeia D. Obelidor', '2025-05-30', '15:00:00', 'Pending', 1, 'Career Coaching', 2),
	(14, 'Cassiopeia D. Obelidor', '2025-05-30', '15:30:00', 'Pending', 1, 'Career Coaching', 2),
	(15, 'Cassiopeia D. Obelidor', '2025-05-30', '14:00:00', 'Pending', 1, 'CV Review', 2),
	(16, 'Cassiopeia D. Obelidor', '2025-05-30', '14:30:00', 'Pending', 1, 'CV Review', 2);

-- Dumping structure for table final_careercoaching.career_center_profile
CREATE TABLE IF NOT EXISTS `career_center_profile` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `contact` varchar(20) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `email` (`email`),
  CONSTRAINT `fk_career_center_email` FOREIGN KEY (`email`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_career_center_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.career_center_profile: ~1 rows (approximately)
INSERT INTO `career_center_profile` (`id`, `user_id`, `name`, `address`, `contact`, `email`) VALUES
	(1, '18-42978', 'Jo-ann Dancanlan', 'Naga City, Camarines Sur', '093798257653', 'joann.dancanlan@unc.edu.ph');

-- Dumping structure for table final_careercoaching.coaches
CREATE TABLE IF NOT EXISTS `coaches` (
  `id` int NOT NULL AUTO_INCREMENT,
  `coach_name` varchar(255) NOT NULL,
  `user_id` int NOT NULL,
  `profile_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_user_id` (`user_id`),
  KEY `fk_coaches_profile` (`profile_id`),
  CONSTRAINT `fk_coaches_profile` FOREIGN KEY (`profile_id`) REFERENCES `coach_profiles` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.coaches: ~1 rows (approximately)
INSERT INTO `coaches` (`id`, `coach_name`, `user_id`, `profile_id`) VALUES
	(1, 'Hilary Joan Prilles', 2, 1);

-- Dumping structure for table final_careercoaching.coach_cancellation_requests
CREATE TABLE IF NOT EXISTS `coach_cancellation_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `coach_id` int NOT NULL,
  `student_name` varchar(100) NOT NULL,
  `original_date` date NOT NULL,
  `original_time` time NOT NULL,
  `reason` text NOT NULL,
  `request_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `student_reply` text,
  `reply_date` datetime DEFAULT NULL,
  `status` enum('Pending','Accepted','Declined','Cancelled','Completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'Pending',
  PRIMARY KEY (`id`),
  KEY `fk_cancellation_appointment` (`appointment_id`),
  KEY `fk_cancellation_coach` (`coach_id`),
  KEY `fk_cancellation_student` (`student_name`),
  KEY `fk_cancellation_date` (`original_date`),
  KEY `fk_cancellation_time` (`original_time`),
  CONSTRAINT `fk_cancellation_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cancellation_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaches` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cancellation_date` FOREIGN KEY (`original_date`) REFERENCES `appointments` (`date_requested`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cancellation_student` FOREIGN KEY (`student_name`) REFERENCES `student_profiles` (`student_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cancellation_time` FOREIGN KEY (`original_time`) REFERENCES `appointments` (`time_requested`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.coach_cancellation_requests: ~2 rows (approximately)
INSERT INTO `coach_cancellation_requests` (`id`, `appointment_id`, `coach_id`, `student_name`, `original_date`, `original_time`, `reason`, `request_date`, `student_reply`, `reply_date`, `status`) VALUES
	(1, 9, 1, 'Cassiopeia D. Obelidor', '2025-05-23', '10:30:00', 'I sincerely apologize for the inconvenience, but I need to reschedule our session due to an unexpected medical emergency. I appreciate your understanding and will be happy to arrange a new time at your earliest convenience.', '2025-05-12 19:44:59', NULL, NULL, 'Pending'),
	(2, 1, 1, 'Cassiopeia D. Obelidor', '2025-05-19', '14:30:00', 'I regret to inform you that I’m experiencing unexpected transportation issues and won’t be able to make it to our session', '2025-05-20 19:33:48', NULL, NULL, 'Pending');

-- Dumping structure for table final_careercoaching.coach_profiles
CREATE TABLE IF NOT EXISTS `coach_profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `coach_name` varchar(100) NOT NULL,
  `position` varchar(100) DEFAULT NULL,
  `contact` varchar(20) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `address` varchar(55) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  KEY `fk_coach_profiles_user_id` (`user_id`),
  CONSTRAINT `fk_coach_profiles_email` FOREIGN KEY (`email`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_coach_profiles_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.coach_profiles: ~1 rows (approximately)
INSERT INTO `coach_profiles` (`id`, `user_id`, `coach_name`, `position`, `contact`, `email`, `address`) VALUES
	(1, '22-39847', 'Hilary Joan Prilles', NULL, '09385846923', 'hilaryjoan.prilles@unc.edu.ph', 'Naga City, Camarines Sur');

-- Dumping structure for table final_careercoaching.request_appointments
CREATE TABLE IF NOT EXISTS `request_appointments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `student_name` varchar(100) NOT NULL,
  `date_requested` date NOT NULL,
  `time_requested` time DEFAULT NULL,
  `status` enum('Pending','Accepted','Declined','Completed','Cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT 'Pending',
  `service_type` enum('Career Coaching','Mock Interview','CV Review') DEFAULT NULL,
  `coach_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_request_appointments_appointment` (`appointment_id`),
  KEY `fk_request_appointments_student` (`student_name`),
  KEY `idx_request_date` (`date_requested`),
  KEY `idx_status` (`status`),
  KEY `fk_request_appointments_coach` (`coach_id`),
  CONSTRAINT `fk_request_appointments_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_request_appointments_coach` FOREIGN KEY (`coach_id`) REFERENCES `coaches` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_request_appointments_student` FOREIGN KEY (`student_name`) REFERENCES `appointments` (`student_name`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.request_appointments: ~16 rows (approximately)
INSERT INTO `request_appointments` (`id`, `appointment_id`, `student_name`, `date_requested`, `time_requested`, `status`, `service_type`, `coach_id`) VALUES
	(1, 1, 'Cassiopeia D. Obelidor', '2025-05-19', '14:30:00', 'Cancelled', 'Career Coaching', 1),
	(2, 2, 'Cassiopeia D. Obelidor', '2025-05-23', '11:00:00', 'Declined', 'Career Coaching', 1),
	(3, 3, 'Cassiopeia D. Obelidor', '2025-05-16', '12:30:00', 'Completed', 'Mock Interview', 1),
	(4, 4, 'Cassiopeia D. Obelidor', '2025-05-23', '11:30:00', 'Completed', 'Mock Interview', 1),
	(5, 5, 'Cassiopeia D. Obelidor', '2025-05-21', '12:00:00', 'Completed', 'Mock Interview', 1),
	(6, 6, 'Cassiopeia D. Obelidor', '2025-05-20', '11:30:00', 'Completed', 'CV Review', 1),
	(7, 7, 'Cassiopeia D. Obelidor', '2025-05-22', '11:30:00', 'Completed', 'CV Review', 1),
	(8, 8, 'Cassiopeia D. Obelidor', '2025-05-16', '12:00:00', 'Completed', 'Career Coaching', 1),
	(9, 9, 'Cassiopeia D. Obelidor', '2025-05-23', '10:30:00', 'Cancelled', 'Mock Interview', 1),
	(10, 10, 'Cassiopeia D. Obelidor', '2025-05-26', '11:30:00', 'Accepted', 'CV Review', 1),
	(11, 11, 'Cassiopeia D. Obelidor', '2025-05-21', '11:30:00', 'Pending', 'CV Review', 1),
	(12, 12, 'Cassiopeia D. Obelidor', '2025-05-23', '12:00:00', 'Declined', 'Mock Interview', 1),
	(13, 13, 'Cassiopeia D. Obelidor', '2025-05-30', '15:00:00', 'Pending', 'Career Coaching', 1),
	(14, 14, 'Cassiopeia D. Obelidor', '2025-05-30', '15:30:00', 'Pending', 'Career Coaching', 1),
	(15, 15, 'Cassiopeia D. Obelidor', '2025-05-30', '14:00:00', 'Pending', 'CV Review', 1),
	(16, 16, 'Cassiopeia D. Obelidor', '2025-05-30', '14:30:00', 'Pending', 'CV Review', 1);

-- Dumping structure for table final_careercoaching.reschedule_requests
CREATE TABLE IF NOT EXISTS `reschedule_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `student_name` varchar(100) NOT NULL,
  `coach_id` int NOT NULL,
  `date_request` date NOT NULL,
  `time_request` time NOT NULL,
  `message` text NOT NULL,
  `request_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `coach_reply` text,
  `reply_date` datetime DEFAULT NULL,
  `reply_by` int DEFAULT NULL,
  `status` enum('Pending','Accepted','Decline') CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_reschedule_requests_appointment` (`appointment_id`),
  KEY `fk_reschedule_requests_student_name` (`student_name`),
  KEY `fk_reschedule_requests_date` (`date_request`),
  KEY `fk_reschedule_requests_time` (`time_request`),
  KEY `fk_reschedule_requests_coach` (`reply_by`),
  KEY `fk_reschedule_requests_coach_id` (`coach_id`),
  CONSTRAINT `fk_reschedule_reply_coach` FOREIGN KEY (`reply_by`) REFERENCES `coaches` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reschedule_requests_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `sessions` (`appointment_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reschedule_requests_coach` FOREIGN KEY (`reply_by`) REFERENCES `coaches` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_reschedule_requests_coach_id` FOREIGN KEY (`coach_id`) REFERENCES `coaches` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reschedule_requests_date` FOREIGN KEY (`date_request`) REFERENCES `sessions` (`session_date`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reschedule_requests_student_name` FOREIGN KEY (`student_name`) REFERENCES `appointments` (`student_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_reschedule_requests_time` FOREIGN KEY (`time_request`) REFERENCES `sessions` (`session_time`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reschedule_requests_ibfk_1` FOREIGN KEY (`reply_by`) REFERENCES `coaches` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.reschedule_requests: ~2 rows (approximately)
INSERT INTO `reschedule_requests` (`id`, `appointment_id`, `student_name`, `coach_id`, `date_request`, `time_request`, `message`, `request_date`, `coach_reply`, `reply_date`, `reply_by`, `status`) VALUES
	(1, 1, 'Cassiopeia D. Obelidor', 1, '2025-05-19', '14:30:00', 'Unfortunately, I’ve fallen ill unexpectedly and won’t be able to attend our scheduled session. Could we please reschedule for another time?', '2025-05-12 19:46:27', 'Your reschedule request has been accepted', '2025-05-12 19:47:19', 1, 'Accepted'),
	(2, 4, 'Cassiopeia D. Obelidor', 1, '2025-05-23', '11:30:00', 'Due to an urgent family matter, I need to request a rescheduling of our session. I truly apologize for the short notice and would appreciate it if we could find an alternative time.', '2025-05-12 19:46:44', NULL, NULL, NULL, 'Pending');

-- Dumping structure for table final_careercoaching.services
CREATE TABLE IF NOT EXISTS `services` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.services: ~3 rows (approximately)
INSERT INTO `services` (`id`, `name`, `description`) VALUES
	(1, 'Career Coaching', 'One-on-one career guidance sessions'),
	(2, 'Mock Interview', 'Practice interview sessions'),
	(3, 'CV Review', 'Resume/CV evaluation and feedback');

-- Dumping structure for table final_careercoaching.sessions
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `appointment_id` int NOT NULL,
  `session_date` date NOT NULL,
  `session_time` time DEFAULT NULL,
  `coach_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_appointment_id` (`appointment_id`),
  KEY `fk_sessions_date` (`session_date`),
  KEY `fk_sessions_time` (`session_time`),
  KEY `fk_sessions_coach` (`coach_id`),
  CONSTRAINT `fk_sessions_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sessions_coach` FOREIGN KEY (`coach_id`) REFERENCES `appointments` (`coach_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sessions_date` FOREIGN KEY (`session_date`) REFERENCES `appointments` (`date_requested`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_sessions_time` FOREIGN KEY (`session_time`) REFERENCES `appointments` (`time_requested`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.sessions: ~16 rows (approximately)
INSERT INTO `sessions` (`id`, `appointment_id`, `session_date`, `session_time`, `coach_id`) VALUES
	(1, 1, '2025-05-19', '14:30:00', 1),
	(2, 2, '2025-05-23', '11:00:00', 1),
	(3, 3, '2025-05-16', '12:30:00', 1),
	(4, 4, '2025-05-23', '11:30:00', 1),
	(5, 5, '2025-05-21', '12:00:00', 1),
	(6, 6, '2025-05-20', '11:30:00', 1),
	(7, 7, '2025-05-22', '11:30:00', 1),
	(8, 8, '2025-05-16', '12:00:00', 1),
	(9, 9, '2025-05-23', '10:30:00', 1),
	(10, 10, '2025-05-26', '11:30:00', 1),
	(26, 11, '2025-05-21', '11:30:00', 1),
	(27, 12, '2025-05-23', '12:00:00', 1),
	(30, 13, '2025-05-30', '15:00:00', 1),
	(31, 14, '2025-05-30', '15:30:00', 1),
	(32, 15, '2025-05-30', '14:00:00', 1),
	(33, 16, '2025-05-30', '14:30:00', 1);

-- Dumping structure for table final_careercoaching.student_notifications
CREATE TABLE IF NOT EXISTS `student_notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(20) NOT NULL,
  `notification_type` enum('Accepted Appointment','Declined Appointment','Accepted Reschedule Request','Declined Reschedule Request','Completed Appointment','Cancelled Appointment','Reschedule Requested','Cancellation Requested') NOT NULL,
  `appointment_id` int DEFAULT NULL,
  `service_type` enum('Career Coaching','Mock Interview','CV Review') DEFAULT NULL,
  `date_requested` date DEFAULT NULL,
  `time_requested` time DEFAULT NULL,
  `message` text,
  `status` enum('Unread','Read','Dismissed') NOT NULL DEFAULT 'Unread',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_student_notification_appointment` (`appointment_id`),
  KEY `fk_student_notification_user` (`user_id`),
  CONSTRAINT `fk_student_notification_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_student_notification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.student_notifications: ~13 rows (approximately)
INSERT INTO `student_notifications` (`id`, `user_id`, `notification_type`, `appointment_id`, `service_type`, `date_requested`, `time_requested`, `message`, `status`, `created_at`, `updated_at`) VALUES
	(1, '19-42344', 'Accepted Appointment', 1, 'Career Coaching', '2025-05-19', '14:30:00', 'Your appointment for Career Coaching on May 19, 2025 at 02:30 PM has been accepted by your Workforce Development Trainer.', 'Unread', '2025-05-12 19:43:28', NULL),
	(2, '19-42344', 'Accepted Appointment', 3, 'Mock Interview', '2025-05-16', '12:30:00', 'Your appointment for Mock Interview on May 16, 2025 at 12:30 PM has been accepted by your Workforce Development Trainer.', 'Unread', '2025-05-12 19:43:30', NULL),
	(3, '19-42344', 'Accepted Appointment', 5, 'Mock Interview', '2025-05-21', '12:00:00', 'Your appointment for Mock Interview on May 21, 2025 at 12:00 PM has been accepted by your Workforce Development Trainer.', 'Unread', '2025-05-12 19:43:33', NULL),
	(4, '19-42344', 'Accepted Appointment', 6, 'CV Review', '2025-05-20', '11:30:00', 'Your appointment for CV Review on May 20, 2025 at 11:30 AM has been accepted by your Workforce Development Trainer.', 'Unread', '2025-05-12 19:43:36', NULL),
	(5, '19-42344', 'Accepted Appointment', 7, 'CV Review', '2025-05-22', '11:30:00', 'Your appointment for CV Review on May 22, 2025 at 11:30 AM has been accepted by your Workforce Development Trainer.', 'Unread', '2025-05-12 19:43:38', NULL),
	(6, '19-42344', 'Accepted Appointment', 8, 'Career Coaching', '2025-05-16', '12:00:00', 'Your appointment for Career Coaching on May 16, 2025 at 12:00 PM has been accepted by your Workforce Development Trainer.', 'Unread', '2025-05-12 19:43:39', NULL),
	(7, '19-42344', 'Accepted Appointment', 9, 'Mock Interview', '2025-05-23', '10:30:00', 'Your appointment for Mock Interview on May 23, 2025 at 10:30 AM has been accepted by your Workforce Development Trainer.', 'Unread', '2025-05-12 19:43:45', NULL),
	(8, '19-42344', 'Accepted Appointment', 4, 'Mock Interview', '2025-05-23', '11:30:00', 'Your appointment for Mock Interview on May 23, 2025 at 11:30 AM has been accepted by your Workforce Development Trainer.', 'Unread', '2025-05-12 19:43:48', NULL),
	(9, '19-42344', 'Declined Appointment', 2, 'Career Coaching', '2025-05-23', '11:00:00', 'Your appointment for Career Coaching on May 23, 2025 at 11:00 AM has been declined by your Workforce Development Trainer. Please request another time.', 'Unread', '2025-05-12 19:45:11', NULL),
	(10, '19-42344', 'Declined Appointment', 12, 'Mock Interview', '2025-05-23', '12:00:00', 'Your appointment for Mock Interview on May 23, 2025 at 12:00 PM has been declined by your Workforce Development Trainer. Please request another time.', 'Unread', '2025-05-12 19:47:07', NULL),
	(11, '19-42344', 'Accepted Reschedule Request', 1, 'Career Coaching', '2025-05-19', '14:30:00', 'Your reschedule request has been accepted by your Workforce Development Trainer.', 'Unread', '2025-05-12 19:47:19', NULL),
	(12, '19-42344', 'Accepted Reschedule Request', 1, 'Career Coaching', '2025-05-19', '14:30:00', 'Your reschedule request has been accepted', 'Unread', '2025-05-12 19:47:19', NULL),
	(13, '19-42344', 'Accepted Appointment', 10, 'CV Review', '2025-05-26', '11:30:00', 'Your appointment for CV Review on May 26, 2025 at 11:30 AM has been accepted by your Workforce Development Trainer.', 'Read', '2025-05-12 19:48:16', '2025-06-09 15:07:31');

-- Dumping structure for table final_careercoaching.student_profiles
CREATE TABLE IF NOT EXISTS `student_profiles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `student_name` varchar(100) NOT NULL,
  `department` varchar(100) NOT NULL,
  `course` varchar(100) NOT NULL,
  `level` varchar(50) NOT NULL,
  `address` varchar(255) NOT NULL,
  `contact` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `gender` enum('Male','Female') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `email` (`email`),
  KEY `fk_student_profiles_student_name` (`student_name`),
  CONSTRAINT `fk_student_profiles_email` FOREIGN KEY (`email`) REFERENCES `users` (`email`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_student_profiles_student_name` FOREIGN KEY (`student_name`) REFERENCES `users` (`name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_student_profiles_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.student_profiles: ~1 rows (approximately)
INSERT INTO `student_profiles` (`id`, `user_id`, `student_name`, `department`, `course`, `level`, `address`, `contact`, `email`, `gender`) VALUES
	(1, '19-42344', 'Cassiopeia D. Obelidor', 'School of Computer and Information Sciences', 'Bachelor of Science in Information Technology', '4th Year', 'Naga City, Camarines Sur', '09387486832', 'cassiopeia.obelidor@unc.edu.ph', 'Female');

-- Dumping structure for table final_careercoaching.student_profile_pictures
CREATE TABLE IF NOT EXISTS `student_profile_pictures` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `image_path` varchar(255) NOT NULL,
  `mime_type` varchar(50) DEFAULT NULL,
  `file_size` int DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `fk_profile_pictures_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.student_profile_pictures: ~0 rows (approximately)

-- Dumping structure for table final_careercoaching.time_slots
CREATE TABLE IF NOT EXISTS `time_slots` (
  `id` int NOT NULL AUTO_INCREMENT,
  `coach_id` int NOT NULL,
  `date_slot` date NOT NULL,
  `day` enum('Monday','Tuesday','Wednesday','Thursday','Friday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_coach_id` (`coach_id`),
  CONSTRAINT `fk_coach_id` FOREIGN KEY (`coach_id`) REFERENCES `coaches` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.time_slots: ~98 rows (approximately)
INSERT INTO `time_slots` (`id`, `coach_id`, `date_slot`, `day`, `start_time`, `end_time`) VALUES
	(1, 1, '2025-05-12', 'Monday', '09:00:00', '09:30:00'),
	(2, 1, '2025-05-12', 'Monday', '09:30:00', '10:00:00'),
	(3, 1, '2025-05-12', 'Monday', '10:00:00', '10:30:00'),
	(4, 1, '2025-05-12', 'Monday', '10:30:00', '11:00:00'),
	(5, 1, '2025-05-13', 'Tuesday', '08:00:00', '08:30:00'),
	(6, 1, '2025-05-13', 'Tuesday', '08:30:00', '09:00:00'),
	(7, 1, '2025-05-13', 'Tuesday', '09:00:00', '09:30:00'),
	(8, 1, '2025-05-14', 'Wednesday', '10:00:00', '10:30:00'),
	(9, 1, '2025-05-14', 'Wednesday', '10:30:00', '11:00:00'),
	(10, 1, '2025-05-14', 'Wednesday', '11:00:00', '11:30:00'),
	(11, 1, '2025-05-14', 'Wednesday', '23:30:00', '24:00:00'),
	(12, 1, '2025-05-15', 'Thursday', '10:00:00', '10:30:00'),
	(13, 1, '2025-05-15', 'Thursday', '10:30:00', '11:00:00'),
	(14, 1, '2025-05-15', 'Thursday', '11:00:00', '11:30:00'),
	(15, 1, '2025-05-15', 'Thursday', '11:30:00', '12:00:00'),
	(16, 1, '2025-05-16', 'Friday', '12:00:00', '12:30:00'),
	(17, 1, '2025-05-16', 'Friday', '12:30:00', '13:00:00'),
	(18, 1, '2025-05-16', 'Friday', '13:00:00', '13:30:00'),
	(19, 1, '2025-05-16', 'Friday', '13:30:00', '14:00:00'),
	(20, 1, '2025-05-19', 'Monday', '13:00:00', '13:30:00'),
	(21, 1, '2025-05-19', 'Monday', '13:30:00', '14:00:00'),
	(22, 1, '2025-05-19', 'Monday', '14:00:00', '14:30:00'),
	(23, 1, '2025-05-19', 'Monday', '14:30:00', '15:00:00'),
	(24, 1, '2025-05-20', 'Tuesday', '23:00:00', '23:30:00'),
	(25, 1, '2025-05-20', 'Tuesday', '11:30:00', '12:00:00'),
	(26, 1, '2025-05-20', 'Tuesday', '12:00:00', '12:30:00'),
	(27, 1, '2025-05-20', 'Tuesday', '12:30:00', '13:00:00'),
	(28, 1, '2025-05-21', 'Wednesday', '11:00:00', '11:30:00'),
	(29, 1, '2025-05-21', 'Wednesday', '11:30:00', '12:00:00'),
	(30, 1, '2025-05-21', 'Wednesday', '12:00:00', '12:30:00'),
	(31, 1, '2025-05-22', 'Thursday', '10:00:00', '10:30:00'),
	(32, 1, '2025-05-22', 'Thursday', '10:30:00', '11:00:00'),
	(33, 1, '2025-05-22', 'Thursday', '11:00:00', '11:30:00'),
	(34, 1, '2025-05-22', 'Thursday', '11:30:00', '12:00:00'),
	(35, 1, '2025-05-22', 'Thursday', '12:00:00', '12:30:00'),
	(36, 1, '2025-05-23', 'Friday', '10:30:00', '11:00:00'),
	(37, 1, '2025-05-23', 'Friday', '11:00:00', '11:30:00'),
	(38, 1, '2025-05-23', 'Friday', '11:30:00', '12:00:00'),
	(39, 1, '2025-05-23', 'Friday', '12:00:00', '12:30:00'),
	(40, 1, '2025-05-26', 'Monday', '10:00:00', '10:30:00'),
	(41, 1, '2025-05-26', 'Monday', '10:30:00', '11:00:00'),
	(42, 1, '2025-05-26', 'Monday', '11:00:00', '11:30:00'),
	(43, 1, '2025-05-26', 'Monday', '11:30:00', '12:00:00'),
	(44, 1, '2025-05-27', 'Tuesday', '13:00:00', '13:30:00'),
	(45, 1, '2025-05-27', 'Tuesday', '13:30:00', '14:00:00'),
	(46, 1, '2025-05-27', 'Tuesday', '14:00:00', '14:30:00'),
	(47, 1, '2025-05-27', 'Tuesday', '14:30:00', '15:00:00'),
	(48, 1, '2025-05-27', 'Tuesday', '15:00:00', '15:30:00'),
	(49, 1, '2025-05-27', 'Tuesday', '15:30:00', '16:00:00'),
	(50, 1, '2025-05-28', 'Wednesday', '08:00:00', '08:30:00'),
	(51, 1, '2025-05-28', 'Wednesday', '08:30:00', '09:00:00'),
	(52, 1, '2025-05-28', 'Wednesday', '09:00:00', '09:30:00'),
	(53, 1, '2025-05-28', 'Wednesday', '09:30:00', '10:00:00'),
	(54, 1, '2025-05-29', 'Thursday', '10:00:00', '10:30:00'),
	(55, 1, '2025-05-29', 'Thursday', '10:30:00', '11:00:00'),
	(56, 1, '2025-05-29', 'Thursday', '11:00:00', '11:30:00'),
	(57, 1, '2025-05-29', 'Thursday', '11:30:00', '12:00:00'),
	(58, 1, '2025-05-29', 'Thursday', '12:00:00', '12:30:00'),
	(59, 1, '2025-05-30', 'Friday', '14:00:00', '14:30:00'),
	(60, 1, '2025-05-30', 'Friday', '14:30:00', '15:00:00'),
	(61, 1, '2025-05-30', 'Friday', '15:00:00', '15:30:00'),
	(62, 1, '2025-05-30', 'Friday', '15:30:00', '16:00:00'),
	(63, 1, '2025-05-30', 'Friday', '16:30:00', '17:00:00'),
	(64, 1, '2025-05-30', 'Friday', '17:00:00', '17:30:00'),
	(65, 1, '2025-06-02', 'Monday', '10:00:00', '10:30:00'),
	(66, 1, '2025-06-02', 'Monday', '10:30:00', '11:00:00'),
	(67, 1, '2025-06-02', 'Monday', '11:00:00', '11:30:00'),
	(68, 1, '2025-06-02', 'Monday', '11:30:00', '12:00:00'),
	(69, 1, '2025-06-02', 'Monday', '12:00:00', '12:30:00'),
	(70, 1, '2025-06-03', 'Tuesday', '09:00:00', '09:30:00'),
	(71, 1, '2025-06-03', 'Tuesday', '09:30:00', '10:00:00'),
	(72, 1, '2025-06-03', 'Tuesday', '10:00:00', '10:30:00'),
	(73, 1, '2025-06-03', 'Tuesday', '10:30:00', '11:00:00'),
	(74, 1, '2025-06-04', 'Wednesday', '09:00:00', '09:30:00'),
	(75, 1, '2025-06-04', 'Wednesday', '09:30:00', '10:00:00'),
	(76, 1, '2025-06-04', 'Wednesday', '10:00:00', '10:30:00'),
	(77, 1, '2025-06-04', 'Wednesday', '10:30:00', '11:00:00'),
	(78, 1, '2025-06-05', 'Thursday', '14:00:00', '14:30:00'),
	(79, 1, '2025-06-05', 'Thursday', '14:30:00', '15:00:00'),
	(80, 1, '2025-06-05', 'Thursday', '15:00:00', '15:30:00'),
	(81, 1, '2025-06-05', 'Thursday', '15:30:00', '16:00:00'),
	(82, 1, '2025-06-06', 'Friday', '10:00:00', '10:30:00'),
	(83, 1, '2025-06-06', 'Friday', '10:30:00', '11:00:00'),
	(84, 1, '2025-06-06', 'Friday', '11:00:00', '11:30:00'),
	(85, 1, '2025-06-06', 'Friday', '11:30:00', '12:00:00'),
	(86, 1, '2025-06-06', 'Friday', '12:00:00', '12:30:00'),
	(87, 1, '2025-06-09', 'Monday', '10:00:00', '10:30:00'),
	(88, 1, '2025-06-09', 'Monday', '10:30:00', '11:00:00'),
	(89, 1, '2025-06-09', 'Monday', '11:00:00', '11:30:00'),
	(90, 1, '2025-06-10', 'Tuesday', '13:00:00', '13:30:00'),
	(91, 1, '2025-06-10', 'Tuesday', '13:30:00', '14:00:00'),
	(92, 1, '2025-06-10', 'Tuesday', '14:00:00', '14:30:00'),
	(93, 1, '2025-06-10', 'Tuesday', '14:30:00', '15:00:00'),
	(94, 1, '2025-06-11', 'Wednesday', '12:00:00', '12:30:00'),
	(95, 1, '2025-06-11', 'Wednesday', '12:30:00', '13:00:00'),
	(96, 1, '2025-06-11', 'Wednesday', '13:00:00', '13:30:00'),
	(97, 1, '2025-06-11', 'Wednesday', '13:30:00', '14:00:00'),
	(98, 1, '2025-06-12', 'Thursday', '08:00:00', '08:30:00');

-- Dumping structure for table final_careercoaching.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(30) NOT NULL COMMENT 'Student, Workforce Development Trainer, Career Center Director',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.users: ~3 rows (approximately)
INSERT INTO `users` (`id`, `user_id`, `name`, `email`, `password`, `role`) VALUES
	(1, '19-42344', 'Cassiopeia D. Obelidor', 'cassiopeia.obelidor@unc.edu.ph', '$2y$10$o.JxcphKUthzxWh9DFkr.OxYCLDN5gEw1kC2abIR9swlK3SrdgCdO', 'Student'),
	(2, '22-39847', 'Hilary Joan Prilles', 'hilaryjoan.prilles@unc.edu.ph', '$2y$10$k47EX7/nh55C3njrRSNnOO7srmfior4T/KFu6ZyyclnP6eSu4yvKi', 'Workforce Development Trainer'),
	(5, '18-42978', 'Jo-ann Dancanlan', 'joann.dancanlan@unc.edu.ph', '$2y$10$j3zUE0/fpzE/qOJyZzsWy.bAJWzB7Oe2ARKMnQkGIzRO/KiRqPmAK', 'Career Center Director');

-- Dumping structure for view final_careercoaching.vw_course_engagement
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vw_course_engagement` (
	`course` VARCHAR(100) NOT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`total_students` BIGINT(19) NOT NULL,
	`active_students` BIGINT(19) NOT NULL,
	`total_appointments` BIGINT(19) NOT NULL,
	`completed_appointments` DECIMAL(23,0) NULL,
	`cancelled_appointments` DECIMAL(23,0) NULL,
	`pending_appointments` DECIMAL(23,0) NULL,
	`engagement_rate` DECIMAL(26,2) NULL,
	`completion_rate` DECIMAL(29,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for view final_careercoaching.vw_department_engagement
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vw_department_engagement` (
	`department` VARCHAR(100) NOT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`total_students` BIGINT(19) NOT NULL,
	`active_students` BIGINT(19) NOT NULL,
	`total_appointments` BIGINT(19) NOT NULL,
	`completed_appointments` DECIMAL(23,0) NULL,
	`cancelled_appointments` DECIMAL(23,0) NULL,
	`pending_appointments` DECIMAL(23,0) NULL,
	`engagement_rate` DECIMAL(26,2) NULL,
	`completion_rate` DECIMAL(29,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for view final_careercoaching.vw_department_engagement_by_year
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vw_department_engagement_by_year` (
	`year` INT(10) NULL,
	`department` VARCHAR(100) NOT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`total_students` BIGINT(19) NOT NULL,
	`active_students` BIGINT(19) NOT NULL,
	`total_appointments` BIGINT(19) NOT NULL,
	`completed_appointments` DECIMAL(23,0) NULL,
	`cancelled_appointments` DECIMAL(23,0) NULL,
	`pending_appointments` DECIMAL(23,0) NULL,
	`engagement_rate` DECIMAL(26,2) NULL,
	`completion_rate` DECIMAL(29,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for view final_careercoaching.vw_department_engagement_with_years
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vw_department_engagement_with_years` (
	`department` VARCHAR(100) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`total_students` BIGINT(19) NULL,
	`active_students` BIGINT(19) NULL,
	`total_appointments` BIGINT(19) NULL,
	`completed_appointments` DECIMAL(23,0) NULL,
	`cancelled_appointments` DECIMAL(23,0) NULL,
	`pending_appointments` DECIMAL(23,0) NULL,
	`engagement_rate` DECIMAL(26,2) NULL,
	`completion_rate` DECIMAL(29,2) NULL,
	`most_active_year` VARCHAR(50) NULL COLLATE 'utf8mb4_0900_ai_ci',
	`percentage_of_total` DECIMAL(32,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for view final_careercoaching.vw_gender_engagement
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vw_gender_engagement` (
	`gender` ENUM('Male','Female') NOT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`total_students` BIGINT(19) NOT NULL,
	`active_students` BIGINT(19) NOT NULL,
	`total_appointments` BIGINT(19) NOT NULL,
	`completed_appointments` DECIMAL(23,0) NULL,
	`cancelled_appointments` DECIMAL(23,0) NULL,
	`pending_appointments` DECIMAL(23,0) NULL,
	`engagement_rate` DECIMAL(26,2) NULL,
	`completion_rate` DECIMAL(29,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for view final_careercoaching.vw_service_analytics
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vw_service_analytics` (
	`service_type` VARCHAR(15) NOT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`total_appointments` BIGINT(19) NOT NULL,
	`completed_appointments` DECIMAL(23,0) NULL,
	`cancelled_appointments` DECIMAL(23,0) NULL,
	`pending_appointments` DECIMAL(23,0) NULL,
	`completion_rate` DECIMAL(29,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for view final_careercoaching.vw_year_level_engagement
-- Creating temporary table to overcome VIEW dependency errors
CREATE TABLE `vw_year_level_engagement` (
	`year_level` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_0900_ai_ci',
	`total_students` BIGINT(19) NOT NULL,
	`active_students` BIGINT(19) NOT NULL,
	`total_appointments` BIGINT(19) NOT NULL,
	`completed_appointments` DECIMAL(23,0) NULL,
	`student_distribution` DECIMAL(26,2) NULL,
	`engagement_percentage` DECIMAL(26,2) NULL
) ENGINE=MyISAM;

-- Dumping structure for table final_careercoaching.wdt_notifications
CREATE TABLE IF NOT EXISTS `wdt_notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `student_name` varchar(100) NOT NULL,
  `notification_type` enum('New Appointment','Reschedule Request','Cancellation','Other') NOT NULL,
  `appointment_id` int DEFAULT NULL,
  `service_type` enum('Career Coaching','Mock Interview','CV Review') DEFAULT NULL,
  `date_requested` date DEFAULT NULL,
  `time_requested` time DEFAULT NULL,
  `message` text,
  `status` enum('Unread','Read','Dismissed') NOT NULL DEFAULT 'Unread',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_notification_coach` (`user_id`),
  KEY `fk_notification_student` (`student_name`),
  KEY `fk_notification_appointment` (`appointment_id`),
  CONSTRAINT `fk_notification_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_notification_student` FOREIGN KEY (`student_name`) REFERENCES `student_profiles` (`student_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Dumping data for table final_careercoaching.wdt_notifications: ~18 rows (approximately)
INSERT INTO `wdt_notifications` (`id`, `user_id`, `student_name`, `notification_type`, `appointment_id`, `service_type`, `date_requested`, `time_requested`, `message`, `status`, `created_at`, `updated_at`) VALUES
	(1, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 1, 'Career Coaching', '2025-05-19', '14:30:00', 'New appointment request for Career Coaching on May 19, 2025 at 02:30 PM', 'Unread', '2025-05-12 19:41:47', NULL),
	(2, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 2, 'Career Coaching', '2025-05-23', '11:00:00', 'New appointment request for Career Coaching on May 23, 2025 at 11:00 AM', 'Unread', '2025-05-12 19:41:53', NULL),
	(3, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 3, 'Mock Interview', '2025-05-16', '12:30:00', 'New appointment request for Mock Interview on May 16, 2025 at 12:30 PM', 'Unread', '2025-05-12 19:42:05', NULL),
	(4, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 4, 'Mock Interview', '2025-05-23', '11:30:00', 'New appointment request for Mock Interview on May 23, 2025 at 11:30 AM', 'Unread', '2025-05-12 19:42:15', NULL),
	(5, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 5, 'Mock Interview', '2025-05-21', '12:00:00', 'New appointment request for Mock Interview on May 21, 2025 at 12:00 PM', 'Unread', '2025-05-12 19:42:19', NULL),
	(6, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 6, 'CV Review', '2025-05-20', '11:30:00', 'New appointment request for CV Review on May 20, 2025 at 11:30 AM', 'Unread', '2025-05-12 19:42:32', NULL),
	(7, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 7, 'CV Review', '2025-05-22', '11:30:00', 'New appointment request for CV Review on May 22, 2025 at 11:30 AM', 'Unread', '2025-05-12 19:42:35', NULL),
	(8, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 8, 'Career Coaching', '2025-05-16', '12:00:00', 'New appointment request for Career Coaching on May 16, 2025 at 12:00 PM', 'Unread', '2025-05-12 19:42:48', NULL),
	(9, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 9, 'Mock Interview', '2025-05-23', '10:30:00', 'New appointment request for Mock Interview on May 23, 2025 at 10:30 AM', 'Unread', '2025-05-12 19:42:59', NULL),
	(10, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 10, 'CV Review', '2025-05-26', '11:30:00', 'New appointment request for CV Review on May 26, 2025 at 11:30 AM', 'Unread', '2025-05-12 19:43:14', NULL),
	(11, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 11, 'CV Review', '2025-05-21', '11:30:00', 'New appointment request for CV Review on May 21, 2025 at 11:30 AM', 'Unread', '2025-05-12 19:45:40', NULL),
	(12, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 12, 'Mock Interview', '2025-05-23', '12:00:00', 'New appointment request for Mock Interview on May 23, 2025 at 12:00 PM', 'Unread', '2025-05-12 19:45:53', NULL),
	(13, '22-39847', 'Cassiopeia D. Obelidor', 'Reschedule Request', 1, 'Career Coaching', '2025-05-19', '14:30:00', 'Reschedule request from Cassiopeia D. Obelidor. Original: May 19, 2025 at 02:30 PM. Requested: May 19, 2025 at 02:30 PM. Reason: Unfortunately, I’ve fallen ill unexpectedly and won’t be able to attend our scheduled session. Could we please reschedule for another time?', 'Unread', '2025-05-12 19:46:27', NULL),
	(14, '22-39847', 'Cassiopeia D. Obelidor', 'Reschedule Request', 4, 'Mock Interview', '2025-05-23', '11:30:00', 'Reschedule request from Cassiopeia D. Obelidor. Original: May 23, 2025 at 11:30 AM. Requested: May 23, 2025 at 11:30 AM. Reason: Due to an urgent family matter, I need to request a rescheduling of our session. I truly apologize for the short notice and would appreciate it if we could find an alternative time.', 'Unread', '2025-05-12 19:46:44', NULL),
	(15, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 13, 'Career Coaching', '2025-05-30', '15:00:00', 'New appointment request for Career Coaching on May 30, 2025 at 03:00 PM', 'Unread', '2025-05-19 09:12:29', NULL),
	(16, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 14, 'Career Coaching', '2025-05-30', '15:30:00', 'New appointment request for Career Coaching on May 30, 2025 at 03:30 PM', 'Unread', '2025-05-19 09:12:32', NULL),
	(17, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 15, 'CV Review', '2025-05-30', '14:00:00', 'New appointment request for CV Review on May 30, 2025 at 02:00 PM', 'Unread', '2025-05-19 09:16:54', NULL),
	(18, '22-39847', 'Cassiopeia D. Obelidor', 'New Appointment', 16, 'CV Review', '2025-05-30', '14:30:00', 'New appointment request for CV Review on May 30, 2025 at 02:30 PM', 'Unread', '2025-05-19 09:16:58', NULL);

-- Dumping structure for trigger final_careercoaching.after_appointment_accepted
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_appointment_accepted` AFTER UPDATE ON `appointments` FOR EACH ROW BEGIN
    DECLARE student_user_id VARCHAR(50);
    
    -- Check if the status was changed to 'Accepted'
    IF OLD.status != 'Accepted' AND NEW.status = 'Accepted' THEN
        -- Get the student's user_id
        SELECT u.user_id INTO student_user_id
        FROM users u
        JOIN student_profiles sp ON u.user_id = sp.user_id
        WHERE sp.student_name = NEW.student_name;
        
        -- Insert a notification into student_notifications
        INSERT INTO student_notifications (
            user_id,
            notification_type,
            appointment_id,
            service_type,
            date_requested,
            time_requested,
            message,
            status,
            created_at
        ) VALUES (
            student_user_id,
            'Accepted Appointment',
            NEW.id,
            NEW.service_type,
            NEW.date_requested,
            NEW.time_requested,
            CONCAT('Your appointment for ', NEW.service_type, ' on ', 
                   DATE_FORMAT(NEW.date_requested, '%M %d, %Y'), 
                   ' at ', TIME_FORMAT(NEW.time_requested, '%h:%i %p'), 
                   ' has been accepted by your Workforce Development Trainer.'),
            'Unread',
            NOW()
        );
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.after_appointment_declined
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_appointment_declined` AFTER UPDATE ON `appointments` FOR EACH ROW BEGIN
    DECLARE student_user_id VARCHAR(50);
    
    -- Check if the status was changed to 'Declined'
    IF OLD.status != 'Declined' AND NEW.status = 'Declined' THEN
        -- Get the student's user_id
        SELECT u.user_id INTO student_user_id
        FROM users u
        JOIN student_profiles sp ON u.user_id = sp.user_id
        WHERE sp.student_name = NEW.student_name;
        
        -- Insert a notification into student_notifications
        INSERT INTO student_notifications (
            user_id,
            notification_type,
            appointment_id,
            service_type,
            date_requested,
            time_requested,
            message,
            status,
            created_at
        ) VALUES (
            student_user_id,
            'Declined Appointment',
            NEW.id,
            NEW.service_type,
            NEW.date_requested,
            NEW.time_requested,
            CONCAT('Your appointment for ', NEW.service_type, ' on ', 
                   DATE_FORMAT(NEW.date_requested, '%M %d, %Y'), 
                   ' at ', TIME_FORMAT(NEW.time_requested, '%h:%i %p'), 
                   ' has been declined by your Workforce Development Trainer. Please request another time.'),
            'Unread',
            NOW()
        );
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.after_appointment_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_appointment_insert` AFTER INSERT ON `appointments` FOR EACH ROW BEGIN
    DECLARE coach_user_id VARCHAR(50);
    
    -- Get the coach's user_id from the users table
    SELECT u.user_id INTO coach_user_id
    FROM users u
    JOIN coaches c ON u.id = c.user_id
    WHERE c.id = NEW.coach_id;
    
    -- Insert a notification into the wdt_notifications table
    INSERT INTO wdt_notifications (
        user_id,
        student_name,
        notification_type,
        appointment_id,
        service_type,
        date_requested,
        time_requested,
        message,
        status,
        created_at
    ) VALUES (
        coach_user_id,
        NEW.student_name,
        'New Appointment',
        NEW.id,
        NEW.service_type,
        NEW.date_requested,
        NEW.time_requested,
        CONCAT('New appointment request for ', NEW.service_type, ' on ', 
               DATE_FORMAT(NEW.date_requested, '%M %d, %Y'), 
               ' at ', TIME_FORMAT(NEW.time_requested, '%h:%i %p')),
        'Unread',
        NOW()
    );
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.after_request_appointment_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_request_appointment_insert` AFTER INSERT ON `request_appointments` FOR EACH ROW BEGIN
    -- Always update the appointments table to match request_appointments
    UPDATE appointments
    SET
        status = NEW.status,
        date_requested = NEW.date_requested,
        time_requested = NEW.time_requested,
        service_type = NEW.service_type
    WHERE id = NEW.appointment_id;
    
    -- Insert or update session regardless of status
    INSERT INTO sessions (appointment_id, session_date, session_time, coach_id)
    SELECT 
        NEW.appointment_id,
        NEW.date_requested,
        NEW.time_requested,
        a.coach_id
    FROM appointments a
    WHERE a.id = NEW.appointment_id
    ON DUPLICATE KEY UPDATE
        session_date = NEW.date_requested,
        session_time = NEW.time_requested;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.after_request_appointment_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_request_appointment_update` AFTER UPDATE ON `request_appointments` FOR EACH ROW BEGIN
    -- Update appointments table to match request_appointments
    UPDATE appointments
    SET
        status = NEW.status,
        date_requested = NEW.date_requested,
        time_requested = NEW.time_requested,
        service_type = NEW.service_type
    WHERE id = NEW.appointment_id;
    
    -- Always insert or update session
    INSERT INTO sessions (appointment_id, session_date, session_time, coach_id)
    SELECT 
        NEW.appointment_id,
        NEW.date_requested,
        NEW.time_requested,
        a.coach_id
    FROM appointments a
    WHERE a.id = NEW.appointment_id
    ON DUPLICATE KEY UPDATE
        session_date = NEW.date_requested,
        session_time = NEW.time_requested;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.after_reschedule_request_accepted
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_reschedule_request_accepted` AFTER UPDATE ON `reschedule_requests` FOR EACH ROW BEGIN
    DECLARE student_user_id VARCHAR(50);
    DECLARE service_type_val VARCHAR(20);
    DECLARE original_date DATE;
    DECLARE original_time TIME;
    
    -- Check if the status was changed to 'Accepted'
    IF OLD.status != 'Accepted' AND NEW.status = 'Accepted' THEN
        -- Get the student's user_id
        SELECT u.user_id INTO student_user_id
        FROM users u
        JOIN student_profiles sp ON u.user_id = sp.user_id
        WHERE sp.student_name = NEW.student_name;
        
        -- Get the original appointment details
        SELECT a.service_type INTO service_type_val
        FROM appointments a
        WHERE a.id = NEW.appointment_id;
        
        -- Get the original date and time from the sessions table
        SELECT s.session_date, s.session_time 
        INTO original_date, original_time
        FROM sessions s
        WHERE s.appointment_id = NEW.appointment_id;
        
        -- Insert a notification into student_notifications
        INSERT INTO student_notifications (
            user_id,
            notification_type,
            appointment_id,
            service_type,
            date_requested,
            time_requested,
            message,
            status,
            created_at
        ) VALUES (
            student_user_id,
            'Accepted Reschedule Request',
            NEW.appointment_id,
            service_type_val,
            original_date,
            original_time,
            CONCAT('Your reschedule request has been accepted by your Workforce Development Trainer.'),
            'Unread',
            NOW()
        );
        
        -- Update the appointment with the new date and time
        UPDATE appointments
        SET 
            date_requested = NEW.date_request,
            time_requested = NEW.time_request
        WHERE id = NEW.appointment_id;
        
        -- Update the session with the new date and time
        UPDATE sessions
        SET 
            session_date = NEW.date_request,
            session_time = NEW.time_request
        WHERE appointment_id = NEW.appointment_id;
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.after_reschedule_request_declined
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_reschedule_request_declined` AFTER UPDATE ON `reschedule_requests` FOR EACH ROW BEGIN
    DECLARE student_user_id VARCHAR(50);
    DECLARE service_type_val VARCHAR(20);
    DECLARE original_date DATE;
    DECLARE original_time TIME;
    
    -- Check if the status was changed to 'Decline'
    IF OLD.status != 'Decline' AND NEW.status = 'Decline' THEN
        -- Get the student's user_id
        SELECT u.user_id INTO student_user_id
        FROM users u
        JOIN student_profiles sp ON u.user_id = sp.user_id
        WHERE sp.student_name = NEW.student_name;
        
        -- Get the original appointment details
        SELECT a.date_requested, a.time_requested, a.service_type 
        INTO original_date, original_time, service_type_val
        FROM appointments a
        WHERE a.id = NEW.appointment_id;
        
        -- Insert a notification into student_notifications
        INSERT INTO student_notifications (
            user_id,
            notification_type,
            appointment_id,
            service_type,
            date_requested,
            time_requested,
            message,
            status,
            created_at
        ) VALUES (
            student_user_id,
            'Declined Reschedule Request',
            NEW.appointment_id,
            service_type_val,
            original_date,
            original_time,
            CONCAT('Your reschedule request has been declined. Please keep your original appointment on ', 
                   DATE_FORMAT(original_date, '%M %d, %Y'), 
                   ' at ', TIME_FORMAT(original_time, '%h:%i %p'), '.'),
            'Unread',
            NOW()
        );
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.after_reschedule_request_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `after_reschedule_request_insert` AFTER INSERT ON `reschedule_requests` FOR EACH ROW BEGIN
    -- Get the original appointment details and coach user_id
    DECLARE service_type_val VARCHAR(20);
    DECLARE coach_user_id_val VARCHAR(50);
    DECLARE original_date DATE;
    DECLARE original_time TIME;
    
    -- Get appointment details
    SELECT a.service_type, a.date_requested, a.time_requested, u.user_id
    INTO service_type_val, original_date, original_time, coach_user_id_val
    FROM appointments a
    JOIN coaches c ON a.coach_id = c.id
    JOIN users u ON c.user_id = u.id
    WHERE a.id = NEW.appointment_id;
    
    -- Insert the notification into wdt_notifications
    INSERT INTO wdt_notifications (
        user_id,
        student_name,
        notification_type,
        appointment_id,
        service_type,
        date_requested,
        time_requested,
        message,
        status,
        created_at
    ) VALUES (
        coach_user_id_val,
        NEW.student_name,
        'Reschedule Request',
        NEW.appointment_id,
        service_type_val,
        NEW.date_request,
        NEW.time_request,
        CONCAT('Reschedule request from ', NEW.student_name, 
               '. Original: ', DATE_FORMAT(original_date, '%M %d, %Y'), ' at ', 
               TIME_FORMAT(original_time, '%h:%i %p'), 
               '. Requested: ', DATE_FORMAT(NEW.date_request, '%M %d, %Y'), ' at ',
               TIME_FORMAT(NEW.time_request, '%h:%i %p'), 
               '. Reason: ', NEW.message),
        'Unread',
        NOW()
    );
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.after_user_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_user_insert` AFTER INSERT ON `users` FOR EACH ROW BEGIN
    -- Only execute if triggers are not disabled
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS = FALSE THEN
        -- Handle Student role
        IF NEW.role = 'Student' THEN
            INSERT INTO student_profiles (user_id, student_name, email)
            VALUES (NEW.user_id, NEW.name, NEW.email);
            
        -- Handle Workforce Development Trainer role
        ELSEIF NEW.role = 'Workforce Development Trainer' THEN
            -- First insert into coach_profiles
            INSERT INTO coach_profiles (user_id, coach_name, email)
            VALUES (NEW.user_id, NEW.name, NEW.email);
            
            -- Then insert into coaches table
            INSERT INTO coaches (coach_name, user_id, profile_id)
            VALUES (
                NEW.name,
                NEW.id,
                LAST_INSERT_ID()
            );
            
        -- Handle Career Center Director role
        ELSEIF NEW.role = 'Career Center Director' THEN
            INSERT INTO career_center_profile (user_id, name, email)
            VALUES (NEW.user_id, NEW.name, NEW.email);
        END IF;
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.after_user_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `after_user_update` AFTER UPDATE ON `users` FOR EACH ROW BEGIN
    -- Only execute if triggers are not disabled
    IF @DISABLE_TRIGGERS IS NULL OR @DISABLE_TRIGGERS = FALSE THEN
        -- Update student profile if user is a student
        IF NEW.role = 'Student' THEN
            UPDATE student_profiles 
            SET student_name = NEW.name, email = NEW.email
            WHERE user_id = NEW.user_id;
        END IF;
        
        -- Update coach profile if user is a Workforce Development Trainer
        IF NEW.role = 'Workforce Development Trainer' THEN
            UPDATE coach_profiles 
            SET coach_name = NEW.name, email = NEW.email
            WHERE user_id = NEW.user_id;
            
            UPDATE coaches
            SET coach_name = NEW.name
            WHERE user_id = NEW.id;
        END IF;
        
        -- Update career center profile if user is Career Center Director
        IF NEW.role = 'Career Center Director' THEN
            UPDATE career_center_profile 
            SET name = NEW.name, email = NEW.email
            WHERE user_id = NEW.user_id;
        END IF;
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.before_appointment_submission
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `before_appointment_submission` BEFORE INSERT ON `appointments` FOR EACH ROW BEGIN
    DECLARE student_exists INT;
    DECLARE coach_exists INT;
    DECLARE valid_time_slot INT;
    
    -- Check if the student exists
    SELECT COUNT(*) INTO student_exists 
    FROM student_profiles 
    WHERE student_name = NEW.student_name;
    
    IF student_exists = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid student: Student does not exist';
    END IF;
    
    -- Check if the coach exists
    SELECT COUNT(*) INTO coach_exists 
    FROM coaches 
    WHERE id = NEW.coach_id;
    
    IF coach_exists = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid coach: Coach does not exist';
    END IF;
    
    -- Check if the time slot is available (optional)
    SELECT COUNT(*) INTO valid_time_slot
    FROM time_slots
    WHERE coach_id = NEW.coach_id
    AND date_slot = NEW.date_requested
    AND start_time <= NEW.time_requested
    AND end_time >= NEW.time_requested;
    
    IF valid_time_slot = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid time slot: The selected time is not available';
    END IF;
    
    -- Set default status if not provided
    IF NEW.status IS NULL THEN
        SET NEW.status = 'Pending';
    END IF;
    
    -- Validate service type
    IF NEW.service_type NOT IN ('Career Coaching', 'Mock Interview', 'CV Review') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Invalid service type';
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger final_careercoaching.before_appointment_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `before_appointment_update` BEFORE UPDATE ON `appointments` FOR EACH ROW BEGIN
    -- Check if the status is being changed differently from request_appointments
    DECLARE request_status VARCHAR(20);
    
    SELECT status INTO request_status 
    FROM request_appointments 
    WHERE appointment_id = NEW.id LIMIT 1;
    
    -- If status is being changed and doesn't match request_appointments, prevent it
    IF NEW.status != OLD.status AND request_status IS NOT NULL AND NEW.status != request_status THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Status must be updated through request_appointments table';
    END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for view final_careercoaching.vw_course_engagement
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_course_engagement`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_course_engagement` AS select `sp`.`course` AS `course`,count(distinct `sp`.`user_id`) AS `total_students`,count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) AS `active_students`,count(`a`.`id`) AS `total_appointments`,sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) AS `completed_appointments`,sum((case when (`a`.`status` = 'Cancelled') then 1 else 0 end)) AS `cancelled_appointments`,sum((case when (`a`.`status` = 'Pending') then 1 else 0 end)) AS `pending_appointments`,round(((count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) * 100.0) / nullif(count(distinct `sp`.`user_id`),0)),2) AS `engagement_rate`,round(((sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) * 100.0) / nullif(count(`a`.`id`),0)),2) AS `completion_rate` from (`student_profiles` `sp` left join `appointments` `a` on((`sp`.`student_name` = `a`.`student_name`))) group by `sp`.`course`;

-- Dumping structure for view final_careercoaching.vw_department_engagement
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_department_engagement`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_department_engagement` AS select ifnull(`sp`.`department`,'Unknown') AS `department`,count(distinct `sp`.`user_id`) AS `total_students`,count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) AS `active_students`,count(`a`.`id`) AS `total_appointments`,sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) AS `completed_appointments`,sum((case when (`a`.`status` = 'Cancelled') then 1 else 0 end)) AS `cancelled_appointments`,sum((case when (`a`.`status` = 'Pending') then 1 else 0 end)) AS `pending_appointments`,round(((count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) * 100.0) / nullif(count(distinct `sp`.`user_id`),0)),2) AS `engagement_rate`,round(((sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) * 100.0) / nullif(count(`a`.`id`),0)),2) AS `completion_rate` from (`student_profiles` `sp` left join `appointments` `a` on((`sp`.`student_name` = `a`.`student_name`))) group by `sp`.`department`;

-- Dumping structure for view final_careercoaching.vw_department_engagement_by_year
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_department_engagement_by_year`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_department_engagement_by_year` AS select year(`a`.`date_requested`) AS `year`,`sp`.`department` AS `department`,count(distinct `sp`.`user_id`) AS `total_students`,count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) AS `active_students`,count(`a`.`id`) AS `total_appointments`,sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) AS `completed_appointments`,sum((case when (`a`.`status` = 'Cancelled') then 1 else 0 end)) AS `cancelled_appointments`,sum((case when (`a`.`status` = 'Pending') then 1 else 0 end)) AS `pending_appointments`,round(((count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) * 100.0) / nullif(count(distinct `sp`.`user_id`),0)),2) AS `engagement_rate`,round(((sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) * 100.0) / nullif(count(`a`.`id`),0)),2) AS `completion_rate` from (`student_profiles` `sp` left join `appointments` `a` on((`sp`.`student_name` = `a`.`student_name`))) where (`a`.`date_requested` is not null) group by year(`a`.`date_requested`),`sp`.`department`;

-- Dumping structure for view final_careercoaching.vw_department_engagement_with_years
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_department_engagement_with_years`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_department_engagement_with_years` AS select `d`.`department` AS `department`,`d`.`total_students` AS `total_students`,`d`.`active_students` AS `active_students`,`d`.`total_appointments` AS `total_appointments`,`d`.`completed_appointments` AS `completed_appointments`,`d`.`cancelled_appointments` AS `cancelled_appointments`,`d`.`pending_appointments` AS `pending_appointments`,`d`.`engagement_rate` AS `engagement_rate`,`d`.`completion_rate` AS `completion_rate`,(select `sp`.`level` from (`student_profiles` `sp` join `appointments` `a` on((`sp`.`student_name` = `a`.`student_name`))) where (`sp`.`department` = `d`.`department`) group by `sp`.`level` order by count(distinct `sp`.`user_id`) desc limit 1) AS `most_active_year`,round(((`d`.`engagement_rate` / (select sum(`vw_department_engagement`.`engagement_rate`) from `vw_department_engagement`)) * 100),2) AS `percentage_of_total` from `vw_department_engagement` `d`;

-- Dumping structure for view final_careercoaching.vw_gender_engagement
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_gender_engagement`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_gender_engagement` AS select `sp`.`gender` AS `gender`,count(distinct `sp`.`user_id`) AS `total_students`,count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) AS `active_students`,count(`a`.`id`) AS `total_appointments`,sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) AS `completed_appointments`,sum((case when (`a`.`status` = 'Cancelled') then 1 else 0 end)) AS `cancelled_appointments`,sum((case when (`a`.`status` = 'Pending') then 1 else 0 end)) AS `pending_appointments`,round(((count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) * 100.0) / count(distinct `sp`.`user_id`)),2) AS `engagement_rate`,round(((sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) * 100.0) / nullif(count(`a`.`id`),0)),2) AS `completion_rate` from (`student_profiles` `sp` left join `appointments` `a` on((`sp`.`student_name` = `a`.`student_name`))) where (`sp`.`gender` in ('Male','Female')) group by `sp`.`gender`;

-- Dumping structure for view final_careercoaching.vw_service_analytics
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_service_analytics`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_service_analytics` AS select ifnull(`a`.`service_type`,'Unknown') AS `service_type`,count(`a`.`id`) AS `total_appointments`,sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) AS `completed_appointments`,sum((case when (`a`.`status` = 'Cancelled') then 1 else 0 end)) AS `cancelled_appointments`,sum((case when (`a`.`status` = 'Pending') then 1 else 0 end)) AS `pending_appointments`,round(((sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) / count(`a`.`id`)) * 100),2) AS `completion_rate` from `appointments` `a` group by `a`.`service_type`;

-- Dumping structure for view final_careercoaching.vw_year_level_engagement
-- Removing temporary table and create final VIEW structure
DROP TABLE IF EXISTS `vw_year_level_engagement`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vw_year_level_engagement` AS with `year_level_stats` as (select `sp`.`level` AS `year_level`,count(distinct `sp`.`user_id`) AS `total_students`,count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) AS `active_students`,count(`a`.`id`) AS `total_appointments`,sum((case when (`a`.`status` = 'Completed') then 1 else 0 end)) AS `completed_appointments` from (`student_profiles` `sp` left join `appointments` `a` on((`sp`.`student_name` = `a`.`student_name`))) where (`sp`.`level` is not null) group by `sp`.`level`), `total_stats` as (select count(distinct `sp`.`user_id`) AS `total_all_students`,count(distinct (case when (`a`.`id` is not null) then `sp`.`user_id` end)) AS `total_active_students` from (`student_profiles` `sp` left join `appointments` `a` on((`sp`.`student_name` = `a`.`student_name`))) where (`sp`.`level` is not null)) select `y`.`year_level` AS `year_level`,`y`.`total_students` AS `total_students`,`y`.`active_students` AS `active_students`,`y`.`total_appointments` AS `total_appointments`,`y`.`completed_appointments` AS `completed_appointments`,round(((`y`.`total_students` * 100.0) / nullif(`t`.`total_all_students`,0)),2) AS `student_distribution`,round(((`y`.`active_students` * 100.0) / nullif(`t`.`total_active_students`,0)),2) AS `engagement_percentage` from (`year_level_stats` `y` join `total_stats` `t`);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
