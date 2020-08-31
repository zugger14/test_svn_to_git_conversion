

/****** Object:  StoredProcedure [dbo].[spa_assign_rec_deals]    Script Date: 07/17/2009 17:55:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_assign_rec_deals]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_assign_rec_deals]
/****** Object:  StoredProcedure [dbo].[spa_assign_rec_deals]    Script Date: 07/17/2009 17:55:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_assign_rec_deals]
	@source_deal_detail_ids VARCHAR(MAX) = NULL, 
	@assignment_type INT = NULL, 
	@assigned_state INT = NULL, 
	@compliance_year INT = NULL, 
	@assigned_date DATETIME = NULL, 
	@assigned_counterparty INT = NULL, 
	@assigned_price NUMERIC(38, 20) = NULL, 
	@trader_id INT = NULL, 
	@table_name VARCHAR(500) = NULL, 
	@unassign INT = 0, 
	@user_id VARCHAR(50) = NULL, 
	@gen_state INT = NULL, 
	@gen_year INT = NULL, 
	@gen_date_from DATETIME = NULL, 
	@gen_date_to DATETIME = NULL, 
	@generator_id INT = NULL, 
	@counterparty_id INT = NULL, 
	@book_deal_type_map_id INT = NULL, 
	@assign_id VARCHAR(100) = NULL, 
	@template_id INT = NULL, 
	@volume VARCHAR(100) = NULL, 
	@select_all_deals INT = 0, 
	@selected_row_ids VARCHAR(MAX) = NULL, 
	@committed BIT = 0,
	@compliance_group_id INT = NULL,
	@commit_type CHAR(1) = NULL,
	@call_from_old INT = 0,
	@call_from_sale_deal INT = NULL,
	@original_deal_id INT = NULL,
	@inserted_source_deal_header_id VARCHAR(MAX) = NULL OUTPUT				
AS
SET NOCOUNT ON
/**************************TEST CODE START************************				
DECLARE	@source_deal_detail_ids	VARCHAR(MAX)	=	NULL
DECLARE	@assignment_type	INT	=	'5173'
DECLARE	@assigned_state	INT	=	'310388'
DECLARE	@compliance_year	INT	=	'2016'
DECLARE	@assigned_date	DATETIME	=	'2016-07-21'
DECLARE	@assigned_counterparty	INT	=	'4653'
DECLARE	@assigned_price	NUMERIC	=	'6'
DECLARE	@trader_id	INT	=	'133'
DECLARE	@table_name	VARCHAR(500)	=	'adiha_process.dbo.recassign__farrms_admin_98A8BE5C_8218_4A05_9C08_55CAAC256C4B'
DECLARE	@unassign	INT	=	'0'
DECLARE	@user_id	VARCHAR(50)	=	NULL
DECLARE	@gen_state	INT	=	NULL
DECLARE	@gen_year	INT	=	NULL
DECLARE	@gen_date_from	DATETIME	=	NULL
DECLARE	@gen_date_to	DATETIME	=	NULL
DECLARE	@generator_id	INT	=	NULL
DECLARE	@counterparty_id	INT	=	NULL
DECLARE	@book_deal_type_map_id	INT	=	NULL
DECLARE	@assign_id	VARCHAR(100)	=	''
DECLARE	@template_id	INT	=	NULL  
DECLARE	@volume	VARCHAR(100)	=	'0'
DECLARE	@select_all_deals	INT	=	'1'
DECLARE	@selected_row_ids	VARCHAR(MAX)	=	'0'
DECLARE	@committed	BIT	=	NULL
DECLARE	@compliance_group_id	INT	=	NULL
DECLARE	@commit_type	CHAR(1)	=	NULL
DECLARE	@call_from_old	INT	=	'0'
DECLARE	@call_from_sale_deal	INT	=	NULL
DECLARE	@original_deal_id	INT		
DECLARE	@inserted_source_deal_header_id	VARCHAR(MAX)		
IF OBJECT_ID(N'tempdb..#deal_count1', N'U') IS NOT NULL
	DROP TABLE	#deal_count1			
IF OBJECT_ID(N'tempdb..#deals_count', N'U') IS NOT NULL
	DROP TABLE	#deals_count			
IF OBJECT_ID(N'tempdb..#deals_count1', N'U') IS NOT NULL
	DROP TABLE	#deals_count1			
IF OBJECT_ID(N'tempdb..#inserted_source_deal_header_id', N'U') IS NOT NULL
	DROP TABLE	#inserted_source_deal_header_id			
IF OBJECT_ID(N'tempdb..#source_deal_header_id', N'U') IS NOT NULL
	DROP TABLE	#source_deal_header_id			
IF OBJECT_ID(N'tempdb..#table_name', N'U') IS NOT NULL
	DROP TABLE	#table_name			
IF OBJECT_ID(N'tempdb..#temp_ids', N'U') IS NOT NULL
	DROP TABLE	#temp_ids			
IF OBJECT_ID(N'tempdb..#unique_id', N'U') IS NOT NULL
	DROP TABLE	#unique_id			

SELECT @assignment_type='5146',@assigned_state='309371',@compliance_year='2015',@assigned_date='2016-07-26',@assigned_counterparty=NULL,@assigned_price=NULL,@trader_id=NULL,@unassign='0',@gen_state=NULL,@gen_year=NULL,@gen_date_from=NULL,@gen_date_to=NULL,@generator_id=NULL,@counterparty_id=NULL,@book_deal_type_map_id=NULL,@table_name='adiha_process.dbo.recassign__farrms_admin_D4A402AE_C97B_49FD_A7C1_B897B88280CD',@assign_id='',@volume=NULL,@select_all_deals='0',@selected_row_ids='1',@committed='1',@compliance_group_id='24',@call_from_sale_deal='0',@original_deal_id=NULL
--**************************TEST CODE END************************/				

DECLARE @user_name VARCHAR(50)
DECLARE @sql_stmt VARCHAR(5000)
DECLARE @sql_stmt2 VARCHAR(5000)
DECLARE @sql_where VARCHAR(5000)
DECLARE @sql_where2 VARCHAR(5000)
DECLARE @job_name VARCHAR(100)
DECLARE @process_id VARCHAR(50)
DECLARE @desc VARCHAR(1000)
DECLARE @farrms_dealId VARCHAR(20)
DECLARE @ref_id VARCHAR(20)
DECLARE @deal_id VARCHAR(100)
DECLARE @uom VARCHAR(100)
DECLARE @assign_commit_label VARCHAR(100)
DECLARE @unassign_commit_label VARCHAR(100)
DECLARE @list_of_states VARCHAR(8000)

SET @sql_where = ''
SET @sql_where2 = ''
SET @farrms_dealId = '' 

SET @assign_commit_label = CASE @committed WHEN 1 THEN 'committed' ELSE 'assigned' END
SET @unassign_commit_label = CASE @committed WHEN 1 THEN 'reverted' ELSE 'unassigned' END

SELECT @deal_id = code FROM static_data_value WHERE value_id = @assignment_type

IF @table_name IS NOT NULL AND @select_all_deals = 1
BEGIN
DECLARE @all_deal_ids VARCHAR(MAX), @sql_ids VARCHAR(250)	
	
SET @sql_ids = 'SELECT STUFF((SELECT '', '' + CAST([ID] AS VARCHAR) FROM '
				+ @table_name + 
				' ORDER BY [ID] FOR XML PATH('''')), 1, 1, '''')'
	
CREATE TABLE #temp_ids(deal_ids VARCHAR(MAX) COLLATE DATABASE_DEFAULT )
INSERT INTO #temp_ids EXEC(@sql_ids)
SELECT @all_deal_ids  = deal_ids FROM #temp_ids
	
SET @sql_where = ' AND ID IN (' + CAST(@all_deal_ids AS VARCHAR(MAX)) + ')'
END	
ELSE IF @select_all_deals = 0
BEGIN
IF @source_deal_detail_ids IS NOT NULL 
	SET @sql_where = ' AND ID IN (' + @source_deal_detail_ids + ')'
		
IF @selected_row_ids IS NOT NULL 
	SET @sql_where = ISNULL(@sql_where, '') + ' AND row_unique_id IN (' + @selected_row_ids + ')'
END
ELSE
BEGIN
SET @sql_where=''
END
	
SET @process_id = dbo.FNAGetNewID()
SET @job_name = 'rec_' + @process_id

IF ISNULL(@user_id, '') = ''
SET @user_name = dbo.FNADBUser()
ELSE	
SET @user_name = @user_id

CREATE TABLE #deals_count
(
[ID] INT IDENTITY, 
source_deal_detail_id INT, 
volume NUMERIC(38,20), 
cert_from INT, 
cert_to INT, 
assign_id INT, 
uom VARCHAR(100) COLLATE DATABASE_DEFAULT , 
compliance_year INT, 
tier INT,
state_value_id INT,
book_deal_type_map_id INT,
counterparty INT,
assigned_date DATETIME,
desc1 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
desc2 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
desc3 VARCHAR(100) COLLATE DATABASE_DEFAULT 
)

CREATE TABLE #deals_count1
(
[ID] INT IDENTITY, 
source_deal_detail_id INT, 
volume NUMERIC(38, 20), 
cert_from INT, 
cert_to INT , 
uom VARCHAR(100) COLLATE DATABASE_DEFAULT , 
compliance_year INT, 
tier INT,
book_deal_type_map_id INT,
counterparty INT,
assigned_date DATETIME,
desc1 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
desc2 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
desc3 VARCHAR(100) COLLATE DATABASE_DEFAULT ,
state_value_id INT,
)

--select * from adiha_process.dbo.process_table_sa_0CB0D990_B351_40C5_9B4F_BB9A4B669E6F

--if sold selected make sure required fields are passed

IF ISNULL(@assignment_type, 5149) = 5149
BEGIN
SELECT 'Error' ErrorCode, 'Assign Credits/Allowance' [Module], 'spa_assign_rec_deals', 'Invalid Category' [Status], 
	('You can not assign/unassign Credits to Banked Category AS non assigned Credits are banked by default. Please SELECT another category to assign.')  [Message], 
	'' Recommendation		
RETURN
END

IF @unassign = 0
BEGIN
IF @call_from_old <> 2
BEGIN
	IF ISNULL(@assignment_type, 5149) = 5173 AND @call_from_old <> 3
	BEGIN
			
		IF @assigned_price IS NULL
		BEGIN
			SELECT 'Error' ErrorCode, 'Assign Credits/Allowance' Module, 'spa_assign_rec_deals', 'Invalid Price' [Status], 
				('Price is required to sale a Credits. Please make sure appropriate Sold Price is entered.')  [Message], 
				'' Recommendation		
			RETURN
		END

		IF @assigned_counterparty IS NULL
		BEGIN
			SELECT 'Error' ErrorCode, 'Assign Credits/Allowance' [Module], 'spa_assign_rec_deals', 'Invalid Counterparty' [Status], 
				('Counterparty is required to sale a Credit(s). Please make sure appropriate Counterparty is selected.')  [Message], 
				'' Recommendation		
			RETURN
		END

		IF @trader_id IS NULL
		BEGIN
			SELECT 'Error' ErrorCode, 'Assign Credits/Allowance' [Module], 'spa_assign_rec_deals', 'Invalid Trder' [Status], 
				('Trader is required to sale a Credit(s). Please make sure appropriate Counterparty is selected.')  [Message], 
				'' Recommendation		
			RETURN
		END
	END
	ELSE
	BEGIN
		IF @assigned_state IS NULL
		BEGIN
			SELECT 'Error' ErrorCode, 'Assign Credits/Allowance' [Module], 'spa_assign_rec_deals', 'Invalid Assigned State' [Status], 
				('State is required to Assign a Credit(s). Please make sure appropriate State is selected.')  [Message], 
				'' Recommendation		
			RETURN
		END	
	END
END
END

IF @table_name IS NOT NULL
BEGIN
IF @unassign = 0
BEGIN
	CREATE TABLE #table_name(volume_assign NUMERIC(38, 20), volume_left NUMERIC(38, 20))
	IF COL_LENGTH('#table_name', '[total volume]') IS NOT NULL AND COL_LENGTH('#table_name', '[volume left]') IS NOT NULL
	BEGIN 
		SET @sql_stmt = '
		INSERT INTO #deals_count(source_deal_detail_id, volume, cert_from, cert_to, uom, compliance_year, tier, state_value_id) 
		SELECT [ID], [volume assign], CAST(cert_from AS INT), CAST(cert_to AS INT), uom, compliance_year, tier_value_id, jurisdiction_state_id
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where
			 
		SET @sql_stmt2 = '
		INSERT INTO #deals_count1 (source_deal_detail_id, volume, compliance_year, tier) 
		SELECT [ID], SUM([volume assign]), compliance_year, tier_value_id 
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where + ' GROUP BY [ID], compliance_year, tier_value_id ' 
	END
	IF @call_from_old = 3
	BEGIN
		SET @sql_stmt = '
		INSERT INTO #deals_count(source_deal_detail_id, volume, uom, book_deal_type_map_id, assigned_date, counterparty, desc1, desc2, desc3) 
		SELECT [ID], [volume assign], uom, book_deal_type_map_id, assigned_date, counterparty, desc1, desc2, desc3
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where
			 
		SET @sql_stmt2 = '
		INSERT INTO #deals_count1 (source_deal_detail_id, volume, book_deal_type_map_id, assigned_date, counterparty, desc1, desc2, desc3) 
		SELECT [ID], SUM([volume assign]), book_deal_type_map_id, max(assigned_date), max(counterparty), max(desc1), max(desc2), max(desc3)
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where + ' GROUP BY [ID], book_deal_type_map_id ' 
	END
	ELSE IF @call_from_old = 2
	BEGIN
		SET @sql_stmt = '
		INSERT INTO #deals_count(source_deal_detail_id, volume, cert_from, cert_to, uom, book_deal_type_map_id, state_value_id) 
		SELECT [ID], [volume assign], CAST(cert_from AS INT), CAST(cert_to AS INT), uom, book_deal_type_map_id, state_value_id
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where
			 
		SET @sql_stmt2 = '
		INSERT INTO #deals_count1 (source_deal_detail_id, volume, book_deal_type_map_id, state_value_id) 
		SELECT [ID], SUM([volume assign]), book_deal_type_map_id, max(state_value_id) state_value_id
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where + ' GROUP BY [ID], book_deal_type_map_id '
	END
	ELSE IF @call_from_old = 1
	BEGIN
		SET @sql_stmt = '
		INSERT INTO #deals_count(source_deal_detail_id, volume, cert_from, cert_to, uom) 
		SELECT [ID], [volume assign], CAST(cert_from AS INT), CAST(cert_to AS INT), uom
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where
			 
		SET @sql_stmt2 = '
		INSERT INTO #deals_count1 (source_deal_detail_id, volume) 
		SELECT [ID], SUM([volume assign]) 
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where + ' GROUP BY [ID] ' 
	END
	ELSE IF @call_from_sale_deal = 2 AND ISNULL(@assignment_type, 5149) IN (5146,5183) 
	BEGIN
		SET @sql_stmt = '
		INSERT INTO #deals_count(source_deal_detail_id, volume, cert_from, cert_to, uom, compliance_year, state_value_id) 
		SELECT [ID], [volume assign], CAST(cert_from AS INT), CAST(cert_to AS INT), uom, compliance_year, jurisdiction_state_id
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where
			 
		SET @sql_stmt2 = '
		INSERT INTO #deals_count1 (source_deal_detail_id, volume, compliance_year) 
		SELECT [ID], SUM([volume assign]), compliance_year 
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where + ' GROUP BY [ID], compliance_year ' 
	END			
	ELSE IF ISNULL(@assignment_type, 5149) = 5173 AND @call_from_sale_deal = 2
	BEGIN
		SET @sql_stmt = '
		INSERT INTO #deals_count(source_deal_detail_id, volume, cert_from, cert_to, uom, tier) 
		SELECT [ID], [volume assign], CAST(cert_from AS INT), CAST(cert_to AS INT), uom, tier_value_id
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where
			 
		SET @sql_stmt2 = '
		INSERT INTO #deals_count1 (source_deal_detail_id, volume) 
		SELECT [ID], SUM([volume assign])  
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where + ' GROUP BY [ID]' 
	END
	ELSE
	BEGIN
		SET @sql_stmt = '
		INSERT INTO #deals_count(source_deal_detail_id, volume, cert_from, cert_to, uom, compliance_year, tier, state_value_id) 
		SELECT [ID], [volume assign], CAST(cert_from AS INT), CAST(cert_to AS INT), uom, compliance_year, tier_value_id, jurisdiction_state_id
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where
			 
		SET @sql_stmt2 = '
		INSERT INTO #deals_count1 (source_deal_detail_id, volume, compliance_year, tier) 
		SELECT [ID], SUM([volume assign]), compliance_year, tier_value_id 
		FROM ' + @table_name + ' 
		WHERE 1 = 1 ' + @sql_where + ' GROUP BY [ID], compliance_year, tier_value_id ' 
	END
		
END
ELSE
BEGIN
	SET @sql_stmt = 'INSERT INTO #deals_count(source_deal_detail_id, volume, cert_from, cert_to, assign_id, uom, tier) 
	SELECT [ID], [volume unassign], CAST(cert_from AS INT), CAST(cert_to AS INT), assign_id, uom , tier_value_id 
	FROM ' + @table_name + ' 
	WHERE 1 = 1 ' + @sql_where
END

EXEC(@sql_stmt)
EXEC(@sql_stmt2)
	
SELECT @list_of_states = ISNULL(@list_of_states,'') + CASE WHEN @list_of_states IS NULL THEN '' ELSE ', ' END + sdv.code from #deals_count dc
INNER JOIN (select * from static_Data_value where type_id = 10002) sdv ON sdv.value_id = dc.state_value_id 
group by sdv.code
	
	
	
--IF EXISTS(SELECT 1 FROM source_deal_detail sdd 
--INNER JOIN #deals_count dc ON sdd.source_deal_detail_id = dc.source_deal_detail_id
--INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
--WHERE close_reference_id IS NOT NULL) AND @committed <> 1
--BEGIN
--	EXEC spa_ErrorHandler @@ERROR, 'Assign Credits/Allowance Deals', 
--		'spa_assign_rec_deals', 'DB Error', 
--		'Only Original deals can be assigned', ''
--	RETURN
--END
	
	
	
--SELECT '#deals_count', * FROM #deals_count ORDER BY id, source_deal_detail_id
--SELECT '#deals_count1', * FROM #deals_count1 ORDER BY id, source_deal_detail_id
--RETURN

--select * from #deals_count
IF (SELECT COUNT(*) FROM #deals_count) <= 0
BEGIN
	--SET @desc = 'No transactions found to ' + CASE WHEN (@unassign = 0) THEN 'Assign' ELSE 'UnAssign' END + 
	--	' task AS of ' + dbo.FNADateFormat(@assigned_date) + ': ' +  
	--	(SELECT code FROM static_data_value WHERE value_id = @assignment_type) +
	--	' Category for ' +  ISNULL((SELECT code FROM static_data_value  WHERE value_id = @assigned_state), 'NoState') +
	--        ' State for Year ' + CAST(@compliance_year AS VARCHAR)
		
	
	--EXEC  spa_message_board 'i', @user_name, 
	--	NULL, 'Assign Credits/Allowance', 
	--	@desc, '', '', 
	--	'e', @job_name
	RETURN
END
END

SELECT @uom = MAX(uom) FROM #deals_count
--Can't find deals for assigning to banked state

IF @@ERROR <> 0
BEGIN
SET @sql_stmt = 'Failed to assign deals: ' + @source_deal_detail_ids
EXEC spa_ErrorHandler @@ERROR, 'Assign Credits/Allowance Deals', 
		'spa_assign_rec_deals', 'DB Error', 
		@sql_stmt, ''
RETURN
END

DECLARE @maxid INT
CREATE TABLE #unique_id([ID] INT IDENTITY, unique_ID INT)

IF @call_from_sale_deal = 1
BEGIN

	
	SELECT @maxid = MAX(farrms_id) FROM farrms_dealId
	
	
	IF @table_name IS NULL      
		INSERT farrms_dealId SELECT GETDATE() FROM transactions
	ELSE
		EXEC('INSERT farrms_dealId SELECT getDate() FROM '+ @table_name)

	INSERT INTO #unique_id(unique_ID) SELECT farrms_id FROM farrms_dealId WHERE farrms_id > @maxid

	--finally UPDATE newly created offset deal's ext_deal_id with its original value
	UPDATE sdh
	SET sdh.ext_deal_id = CAST(org.source_deal_header_id AS VARCHAR(50))
	FROM 
	source_deal_header sdh 
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
	INNER JOIN #deals_count1 assign ON sdd.[source_deal_detail_id] = assign.[source_deal_detail_id]
	CROSS JOIN source_deal_header org
	where org.source_deal_header_id = @original_deal_id

	UPDATE org
	SET org.assignment_type_value_id = @assignment_type
	FROM 
	source_deal_header org
	where org.source_deal_header_id = @original_deal_id


	IF @@ERROR <> 0
	BEGIN
		SET @sql_stmt = 'Failed to create sale positions for Credits/Allowance: ' + @source_deal_detail_ids
		EXEC spa_ErrorHandler @@ERROR, 'Assign Credits/Allowance Deals', 
				'spa_assign_rec_deals', 'DB Error', @sql_stmt, ''
		RETURN
	END
	ELSE
	BEGIN
		--IMP: source_deal_header_id AND source_deal_header_id_from in table assignment_audit actually stores deal detail ids.
		SET @sql_stmt = '
		INSERT INTO assignment_audit
		(
			assignment_type, assigned_volume, source_deal_header_id, source_deal_header_id_from, compliance_year, state_value_id
			, assigned_date, assigned_by, cert_from, cert_to, tier, committed, compliance_group_id, org_assigned_volume
		)
		--distinct is required as joining with sdh.ext_deal_id produces duplicates when same deal is contributing to multiple tiers,
		--resulting in creation of multiple assignment deals having same ext_deal_id
		SELECT DISTINCT
			' + CAST(@assignment_type AS VARCHAR(25)) + ' assignment_type, tmp.[volume] assigned_volume, sdd_assign.source_deal_detail_id source_deal_header_id
			, sdd_recs.source_deal_detail_id source_deal_header_id_from, ' + CASE WHEN CAST(@assignment_type AS VARCHAR(25)) <> 5173 
				THEN 'ISNULL(tmp.compliance_year, ' + CAST(@compliance_year AS VARCHAR(10)) + ')' ELSE 'NULL' END + ' 
			, ' + CASE WHEN (@assigned_state IS NULL OR @assignment_type = 5173) THEN 'NULL' ELSE CAST(@assigned_state AS VARCHAR(25)) END + '
			, ''' + dbo.FNAGetSQLStandardDate(@assigned_date) + ''', dbo.FNADBUser(), tmp.cert_from, tmp.cert_to, tmp.tier, ' + CAST(ISNULL(@committed, 0) AS VARCHAR(1)) + ' ,' + CAST(ISNULL(@compliance_group_id,0) AS VARCHAR(100)) + ', tmp.[volume] org_assigned_volume
		FROM
			#deals_count tmp 
			INNER JOIN source_deal_detail sdd_recs ON tmp.source_deal_detail_id = sdd_recs.source_deal_detail_id
			INNER JOIN source_deal_header sdh_recs ON sdh_recs.source_deal_header_id = sdd_recs.source_deal_header_id
			INNER JOIN source_deal_header sdh_assign ON CAST(sdh_assign.[source_deal_header_id] AS VARCHAR(25)) = sdh_recs.ext_deal_id
			INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_header_id = sdh_assign.source_deal_header_id
			--INNER JOIN #unique_id unq ON ''Assigned-'' + CAST(unq.[unique_id] AS VARCHAR) = sdh_assign.deal_id
			--INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh_assign.source_deal_header_id
			--	AND CAST(tmp.tier AS VARCHAR(8000)) = uddf.udf_value				
			--INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id
			--	AND uddft.field_name = -10020
		WHERE 1 = 1 
			--TODO: Seems like this block is wrong and can be removed.
			AND NOT EXISTS (SELECT 1 FROM assignment_audit WHERE source_deal_header_id = sdd_recs.source_deal_detail_id)
		'
		
		EXEC(@sql_stmt)
		
		UPDATE sdh 
		SET sdh.close_reference_id = @original_deal_id 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #deals_count dc 
			ON dc.source_deal_detail_id = sdd.source_deal_detail_id
		
		IF @commit_type <> 'a'
		BEGIN
			SET @sql_stmt = '
			UPDATE sdd_allocated
				SET sdd_allocated.volume_left = sdd_allocated.volume_left - (sdd_allocated.deal_volume/sdd.deal_volume)*ISNULL(rs_tmp.volume,0)
			FROM
				source_deal_detail sdd 
				INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
				INNER JOIN source_deal_header sdh_offset ON sdh.source_deal_header_id = sdh_offset.close_reference_id
				INNER JOIN source_deal_header sdh_allocated ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
				INNER JOIN source_deal_detail sdd_allocated ON sdh_allocated.source_deal_header_id = sdd_allocated.source_deal_header_id
				INNER JOIN (
					SELECT SUM(volume) volume, source_deal_detail_id  
					FROM #deals_count tmp 
					group by source_deal_detail_id
				) rs_tmp ON rs_tmp.[source_deal_detail_id] = sdd.source_deal_detail_id
				WHERE 1 = 1'

			--IF @source_deal_detail_ids is not null AND @source_deal_detail_ids<>''
	  --			SET @sql_where=' AND sd.source_deal_detail_id in(' + @source_deal_detail_ids + ')'

			IF @assign_id IS NOT NULL AND @assign_id <> ''
				SET @sql_where2 = ' AND tmp.assign_id in(' + @assign_id + ')'
			
			SET @sql_stmt = @sql_stmt + @sql_where2
			
			EXEC (@sql_stmt)
		END
		
			
	
		--SET @sql_stmt = '
		--UPDATE sdd
		--	SET sdd.volume_left = sdd.volume_left - ISNULL(rs_tmp.[volume], 0)
		----SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.volume_left, ISNULL(rs_tmp.[volume], 0), sdd.volume_left - ISNULL(rs_tmp.[volume], 0)
		--FROM
		--	source_deal_detail sdd 
		--	INNER JOIN (
		--		SELECT SUM(volume) volume, source_deal_detail_id  
		--		FROM #deals_count tmp 
		--		group by source_deal_detail_id
		--	) rs_tmp ON rs_tmp.[source_deal_detail_id] = sdd.source_deal_detail_id
		--	WHERE 1 = 1 '

		----IF @source_deal_detail_ids is not null AND @source_deal_detail_ids<>''
  ----			SET @sql_where=' AND sd.source_deal_detail_id in(' + @source_deal_detail_ids + ')'

		--IF @assign_id IS NOT NULL AND @assign_id <> ''
		--	SET @sql_where2 = ' AND tmp.assign_id in(' + @assign_id + ')'
		
		--SET @sql_stmt = @sql_stmt + @sql_where2
		
		--EXEC (@sql_stmt)
	
		SET @desc = (SELECT code FROM static_data_value WHERE value_id = @assignment_type) +
			CASE WHEN(@assignment_type in (5173,5183)) THEN ' Category.' ELSE		
			' Category for ' +  ISNULL((SELECT code FROM static_data_value WHERE value_id = @assigned_state), 'NoState') +
		        ' State for Year ' + CAST(@compliance_year AS VARCHAR(10)) 
			END 
			+
			CASE WHEN(@assignment_type in (5173,5183)) THEN ' sales position for ' 
				+ (SELECT counterparty_name 
					FROM source_counterparty 
				    WHERE source_counterparty_id = @assigned_counterparty) + ' automatically created' ELSE '' 
			END
			
			
		--IF @template_id IS NULL
		--BEGIN
			--select * from #deals_count
			INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
			SELECT sdd_sale.source_deal_detail_id, 
			CASE WHEN ISNUMERIC(substring(gc_assign.gis_certificate_number_from,len(gc_assign.gis_certificate_number_from)-charindex('-',reverse(gc_assign.gis_certificate_number_from))+2,LEN(gc_assign.gis_certificate_number_from))) = 1
			THEN
			SUBSTRING(gc_assign.gis_certificate_number_from,0,LEN(gc_assign.gis_certificate_number_from) - CHARINDEX('-',REVERSE(gc_assign.gis_certificate_number_from)) + 2) 
			+ CAST((certificate_number_from_int + (sdd_sale.deal_volume - sdd_sale.volume_left)) AS VARCHAR)
			ELSE gc_assign.gis_certificate_number_from END
			, CASE WHEN ISNUMERIC(substring(gc_assign.gis_certificate_number_to,len(gc_assign.gis_certificate_number_to)-charindex('-',reverse(gc_assign.gis_certificate_number_to))+2,LEN(gc_assign.gis_certificate_number_to))) = 1
			THEN 
			SUBSTRING(gc_assign.gis_certificate_number_from,0,LEN(gc_assign.gis_certificate_number_from) - CHARINDEX('-',REVERSE(gc_assign.gis_certificate_number_from)) + 2) 
			+ CAST((certificate_number_from_int + (sdd_sale.deal_volume - sdd_sale.volume_left) + dc.volume) AS VARCHAR)
			ELSE gc_assign.gis_certificate_number_to END ,
			 (certificate_number_from_int + (sdd_sale.deal_volume - sdd_sale.volume_left)) , (certificate_number_from_int + (sdd_sale.deal_volume - sdd_sale.volume_left) + dc.volume) 
			, GETDATE()		
			  FROM 
			 #deals_count dc 
			INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_detail_id = dc.source_deal_detail_id
			INNER JOIN gis_certificate gc_assign ON gc_assign.source_deal_header_id = sdd_assign.source_deal_detail_id
				--AND gc_assign.state_value_id = dc.state_value_id
			INNER JOIN source_deal_header sdh_assign ON sdh_assign.source_deal_header_id = sdd_assign.source_deal_header_id 
			INNER JOIN source_deal_header sdh_sale ON sdh_sale.source_deal_header_id = sdh_assign.ext_deal_id
			INNER JOIN source_deal_detail sdd_sale on sdd_sale.source_deal_header_id = sdh_sale.source_deal_header_id
		--END
		
		--return

		--INSERT INTO rec_assign_log(process_id, code, [Module], [source], [type], [description], source_deal_header_id, source_deal_header_id_sale_from)  
		--SELECT DISTINCT @process_id, 'Success', 'Credits/Allowance Assign', 'spa_assign_rec_deals', 'Status'
		--	, 'Deal ' + CAST(sdd.source_deal_header_id AS VARCHAR(25)) + ' assigned to ' + @desc 
		--	, sdh.source_deal_header_id, sdd.source_deal_header_id
		--FROM  #deals_count tmp
		--INNER JOIN source_deal_detail sdd ON tmp.source_deal_detail_id = sdd.source_deal_detail_id
		--INNER JOIN source_deal_header sdh ON sdh.ext_deal_id = CAST(sdd.source_deal_header_id AS VARCHAR(25))
		--INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = sdh.source_deal_header_id	
	END
END	--assignment type <> 5149	

ELSE IF @assignment_type <> 5149 AND @unassign = 0
BEGIN

SELECT @maxid = MAX(farrms_id) FROM farrms_dealId
--CREATE TABLE #unique_id([ID] INT IDENTITY, unique_ID INT)
	
IF @table_name IS NULL      
	INSERT farrms_dealId SELECT GETDATE() FROM transactions
ELSE
	EXEC('INSERT farrms_dealId SELECT getDate() FROM '+ @table_name)
		
INSERT INTO #unique_id(unique_ID) SELECT farrms_id FROM farrms_dealId WHERE farrms_id > @maxid
CREATE TABLE #inserted_source_deal_header_id(source_deal_header_id INT, unique_deal_tier_id INT)
	
	
IF @template_id IS NOT NULL
BEGIN
	SET @sql_stmt = '
	INSERT INTO source_deal_header
	(
		source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, 
		source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, 
		source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id, 
		internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, 
		generator_id, status_date, assignment_type_value_id, compliance_year, state_value_id, 
		assigned_date, assigned_by, deal_status, confirm_status_type	
	) output inserted.source_deal_header_id, INSERTED.ext_deal_id INTO #inserted_source_deal_header_id (source_deal_header_id, unique_deal_tier_id)
	SELECT     
		sdh.source_system_id
		, CASE WHEN ' + CAST(ISNULL(@assignment_type, 5149) AS VARCHAR) + ' = 5173 THEN ''Sold/Xferred-'' ELSE ''Assigned-'' END + CAST(unq.unique_id AS VARCHAR(50)) AS deal_id	   
		, ' + CASE WHEN @call_from_old = 3 THEN ' assign.assigned_date' ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' END + ' deal_date
		--, CAST(sdh.source_deal_header_id AS VARCHAR) ext_deal_id
		, assign.ID	--save unique id of #deal_count1 instead of saving real ext_deal_id. This will help us to map between newly created deal AND original deal AND its tier.
		, sdh.physical_financial_flag
		, NULL AS structured_deal_id
		, ' + CASE WHEN @call_from_old = 3 THEN ' assign.counterparty ' WHEN @assigned_counterparty IS NULL THEN 
						' sdh.counterparty_id ' 
					ELSE CAST(@assigned_counterparty AS VARCHAR(250)) 
			    END + '
		, sdh.entire_term_start AS entire_term_start
		, sdh.entire_term_end  AS entire_term_end
		, CASE WHEN (sdh.source_deal_type_id = 53) THEN 55 ELSE sdh.source_deal_type_id END source_deal_type_id
		, sdh.deal_sub_type_type_id, sdh.option_flag, sdh.option_type, sdh.option_excercise_type
		, ISNULL(ssbm.source_system_book_id1, sdh.source_system_book_id1)
		, ISNULL(ssbm.source_system_book_id2, sdh.source_system_book_id2)
		, ISNULL(ssbm.source_system_book_id3, sdh.source_system_book_id3)
		, ISNULL(ssbm.source_system_book_id4, sdh.source_system_book_id4)
		, '+ CASE WHEN @call_from_old = 3 THEN ' assign.desc1 ' ELSE '(''' + @deal_id + ''' + '' FROM deal '' + CAST(sdh.source_deal_header_id AS VARCHAR(25)))' END + ' description1
		, '+ CASE WHEN @call_from_old = 3 THEN ' assign.desc2 ' ELSE ' sdh.description2 ' END + ', 
		' + CASE WHEN @call_from_old = 3 THEN ' assign.desc3 ' ELSE ' sdh.description3 ' END + '
		, sdh.deal_category_value_id 
		, '	+ CASE WHEN @trader_id IS NULL THEN ' sdh.trader_id ' ELSE CAST(@trader_id  AS VARCHAR(150)) END + '
		, sdh.internal_deal_type_value_id, sdh.internal_deal_subtype_value_id
		, sdht.template_id, ''s'' header_buy_sell_flag, sdh.broker_id
		, sdh.generator_id,sdh.status_date
		, ' + CAST(@assignment_type AS VARCHAR(25)) + ' assignment_type_value_id	
		, ' + CASE WHEN ISNULL(@call_from_old,0) = 1  THEN cast (@compliance_year AS VARCHAR(20)) ELSE + 'CASE WHEN ' + CAST(@assignment_type AS VARCHAR(25)) + ' <> 5149 AND ' + CAST(@assignment_type AS VARCHAR(25)) + ' <> 5173 THEN 
			ISNULL(assign.compliance_year, ' + CAST(ISNULL(@compliance_year, '') AS VARCHAR(10)) + ') ELSE NULL END '  END + '
		, CASE WHEN  ' + CAST(@call_from_old as VARCHAR) + ' = 2 THEN assign.state_value_id WHEN ' + CAST(@assignment_type AS VARCHAR(25)) + ' <> 5173 THEN ' + CAST(ISNULL(@assigned_state, '') AS VARCHAR(25)) 
			+ ' ELSE NULL END
		, ' + CASE WHEN @call_from_old = 3 THEN ' assign.assigned_date' ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' END + '
		, ''' + @user_name + '''
		, 5604
		, 17200	
	FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		CROSS JOIN source_deal_header_template sdht
		INNER JOIN #deals_count1 assign ON sdd.[source_deal_detail_id] = assign.[source_deal_detail_id]
		INNER JOIN static_data_value at ON at.value_id = '+CAST(@assignment_type AS VARCHAR(25)) + '  
		INNER JOIN #unique_id unq ON unq.[ID] = assign.[ID]
		LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = ' +
			CASE WHEN @call_from_old IN (2,3) THEN ' assign.book_deal_type_map_id' ELSE CASE WHEN ISNULL(@book_deal_type_map_id,'-1') = '-1' THEN 'NULL' ELSE 
			CAST(@book_deal_type_map_id AS VARCHAR(25)) END END + '			
		WHERE 1 = 1 AND sdht.template_id = ' + CAST(@template_id AS VARCHAR(25))
			    
	--IF ISNULL(@source_deal_detail_ids, '') <> ''
	--	SET @sql_where=' AND sdd.source_deal_detail_id in('+@source_deal_detail_ids+')'	
	--SET @sql_stmt=@sql_stmt--+@sql_where
	
END	--@template_id NOT NULL
ELSE
BEGIN
	SET @sql_stmt = '
	INSERT INTO  source_deal_header
	(
		source_system_id, deal_id, deal_date, ext_deal_id, physical_financial_flag, structured_deal_id, counterparty_id, entire_term_start, entire_term_end, 
		source_deal_type_id, deal_sub_type_type_id, option_flag, option_type, option_excercise_type, source_system_book_id1, source_system_book_id2, 
		source_system_book_id3, source_system_book_id4, description1, description2, description3, deal_category_value_id, trader_id, 
		internal_deal_type_value_id, internal_deal_subtype_value_id, template_id, header_buy_sell_flag, broker_id, 
		generator_id, status_date, assignment_type_value_id, compliance_year, state_value_id, 
		assigned_date, assigned_by
	) OUTPUT inserted.source_deal_header_id, INSERTED.ext_deal_id INTO #inserted_source_deal_header_id (source_deal_header_id, unique_deal_tier_id)
	SELECT     
		source_system_id  
		, ''Assigned-'' + CAST(unq.unique_id AS VARCHAR(50)) AS deal_id	   
		, ' + CASE WHEN @call_from_old = 3 THEN ' assign.assigned_date' ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' END + ' deal_date
		--CAST(sdh.source_deal_header_id AS VARCHAR) ext_deal_id
		, assign.ID	--save unique id of #deal_count1 instead of saving real ext_deal_id. This will help us to map between newly created deal AND original deal AND its tier.
		, sdh.physical_financial_flag
		, NULL AS structured_deal_id
		, ' + CASE WHEN @call_from_old = 3 THEN ' assign.counterparty ' WHEN @assigned_counterparty IS NULL THEN 
						' sdh.counterparty_id ' 
					ELSE CAST(@assigned_counterparty AS VARCHAR(250)) 
			    END + '
		, sdh.entire_term_start AS entire_term_start, sdh.entire_term_end  AS entire_term_end 
		, CASE WHEN (source_deal_type_id = 53) THEN 55 ELSE source_deal_type_id END source_deal_type_id
		, deal_sub_type_type_id, option_flag, option_type, option_excercise_type
		, ISNULL(ssbm.source_system_book_id1, sdh.source_system_book_id1)
		, ISNULL(ssbm.source_system_book_id2, sdh.source_system_book_id2) 
		, ISNULL(ssbm.source_system_book_id3, sdh.source_system_book_id3)
		, ISNULL(ssbm.source_system_book_id4, sdh.source_system_book_id4) 
		, '+ CASE WHEN @call_from_old = 3 THEN ' assign.desc1 ' ELSE '(''' + @deal_id + ''' + '' FROM deal '' + CAST(sdh.source_deal_header_id AS VARCHAR(25)))' END + ' description1
		, '+ CASE WHEN @call_from_old = 3 THEN ' assign.desc2 ' ELSE ' sdh.description2 ' END + ', 
		' + CASE WHEN @call_from_old = 3 THEN ' assign.desc3 ' ELSE ' sdh.description3 ' END + '
		, sdh.deal_category_value_id 
		, ' + CASE WHEN @trader_id IS NULL THEN ' trader_id ' ELSE CAST(@trader_id  AS VARCHAR(25)) END + '
		, internal_deal_type_value_id, internal_deal_subtype_value_id
		, template_id, ''s'' header_buy_sell_flag, broker_id
		, generator_id, status_date
		, ' + CAST(@assignment_type AS VARCHAR(25)) + ' assignment_type_value_id
		, CASE WHEN ' + CAST(@assignment_type AS VARCHAR(25)) + ' <> 5149 AND ' + CAST(@assignment_type AS VARCHAR(25)) + ' <> 5173 
			THEN ISNULL(assign.compliance_year, ' + CAST(ISNULL(@compliance_year, '') AS VARCHAR(10)) + ') ELSE NULL END
		, CASE WHEN ' + CAST(@assignment_type AS VARCHAR(25)) + ' <> 5173 THEN ' + CAST(ISNULL(@assigned_state, '') AS VARCHAR(25)) 
			+ ' ELSE NULL END
		, ' + CASE WHEN @call_from_old = 3 THEN ' assign.assigned_date' ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' END + '
		, ''' + @user_name + '''	
	FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		INNER JOIN #deals_count1 assign	ON sdd.[source_deal_detail_id] = assign.[source_deal_detail_id]
		INNER JOIN static_data_value at ON at.value_id=' + CAST(@assignment_type AS VARCHAR(25)) + '  
		INNER JOIN #unique_id unq ON unq.[ID] = assign.[ID]
		LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = ' +
			CASE WHEN @call_from_old IN (2,3) THEN ' assign.book_deal_type_map_id' ELSE CASE WHEN ISNULL(@book_deal_type_map_id,'-1') = '-1' THEN 'NULL' ELSE 
			CAST(@book_deal_type_map_id AS VARCHAR(25)) END END + '		
		WHERE 1 = 1 '

	--IF ISNULL(@source_deal_detail_ids, '') <> ''
	--	SET @sql_where=' AND sdd.source_deal_detail_id in('+@source_deal_detail_ids+')'	
	--SET @sql_stmt=@sql_stmt--+@sql_where
END	--@template_id NULL
	
EXEC(@sql_stmt)	


--insert tier into deal header UDF
SET @sql_stmt = '
INSERT INTO user_defined_deal_fields(source_deal_header_id, udf_template_id, udf_value)
SELECT isdhi.source_deal_header_id, uddft.udf_template_id, dc.tier 
FROM #inserted_source_deal_header_id isdhi
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = isdhi.source_deal_header_id
INNER JOIN user_defined_deal_fields_template uddft ON uddft.field_name = -10020
	AND uddft.template_id = sdh.template_id
INNER JOIN #deals_count dc ON dc.ID = isdhi.unique_deal_tier_id'
		

EXEC(@sql_stmt)
	
SET @inserted_source_deal_header_id = ''
SELECT @inserted_source_deal_header_id = @inserted_source_deal_header_id 
	+ CASE WHEN @inserted_source_deal_header_id = '' THEN '' ELSE ', ' END + CAST(source_deal_header_id AS VARCHAR(25)) 
FROM #inserted_source_deal_header_id 
	
IF @template_id IS NOT NULL
BEGIN
	SET @sql_stmt =
	'INSERT INTO source_deal_detail
		(
			source_deal_header_id, term_start, term_end, leg, contract_expiration_date, fixed_float_leg, 
			buy_sell_flag, curve_id, fixed_price, fixed_price_currency_id, 
			option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, 
			block_description, deal_detail_description, formula_id, physical_financial_flag,settlement_uom,settlement_volume, delivery_date
		)
		SELECT 
		sdh1.source_deal_header_id
		, sdd.term_start AS entire_term_start
		, sdd.term_end AS entire_term_end 
		, sdd.Leg, sdd.contract_expiration_date, sdd.fixed_float_leg 
		, ''s'', sdd.curve_id
		, ' + CASE WHEN @assigned_price IS NULL THEN 'sdd.fixed_price' ELSE CAST(@assigned_price AS VARCHAR(40)) END + '
		, sdd.fixed_price_currency_id, sdd.option_strike_price, assign.[volume] 
		, sdd.deal_volume_frequency, sdd.deal_volume_uom_id, sdd.block_description 
		, sdd.deal_detail_description, sdd.formula_id, sdd.physical_financial_flag,sdd.settlement_uom,assign.[volume]*CAST(ISNULL(conv.conversion_factor,1) AS NUMERIC(18,10))
		, ' + CASE WHEN @assignment_type = 5173 THEN 'assign.assigned_date'  ELSE  'NULL' END  + '
	FROM        
		source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		CROSS JOIN source_deal_detail_template sddt
		INNER JOIN source_deal_header_template sdht ON sdht.template_id = sddt.template_id
		INNER JOIN	#deals_count1 assign ON sdd.[source_deal_detail_id] = assign.source_deal_detail_id
		--INNER JOIN source_deal_header sdh1 ON CAST(sdh1.ext_deal_id AS VARCHAR(25)) = CAST(sdh.source_deal_header_id AS VARCHAR(25))
		INNER JOIN #inserted_source_deal_header_id isdh ON isdh.unique_deal_tier_id = assign.ID
		INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = isdh.source_deal_header_id
		INNER JOIN #unique_id unq ON ''Assigned-'' + CAST(unq.[unique_id] AS VARCHAR(25)) = sdh1.deal_id
			OR ''Sold/Xferred-'' + CAST(unq.[unique_id] AS VARCHAR(25)) = sdh1.deal_id
		INNER JOIN static_data_value at ON at.value_id = ' + CAST(@assignment_type AS VARCHAR(25)) + 		
		' LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = ' + 
			CASE WHEN @call_from_old IN (2,3) THEN ' assign.book_deal_type_map_id' ELSE CASE WHEN ISNULL(@book_deal_type_map_id,'-1') = '-1' THEN 'NULL' ELSE 
			CAST(@book_deal_type_map_id AS VARCHAR(25)) END END + '	
		LEFT JOIN rec_volume_unit_conversion conv on sdd.deal_volume_uom_id=conv.from_source_uom_id 
				AND conv.to_source_uom_id=sdd.settlement_uom
				AND conv.state_value_id is null and conv.assignment_type_value_id is null and conv.curve_id is null   		
			WHERE 1 = 1 AND sdht.template_id = ' + CAST(@template_id AS VARCHAR(25))
END	--@template_id NOT NULL
ELSE
BEGIN
	SET @sql_stmt =
		'INSERT INTO source_deal_detail
		(
		source_deal_header_id, 
		term_start, term_end, leg, contract_expiration_date, fixed_float_leg, 
		buy_sell_flag, curve_id, fixed_price, fixed_price_currency_id, 
		option_strike_price, deal_volume, deal_volume_frequency, deal_volume_uom_id, 
		block_description, deal_detail_description, formula_id, physical_financial_flag,settlement_uom,settlement_volume
        )
	
	SELECT 
		sdh1.source_deal_header_id
		, sdd.term_start AS entire_term_start 
		, sdd.term_end AS entire_term_end  
		, sdd.Leg, sdd.contract_expiration_date, sdd.fixed_float_leg
		, ''s'', sdd.curve_id
		, ' + CASE WHEN @assigned_price IS NULL THEN 'sdd.fixed_price' ELSE CAST(@assigned_price AS VARCHAR(40)) END + '
		, sdd.fixed_price_currency_id, sdd.option_strike_price, assign.[volume]  
		, sdd.deal_volume_frequency, sdd.deal_volume_uom_id, sdd.block_description
		, sdd.deal_detail_description, sdd.formula_id, sdd.physical_financial_flag,settlement_uom,assign.[volume]*CAST(ISNULL(conv.conversion_factor,1) AS NUMERIC(18,10))
	FROM        
		source_deal_header sdh 
		INNER JOIN source_deal_detail sdd ON sdh.source_deal_header_id = sdd.source_deal_header_id 
		INNER JOIN #deals_count1 assign ON sdd.[source_deal_detail_id] = assign.source_deal_detail_id
		--INNER JOIN source_deal_header sdh1 ON CAST(sdh1.ext_deal_id AS VARCHAR) = CAST(sdh.source_deal_header_id AS VARCHAR(25))
		INNER JOIN #inserted_source_deal_header_id isdh ON isdh.unique_deal_tier_id = assign.ID
		INNER JOIN source_deal_header sdh1 ON sdh1.source_deal_header_id = isdh.source_deal_header_id
		INNER JOIN #unique_id unq ON ''Assigned-'' + CAST(unq.[unique_id] AS VARCHAR(25)) = sdh1.deal_id
			OR ''Sold/Xferred-'' + CAST(unq.[unique_id] AS VARCHAR(25)) = sdh1.deal_id
		INNER JOIN static_data_value at ON at.value_id = ' + CAST(@assignment_type AS VARCHAR(25)) + '
		LEFT JOIN source_system_book_map ssbm ON ssbm.book_deal_type_map_id = ' 
			+ CASE WHEN @call_from_old IN (2,3) THEN ' assign.book_deal_type_map_id' ELSE CASE WHEN ISNULL(@book_deal_type_map_id,'-1') = '-1' THEN 'NULL' ELSE 
			CAST(@book_deal_type_map_id AS VARCHAR(25)) END END + '	
		LEFT JOIN rec_volume_unit_conversion conv on sdd.deal_volume_uom_id=conv.from_source_uom_id 
			AND conv.to_source_uom_id=sdd.settlement_uom
			AND conv.state_value_id is null and conv.assignment_type_value_id is null and conv.curve_id is null   		
	 	WHERE 1 = 1 '
END --@template_id NULL

EXEC(@sql_stmt)


--finally UPDATE newly created offset deal's ext_deal_id with its original value
UPDATE sdh
SET sdh.ext_deal_id = CAST(sdd.source_deal_header_id AS VARCHAR(50)),
    sdh.close_reference_id = CAST(sdd.source_deal_header_id AS VARCHAR(50)) 
FROM #inserted_source_deal_header_id tsdh
INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = tsdh.source_deal_header_id
INNER JOIN #deals_count1 dc ON dc.ID = tsdh.unique_deal_tier_id
INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = dc.source_deal_detail_id
	
	
IF @@ERROR <> 0
BEGIN
	SET @sql_stmt = 'Failed to create sale positions for Credits/Allowance: ' + @source_deal_detail_ids
	EXEC spa_ErrorHandler @@ERROR, 'Assign Credits/Allowance Deals', 
			'spa_assign_rec_deals', 'DB Error', @sql_stmt, ''
	RETURN
END
ELSE
BEGIN
	IF @call_from_old IN (1,2,3)
	BEGIN
		--IMP: source_deal_header_id AND source_deal_header_id_from in table assignment_audit actually stores deal detail ids.
		SET @sql_stmt = '
		INSERT INTO assignment_audit
		(
			assignment_type, assigned_volume, source_deal_header_id, source_deal_header_id_from, compliance_year, state_value_id
			, assigned_date, assigned_by, cert_from, cert_to, committed, compliance_group_id, org_assigned_volume
		)
		--distinct is required as joining with sdh.ext_deal_id produces duplicates when same deal is contributing to multiple tiers,
		--resulting in creation of multiple assignment deals having same ext_deal_id
		SELECT DISTINCT
			' + CAST(@assignment_type AS VARCHAR(25)) + ' assignment_type, tmp.[volume] assigned_volume, sdd_assign.source_deal_detail_id source_deal_header_id
			, sdd_recs.source_deal_detail_id source_deal_header_id_from, ' + CASE WHEN CAST(@assignment_type AS VARCHAR(25)) <> 5173 
				THEN  CAST(@compliance_year AS VARCHAR(10))  ELSE 'NULL' END + ' 
			, ' + CASE WHEN (@assigned_state IS NULL OR @assignment_type = 5173) THEN 'NULL' ELSE CAST(@assigned_state AS VARCHAR(25)) END + '
			, ' + CASE WHEN @call_from_old = 3 THEN ' tmp.assigned_date' ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + '''' END + ', dbo.FNADBUser(), tmp.cert_from, tmp.cert_to,  ' + CAST(ISNULL(@committed, 0) AS VARCHAR(1)) + ' ,' + CAST(ISNULL(@compliance_group_id,0) AS VARCHAR(100)) + ', tmp.[volume] org_assigned_volume
		FROM
			#deals_count tmp 
			INNER JOIN source_deal_detail sdd_recs ON tmp.source_deal_detail_id = sdd_recs.source_deal_detail_id
			INNER JOIN source_deal_header sdh_assign ON CAST(sdd_recs.[source_deal_header_id] AS VARCHAR(25)) = sdh_assign.ext_deal_id
			INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_header_id = sdh_assign.source_deal_header_id
			INNER JOIN #unique_id unq ON ''Assigned-'' + CAST(unq.[unique_id] AS VARCHAR) = sdh_assign.deal_id
				OR ''Sold/Xferred-'' + CAST(unq.[unique_id] AS VARCHAR(25)) = sdh_assign.deal_id
			INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh_assign.source_deal_header_id
				--AND CAST(tmp.tier AS VARCHAR(8000)) = uddf.udf_value				
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id
				AND uddft.field_name = -10020
		WHERE 1 = 1 
			--TODO: Seems like this block is wrong and can be removed.
			--AND NOT EXISTS (SELECT 1 FROM assignment_audit WHERE source_deal_header_id = sdd_recs.source_deal_detail_id)
		'
	END
	ELSE
	BEGIN
		--IMP: source_deal_header_id AND source_deal_header_id_from in table assignment_audit actually stores deal detail ids.
		SET @sql_stmt = '
		INSERT INTO assignment_audit
		(
			assignment_type, assigned_volume, source_deal_header_id, source_deal_header_id_from, compliance_year, state_value_id
			, assigned_date, assigned_by, cert_from, cert_to, tier, committed, compliance_group_id, org_assigned_volume
		)
		--distinct is required as joining with sdh.ext_deal_id produces duplicates when same deal is contributing to multiple tiers,
		--resulting in creation of multiple assignment deals having same ext_deal_id
		SELECT DISTINCT
			' + CAST(@assignment_type AS VARCHAR(25)) + ' assignment_type, tmp.[volume] assigned_volume, sdd_assign.source_deal_detail_id source_deal_header_id
			, sdd_recs.source_deal_detail_id source_deal_header_id_from, ' + CASE WHEN CAST(@assignment_type AS VARCHAR(25)) <> 5173 
				THEN 'ISNULL(tmp.compliance_year, ' + CAST(@compliance_year AS VARCHAR(10)) + ')' ELSE 'NULL' END + ' 
			, ' + CASE WHEN (@assigned_state IS NULL OR @assignment_type = 5173) THEN 'NULL' ELSE CAST(@assigned_state AS VARCHAR(25)) END + '
			, ' + CASE WHEN @call_from_old = 3 THEN ' tmp.assigned_date' ELSE '''' + dbo.FNAGetSQLStandardDate(@assigned_date) + ''''  END + ', dbo.FNADBUser(), tmp.cert_from, tmp.cert_to, tmp.tier, ' + CAST(ISNULL(@committed, 0) AS VARCHAR(1)) + ' ,' + CAST(ISNULL(@compliance_group_id,0) AS VARCHAR(100)) + ', tmp.[volume] org_assigned_volume
		FROM
			#deals_count tmp 
			INNER JOIN source_deal_detail sdd_recs ON tmp.source_deal_detail_id = sdd_recs.source_deal_detail_id
			INNER JOIN source_deal_header sdh_assign ON CAST(sdd_recs.[source_deal_header_id] AS VARCHAR(25)) = sdh_assign.ext_deal_id
			INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_header_id = sdh_assign.source_deal_header_id
			INNER JOIN #unique_id unq ON ''Assigned-'' + CAST(unq.[unique_id] AS VARCHAR) = sdh_assign.deal_id
			INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id = sdh_assign.source_deal_header_id
				AND CAST(tmp.tier AS VARCHAR(8000)) = uddf.udf_value				
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.udf_template_id = uddf.udf_template_id
				AND uddft.field_name = -10020
		WHERE 1 = 1 
			--TODO: Seems like this block is wrong and can be removed.
			AND NOT EXISTS (SELECT 1 FROM assignment_audit WHERE source_deal_header_id = sdd_recs.source_deal_detail_id)
		'
		--IF ISNULL(@source_deal_detail_ids, '') <> ''
		--	SET @sql_where=' AND sdd.source_deal_detail_id in('+@source_deal_detail_ids+')'

		--SET @sql_stmt=@sql_stmt+@sql_where
	END
	
	EXEC(@sql_stmt)
	
	IF @call_from_sale_deal = 1
	BEGIN
		UPDATE sdh 
		SET sdh.close_reference_id = @original_deal_id 
		FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd 
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN #deals_count dc 
			ON dc.source_deal_detail_id = sdd.source_deal_detail_id
	END
	--ELSE
	--BEGIN
	--	UPDATE sdh 
	--	SET sdh.close_reference_id = sdh.source_deal_header_id 
	--	FROM source_deal_header sdh 
	--	INNER JOIN source_deal_detail sdd 
	--		ON sdh.source_deal_header_id = sdd.source_deal_header_id
	--	INNER JOIN #deals_count dc 
	--		ON dc.source_deal_detail_id = sdd.source_deal_detail_id
	--END
	
	IF @commit_type <> 'a'
	BEGIN
		SET @sql_stmt = '
		UPDATE sdd_allocated
			SET sdd_allocated.volume_left = sdd_allocated.volume_left - (sdd_allocated.deal_volume/sdd.deal_volume)*ISNULL(rs_tmp.volume,0)
		FROM
			source_deal_detail sdd 
			INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
			INNER JOIN source_deal_header sdh_offset ON sdh.source_deal_header_id = sdh_offset.close_reference_id
			INNER JOIN source_deal_header sdh_allocated ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
			INNER JOIN source_deal_detail sdd_allocated ON sdh_allocated.source_deal_header_id = sdd_allocated.source_deal_header_id
			INNER JOIN (
				SELECT SUM(volume) volume, source_deal_detail_id  
				FROM #deals_count tmp 
				group by source_deal_detail_id
			) rs_tmp ON rs_tmp.[source_deal_detail_id] = sdd.source_deal_detail_id
			WHERE 1 = 1'

		--IF @source_deal_detail_ids is not null AND @source_deal_detail_ids<>''
	--			SET @sql_where=' AND sd.source_deal_detail_id in(' + @source_deal_detail_ids + ')'

		IF @assign_id IS NOT NULL AND @assign_id <> ''
			SET @sql_where2 = ' AND tmp.assign_id in(' + @assign_id + ')'
			
		SET @sql_stmt = @sql_stmt + @sql_where2
		
		EXEC (@sql_stmt)
	END
		
			
	
--	SET @sql_stmt = '
--	UPDATE sdd
--		SET sdd.volume_left = sdd.volume_left - ISNULL(rs_tmp.[volume], 0)
--	--SELECT sdd.source_deal_header_id, sdd.source_deal_detail_id, sdd.volume_left, ISNULL(rs_tmp.[volume], 0), sdd.volume_left - ISNULL(rs_tmp.[volume], 0)
--	FROM
--		source_deal_detail sdd 
--		INNER JOIN (
--			SELECT SUM(volume) volume, source_deal_detail_id  
--			FROM #deals_count tmp 
--			group by source_deal_detail_id
--		) rs_tmp ON rs_tmp.[source_deal_detail_id] = sdd.source_deal_detail_id
--		WHERE 1 = 1 '

--	--IF @source_deal_detail_ids is not null AND @source_deal_detail_ids<>''
----			SET @sql_where=' AND sd.source_deal_detail_id in(' + @source_deal_detail_ids + ')'

--	IF @assign_id IS NOT NULL AND @assign_id <> ''
--		SET @sql_where2 = ' AND tmp.assign_id in(' + @assign_id + ')'
		
--	SET @sql_stmt = @sql_stmt + @sql_where2
	
--	EXEC (@sql_stmt)
		
	IF @call_from_old = 3
	BEGIN
		SET @desc = ''
	END
	ELSE
	BEGIN
		SET @desc = (SELECT code FROM static_data_value WHERE value_id = @assignment_type) +
		CASE WHEN(@assignment_type = 5173) THEN ' Category.' ELSE		
		' Category for ' +  ISNULL((SELECT code FROM static_data_value WHERE value_id = @assigned_state), 'NoState') +
		    ' State for Year ' + CAST(@compliance_year AS VARCHAR(10)) 
		END 
		+
		CASE WHEN(@assignment_type =  5173) THEN ' And sales position for ' 
			+ (SELECT counterparty_name 
				FROM source_counterparty 
				WHERE source_counterparty_id = @assigned_counterparty) + ' automatically created' ELSE '' 
		END
	END
	
			
			
	IF @template_id IS NULL
	BEGIN
		--select * from #deals_count
		INSERT INTO gis_certificate(source_deal_header_id, gis_certificate_number_from, gis_certificate_number_to, certificate_number_from_int, certificate_number_to_int, gis_cert_date)
		SELECT sdd_recs.source_deal_detail_id, 
		CASE WHEN ISNUMERIC(substring(gc_assign.gis_certificate_number_from,len(gc_assign.gis_certificate_number_from)-charindex('-',reverse(gc_assign.gis_certificate_number_from))+2,LEN(gc_assign.gis_certificate_number_from))) = 1
		THEN
		SUBSTRING(gc_assign.gis_certificate_number_from,0,LEN(gc_assign.gis_certificate_number_from) - CHARINDEX('-',REVERSE(gc_assign.gis_certificate_number_from)) + 2) 
		+ CAST((certificate_number_from_int + (sdd_recs.deal_volume - sdd_recs.volume_left)) AS VARCHAR)
		ELSE gc_assign.gis_certificate_number_from END
		, CASE WHEN ISNUMERIC(substring(gc_assign.gis_certificate_number_to,len(gc_assign.gis_certificate_number_to)-charindex('-',reverse(gc_assign.gis_certificate_number_to))+2,LEN(gc_assign.gis_certificate_number_to))) = 1
		THEN 
		SUBSTRING(gc_assign.gis_certificate_number_from,0,LEN(gc_assign.gis_certificate_number_from) - CHARINDEX('-',REVERSE(gc_assign.gis_certificate_number_from)) + 2) 
		+ CAST((certificate_number_from_int + (sdd_recs.deal_volume - sdd_recs.volume_left) + dc.volume) AS VARCHAR)
		ELSE gc_assign.gis_certificate_number_to END ,
			(certificate_number_from_int + (sdd_recs.deal_volume - sdd_recs.volume_left)) , (certificate_number_from_int + (sdd_recs.deal_volume - sdd_recs.volume_left) + dc.volume) 
		, GETDATE()		
			FROM 
			#deals_count dc 
		INNER JOIN source_deal_detail sdd_assign ON sdd_assign.source_deal_detail_id = dc.source_deal_detail_id
		INNER JOIN gis_certificate gc_assign ON gc_assign.source_deal_header_id = sdd_assign.source_deal_detail_id
			AND gc_assign.state_value_id = dc.state_value_id
		INNER JOIN assignment_audit aa ON aa.source_deal_header_id_from = sdd_assign.source_deal_detail_id
			AND aa.Tier = dc.tier
		INNER JOIN source_deal_detail sdd_recs ON sdd_recs.source_deal_detail_id = aa.source_deal_header_id
	END
		
	--return

	INSERT INTO rec_assign_log(process_id, code, [Module], [source], [type], [description], source_deal_header_id, source_deal_header_id_sale_from)  
	SELECT DISTINCT @process_id, 'Success', 'Credits/Allowance Assign', 'spa_assign_rec_deals', 'Status'
		, 'Deal ' + CAST(sdd.source_deal_header_id AS VARCHAR(25)) + ' assigned to ' + @desc 
		, sdh.source_deal_header_id, sdd.source_deal_header_id
	FROM  #deals_count tmp
	INNER JOIN source_deal_detail sdd ON tmp.source_deal_detail_id = sdd.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdh.ext_deal_id = CAST(sdd.source_deal_header_id AS VARCHAR(25))
	INNER JOIN source_deal_detail sdd1 ON sdd1.source_deal_header_id = sdh.source_deal_header_id	
END
END	--assignment type <> 5149



IF @unassign = 1  
BEGIN


--LOG
--IMP: source_deal_header_id AND source_deal_header_id_from in table unassignment_audit actually stored deal detail ids.
--TODO: Handle source_deal_detail volume update without using trigger
	
	
--SET @sql_stmt = '
--	UPDATE sdd_allocated
--		SET sdd_allocated.volume_left = sdd_allocated.volume_left + (sdd_allocated.deal_volume/original_sdd.deal_volume)*ISNULL(rs_tmp.volume,0)
--	FROM
--		source_deal_detail sdd 
--		INNER JOIN assignment_audit aa ON aa.source_deal_header_id = sdd.source_deal_detail_id
--		INNER JOIN source_deal_detail original_sdd ON original_sdd.source_deal_detail_id = aa.source_deal_header_id_from
--		INNER JOIN source_deal_header original_sdh ON original_sdh.source_deal_header_id = original_sdd.source_deal_header_id
--		INNER JOIN source_deal_header sdh_offset ON original_sdh.source_deal_header_id = sdh_offset.close_reference_id
--		INNER JOIN source_deal_header sdh_allocated ON sdh_offset.source_deal_header_id = sdh_allocated.close_reference_id
--		INNER JOIN source_deal_detail sdd_allocated ON sdh_allocated.source_deal_header_id = sdd_allocated.source_deal_header_id
--		INNER JOIN (
--			SELECT SUM(volume) volume, source_deal_detail_id  
--			FROM #deals_count tmp 
--			group by source_deal_detail_id
--		) rs_tmp ON rs_tmp.[source_deal_detail_id] = sdd.source_deal_detail_id
--		WHERE 1 = 1'

--	--IF @source_deal_detail_ids is not null AND @source_deal_detail_ids<>''
-- --			SET @sql_where=' AND sd.source_deal_detail_id in(' + @source_deal_detail_ids + ')'

--
--EXEC (@sql_stmt)
	
UPDATE sdd SET sdd.volume_left = sdd.volume_left + g.volume
FROM source_deal_detail sdd
INNER JOIN
(
	SELECT SUM(dc.volume) volume, sdd.source_deal_detail_id
	FROM assignment_audit aa
	INNER JOIN #deals_count dc ON aa.assignment_id = dc.assign_id
	INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = aa.source_deal_header_id_from
	GROUP BY sdd.source_deal_detail_id
) g ON g.source_deal_detail_id = sdd.source_deal_detail_id
	
DELETE aa FROM assignment_audit aa INNER JOIN #deals_count dc ON dc.assign_id = aa.assignment_id
WHERE aa.assigned_volume = dc.volume
	
UPDATE aa SET aa.assigned_volume = aa.assigned_volume - dc.volume 
FROM assignment_audit aa INNER JOIN #deals_count dc ON dc.assign_id = aa.assignment_id
WHERE dc.volume < aa.assigned_volume
	
UPDATE sdd SET sdd.volume_left = sdd.volume_left - dc.volume
FROM source_deal_detail sdd
INNER JOIN assignment_audit aa ON aa.source_deal_header_id = sdd.source_deal_detail_id
INNER JOIN #deals_count dc ON dc.source_deal_detail_id = sdd.source_deal_detail_id
	AND dc.tier = aa.tier
WHERE dc.volume < sdd.volume_left
	
IF OBJECT_ID('tempdb..#source_deal_header_id') IS NOT NULL
	DROP TABLE #source_deal_header_id
	
SELECT sdd.source_deal_header_id INTO #source_deal_header_id 
FROM source_deal_detail sdd
--INNER JOIN assignment_audit aa ON aa.source_deal_header_id = sdd.source_deal_detail_id 
INNER JOIN #deals_count dc ON dc.source_deal_detail_id = sdd.source_deal_detail_id
	--AND dc.tier = aa.tier
WHERE sdd.volume_left = dc.volume
	
DELETE gc FROM gis_certificate gc 
INNER JOIN source_deal_detail sdd ON gc.source_deal_header_id = sdd.source_deal_detail_id
INNER JOIN #source_deal_header_id sdhi ON sdhi.source_deal_header_id = sdd.source_deal_header_id

DELETE sdd FROM source_deal_detail sdd 
inner join #source_deal_header_id isdh ON isdh.source_deal_header_id = sdd.source_deal_header_id

DELETE uddf FROM user_defined_deal_fields uddf 
INNER JOIN #source_deal_header_id sdhi ON sdhi.source_deal_header_id = uddf.source_deal_header_id

DELETE csr FROM confirm_status_recent csr
INNER JOIN #source_deal_header_id sdhi ON sdhi.source_deal_header_id = csr.source_deal_header_id

DELETE cs FROM confirm_status cs
INNER JOIN #source_deal_header_id sdhi ON sdhi.source_deal_header_id = cs.source_deal_header_id

DELETE sdh FROM source_deal_header sdh 
inner join #source_deal_header_id isdh ON isdh.source_deal_header_id = sdh.source_deal_header_id
	
	
	
--SET @sql_stmt = '
--	INSERT INTO unassignment_audit
--	(assignment_type, assigned_volume, source_deal_header_id, source_deal_header_id_from, compliance_year, state_value_id
--		, assigned_date, assigned_by, cert_from, cert_to)
--	SELECT
--		' + CAST(@assignment_type AS VARCHAR(25)) + ', assign.[assigned_volume], sdd.source_deal_detail_id 
--		, assign.[source_deal_header_id_from], ' + CASE WHEN CAST(@assignment_type AS VARCHAR(25)) <> 5173 
--			THEN CAST(@compliance_year AS VARCHAR(10)) ELSE 'NULL' END + '
--		, ' + CASE WHEN (@assigned_state IS NULL) THEN 'NULL' ELSE CAST(@assigned_state AS VARCHAR(25)) END  + '
--		, ''' + dbo.FNAGetSQLStandardDate(@assigned_date) + ''', dbo.FNADBUser(), tmp.cert_to-assign.[assigned_volume] + 1, tmp.cert_to
--	FROM
--		#deals_count tmp 
--		INNER JOIN source_deal_detail sdd ON tmp.source_deal_detail_id = sdd.source_deal_detail_id
--		INNER JOIN assignment_audit assign ON sdd.[source_deal_detail_id] = assign.source_deal_header_id
--		WHERE 1 = 1 
--			AND tmp.assign_id = assign.assignment_id 
--	'
--	/* IF ISNULL(@source_deal_detail_ids, '') <> ''
--		SET @sql_where=' AND tmp.source_deal_detail in('+@source_deal_detail_ids+')' */

--IF @assign_id IS NOT NULL AND @assign_id <> ''
--	SET @sql_where2 = ' AND tmp.assign_id in(' + @assign_id + ')'

--SET @sql_stmt = @sql_stmt + @sql_where2
--EXEC(@sql_stmt)

--SET @sql_stmt='
--	UPDATE sdd
--		SET sdd.volume_left = sdd.volume_left - rs_tmp.[volume]
--	--SELECT sdd.volume_left, ISNULL(rs_tmp.[volume], 0) assigned, sdd.volume_left - ISNULL(rs_tmp.[volume], 0) final
--	FROM
--		source_deal_detail sdd 
--		CROSS APPLY (
--			SELECT SUM(volume) volume 
--			FROM #deals_count tmp 
--			WHERE tmp.[source_deal_detail_id] = sdd.source_deal_detail_id
--		) rs_tmp 
--		WHERE 1 = 1 
--			AND rs_tmp.[volume] IS NOT NULL'	--prevent updating unchanged rows

----IF @source_deal_detail_ids is not null AND @source_deal_detail_ids<>''
---- 		SET @sql_where=' AND sd.source_deal_detail_id in(' + @source_deal_detail_ids + ')'

--IF @assign_id IS NOT NULL AND @assign_id <> ''
--		SET @sql_where2 = ' AND tmp.assign_id in(' + @assign_id + ')'
	
--SET @sql_stmt = @sql_stmt + @sql_where2
--
--EXEC (@sql_stmt)

--IF @@ERROR = 0
--BEGIN
--	--IMP: source_deal_header_id AND source_deal_header_id_from in table unassignment_audit actually stored deal detail ids.
--	--TODO: Handle source_deal_detail volume update without using trigger
--	SET @sql_stmt = '
--		INSERT INTO unassignment_audit
--		(assignment_type, assigned_volume, source_deal_header_id, source_deal_header_id_from, compliance_year, state_value_id
--			, assigned_date, assigned_by, cert_from, cert_to)
--		SELECT
--			' + CAST(@assignment_type AS VARCHAR(25)) + ', assign.[assigned_volume], sdd.source_deal_detail_id 
--			, assign.[source_deal_header_id_from], ' + CASE WHEN CAST(@assignment_type AS VARCHAR(25)) <> 5173 
--				THEN CAST(@compliance_year AS VARCHAR(10)) ELSE 'NULL' END + '
--			, ' + CASE WHEN (@assigned_state IS NULL) THEN 'NULL' ELSE CAST(@assigned_state AS VARCHAR(25)) END  + '
--			, ''' + dbo.FNAGetSQLStandardDate(@assigned_date) + ''', dbo.FNADBUser(), tmp.cert_to-assign.[assigned_volume] + 1, tmp.cert_to
--		FROM
--			#deals_count tmp 
--			INNER JOIN source_deal_detail sdd ON tmp.source_deal_detail_id = sdd.source_deal_detail_id
--			INNER JOIN assignment_audit assign ON sdd.[source_deal_detail_id] = assign.source_deal_header_id
--			WHERE 1 = 1 
--				AND tmp.assign_id = assign.assignment_id 
--		'
--	--IF ISNULL(@source_deal_detail_ids, '') <> ''
--	--	SET @sql_where = ' AND tmp.source_deal_detail_id IN (' + @source_deal_detail_ids + ')'

--	IF @assign_id IS NOT NULL AND @assign_id <> ''
--		SET @sql_where2 = ' AND tmp.assign_id in(' + @assign_id + ')'

--	SET @sql_stmt = @sql_stmt + @sql_where2
--	EXEC(@sql_stmt)

	--IMP: source_deal_header_id AND source_deal_header_id_from in table assignment_audit actually stored deal detail ids.
	--SET @sql_stmt = '
	--	UPDATE assign
	--		SET assign.assigned_volume = assign.assigned_volume - tmp.[volume] 
	--			, assign.cert_from = tmp.cert_from - (assign.assigned_volume - tmp.[volume]) 
	--			, assign.cert_to = tmp.cert_from - 1
	--	FROM
	--		assignment_audit assign 
	--		INNER JOIN source_deal_detail sdd ON sdd.source_deal_detail_id = assign.source_deal_header_id
	--		INNER JOIN #deals_count tmp ON sdd.source_deal_detail_id = tmp.[source_deal_detail_id]
	--		WHERE 1 = 1 
	--			AND tmp.assign_id = assign.assignment_id'
				
	----IF @source_deal_detail_ids is not null AND @source_deal_detail_ids <> ''
----			SET @sql_where = ' AND tmp.source_deal_detail_id IN (' + @source_deal_detail_ids + ')'

	--IF @assign_id IS NOT NULL AND @assign_id <> ''
	--	SET @sql_where2 = ' AND tmp.assign_id IN (' + @assign_id + ')'
		
	--SET @sql_stmt = @sql_stmt + @sql_where2
	--EXEC(@sql_stmt)

	SET @desc = 'Banked (Inventory)'+ ' Category.' 

--	INSERT INTO rec_assign_log(process_id, code, module, [source], type, [description], source_deal_header_id, 
--	source_deal_header_id_sale_from)  
--	SELECT 	@process_id, 'Success', 'Credits/Allowance Assign', 'spa_assign_rec_deals', 'Status', 
--		'Deal ' + CAST(dc.source_deal_header_id AS VARCHAR)  + ' assigned to ' + @desc, 
--		sd.source_deal_detail_id, sdh.ext_deal_id
--	FROM  #deals_count dc INNER JOIN source_deal_detail sd 
--	ON dc.source_deal_header_id=sd.source_deal_detail_id
--	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id=sd.source_deal_header_id 

	/****************Source Deal Header ID selected instead of Source Deal Detail ID*******/
	INSERT INTO rec_assign_log(process_id, code, [module], [source], [type], [description], source_deal_header_id, 
	source_deal_header_id_sale_from)  
	SELECT DISTINCT	@process_id, 'Success', 'Credits/Allowance Assign', 'spa_assign_rec_deals', 'Status' 
		, 'Deal ' + CAST(sdh.source_deal_header_id AS VARCHAR(25)) + ' assigned to ' + @desc 
		, sdh.source_deal_header_id, sdh.ext_deal_id
	FROM #deals_count dc 
	INNER JOIN source_deal_detail sd ON dc.source_deal_detail_id = sd.source_deal_detail_id
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sd.source_deal_header_id 	
--END
END	--unassignment log

IF @unassign = 0
BEGIN
IF @call_from_old = 3
BEGIN
	SET @desc = CAST(CAST((
	SELECT SUM(tmp.volume)
		FROM #deals_count tmp 
		INNER JOIN source_deal_detail sdd ON tmp.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id) AS INT) AS VARCHAR(40)) 
		+ ' ' + (select uom_name from source_uom where source_uom_id = @uom) + '  assigned to ' 
		+ (SELECT code FROM static_data_value WHERE value_id = @assignment_type) 
		+  ' Category.' 
END
ELSE
BEGIN
	SET @desc = CAST(CAST((
	SELECT SUM(tmp.volume)
		FROM #deals_count tmp 
		INNER JOIN source_deal_detail sdd ON tmp.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id) AS INT) AS VARCHAR(40)) 
		+ ' ' + (@uom) + '  assigned to ' 
		+ (SELECT code FROM static_data_value WHERE value_id = @assignment_type) 
		+ CASE WHEN(@assignment_type =  5173) THEN ' Category.' 
			ELSE ' Category for ' + ISNULL(@list_of_states, 'NoState') 
			+ ' State for Year ' + CAST(@compliance_year AS VARCHAR(10)) + ' ON ' + dbo.FNADateFormat(@assigned_date) 
			END 
		+ CASE WHEN(@assignment_type =  5173) THEN ' And sales position for '
			+ (SELECT counterparty_name 
				FROM source_counterparty 
				WHERE source_counterparty_id = @assigned_counterparty) + ' automatically created' 
			ELSE '' 
			END
END
END
ELSE
BEGIN
SET @desc = CAST(CAST((
	SELECT SUM(tmp.volume)
		FROM #deals_count tmp 
		INNER JOIN source_deal_detail sdd ON tmp.source_deal_detail_id = sdd.source_deal_detail_id
		INNER JOIN source_deal_header sdh ON sdd.source_deal_header_id = sdh.source_deal_header_id) AS INT) AS VARCHAR(40)) 
		+ ' ' + (@uom) + ' assigned to Banked (Inventory) '
		+ ' Category ON ' + dbo.FNADateFormat(@assigned_date) 
		+ CASE WHEN(@assignment_type =  5173) THEN ' . And sales position were automatically deleted' ELSE '' END
END

SET @desc = '<a target="_blank" href="' + 
'./dev/spa_html.php?__user_name__=' + dbo.FNADBUser() + 
'&enable_paging=true&spa=exec spa_get_rec_assign_log ''' + @process_id + '''' + 
'">' + 
@desc + 
'.</a>'

IF @unassign = 0
BEGIN
	EXEC spa_message_board 'i', @user_name, NULL, 'Assign Credits/Allowance', @desc, '', '', 's', @job_name
	
	-- Trigger Alert/ Workflow - Post Assign
	IF @committed = 0
	BEGIN
		DECLARE @alert_process_id VARCHAR(200) = dbo.FNAGetNewID()
		DECLARE @alert_process_table VARCHAR(500) = 'adiha_process.dbo.alert_assign_transaction_' + @alert_process_id + '_aat'

		DECLARE @sql_st VARCHAR(MAX)
		
		SET @sql_st = 'CREATE TABLE ' + @alert_process_table + ' (
							assignment_type    INT
						)
	
						INSERT INTO ' + @alert_process_table + '(assignment_type)
						SELECT ' + CAST(@assignment_type AS VARCHAR(100))

		EXEC(@sql_st)

		EXEC spa_register_event 20613, 20539, @alert_process_table, 0, @alert_process_id
	END	
END
ELSE
BEGIN
	EXEC spa_message_board 'i', @user_name, NULL, 'Assign Credits/Allowance', @desc, '', '', 's', @job_name
END

IF @@ERROR <> 0
BEGIN	
SET @sql_stmt = 'Failed to assign Credits/Allowance: ' + @source_deal_detail_ids
EXEC spa_ErrorHandler @@ERROR, 'Assign Credits/Allowance Deals', 'spa_assign_rec_deals', 'DB Error', @sql_stmt, ''
END
ELSE
BEGIN
IF @unassign = 0
	SET @sql_stmt = 'Successfully ' + @assign_commit_label + ' Credits '  +
		CASE WHEN(@assignment_type = 5173) THEN ', AND sales position created.' ELSE '' END
ELSE
	SET @sql_stmt = 'Successfully ' + @unassign_commit_label + ' Credits ' +
		CASE WHEN(@assignment_type = 5173) THEN ', AND sales position deleted.' ELSE '' END

EXEC spa_ErrorHandler 0, 'Assign Credits/Allowance Deals', 'spa_assign_rec_deals', 'Success', @sql_stmt, ''
END
