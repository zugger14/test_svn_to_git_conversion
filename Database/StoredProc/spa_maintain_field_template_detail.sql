

/****** Object:  StoredProcedure [dbo].[spa_maintain_field_template_detail]    Script Date: 10/18/2011 13:49:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_maintain_field_template_detail]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_maintain_field_template_detail]
GO


/****** Object:  StoredProcedure [dbo].[spa_maintain_field_template_detail]    Script Date: 10/18/2011 13:49:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[spa_maintain_field_template_detail]
@flag CHAR(1),
@field_template_detail_id INT = NULL,
@field_template_id INT = NULL,
@field_group_id VARCHAR(1000) = NULL,
@field_id INT = NULL,
@seq_no INT = NULL,
@is_disable CHAR(1)=NULL, 
@insert_required CHAR(1) = NULL, 
@update_required CHAR(1) = NULL,
@field_caption VARCHAR(150) = NULL,
@default_value VARCHAR(150) = NULL,
@udf_of_system CHAR(1) = NULL,
@min_value FLOAT = NULL,
@max_value FLOAT = NULL,
@validation_id INT = NULL,
@header_detail CHAR(1) = NULL  

AS 

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN 

	SET @sql='
	SELECT [field_template_detail_id]
      ,mftd.[field_template_id]
      ,mfg.Group_Name
      ,mfd.default_label [Field Name]
      ,mftd.[seq_no]
       ,mftd.[is_disable]  
      ,mftd.[insert_required]
      ,[field_caption]
      ,mftd.[default_value]
      ,mftd.[udf_or_system]
      ,[min_value]
      ,[max_value]
      ,[validation_id]
      ,mftd.[update_required]
		FROM [maintain_field_template_detail] mftd inner join maintain_field_deal mfd 
			on mftd.field_id = mfd.field_id 
		left join maintain_field_template_group mfg 
			on mfg.field_group_id=mftd.field_group_id	
		WHERE mftd.field_template_id = '+ CAST(@field_template_id  AS VARCHAR)
		
	IF @field_group_id IS NOT NULL 
		SET @sql = @sql + ' AND mftd.field_group_id IN ('+ @field_group_id+')'
		
	IF @header_detail IS NOT NULL 
		SET @sql = @sql + ' AND mfd.header_detail = '''+ @header_detail +''''
		
	SET @sql = @sql + ' order  by mfg.seq_no,mftd.seq_no'
	exec spa_print @sql
	EXEC (@sql)
	
END
IF @flag = 'a'
BEGIN 
	
	SELECT [field_template_detail_id]
      ,[field_template_id]
      ,[field_group_id]
      ,[field_id]
      ,[seq_no]
      ,[is_disable]  
      ,[insert_required]
      ,[update_required]
      ,[field_caption]
      ,[default_value]
      ,[udf_or_system]
      ,[min_value]
      ,[max_value]
      ,[validation_id]
		FROM [maintain_field_template_detail]
			WHERE field_template_detail_id = @field_template_detail_id 
		
END
IF @flag = 'i'
BEGIN 
	
		INSERT maintain_field_template_detail
		(
		   [field_template_id],
		   [field_group_id],
		   [field_id],
		   [seq_no],
		   [is_disable], 
		   [insert_required], 
		   [update_required],
		   [field_caption],
		   [default_value],
		   [udf_or_system],
		   [min_value],
		   [max_value],
		   [validation_id]
		)
		VALUES
		(
			@field_template_id,
			@field_group_id,
			@field_id,
			@seq_no,
			@is_disable,
			@insert_required,
			@update_required,
			@field_caption,
			@default_value,
			@udf_of_system,
			@min_value,
			@max_value,
			@validation_id
      )
	
     EXEC spa_ErrorHandler 0,
			     'Field Template',
			     'spa_maintain_fields_templates',
			     'Success',
			     'Field Template successfully inserted.',
			     ''
			     
END
IF @flag = 'u'
BEGIN 
	
	update maintain_field_template_detail SET 
		[seq_no] = @seq_no
		  ,[is_disable] = @is_disable  
		  ,[insert_required] = @insert_required  
		  ,[update_required] = @update_required
		  ,[field_caption] = @field_caption
		  ,[default_value] = @default_value
		  ,[udf_or_system] = @udf_of_system
		  ,[min_value] = @min_value
		  ,[max_value] = @max_value
		  ,[validation_id] = @validation_id
		WHERE field_template_detail_id = @field_template_detail_id 
	
END
IF @flag = 'd'
BEGIN 
	DELETE maintain_field_template_detail 	WHERE field_template_detail_id = @field_template_detail_id 
	
	EXEC spa_ErrorHandler 0,
		 'Field Template',
		 'spa_maintain_fields_templates',
		 'Success',
		 'Field Template successfully removed.',
		 ''
END






GO


