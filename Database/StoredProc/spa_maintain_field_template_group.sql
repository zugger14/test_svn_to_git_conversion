IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_maintain_field_template_group]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_maintain_field_template_group]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spa_maintain_field_template_group]
	@flag CHAR(1),
	@field_group_id INT = NULL,
	@field_template_id INT = NULL,
	@group_name VARCHAR(50) = NULL,
	@seq_no INT = NULL
AS
SET NOCOUNT ON

IF @flag = 's'
BEGIN
	SELECT [field_group_id] AS [Group ID],
		[group_name] [Group Name],
		[seq_no] [Seq no]
	FROM [maintain_field_template_group] 
	WHERE field_template_id = @field_template_id
END

IF @flag = 'a'
BEGIN
	SELECT * FROM maintain_field_template_group WHERE field_group_id = @field_group_id 
END

IF @flag = 'i'
BEGIN
	IF EXISTS (SELECT 1 FROM [maintain_field_template_group] WHERE seq_no = @seq_no AND field_template_id = @field_template_id)
	BEGIN
		EXEC spa_ErrorHandler -1,
			'Field Template',
			'spa_maintain_fields_templates',
			'Error',
			'Sequence Number already exists.',
			''
		RETURN
	END
	
	IF NOT EXISTS (SELECT 1 FROM [maintain_field_template_group] WHERE [group_name] = @group_name AND field_template_id = @field_template_id)
	BEGIN
		INSERT INTO [maintain_field_template_group](
           	[field_template_id],
			[group_name],
			[seq_no]
		)
		VALUES(
			@field_template_id,
			@group_name,
			@seq_no
		)
	    
		SET @field_group_id = SCOPE_IDENTITY()
	     
		DECLARE @total_group INT 
		DECLARE @min_update_seq INT
		SELECT @total_group = COUNT(1) FROM maintain_field_template_group WHERE field_template_id = @field_template_id

		IF @total_group = 1
		BEGIN
			INSERT maintain_field_template_detail(
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
			SELECT @field_template_id,
				CASE
					WHEN mfd.header_detail = 'd' THEN NULL
					ELSE @field_group_id
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
			FROM maintain_field_deal mfd
			WHERE system_required = 'y'
		
			SELECT @min_update_seq = MIN(deal_update_seq_no)
			FROM maintain_field_template_detail
			WHERE field_template_id = @field_template_id
				AND field_group_id IS NULL
		
			UPDATE mftd
			SET deal_update_seq_no = CASE
										WHEN mftd.field_group_id IS NULL THEN CASE 
											WHEN mftd.hide_control = 'y' THEN deal_update_seq_no - @min_update_seq + 1001
											ELSE deal_update_seq_no - @min_update_seq + 1
										END
										ELSE NULL
									END
			FROM maintain_field_template_detail mftd
			WHERE field_template_id = @field_template_id
		END
	
		EXEC spa_ErrorHandler 0,
			'Field Template',
			'spa_maintain_fields_templates',
			'Success',
			'Field Template successfully inserted.',
			''
	END
	ELSE 
	BEGIN
		EXEC spa_ErrorHandler -1,
			'Field Template',
			'spa_maintain_fields_templates',
			'Error',
			'Group Name already exists.',
			''
	END
END

IF @flag = 'u'
BEGIN 
	IF EXISTS (SELECT 1 FROM [maintain_field_template_group] WHERE seq_no = @seq_no AND field_template_id = @field_template_id AND field_group_id <> @field_group_id)
	BEGIN 
		EXEC spa_ErrorHandler -1,
			'Field Template',
			'spa_maintain_fields_templates',
			'Error',
			'Sequence Number already exists.',
			''
		RETURN
	END
	
	IF NOT EXISTS (SELECT 1 FROM [maintain_field_template_group] WHERE [group_name] = @group_name  AND field_template_id = @field_template_id AND field_group_id <> @field_group_id)
	BEGIN
		UPDATE [maintain_field_template_group]
		SET [group_name] = @group_name,
			seq_no = @seq_no
		WHERE field_group_id = @field_group_id 
          
		EXEC spa_ErrorHandler 0,
			'Field Template',
			'spa_maintain_fields_templates',
			'Success',
			'Field Template successfully updated.',
			''
	END
	ELSE 
	BEGIN
		EXEC spa_ErrorHandler -1,
			'Field Template',
			'spa_maintain_fields_templates',
			'Error',
			'Group Name already exists.',
			''
	END
END

IF @flag =  'd'
BEGIN 
	IF EXISTS(
		SELECT 1 
		FROM source_deal_header_template sdht
		INNER JOIN maintain_field_template_group mftg ON mftg.field_template_id = sdht.field_template_id
			AND mftg.field_template_id = @field_template_id
	)
	BEGIN
		EXEC spa_ErrorHandler -1,
			'Field Template',
			'spa_maintain_fields_templates',
			'Success',
			'Field Template Group is already in use.',
			''
		RETURN
	END
	---- starts default field group validation-----
	DECLARE @temp_field_group_id INT
	DECLARE @count_field_group INT
	
	SELECT @count_field_group = COUNT(1) FROM maintain_field_template_group WHERE field_template_id = @field_template_id
	
	IF EXISTS (
		SELECT 1
		FROM maintain_field_template_detail mftd
		INNER JOIN maintain_field_deal mfd ON mftd.field_id = mfd.field_id
			AND mftd.udf_or_system = 's'
			AND mfd.system_required = 'y'
		WHERE field_group_id=@field_group_id
	)
	BEGIN
		EXEC spa_ErrorHandler -1,
			'Field Template',
			'spa_maintain_fields_templates',
			'Error',
			'Field template group contain system required fields.',
			''
		RETURN
	END
	
	/*
	IF EXISTS(SELECT TOP 1  field_group_id   FROM maintain_field_template_detail 
	WHERE field_template_id=@field_template_id )
	BEGIN
		SELECT @temp_field_group_id = field_group_id   FROM maintain_field_template_detail 
		WHERE field_template_id=@field_template_id and field_group_id is not null
		IF (@temp_field_group_id = @field_group_id and @count_field_group > 1 )
		BEGIN
			EXEC spa_ErrorHandler -1,
			 'Field Template',
			 'spa_maintain_fields_templates',
			 'Error',
			 'Please delete other group first to delete default field group.',
			 ''
			 RETURN
		END
	END
	*/
	---- ends default field group validation-----
	
	DELETE maintain_field_template_group WHERE field_group_id = @field_group_id 
	
	IF EXISTS(SELECT TOP 1 field_template_detail_id FROM maintain_field_template_detail 
	WHERE field_template_id=@field_template_id AND field_group_id = @field_group_id)
	BEGIN		
		DELETE
		FROM maintain_field_template_detail
		WHERE field_template_id = @field_template_id
			AND field_group_id = @field_group_id
	END
	
	IF NOT EXISTS(
		SELECT TOP 1 field_template_detail_id
		FROM maintain_field_template_detail
		WHERE field_template_id = @field_template_id
			AND field_group_id IS NOT NULL
	)
	BEGIN
	    DELETE
	    FROM maintain_field_template_detail
	    WHERE field_template_id = @field_template_id
			AND field_group_id IS NULL
	END

	EXEC spa_ErrorHandler 0,
		'Field Template',
		'spa_maintain_fields_templates',
		'Success',
		'Field Template successfully removed.',
		''
END

IF @flag = 'b'
BEGIN
	SELECT field_group_id, group_name FROM maintain_field_template_group WHERE field_template_id = @field_template_id
END

GO