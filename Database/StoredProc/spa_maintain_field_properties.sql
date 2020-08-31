/****** Object:  StoredProcedure [dbo].[spa_maintain_field_properties]    Script Date: 01/30/2012 03:26:07 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_maintain_field_properties]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_maintain_field_properties]
GO

/****** Object:  StoredProcedure [dbo].[spa_maintain_field_properties]    Script Date: 01/30/2012 03:26:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE  PROC [dbo].[spa_maintain_field_properties]
	@flag CHAR(1),
	@field_template_detail_id VARCHAR(5000)= NULL, 
	@field_template_id INT = NULL ,
	@field_group_id INT = NULL,
	@field_id_selected VARCHAR(MAX) = NULL,
	@seq_no_fields VARCHAR(MAX) = NULL,
	@is_disable CHAR(1) = NULL,
	@insert_required CHAR(1) = NULL,
	@update_required CHAR(1) = NULL,
	@field_caption VARCHAR(150) = NULL,
	@default_value VARCHAR(150) = NULL,
	@min_value FLOAT = NULL,
	@max_value FLOAT = NULL,
	@validation_id INT = NULL,
	@hide_control CHAR(1) = NULL,
	@header_detail CHAR(1) = NULL,
	@display_format INT = NULL,
	@deal_update_seq_no_fields VARCHAR(MAX) = NULL,
	@buy_label VARCHAR(500) = NULL,
	@sell_label VARCHAR(500) = NULL,
	@value_required CHAR(1) = NULL,
	@detail_group_id INT = NULL
AS


DECLARE @max_seq INT
DECLARE @deal_update_max_seq_show INT
DECLARE @deal_update_max_seq_hide INT

DECLARE @row_count INT 
--select @header_detail

IF @flag = 'i'
BEGIN 
	--select @field_id_selected,@max_seq,@field_template_id
	IF @header_detail = 'd' AND @detail_group_id IS NULL
	BEGIN		
	    --- Detail  GRID Max Seq No
	    SELECT @max_seq = MAX(seq_no)
	    FROM   maintain_field_template_detail
	    WHERE  field_template_id = @field_template_id
	           AND field_group_id IS NULL AND detail_group_id IS NULL
	END
	ELSE IF @header_detail = 'd'
	BEGIN
		--- Detail COST tab Max Seq No
	    SELECT @max_seq = MAX(seq_no)
	    FROM   maintain_field_template_detail
	    WHERE  field_template_id = @field_template_id
	           AND detail_group_id IS NOT NULL
	END
	ELSE
	    --- Header Max Seq NO
	    SELECT @max_seq = ISNULL(MAX(seq_no), 0)
	    FROM   maintain_field_template_detail
	    WHERE  field_template_id = @field_template_id
	           AND field_group_id = @field_group_id
	
	SELECT @deal_update_max_seq_show = MAX(deal_update_seq_no)
	FROM   maintain_field_template_detail
	WHERE  field_template_id = @field_template_id
	AND field_group_id IS NULL AND update_required = 'y'
	
	SELECT @deal_update_max_seq_hide = MAX(deal_update_seq_no)
	FROM   maintain_field_template_detail
	WHERE  field_template_id = @field_template_id
	AND field_group_id IS NULL AND update_required = 'n'
	
	INSERT maintain_field_template_detail
	  (
	    field_template_id,
	    field_group_id,
	    field_id,
	    udf_or_system,
	    seq_no,
		is_disable,
	    hide_control,
	    field_caption,
	    default_value,
	    deal_update_seq_no,
	    insert_required,
	    update_required,
	    detail_group_id,
	    show_in_form
	    
	  )
	SELECT @field_template_id,
	       @field_group_id,
	       mfd.field_id,
	       's',
	       ROW_NUMBER() OVER(ORDER BY s.item) + @max_seq,
		   @is_disable,
		   ISNULL(@hide_control, is_hidden),
	       mfd.default_label,
	       default_value,
	       CASE 
	            WHEN mfd.header_detail = 'h' THEN NULL
	            ELSE CASE 
	                      WHEN mfd.is_hidden = 'y' THEN ROW_NUMBER() OVER(ORDER BY s.item) 
	                           + @deal_update_max_seq_hide
	                      ELSE ROW_NUMBER() OVER(ORDER BY s.item) + @deal_update_max_seq_show
	                 END
	       END,
	       ISNULL(@insert_required,mfd.insert_required),
	       ISNULL(@update_required,mfd.update_required),
	       @detail_group_id,
	       CASE WHEN s.item IN ('origin','form', 'organic', 'attribute1', 'attribute2','attribute3', 'attribute4', 'attribute5') THEN 'y' ELSE 'n' END
	FROM   SplitCommaSeperatedValues(@field_id_selected) s
	       JOIN maintain_field_deal mfd
	            ON  s.item = mfd.farrms_field_id
	            AND mfd.header_detail = ISNULL(@header_detail, 'd')

	SET @row_count = @@ROWCOUNT
	SET @max_seq = @max_seq + @row_count
	
	
	SET @field_id_selected = REPLACE(@field_id_selected, 'UDF___', '')
	
	IF @header_detail = 'd' AND @detail_group_id IS NULL
	    --- Detail  Max Seq No
	    SELECT @max_seq = MAX(seq_no)
	    FROM   maintain_field_template_detail
	    WHERE	field_template_id = @field_template_id
	    AND field_group_id IS NULL AND detail_group_id IS NULL
	ELSE IF @header_detail = 'd'
	BEGIN
		--- Detail COST tab Max Seq No
	    SELECT @max_seq = MAX(seq_no)
	    FROM   maintain_field_template_detail
	    WHERE  field_template_id = @field_template_id
	           AND field_group_id IS NULL AND detail_group_id IS NOT NULL
	END
	ELSE
	    --- Header Max Seq NO
	    SELECT @max_seq = MAX(seq_no)
	    FROM   maintain_field_template_detail
	    WHERE  field_template_id = @field_template_id
	           AND field_group_id = @field_group_id
	
	SELECT @deal_update_max_seq_show = MAX(deal_update_seq_no)
	FROM   maintain_field_template_detail
	WHERE  field_template_id = @field_template_id
	AND field_group_id IS NULL AND update_required = 'y'
	
	SELECT @deal_update_max_seq_hide = MAX(deal_update_seq_no)
	FROM   maintain_field_template_detail
	WHERE  field_template_id = @field_template_id
	AND field_group_id IS NULL AND update_required = 'n'
	
	-- adding udf fields
	INSERT maintain_field_template_detail
	  (
	    field_template_id,
	    field_group_id,
	    field_id,
	    udf_or_system,
	    seq_no,
	    insert_required,
	    update_required,
	    field_caption,
	    default_value,
	    deal_update_seq_no,
	    hide_control,
	    detail_group_id
	  )
	SELECT @field_template_id,
	       @field_group_id,
	       udf.udf_template_id,
	       'u',
	       ROW_NUMBER() OVER(ORDER BY s.item) + @max_seq,
	       'y',
	       'y',
	       udf.Field_label,
	       udf.default_value,
	       CASE 
	            WHEN udf.udf_type = 'h' THEN NULL
	            ELSE ROW_NUMBER() OVER(ORDER BY s.item) 
	                 + @deal_update_max_seq_show --ufd is always show
	       END,
	       'n',
	       @detail_group_id
	FROM   SplitCommaSeperatedValues(@field_id_selected) s
	       JOIN user_defined_fields_template udf
	            ON  s.item = CAST(udf.udf_template_id AS VARCHAR(20))

	SELECT udf.*,
	       st.template_id INTO #tempUDF
	FROM   dbo.source_deal_header_template st
	       JOIN maintain_field_template_detail ft
	            ON  st.field_template_id = ft.field_template_id
	       JOIN user_defined_fields_template udf
	            ON  udf.udf_template_id = ft.field_id
	WHERE  udf_or_system = 'u'
	       AND ft.field_template_id = @field_template_id --AND udf.udf_type='h'
	ORDER BY
	       st.template_id
	
	--insert added header udf in all previous deals templates
	INSERT INTO [user_defined_deal_fields_template_main]
	  (
	    template_id,
	    field_name,
	    Field_label,
	    Field_type,
	    data_type,
	    is_required,
	    sql_string,
	    udf_type,
	    sequence,
	    field_size,
	    field_id,	    
	    book_id,
	    udf_group,
	    udf_tabgroup,
	    formula_id,
	    internal_field_type,
	    currency_field_id,
	    udf_user_field_id,
	    leg,
	    default_value
	  )
	SELECT sdht.template_id,
	       udft.field_name,
	       udft.field_label,
	       udft.field_type,
	       udft.data_type,
	       udft.is_required,
	       ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string) sql_string,
	       udft.udf_type,
	       udft.sequence,
	       udft.field_size,
	       udft.field_id,
	       udft.book_id,
	       udft.udf_group,
	       udft.udf_tabgroup,
	       udft.formula_id,
	       udft.internal_field_type,
	       NULL currency_field_id,
	       udft.udf_template_id udf_user_field_id,	       
	       udft.leg leg,
	       udft.default_value
	FROM   SplitCommaSeperatedValues(@field_id_selected) s
	       JOIN user_defined_fields_template udft
	            ON  s.item = CAST(udft.udf_template_id AS VARCHAR)
	       CROSS  JOIN source_deal_header_template sdht
		   LEFT JOIN udf_data_source uds 
				ON uds.udf_data_source_id = udft.data_source_type_id
	WHERE  sdht.field_template_id = @field_template_id
			AND udft.udf_type = 'h' 	
	       AND udft.udf_template_id NOT IN (SELECT uddft.udf_user_field_id
	                                        FROM   SplitCommaSeperatedValues(@field_id_selected) s
	                                               INNER JOIN user_defined_fields_template udft
	                                                    ON  s.item = CAST(udft.udf_template_id AS VARCHAR)
	                                               INNER JOIN user_defined_deal_fields_template_main uddft
	                                                    ON  uddft.udf_user_field_id = udft.udf_template_id
	                                               INNER JOIN source_deal_header_template sdht
	                                                    ON  sdht.template_id = uddft.template_id
	                                        WHERE  sdht.field_template_id = @field_template_id)
	ORDER BY
	       sdht.template_id
	
	CREATE TABLE #temp_deal_template_leg (
		id INT IDENTITY,
		template_id INT,
		leg INT 
	)
	
	INSERT INTO #temp_deal_template_leg(template_id, leg)
	SELECT sdht.template_id, leg FROM source_deal_header_template sdht
	INNER JOIN source_deal_detail_template sddt
	ON sdht.template_id = sddt.template_id 
	WHERE sdht.field_template_id = @field_template_id
	
	
	--insert added detail udf in all previous deals templates
	INSERT INTO [user_defined_deal_fields_template_main]
	  (
	    template_id,
	    field_name,
	    Field_label,
	    Field_type,
	    data_type,
	    is_required,
	    sql_string,
	    udf_type,
	    sequence,
	    field_size,
	    field_id,
	    default_value,
	    book_id,
	    udf_group,
	    udf_tabgroup,
	    formula_id,
	    internal_field_type,
	    currency_field_id,
	    udf_user_field_id,
	    leg
	  )
	SELECT sdht.template_id,
	       udft.field_name,
	       udft.field_label,
	       udft.field_type,
	       udft.data_type,
	       udft.is_required,
	       ISNULL(NULLIF(udft.sql_string, ''), uds.sql_string) sql_string,
	       udft.udf_type,
	       udft.sequence,
	       udft.field_size,
	       udft.field_id,
	       udft.default_value,
	       udft.book_id,
	       udft.udf_group,
	       udft.udf_tabgroup,
	       udft.formula_id,
	       udft.internal_field_type,
	       NULL currency_field_id,
	       udft.udf_template_id udf_user_field_id,	       
	       tdtl.leg leg
	FROM   SplitCommaSeperatedValues(@field_id_selected) s
	       JOIN user_defined_fields_template udft
	            ON  s.item = CAST(udft.udf_template_id AS VARCHAR)
	       CROSS  JOIN source_deal_header_template sdht
	       INNER JOIN #temp_deal_template_leg tdtl 
				ON tdtl.template_id = sdht.template_id
			LEFT JOIN udf_data_source uds 
				ON uds.udf_data_source_id = udft.data_source_type_id	       
	WHERE  sdht.field_template_id = @field_template_id
			AND udft.udf_type = 'd' 	
	       AND udft.udf_template_id NOT IN (SELECT uddft.udf_user_field_id
	                                        FROM   SplitCommaSeperatedValues(@field_id_selected) s
	                                               INNER JOIN user_defined_fields_template udft
	                                                    ON  s.item = CAST(udft.udf_template_id AS VARCHAR)
	                                               INNER JOIN user_defined_deal_fields_template_main uddft
	                                                    ON  uddft.udf_user_field_id = udft.udf_template_id
	                                               INNER JOIN source_deal_header_template sdht
	                                                    ON  sdht.template_id = uddft.template_id
	                                        WHERE  sdht.field_template_id = @field_template_id)
	ORDER BY
	       sdht.template_id
	

	DECLARE @template_ids VARCHAR(5000), @sql_string VARCHAR(5000)
	
	SELECT @template_ids = COALESCE(@template_ids + ', ', '') + CAST(template_id AS VARCHAR)
	FROM   source_deal_header_template sdht
	WHERE  sdht.field_template_id = @field_template_id


	--insert added header udf in all previous deals
	SET @sql_string = '
	INSERT INTO user_defined_deal_fields
	(		
		source_deal_header_id,
		udf_template_id
	)
	SELECT DISTINCT sdh.source_deal_header_id,
       uddft.udf_template_id
      
	FROM   user_defined_deal_fields_template_main uddft
		   LEFT JOIN user_defined_deal_fields uddf
				ON  uddf.udf_template_id = uddft.udf_template_id				
		   LEFT JOIN source_deal_header sdh
				ON  sdh.template_id = uddft.template_id
	WHERE uddft.udf_type = ''h'' AND uddf.udf_template_id IS NULL 
			AND sdh.template_id IN (' + @template_ids + ')'
	
	EXEC(@sql_string)
	
	--insert added detail udf in all previous deals	
	SET @sql_string = 
	'
	INSERT INTO user_defined_deal_detail_fields
	(		
		source_deal_detail_id,
		udf_template_id
	)
	SELECT DISTINCT sdd.source_deal_detail_id,
       uddft.udf_template_id
      
	FROM   user_defined_deal_fields_template_main uddft
		   LEFT JOIN user_defined_deal_detail_fields udddf
				ON  udddf.udf_template_id = uddft.udf_template_id
		   LEFT JOIN source_deal_header sdh
				ON  sdh.template_id = uddft.template_id
		   LEFT JOIN source_deal_detail sdd
			ON sdh.source_deal_header_id = sdd.source_deal_header_id
	WHERE uddft.udf_type = ''d'' AND udddf.udf_template_id IS NULL  
	AND sdh.template_id IN (' + @template_ids + ')'
	
	EXEC(@sql_string)
	
    EXEC spa_ErrorHandler 0,
		 'Field Template Properties',
		 'spa_maintain_field_properties',
		 'Success',
		 'Field Template successfully inserted.',
		 ''
END 
IF @flag='u'
BEGIN	
	DECLARE @deal_template_id VARCHAR(2000)
	
	SELECT * INTO #temp FROM SplitCommaSeperatedValues(@field_template_detail_id)	

	SELECT @deal_template_id = COALESCE(@deal_template_id + ',', '') + CAST(template_id AS VARCHAR(100))
	FROM   source_deal_header_template sdht
	WHERE  sdht.field_template_id = @field_template_id
	
	SELECT * INTO #temp_deal_template_id FROM SplitCommaSeperatedValues(@deal_template_id)  
	
	SELECT fb.formula_id INTO #temp_formula_id
	FROM   #temp t
	       LEFT JOIN maintain_field_template_detail mftd
	            ON  t.item = mftd.field_template_detail_id
	            AND mftd.udf_or_system = 'u'
	       LEFT JOIN user_defined_fields_template udft
	            ON  udft.udf_template_id = mftd.field_id
	       LEFT JOIN formula_breakdown fb
	            ON  fb.arg1 = cast(udft.field_name AS VARCHAR(50))--udft.field_name
	            AND fb.func_name IN ('UDFValue','FieldValue') 


		IF EXISTS(
		       SELECT 1
		       FROM   maintain_field_template_detail mftd
		              INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
					  INNER JOIN #temp_formula_id tfi
		                   ON  mftd.default_value = tfi.formula_id
		                   AND mftd.udf_or_system = 's'
		                   AND mftd.field_template_id = @field_template_id
					WHERE mfd.farrms_field_id = 'formula_id'
						  AND mfd.header_detail = 'd'
		       UNION ALL
		       SELECT 1
		       FROM   source_deal_detail_template sddt
		              INNER JOIN #temp_formula_id tfi
		                   ON  sddt.formula_id = tfi.formula_id
		              INNER JOIN #temp_deal_template_id tdf
		                   ON  tdf.item = sddt.template_id
		       UNION ALL 
		       SELECT 1
		       FROM   source_deal_detail sdd
		              INNER JOIN #temp_formula_id tfi
		                   ON  sdd.formula_id = tfi.formula_id
		              INNER JOIN source_deal_header sdh
		                   ON  sdd.source_deal_header_id = sdh.source_deal_header_id
		              INNER JOIN #temp_deal_template_id tdf
		                   ON  tdf.item = sdh.template_id
		   )
		BEGIN
		    EXEC spa_ErrorHandler -1,
		         'Maintain UDF Template',
		         'spa_user_defined_fields_template',
		         'error',
		         'UDF is used in formula and cannot be removed.',
		         ''
		    
		    RETURN
		END
	
	
	--delete header udf from deals
	DELETE uddf	
	FROM   user_defined_deal_fields_template_main uddft
	       INNER JOIN user_defined_fields_template udft
	            ON  uddft.field_name = udft.field_name
	       INNER JOIN maintain_field_template_detail mftd
	            ON  udft.udf_template_id = mftd.field_id
	            AND mftd.udf_or_system = 'u'	          
	       INNER JOIN #temp t
	            ON  t.item = mftd.field_template_detail_id
	       INNER JOIN source_deal_header_template sdht
	        ON uddft.template_id = sdht.template_id	
	        INNER JOIN user_defined_deal_fields uddf
	        ON uddf.udf_template_id = uddft.udf_template_id            
	WHERE sdht.field_template_id = @field_template_id  
	
	--delete detail udf from deals
	DELETE udddf	
	FROM   user_defined_deal_fields_template_main uddft
	       INNER JOIN user_defined_fields_template udft
	            ON  uddft.field_name = udft.field_name
	       INNER JOIN maintain_field_template_detail mftd
	            ON  udft.udf_template_id = mftd.field_id
	            AND mftd.udf_or_system = 'u'	          
	       INNER JOIN #temp t
	            ON  t.item = mftd.field_template_detail_id
	       INNER JOIN source_deal_header_template sdht
	        ON uddft.template_id = sdht.template_id	
	        INNER JOIN user_defined_deal_detail_fields udddf
	        ON udddf.udf_template_id = uddft.udf_template_id            
	WHERE sdht.field_template_id = @field_template_id 
	
	--delete udf from deal template
	DELETE uddft	
	FROM   user_defined_deal_fields_template_main uddft
	       INNER JOIN user_defined_fields_template udft
	            ON  uddft.field_name = udft.field_name
	       INNER JOIN maintain_field_template_detail mftd
	            ON  udft.udf_template_id = mftd.field_id
	            AND mftd.udf_or_system = 'u'	          
	       INNER JOIN #temp t
	            ON  t.item = mftd.field_template_detail_id
	       INNER JOIN source_deal_header_template sdht
	        ON uddft.template_id = sdht.template_id	            
	WHERE sdht.field_template_id = @field_template_id     
	  

	--delete udf and standard fields from field template	
	DELETE maintain_field_template_detail
	FROM maintain_field_template_detail mftd 
	JOIN #temp t ON mftd.field_template_detail_id=t.item 
		
	IF @seq_no_fields IS NOT NULL
	BEGIN
	    SELECT * INTO #temp_seq
	    FROM   SplitCommaSeperatedValues(@seq_no_fields)
	    
	    ALTER TABLE #temp_seq 
	    ADD seq_no INT IDENTITY(1, 1)
	    
	    SELECT * INTO #temp_deal_update_seq
	    FROM   SplitCommaSeperatedValues(@deal_update_seq_no_fields)
	    
	    ALTER TABLE #temp_deal_update_seq 
	    ADD deal_update_seq_no INT IDENTITY(1, 1)
	    
	    UPDATE maintain_field_template_detail
	    SET    seq_no = t.seq_no
	    FROM   maintain_field_template_detail mftd
	           JOIN #temp_seq t
	                ON  mftd.field_template_detail_id = t.item 
	    
	    UPDATE maintain_field_template_detail
	    SET    deal_update_seq_no = t.deal_update_seq_no
	    FROM   maintain_field_template_detail mftd
	           JOIN #temp_deal_update_seq t
	                ON  mftd.field_template_detail_id = t.item
	                AND mftd.hide_control = 'n'
	                
 
	END
------------------------------------------------------------

	
	--UPDATE	[user_defined_deal_fields_template]
	--SET		[field_name] = ft.field_name
	--		,[Field_label] = ft.Field_label
	--		,[Field_type] = ft.Field_type
	--		,[data_type] = ft.data_type
	--		,[is_required] = ft.is_required
	--		,[sql_string] = ft.sql_string
	--		,[create_user] = ft.create_user
	--		,[create_ts] = GETDATE()
	--		,[update_user] = ft.update_user
	--		,[update_ts] = GETDATE()
	--		,[udf_type] = ft.udf_type
	--		,[field_size] = ft.field_size
	--		,[field_id] = ft.field_id
	--		,[default_value] = ft.default_value
	--		,[udf_group] = ft.udf_group
	--		,[udf_tabgroup] =ft.udf_tabgroup
	--		,[formula_id] = ft.formula_id
	--FROM	user_defined_deal_fields_template dt 
	--JOIN	#tempUDF ft	ON dt.udf_user_field_id=ft.udf_template_id 
	--	AND dt.template_id=ft.template_id 



	
	--INSERT INTO [user_defined_deal_fields_template]
	--		   ([template_id]
	--		   ,[field_name]
	--		   ,[Field_label]
	--		   ,[Field_type]
	--		   ,[data_type]
	--		   ,[is_required]
	--		   ,[sql_string]
	--		   ,[create_user]
	--		   ,[create_ts]
	--		   ,[update_user]
	--		   ,[update_ts]
	--		   ,[udf_type]
	--		   ,[field_size]
	--		   ,[field_id]
	--		   ,[default_value]
	--		   ,[udf_group]
	--		   ,[udf_tabgroup]
	--		   ,[formula_id]
	--		   ,[udf_user_field_id])
	--	SELECT	ft.template_id,
	--			ft.[field_name]
	--		   ,ft.[Field_label]
	--		   ,ft.[Field_type]
	--		   ,ft.[data_type]
	--		   ,ft.[is_required]
	--		   ,ft.[sql_string]
	--		   ,ft.[create_user]
	--		   ,GETDATE()
	--		   ,ft.[update_user]
	--		   ,GETDATE()
	--		   ,ft.[udf_type]
	--		   ,ft.[field_size]
	--		   ,ft.[field_id]
	--		   ,ft.[default_value]
	--		   ,ft.[udf_group]
	--		   ,ft.[udf_tabgroup]
	--		   ,ft.[formula_id]
	--		   ,ft.[udf_template_id] 
	--FROM user_defined_deal_fields_template dt 
	--RIGHT OUTER JOIN #tempUDF ft ON dt.udf_user_field_id=ft.udf_template_id 
	--	AND dt.template_id=ft.template_id        
	--WHERE dt.udf_user_field_id IS NULL 

	--DELETE user_defined_deal_fields 
	--FROM user_defined_deal_fields udf 
	--JOIN user_defined_deal_fields_template dt ON udf.udf_template_id=dt.udf_template_id
	--LEFT OUTER JOIN #tempUDF ft ON dt.template_id=ft.template_id     
	--WHERE dt.udf_user_field_id NOT IN (SELECT udf_template_id FROM #tempUDF)


	--DELETE user_defined_deal_fields_template 
	--FROM user_defined_deal_fields_template dt 
	--JOIN #tempUDF ft ON dt.template_id=ft.template_id     
	--WHERE dt.udf_user_field_id NOT IN (SELECT udf_template_id FROM #tempUDF)
------------------------------------------------------------------------------------------------
	EXEC spa_ErrorHandler 0,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'Success',
		'Field Template successfully updated.',
		''
END 
IF @flag = 'p'
BEGIN 
	/*
	DECLARE @msg VARCHAR(250)
----------------Physical/financial and Location relationship-------------------	

	IF EXISTS(SELECT 1
	          FROM   maintain_field_template_detail mftd
	                 INNER JOIN maintain_field_template_detail mftd1
	                      ON  mftd.field_template_id = mftd1.field_template_id
	          WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                 AND mftd.udf_or_system = 's'
	                 AND mftd1.field_id = 111
	                 AND mftd.field_id = 109
	                 AND mftd1.default_value = 'p'
	                 AND (
	                         @hide_control = 'y'
	                         AND @default_value IS NULL
	                         OR (
	                                @insert_required = 'n'
	                                AND @hide_control = 'n'
	                                AND @default_value IS NULL
	                            )
	                     )
	                 )
	                 
	BEGIN	
	
		IF @insert_required = 'n' AND @hide_control = 'n' AND @default_value IS NULL
			SET @msg = 'Please insert default value as Physical/Financial flag is Physical.'
		ELSE
			SET @msg = 'Please insert default value to hide this field as Physical/Financial flag is Physical.'
		
		EXEC spa_ErrorHandler -1,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error_retain_window',
		@msg,
		''
		
		RETURN
	END
	ELSE IF EXISTS(SELECT 1
	               FROM   maintain_field_template_detail mftd
	                      INNER JOIN maintain_field_template_detail mftd1
	                           ON  mftd.field_template_id = mftd1.field_template_id
	               WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                      AND mftd.udf_or_system = 's'
	                      AND mftd1.field_id = 111
	                      AND mftd.field_id = 109
	                      AND mftd1.default_value = 'f'
	                      AND (
	                              @hide_control = 'n'	                              
	                              OR @default_value IS NOT NULL
	                          ))
	BEGIN
		
		IF @hide_control ='n'	
			SET @msg = 'Location is not required when physical/financial flag is financial.'
		ELSE
			SET @msg = 'Default value for location should be empty when physical/financial flag is financial.'
				
		EXEC spa_ErrorHandler 0,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error',
		@msg,
		''
		
		
		RETURN
	END
----------------Physical/financial and Meter ID relationship-------------------		
	IF EXISTS(SELECT 1
	          FROM   maintain_field_template_detail mftd
	                 INNER JOIN maintain_field_template_detail mftd1
	                      ON  mftd.field_template_id = mftd1.field_template_id
	          WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                 AND mftd.udf_or_system = 's'
	                 AND mftd1.field_id = 111
	                 AND mftd.field_id = 110
	                 AND mftd1.default_value = 'p'
	                 AND (
	                         @hide_control = 'y'
	                         AND @default_value IS NULL
	                         OR (
	                                @insert_required = 'n'
	                                AND @hide_control = 'n'
	                                AND @default_value IS NULL
	                            )
	                     )
	                 )
	BEGIN	
	
		
		IF @insert_required = 'n' AND @hide_control = 'n' AND @default_value IS NULL
			SET @msg = 'Please insert default value as Physical/Financial flag is Physical.'
		ELSE
			SET @msg = 'Please insert default value to hide this field as Physical/Financial flag is Physical.'
		
		EXEC spa_ErrorHandler -1,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error_retain_window',
		@msg,
		''
		
		RETURN
	END
	ELSE IF EXISTS(SELECT 1
	               FROM   maintain_field_template_detail mftd
	                      INNER JOIN maintain_field_template_detail mftd1
	                           ON  mftd.field_template_id = mftd1.field_template_id
	               WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                      AND mftd.udf_or_system = 's'
	                      AND mftd1.field_id = 111
	                      AND mftd.field_id = 110
	                      AND mftd1.default_value = 'f'
	                      AND (
	                              @hide_control = 'n'	                              
	                              OR @default_value IS NOT NULL
	                          ))
	BEGIN
		
		IF @hide_control ='n'	
			SET @msg = 'Meter ID is not required when physical/financial flag is financial.'
		ELSE
			SET @msg = 'Default value for Meter ID should be empty when physical/financial flag is financial.'
				
		EXEC spa_ErrorHandler 0,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error',
		@msg,
		''
		
		RETURN
	END
	
----------------Fixed/Float and Curve ID relationship-------------------		

	IF EXISTS(SELECT 1
	          FROM   maintain_field_template_detail mftd
	                 INNER JOIN maintain_field_template_detail mftd1
	                      ON  mftd.field_template_id = mftd1.field_template_id
	          WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                 AND mftd.udf_or_system = 's' 
	                 AND mftd1.field_id = 86
	                 AND mftd.field_id = 88
	                 AND mftd1.default_value = 't'
	                 AND (
	                         @hide_control = 'y'
	                         AND @default_value IS NULL
	                         OR (
	                                @insert_required = 'n'
	                                AND @hide_control = 'n'
	                                AND @default_value IS NULL
	                            )
	                     )
	                 
				)
	BEGIN	
		
		IF @insert_required = 'n' AND @hide_control = 'n' AND @default_value IS NULL
			SET @msg = 'Please insert default value to hide this field as Fixed/Float flag is float'
		ELSE
			SET @msg = 'Please insert default value as Fixed/Float flag is float'
		
		EXEC spa_ErrorHandler 0,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error_retain_window',
		@msg,
		''
		
		RETURN
	END
	ELSE IF EXISTS(SELECT 1
	               FROM   maintain_field_template_detail mftd
	                      INNER JOIN maintain_field_template_detail mftd1
	                           ON  mftd.field_template_id = mftd1.field_template_id
	               WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                      AND mftd.udf_or_system = 's' 
	                      AND mftd1.field_id = 86
	                      AND mftd.field_id = 88
	                      AND mftd1.default_value = 'f'
	                      AND (
	                              @hide_control = 'n'	                             
	                              OR @default_value IS NOT NULL
	                          ))
	BEGIN
		
		IF (@hide_control ='n')	
			SET @msg = 'Curve Id is not required, when Fixed/Float is Fixed.'
		ELSE
			SET @msg = 'Default value for curve id should be empty when Fixed/Float is Fixed.'
				
		EXEC spa_ErrorHandler 0,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error',
		@msg,
		''	
		
		RETURN
	END	
----------------Options and Option Type relationship-------------------		
	
	IF EXISTS(SELECT 1
	          FROM   maintain_field_template_detail mftd
	                 INNER JOIN maintain_field_template_detail mftd1
	                      ON  mftd.field_template_id = mftd1.field_template_id
	          WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                 AND mftd.udf_or_system = 's' 
	                 AND mftd1.field_id = 16
	                 AND mftd.field_id = 17
	                 AND mftd1.default_value = 'y'
	                AND (
	                         @hide_control = 'y'
	                         AND @default_value IS NULL
	                         OR (
	                                @insert_required = 'n'
	                                AND @hide_control = 'n'
	                                AND @default_value IS NULL
	                            )
	                     )
				)
	BEGIN	
		IF @insert_required = 'n' AND @hide_control = 'n' AND @default_value IS NULL
			SET @msg = 'Please select default value as Options is Yes.'
		ELSE
			SET @msg = 'Please select default value to hide this field as Options is Yes.'

		
		EXEC spa_ErrorHandler 0,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error_retain_window',
		@msg,
		''
		
		RETURN
	END
	ELSE IF EXISTS(SELECT 1
	               FROM   maintain_field_template_detail mftd
	                      INNER JOIN maintain_field_template_detail mftd1
	                           ON  mftd.field_template_id = mftd1.field_template_id
	               WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                      AND mftd.udf_or_system = 's' 
	                      AND mftd1.field_id = 16
	                      AND mftd.field_id = 17
	                      AND mftd1.default_value = 'n'
	                      AND (
	                              @hide_control = 'n'	                             
	                              OR @default_value IS NOT NULL
	                          )
	              )	                             
	                          
	BEGIN
		
		IF (@hide_control ='n')	
			SET @msg = 'Options flag is No, Please check it first.'
		ELSE
			SET @msg = 'Default value for option type should be empty when options is no.'

		
		EXEC spa_ErrorHandler 0,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error',
		@msg,
		''	
		
		RETURN
	END	
	
----------------Options and Exercise Type relationship-------------------		
	
	IF EXISTS(SELECT 1
	          FROM   maintain_field_template_detail mftd
	                 INNER JOIN maintain_field_template_detail mftd1
	                      ON  mftd.field_template_id = mftd1.field_template_id
	          WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                 AND mftd.udf_or_system = 's' 
	                 AND mftd1.field_id = 16
	                 AND mftd.field_id = 18
	                 AND mftd1.default_value = 'y'
	                 AND (
	                         @hide_control = 'y'
	                         AND @default_value IS NULL
	                         OR (
	                                @insert_required = 'n'
	                                AND @hide_control = 'n'
	                                AND @default_value IS NULL
	                            )
	                     )
				)
	BEGIN	
	
		IF @insert_required = 'n' AND @hide_control = 'n' AND @default_value IS NULL
			SET @msg = 'Please select default value as Options is Yes.'
		ELSE
			SET @msg = 'Please select default value to hide this field as Options is Yes.'

		EXEC spa_ErrorHandler -1,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error_retain_window',
		@msg,
		''
		
		RETURN
	END
	ELSE IF EXISTS(SELECT 1
	               FROM   maintain_field_template_detail mftd
	                      INNER JOIN maintain_field_template_detail mftd1
	                           ON  mftd.field_template_id = mftd1.field_template_id
	               WHERE  mftd.field_template_detail_id = @field_template_detail_id
	                      AND mftd.udf_or_system = 's'
	                      AND mftd1.field_id = 16
	                      AND mftd.field_id = 18
	                      AND mftd1.default_value = 'n'
	                      AND (
	                              @hide_control = 'n'	                             
	                              OR @default_value IS NOT NULL
	                          )
	              )	                             
	                          
	BEGIN
		
		IF (@hide_control ='n')	
			SET @msg = 'Options flag is No, Please check it first.'
		ELSE
			SET @msg = 'Default value for exercise type should be empty when options is no.'

		
		EXEC spa_ErrorHandler 0,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'error',
		@msg,
		''
		
		RETURN
	END	
	*/
BEGIN TRY
BEGIN TRAN	
	SELECT @deal_update_max_seq_show = MAX(deal_update_seq_no)
	FROM   maintain_field_template_detail
	WHERE  field_template_id = @field_template_id
	AND field_group_id IS NULL AND update_required = 'y'
	
	SELECT @deal_update_max_seq_hide = MAX(deal_update_seq_no)
	FROM   maintain_field_template_detail
	WHERE  field_template_id = @field_template_id
	AND field_group_id IS NULL AND update_required = 'n'
	
	DECLARE @change_hide_show_status BIT
	DECLARE @sql VARCHAR(max)
	DECLARE @deal_update_seq_no INT 
	SET @change_hide_show_status = 0
	

	IF EXISTS(SELECT 1
	FROM   maintain_field_template_detail
	WHERE  field_template_detail_id = @field_template_detail_id 
	AND (hide_control <> @hide_control OR update_required <> @update_required)	
	AND field_group_id IS NULL) 
	BEGIN
		SET @change_hide_show_status = 1
		
		SELECT @deal_update_seq_no = deal_update_seq_no
		FROM   maintain_field_template_detail
		WHERE  field_template_detail_id = @field_template_detail_id 
		
		
		SET @sql = 'UPDATE mftd SET mftd.deal_update_seq_no = mftd.deal_update_seq_no - 1
		FROM   maintain_field_template_detail mftd
		WHERE  mftd.field_template_id = ' + CAST(@field_template_id AS VARCHAR(10)) + '
		       AND mftd.deal_update_seq_no > ' + CAST(@deal_update_seq_no AS VARCHAR(10))
		
		IF @deal_update_seq_no < 1000
		BEGIN
			SET @sql = @sql + ' AND mftd.deal_update_seq_no < 1000'
		END
		--SELECT @deal_update_max_seq_hide
		--SELECT @deal_update_max_seq_show
		UPDATE maintain_field_template_detail
		SET    deal_update_seq_no = CASE 
		                                 WHEN @update_required = 'n'  THEN @deal_update_max_seq_hide + 1
		                                 ELSE @deal_update_max_seq_show + 1
		                            END
		WHERE  field_template_detail_id = @field_template_detail_id 
		
		EXEC spa_print @sql
		EXEC(@sql)
		       
	END
	
	
	UPDATE maintain_field_template_detail
	SET    is_disable = @is_disable,
	       insert_required = @insert_required,
	       update_required = @update_required,
	       field_caption = @field_caption,
	       default_value = @default_value,
	       min_value = @min_value,
	       max_value = @max_value,
	       validation_id = @validation_id,
	       hide_control = @hide_control,
	       field_group_id = @field_group_id,
	       display_format = @display_format,
	       buy_label = @buy_label,
	       sell_label = @sell_label,
	       value_required = @value_required
	       --deal_update_seq_no = CASE WHEN @change_hide_show_status = 1 THEN   CASE WHEN @hide_control = 'y' THEN @deal_update_max_seq_hide + 1 ELSE @deal_update_max_seq_show + 1 END ELSE deal_update_seq_no END
	WHERE  field_template_detail_id = @field_template_detail_id 
	
	/*
	DECLARE @template_id INT		
--------------Physical/Financial and Location and Meter ID relation--------------------------	
	IF EXISTS(SELECT 1
	          FROM   maintain_field_template_detail
	          WHERE  field_template_detail_id = @field_template_detail_id
	                 AND udf_or_system = 's' 
	                 AND field_id = 111
	                 AND @default_value = 'p')
	BEGIN		
		UPDATE mftd
		SET    hide_control = 'n',
		       insert_required = 'y'
		FROM   maintain_field_template_detail mftd
		       INNER JOIN maintain_field_template_detail mftd1
		            ON  mftd.field_template_id = mftd1.field_template_id
		WHERE  mftd1.field_template_detail_id = @field_template_detail_id
		       
		       AND mftd.field_id IN (109, 110)
		
	END 
	ELSE IF EXISTS(SELECT 1
	               FROM   maintain_field_template_detail
	               WHERE  field_template_detail_id = @field_template_detail_id
	                      AND udf_or_system = 's' 
	                      AND field_id = 111
	                      AND @default_value = 'f')
	BEGIN	
		UPDATE mftd
		SET    hide_control = 'y',
		       insert_required = 'n',
		       default_value = NULL
		FROM   maintain_field_template_detail mftd
		       INNER JOIN maintain_field_template_detail mftd1
		            ON  mftd.field_template_id = mftd1.field_template_id
		WHERE  mftd1.field_template_detail_id = @field_template_detail_id
		       AND mftd.field_id IN (109, 110)
	END
---------Option and (Option Type relation and Exercise Type)--------------	
	IF EXISTS(
	       SELECT 1
	       FROM   maintain_field_template_detail
	       WHERE  field_template_detail_id = @field_template_detail_id
	              AND udf_or_system = 's' 
	              AND field_id = 16
	              AND @default_value = 'y'
	   )
	BEGIN
	    UPDATE mftd
	    SET    hide_control = 'n',
	           insert_required = 'y'
	    FROM   maintain_field_template_detail mftd
	           INNER JOIN maintain_field_template_detail mftd1
	                ON  mftd.field_template_id = mftd1.field_template_id
	    WHERE  mftd1.field_template_detail_id = @field_template_detail_id
	           AND mftd.field_id IN(17, 18)
	END
	ELSE IF EXISTS( SELECT 1
	                FROM   maintain_field_template_detail
	                WHERE  field_template_detail_id = @field_template_detail_id
	                        AND udf_or_system = 's' 
	                       AND field_id = 16
	                       AND @default_value = 'n')
	BEGIN		
		UPDATE mftd
		SET    hide_control = 'y',
		       insert_required = 'n',
		       default_value = NULL
		FROM   maintain_field_template_detail mftd
		       INNER JOIN maintain_field_template_detail mftd1
		            ON  mftd.field_template_id = mftd1.field_template_id
		WHERE  mftd1.field_template_detail_id = @field_template_detail_id		      
		       AND mftd.field_id IN (17, 18)	
			
	END	
----------Fixed/float and curve id relation---------------------	
	IF EXISTS(SELECT 1
	          FROM   maintain_field_template_detail
	          WHERE  field_template_detail_id = @field_template_detail_id
	                 AND udf_or_system = 's' 
	                 AND field_id = 86
	                 AND @default_value = 't')
	BEGIN		
		UPDATE mftd
		SET    hide_control = 'n',
		       insert_required = 'y'
		FROM   maintain_field_template_detail mftd
		       INNER JOIN maintain_field_template_detail mftd1
		            ON  mftd.field_template_id = mftd1.field_template_id
		WHERE  mftd1.field_template_detail_id = @field_template_detail_id
		       AND mftd.field_id = 88
		
	END 
	ELSE IF EXISTS(SELECT 1
	               FROM   maintain_field_template_detail
	               WHERE  field_template_detail_id = @field_template_detail_id
	                      AND udf_or_system = 's' 
	                      AND field_id = 86
	                      AND @default_value = 'f')
	BEGIN	
		UPDATE mftd
		SET    hide_control = 'y',
		       insert_required = 'n',
		       default_value = NULL
		FROM   maintain_field_template_detail mftd
		       INNER JOIN maintain_field_template_detail mftd1
		            ON  mftd.field_template_id = mftd1.field_template_id
		WHERE  mftd1.field_template_detail_id = @field_template_detail_id
		       AND mftd.field_id = 88
	END
*/
	EXEC spa_ErrorHandler 0,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'Success',
		'Field properties successfully updated.',
		''
	COMMIT
END TRY

BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK
	DECLARE @error_msg VARCHAR(1000) = 'Error updating field properties',
			@error_num INT
	SET @error_num = ERROR_NUMBER()
	IF @error_num = 2627
	BEGIN
		SET @error_msg = 'Duplicate field labels are not allowed.'
	END
	EXEC spa_ErrorHandler -1,
		'Field Template Properties',
		'spa_maintain_field_properties',
		'Error',
		@error_msg,
		''
END CATCH
END 
GO