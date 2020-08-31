
/****** Object:  StoredProcedure [dbo].[spa_slide_range_left_window_datetime]    Script Date: 08/08/2014 12:56:15 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_slide_range_left_window_datetime]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_slide_range_left_window_datetime]
GO


/****** Object:  StoredProcedure [dbo].[spa_slide_range_left_window_datetime]    Script Date: 08/08/2014 12:56:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[spa_slide_range_left_window_datetime]
	@RunDate				DATETIME 
	,@frequency				VARCHAR(1) = 'm' --'d=daily,a=annually,m=monthly
	,@pf_name				VARCHAR(100)
	,@fg_name				VARCHAR(100)
	,@ps_name				VARCHAR(100)
	,@switch_data			VARCHAR(1) = 'n'
	,@partition_table_name	VARCHAR(100) = NULL,  --there should be the replicate of this partition table with name 'stage_'+@partition_table_name
	@partition_type			INT = 1 -- 0=partion by different granularity of the boundary (1st bounday is of 1 day and from second bounday is of monthly);  1= partion by granularity of the boundaryterm_start(all the;
AS

/*

	
--SELECT pf.name , CAST(prv.value AS DATETIME)
-- FROM sys.partition_functions AS pf JOIN sys.partition_range_values AS prv ON prv.function_id = pf.function_id
--	WHERE pf.name = 'PF_PRICECURVE' AND prv.boundary_id=1 


--select c.name 
--from  sys.tables          t
--join  sys.indexes         i 
--      on(i.object_id = t.object_id 
--      and i.index_id < 2)
--join  sys.index_columns  ic 
--      on(ic.partition_ordinal > 0 
--      and ic.index_id = i.index_id and ic.object_id = t.object_id)
--join  sys.columns         c 
--      on(c.object_id = ic.object_id 
--      and c.column_id = ic.column_id)
--where t.object_id  = object_id('source_deal_pnl')

--select * from source_deal_pnl




--exec dbo.spa_slide_range_left_window_datetime '2010-02-28','m','PF_PNL','[PRIMARY]','PS_PNL'
--exec dbo.spa_slide_range_left_window_datetime '2010-02-28','m','PF_PNL_DETAIL','[PRIMARY]','PS_PNL_DETAIL'
--exec dbo.spa_slide_range_left_window_datetime '2010-02-28','m','PF_PRICECURVE','[PRIMARY]','PS_PRICECURVE'

declare @RunDate DATETIME=null
,@frequency varchar(1)='m' --'d=daily,a=annually,m=monthly
,@pf_name varchar(100)='PF_PNL'
,@fg_name varchar(100)='PRIMARY'
,@ps_name  varchar(100)='PS_PNL'
,@partition_table_name varchar(100)='source_deal_pnl' ,@switch_data varchar(1)='y'
,@partition_type			INT = 1
--*/
SET NOCOUNT, XACT_ABORT ON;
DECLARE @error INT, @rowcount BIGINT, @errorline INT, @message VARCHAR(255), @lastpartitionboundarydate DATETIME, @partitionboundarydate DATETIME;
DECLARE  @st VARCHAR(MAX) , @no_partitons TINYINT, @end_of_month DATETIME, @user_name VARCHAR(30), @process_id VARCHAR(100)
DECLARE @i TINYINT,@second_partition_boundary_date datetime,@new_boundary datetime
SET @error = 0;
DECLARE @partition_no INT ,@current_filegroup varchar(100),@second_filegroup varchar(100)
DECLARE  @partitionlastboundarydate DATETIME
DECLARE  @partitionsecondboundarydate DATETIME
SET @user_name = dbo.FNADBUser()

set @RunDate=null
IF @process_id IS NULL
BEGIN
	SET @process_id = REPLACE(newid(), '-', '_')
END

set @partition_type=ISNULL(@partition_type,1)

if @partition_type=0 set @frequency='m'

set @RunDate=ISNULL(@RunDate,GETDATE())

select @partitionboundarydate=CAST(prv.value AS DATETIME) FROM sys.partition_functions AS pf JOIN sys.partition_range_values AS prv ON prv.function_id = pf.function_id
	WHERE pf.name = @pf_name  AND prv.boundary_id=1
	
select @second_partition_boundary_date=CAST(prv.value AS DATETIME) FROM sys.partition_functions AS pf JOIN sys.partition_range_values AS prv ON prv.function_id = pf.function_id
	WHERE pf.name = @pf_name  AND prv.boundary_id=2

		
SELECT   @lastpartitionboundarydate = CAST(MAX(prv.value) AS DATETIME) FROM sys.partition_functions AS pf
  JOIN sys.partition_range_values AS prv ON   prv.function_id = pf.function_id
  WHERE pf.name = @pf_name;	

SELECT @current_filegroup=MAX(fg.name) FROM sys.partitions p  INNER JOIN sys.allocation_units au
    ON au.container_id = p.hobt_id   INNER JOIN sys.filegroups fg
    ON fg.data_space_id = au.data_space_id
WHERE p.object_id = OBJECT_ID(@partition_table_name) and p.partition_number=1

SELECT @second_filegroup= MAX(fg.name) FROM sys.partitions p  INNER JOIN sys.allocation_units au
	ON au.container_id = p.hobt_id   INNER JOIN sys.filegroups fg
	ON fg.data_space_id = au.data_space_id
WHERE p.object_id = OBJECT_ID(@partition_table_name) and p.partition_number=2


IF NOT EXISTS (SELECT 1 FROM sys.partition_functions AS pf JOIN sys.partition_range_values AS prv ON prv.function_id = pf.function_id
	WHERE pf.name = @pf_name AND CAST(prv.value AS DATETIME) = @partitionboundarydate)
BEGIN
	SET  @Message = 'The ' + CONVERT(VARCHAR(10), @partitionboundarydate, 120) + ' is not exist in the partition.'
	PRINT @Message
	GOTO messaging 
END

SELECT @no_partitons = no_partitions FROM partition_config_info WHERE function_name = @pf_name
 
BEGIN TRY
     
     SET @Message = 'Run date= ' + CONVERT(VARCHAR(23), @rundate, 121) + ', Partition range: ' +CONVERT(VARCHAR(10),@partitionboundarydate,120) +' ~ '+ CONVERT(VARCHAR(10),@lastpartitionboundarydate,120)  +', No. partition = ' + CAST(@no_partitons AS VARCHAR(10));
     RAISERROR (@Message, 0, 1) WITH NOWAIT;

     BEGIN TRAN;

---------------Switching data to staging table--------------------------------

	IF ISNULL(@switch_data,'n') = 'y'
	BEGIN
		  --acquire exclusive table lock to prevent deadlocking with concurrent activity.

		 EXEC('SELECT TOP 1 0 aa INTO #tttt FROM dbo.' + @partition_table_name + ' WITH (TABLOCKX, HOLDLOCK);')
	     
		--Ensure target staging partition is empty
		EXEC('SELECT TOP 1 0 aa INTO #data_exist FROM dbo.Stage_' + @partition_table_name)
		IF @@ROWCOUNT > 0
		BEGIN
			SET @message = 'The prior archive job, found incomplete as table:stage_' + @partition_table_name + ' is not empty. Please re-run archive job manually to prevent data loss.'
			PRINT @message
			GOTO messaging 
		END

		if @partition_type<>1 --filegroup is not always in primary (in case @partition_type=1, the first boundary is always in primary)
		begin
			declare @IndexName varchar(200),@KeyCols varchar(500)
			
			SELECT @IndexName=Ind.[name],	@KeyCols=SUBSTRING(
				( SELECT ', ' + AC.name FROM sys.[tables] AS T
					INNER JOIN sys.[indexes] I ON T.[object_id] = I.[object_id]
					INNER JOIN sys.[index_columns] IC ON I.[object_id] = IC.[object_id] AND I.[index_id] = IC.[index_id]
					INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id] AND IC.[column_id] = AC.[column_id]
					WHERE Ind.[object_id] = I.[object_id] AND Ind.index_id = I.index_id AND IC.is_included_column = 0
					ORDER BY IC.key_ordinal
					FOR
					XML PATH('')
				), 2, 8000)
				--,SUBSTRING(
				--( SELECT ', ' + AC.name FROM sys.[tables] AS T
				--	INNER JOIN sys.[indexes] I ON T.[object_id] = I.[object_id]
				--	INNER JOIN sys.[index_columns] IC ON I.[object_id] = IC.[object_id] AND I.[index_id] = IC.[index_id]
				--	INNER JOIN sys.[all_columns] AC ON T.[object_id] = AC.[object_id] AND IC.[column_id] = AC.[column_id]
				--	WHERE Ind.[object_id] = I.[object_id] AND Ind.index_id = I.index_id AND IC.is_included_column = 1
				--	ORDER BY IC.key_ordinal
				--	FOR XML PATH('')
				--), 2, 8000) AS IncludeCols
				FROM sys.indexes Ind
				INNER JOIN sys.[tables] AS Tab
				ON Tab.[object_id] = Ind.[object_id] and Tab.[name]='stage_'+ @partition_table_name and ind.[type]=1 -- 1 = Clustered 
				INNER JOIN sys.[schemas] AS Sch
				ON Sch.[schema_id] = Tab.[schema_id]
			--if @IndexName is not null 
			--begin
			--	exec('drop index '+@IndexName+ ' on dbo.stage_'+@partition_table_name)
			--	exec('create index '+@IndexName+ ' on dbo.stage_'+@partition_table_name+' ( '+@KeyCols+') ON  ' + @current_filegroup)
			--end
		end

		SET @st = 'ALTER TABLE dbo.' + @partition_table_name + ' SWITCH PARTITION 1 TO dbo.stage_' + @partition_table_name + ' PARTITION 1;'
		RAISERROR(@st, 0, 1) WITH NOWAIT;
		EXEC (@st)

		SELECT @RowCount = ROWS FROM sys.partitions
			WHERE OBJECT_ID = OBJECT_ID(N'stage_' + @partition_table_name) AND partition_number = 1;

		SET @Message = 'Moved data older than ' +  CONVERT(VARCHAR(23), @partitionboundarydate, 120) + ' (' + CAST(@RowCount AS VARCHAR(20)) + ' rows) to staging table';

		RAISERROR(@Message, 0, 1) WITH NOWAIT;
	END

------------------------------------end--- switching-------------------------------

	--merge first and second partitions

	SET @st = 'ALTER PARTITION FUNCTION ' + @pf_name + '() MERGE RANGE(''' + CONVERT(VARCHAR(10), @partitionboundarydate, 120) + ''')'
	RAISERROR(@st, 0, 1) WITH NOWAIT;
	EXEC (@st)

	SET @message = 'Removed boundary ' +   CONVERT(VARCHAR(10), @partitionboundarydate, 120);
	RAISERROR(@message, 0, 1) WITH NOWAIT;
	
	--------------------------------------------------------------------
	--'Split logic start here-----------------------------
-----------------------------------------------------------
	
		
	SET @message = '@partition_type= ' +   CAST(@partition_type as varchar)
	RAISERROR(@message, 0, 1) WITH NOWAIT;
	
	if @partition_type=1 --equal granularity boundary
	begin
		
		SELECT @new_boundary = CASE 
									WHEN @frequency = 'm' THEN dbo.[FNAGetTermStartDate](@frequency, @lastpartitionboundarydate,1)
									WHEN @frequency = 'd' THEN DATEADD(d, 1, @lastpartitionboundarydate)
							   END
		
		
		SET @st = 'ALTER PARTITION SCHEME ' + @ps_name + ' NEXT USED [' + @current_filegroup +']'
		RAISERROR(@st, 0, 1) WITH NOWAIT;
		EXEC (@st)

		IF not EXISTS (SELECT prv.value FROM sys.partition_functions AS pf JOIN sys.partition_range_values AS prv ON   prv.function_id = pf.function_id
							WHERE  pf.name = @pf_name  AND CAST(prv.value AS datetime) = @new_boundary )
		BEGIN 

			SET @st = 'ALTER PARTITION FUNCTION ' + @pf_name + '() SPLIT RANGE(''' + CONVERT(VARCHAR(10), @new_boundary, 120) + ''')'
			RAISERROR(@st, 0, 1) WITH NOWAIT;
			EXEC (@st)
		end
		else
		begin
			SET @st = 'already exist the boundary:''' + CONVERT(VARCHAR(10), @new_boundary, 120) + '''. Please make sure the bounday...'
			RAISERROR(@st, 0, 1) WITH NOWAIT;

		end
	end
	else --different granularity boundary
	begin
		if DAY(DATEADD(DAY,2,@partitionboundarydate))<>1 --not 2nd last day of the month
		begin
			SET @new_boundary =DATEADD(DAY,1,@partitionboundarydate)
			
			SET @st = 'ALTER PARTITION SCHEME ' + @ps_name + ' NEXT USED [' + @current_filegroup +']'
			RAISERROR(@st, 0, 1) WITH NOWAIT;
			EXEC (@st)

			IF not EXISTS (SELECT prv.value FROM sys.partition_functions AS pf JOIN sys.partition_range_values AS prv ON   prv.function_id = pf.function_id
								WHERE  pf.name = @pf_name  AND CAST(prv.value AS datetime) = @new_boundary )
			BEGIN 

				SET @st = 'ALTER PARTITION FUNCTION ' + @pf_name + '() SPLIT RANGE(''' + CONVERT(VARCHAR(10), @new_boundary, 120) + ''')'
				RAISERROR(@st, 0, 1) WITH NOWAIT;
				EXEC (@st)
			end
			else
			begin
				SET @st = 'already exist the boundary:''' + CONVERT(VARCHAR(10), @second_partition_boundary_date, 120) + '''. Please make sure the bounday...'
				RAISERROR(@st, 0, 1) WITH NOWAIT;
			end
			
		end
		else -- 2nd last day of the month
		begin
			SET @new_boundary =DATEADD(DAY,1,@partitionboundarydate)
			
			--merge first and second partitions

			SET @st = 'ALTER PARTITION FUNCTION ' + @pf_name + '() MERGE RANGE(''' + CONVERT(VARCHAR(10), @second_partition_boundary_date, 120) + ''')'
			RAISERROR(@st, 0, 1) WITH NOWAIT;
			EXEC (@st)

			SET @message = 'Removed boundary ' +   CONVERT(VARCHAR(10), @partitionboundarydate, 120);
			RAISERROR(@message, 0, 1) WITH NOWAIT;
			
			SET @st = 'ALTER PARTITION SCHEME ' + @ps_name + ' NEXT USED [' + @second_filegroup + ']'
			RAISERROR(@st, 0, 1) WITH NOWAIT;
			EXEC (@st)
			
			SET @new_boundary = dbo.[FNAGetTermEndDate](@frequency, @lastpartitionboundarydate,1) --@frequency is always 'm'
			
			IF not EXISTS (SELECT prv.value FROM sys.partition_functions AS pf JOIN sys.partition_range_values AS prv ON   prv.function_id = pf.function_id
								WHERE  pf.name = @pf_name  AND CAST(prv.value AS datetime) = @new_boundary )
			BEGIN 
			
				SET @st = 'ALTER PARTITION FUNCTION ' + @pf_name + '() SPLIT RANGE(''' + CONVERT(VARCHAR(10), @new_boundary, 120) + ''')'
				RAISERROR(@st, 0, 1) WITH NOWAIT;
				EXEC (@st)
			
			end 
			else
			begin
				SET @st = 'already exist the boundary:''' + CONVERT(VARCHAR(10), @new_boundary, 120) + '''. Please make sure the bounday...'
				RAISERROR(@st, 0, 1) WITH NOWAIT;

			end
			
			SET @st = 'ALTER PARTITION SCHEME ' + @ps_name + ' NEXT USED [' + @current_filegroup +']' --@current_filegroup is always primary filegroup
			RAISERROR(@st, 0, 1) WITH NOWAIT;
			EXEC (@st)
			
			IF not EXISTS (SELECT prv.value FROM sys.partition_functions AS pf JOIN sys.partition_range_values AS prv ON   prv.function_id = pf.function_id
								WHERE  pf.name = @pf_name  AND CAST(prv.value AS datetime) = @second_partition_boundary_date )
			BEGIN 
				SET @st = 'ALTER PARTITION FUNCTION ' + @pf_name + '() SPLIT RANGE(''' + CONVERT(VARCHAR(10), @second_partition_boundary_date, 120) + ''')'
				RAISERROR(@st, 0, 1) WITH NOWAIT;
				EXEC (@st)
			end
			else
			begin
				SET @st = 'already exist the boundary:''' + CONVERT(VARCHAR(10), @second_partition_boundary_date, 120) + '''. Please make sure the bounday...'
				RAISERROR(@st, 0, 1) WITH NOWAIT;

			end
		end
	end
	
   COMMIT;
   
	RETURN
END TRY
BEGIN CATCH
      SELECT @error = ERROR_NUMBER(),
             @message = ERROR_MESSAGE(),
             @errorline = ERROR_LINE();

      SET @message = 'Error in boundary ' + CONVERT(VARCHAR(10), @partitionboundarydate, 120) + '. Partition maintenenace failed with error %d at line %d: ' + @message;

      RAISERROR(@message, 16, 1, @error, @errorline) WITH NOWAIT;

      IF @@TRANCOUNT > 0
      BEGIN
            ROLLBACK;
      END;
	GOTO  messaging
END CATCH


messaging: --error messaging
IF @@TRANCOUNT > 0
   ROLLBACK;
            
EXEC  spa_message_board 'i', @user_name, NULL, 'Sliding & Archival',  @message, '', '', 'e', 'Sliding & Archival', NULL, @process_id


--select * from message_board where process_id=@process_id


/*
--RAISERROR ('Partition boundaries after maintenance', 0, 1) WITH NOWAIT;

SELECT boundary_id, CAST(prv.value AS datetime) AS PartitionBoundary
      FROM sys.partition_functions AS pf
      JOIN sys.partition_range_values AS prv ON
            prv.function_id = pf.function_id
      WHERE pf.name ='PF_PRICECURVE';
      
SELECT *, CAST(prv.value AS datetime) AS PartitionBoundary
      FROM sys.partition_functions AS pf
      JOIN sys.partition_range_values AS prv ON
            prv.function_id = pf.function_id
      WHERE pf.name ='PF_PRICECURVE';
      
      
      
SELECT *, rows  FROM sys.partitions
		WHERE object_id = OBJECT_ID(N'MyPartitionedTable') AND partition_number = 1;
      
 select * FROM sys.partition_range_values AS pf JOIN sys.partition_range_values AS prv ON   prv.function_id = pf.function_id   
 
  select * FROM sys.partition_schemas
  
    
--Done:

*/



GO


