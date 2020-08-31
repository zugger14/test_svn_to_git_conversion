/****** Object:  StoredProcedure [dbo].[spa_Create_Daily_Risk_Control_Activities]    Script Date: 10/19/2008 11:49:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_read_control_activities_complete]') AND type in (N'P', N'PC'))
DROP proc [dbo].[spa_read_control_activities_complete]
go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


CREATE proc [dbo].[spa_read_control_activities_complete]
									@userId varchar(200)=null, 	 
									@asOfDate varchar(200)=null, 
                                    @subID varchar(250)=null, 
                                    @frequencyID int=null, 
                                    @riskPriorityID int=Null,
                                    @performRoleID  int=null,      
                                    @activityStatus INT =null, 
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
									@strategy_id varchar(250)=NULL,
                                    @book_id VARCHAR(1000)=null, 
                                    @asOfDateTo varchar(200)=null,
                                    @next_action INT=null,
                                    @img_path varchar(5000) = null,
									@force_build char(1)=null
                                
AS
   
declare @sqlStmt varchar(5000)

BEGIN
			set @sqlStmt = 'EXEC spa_Get_Risk_Control_Activities_Complete ' + ''''+@userID+''''+','+ ''''+ ISNULL(@asOfDate, '1900-01-01') +'''' + ','


           if @subID is not NULL

            set @sqlStmt = @sqlStmt + ''''+ CAST(@subID AS VARCHAR(1000)) +'''' + ','
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




       if @activityStatus is not NULL

            set @sqlStmt = @sqlStmt + CAST(@activityStatus AS VARCHAR) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

      set @sqlStmt = @sqlStmt + '1,'
      set @sqlStmt = @sqlStmt + '0,'
       
      if @process_number is not NULL

            set @sqlStmt = @sqlStmt + CAST(@process_number AS VARCHAR) +','
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

            set @sqlStmt = @sqlStmt + ''''+ CAST(@activity_desc AS VARCHAR(MAX)) +'''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @control_type is not NULL

            set @sqlStmt = @sqlStmt + cast(@control_type as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @montetory_value_defined is not NULL

            set @sqlStmt = @sqlStmt + CAST(@montetory_value_defined AS VARCHAR) +','
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

            set @sqlStmt = @sqlStmt + cast(@risk_control_id as varchar) +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @strategy_id is not NULL

            set @sqlStmt = @sqlStmt + '''' + @strategy_id + '''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @book_id is not NULL

            set @sqlStmt = @sqlStmt + '''' + cast(@book_id as VARCHAR(1000)) + '''' +','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'

  set @sqlStmt = @sqlStmt + 'NULL,NULL,'


if @asOfDateTo is not NULL

            set @sqlStmt = @sqlStmt + ''''+ CAST(@asOfDateTo AS VARCHAR) +''''+','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'


if @next_action is not NULL

            set @sqlStmt = @sqlStmt +  CAST(@next_action AS VARCHAR) + ','
          Else
            set @sqlStmt = @sqlStmt + 'NULL,'



if @img_path is not NULL
	set @sqlStmt = @sqlStmt + '''' + CAST(@img_path AS VARCHAR(MAX)) + '''' + ','
else
	set @sqlStmt = @sqlStmt + 'NULL,'


if @force_build is not NULL
	set @sqlStmt = @sqlStmt + '''' + CAST(@force_build AS VARCHAR)+ ''''
else
	set @sqlStmt = @sqlStmt + '''n'''

EXEC spa_print @sqlStmt               
exec(@sqlStmt)
END














