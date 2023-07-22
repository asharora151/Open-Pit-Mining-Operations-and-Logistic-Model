use mine_operations;

-- check datatypes of each cycle
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'mine_operations'
AND table_name = 'cycle_data';


# Operational Analysis
-- NUMBER OF MACHINES

-- 1) Total Number of UNIQUE equipment in the field.
select count( distinct `Primary Machine Name`) as `Total Operating Machines`
from cycle_data;

-- 1) Total Number of UNIQUE equipment in the EACH cycle.
SELECT 		`Cycle Type`,
			COUNT( DISTINCT `Primary Machine Name`) AS `Total Operating Machines`
FROM 		cycle_data
GROUP BY 	`Cycle Type`
ORDER BY 	COUNT( DISTINCT `Primary Machine Name`) DESC;

-- 1) Total Number of UNIQUE equipment in the EACH cycle and machine category
SELECT 		`Cycle Type`,`Primary Machine Category Name`,
			COUNT( DISTINCT `Primary Machine Name`) AS `Total Operating Machines`
FROM 		cycle_data
GROUP BY 	`Cycle Type`,`Primary Machine Category Name`
ORDER BY 	`Cycle Type`, COUNT( DISTINCT `Primary Machine Name`) DESC;


-- ------------------------------------------------------------------------------------------------------------------------------

-- Equipment Utilisation Rate = (Working Time/ Total Time)*100  if a machine is being utlilies less than 65% then it is under maintenece

-- 2) Total machines under maintainence

SELECT		`Cycle Type`,
			count(  `Primary Machine Name`) as `Total Machines`,
			sum( IF(WORKINGDURATION/`TOTALTIME (CAT)`<=0.6, 1, 0)) AS `Machines under Maintence`
FROM 		cycle_data
GROUP BY 	`Cycle Type`
ORDER BY 	sum( IF(WORKINGDURATION/`TOTALTIME (CAT)`<=0.6, 1, 0)) DESC;

-- 2) Total number of machines in each cycle
SELECT 		`Cycle Type`,
			COUNT(  `Primary Machine Name`) AS `Total Machines`
FROM 		cycle_data
GROUP BY 	`Cycle Type`
ORDER BY 	COUNT(  `Primary Machine Name`) DESC;

-- 2) Total Number of equipment under maintainence in the field.
SELECT 		`Primary Machine Category Name`, 
			sum( IF(WORKINGDURATION/`TOTALTIME (CAT)`<=0.6, 1, 0)) AS `Machines under Maintence`
FROM 		cycle_data
GROUP BY 	`Primary Machine Category Name`
ORDER BY 	sum( IF(WORKINGDURATION/`TOTALTIME (CAT)`<=0.6, 1, 0)) DESC;




-- 2) show results in parallel
WITH MACHINE_SUMMARY AS
(
SELECT		`Cycle Type`,`Primary Machine Category Name`,
			count(  `Primary Machine Name`) as `Total Machines`,
			sum( IF(WORKINGDURATION/`TOTALTIME (CAT)`<=0.6, 1, 0)) AS `Machines under Maintence`
FROM 		cycle_data
GROUP BY 	`Cycle Type`, `Primary Machine Category Name`
ORDER BY 	 count(  `Primary Machine Name`) desc, `Cycle Type`
) 
	SELECT 		`Cycle Type`,
				`Primary Machine Category Name`, 
                `Total Machines`,
				`Total Machines` - `Machines under Maintence` as `Machines Operating`,
				`Machines under Maintence`
	FROM 		MACHINE_SUMMARY;

-- --------------------------------------------------------------------------------------------------------------------------------
-- Number of cycles completed by machine

SELECT `Completed Cycle Count`, count(`Primary Machine Class Name`) AS `Number of cycle Completed`
FROM `cycle_data`
GROUP BY `Completed Cycle Count`;

-- NUMBER OF COMPLETE CYCLE IN EACH MACHINE CLASS AND CYCLE
SELECT `Cycle Type`,`Primary Machine Class Name`, 
		count(`Primary Machine Class Name`) AS `Number of cycle Completed`,
        sum(if(`Completed Cycle Count` = 'Yes',1,0)) as `Number of cycle completed`,
        sum(if(`Completed Cycle Count` = 'No',1,0)) as `Number of cycle not completed`
FROM `cycle_data`
GROUP BY `Cycle Type`, `Primary Machine Class Name`
order by count(`Primary Machine Class Name`) desc limit 10;

-- TOP 5 MACHINE WHICH HAS DOME THE COMPLETE THE MOST NUMBER OF CYCLES in all cycle type

WITH loader_truck_completed_summary AS
(
	SELECT `Cycle Type`, `Primary Machine Name`, count(`Primary Machine Name`) AS `Number of cycle Completed`
	FROM `cycle_data`
	where  `Completed Cycle Count` = 'Yes'
	GROUP BY `Cycle Type`, `Primary Machine Name`
), PARTITION_SUMMARY
AS(
		SELECT *, row_number() OVER( PARTITION BY `Cycle Type` ORDER BY `Number of cycle Completed` DESC) AS row_num
        FROM loader_truck_completed_summary
        order by `Cycle Type` desc
 )
			SELECT `Cycle Type`, `Primary Machine Name`, `Number of cycle Completed`
            FROM PARTITION_SUMMARY
            WHERE row_num <=5;

-- ----------------------------------------------------------------------------------------------------------------------------
# amount of paylod load or excavated done by each machine
SELECT `Cycle Type`, `Primary Machine Name`, round(sum(`Payload (t)`),2) AS `Total Payload in tonnes`
FROM `cycle_data`
where `Cycle Type` in ( 'TruckCycle', "LoaderCycle")
GROUP BY `Cycle Type`,`Primary Machine Name`
order by round(sum(`Payload (t)`),2) desc;

# amount of total payload load or excavated by trucks and loaders or shovels respectively
SELECT `Cycle Type`,  round(sum(`Payload (t)`),2) AS `Total Payload in tonnes`
FROM `cycle_data`
where `Cycle Type` in ( 'TruckCycle', "LoaderCycle")
GROUP BY `Cycle Type`
order by round(sum(`Payload (t)`),2) desc;

# Top 5 loaders and Trucks
WITH loader_truck_payload_summary AS
(
	SELECT `Cycle Type`, `Primary Machine Name`, round(sum(`Payload (t)`),2) AS `Total Payload in tonnes`
	FROM `cycle_data`
	WHERE `Payload (t)`>0
	GROUP BY `Cycle Type`,`Primary Machine Name`
	ORDER BY round(sum(`Payload (t)`),2) desc
), LOADER_PARTITION_SUMMARY
AS(
		SELECT *, row_number() OVER( PARTITION BY `Cycle Type` ORDER BY `Total Payload in tonnes` DESC) AS row_num
        FROM loader_truck_payload_summary
 )
			SELECT `Cycle Type`, `Primary Machine Name`, `Total Payload in tonnes`
            FROM LOADER_PARTITION_SUMMARY
            WHERE row_num <=5;
        
-- ----------------------------------------------------------------------------------------------------------------------------
# Shovels class vs Loader class in loading

select `Primary Machine Category Name`,  `Secondary Machine Category Name`,
		count(`Primary Machine Category Name`) as "total_machines",
        round(sum(`Payload (t)`),2) as 'total payload',
        round(sum(`Payload (t)`)/sum(`Loading Count`),2) as Loading_capacity,
        round(avg(`Loading Efficiency`),2) as avg_loading_efficiency,
        sum(`Loading Count`) as total_loading_count
from `cycle_data`
where `Cycle Type` = "LoaderCycle" and `Secondary Machine Category Name` <> "unknown"
group by `Primary Machine Category Name`,  `Secondary Machine Category Name`;



# Truck Loading qty, loading Capacity, efficiency and count
select `Primary Machine Category Name`,  `Secondary Machine Category Name`,
		count(`Primary Machine Category Name`) as "total_machines",
        round(sum(`Payload (t)`),2) as 'total payload',
        round(sum(`Payload (t)`)/sum(`Loading Count`),2) as Loading_capacity,
        sum(`Loading Count`)
from `cycle_data`
where `Cycle Type` = "TruckCycle"
group by `Primary Machine Category Name`,  `Secondary Machine Category Name`;

-- ----------------------------------------------------------------------------------------------------------------------------

-- payload per cycle

SELECT `Cycle Type`,
    ROUND(SUM(`payload (t)`) / count(`completed cycle count`),2) AS payload_per_cycle
FROM
    `cycle_data`
WHERE  `completed cycle count` = 'Yes'

group by `Cycle Type`;


-- ----------------------------------------------------------------------------------------------------------------------------

# actual vs planned rate
select  *
from actual_planned_metrics_view;

-- Top 5 trucks with best average truck mileage

select *
from fuel_metrics_view
order by `Avg Truck Mileage in Total` desc limit 5;

-- Top 5 trucks with poor average truck mileage

select *
from fuel_metrics_view
order by `Avg Truck Mileage in Total` asc limit 5;

-- Top 5 trucks with best average truck mileage

select *
from fuel_metrics_view
order by `Avg Truck Mileage in Total` desc limit 5;

-- Top 5 trucks with oee_metrics_view



