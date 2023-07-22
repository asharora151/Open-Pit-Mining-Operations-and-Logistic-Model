DROP DATABASE IF EXISTS mine_operations;
CREATE  DATABASE mine_operations;

USE mine_operations;

-- Creating tables to load data for data analyis of mine operations
-- 1. Cycle Table
-- 2. Movement Master Table
-- 3. Location Master Table
-- 4. Location Type Master Table
-- 5. Equipment Master Table
-- 6. Equipment Type Master Table
-- 7. Delay Table

-- Cycle Table
DROP TABLE IF EXISTS cycle_data;
CREATE TABLE cycle_data 
(
   `Cycle Type` varchar(100) , 
   `Crew OI` varchar(100), 
   `Primary Machine Category Name` varchar(200),
   `Primary Machine Class Name` varchar(200), 
   `Primary Machine Name` varchar(200),
   `Secondary Machine Category Name` varchar(200), 
   `Secondary Machine Class Name` varchar(200),
   `Secondary Machine Name` varchar(100), 
   `PREVIOUSSECONDARYMACHINE` varchar(100) default null, 
   `Available Time` mediumint, 
   `Cycle Start Timestamp (GMT8)` datetime,
   `Cycle End Timestamp (GMT8)` datetime, 
   `Cycle Duration`  mediumint, 
   `Completed Cycle Count` varchar(20),
   `COMPLETEDCYCLEDURATION`  mediumint, 
   `TOTALTIME (CAT)`  mediumint, 
   `OPERATINGTIME (CAT)`  mediumint,
   `WORKINGDURATION` mediumint, 
   `Idle Duration` mediumint, 
   `Down Time` mediumint, 
   `SD_SCHEDULEDDOWNTIME`mediumint,
   `UNSCHEDULEDDOWNTIME` mediumint, 
   `DTE Down Time Equipment` mediumint default null,
   `UNSCHEDULEDDOWNCOUNT` mediumint default null, 
   `Available SMU Time`mediumint default null, 
   `Cycle SMU Duration`mediumint default null,
   `Destination Queuing Start Timestamp (GMT8)` datetime default null,
   `Destination Queuing End Timestamp (GMT8)` datetime default null,
   `Queuing at Sink Duration` double default null, 
   `Source Queuing Start Timestamp (GMT8)` datetime default null,
   `Source Queuing End Timestamp (GMT8)` datetime default null,
   `Queuing at Source Duration` double default null,
   `Queuing Duration` double default null, 
   `WAITFORDUMPDURATION` double default null, 
   `WAITFORLOADDURATION` double default null,
   `Destination Dumping Start Timestamp (GMT8)` double default null,
   `Destination Dumping End Timestamp (GMT8)` double default null,
   `Dumping Duration` double default null, 
   `Dumping SMU Duration` double default null,
   `Source Loading Start Timestamp (GMT8)` datetime default null,
   `Source Loading End Timestamp (GMT8)` datetime default null,
   `Loading Duration` double default null,
   `Loading Count` double default null, 
   `Loading Efficiency` double default null, 
   `Payload (kg)` double default null, 
   `Payload (t)`double default null, 
   `ASSOCPAYLOADNOMINAL`double default null,
   `TRUCKQUEUEATSOURCEDURATION` double default null, 
   `Empty Travel Duration` double default null,
   `Full Travel Duration` double default null, 
   `Source Location Name` varchar(200) default null,
   `Destination Location Name` varchar(200) default null, 
   `PREVIOUSSINKDESTINATION` varchar(200) default null,
   `Source Location is Source Flag` varchar(20) default null, 
   `Source Location is Active Flag` varchar(20) default null,
   `Destination Location is Active Flag` varchar(20) default null,
   `Destination Location is Source Flag` varchar(20) default null,
   `Destination Location Description` varchar(200) default null, 
   `Fuel Used` double default null, 
   `TMPH` double default null,
   `Empty EFH Distance` double default null, 
   `Empty Slope Distance` double default null, 
   `Day Hours`  varchar(100) default null,                                  
   `Day-DayName`   varchar(100) default null,                       
   `Number of Trucks Traveling Empty` smallint default null,           
   `Number of Trucks Traveling with Load` smallint default null,           
   `Truck at Dumping` varchar(100) default null,                             
   `Truck at Loading` varchar(100) default null,                                
   `Source_loc_ava` varchar(100) default null, 
   `Source Latitude` double default null,
   `Source Longitude` double default null, 
   `Destination_loc_ava` varchar(100) default null, 
   `Destination Latitude` double default null,
   `Destination Longitude` double default null
);

-- Movement Master Table
DROP TABLE IF EXISTS movement_master;
CREATE	TABLE movement_master
(
 `Primary Machine Name` varchar(200), 
 `Source Location Name` varchar(200),
 `Destination Location Name` varchar(200), 
 `Payload (t)` double,
 `Cycle Start Timestamp (GMT8)` datetime, 
 `Cycle End Timestamp (GMT8)` datetime
);

-- Location Master Table
DROP TABLE IF EXISTS location_master;
CREATE	TABLE location_master
( 
 `Cycle Type` varchar(100) , 
 `Primary Machine Name` varchar(200),
 `Source Location Name` varchar(200) default null, 
 `Destination Location Name` varchar(20) default null,
 `Payload (t)` double default null,
 `Dumping Duration` double default null,
 `Loading Duration` double default null,
 `Queuing at Sink Duration` double default null,
 `Queuing at Source Duration` double default null, 
 `Queuing Duration` double default null, 
 `WAITFORDUMPDURATION` double default null,
 `WAITFORLOADDURATION` double default null, 
 `Source Location is Source Flag` varchar(20) default null, 
 `Source Location is Active Flag` varchar(20) default null,
 `Destination Location is Active Flag` varchar(20) default null,
 `Destination Location is Source Flag` varchar(20) default null,
 `Destination Location Description` varchar(300) default null
);

-- Location Type Master Table
DROP TABLE IF EXISTS location_type_master;
CREATE	TABLE location_type_master
( 
 `Cycle Type` varchar(100) , 
 `Primary Machine Name` varchar(200),
 `Source_loc_ava` varchar(200) default null, 
 `Source Latitude` double default null,
 `Source Longitude` double default null,
 `Destination_loc_ava` varchar(200) default null,
 `Destination Latitude` double default null,
 `Destination Longitude` double default null
);

-- Equipment Master
DROP TABLE IF EXISTS equipment_master;
CREATE TABLE eqipment_master 
(
   `Cycle Type` varchar(100) , 
   `Cycle Duration`  mediumint, 
   `Available Time` mediumint, 
   `Completed Cycle Count` varchar(20),
   `Primary Machine Name` varchar(200),
   `Primary Machine Category Name` varchar(200),
   `Secondary Machine Name` varchar(100), 
   `Secondary Machine Category Name` varchar(200), 
   `Payload (t)`double default null, 
   `ASSOCPAYLOADNOMINAL`double default null,
   `Fuel Used` double default null, 
   `TMPH` double default null,
   `Empty EFH Distance` double default null, 
   `TOTALTIME (CAT)`  mediumint, 
   `OPERATINGTIME (CAT)`  mediumint,
   `WORKINGDURATION` mediumint, 
   `Idle Duration` mediumint, 
   `Down Time` mediumint, 
   `Queuing Duration` double default null, 
   `DTE Down Time Equipment` mediumint default null,
   `Dumping Duration` double default null, 
   `Loading Duration` double default null,
   `Loading Count` double default null, 
   `Loading Efficiency` double default null, 
   `Available SMU Time`mediumint default null, 
   `Cycle SMU Duration`mediumint default null
);

-- Equipment Type Master
DROP TABLE IF EXISTS equipment_type_master;
CREATE TABLE eqipment_type_master 
(
   `Cycle Type` varchar(100) , 
   `Cycle Duration`  mediumint, 
   `Primary Machine Category Name` varchar(200),
   `Primary Machine Class Name` varchar(200),
   `Secondary Machine Category Name` varchar(100), 
   `Secondary Machine Class Name` varchar(200), 
   `Payload (t)`double default null, 
   `OPERATINGTIME (CAT)`  mediumint,
   `WORKINGDURATION` mediumint, 
   `Idle Duration` mediumint, 
   `Down Time` mediumint, 
   `Dumping Duration` double default null, 
   `Loading Duration` double default null
);

-- Delay Data 
DROP TABLE IF EXISTS delay_data;
CREATE TABLE delay_data 
(
  `Delay OID` varchar(100), 
  `Engine Stopped Flag` varchar(10), 
  `Field Notification Required Flag` varchar(10),
  `Production Reporting Only Flag` varchar(10), 
  `Delay Class Name`  varchar(1000),
  `Delay Class Category Name`  varchar(1000), 
  `Target Machine Name`  varchar(200),
  `Target Machine Class Name`   varchar(200), 
  `Target Machine Class Description` varchar(200), 
  `Target Machine Class Category Name`  varchar(200), 
  `Delay Start Timestamp (GMT8)`   datetime ,
  `Delay Finish Timestamp (GMT8)` datetime    
);



-- LOADING CYCLE DATA
LOAD DATA INFILE 'combined_cycle_df.csv'
INTO TABLE cycle_data
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'; 

-- LOADING Delay DATA
LOAD DATA INFILE 'delay_df.csv'
INTO TABLE delay_data
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'; 

-- LOADING Location_Master DATA
LOAD DATA INFILE 'Location_Master.csv'
INTO TABLE location_master
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'; 

-- LOADING Location_Type_Master DATA
LOAD DATA INFILE 'Location_Type_Master.csv'
INTO TABLE location_type_master
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'; 

-- LOADING Equipment_Master DATA
LOAD DATA INFILE 'Equipment_Master.csv'
INTO TABLE equipment_master
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'; 

-- LOADING Equipment_Type_Master DATA
LOAD DATA INFILE 'Equipment_Type_Master.csv'
INTO TABLE equipment_type_master
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n'; 



select * from cycle_data



