
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_source_sink_type]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_source_sink_type]



set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

 

-- exec spa_source_sink_type 's',NULL,1

CREATE PROCEDURE [dbo].[spa_source_sink_type]
 @flag varchar(1),
 @source_sink_id_auto int,
 @generator_id int=null,
 @emissions_reporting_group_id int=null,
 @source_sink_type_id int=null

 

As 

if @flag='s'
Begin 
	
	CREATE TABLE  #tmp (
		TYPE_ID INT,value_id INT
		,code VARCHAR(250) COLLATE DATABASE_DEFAULT
		,DESCRIPTION VARCHAR(250) COLLATE DATABASE_DEFAULT
		,entity_id INT,category_id INT
		,category_name VARCHAR(100) COLLATE DATABASE_DEFAULT
	)

INSERT INTO #tmp
	EXEC spa_StaticDataValues 'm',10022,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@generator_id
	
	select source_sink_id_auto ID,sdv.description as [Emissions Reporting Group],
			eph2.entity_name+'->'+eph1.entity_name+'->'+eph.entity_name as [Source Sink Type]
			,source_sink_type_id,cast((SELECT COUNT(*) FROM #tmp) AS VARCHAR) chk   from
		 source_sink_type sst inner join ems_portfolio_hierarchy eph  on eph.entity_id=sst.source_sink_type_id
		 LEFT JOIN 	ems_portfolio_hierarchy EPH1 ON EPH.PARENT_ENTITY_ID=EPH1.ENTITY_ID AND EPH1.HIERARCHY_LEVEL=1
		 LEFT JOIN 	ems_portfolio_hierarchy EPH2 ON EPH1.PARENT_ENTITY_ID=EPH2.ENTITY_ID AND EPH2.HIERARCHY_LEVEL=2
		 inner join static_data_value sdv on sdv.value_id=sst.emissions_reporting_group_id
		
	where 
		generator_id=@generator_id
END

 
else if @flag='i'
Begin
	--Added 'NOT EXISTS' condition to check for duplicate Insertion: Sudeep Lamsal, 26th April 2010
	IF NOT EXISTS(SELECT generator_id,emissions_reporting_group_id,source_sink_type_id 
		FROM source_sink_type WHERE emissions_reporting_group_id=@emissions_reporting_group_id 
											AND generator_id=@generator_id)
		BEGIN
			insert into source_sink_type(generator_id,emissions_reporting_group_id,source_sink_type_id) 
			 values(@generator_id,@emissions_reporting_group_id,@source_sink_type_id)
			If @@ERROR <> 0
				Exec spa_ErrorHandler @@ERROR, "Source/sink Type", 
				"spa_source_sink_type", "DB Error", 
				"Error on inserting source/sink type.", ''
			else
				Exec spa_ErrorHandler 0, 'Source/sink Type', 
				'spa_source_sink_type', 'Success', 
				'Source/sink type successfully inserted.', ''
		END
	ELSE
		BEGIN
			Exec spa_ErrorHandler 1, 'Source/sink Type', 
				'spa_source_sink_type', 'Error', 
				'Unsuccessfull Insertion. Duplicate Emissions Reporting Group. ', ''
		END
End

else if @flag='u'
Begin 
--select * from source_sink_type
	IF NOT EXISTS(SELECT generator_id,emissions_reporting_group_id,source_sink_type_id 
		FROM source_sink_type WHERE emissions_reporting_group_id=@emissions_reporting_group_id 
											AND generator_id=@generator_id AND source_sink_id_auto<>@source_sink_id_auto)
	BEGIN
		

		update source_sink_type
		set
					
			emissions_reporting_group_id=@emissions_reporting_group_id,
			source_sink_type_id=@source_sink_type_id,
			generator_id=@generator_id

		where 
			source_sink_id_auto=@source_sink_id_auto

		If @@ERROR <> 0
			Exec spa_ErrorHandler @@ERROR, "Source/sink Type", 
			"spa_source_sink_type", "DB Error", 
			"Error on updating source/sink type.", ''
		else
			Exec spa_ErrorHandler 0, 'Source/sink Type', 
			'spa_source_sink_type', 'Success', 
			'Source/sink type successfully updated.', ''
	END
	ELSE
		Exec spa_ErrorHandler -1, "Source/sink Type", 
			"spa_source_sink_type", "DB Error", 
			"'Source/Sink Type' for the selected 'Reporting Group' already exists.", ''
End

else if @flag='d'
Begin
	delete from source_sink_type
		where 
			source_sink_id_auto=@source_sink_id_auto

If @@ERROR <> 0
		Exec spa_ErrorHandler @@ERROR, "Source/sink Type", 
		"spa_source_sink_type", "DB Error", 
		"Error on deleting source/sink type.", ''
	else
		Exec spa_ErrorHandler 0, 'Source/sink Type', 
		'spa_source_sink_type', 'Success', 
		'Source/sink type successfully deleted.', ''
End
	


 







