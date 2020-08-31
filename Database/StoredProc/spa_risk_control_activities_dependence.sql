/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/

IF object_id('[dbo].[spa_risk_control_activities_dependence]','p') is not null
drop proc [dbo].[spa_risk_control_activities_dependence]
go

CREATE proc [dbo].[spa_risk_control_activities_dependence] 
                     @risk_control_id int=null,
                     @add_risk_control_id int=null, 
                     @process_number int=null , 
                     @sub_id int=null, 
                     @flag varchar(20)=null                                       
AS
BEGIN

declare @sqlStmt varchar(5000)
declare @risk_ctrl_id varchar(50)
set @risk_ctrl_id = cast(@risk_control_id as varchar)
  
  set @sqlStmt = 'SELECT process_control_header.process_number  [Process Number] ,'
  set @sqlStmt = @sqlStmt + '(cast(process_risk_description.risk_description_id as varchar) + '' - '' + process_risk_description.risk_description) [Risk Description] ,'
  set @sqlStmt = @sqlStmt + '(cast(process_risk_controls.risk_control_id as varchar) + '' - '' +  DBO.FNAGetActivityName(process_risk_controls.risk_control_id)) [Control Actiivty], '
  set @sqlStmt = @sqlStmt + 'process_risk_controls.risk_control_id [Risk Control Id] '

  
 -- set @sqlStmt = @sqlStmt +'dbo.FNAHyperLinkText3(400, ''Add'','+@risk_ctrl_id+', cast(process_risk_controls.risk_control_id as varchar),''"i"'') as add_action '
        set @sqlStmt = @sqlStmt +'FROM process_control_header INNER JOIN
                                 process_risk_description ON process_control_header.process_id = process_risk_description.process_id INNER JOIN
                               	process_risk_controls ON process_risk_description.risk_description_id = process_risk_controls.risk_description_id


                            	where 1=1 '

        if @risk_control_id is not null

           set @sqlStmt = @sqlStmt + 'AND process_risk_controls.risk_control_id <> ' + cast(@risk_control_id as  varchar)


        If @sub_id is NULL 
               set @sqlStmt = @sqlStmt +'AND process_control_header.fas_subsidiary_id Is NULL '
            Else
               set @sqlStmt = @sqlStmt +'AND process_control_header.fas_subsidiary_id ='+ cast(@sub_id as varchar)
           
            set @sqlStmt = @sqlStmt + 'order by process_control_header.process_number, process_risk_description.risk_description_id, process_risk_controls.risk_control_id'
EXEC spa_print @sqlStmt
exec(@sqlStmt)

END





