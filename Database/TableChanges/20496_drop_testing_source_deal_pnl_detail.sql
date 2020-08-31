IF OBJECT_ID('tempdb..#drop_pre_post_source_deal_pnl_detail') IS NOT NULL
DROP TABLE #drop_pre_post_source_deal_pnl_detail
Create table #drop_pre_post_source_deal_pnl_detail (name VARCHAR(500) COLLATE DATABASE_DEFAULT)

Insert into #drop_pre_post_source_deal_pnl_detail
select table_name
FROM INFORMATION_SCHEMA.TABLES
WHERE table_schema = 'testing' and table_name like '%source_deal_pnl_detail'

	IF CURSOR_STATUS('local','delete_table') > = -1
		BEGIN
			DEALLOCATE delete_table
		END

	DECLARE delete_table CURSOR LOCAL FOR
		
		SELECT name
		FROM   #drop_pre_post_source_deal_pnl_detail 

		DECLARE @table_name varchar(100)
		DECLARE @sqlCmd varchar(1000)

		OPEN delete_table 
		FETCH NEXT FROM delete_table 
		INTO @table_name
		WHILE @@FETCH_STATUS = 0
		BEGIN
											
		SET @sqlCmd = N'drop table testing.' + @table_name
     	exec (@sqlCmd)
				
		FETCH NEXT FROM delete_table INTO @table_name
		END

		CLOSE delete_table
		DEALLOCATE delete_table

