

/****** Object:  StoredProcedure [dbo].[spa_maintain_fields_templates]    Script Date: 12/30/2011 15:36:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_maintain_fields_templates]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_maintain_fields_templates]
GO



/****** Object:  StoredProcedure [dbo].[spa_maintain_fields_templates]    Script Date: 12/30/2011 15:31:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROC [dbo].[spa_maintain_fields_templates]
@flag CHAR(1),
@field_template_id VARCHAR(5000) = NULL, 
@template_name VARCHAR(50) = NULL,
@template_description VARCHAR(150) = null,
@active_inactive CHAR(1) = NULL,
@show_cost_tab NCHAR(1) = NULL,
@show_detail_cost_tab NCHAR(1) = NULL,
@is_mobile NCHAR(1) = NULL,
@show_udf_tab NCHAR(1) = NULL
AS 
SET NOCOUNT ON


DECLARE @new_field_template_id INT

IF @flag = 's'
BEGIN  	
	SELECT field_template_id [Field ID],
	template_name [Field Template Name],
	template_description [Field Template Description],
	CASE WHEN active_inactive='y' THEN 'Yes' ELSE 'No' END  [Active],
	CASE WHEN show_cost_tab ='y' THEN 'Yes' ELSE 'No' END [Cost Tab],
	CASE WHEN show_detail_cost_tab ='y' THEN 'Yes' ELSE 'No' END [Detail Cost Tab]	
	FROM maintain_field_template
	 
END

IF @flag = 'o' --only active
BEGIN  	
	SELECT field_template_id [Field ID],
	template_name [Field Template Name],
	template_description [Field Template Description],
	CASE WHEN active_inactive='y' THEN 'Yes' ELSE 'No' END  [Active],
	CASE WHEN show_cost_tab ='y' THEN 'Yes' ELSE 'No' END [Cost Tab],	
	CASE WHEN show_detail_cost_tab ='y' THEN 'Yes' ELSE 'No' END [Detail Cost Tab]
	FROM maintain_field_template mft WHERE mft.active_inactive = 'y'
	 
END

IF @flag = 'a'
BEGIN 
	SELECT field_template_id [Field ID],
	template_name [Field Template Name],
	template_description [Field Template Description],
	CASE WHEN active_inactive='y' THEN 'Yes' ELSE 'No' END  [Active],
	CASE WHEN show_cost_tab ='y' THEN 'Yes' ELSE 'No' END [Cost Tab],	
	CASE WHEN show_detail_cost_tab ='y' THEN 'Yes' ELSE 'No' END [Detail Cost Tab]
	, is_mobile
	, CASE WHEN show_udf_tab = 'y' THEN 'Yes' ELSE 'No' END [UDF Tab]
	FROM maintain_field_template 
	WHERE field_template_id = @field_template_id 
END

IF @flag = 'i'
BEGIN 
	IF EXISTS (SELECT 1 FROM maintain_field_template WHERE template_name = @template_name)
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'Field Template',
			 'spa_maintain_fields_templates',
			 'Error',
			 'Field Template already exists.',
			 ''
	END
	ELSE
	BEGIN
		INSERT INTO [maintain_field_template]
           (
           		[template_name]
			   , [template_description]
			   , [active_inactive]
			   , show_cost_tab
			   , show_detail_cost_tab
			   , is_mobile
			   , show_udf_tab
           )
		 VALUES
			   (
           			@template_name
				   , @template_description
				   , @active_inactive
				   , @show_cost_tab
				   , @show_detail_cost_tab
				   , @is_mobile
				   , @show_udf_tab
			   )
			   
		 SET @new_field_template_id = SCOPE_IDENTITY()
		 
		 INSERT maintain_field_template_group (
			field_template_id,
			group_name,
			seq_no,
			default_tab				
		 )
		 SELECT @new_field_template_id, 'General', 1, 0
		 
		 DECLARE @new_general_group INT
		 	SELECT @new_general_group = field_group_id
		 	FROM   maintain_field_template_group
		 	WHERE field_template_id     = @new_field_template_id
		 	AND   group_name            = 'General'
		 	
		 	INSERT maintain_field_template_detail (
				field_template_id,
				field_group_id,
				field_id,
				udf_or_system,
				seq_no,
				hide_control,
				field_caption,
				default_value,
				insert_required,
				deal_update_seq_no,
				is_disable,
				update_required
			  )
			SELECT @new_field_template_id,
				   CASE 
						WHEN mfd.header_detail = 'd' THEN NULL
						ELSE @new_general_group
				   END,
				   mfd.field_id,
				   's',
				   ROW_NUMBER() OVER(ORDER BY mfd.is_hidden, field_id),
				   is_hidden,
				   mfd.default_label,
				   default_value,
				   insert_required,
				   ROW_NUMBER() OVER(ORDER BY mfd.is_hidden, field_id),
				   mfd.is_disable,
				   mfd.update_required		       
			FROM   maintain_field_deal mfd
			WHERE  system_required = 'y'
			
			DECLARE @min_update_seq INT
			SELECT @min_update_seq = MIN(deal_update_seq_no)
			FROM   maintain_field_template_detail
			WHERE  field_template_id = @field_template_id
				   AND field_group_id IS NULL 
		
			UPDATE mftd
			SET    deal_update_seq_no = CASE 
											 WHEN mftd.field_group_id IS NULL THEN CASE 
																						WHEN mftd.hide_control = 'y' THEN deal_update_seq_no - @min_update_seq + 1001
																						ELSE deal_update_seq_no - @min_update_seq + 1
																				   END
											 ELSE NULL
										END
			FROM   maintain_field_template_detail mftd
			WHERE  field_template_id = @field_template_id
		 
		 IF @show_cost_tab = 'y'
		 BEGIN
		 	INSERT maintain_field_template_group (
				field_template_id,
				group_name,
				seq_no,
				default_tab
				
		 	)
		 	SELECT @new_field_template_id, 'Cost', 2, 1	
		 END
		 
		 IF @show_detail_cost_tab = 'y'
		 BEGIN
		 	INSERT maintain_field_template_group_detail (
				field_template_id,
				group_name,
				seq_no,
				default_tab
				
		 	)
		 	SELECT @new_field_template_id, 'Cost', 1, 1
		 END
		 
		 EXEC spa_ErrorHandler 0,
			 'Field Template',
			 'spa_maintain_fields_templates',
			 'Success',
			 'Field Template successfully inserted.',
			 ''
	END
	
			     
END
IF @flag = 'u'
BEGIN 
	IF EXISTS (SELECT 1 FROM maintain_field_template WHERE template_name = @template_name AND field_template_id <> @field_template_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
			 'Field Template',
			 'spa_maintain_fields_templates',
			 'Error',
			 'Field Template already exists.',
			 ''
	END
	ELSE
	BEGIN
		UPDATE [maintain_field_template]
		SET [template_name] = @template_name
			, [template_description] = @template_description
			, [active_inactive] = @active_inactive
			, show_cost_tab = @show_cost_tab 
			, show_detail_cost_tab = @show_detail_cost_tab
			, is_mobile = @is_mobile
			, show_udf_tab = @show_udf_tab
		WHERE field_template_id = @field_template_id 
		
		IF @show_cost_tab = 'y'
		BEGIN
			DECLARE @max_seq_id INT
			
			IF NOT EXISTS (SELECT 1 FROM maintain_field_template_group WHERE default_tab = 1 AND field_template_id = @field_template_id)
			BEGIN
				SELECT @max_seq_id = MAX(seq_no) FROM maintain_field_template_group WHERE field_template_id = @field_template_id
				IF NOT EXISTS(SELECT 1 FROM maintain_field_template_group WHERE group_name = 'Costs' AND field_template_id = @field_template_id)
				BEGIN
					INSERT maintain_field_template_group (
						field_template_id,
						group_name,
						seq_no,
						default_tab
		 			)
		 			SELECT @field_template_id, 'Costs', @max_seq_id + 1, 1
				END
			END
			
			
		END
		ELSE
		BEGIN
			DELETE mftd 
			FROM maintain_field_template_detail mftd
			INNER JOIN maintain_field_template_group mftg 
				ON mftg.field_group_id = mftd.field_group_id
			WHERE default_tab = 1 AND mftg.field_template_id = @field_template_id
			
			DELETE 
			FROM   maintain_field_template_group
			WHERE  default_tab = 1
			AND    field_template_id = @field_template_id	
		END
		
		IF @show_detail_cost_tab = 'y'
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM maintain_field_template_group_detail WHERE default_tab = 1 AND field_template_id = @field_template_id)
			BEGIN
				SELECT @max_seq_id = MAX(seq_no) FROM maintain_field_template_group_detail WHERE field_template_id = @field_template_id
				IF NOT EXISTS(SELECT 1 FROM maintain_field_template_group_detail WHERE group_name = 'Costs' AND field_template_id = @field_template_id)
				BEGIN
					INSERT maintain_field_template_group_detail (
						field_template_id,
						group_name,
						seq_no,
						default_tab
		 			)
		 			SELECT @field_template_id, 'Costs', @max_seq_id + 1, 1
				END
			END
		END
		ELSE
		BEGIN
			DELETE mftd 
			FROM maintain_field_template_detail mftd
			INNER JOIN maintain_field_template_group_detail mftg 
				ON mftg.group_id = mftd.detail_group_id
			WHERE default_tab = 1 AND mftg.field_template_id = @field_template_id
			
			DELETE 
			FROM   maintain_field_template_group_detail
			WHERE  default_tab = 1
			AND    field_template_id = @field_template_id
		END
          
		EXEC spa_ErrorHandler 0,
			 'Field Template',
			 'spa_maintain_fields_templates',
			 'Success',
			 'Field Template successfully updated.',
			 ''
	END
END
IF @flag = 'd'
BEGIN 
	IF EXISTS(SELECT 'x' FROM source_deal_header_template sdht INNER JOIN maintain_field_template mft
	ON sdht.field_template_id = mft.field_template_id AND mft.field_template_id = @field_template_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
		 'Field Template',
		 'spa_maintain_fields_templates',
		 'Success',
		 'Field Template is already in use.',
		 ''
		 RETURN
	END
	
	DELETE maintain_field_template_detail WHERE field_template_id = @field_template_id 
	DELETE maintain_field_template_group WHERE field_template_id = @field_template_id 
	DELETE maintain_field_template_group_detail WHERE field_template_id = @field_template_id 
	DELETE maintain_field_template WHERE field_template_id = @field_template_id 
	
	EXEC spa_ErrorHandler 0,
		 'Field Template',
		 'spa_maintain_fields_templates',
		 'Success',
		 'Field Template successfully removed.',
		 ''
END
IF @flag = 'c'
BEGIN
		CREATE TABLE #tmp_table_fields_templates (
			 org_fields_templates_id VARCHAR(100) COLLATE DATABASE_DEFAULT , 
			 copied_fields_templates_id VARCHAR(100) COLLATE DATABASE_DEFAULT  
		)
		
		CREATE TABLE #tmp_table_new_group_id (
			 org_group_id INT,
			 new_group_id INT			 
		)
				
		INSERT INTO [maintain_field_template] (
			[template_name]
			,[template_description]
			,[active_inactive]
			,show_cost_tab
		)
		OUTPUT INSERTED.template_name, INSERTED.field_template_id INTO #tmp_table_fields_templates
		SELECT 
			field_template_id,
			template_description,
			active_inactive,
			mft.show_cost_tab
		FROM maintain_field_template mft
			INNER JOIN dbo.SplitCommaSeperatedValues(@field_template_id) scsv 
				ON mft.field_template_id = scsv.item

		UPDATE mft
		SET    template_name = temp_cnt.new_temp_name
		FROM   maintain_field_template mft
		       INNER JOIN #tmp_table_fields_templates ttft
		            ON  mft.field_template_id = ttft.copied_fields_templates_id
		       INNER JOIN maintain_field_template mft_org
		            ON  ttft.org_fields_templates_id = mft_org.field_template_id
		       CROSS APPLY(
		    SELECT '(' + CAST(COUNT(template_name) + 01 AS VARCHAR(10)) + 
		           ') Copy of ' + mft_org.template_name new_temp_name
		    FROM   maintain_field_template
		    WHERE  template_name LIKE '(_) Copy of ' + mft_org.template_name
		           OR  template_name LIKE '(__) Copy of ' + mft_org.template_name
		           OR  template_name LIKE '(___) Copy of ' + mft_org.template_name
		) temp_cnt
		
		INSERT maintain_field_template_group
		  (
		    field_template_id,
		    group_name,
		    seq_no
		  )OUTPUT INSERTED.group_name, INSERTED.field_group_id INTO #tmp_table_new_group_id
		SELECT ttft.copied_fields_templates_id,
		       mftg.field_group_id,
		       mftg.seq_no
		FROM   maintain_field_template_group mftg
		       INNER JOIN dbo.SplitCommaSeperatedValues(@field_template_id) scsv
		            ON  mftg.field_template_id = scsv.item
		       INNER JOIN #tmp_table_fields_templates ttft
		            ON  mftg.field_template_id = ttft.org_fields_templates_id
		
		UPDATE mftg
		SET    mftg.group_name = mftg1.group_name
		FROM   maintain_field_template_group mftg
		       INNER JOIN maintain_field_template_group mftg1
		            ON  mftg.group_name = CAST(mftg1.field_group_id AS VARCHAR)
		

		INSERT maintain_field_template_detail
		  (
		    field_template_id,
		    field_group_id,
		    field_id,
		    udf_or_system,
		    seq_no,
		    is_disable,
		    insert_required,
		    field_caption,
		    default_value,
		    min_value,
		    max_value,
		    validation_id,
		    hide_control,
		    data_flag,
		    display_format,
		    buy_label,
		    sell_label,
		    update_required,
		    deal_update_seq_no
		  )
		SELECT ttft.copied_fields_templates_id,
		       ttng.new_group_id,
		       field_id,
		       udf_or_system,
		       seq_no,
		       is_disable,
		       insert_required,
		       field_caption,
		       default_value,
		       min_value,
		       max_value,
		       validation_id,
		       hide_control,
		       data_flag,
		       display_format,
		       buy_label,
		       sell_label,
		       update_required,
		       deal_update_seq_no
		FROM   maintain_field_template_detail mfd
		       INNER JOIN dbo.SplitCommaSeperatedValues(@field_template_id) scsv
		            ON  mfd.field_template_id = scsv.item
		       INNER JOIN #tmp_table_fields_templates ttft
		            ON  mfd.field_template_id = ttft.org_fields_templates_id
		       INNER JOIN #tmp_table_new_group_id ttng
		            ON  mfd.field_group_id = ttng.org_group_id
		WHERE  mfd.field_group_id IS NOT NULL
		
		INSERT maintain_field_template_detail
		  (
		    field_template_id,
		    field_group_id,
		    field_id,
		    udf_or_system,
		    seq_no,
		    is_disable,
		    insert_required,
		    field_caption,
		    default_value,
		    min_value,
		    max_value,
		    validation_id,
		    hide_control,
		    data_flag,
		    display_format,
		    buy_label,
		    sell_label,
		    update_required,
		    deal_update_seq_no
		  )
		SELECT ttft.copied_fields_templates_id,
		       NULL,
		       field_id,
		       udf_or_system,
		       seq_no,
		       is_disable,
		       insert_required,
		       field_caption,
		       default_value,
		       min_value,
		       max_value,
		       validation_id,
		       hide_control,
		       data_flag,
		       display_format,
		       buy_label,
		       sell_label,
		       update_required,
		       deal_update_seq_no
		FROM   maintain_field_template_detail mfd
		       INNER JOIN dbo.SplitCommaSeperatedValues(@field_template_id) scsv
		            ON  mfd.field_template_id = scsv.item
		       INNER JOIN #tmp_table_fields_templates ttft
		            ON  mfd.field_template_id = ttft.org_fields_templates_id
		WHERE  mfd.field_group_id IS NULL
		

		 EXEC spa_ErrorHandler 0,
			 'Field Template Properties',
			 'spa_maintain_field_properties',
			 'Success',
			 'Field Template successfully inserted.',
			 ''
END
IF @flag = 'e'
BEGIN
	SELECT field_template_detail_id AS [ID],
	       field_caption AS [Field Name],
	       is_disable AS [Enable/Disable],
	       insert_required AS [Insert Required],
	       default_value AS [Default Value],
	       udf_or_system AS [UDF/System],
	       min_value AS [Minimum Value],
	       max_value AS [Maximum Value],
	       buy_label AS [Buy Label],
	       sell_label AS [Sell Label],
	       update_required AS [Update Required],
	       hide_control AS [Hide Control],
	       display_format AS [Display Format]
	FROM   maintain_field_template_detail
	WHERE  field_template_id = @field_template_id
	       AND field_group_id IS NOT NULL
END


IF @flag = 'f'
BEGIN
	SELECT '1' value, 'Yes' text UNION ALL SELECT '0', 'No'
END

IF @flag = 'g'
BEGIN
	SELECT 's', 'System' UNION ALL SELECT 'u', 'UDF'
END

IF @flag = 'h'
BEGIN
	SELECT value_id,
		   Code
	FROM   static_data_value s
		   LEFT OUTER JOIN static_data_category c
				ON  c.category_id = s.category_id
	WHERE  s.type_id = 19200
		   AND entity_id IS NULL
	ORDER BY
		   c.category_name,
		   code
END

IF @flag = 'j'
BEGIN
    SELECT field_template_detail_id AS [ID],
           field_caption AS [Field Name],
           is_disable AS [Enable/Disable],
           insert_required AS [Insert Required],
           default_value AS [Default Value],
           udf_or_system AS [UDF/System],
           min_value AS [Minimum Value],
           max_value AS [Maximum Value],
           buy_label AS [Buy Label],
           sell_label AS [Sell Label],
           update_required AS [Update Required],
           hide_control AS [Hide Control],
           display_format AS [Display Format]
    FROM   maintain_field_template_detail
    WHERE  field_template_id = @field_template_id
           AND field_group_id IS NULL
END		

IF @flag = 'k'
BEGIN 
	SELECT field_group_id
	FROM   maintain_field_template_group
	WHERE  seq_no IN (SELECT MIN(seq_no)
					  FROM   maintain_field_template_group mftg
					  WHERE  mftg.field_template_id = @field_template_id
					  GROUP BY
							 field_template_id)
		   AND field_template_id = @field_template_id
END

GO
SET ANSI_NULLS ON
GO

