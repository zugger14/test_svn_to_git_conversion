if object_id('[dbo].[spa_read_process_risk_controls_date]','p') is not null
drop proc [dbo].[spa_read_process_risk_controls_date]
go
/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/


-- exec spa_process_risk_controls 'a', 1

CREATE  PROCEDURE [dbo].[spa_read_process_risk_controls_date]
	 
                                    @userID varchar(200)=null, 
                                    @asOfDate varchar(200)=null, 
                                    @subID varchar(200)=null, 
                                    @frequencyID int=null , 
                                    @riskPriorityID int=null, 
                                    @unapprovedFlag char(1)=null, 
                                    @process_number varchar(200)=null,
                                    @risk_description_id int=null, 
                                    @activity_category_id int=null,
                                    @who_for int=null, 
                                    @where int=null, 
                                    @why int=null,
                                    @activity_area int=null, 
                                    @activity_sub_area int=null, 
                                    @activity_action int=null, 
                                    @activity_desc varchar(300)=null, 
                                    @control_type int=null, 
                                    @montetory_value_defined char(1)=null, 
                                    @process_owner int=null, 
                                    @risk_owner int=null, 
                                    @risk_control_id int=null, 
                                    @strategy_id int=null,
                                    @book_id int=null,
                                    @asOfDateTo varchar(200)=null
	

AS



declare @sqlStmt varchar(5000)

 
BEGIN
	set  @sqlStmt = 'SELECT  DISTINCT portfolio_hierarchy.entity_id AS subsidiary_id,'
           set  @sqlStmt = @sqlStmt + 'isnull(portfolio_hierarchy.entity_name, '''') AS Subsidiary,'
           set  @sqlStmt = @sqlStmt + 'dbo.FNADateFormat(prca.as_of_date) AS as_of_date, rp.code As risk_priority, rf.code as run_frequency'
           set  @sqlStmt = @sqlStmt + ' , prc.run_frequency as run_frequency_id, prd.risk_priority risk_priority_id, dbo.FNAGetSQLStandardDate(prca.as_of_date) AS as_of_date_argument '
           set  @sqlStmt = @sqlStmt + 'FROM         process_risk_controls prc INNER JOIN
                                       static_data_value rf ON prc.run_frequency = rf.value_id INNER JOIN
                                       process_risk_description prd ON prc.risk_description_id = prd.risk_description_id INNER JOIN
                                       static_data_value rp ON  prd.risk_priority = rp.value_id INNER JOIN
                                       process_control_header pch ON prd.process_id = pch.process_id INNER JOIN
                                       process_risk_controls_activities prca ON prc.risk_control_id = prca.risk_control_id LEFT OUTER JOIN
                                       portfolio_hierarchy ON pch.fas_subsidiary_id = portfolio_hierarchy.entity_id '


               

                If (@frequencyID is not null  Or @subID is not null  Or @riskPriorityID is not null Or @unapprovedFlag is not null  And upper(@unapprovedFlag) <> 'A')
                   set  @sqlStmt = @sqlStmt + 'WHERE 1=1 '
              

                --filter by risk priority id if selected
                If @riskPriorityID is not null 
                   set  @sqlStmt = @sqlStmt + 'AND prd.risk_priority = ' +  cast(@riskPriorityID as varchar)
                    
               


                --filter by frequency_id if selected
                If @frequencyID is not null 
                     set  @sqlStmt = @sqlStmt + ' AND prc.run_frequency = ' + cast(@frequencyID as varchar)
                   

                --filter by susidiary_id if selected
                If @subID is not null  
                    set  @sqlStmt = @sqlStmt + ' AND portfolio_hierarchy.entity_id in' + '('+@subID+')' 

                If upper(@unapprovedFlag) = 'C' 
                    set  @sqlStmt = @sqlStmt+ ' AND prca.control_status = in (727, 728)'
                Else If upper(@unapprovedFlag) = 'U' 
                    set  @sqlStmt = @sqlStmt + ' AND prca.control_status = 726'
                   

                set  @sqlStmt = @sqlStmt + ' ORDER BY portfolio_hierarchy.entity_id, prd.risk_priority, prc.run_frequency, as_of_date DESC '
                 

EXEC spa_print @sqlStmt
exec(@sqlStmt)
               
END



