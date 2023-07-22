# Creating Procedures

use mine_operations;
-- 1. Creating Stored Procedure for cycle table
drop procedure if exists cycle_key;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` procedure cycle_key (cycle_type varchar(50))
begin
select *
from cycle_data
where `Cycle Type` = cycle_type;
end $$
DELIMITER ;

call cycle_key('LoaderCycle');

-- ______________________________________________________________

# 2. Creating Stored Procedure for delay table
drop procedure if exists delay_key;

DELIMITER $$
create procedure delay_key (Machine_Class_Category_Name varchar(50))
begin
select *
from delay_data
where `Target Machine Class Category Name` = Machine_Class_Category_Name;
end $$
DELIMITER ;

call delay_key("Truck Classes");

-- ______________________________________________________________

# 3. Creating Stored Procedure for movement table
drop procedure if exists movement_key;
DELIMITER $$
create procedure movement_key (Truck_Name varchar(20))
begin
select *
from movement_master
where `Primary Machine Name` = Truck_Name;
end $$
DELIMITER ;

call movement_key('DT5226');

-- ______________________________________________________________

# 4. Creating Stored Procedure for equipment_master table
drop procedure if exists equipment_master_key;

DELIMITER !!
CREATE PROCEDURE equipment_master_key ( cycle_type VARCHAR(100))
BEGIN
SELECT * 
FROM equipment_master
WHERE `Cycle Type` = cycle_type;
end !!
DELIMITER ;

-- ______________________________________________________________

# 5. Creating Stored Procedure for equipment_master_type table
drop procedure if exists equipment_master_type_key;

DELIMITER !!
CREATE PROCEDURE equipment_master_type_key ( cycle_type VARCHAR(100))
BEGIN
SELECT * 
FROM equipment_master_type
WHERE `Cycle Type` = cycle_type;
end !!
DELIMITER ;

-- ______________________________________________________________

# 6. Creating Stored Procedure for location_master_type table
DROP PROCEDURE IF EXISTS location_master_type_key;

DELIMITER $$
CREATE PROCEDURE location_master_type_key()
BEGIN
    SELECT * FROM location_master_type;
END $$
DELIMITER ;

-- ______________________________________________________________

# 7. Creating Stored Procedure for location_master table
DROP PROCEDURE IF EXISTS location_master_key;

DELIMITER $$
CREATE PROCEDURE location_master_key()
BEGIN
    SELECT * FROM location_master;
END $$
DELIMITER ;

-- ______________________________________________________________

# 8. CREATE PROCEDURE FOR OEE METRICES

-- OEE: Overall Equipment Efficiency =  Availability*Performance*Quality
-- Availability = (Available Time - Down Time)/Available Time
-- Performance = (OPERATINGTIME (CAT) - Down Time)/ OPERATINGTIME (CAT)
-- Quality = (OPERATINGTIME (CAT) - Idle Duration - Down Time)/OPERATINGTIME (CAT)

drop view if exists oee_metrics_view;
create view oee_metrics_view  as
(
	with oee_summary as
	(
		SELECT 
				`Cycle Type`,  `Primary Machine Category Name`, `Primary Machine Class Name`, `Primary Machine Name`,
				(`Available Time`- `Idle duration` - `Down Time`)/`Available Time` as availability,
				(`OPERATINGTIME (CAT)` - `Down Time`)/ `OPERATINGTIME (CAT)` as performance,
				(`OPERATINGTIME (CAT)` - `Idle Duration`- `Down Time`)/`OPERATINGTIME (CAT)` as quality
		FROM
				cycle_data
	)
		select `Cycle Type`,  `Primary Machine Category Name`, `Primary Machine Class Name`, `Primary Machine Name`,
				ROUND(AVG(availability),2) AS avg_avability,
                ROUND(AVG(performance),2) AS avg_performance,
                ROUND(AVG(quality),2) AS avg_quality,
                ROUND(AVG(availability)*AVG(performance)*AVG(quality),2) as OEE
		from 	
				oee_summary
		GROUP BY `Cycle Type`,  `Primary Machine Category Name`, `Primary Machine Class Name`, `Primary Machine Name`
		ORDER BY ROUND(AVG(availability)*AVG(performance)*AVG(quality),2) DESC 
);


DROP PROCEDURE IF EXISTS OEE_metrics_key;
DELIMITER $$
CREATE PROCEDURE OEE_metrics_key ( cycle_type varchar(30))
Begin
select * 
from oee_metrics_view
where `Cycle Type` = cycle_type;
END $$
DELIMITER ;

call OEE_metrics_key('LoaderCycle');

-- ______________________________________________________________

# 9. CREATE PROCEDURE FOR FUEL METRICES

-- Actual Fuel Used = Fuel Used/ TMPH
-- Fuel used Empty =  (Empty Travel Duration/(Empty Travel Duration + Full Travel Duration))*Total Fuel Used
-- Fuel used Full =   (Full Travel Duration/(Empty Travel Duration + Full Travel Duration))*Total Fuel Used
-- Total Mileage = (2*Empty EFH Distance)/Total Fuel Used
-- Empty Truck Mileage = Empty EFH Distance/Fuel Used Empty
-- Loaded Truck Mileage = Empty EFH Distance/Fuel Used Full

drop view if exists fuel_metrics_view ;
Create view fuel_metrics_view as 
(
with fuel_metrics_view_summary as 
(
	SELECT 
		`Cycle Type`, `Primary Machine Name`,
		 round(`Fuel Used`* TMPH,3)   as `Total Fuel Used`,
         round( (`Empty Travel Duration`/(`Empty Travel Duration`+ `Full Travel Duration`))*(`Fuel Used`* TMPH),3) as `Fuel used Empty`,
         round( (`Full Travel Duration`/(`Empty Travel Duration`+ `Full Travel Duration`))*(`Fuel Used`* TMPH),3) as `Fuel used Full`,
		 round( ((`Empty EFH Distance` + `Empty Slope Distance` )*2)/(`Fuel Used`* TMPH),3 ) as `Truck Mileage`,
		 round( (`Empty EFH Distance` + `Empty Slope Distance`)/((`Empty Travel Duration`/(`Empty Travel Duration`+ `Full Travel Duration`))*(`Fuel Used`* TMPH)),3) as `Empty Truck Mileage`,
         round( (`Empty EFH Distance` + `Empty Slope Distance`)/((`Full Travel Duration`/(`Empty Travel Duration`+ `Full Travel Duration`))*(`Fuel Used`* TMPH)),3) as `Full Truck Mileage`
         
	FROM `cycle_data`
    where `Cycle Type` = 'TruckCycle'
)
	select  `Primary Machine Name`,
			round(avg(`Total Fuel Used`),2) as `Avg Fuel Used in Total`,
            round(avg(`Fuel used Empty`),2) as `Avg Fuel Used Empty`,
            round(avg(`Fuel used Full`),2) as `Avg Fuel Used Full`, 
            round(avg(`Truck Mileage`),2) as `Avg Truck Mileage in Total`,
            round(avg(`Empty Truck Mileage`),2) as `Avg Truck Mileage Empty`,
            round(avg(`Full Truck Mileage`),2) as `Avg Truck Mileage Full`
	from fuel_metrics_view_summary
    group by  `Primary Machine Name`
);

DROP PROCEDURE IF EXISTS fuel_metrics_key;
DELIMITER $$
CREATE PROCEDURE fuel_metrics_key()
Begin
select * from fuel_metrics_view;
END $$
DELIMITER ;

call fuel_metrics_key();

-- ______________________________________________________________

# 10. CREATE PROCEDURE FOR ACTUAL VS PLANNED PRODUCTION METRICES

-- Actual Production Rate = Payload(t)/Cycle Duration
-- Planned Production Rate = ASSOCPAYLOADNOMINAL/Available Time

# Actual VS Planned Production Rate

drop view if exists actual_planned_metrics_view;
create view  actual_planned_metrics_view as
(
	WITH actual_plan_production_sumamry as
	(
		SELECT `Cycle Type`, 
			   `Primary Machine Name`, 
			   `Primary Machine Category Name`,
			   `Primary Machine Class Name`,
			   `Payload (t)`/`Cycle Duration` as `Actual Production Rate`,
			   `ASSOCPAYLOADNOMINAL`/`Available Time` as `Planned Production Rate`,
			   IF ((`Payload (t)`/`Cycle Duration`) >= (`ASSOCPAYLOADNOMINAL`/`Available Time`),1,0) as `Target Achievd`
		FROM  `cycle_data`
		where `Cycle Type` <> 'AuxMobileCycle'
	)
		SELECT 	   `Cycle Type`, 
				   `Primary Machine Category Name`,
				   `Primary Machine Class Name`,
				   `Primary Machine Name`,
				   ROUND(AVG(`Actual Production Rate`),2) as avg_actual_prodction_rate, 
				   ROUND(AVG(`Planned Production Rate`),2) as avg_planned_production_rate,
				   round((sum(`Target Achievd`)/count(`Target Achievd`))*100,2) as target_achieved_percentage
		FROM  	   actual_plan_production_sumamry
		GROUP BY  `Cycle Type`, 
				   `Primary Machine Name`, 
				   `Primary Machine Category Name`,
				   `Primary Machine Class Name`
);

DROP PROCEDURE IF EXISTS actual_vs_planned_metrics_key;
DELIMITER $$
CREATE PROCEDURE actual_vs_planned_metrics_key()
Begin
select * from actual_planned_metrics_view;
END $$
DELIMITER ;

call actual_vs_planned_metrics_key();


# important views       


drop view if exists laod_cycle_df_view;
CREATE VIEW laod_cycle_df_view as
select * from cycle_data where `Cycle Type` = 'LoaderCycle';

drop view if exists truck_cycle_df_view;
CREATE VIEW truck_cycle_df_view as
select * from cycle_data where `Cycle Type` = 'TruckCycle';
                       
	
           
           







