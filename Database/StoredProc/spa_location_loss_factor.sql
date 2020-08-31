IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_location_loss_factor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_location_loss_factor]
go

CREATE PROCEDURE [dbo].[spa_location_loss_factor]
	@flag CHAR(1),
	@location_loss_factor_id INT = NULL,
	@effective_date VARCHAR(100) = NULL,
	@from_location_id INT = NULL,
	@to_location_id INT = NULL,
	@loss_factor FLOAT = NULL,
	@meter_from INT = NULL,
	@meter_to INT = NULL,
	@rate_loss_flag CHAR(1) = NULL,
	@rate_schedule INT = NULL,
	@from_location_group_id INT = NULL,
	@to_location_group_id INT = NULL,
	@pipeline VARCHAR(100) = NULL,
	@logical_name VARCHAR(400) = NULL, 
	@priority INT =  NULL
	
AS
	
declare @sql varchar(MAX)
IF @flag='s'
Begin
	set @sql='select 			
			max(location_loss_factor_id) [Location Loss Factor ID],
			llf.logical_name [Logical Name],
			max(dbo.fnadateformat(effective_date)) [Effective Date] ,
			MAX(smjl1f.location_name) [From Location Group],
			MAX(smjlt.location_name) [To Location Group],
			case when max(smjl.location_name) is null then '''' else max(smjl.location_name) + '', '' end +  max(sml.[Location_Name]) as [From Location],
			case when max(smjl1.location_name) is null then '''' else max(smjl1.location_name) + '', '' end +  max(sml1.[Location_Name]) as [To Location],

--			isnull(sml.location_name,''N/A'') [From Location] ,
--			isnull(sml1.location_name ,''N/A'')[To Location],
			
			MAX(mi.recorderid) AS [Meter From],
			MAX(mit.recorderid) AS [Meter To],
			max(loss_factor)[Loss Factor]
			FROM location_loss_factor llf 
			LEFT JOIN source_minor_location sml on llf.from_location_id = sml.source_minor_location_id
			LEFT JOIN source_minor_location sml1 on llf.to_location_id = sml1.source_minor_location_id
			LEFT JOIN source_Major_Location smjl ON sml.source_Major_Location_Id=smjl.source_major_location_ID
			LEFT JOIN source_Major_Location smjl1 ON sml1.source_Major_Location_Id=smjl1.source_major_location_ID
			LEFT JOIN source_Major_Location smjl1f ON smjl1f.source_Major_Location_Id = llf.from_location_group_id
			LEFT JOIN source_Major_Location smjlt ON smjlt.source_Major_Location_Id = llf.to_location_group_id
			LEFT JOIN static_data_value sdv ON sdv.value_id = llf.rate_schedule
			LEFT JOIN meter_id mi ON mi.meter_id = llf.meter_From
			LEFT JOIN meter_id mit ON mit.meter_id = llf.meter_to

where 1=1 AND llf.rate_loss_flag=''l'''

if @location_loss_factor_id is not null
		Begin
			SET @sql=@sql +'and location_loss_factor_id='+cast(@location_loss_factor_id as varchar)
		End

if @from_location_id is not null
		Begin
			SET @sql=@sql +'and llf.from_location_id='+cast(@from_location_id as varchar)
		End
if @to_location_id is not null
		Begin
			SET @sql=@sql +'and llf.to_location_id='+cast(@to_location_id as varchar)
		End

if @effective_date is not null
		Begin
			SET @sql=@sql +'and llf.effective_date<='''+cast(@effective_date as varchar)+''' or llf.effective_date is NULL'
		End
		
SET @sql=@sql + ' GROUP BY llf.logical_name, llf.from_location_id,llf.to_location_id '		
EXEC spa_print @sql
exec(@sql)
End

ELSE IF @flag = 'a'
BEGIN
     SET @sql = 
         'SELECT location_loss_factor_id,
                 a.source_major_location_id,
                 llf.from_location_group_id [Major location from],
                 b.source_major_location_id,
                 llf.to_location_group_id [Major location to],
                 dbo.fnadateformat(effective_date),
                 from_location_id,                 
				 sml.Location_Name [Minor Location From],
                 to_location_id,
                 sml2.Location_Name [Minor Location To],
                 loss_factor,
                 llf.meter_from [Meter ID From],
                 llf.meter_to [Meter ID To],
                 mi.recorderid [Meter From],
                 mit.recorderid [Meter To],
                 logical_name,
                 llf.pipeline [Counterparty],
                 --scp.counterparty_name [Counterparty],
                 llf.priority [Priority],
                 llf.rate_schedule as [Rate Schedule]
                 
          FROM   location_loss_factor llf
                 LEFT JOIN source_minor_location sml ON  sml.source_minor_location_id = llf.from_location_id
                 LEFT JOIN source_minor_location sml2 ON  sml2.source_minor_location_id = llf.to_location_id
                 LEFT JOIN (
                          SELECT nor.source_minor_location_id,
                                 nor.source_major_location_id,
                                 jor.location_name
                          FROM   source_minor_location nor
                                 LEFT JOIN source_major_location jor ON  jor.source_major_location_id = nor.source_major_location_id
                      ) a
                      ON  a.source_minor_location_id = llf.from_location_id
                 LEFT JOIN (
                          SELECT nor.source_minor_location_id,
                                 nor.source_major_location_id,
                                 jor.location_name
                          FROM   source_minor_location nor
                                 LEFT JOIN source_major_location jor ON  jor.source_major_location_id = nor.source_major_location_id
                      ) b
                      ON  b.source_minor_location_id = llf.to_location_id
                 LEFT JOIN meter_id mi ON mi.meter_id = llf.meter_from
                 left join meter_id mit ON mit.meter_id = llf.meter_to  
          WHERE  1 = 1'
     
     IF @location_loss_factor_id IS NOT NULL
     BEGIN
         SET @sql = @sql + ' and location_loss_factor_id=' + CAST(@location_loss_factor_id AS VARCHAR)
     END
     
     EXEC spa_print @sql
     EXEC (@sql)
END

ELSE IF @flag = 'i'
BEGIN

--create table  #temp1 (sno int identity,source_minor_location_id int)
--create table #temp2 (sno int identity,source_minor_location_id int)
--
--	/*select source_minor_location_id into #temp1 from source_minor_location where source_major_location_id=@from_location_id
--
--	select source_minor_location_id into #temp2 from source_minor_location where source_major_location_id=@to_location_id
--*/
--insert into #temp1(source_minor_location_id) select source_minor_location_id from source_minor_location where source_major_location_id=@from_location_id
--insert into #temp2(source_minor_location_id) select source_minor_location_id from source_minor_location where source_major_location_id=@to_location_id
--
--declare @max1 int
--,@max2 int
--
--select @max1 = count(*) from #temp1
--select @max2 = count(*) from #temp2
--
--if @max1 > @max2
--insert into location_loss_factor(effective_date ,from_location_id,to_location_id,loss_factor) select @effective_date,a.source_minor_location_id
--,b.source_minor_location_id,@loss_factor from #temp1 a
-- left join #temp2 b on a.sno = b.sno
--
--else if @max1 < @max2
--insert into location_loss_factor(effective_date ,from_location_id,to_location_id,loss_factor) select @effective_date,a.source_minor_location_id
--,b.source_minor_location_id,@loss_factor from #temp1 a
-- right join #temp2 b on a.sno = b.sno
--
--else  
--insert into location_loss_factor(effective_date ,from_location_id,to_location_id,loss_factor) select @effective_date,a.source_minor_location_id
--,b.source_minor_location_id,@loss_factor from #temp1 a
--  join #temp2 b on a.sno = b.sno
	IF EXISTS (SELECT 1 FROM location_loss_factor WHERE logical_name = @logical_name)
	BEGIN
		 EXEC spa_ErrorHandler -1,
	         'Loss Factor',
	         'spa_location_loss_factor',
	         'DB Error',
	         'Logical Name already exists.',
	         ''
	    RETURN
	END
	
	INSERT INTO location_loss_factor
	  (
	    effective_date,
	    from_location_id,
	    to_location_id,
			loss_factor,
			meter_from,
			meter_to,
			rate_loss_flag,
			from_location_group_id,
			to_location_group_id,
			logical_name,
			pipeline,
			priority,
			rate_schedule	    	    	    
	  )
	VALUES
	  (
	    @effective_date,
	    @from_location_id,
	    @to_location_id,
			@loss_factor,
			@meter_from,
			@meter_to,
			@rate_loss_flag,
			@from_location_group_id,
			@to_location_group_id,
			@logical_name,
			@pipeline,
			@priority,
			@rate_schedule
	  )
		  
	    EXEC spa_ErrorHandler 0,
	         'Loss Factor ',
	         'spa_location_loss_factor',
	         'Success',
	         'Loss Factor inserted.',
	         ''
	
END

ELSE IF @flag='u'
BEGIN
	IF EXISTS (SELECT 1 FROM location_loss_factor WHERE logical_name = @logical_name AND location_loss_factor_id <> @location_loss_factor_id)
	BEGIN
		 EXEC spa_ErrorHandler -1,
	         'Loss Factor',
	         'spa_location_loss_factor',
	         'DB Error',
	         'Logical Name already exists.',
	         ''
	    RETURN
	END
	
	UPDATE location_loss_factor
	SET    effective_date              = @effective_date,
	       from_location_id            = @from_location_id,
	       to_location_id              = @to_location_id,
	       loss_factor                 = @loss_factor,
	       meter_from                  = @meter_from,
	       meter_to                    = @meter_to,
	       from_location_group_id      = @from_location_group_id,
	       to_location_group_id        = @to_location_group_id,
	       logical_name				   = @logical_name,
	       pipeline					   = @pipeline,
	       priority					   = @priority,
	       rate_schedule			   =  @rate_schedule
	       
	WHERE  location_loss_factor_id     = @location_loss_factor_id

	    EXEC spa_ErrorHandler 0,
	         'Loss Factor ',
	         'spa_location_loss_factor',
	         'Success',
	        'Loss Factor successfully updated.',''

End

ELSE IF @flag = 'd'
BEGIN
		
	DELETE 
	FROM   location_loss_factor
	WHERE  location_loss_factor_id = @location_loss_factor_id

	IF @@Error <> 0
		EXEC spa_ErrorHandler @@Error,
			 'Loss Factor',
			 'spa_location_loss_factor',
			 'DB Error',
			 'Failed to delete Loss Factor.',
			 ''
	ELSE
		EXEC spa_ErrorHandler 0,
			 'Loss Factor ',
			 'spa_location_loss_factor',
			 'Success',
			 'Loss Factor Deleted.',
			 ''
END
ELSE IF @flag = 't' --to display in grid on maintain rate schedules window
BEGIN
	SET  @sql='select max(location_loss_factor_id) [Location Loss Factor ID],
				max(dbo.fnadateformat(effective_date)) [Effective Date] ,
				MAX(smjl1f.location_name) [From Location Group],
				MAX(smjlt.location_name) [To Location Group],
				case when max(smjl.location_name) is null then '''' else max(smjl.location_name) + '', '' end +  max(sml.[Location_Name]) as [From Location],
				case when max(smjl1.location_name) is null then '''' else max(smjl1.location_name) + '', '' end +  max(sml1.[Location_Name]) as [To Location],
				MAX(mi.recorderid) AS [Meter From],
				MAX(mit.recorderid) AS [Meter To],			
				MAX(sdv.code) AS [Rate Schedule]
				FROM location_loss_factor llf 
				left join source_minor_location sml on llf.from_location_id = sml.source_minor_location_id
				left join source_minor_location sml1 on llf.to_location_id = sml1.source_minor_location_id
				LEFT JOIN source_Major_Location smjl ON sml.source_Major_Location_Id=smjl.source_major_location_ID
				LEFT JOIN source_Major_Location smjl1 ON sml1.source_Major_Location_Id=smjl1.source_major_location_ID
				LEFT JOIN source_Major_Location smjl1f ON smjl1f.source_Major_Location_Id = llf.from_location_group_id
				LEFT JOIN source_Major_Location smjlt ON smjlt.source_Major_Location_Id = llf.to_location_group_id
				LEFT JOIN static_data_value sdv ON sdv.value_id = llf.rate_schedule
				LEFT JOIN meter_id mi ON mi.meter_id = llf.meter_From
				LEFT JOIN meter_id mit ON mit.meter_id = llf.meter_to

	where 1=1 AND llf.rate_loss_flag=''r'''
	
	IF @location_loss_factor_id IS NOT NULL
	BEGIN
		SET @sql = @sql + 'and location_loss_factor_id=' + CAST(@location_loss_factor_id AS VARCHAR)
	END

	IF @from_location_id IS NOT NULL
	BEGIN
		SET @sql = @sql + 'and llf.from_location_id=' + CAST(@from_location_id AS VARCHAR)
	END

	IF @to_location_id IS NOT NULL
	BEGIN
		SET @sql = @sql + 'and llf.to_location_id=' + CAST(@to_location_id AS VARCHAR)
	END

	IF @effective_date IS NOT NULL
	BEGIN
		SET @sql = @sql + 'and llf.effective_date<=''' + CAST(@effective_date AS VARCHAR)
			+ ''' or llf.effective_date is NULL'
	END

	SET @sql = @sql + ' GROUP BY llf.from_location_id,llf.to_location_id '		
	
EXEC spa_print @sql
EXEC (@sql)
END
ELSE IF @flag = 'v' --to insert the data on maintain rate schedules UI
BEGIN
	INSERT INTO location_loss_factor
	  (
	    effective_date,
	    from_location_id,
	    to_location_id,
	    loss_factor,
	    meter_from,
	    meter_to,
	    rate_loss_flag,
	    rate_schedule,
	    from_location_group_id,
	    to_location_group_id
	  )
	VALUES
	  (
	    @effective_date,
	    @from_location_id,
	    @to_location_id,
	    @loss_factor,
	    @meter_from,
	    @meter_to,
	    @rate_loss_flag,
	    @rate_schedule,
	    @from_location_group_id,
	    @to_location_group_id
	  )


	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'location_loss_factor_id',
	         'spa_location_loss_factor',
	         'DB Error',
	         'Failed to insert Map Rate Schedule Detail.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'location_loss_factor_id',
	         'spa_location_loss_factor',
	         'Success',
	         'Map Rate Schedule Detail inserted.',
	         ''
END
ELSE IF @flag = 'w'
BEGIN
	UPDATE location_loss_factor
	SET    effective_date              = @effective_date,
	       from_location_id            = @from_location_id,
	       to_location_id              = @to_location_id,
	       loss_factor                 = @loss_factor,
	       meter_from                  = @meter_from,
	       meter_to                    = @meter_to,
	       rate_schedule               = @rate_schedule,
	       from_location_group_id      = @from_location_group_id,
	       to_location_group_id        = @to_location_group_id
	WHERE  location_loss_factor_id     = @location_loss_factor_id
	
	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'location_loss_factor_id',
	         'spa_location_loss_factor',
	         'DB Error',
	         'Failed to update Map Rate Schedule Detail.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'location_loss_factor_id',
	         'spa_location_loss_factor',
	         'Success',
	         'Map Rate Schedule Detail updated.',
	         ''
END
ELSE IF @flag = 'l'
BEGIN
	--Collect logical name from location_loss_factor to show in dropdown in Setupdelivery path UI page.
	SELECT logical_name, logical_name FROM location_loss_factor
END