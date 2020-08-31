
if object_id('[dbo].[spa_process_risk_controls_status_date]','p') is not null
drop proc [dbo].[spa_process_risk_controls_status_date]
go
/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/


-- exec spa_process_risk_controls 'a', 1

CREATE PROCEDURE [dbo].[spa_process_risk_controls_status_date]
	                                
                                    @subID varchar(200), 
                                    @frequencyID int=null,
                                    @riskPriorityID int=null,
                                    @unapprovedFlag char(1)=null
                                    	

AS



declare @sql_stmt varchar(5000)

CREATE TABLE #tempControls (
	[subsidiary_id] [int]   NULL ,
	[subsidiary] [varchar] (100) COLLATE DATABASE_DEFAULT NULL ,
	[as_of_date] [varchar](100) COLLATE DATABASE_DEFAULT  NULL ,
    [risk_priority] [varchar](100) COLLATE DATABASE_DEFAULT  NULL ,
	[run_frequency] [varchar] (50) COLLATE DATABASE_DEFAULT  NULL ,
	[run_frequency_id] [int]  NULL ,
	[risk_priority_id] [int]  NULL ,
	[as_of_date_argument] [varchar] (100) COLLATE DATABASE_DEFAULT  NULL 
	 
)


BEGIN
	set @sql_stmt = 'INSERT #tempControls SELECT  DISTINCT portfolio_hierarchy.entity_id AS subsidiary_id,
                  isnull(portfolio_hierarchy.entity_name, '''') AS subsidiary,
                  dbo.FNADateFormat(prca.as_of_date) AS as_of_date,
                  rp.code As risk_priority,
                  rf.code as run_frequency,
                  prc.run_frequency as run_frequency_id,
                  prd.risk_priority risk_priority_id,
                  dbo.FNAGetSQLStandardDate(prca.as_of_date) AS as_of_date_argument
                  FROM         process_risk_controls prc INNER JOIN
                               static_data_value rf ON prc.run_frequency = rf.value_id INNER JOIN
                               process_risk_description prd ON prc.risk_description_id = prd.risk_description_id INNER JOIN
                               static_data_value rp ON  prd.risk_priority = rp.value_id INNER JOIN
                               process_control_header pch ON prd.process_id = pch.process_id INNER JOIN
                               process_risk_controls_activities prca ON prc.risk_control_id = prca.risk_control_id LEFT OUTER JOIN
                               portfolio_hierarchy ON pch.fas_subsidiary_id = portfolio_hierarchy.entity_id
                  WHERE 1=1'


            

               

           
                If  @riskPriorityID  is not NULL
                   set @sql_stmt = @sql_stmt + ' AND prd.risk_priority =' + cast(@riskPriorityID as varchar)

               If  @frequencyID is not NULL
                   set @sql_stmt = @sql_stmt + ' AND prc.run_frequency =' + cast(@frequencyID as varchar)
                   
              
       

               
                 If  @subID is not NULL
                    set @sql_stmt = @sql_stmt + 'AND portfolio_hierarchy.entity_id in ('''+@subID+''')'
                   

              
                If @unapprovedFlag = 'C' 

                    set @sql_stmt = @sql_stmt  + 'prca.control_status  in (727, 728)'

                Else If @unapprovedFlag = 'U' 
                    set @sql_stmt = @sql_stmt +'prca.control_status = 726'
                    

               set @sql_stmt = @sql_stmt + 'ORDER BY portfolio_hierarchy.entity_id, prd.risk_priority, prc.run_frequency, as_of_date DESC '
END

exec(@sql_stmt)

 select  subsidiary [Subsidiary],
         risk_priority [Priority],
         run_frequency [Frequency],
         as_of_date [Date]
         
           



 from #tempControls

