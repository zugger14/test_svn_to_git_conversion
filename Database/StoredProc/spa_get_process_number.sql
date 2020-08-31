IF OBJECT_ID(N'[dbo].[spa_get_process_number]', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_get_process_number]
 GO 



--drop proc spa_get_process_number
--exec spa_get_process_number

-----this procedure returns Process_number and process_name

CREATE PROCEDURE [dbo].[spa_get_process_number] 
@sub_id int=null

 AS
if @sub_id is null
SELECT     process_number as process_number, process_number + ' - ' + process_name AS process_desc FROM       
 process_control_header ORDER BY process_number
else
SELECT  process_number as process_number, process_number + ' - ' + process_name AS process_desc FROM       
process_control_header where fas_subsidiary_id=@sub_id
ORDER BY process_number








