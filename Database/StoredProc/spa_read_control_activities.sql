
GO
/****** Object:  StoredProcedure [dbo].[spa_read_control_activities]    Script Date: 10/27/2008 16:21:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_read_control_activities]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_read_control_activities]


GO
/****** Object:  StoredProcedure [dbo].[spa_read_control_activities]    Script Date: 10/27/2008 16:21:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[spa_read_control_activities]
									@userId varchar(200)=null, 	 
									@asOfDate varchar(200)=null, 
                                    @subID varchar(200)=null, 
                                    @frequencyID int=null, 
                                    @riskPriorityID int=Null,
                                    @performRoleID  int=null,      
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
                                    @activity_desc varchar(200)=null, 
                                    @control_type  int=null, 
                                    @montetory_value_defined char(1)=null, 
                                    @process_owner varchar(200)=null, 
                                    @risk_owner varchar(200)=null, 
                                    @risk_control_id int=null, 
                                    @strategy_id int=null, 
                                    @book_id int=null, 
                                    @asOfDateTo varchar(200)=NULL,
									@message_id INT = NULL 
AS
   
declare @sqlStmt varchar(5000)

BEGIN
	IF @unapprovedFlag = 'R'
		set @sqlStmt = 'EXEC spa_Get_Risk_Control_Activities_perform_reminder ' + ''''+@userID+''''+','+ ''''+@asOfDate+'''' + ','
	ELSE
		set @sqlStmt = 'EXEC spa_Get_Risk_Control_Activities_perform ' + ''''+@userID+''''+','+ ''''+@asOfDate+'''' + ','

           if @subID is not NULL

            set @sqlStmt = @sqlStmt + ''''+@subID+'''' + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

          if @frequencyID is not NULL

            set @sqlStmt = @sqlStmt + cast(@frequencyID as varchar) + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

         
        if @riskPriorityID is not NULL

            set @sqlStmt = @sqlStmt + cast(@riskPriorityID as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

 
      if @performRoleID is not NULL

         set @sqlStmt = @sqlStmt + cast(@performRoleID as varchar) +','
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

            set @sqlStmt = @sqlStmt + cast(@risk_description_id as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


   if @activity_category_id is not NULL

            set @sqlStmt = @sqlStmt + cast(@activity_category_id as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


  if @who_for is not NULL

            set @sqlStmt = @sqlStmt + cast(@who_for as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,' 


 if @where is not NULL

            set @sqlStmt = @sqlStmt + cast(@where as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,' 

 
if @why is not NULL

            set @sqlStmt = @sqlStmt + cast(@why as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,' 


if @activity_area is not NULL

            set @sqlStmt = @sqlStmt + cast(@activity_area as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_sub_area is not NULL

            set @sqlStmt = @sqlStmt + cast(@activity_sub_area as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_action is not NULL

            set @sqlStmt = @sqlStmt + cast(@activity_action as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_desc is not NULL

            set @sqlStmt = @sqlStmt + ''''+@activity_desc+'''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @control_type is not NULL

            set @sqlStmt = @sqlStmt + cast(@control_type as varchar) +','
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

            set @sqlStmt = @sqlStmt + cast(@risk_control_id as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @strategy_id is not NULL

            set @sqlStmt = @sqlStmt + cast(@strategy_id as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @book_id is not NULL

            set @sqlStmt = @sqlStmt + cast(@book_id as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

  set @sqlStmt = @sqlStmt + 'NULL,NULL,'


if @asOfDateTo is not NULL

            set @sqlStmt = @sqlStmt + ''''+@asOfDateTo+'''' + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @message_id is not NULL
	set @sqlStmt = @sqlStmt + ''''+ CAST(@message_id AS VARCHAR) +''''
Else
	set @sqlStmt = @sqlStmt + 'NULL'         
       

EXEC spa_print @sqlStmt
 --return              

               
exec(@sqlStmt)
END










