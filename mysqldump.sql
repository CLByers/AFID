-- MySQL dump 10.13  Distrib 5.7.16, for Linux (x86_64)
--
-- Host: localhost    Database: AFID
-- ------------------------------------------------------
-- Server version	5.7.16-0ubuntu0.16.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `tblComparison`
--

DROP TABLE IF EXISTS `tblComparison`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tblComparison` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `faceImageFK1` int(11) DEFAULT NULL,
  `faceImageFK2` int(11) DEFAULT NULL,
  `distance` float DEFAULT NULL,
  PRIMARY KEY (`pk`),
  KEY `fk_face1` (`faceImageFK1`),
  KEY `fk_face2` (`faceImageFK2`),
  CONSTRAINT `fk_face1` FOREIGN KEY (`faceImageFK1`) REFERENCES `tblFaceImage` (`pk`) ON DELETE CASCADE,
  CONSTRAINT `fk_face2` FOREIGN KEY (`faceImageFK2`) REFERENCES `tblFaceImage` (`pk`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=444154 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tblFaceImage`
--

DROP TABLE IF EXISTS `tblFaceImage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tblFaceImage` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `sourceImageFK` int(11) NOT NULL,
  `boundingRectLeft` int(11) DEFAULT NULL,
  `boundingRectTop` int(11) DEFAULT NULL,
  `boundingRectWidth` int(11) DEFAULT NULL,
  `boundingRectHeight` int(11) DEFAULT NULL,
  `knownIdentityFK` int(11) DEFAULT NULL,
  `imageData` longblob,
  `representationData` longblob,
  `imageURL` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`pk`),
  KEY `sourceImageFK` (`sourceImageFK`),
  KEY `tblFaceImage_IDfk` (`knownIdentityFK`),
  CONSTRAINT `tblFaceImage_ibfk_1` FOREIGN KEY (`sourceImageFK`) REFERENCES `tblSourceImage` (`pk`),
  CONSTRAINT `tblFaceImage_ibfk_2` FOREIGN KEY (`knownIdentityFK`) REFERENCES `tblKnownIdentity` (`pk`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2405 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tblKnownIdentity`
--

DROP TABLE IF EXISTS `tblKnownIdentity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tblKnownIdentity` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `firstName` varchar(30) DEFAULT NULL,
  `lastName` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tblSourceImage`
--

DROP TABLE IF EXISTS `tblSourceImage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tblSourceImage` (
  `pk` int(11) NOT NULL AUTO_INCREMENT,
  `imageURL` varchar(200) DEFAULT NULL,
  `metaURL` varchar(200) DEFAULT NULL,
  `lastProcessedDate` datetime DEFAULT NULL,
  `sourceTitle` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`pk`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `vwComparedFaceImages`
--

DROP TABLE IF EXISTS `vwComparedFaceImages`;
/*!50001 DROP VIEW IF EXISTS `vwComparedFaceImages`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vwComparedFaceImages` AS SELECT 
 1 AS `PK1`,
 1 AS `url1`,
 1 AS `PK2`,
 1 AS `url2`,
 1 AS `distance`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwComparisonsNeedingDistance`
--

DROP TABLE IF EXISTS `vwComparisonsNeedingDistance`;
/*!50001 DROP VIEW IF EXISTS `vwComparisonsNeedingDistance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vwComparisonsNeedingDistance` AS SELECT 
 1 AS `pk`,
 1 AS `faceImageFK1`,
 1 AS `faceImageFK2`,
 1 AS `rep1`,
 1 AS `rep2`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwFacesData`
--

DROP TABLE IF EXISTS `vwFacesData`;
/*!50001 DROP VIEW IF EXISTS `vwFacesData`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vwFacesData` AS SELECT 
 1 AS `pk`,
 1 AS `imageURL`,
 1 AS `sourceImageURL`,
 1 AS `sourceTitle`,
 1 AS `sourceFK`,
 1 AS `boundingRectLeft`,
 1 AS `boundingRectTop`,
 1 AS `boundingRectWidth`,
 1 AS `boundingRectHeight`,
 1 AS `minDistance`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwMinDistance`
--

DROP TABLE IF EXISTS `vwMinDistance`;
/*!50001 DROP VIEW IF EXISTS `vwMinDistance`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vwMinDistance` AS SELECT 
 1 AS `pk`,
 1 AS `minDistance`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwRepresentationsNeedingComparison`
--

DROP TABLE IF EXISTS `vwRepresentationsNeedingComparison`;
/*!50001 DROP VIEW IF EXISTS `vwRepresentationsNeedingComparison`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vwRepresentationsNeedingComparison` AS SELECT 
 1 AS `pk`,
 1 AS `faceImageFK1`,
 1 AS `faceImageFK2`,
 1 AS `rep1`,
 1 AS `rep2`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vwSourceNetworkData`
--

DROP TABLE IF EXISTS `vwSourceNetworkData`;
/*!50001 DROP VIEW IF EXISTS `vwSourceNetworkData`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `vwSourceNetworkData` AS SELECT 
 1 AS `source1`,
 1 AS `source2`,
 1 AS `connections`*/;
SET character_set_client = @saved_cs_client;


--
-- Definition for sp_FillTblComparison
--
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `spFillTblComparison`()
BEGIN
insert tblComparison(faceImageFK1, faceImageFK2)
select f1.pk as faceImageFK1, f2.pk as faceImageFK2
                 from tblFaceImage f1
                 inner join tblFaceImage f2
                 on f2.pk < f1.pk
                 left join tblComparison tc
                 on tc.faceImageFK1 = f1.pk
				and tc.faceImageFK2 = f2.pk
				where tc.pk is null;
END$$
DELIMITER ;

--
-- Final view structure for view `vwComparedFaceImages`
--

/*!50001 DROP VIEW IF EXISTS `vwComparedFaceImages`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwComparedFaceImages` AS (select `tfi1`.`pk` AS `PK1`,`tfi1`.`imageURL` AS `url1`,`tfi2`.`pk` AS `PK2`,`tfi2`.`imageURL` AS `url2`,`tc`.`distance` AS `distance` from ((`tblComparison` `tc` join `tblFaceImage` `tfi1` on((`tfi1`.`pk` = `tc`.`faceImageFK1`))) join `tblFaceImage` `tfi2` on((`tfi2`.`pk` = `tc`.`faceImageFK2`))) where (`tc`.`distance` < 1.0)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwComparisonsNeedingDistance`
--

/*!50001 DROP VIEW IF EXISTS `vwComparisonsNeedingDistance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwComparisonsNeedingDistance` AS (select `tc`.`pk` AS `pk`,`tc`.`faceImageFK1` AS `faceImageFK1`,`tc`.`faceImageFK2` AS `faceImageFK2`,`f1`.`representationData` AS `rep1`,`f2`.`representationData` AS `rep2` from ((`tblComparison` `tc` join `tblFaceImage` `f1` on((`f1`.`pk` = `tc`.`faceImageFK1`))) join `tblFaceImage` `f2` on((`f2`.`pk` = `tc`.`faceImageFK2`))) where isnull(`tc`.`distance`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwFacesData`
--

/*!50001 DROP VIEW IF EXISTS `vwFacesData`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwFacesData` AS (select `tf`.`pk` AS `pk`,`tf`.`imageURL` AS `imageURL`,`tsi`.`imageURL` AS `sourceImageURL`,`tsi`.`sourceTitle` AS `sourceTitle`,`tsi`.`pk` AS `sourceFK`,`tf`.`boundingRectLeft` AS `boundingRectLeft`,`tf`.`boundingRectTop` AS `boundingRectTop`,`tf`.`boundingRectWidth` AS `boundingRectWidth`,`tf`.`boundingRectHeight` AS `boundingRectHeight`,`vmd`.`minDistance` AS `minDistance` from ((`tblFaceImage` `tf` left join `tblSourceImage` `tsi` on((`tsi`.`pk` = `tf`.`sourceImageFK`))) left join `vwMinDistance` `vmd` on((`vmd`.`pk` = `tf`.`pk`)))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwMinDistance`
--

/*!50001 DROP VIEW IF EXISTS `vwMinDistance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwMinDistance` AS (select `tfd`.`pk` AS `pk`,min(`tc`.`distance`) AS `minDistance` from (`tblFaceImage` `tfd` left join `tblComparison` `tc` on((`tfd`.`pk` in (`tc`.`faceImageFK1`,`tc`.`faceImageFK2`)))) where (`tc`.`distance` < 0.4) group by `tfd`.`pk`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwRepresentationsNeedingComparison`
--

/*!50001 DROP VIEW IF EXISTS `vwRepresentationsNeedingComparison`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwRepresentationsNeedingComparison` AS (select `tc`.`pk` AS `pk`,`tc`.`faceImageFK1` AS `faceImageFK1`,`tc`.`faceImageFK2` AS `faceImageFK2`,`f1`.`representationData` AS `rep1`,`f2`.`representationData` AS `rep2` from ((`tblComparison` `tc` join `tblFaceImage` `f1` on((`f1`.`pk` = `tc`.`faceImageFK1`))) join `tblFaceImage` `f2` on((`f2`.`pk` = `tc`.`faceImageFK2`))) where isnull(`tc`.`distance`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vwSourceNetworkData`
--

/*!50001 DROP VIEW IF EXISTS `vwSourceNetworkData`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vwSourceNetworkData` AS (select `tsi1`.`pk` AS `source1`,`tsi2`.`pk` AS `source2`,count(0) AS `connections` from ((((`tblComparison` `tc` left join `tblFaceImage` `tfi1` on((`tfi1`.`pk` = `tc`.`faceImageFK1`))) left join `tblFaceImage` `tfi2` on((`tfi2`.`pk` = `tc`.`faceImageFK2`))) left join `tblSourceImage` `tsi1` on((`tsi1`.`pk` = `tfi1`.`sourceImageFK`))) left join `tblSourceImage` `tsi2` on((`tsi2`.`pk` = `tfi2`.`sourceImageFK`))) where ((`tsi2`.`pk` is not null) and (`tc`.`distance` < 0.3)) group by `tsi1`.`pk`,`tsi2`.`pk`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;



-- Dump completed on 2016-11-10  9:35:54
