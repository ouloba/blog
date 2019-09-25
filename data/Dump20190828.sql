CREATE DATABASE  IF NOT EXISTS `blogs` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci */;
USE `blogs`;
-- MySQL dump 10.13  Distrib 8.0.16, for Win64 (x86_64)
--
-- Host: localhost    Database: blogs
-- ------------------------------------------------------
-- Server version	8.0.13

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `accounts` (
  `userid` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '用',
  `account` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `nickname` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reg_date` datetime DEFAULT NULL,
  `reg_ip` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `login_date` datetime DEFAULT NULL,
  `login_ip` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `score` bigint(20) DEFAULT '0',
  `insurescore` bigint(20) DEFAULT '0',
  `insurepassword` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `loginpassword` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `dynamicpassword` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `phonepassword` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `spreadids` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci DEFAULT '{}',
  `spreadid` int(11) DEFAULT '0',
  `headurl` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `faceid` int(11) DEFAULT '0',
  `sex` smallint(6) DEFAULT '2',
  `isbot` tinyint(4) DEFAULT '0',
  `right` int(11) DEFAULT '0',
  `scorepoint` bigint(20) DEFAULT '0' COMMENT '用于计算输赢',
  `forbid` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`userid`),
  UNIQUE KEY `account_UNIQUE` (`account`),
  KEY `spread_index` (`spreadid`)
) ENGINE=InnoDB AUTO_INCREMENT=100000 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci COMMENT='账户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `awards`
--

DROP TABLE IF EXISTS `awards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `awards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) DEFAULT NULL,
  `total_score` bigint(20) DEFAULT NULL,
  `week_team_score` bigint(20) DEFAULT NULL,
  `user_score` bigint(20) DEFAULT NULL,
  `award` bigint(20) DEFAULT NULL,
  `state` tinyint(4) DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `awards`
--

LOCK TABLES `awards` WRITE;
/*!40000 ALTER TABLE `awards` DISABLE KEYS */;
INSERT INTO `awards` VALUES (6,100000,0,0,0,0,0,'2019-07-08 00:00:01','2019-07-14 23:59:59'),(7,100151,0,0,0,0,0,'2019-07-08 00:00:00','2019-07-14 23:59:59');
/*!40000 ALTER TABLE `awards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `betorders`
--

DROP TABLE IF EXISTS `betorders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `betorders` (
  `orderid` int(10) unsigned NOT NULL,
  `ordertime` datetime DEFAULT NULL,
  `bet` int(11) DEFAULT NULL,
  `userid` int(11) DEFAULT NULL,
  `gameid` int(11) DEFAULT NULL,
  `kindid` smallint(6) DEFAULT NULL,
  `chairid` smallint(6) DEFAULT NULL,
  `result` smallint(6) DEFAULT NULL COMMENT '1-成功， 2-失败',
  `nowscore` bigint(20) DEFAULT '0',
  PRIMARY KEY (`orderid`),
  UNIQUE KEY `orderid_UNIQUE` (`orderid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `betorders`
--

LOCK TABLES `betorders` WRITE;
/*!40000 ALTER TABLE `betorders` DISABLE KEYS */;
/*!40000 ALTER TABLE `betorders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cashouts`
--

DROP TABLE IF EXISTS `cashouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `cashouts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `userid` int(11) DEFAULT NULL,
  `score` bigint(20) DEFAULT NULL,
  `rmb` int(11) DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  `state` tinyint(4) DEFAULT NULL,
  `cardnum` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `reqtype` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashouts`
--

LOCK TABLES `cashouts` WRITE;
/*!40000 ALTER TABLE `cashouts` DISABLE KEYS */;
/*!40000 ALTER TABLE `cashouts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `documents` (
  `id` bigint(20) unsigned NOT NULL,
  `post_author` bigint(20) DEFAULT NULL,
  `post_date` datetime DEFAULT NULL,
  `post_content` longtext,
  `post_title` text,
  `post_status` int(11) DEFAULT '0',
  `category` varchar(1024) DEFAULT '' COMMENT '类别',
  `post_desc` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='博客';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (2386433,10000,'2019-08-28 16:56:45','<p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">由于使用者过少，MongoDB 宣布弃用&nbsp;Perl 驱动。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><img height=\"308\" src=\"https://oscimg.oschina.net/oscnet/78932948bec304f32cc43e70b94565f361f.jpg\" width=\"700\" class=\"zoom-in-cursor\"/></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">MongoDB&nbsp;高级产品经理&nbsp;Scott L&#39;Hommedieu 表示，在过去几年中，团队调查了用户群体，并与使用 Perl 驱动的公司进行交流，得到的反馈是，用户对于通过&nbsp;Perl 驱动支持 MongoDB 新功能的要求极少。另一边，MongoDB 社区自 2018 年以来，没有用户询问过 Perl 驱动相关的问题。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">这就意味着，现在只有极少数人在使用 MongoDB Perl 驱动，而只有当人们使用的时候，驱动才有存在的意义。对于项目的开发团队来的，工程师的时间与精力需要专注于能够让大多数用户受益的地方，比如 Perl 的现代化替代品 Python、Go 与 Node.js。所以&nbsp;<a href=\"https://www.mongodb.com/blog/post/the-mongodb-perl-driver-is-being-deprecated\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">MongoDB 决定不再维护 Perl 驱动</a>。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">MongoDB Perl 驱动将以优雅、社区友好的方式弃用，具体是在 2.2.0 版本发布的 12 个月后正式结束生命周期（2020&nbsp;年 8 月13 日）。在这 12 个月中，开发团队将为该驱动提供关键/安全修复程序。在 eof 之后，如果有任何希望维护 Perl 驱动的 Perl 社区成员，可以与 MongoDB 社区管理员联系，源码可以 fork 出来。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">此公告还附带了 MongoDB Perl 2.2.0 GA 版本的更新说明，更新内容主要是：</p><ul style=\"box-sizing: inherit; padding: 0px 0px 0px 2.5em;\" class=\" list-paddingleft-2\"><li><p>支持 MongoDB 4.2 的功能，包括分布式事务、更新命令管道和 $merge 聚合状态。</p></li><li><p>可重试读操作。</p></li><li><p>会话的“with_transaction”回调 API。</p></li></ul><h4 style=\"box-sizing: inherit; font-family: &quot;PingFang SC&quot;, &quot;Helvetica Neue&quot;, &quot;Microsoft YaHei UI&quot;, &quot;Microsoft YaHei&quot;, &quot;Noto Sans CJK SC&quot;, Sathu, EucrosiaUPC, Arial, Helvetica, sans-serif; line-height: 1.28571em; margin: 1.2em 0px 0.8em; font-weight: 500; padding: 0px; font-size: 18px; border: none;\"><span style=\"box-sizing: inherit; font-weight: 700;\">Perl 还能行吗？</span></h4><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">Perl 是一种高级、通用、直译式、动态的编程语言，它汲取了 C、sed、awk 与 Shell 脚本以及众多其它编程语言的特性，其中最重要的特性是内置正则表达式，以及强大的第三方代码库 CPAN（the Comprehensive Perl Archive Network，全面的 Perl 存档网络）。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><img alt=\"\" src=\"https://oscimg.oschina.net/oscnet/7325f45e60973baf60350015d29ce6259b9.jpg\" class=\"zoom-in-cursor\"/></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">Perl 的特点是追求简单，它的一个追求是：</p><blockquote style=\"box-sizing: inherit; position: relative; font-size: 15px; background: rgb(246, 246, 246); margin: 20px 0px; padding: 16px 24px 16px 48px; border: none;\"><p style=\"box-sizing: inherit; margin-top: 2px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">Easy things should be easy, and hard things should be possible.</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 0px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">简单的事情就让它简单，困难的事情就让它变得可解。</span></p></blockquote><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">开发者直言：“解决一个一般的问题只用几行代码就搞定，而面对稍微复杂一点的问题，代码行数也不会超过一屏。”</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">另一方面，Perl 的灵活性也很强，它被称为脚本语言中的“瑞士军刀”，Perl 的中心思想可以概括为：</p><blockquote style=\"box-sizing: inherit; position: relative; font-size: 15px; background: rgb(246, 246, 246); margin: 20px 0px; padding: 16px 24px 16px 48px; border: none;\"><p style=\"box-sizing: inherit; margin-top: 2px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">There&#39;s More Than One Way To Do It.（TMTOWTDI）</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 0px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">可以用多种方法实现。</span></p></blockquote><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">Perl 可以运行在超过 100 种计算机平台上，适用性非常广泛，从大型机到便携设备、从快速原型创建到大规模可扩展开发都可以一把梭，除 CGI 以外，它还被用于图形编程、系统管理、网络编程、金融、生物以及其它领域。然而从近来各种消息来看，Perl 似乎不太行了。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">上个月 TIOBE 编程语言排行榜中，TIOBE 官方使用的标题是：Perl is one of the victims of Python&#39;s hype（<a href=\"https://www.oschina.net/news/108034/tiobe-index-201907\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">Perl 成为过分炒作 Python 的受害者</a>）。Perl 当时在 TIOBE 榜单中位于第 19 位，这是有史以来的最低的一次，要知道，在 2005 年 Perl 曾坐过第三名的位置，而当时其&nbsp;Ratings 指数超过 10%。另一方面，Perl 6 被单独统计，而它仅排在&nbsp;93 位。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">Python 等同类型语言的崛起，加上&nbsp;Perl 的非常规语法及其不明确的未来（Perl 5 与 Perl 6 之间的差异），对&nbsp;Perl 造成了极大的伤害。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">另一方面，为科技专业人群提供分析的网站&nbsp;Dice Insights 近期指出，目前开发人员普遍使用其它语言构建网站，Perl 的采用变得越来越窄，同时&nbsp;Perl 本身几乎没有进行积极开发，所以&nbsp;<a href=\"https://www.oschina.net/news/108665/5-programming-languages-probably-doomed\" target=\"_blank\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">Perl 将会衰落</a>。关于 Perl 没有采用率与本身没有积极发展，这一点在前边描述的 MongoDB Perl 驱动缺乏活力中似乎就可以直观感受到。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">Perl 还能行吗，你怎么看？</p><h3 style=\"box-sizing: inherit; line-height: 1.28571em; margin: 0px 0px 1rem; padding: 0px; font-size: 1.28571rem;\">相关链接</h3><ul class=\"link-list list-paddingleft-2\" style=\"list-style-type: square;\"><li><p>Perl 的详细介绍：<a href=\"https://www.oschina.net/p/perl\" target=\"_blank\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">点击查看</a></p></li><li><p>Perl 的下载地址：<a href=\"http://www.perl.org/get.html\" target=\"_blank\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">点击下载</a></p></li><li><p><br/></p></li></ul><p></p><p><br/></p>','由于使用者过少，MongoDB 宣布弃用 Perl 驱动。',0,'新闻','由于使用者过少，MongoDB 宣布弃用 Perl 驱动。MongoDB 高级产品经理 Scott L\'Hommedieu 表示，在过去几年中，团队调查了用户群体，并与使用 Perl 驱动的公司进行交流，得到的反馈是，用户对于通过 Perl 驱动支持 MongoDB 新功能的要求极少。另一边，MongoDB 社区自 2018 年以来，没有用户询问过 Perl'),(2386434,10000,'2019-08-28 17:04:29','<p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px; color: rgb(51, 51, 51); font-family: &quot;Pingfang SC&quot;, STHeiti, &quot;Lantinghei SC&quot;, &quot;Open Sans&quot;, Arial, &quot;Hiragino Sans GB&quot;, &quot;Microsoft YaHei&quot;, &quot;WenQuanYi Micro Hei&quot;, SimSun, sans-serif; white-space: normal; background-color: rgb(255, 255, 255);\">5G 已经被热炒得家喻户晓，但与其对标的 Wi-Fi 新技术标准—— Wi-Fi 6 却可能有着更好的经济和技术前景，Wi-Fi 6 也称为 802.11ax，比过去的 Wi-Fi 技术更好，速度更快能跟 5G 对标，连接性更好，信号覆盖和稳定性都更好，同时支持的用户数更多，而且还比 5G 基站成本更低。在工厂、仓库、码头等商用场景，Wi-Fi 6 相比 5G 具备明显的成本优势和安全属性（数据和设备都在本地），但对于个人用户来说，是否值得为 Wi-Fi 6 买单呢？</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px; color: rgb(51, 51, 51); font-family: &quot;Pingfang SC&quot;, STHeiti, &quot;Lantinghei SC&quot;, &quot;Open Sans&quot;, Arial, &quot;Hiragino Sans GB&quot;, &quot;Microsoft YaHei&quot;, &quot;WenQuanYi Micro Hei&quot;, SimSun, sans-serif; white-space: normal; background-color: rgb(255, 255, 255);\">买一个物美价廉的 Wi-Fi 6 路由器，提前在家庭、办公和商业环境体验 5G 极速，这听起来不错，而且已经有不少路由器厂商在学生返校的旺季“抢鲜”上架 Wi-Fi 6 路由器，未来几个月内想必大多数路由器厂商就会加入 Wi-Fi 6 路由器的宣传造势中，但是对于普通消费者来说，现在买 Wi-Fi 6 路由器值得吗？</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px; color: rgb(51, 51, 51); font-family: &quot;Pingfang SC&quot;, STHeiti, &quot;Lantinghei SC&quot;, &quot;Open Sans&quot;, Arial, &quot;Hiragino Sans GB&quot;, &quot;Microsoft YaHei&quot;, &quot;WenQuanYi Micro Hei&quot;, SimSun, sans-serif; white-space: normal; background-color: rgb(255, 255, 255);\">从亚马逊的价格监测来看，Wi-Fi 6 路由器的价格平均比同类 Wi-Fi 5（802.11ac）路由器高出 100 到 150 美元。虽然 Wi-Fi 6 可能有助于解决机场，体育场和公共交通站等公共场所的部分无线网络的问题（例如信号覆盖，连接稳定性等），但目前它还不会给家庭用户带来肉眼可见的好处。原因如下：</p><h4 style=\"box-sizing: inherit; font-family: &quot;PingFang SC&quot;, &quot;Helvetica Neue&quot;, &quot;Microsoft YaHei UI&quot;, &quot;Microsoft YaHei&quot;, &quot;Noto Sans CJK SC&quot;, Sathu, EucrosiaUPC, Arial, Helvetica, sans-serif; line-height: 1.28571em; margin: 1.2em 0px 0.8em; font-weight: 500; padding: 0px; font-size: 18px; border: none; color: rgb(51, 51, 51); white-space: normal; background-color: rgb(255, 255, 255);\"><span style=\"box-sizing: inherit; font-weight: 700;\">现有的大多数移动设备都无法发挥 Wi-Fi 6 路由器性能</span></h4><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px; color: rgb(51, 51, 51); font-family: &quot;Pingfang SC&quot;, STHeiti, &quot;Lantinghei SC&quot;, &quot;Open Sans&quot;, Arial, &quot;Hiragino Sans GB&quot;, &quot;Microsoft YaHei&quot;, &quot;WenQuanYi Micro Hei&quot;, SimSun, sans-serif; white-space: normal; background-color: rgb(255, 255, 255);\">任何连接到 Wi-Fi 6 路由器的设备设备，如果没有搭载最新的 11ax 芯片，都无法发挥 Wi-Fi 6 的性能优势，而你为 Wi-Fi 6 技术额外支付的费用，基本也就打了水漂。而各种流媒体设备、手机、平板电脑、无线耳机、笔记本电脑、打印机、智能音箱以及其他智能家居技术，搭载 11ax / Wi-Fi 6 芯片还需要很难长的一个普及周期。目前，市场上只有少数 11ax 设备，但预计未来几年支持 11ax 的产品的出货量将快速放大。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px; color: rgb(51, 51, 51); font-family: &quot;Pingfang SC&quot;, STHeiti, &quot;Lantinghei SC&quot;, &quot;Open Sans&quot;, Arial, &quot;Hiragino Sans GB&quot;, &quot;Microsoft YaHei&quot;, &quot;WenQuanYi Micro Hei&quot;, SimSun, sans-serif; white-space: normal; background-color: rgb(255, 255, 255);\"><img alt=\"WiFi6è·¯ç±å¨\" src=\"https://www.ctocio.com/wp-content/uploads/2019/08/%E5%B1%8F%E5%B9%95%E5%BF%AB%E7%85%A7-2019-08-25-17.15.44-1.png\" class=\"zoom-in-cursor\"/></p><h4 style=\"box-sizing: inherit; font-family: &quot;PingFang SC&quot;, &quot;Helvetica Neue&quot;, &quot;Microsoft YaHei UI&quot;, &quot;Microsoft YaHei&quot;, &quot;Noto Sans CJK SC&quot;, Sathu, EucrosiaUPC, Arial, Helvetica, sans-serif; line-height: 1.28571em; margin: 1.2em 0px 0.8em; font-weight: 500; padding: 0px; font-size: 18px; border: none; color: rgb(51, 51, 51); white-space: normal; background-color: rgb(255, 255, 255);\"><span style=\"box-sizing: inherit; font-weight: 700;\">Wi-Fi 6 速度更快带宽高，但前提是你连接了 50 多台设备</span></h4><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px; color: rgb(51, 51, 51); font-family: &quot;Pingfang SC&quot;, STHeiti, &quot;Lantinghei SC&quot;, &quot;Open Sans&quot;, Arial, &quot;Hiragino Sans GB&quot;, &quot;Microsoft YaHei&quot;, &quot;WenQuanYi Micro Hei&quot;, SimSun, sans-serif; white-space: normal; background-color: rgb(255, 255, 255);\">Wi-Fi 6 的带宽有望达到 10,000 Mbps 的速度（10GB/秒，万兆网速）。听起来真的很快，但你要搞清楚，这个网速只是局域网速度，而你使用手机或笔记本电脑的速度，主要瓶颈是云服务或者流媒体内容提供商的广域网速度，换而言之，除了局域网内部的数据交换外，对于互联网应用，Wi-Fi 6 的高带宽帮不了你什么。但是 Wi-Fi 6 的高带宽对于多用户多设备环境来说非常有用，例如播放一个流媒体 4K 高清视频，你只需要 20 Mbps 带宽，因此，即使你家中有四台电视同时播放 4K 运动，也只需要 80Mbps，这个 Wi-Fi 5 就能满足，但是如果你的应用场景连接的用户数高达 50 人，那么 Wi-Fi 6 的带宽优势就体现出来了。但是 Wi-Fi 6 的带宽数据只是一个理论值，对于家庭用户来说，要想获得接近理论值的网速，就必须非常靠近路由器，大约在 5 米以内，而且中间还不能有墙壁或家具遮挡。</p><h4 style=\"box-sizing: inherit; font-family: &quot;PingFang SC&quot;, &quot;Helvetica Neue&quot;, &quot;Microsoft YaHei UI&quot;, &quot;Microsoft YaHei&quot;, &quot;Noto Sans CJK SC&quot;, Sathu, EucrosiaUPC, Arial, Helvetica, sans-serif; line-height: 1.28571em; margin: 1.2em 0px 0.8em; font-weight: 500; padding: 0px; font-size: 18px; border: none; color: rgb(51, 51, 51); white-space: normal; background-color: rgb(255, 255, 255);\"><span style=\"box-sizing: inherit; font-weight: 700;\">普及还需要 3 年或更长时间</span></h4><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px; color: rgb(51, 51, 51); font-family: &quot;Pingfang SC&quot;, STHeiti, &quot;Lantinghei SC&quot;, &quot;Open Sans&quot;, Arial, &quot;Hiragino Sans GB&quot;, &quot;Microsoft YaHei&quot;, &quot;WenQuanYi Micro Hei&quot;, SimSun, sans-serif; white-space: normal; background-color: rgb(255, 255, 255);\">Wi-Fi 6 是一项新技术，对于手机或其他设备公司而言，目前采购成本非常高。而且，增加的成本和对家庭用户来说几乎没有任何明显的好处，这可能会导致 Wi-Fi 6 芯片普及的速度变慢。IDC 的研究表明，Wi-Fi 6 的主流采用将在 2023 年之前完成，普及阶段长达三年。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px; color: rgb(51, 51, 51); font-family: &quot;Pingfang SC&quot;, STHeiti, &quot;Lantinghei SC&quot;, &quot;Open Sans&quot;, Arial, &quot;Hiragino Sans GB&quot;, &quot;Microsoft YaHei&quot;, &quot;WenQuanYi Micro Hei&quot;, SimSun, sans-serif; white-space: normal; background-color: rgb(255, 255, 255);\">对于家庭 Wi-Fi 用户和小型企业来说，在 Wi-Fi 6 成本下降，以及更多设备兼容 11ax 芯片之前，可以暂缓 Wi-Fi 6 路由器的采购。目前 Wi-Fi 5 路由器用户可以通过网状系统（Mesh）等方式来增强 Wi-Fi 5 的信号覆盖和连接性。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px; color: rgb(51, 51, 51); font-family: &quot;Pingfang SC&quot;, STHeiti, &quot;Lantinghei SC&quot;, &quot;Open Sans&quot;, Arial, &quot;Hiragino Sans GB&quot;, &quot;Microsoft YaHei&quot;, &quot;WenQuanYi Micro Hei&quot;, SimSun, sans-serif; white-space: normal; background-color: rgb(255, 255, 255);\">来自：<a href=\"https://www.ctocio.com/ccnews/29862.html\" target=\"_blank\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">IT经理网</a>&nbsp;作者：<a href=\"https://www.ctocio.com/author/zhanglin\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">张霖</a></p><p><br/></p>','WiFi 6 目前还不适合个人用户',0,'新闻','5G 已经被热炒得家喻户晓，但与其对标的 Wi-Fi 新技术标准—— Wi-Fi 6 却可能有着更好的经济和技术前景，Wi-Fi 6 也称为 802.11ax，比过去的 Wi-Fi 技术更好，速度更快能跟 5G 对标，连接性更好，信号覆盖和稳定性都更好，同时支持的用户数更多，而且还比 5G 基站成本更低。在工厂、仓库、码头等商用场景，Wi-Fi 6 相比 5'),(2386435,10000,'2019-08-28 17:07:53','<p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">根据&nbsp;<a href=\"https://www.phonearena.com/news/Android-10-release-date-confirmed-official-Pixel_id118451\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">phonearena</a>&nbsp;的报道，他们向两位谷歌支持团队的成员分别确认 Android 10 的发布日期，得到的答复都是 2019 年 9 月 3 日。也就是说，如果信息准确无误的话，Android 10 将在下周就会正式推出。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><img alt=\"\" height=\"271\" src=\"https://oscimg.oschina.net/oscnet/7aa15c81940a1973bbcb524b9f2c36c06de.jpg\" width=\"542\" class=\"zoom-in-cursor\"/>&nbsp;<img alt=\"\" height=\"442\" src=\"https://oscimg.oschina.net/oscnet/11b6b19e1f9082cf11443d7a3959bfb6634.jpg\" width=\"300\" class=\"zoom-in-cursor\"/></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">谷歌自家的 Pixel 手机或将成为搭载 Android 10 系统的第一批设备，包括&nbsp;Pixel 3/3XL、3a/3a XL，以及 Pixel&nbsp;2/2 XL，甚至是 2016 年发布的初代 Pixel 和&nbsp;Pixel XL，都会获得更新。同时，Android 10 的正式推出也意味着最新版&nbsp;Pixel 4 系列手机即将亮相。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">至于其他 Android 设备，也都将在接下来几个月内陆续收到更新。三星、诺基亚等分别公布了推出 Android 10 的时间表，还有部分第三方厂商公布了首批升级 Android 10 的设备机型。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><img alt=\"\" height=\"338\" src=\"https://oscimg.oschina.net/oscnet/77850edf58e647bb9d8a01949f7bb947039.jpg\" width=\"600\" class=\"zoom-in-cursor\"/></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">上周谷歌刚刚公布 Android Q 不同以往的命名方式，即从甜点命名转为数字版号。它还更换了新的 logo：将文本从绿色改为黑色，以便于阅读，转换字体，并使用特写的机器人，而且采用了一种新的绿色。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">目前为止，即将推出的 Android 10 已经发布了 6 个 beta 版本。新版本 Android 的新功能包括对可折叠手机的支持、对 5G 的支持、实时字幕、智能回复、建议操作以及改进的安全和隐私功能。值得一提的其他功能还包括无缝背景更新、改进的数字健康套件和家长控制功能，以及令许多用户期待的暗黑模式。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">相关阅读：<a href=\"https://www.oschina.net/news/109287/android-q-is-android-10\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">Android Q 不叫 Q，正式命名为 Android 10</a></p><h3 style=\"box-sizing: inherit; line-height: 1.28571em; margin: 0px 0px 1rem; padding: 0px; font-size: 1.28571rem;\">相关链接</h3><ul class=\"link-list list-paddingleft-2\" style=\"list-style-type: square;\"><li><p>Android 的详细介绍：<a href=\"https://www.oschina.net/p/android-os\" target=\"_blank\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">点击查看</a></p></li><li><p>Android 的下载地址：<a href=\"http://source.android.com/source/downloading.html\" target=\"_blank\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">点击下载</a></p></li></ul><p><br/></p>','Android 10 正式版本或将于 9 月 3 日推出',0,'新闻','根据 phonearena 的报道，他们向两位谷歌支持团队的成员分别确认 Android 10 的发布日期，得到的答复都是 2019 年 9 月 3 日。也就是说，如果信息准确无误的话，Android 10 将在下周就会正式推出。 谷歌自家的 Pixel 手机或将成为搭载 Android 10 系统的第一批设备，包括 Pixel 3/3XL、3a/3a XL'),(2386436,10000,'2019-08-28 17:10:22','<p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">上周 IBM 宣布<a href=\"https://www.oschina.net/news/109262/ibm-opensourced-power\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">开源 Power 指令集架构</a>，同时&nbsp;OpenPOWER 基金会加入了 Linux 基金会运营，这一消息引起了许多讨论，有人看好 Power 接下来的发展，有人则觉得它的时代早已逝去。这是关于 Power 自身的看法，而由于 Power 的开源，将会引发周边生态怎样的变数呢？</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">ZDNet 的高级技术编辑&nbsp;<a href=\"https://www.zdnet.com/meet-the-team/us/jason-perlow/\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">Jason Perlow</a>&nbsp;就简单分析了这个问题，并且他认为<span style=\"box-sizing: inherit; font-weight: 700;\">中国是其中的大赢家</span>。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><img height=\"462\" src=\"https://oscimg.oschina.net/oscnet/4e6befe368ce1209077a961d9d5c302661f.jpg\" width=\"700\" class=\"zoom-in-cursor\"/></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">Power（Performance Optimization With Enhanced RISC）是最通用的几种 CPU 架构之一，它具有高度通用、高性能等特性，支持从嵌入式系统到超级计算机等平台，在过去的几十年里，它在汽车、医疗设备和军事/航空航天等领域都有一席之地。可以说 Power 是适用于物联网、网络和无线、工业和环境控制系统、个人计算、企业服务器以及手持设备和移动设备等领域的一款 CPU 架构。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">Jason 的文章介绍了他认为在 IBM 将其杀器 Power 开源后，分别有哪些公司成为了赢家与输家。</p><h4 style=\"box-sizing: inherit; font-family: &quot;PingFang SC&quot;, &quot;Helvetica Neue&quot;, &quot;Microsoft YaHei UI&quot;, &quot;Microsoft YaHei&quot;, &quot;Noto Sans CJK SC&quot;, Sathu, EucrosiaUPC, Arial, Helvetica, sans-serif; line-height: 1.28571em; margin: 1.2em 0px 0.8em; font-weight: 500; padding: 0px; font-size: 18px; border: none;\"><span style=\"box-sizing: inherit; color: rgb(22, 160, 133);\"><span style=\"box-sizing: inherit; font-weight: 700;\">赢家</span></span></h4><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">IBM</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">IBM 的所有软件、服务和云采用 Power，而 Red Hat 是整个 IBM Power 生态系统中的关键环节，所以未来 Red Hat 可以成为相当大的未来收入来源。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">中国公司</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">以华为为代表，现在华为现在可以使用 Power 架构构建 5G 基础架构、网络交换机和物联网组件，而且，可能还有智能手机和平板电脑处理器。但这对于解决华为主要的 5G 组件供应链问题来说，杯水车薪。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">任何搞 IoT 设备的人</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">他们现在有比 ARM 或 Intel 更好的选择。微软 Xbox 可能再次成为 PowerPC，每个人都可以制作 Wi-Fi 路由器、家居网关、Alexa 智能扬声器等智能设备。同时这些硬件背后：made in China。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">Apple</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">史蒂夫乔布斯当年的 Power Mac 可能在十多年后的今天重新回归，并且可能迎来新一代 Power iPad、Power Watch 与其它基于 Power 的苹果设备。苹果完全可以不再依赖于 ARM 或者 Intel 的授权许可，从头再来过。不过这也需要与华为一样投入资源来构建自己的 Power 生态，在这一点上，苹果似乎已经有了一个好的开端——多年前 Tim Cook 与 Ginni Rometty 创建了 IBM 联盟——这么看这似乎是苹果的一个计谋。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">每个超大规模的云供应商</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">Azure、AWS 和 Google 可以与台积电、三星微电子、GlobalFoundries 等制造商合作开发 Power 芯片。重型容器化和开源工作负载将不再需要兼容 Intel。反过来，这将对其它无法支持这些芯片的云供应商施加压力，并且由于 Power 的自然架构和能源效率，它最终将极大地降低云计算的成本。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">Microsoft</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">虽然看起来 x86 在 Power 崛起时受损会损害其 Windows/Wintel 的主导地位，但微软多年来其实一直在往云供应商和应用开发商的角色转变，并且它已经在 Surface 硬件领域不再依赖&nbsp;Intel。现代 Windows 10 应用架构也不依赖于 Win32，其在每个版本中都将旧版组件替换为新组件。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">俄罗斯和所有美国敌人</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">利用像 Power 这样的开源超级计算技术，任何对美国构成国家安全风险的国家，现在都可以使用为国防部和国家安全局提供最重要系统的微处理器技术。</p><h4 style=\"box-sizing: inherit; font-family: &quot;PingFang SC&quot;, &quot;Helvetica Neue&quot;, &quot;Microsoft YaHei UI&quot;, &quot;Microsoft YaHei&quot;, &quot;Noto Sans CJK SC&quot;, Sathu, EucrosiaUPC, Arial, Helvetica, sans-serif; line-height: 1.28571em; margin: 1.2em 0px 0.8em; font-weight: 500; padding: 0px; font-size: 18px; border: none;\"><span style=\"box-sizing: inherit; color: rgb(22, 160, 133);\"><span style=\"box-sizing: inherit; font-weight: 700;\">输家</span></span></h4><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">Intel</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><a href=\"http://www.zdnet.com/article/post-pc-why-intel-can-no-longer-live-in-denial/\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">x86 已经挣扎了将近十年</a>，它已经在云中失去了重要的相关性，因为云中出生的工作负载不再与架构因素绑定，它们是高度容器化、面向服务的，并且大量使用包括 Linux 在内的开源工具集。ARM 正在取代 Intel，而现在每个人都有一个免费的超级计算级系统架构 Power 可以采用。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">Qualcomm</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">高通公司拥有领先的 5G、Wi-Fi 和运营商设备芯片组，它是智能手机芯片的头号供应商，它的 Snapdragon SoC 为美国的三星 Galaxy 手机、Google Pixel 以及其它几乎所有不是华为制造的 Android 手机提供动力，甚至实际上华为也依赖于它，但目前贸易战使得这一层依赖断裂。而除了智能手机芯片，凭借 Power，华为可以开发自己的网络处理器。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">ARM</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">ARM 是领先的嵌入式处理器架构，但它有相关的授权费问题，它不是一家晶圆厂公司，只能通过向苹果、高通、三星与华为等公司授权基本的处理器设计。这样一来，一个开源的、专利使用免费的 Power 可能会将它击垮。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">AMD</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">虽然不像 Intel 那样与 x86 捆绑在一起，但潜在的 ARM 的失落仍然是对 AMD 未来业务的重大打击。不过，AMD 也可以转型成为基于 Power 的芯片的合约制造商，甚至可以在多个市场领域设计自己的产品，从嵌入式/网络到企业和移动领域。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">Samsung</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">与 AMD 一样，三星是全球最大的半导体合约制造商之一，可以为苹果等企业制造基于 Power 的芯片，但这意味着它将不得不与&nbsp;Globalfoundries 等公司进行竞争，这些公司在 Power 和 IBM 的工厂中占据优势，而中国方面，他的竞争对手包括台积电、富士康和华为。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">RISC-V</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">作为 ARM 的开源替代品，在&nbsp;Power 开源后拥有了广泛的行业支持之后，RISC-V 几乎可以说再见了。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><span style=\"box-sizing: inherit; font-weight: 700;\">特朗普政府</span></p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">想要让公司不使用免版税的开源技术，这不可能。特朗普政府无法阻止开源被采用。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">文章作者&nbsp;Jason 最后表示，这些影响可能需要数年时间才能应验，而且并不是所有有利方都会积极拥抱开源的 Power。但是毫无疑问，对于上边清单中列出的受影响的公司，巨大的变化是必然的。</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">你觉得这些判断有道理吗？</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\">原文地址：</p><p style=\"box-sizing: inherit; margin-top: 16px; margin-bottom: 14px; line-height: 28px;\"><a href=\"https://www.zdnet.com/article/ibms-power-ful-open-source-gift-big-winner-is-china-losers-include-you-know-who/\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">https://www.zdnet.com/article/ibms-power-ful-open-source-gift-big-winner-is-china-losers-include-you-know-who/</a></p><h3 style=\"box-sizing: inherit; line-height: 1.28571em; margin: 0px 0px 1rem; padding: 0px; font-size: 1.28571rem;\">相关链接</h3><ul class=\"link-list list-paddingleft-2\" style=\"list-style-type: square;\"><li><p>RISC-V 的详细介绍：<a href=\"https://www.oschina.net/p/risc-v\" target=\"_blank\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">点击查看</a></p></li><li><p>RISC-V 的下载地址：<a href=\"http://riscv.org/download.html\" target=\"_blank\" style=\"box-sizing: inherit; background-color: transparent; color: rgb(65, 131, 196); text-decoration-line: none;\">点击下载</a></p></li></ul><p><br/></p>','IBM 开源 Power 指令集架构，中国成最大赢家？',0,'新闻','上周 IBM 宣布开源 Power 指令集架构，同时 OpenPOWER 基金会加入了 Linux 基金会运营，这一消息引起了许多讨论，有人看好 Power 接下来的发展，有人则觉得它的时代早已逝去。这是关于 Power 自身的看法，而由于 Power 的开源，将会引发周边生态怎样的变数呢？ZDNet 的高级技术编辑 Jason Perlow 就简单分析了这');
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gameconfig`
--

DROP TABLE IF EXISTS `gameconfig`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `gameconfig` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `kindid` int(11) DEFAULT '0',
  `type` int(11) DEFAULT '0' COMMENT '0-默认 1-配置 2-lua代码 3-客户端配置',
  `level` tinyint(4) DEFAULT '0',
  `name` varchar(45) DEFAULT '',
  `note` varchar(1024) DEFAULT '',
  `data` bigint(20) DEFAULT '0',
  `cond` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='游戏配置数据';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gameconfig`
--

LOCK TABLES `gameconfig` WRITE;
/*!40000 ALTER TABLE `gameconfig` DISABLE KEYS */;
INSERT INTO `gameconfig` VALUES (0,10,1,1,'实习生','当日整线业绩',60,1),(1,10,1,1,'实习生','当日整线业绩',70,1000),(2,10,1,2,'实习生','当日整线业绩',80,7000),(3,10,1,3,'实习生','当日整线业绩',100,12000),(4,10,1,4,'实习生','当日整线业绩',120,40000),(5,10,1,5,'实习生','当日整线业绩',140,80000),(6,10,1,6,'实习生','当日整线业绩',160,120000),(7,10,1,7,'实习生','当日整线业绩',180,250000),(8,10,1,8,'实习生','当日整线业绩',200,500000),(9,10,1,9,'实习生','当日整线业绩',220,800000),(10,10,1,10,'实习生','当日整线业绩',240,1000000),(11,10,1,11,'实习生','当日整线业绩',260,1200000),(12,10,1,12,'实习生','当日整线业绩',270,3600000),(13,10,1,13,'实习生','当日整线业绩',280,5000000),(14,10,1,14,'实习生','当日整线业绩',290,10000000),(15,10,1,15,'实习生','当日整线业绩',300,15000000),(16,10,1,16,'实习生','当日整线业绩',300,100000000),(17,130,2,0,'牛牛抽水','TAX_COE=0.02',0,0),(18,100,2,0,'三公抽水','TAX_COE=0.02',0,0),(19,150,2,0,'红黑抽水','TAX_COE=0.02',0,0),(20,110,2,0,'龙虎抽水','TAX_COE=0.02',0,0),(21,180,2,0,'诈金花抽水','TAX_COE=0.02',0,0),(22,110,2,0,'龙虎上庄','ONBANKERS_SCORE=300000',0,0),(23,150,2,0,'红黑上庄','ONBANKERS_SCORE=300000',0,0),(24,130,2,0,'牛牛上庄','ONBANKERS_SCORE=200000',0,0),(25,10,2,0,'平台版本号','APPVERSION=\"1.0.1\"',0,0),(26,10,2,0,'注册赠送分','REGISTER_ACCOUNT_SCORE=0',0,0),(27,130,3,0,'牛牛机器人取钱','TAKE_MONEY=1000000',0,0),(28,100,3,0,'三公机器人取钱','TAKE_MONEY=1000000',0,0),(29,150,3,0,'红黑机器人取钱','TAKE_MONEY=1000000',0,0),(30,110,3,0,'龙虎机器人取钱','TAKE_MONEY=1000000',0,0);
/*!40000 ALTER TABLE `gameconfig` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gamemoneylogs`
--

DROP TABLE IF EXISTS `gamemoneylogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `gamemoneylogs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) DEFAULT '0',
  `addscore` bigint(20) DEFAULT '0',
  `addinsurescore` bigint(20) DEFAULT '0',
  `logtime` datetime DEFAULT '0000-00-00 00:00:00',
  `oldscore` bigint(20) DEFAULT '0',
  `nowscore` bigint(20) DEFAULT '0',
  `oldinsurescore` bigint(20) DEFAULT '0',
  `nowinsurescore` bigint(20) DEFAULT '0',
  `tax` bigint(20) DEFAULT '0',
  `note` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '0' COMMENT '备注',
  `gameid` int(11) DEFAULT '0' COMMENT '房间号',
  `chairid` smallint(6) DEFAULT '-1' COMMENT '座位',
  `kindid` smallint(6) DEFAULT '0' COMMENT '游戏类型',
  `reason` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '原因',
  `fromid` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gamemoneylogs`
--

LOCK TABLES `gamemoneylogs` WRITE;
/*!40000 ALTER TABLE `gamemoneylogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `gamemoneylogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gamerecords`
--

DROP TABLE IF EXISTS `gamerecords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `gamerecords` (
  `id` int(11) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `gameid` int(11) DEFAULT '0',
  `kindid` smallint(6) DEFAULT '0',
  `options` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `groupid` int(11) DEFAULT '0',
  `owner` int(11) DEFAULT NULL,
  `recordtime` datetime DEFAULT '0000-00-00 00:00:00',
  `results` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `uiid` int(11) DEFAULT '0',
  `rounde` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gamerecords`
--

LOCK TABLES `gamerecords` WRITE;
/*!40000 ALTER TABLE `gamerecords` DISABLE KEYS */;
/*!40000 ALTER TABLE `gamerecords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gameuserrecords`
--

DROP TABLE IF EXISTS `gameuserrecords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `gameuserrecords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) DEFAULT '0',
  `kindid` int(11) DEFAULT '0',
  `recorduiid` int(11) DEFAULT '0',
  `recordtime` datetime DEFAULT '0000-00-00 00:00:00',
  `lastrounde` tinyint(4) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gameuserrecords`
--

LOCK TABLES `gameuserrecords` WRITE;
/*!40000 ALTER TABLE `gameuserrecords` DISABLE KEYS */;
/*!40000 ALTER TABLE `gameuserrecords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `orders` (
  `orderid` bigint(20) NOT NULL,
  `userid` int(11) DEFAULT NULL,
  `score` bigint(20) DEFAULT NULL,
  `insurescore` bigint(20) DEFAULT NULL,
  `state` tinyint(4) DEFAULT NULL COMMENT '0-未结算\\n1-已结算\\n2-撤销\\n3-已完成',
  `ordertime` datetime DEFAULT NULL,
  `itemid` int(11) DEFAULT NULL,
  `note` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`orderid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT='订单';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `systemctrl`
--

DROP TABLE IF EXISTS `systemctrl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `systemctrl` (
  `id` int(11) NOT NULL,
  `kindid` int(11) DEFAULT '0' COMMENT '游戏类型ID',
  `gameid` int(11) DEFAULT '0',
  `sysmin` bigint(20) DEFAULT '0' COMMENT '库存下限',
  `sysmax` bigint(20) DEFAULT '0' COMMENT '库存上限',
  `currency` bigint(20) DEFAULT '0' COMMENT '当前库存',
  `userid` int(11) DEFAULT '0' COMMENT '用户id',
  `sysparam` float DEFAULT '1' COMMENT '附加系数',
  PRIMARY KEY (`id`),
  KEY `index_kindid` (`kindid`),
  KEY `index_gameid` (`gameid`),
  KEY `index_userid` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `systemctrl`
--

LOCK TABLES `systemctrl` WRITE;
/*!40000 ALTER TABLE `systemctrl` DISABLE KEYS */;
/*!40000 ALTER TABLE `systemctrl` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `userextinfo`
--

DROP TABLE IF EXISTS `userextinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `userextinfo` (
  `userid` int(10) unsigned NOT NULL,
  `card` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `alipay` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `phone` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `bankaddr` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT '开户行',
  `city` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `province` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `userextinfo`
--

LOCK TABLES `userextinfo` WRITE;
/*!40000 ALTER TABLE `userextinfo` DISABLE KEYS */;
/*!40000 ALTER TABLE `userextinfo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usermessages`
--

DROP TABLE IF EXISTS `usermessages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `usermessages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) DEFAULT NULL,
  `type` smallint(6) DEFAULT NULL COMMENT '1-用户邮件\n2-游戏消息\n3-系统消息 4-配置',
  `title` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `content` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `state` tinyint(4) DEFAULT NULL COMMENT '0-未读\n1-已读',
  `msgtime` datetime DEFAULT NULL,
  `fromid` int(11) DEFAULT NULL,
  `funcid` int(11) DEFAULT NULL COMMENT '功能性id, 1-活动公告 2-客服联系方式 3-走马灯 4-收款2维码',
  `data` bigint(20) DEFAULT NULL COMMENT '绑定数据',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usermessages`
--

LOCK TABLES `usermessages` WRITE;
/*!40000 ALTER TABLE `usermessages` DISABLE KEYS */;
INSERT INTO `usermessages` VALUES (7,0,4,'feedback','0- 0你好！',0,'2019-07-17 10:59:32',0,3,0),(8,0,4,'活动','大大甩卖大甩卖大甩卖大甩卖大甩卖大甩卖甩卖大甩卖',0,'2019-07-17 10:59:32',0,1,0),(9,0,4,'客服联系','wx123456',0,'2019-07-17 10:59:32',0,2,0),(10,0,1,'1','wx1.jpg',0,'2019-07-17 10:59:32',0,4,0),(11,0,4,'1','wx2.png',0,'2019-07-17 10:59:32',0,4,1),(12,0,4,'2','zfb1.png',0,'2019-07-17 10:59:32',0,4,0),(13,0,4,'2','zfb2.jpg',0,'2019-07-17 10:59:32',0,4,1),(15,0,4,'公告','公告',0,'2019-07-18 17:47:30',0,1,0),(20,100000,2,'测试','给你发封邮件，不代表啥意思',0,'2019-07-18 17:47:30',100151,1,0),(21,0,3,'feedback','大家啊看见',0,'2019-07-19 12:32:15',100000,0,0);
/*!40000 ALTER TABLE `usermessages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'blogs'
--
/*!50003 DROP PROCEDURE IF EXISTS `init_gamedb` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `init_gamedb`()
BEGIN
	truncate table accounts;
    truncate table betorders;
    truncate table cashouts;
    truncate table gamemoneylogs;
    truncate table gamerecords;
    truncate table gameuserrecords;
    truncate table orders;
    truncate table systemctrl;
    truncate table userextinfo;
    alter table accounts  auto_increment = 100000;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-08-28 17:16:50
