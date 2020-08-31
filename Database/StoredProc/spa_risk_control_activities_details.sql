
if object_id('[dbo].[spa_risk_control_activities_details]','p') is not null
	DROP proc [dbo].[spa_risk_control_activities_details] 
go

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE  proc [dbo].[spa_risk_control_activities_details] 
	@riskControlId int = null
                                       
AS
BEGIN

declare @sqlStmt varchar(5000)

CREATE TABLE #tempControls_refine (
	[tmp_risk_control_id][varchar](200) COLLATE DATABASE_DEFAULT NULL,
	[control_activity] [varchar](200) COLLATE DATABASE_DEFAULT NULL, 
    [run_frequency] [varchar](200) COLLATE DATABASE_DEFAULT NULL,
    [PerformRole] [varchar](200) COLLATE DATABASE_DEFAULT NULL,
    [ApproveRole] [varchar](200) COLLATE DATABASE_DEFAULT NULL,
    [depend_on_activity] [varchar](200) COLLATE DATABASE_DEFAULT NULL,
    [perform_role_id] INT NULL,
    [approve_role_id] INT NULL,
    [threshold_days] INT NULL,
    [requires_approval] [varchar](10) COLLATE DATABASE_DEFAULT NULL,
    [risk_control_id] INT NULL,
    [requires_proof] [varchar](10) COLLATE DATABASE_DEFAULT NULL, 
    [control_objective] [varchar](100) COLLATE DATABASE_DEFAULT NULL,
    [control_objective_id] [int] NULL, 
    [email] [varchar] (50) COLLATE DATABASE_DEFAULT NULL  
    
   -- [depend_risk_control_id] [int] NULL, 
    
 
)




set @sqlStmt = 'insert #tempControls_refine  SELECT   DISTINCT(CAST(prc.risk_control_id AS varchar)) ,CAST(prc.risk_control_id AS varchar) + '' - '' + DBO.FNAGetActivityName(prc.risk_control_id) AS control_activity,'


set @sqlStmt = @sqlStmt +'isnull(rf.code, '''') AS run_frequency,'


set @sqlStmt = @sqlStmt +'isnull(asrP.role_name, '''') AS PerformRole,'

set @sqlStmt = @sqlStmt +'isnull(asrA.role_name, '''') AS ApproveRole,'

set @sqlStmt = @sqlStmt +'CAST(prcdpd.risk_control_id AS varchar) + '' - '' + DBO.FNAGetActivityName(prcdpd.risk_control_id) AS depend_on_activity,'

set @sqlStmt = @sqlStmt +'isnull(prc.perform_role, '''') as perform_role_id,'
    



set @sqlStmt = @sqlStmt +'isnull(prc.approve_role, '''') as approve_role_id,'


set @sqlStmt = @sqlStmt +'isnull(cast(prc.threshold_days as varchar),'''') as threshold_days,'


set @sqlStmt = @sqlStmt +' CASE prc.requires_approval when ''y'' then ''Yes'' Else '''' END as requires_approval,'

set @sqlStmt = @sqlStmt +' CAST(prc.risk_control_id AS varchar) as risk_control_id,'
set @sqlStmt = @sqlStmt +'CASE prc.requires_proof when ''y'' then ''Yes'' Else '''' END as requires_proof,'


set @sqlStmt = @sqlStmt +'isnull(co.code, '''') as control_objective,'
set @sqlStmt = @sqlStmt +'isnull(prc.control_objective,'''') as control_objective_id,'
set @sqlStmt = @sqlStmt +' '' '' as email'

--set @sqlStmt = @sqlStmt +'isnull(CAST(prcd.risk_control_id_depend_on AS varchar),'''') as depend_risk_control_id '


            set @sqlStmt = @sqlStmt +' FROM process_risk_controls prc LEFT OUTER JOIN
             static_data_value co ON prc.control_objective = co.value_id LEFT OUTER   JOIN
             static_data_value rf ON prc.run_frequency = rf.value_id LEFT OUTER   JOIN
            application_security_role asrP ON prc.perform_role = asrP.role_id LEFT OUTER   JOIN
             application_security_role asrA ON prc.approve_role = asrA.role_id LEFT OUTER JOIN
            process_risk_controls_dependency prcd ON prc.risk_control_id = prcd.risk_control_id LEFT OUTER JOIN
            process_risk_controls prcdpd ON prcd.risk_control_id_depend_on = prcdpd.risk_control_id '


            If @riskControlId is not NULL
              set @sqlStmt = @sqlStmt + 'WHERE prc.risk_control_id ='  + cast(@riskControlId as varchar) 
          
           -- set @sqlStmt = @sqlStmt  + ' ORDER BY prc.risk_control_id, prcd.risk_control_id_depend_on'
EXEC spa_print @sqlStmt
exec(@sqlStmt)

SELECT #tempControls_refine.control_activity as 'Control Activity',
       #tempControls_refine.control_objective as 'Control Objective',
       
       #tempControls_refine.run_frequency as 'Control Frequency',
       #tempControls_refine.threshold_days as 'Threshold (Days)',
       #tempControls_refine.PerformRole as 'Peform Role',
       #tempControls_refine.ApproveRole as 'Approve Role',
       #tempControls_refine.requires_approval as 'Requires Approval',
       #tempControls_refine.requires_proof as 'Requires Proof',
       case when ((select count(*) from process_risk_controls_email where risk_control_id = + cast(@riskControlId as varchar)) = 0) then
       'No' else
       dbo.FNAComplianceHyperlink('a',409,'Yes',cast(@riskControlId as varchar),default,default,default,default,default,default) end as 'Communication Status'
       
       --case when #tempControls_refine.depend_on_activity is null then
       ---dbo.FNAComplianceHyperlink('b',396, 'Add', cast(#tempControls_refine.risk_control_id as varchar),'''i''')+' '+dbo.FNAComplianceHyperlink('b',396, 'Delete', cast(#tempControls_refine.risk_control_id as varchar),'''d''')  
       --else
        ---dbo.FNAComplianceHyperlink('a',333, #tempControls_refine.depend_on_activity, cast(#tempControls_refine.depend_risk_control_id as varchar)) + ' ' +dbo.FNAComplianceHyperlink('b',396, 'Add', cast(#tempControls_refine.risk_control_id as varchar),'''i''')+' '+dbo.FNAComplianceHyperlink('b',396, 'Delete', cast(#tempControls_refine.risk_control_id as varchar),'''d''') end  as 'Depend On Activity'

 FROM #tempControls_refine

END







