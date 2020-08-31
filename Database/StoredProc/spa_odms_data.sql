IF OBJECT_ID(N'spa_odms_data', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_odms_data]
GO 

CREATE PROC [dbo].[spa_odms_data] 
	@fromdate varchar(20),		
	@todate varchar(20),
	@user_id varchar(100),
	@source_system_id int=NULL	
AS
 
BEGIN

DECLARE @source VARCHAR(100)

-- SELECT @source=source_system_name from source_system_description where source_system_id=@source_system_id
-- 
-- IF @source<>'ODMS'
-- BEGIN
-- 	Exec spa_ErrorHandler 0, 'ODMS Import', 
-- 			'spa_odms_data_as_job', 'Status', 
-- 			'Cannot Import from selected source.', 
-- 			'Please select different source.'
-- 
-- RETURN
-- END

DECLARE @job_name    VARCHAR(50)
DECLARE @process_id  VARCHAR(100)
DECLARE @desc        VARCHAR(500)
DECLARE @spa         VARCHAR(5000)


SET @process_id = REPLACE(NEWID(), '-', '_')
SET @job_name = 'ODMS_' + @process_id


DECLARE @year_from int
DECLARE @month_from int		
DECLARE @year_to int
DECLARE @month_to int	
DECLARE @sqlStmt varchar(5000)
DECLARE @tempTable varchar(200)	

SET @year_from=YEAR(@fromdate)
SET @month_from=MONTH(@fromdate)
SET @year_to=YEAR(@todate)
SET @month_to=MONTH(@todate)

set @tempTable=dbo.FNAProcessTableName('odmsdata', @user_id,@process_id)
declare @user_name varchar(100)
set @user_name=dbo.FNADBUser()
 EXEC sp_droplinkedsrvlogin 'ODMS_Rectracker',@user_name
 EXEC sp_addlinkedsrvlogin 'ODMS_Rectracker',  false,@user_name, 'COD_USER', 'COD8ES'


EXEC('
CREATE TABLE '+@tempTable+'( 
	UTIL_CODE VARCHAR(100),
	UNIT_TYPE_DESCR  VARCHAR(100),
	PLANT_ID VARCHAR(100),
	PLANT_NAME VARCHAR(100),
	PLANT_CODE VARCHAR(100),
	STATE_CODE VARCHAR(100),
	UNIT_CODE VARCHAR(100),
	UNIT_MSR_YR INT,
	UNIT_MSR_MTH INT,
	ACT_GR_MTHLY_MWH FLOAT,
	ACT_NET_MTHLY_MWH FLOAT
)')
	
SET @sqlStmt='
INSERT INTO '+@tempTable+'  
select * FROM OPENQUERY(ODMS_Rectracker,''
	    SELECT 
             COD_UTILITY.UTIL_CODE,
             COD_UNIT_TYPE.UNIT_TYPE_DESCR, 
             Cod_plant.PLANT_ID,
             COD_PLANT.PLANT_NAME, 
             COD_PLANT.Plant_code, 
 	     COD_STATE.STATE_CODE,
             COD_UNIT.UNIT_CODE,
             COD_MTHLY_UNIT_MEASURE.UNIT_MSR_YR, 
             COD_MTHLY_UNIT_MEASURE.UNIT_MSR_MTH, 
             COD_MTHLY_UNIT_MEASURE.ACT_GR_MTHLY_MWH, 
             COD_MTHLY_UNIT_MEASURE.ACT_NET_MTHLY_MWH

 FROM COD_PLANT, COD_UNIT,COD_UNIT_TYPE,COD_MTHLY_UNIT_MEASURE,
COD_UTILITY, COD_STATE

 WHERE COD_UTILITY.UTIL_ID = COD_PLANT.UTIL_ID 

      AND COD_MTHLY_UNIT_MEASURE.UNIT_ID = COD_UNIT.UNIT_ID

      AND COD_PLANT.PLANT_ID = COD_UNIT.PLANT_ID

      AND COD_UNIT.UNTY_ID = COD_UNIT_TYPE.UNTY_ID

      AND cod_state.state_id = cod_plant.state_id and COD_MTHLY_UNIT_MEASURE.ACT_NET_MTHLY_MWH>0
'' )
where cast(cast(UNIT_MSR_YR as varchar)+''/''+cast(UNIT_MSR_MTH as varchar)+''/''+''01'' as datetime) 
between '''+cast(@fromdate as varchar)+''' and '''+cast(@todate as varchar)+'''
and cast(Plant_ID  as varchar) in
(select rg.id2 from rec_generator rg inner join source_counterparty sc
  on rg.ppa_counterparty_id=sc.source_counterparty_id where int_ext_flag=''i'')
'
--print @sqlStmt
EXEC(@sqlStmt)

SET @spa = ' spa_odms_data_as_job ''' +@fromdate + ''', ' +''''+@todate+ ''', ' +'''' +  @tempTable + ''''

EXEC spa_run_sp_as_job @job_name, @spa, 'ODMS Import', @user_id

Exec spa_ErrorHandler 0, 'ODMS Import', 
			'spa_odms_data_as_job', 'Status', 
			'Data Import Process has been run and will complete shortly.', 
			'Please check/refresh your message board.'
END




