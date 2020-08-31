IF OBJECT_ID(N'[dbo].[spa_get_run_measurement_process_status]', N'P') IS NOT NULL
	DROP PROCEDURE [dbo].[spa_get_run_measurement_process_status]
GO 



---This procedure returns the status of a measurement process run
-- DROP PROCEDURE spa_get_run_measurement_process_status  
-- EXEC spa_get_run_measurement_process_status  '111222333'
-- EXEC spa_get_run_measurement_process_status  '555666777'
--'111222333', '555666777'

CREATE PROCEDURE [dbo].[spa_get_run_measurement_process_status]
	@process_id varchar(50),
	@run_process_step int = null
AS

--If @run_process_step = 1
		
SELECT  CASE when (status_code = 'Error') then '<font color="red"><b>' + status_code + '</b></font>' 
	else	status_code end as Code,
	CASE WHEN (calc_type = 'd') then 'De-Designation' else 'Designation' end as Type, 
	status_description as Description, 
	'Message' as Status, 
	'Measurement' as [Module],
	'runMeasurement' as Source
FROM   	measurement_process_status where 
process_id = @process_id
--Else
UNION
SELECT  CASE when (code = 'Error') then '<font color="red"><b>' + code + '</b></font>' 
	else	code end as code,
	CASE WHEN (calc_type = 'd') then 'De-Designation' else 'Designation' end as Type,
	'<b>' + description + '</b>' AS description, 
	'Completed' AS status, 
	[module], 
	source
FROM    measurement_process_status_completed
WHERE 	process_id =  @process_id

order by CASE WHEN (calc_type = 'd') then 'De-Designation' else 'Designation' end







