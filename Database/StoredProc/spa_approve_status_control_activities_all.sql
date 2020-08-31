/****** Object:  StoredProcedure [dbo].[spa_approve_status_control_activities_all]    Script Date: 10/17/2008 10:16:35 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_approve_status_control_activities_all]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_approve_status_control_activities_all]

GO
/****** Object:  StoredProcedure [dbo].[spa_approve_status_control_activities_all]    Script Date: 10/17/2008 10:16:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[spa_approve_status_control_activities_all]
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
                                    @strategy_id VARCHAR(1000) = NULL , 
                                    @book_id VARCHAR(1000) = NULL , 
                                    @asOfDateTo varchar(200)=null,
                                    @activity_mode char(1)=null,
									@img_path varchar(5000) = null 
                                
AS
   
declare @sqlStmt varchar(5000)

BEGIN
			set @sqlStmt = 'EXEC spa_Get_Risk_Control_Activities_approve_all ' + ''''+@userID+''''+','+ ''''+ CAST(ISNULL(@asOfDate, '') AS VARCHAR) +'''' + ','


           if @subID is not NULL

            set @sqlStmt = @sqlStmt + ''''+ CAST(@subID AS VARCHAR) +'''' + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

          if @frequencyID is not NULL

            set @sqlStmt = @sqlStmt + CAST(@frequencyID AS VARCHAR) + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

         
        if @riskPriorityID is not NULL

            set @sqlStmt = @sqlStmt + CAST(@riskPriorityID AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

 
      if @approveRoleID is not NULL

         set @sqlStmt = @sqlStmt + CAST(@approveRoleID AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'




       if @unapprovedFlag is not NULL

            set @sqlStmt = @sqlStmt + '''' + CAST(@unapprovedFlag AS VARCHAR) +''','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

      set @sqlStmt = @sqlStmt + '1,'
      set @sqlStmt = @sqlStmt + '0,'
       
      if @process_number is not NULL

            set @sqlStmt = @sqlStmt + '''' +  CAST(@process_number AS VARCHAR) +'''' + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'
    
     if @risk_description_id is not NULL

            set @sqlStmt = @sqlStmt + CAST(@risk_description_id AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

   if @activity_category_id is not NULL

            set @sqlStmt = @sqlStmt + CAST(@activity_category_id AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


  if @who_for is not NULL

            set @sqlStmt = @sqlStmt + CAST(@who_for AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,' 


 if @where is not NULL

            set @sqlStmt = @sqlStmt + CAST(@where AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,' 

 
if @why is not NULL

            set @sqlStmt = @sqlStmt + CAST(@why AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,' 


if @activity_area is not NULL

            set @sqlStmt = @sqlStmt + CAST(@activity_area AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_sub_area is not NULL

            set @sqlStmt = @sqlStmt + CAST(@activity_sub_area AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_action is not NULL

            set @sqlStmt = @sqlStmt + CAST(@activity_action AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_desc is not NULL

            set @sqlStmt = @sqlStmt + ''''+ CAST(@activity_desc AS VARCHAR(MAX)) +'''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @control_type is not NULL

            set @sqlStmt = @sqlStmt + CAST(@control_type AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @montetory_value_defined is not NULL

            set @sqlStmt = @sqlStmt + '''' + CAST(@montetory_value_defined AS VARCHAR) +'''' + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @process_owner is not NULL

            set @sqlStmt = @sqlStmt + ''''+ CAST(@process_owner AS VARCHAR) +'''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'




if @risk_owner is not NULL

            set @sqlStmt = @sqlStmt + ''''+ CAST(@risk_owner AS VARCHAR) +'''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @risk_control_id is not NULL

            set @sqlStmt = @sqlStmt + CAST(@risk_control_id AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @strategy_id is not NULL

            set @sqlStmt = @sqlStmt + '''' + @strategy_id + '''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @book_id is not NULL

            set @sqlStmt = @sqlStmt + '''' + CAST(@book_id AS VARCHAR) + '''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

  set @sqlStmt = @sqlStmt + 'NULL,NULL,'


if @asOfDateTo is not NULL

            set @sqlStmt = @sqlStmt + ''''+ CAST(@asOfDateTo AS VARCHAR) +''''+','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @activity_mode is not NULL

            set @sqlStmt = @sqlStmt + ''''+ CAST(@activity_mode AS VARCHAR) +'''' + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @img_path is not NULL

            set @sqlStmt = @sqlStmt + ''''+ CAST(@img_path AS VARCHAR(MAX)) +''''
          Else
            set @sqlStmt = @sqlStmt + 'NULL'

         
       

EXEC spa_print @sqlStmt
 --return              

               
exec(@sqlStmt)
END













