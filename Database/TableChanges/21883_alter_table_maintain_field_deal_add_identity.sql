SET NOCOUNT ON
BEGIN TRY
	BEGIN TRAN
	
	IF OBJECT_ID('tempdb..#temp_maintain_field_deal') IS NOT NULL
		DROP TABLE #temp_maintain_field_deal
	
	-- 1. Drop PK constraint of field_deal_id.
	ALTER TABLE maintain_field_deal
	DROP CONSTRAINT PK_maintain_field_deal1

	-- 2. Drop column field_deal_id from main table.
	ALTER TABLE maintain_field_deal
	DROP COLUMN field_deal_id

	-- 3. Copy all data from main table to temp table.
	SELECT * INTO #temp_maintain_field_deal 
	FROM maintain_field_deal

	-- 4. Drop unique constraint of field_id.
	IF OBJECT_ID('UC_maintain_field_deal_field_id') IS NOT NULL
	BEGIN
		ALTER TABLE maintain_field_deal
		DROP CONSTRAINT UC_maintain_field_deal_field_id
	END
	-- 5. Drop existing column field_id.
	ALTER TABLE maintain_field_deal
	DROP COLUMN field_id

	-- 6. runcate main table
	TRUNCATE table maintain_field_deal

	-- 7. Add new column field_id as PK identity column with seed 1.
	ALTER TABLE maintain_field_deal
	ADD field_id INT PRIMARY KEY IDENTITY(1,1)

	-- 8. Insert all data from temp table to main table setting IDENTITY_INSERT ON. 
	   -- Set IDENTITY_INSERT flag to OFF back.
	DECLARE @sql VARCHAR(MAX)
	DECLARE @col_list VARCHAR(MAX)

	SELECT @col_list = COALESCE(@col_list + ', ', '') + sc.name 
	FROM sys.columns sc
	INNER JOIN sys.tables st
		ON sc.object_id = st.object_id
	WHERE st.name = 'maintain_field_deal'

	SET @sql = '
		SET IDENTITY_INSERT dbo.maintain_field_deal ON	
		INSERT INTO maintain_field_deal (
			' + @col_list + '
		) SELECT
			' + @col_list + '		
		FROM #temp_maintain_field_deal
		SET IDENTITY_INSERT dbo.maintain_field_deal OFF
	'
	EXEC(@sql)

	COMMIT TRAN
END TRY
BEGIN CATCH
	--select ERROR_MESSAGE(), ERROR_LINE()
	ROLLBACK TRAN
END CATCH