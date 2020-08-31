if object_id('[dbo].[spa_approve_status_control_activities]','p') is not null
drop proc [dbo].[spa_approve_status_control_activities]
go
/*
Vishwas Khanal
Dated : 09.April.2009
Compliance Integration to TRM
*/

CREATE proc [dbo].[spa_approve_status_control_activities]
									@userId varchar(200)=null, 	 
									@asOfDate varchar(200)=null, 
                                    @subID varchar(200)=null, 
                                    @frequencyID int=null, 
                                    @riskPriorityID int=Null,
                                    @approveRoleID  int=null,      
                                    @unapprovedFlag varchar(200)=null, 
                                    @process_number varchar(200)=null, 
                                    @risk_description_id int=null, 
                                    @activity_category_id int=null, 
                                    @who_for int=null, 
                                    @where int=null, 
                                    @why int=null, 
                                    @activity_area int=null, 
                                    @activity_sub_area int=null, 
                                    @activity_action int=null, 
                                    @activity_desc varchar(200)=null, 
                                    @control_type  int=null, 
                                    @montetory_value_defined char(1)=null, 
                                    @process_owner varchar(200)=null, 
                                    @risk_owner varchar(200)=null, 
                                    @risk_control_id int=null, 
                                    @strategy_id int=null, 
                                    @book_id int=null, 
                                    @asOfDateTo varchar(200)=null
                                
AS
   
declare @sqlStmt varchar(5000)

BEGIN
			set @sqlStmt = 'EXEC spa_Get_Risk_Control_Activities_approve ' + ''''+@userID+''''+','+ ''''+@asOfDate+'''' + ','


           if @subID is not NULL

            set @sqlStmt = @sqlStmt + ''''+@subID+'''' + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

          if @frequencyID is not NULL

            set @sqlStmt = @sqlStmt + @frequencyID + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

         
        if @riskPriorityID is not NULL

            set @sqlStmt = @sqlStmt + @riskPriorityID +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

 
      if @approveRoleID is not NULL

         set @sqlStmt = @sqlStmt + @approveRoleID +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'




       if @unapprovedFlag is not NULL

            set @sqlStmt = @sqlStmt + @unapprovedFlag +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

      set @sqlStmt = @sqlStmt + '1,'
      set @sqlStmt = @sqlStmt + '0,'
       
      if @process_number is not NULL

            set @sqlStmt = @sqlStmt + @process_number +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

    
     if @risk_description_id is not NULL

            set @sqlStmt = @sqlStmt + @risk_description_id +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


   if @activity_category_id is not NULL

            set @sqlStmt = @sqlStmt + @activity_category_id +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


  if @who_for is not NULL

            set @sqlStmt = @sqlStmt + @who_for +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,' 


 if @where is not NULL

            set @sqlStmt = @sqlStmt + @where +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,' 

 
if @why is not NULL

            set @sqlStmt = @sqlStmt + @why +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,' 


if @activity_area is not NULL

            set @sqlStmt = @sqlStmt + @activity_area +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_sub_area is not NULL

            set @sqlStmt = @sqlStmt + @activity_sub_area +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_action is not NULL

            set @sqlStmt = @sqlStmt + @activity_action +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_desc is not NULL

            set @sqlStmt = @sqlStmt + ''''+@activity_desc+'''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @control_type is not NULL

            set @sqlStmt = @sqlStmt + @control_type +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @montetory_value_defined is not NULL

            set @sqlStmt = @sqlStmt + @montetory_value_defined +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @process_owner is not NULL

            set @sqlStmt = @sqlStmt + ''''+@process_owner+'''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'




if @risk_owner is not NULL

            set @sqlStmt = @sqlStmt + ''''+@risk_owner+'''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @risk_control_id is not NULL

            set @sqlStmt = @sqlStmt + @risk_control_id +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @strategy_id is not NULL

            set @sqlStmt = @sqlStmt + @strategy_id +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @book_id is not NULL

            set @sqlStmt = @sqlStmt + @book_id +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

  set @sqlStmt = @sqlStmt + 'NULL,NULL,'


if @asOfDateTo is not NULL

            set @sqlStmt = @sqlStmt + ''''+@asOfDateTo+''''
          Else
            set @sqlStmt = @sqlStmt + 'NULL'


         
       

EXEC spa_print @sqlStmt
 --return              

               
exec(@sqlStmt)
END














