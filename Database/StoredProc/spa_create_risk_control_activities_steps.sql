
if object_id('[dbo].[spa_create_risk_control_activities_steps]','p') is not null
drop proc [dbo].[spa_create_risk_control_activities_steps]
/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/
-- EXEC spa_Get_Risk_Control_Activities_Audit '135', 'farrms_admin', '2006-01-31', '2006-12-31',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, null

--EXEC spa_Get_Risk_Control_Activities_Audit '135', 'farrms_admin', '2006-01-31', '2006-12-31',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL, null
go
CREATE PROC [dbo].[spa_create_risk_control_activities_steps]
	@riskControlId int=null 
As
 DECLARE @sqlStmt as varchar(5000)
 DECLARE @risk_id as varchar(50)
 DECLARE @sql as varchar(5000)
 set @risk_id = cast(@riskControlId as varchar) 
declare @flag as varchar(10)
set @flag = 'i'
 CREATE TABLE #tempControlsSteps (
	[control_activity] [varchar] (200) COLLATE DATABASE_DEFAULT  NULL ,
	[risk_control_step_id] int NULL ,
	[risk_control_id] int NULL ,
	[step_sequence] [varchar] (50) COLLATE DATABASE_DEFAULT,
	[step_desc1] [varchar] (200) COLLATE DATABASE_DEFAULT NULL ,
	[step_desc2] [varchar] (200) COLLATE DATABASE_DEFAULT NULL ,
	[step_reference] [varchar] (200) COLLATE DATABASE_DEFAULT 
    
)

 BEGIN
 set  @sqlStmt = 'INSERT  #tempControlsSteps select CAST(prc.risk_control_id AS varchar) + '' - '' + DBO.FNAGetActivityName(prc.risk_control_id) AS control_activity,'
           set @sqlStmt = @sqlStmt + 'isnull(prcs.risk_control_step_id,'''') as risk_control_step_id,'
           set @sqlStmt = @sqlStmt + 'isnull(prcs.risk_control_id, '''') as risk_control_id,'
           set @sqlStmt = @sqlStmt + 'CAST(isnull(prcs.step_sequence,'''') as varchar) as step_sequence,'
           set @sqlStmt = @sqlStmt + 'isnull((CAST(prcs.step_sequence as varchar) + ''. '' +'
           set @sqlStmt = @sqlStmt + 'prcs.step_desc1),'''') as step_desc1,'
           set @sqlStmt = @sqlStmt + 'isnull(prcs.step_desc2, '''') as step_desc2,' 
           set @sqlStmt = @sqlStmt +  'isnull(prcs.step_reference, '''') as step_reference '
          

           set @sqlStmt = @sqlStmt +  'from process_risk_controls prc INNER JOIN '
           set @sqlStmt = @sqlStmt +  'process_risk_controls_steps prcs ON prc.risk_control_id = prcs.risk_control_id '
           set @sqlStmt = @sqlStmt +  'where prc.risk_control_id ='  + cast(@riskControlId as varchar)
           set @sqlStmt = @sqlStmt + ' order by prcs.step_sequence'
--print @sqlStmt

execute(@sqlStmt)

	SELECT
		risk_control_step_id as [Risk Control Step ID],
		control_activity as [Control Activities],
   		step_desc1 as 'Step Description',
 		step_desc2 as Description,
		step_reference as Reference 
    from  #tempControlsSteps
  --print @sql
	--exec(@sql) 
 END







