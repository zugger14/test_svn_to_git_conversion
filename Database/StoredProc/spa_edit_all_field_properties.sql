
IF OBJECT_ID('dbo.spa_edit_all_field_properties', 'p') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.spa_edit_all_field_properties
END
GO

CREATE PROC dbo.spa_edit_all_field_properties
	@flag CHAR(1),
	@xml VARCHAR(MAX) = NULL

AS

DECLARE @idoc INT

EXEC sp_xml_preparedocument @idoc OUTPUT, @xml

CREATE TABLE #maintain_field_template_detail
(
	field_template_detail_id  INT,
	field_caption             VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	is_disable                VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	insert_required           VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	default_value             VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	udf_or_system             VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	min_value                 VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	max_value                 VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	buy_label                 VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	sell_label                VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	update_required           VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	hide_control              VARCHAR(MAX) COLLATE DATABASE_DEFAULT ,
	display_format            VARCHAR(MAX) COLLATE DATABASE_DEFAULT 
)

IF @flag = 'u'
    DECLARE @field_template_ids VARCHAR(MAX)
    DECLARE @field_template_detail_id INT

BEGIN
	BEGIN TRY
		INSERT INTO #maintain_field_template_detail
		  (
	  		field_template_detail_id,
			field_caption,
			is_disable,
			insert_required,
			default_value,
			udf_or_system,
			min_value,
			max_value,
			buy_label,
			sell_label,
			update_required,
			hide_control,
			display_format
		  )
		SELECT  field_template_detail_id,
				field_caption,
				is_disable,
				insert_required,
				default_value,
				udf_or_system,
				min_value,
				max_value,
				buy_label,
				sell_label,
				update_required,
				hide_control,
				display_format
		FROM   OPENXML(@idoc, '/Root/PSRecordset', 1)
			   WITH (
	       		   field_template_detail_id INT '@editGrid1',
				   field_caption VARCHAR(MAX) '@editGrid2',
				   is_disable VARCHAR(MAX) '@editGrid3',
				   insert_required VARCHAR(MAX) '@editGrid4',
				   default_value VARCHAR(MAX) '@editGrid5',
				   udf_or_system VARCHAR(MAX) '@editGrid6',
				   min_value VARCHAR(MAX) '@editGrid7',
				   max_value VARCHAR(MAX) '@editGrid8',
				   buy_label VARCHAR(MAX) '@editGrid9',
				   sell_label VARCHAR(MAX) '@editGrid10',
				   update_required VARCHAR(MAX) '@editGrid11',
				   hide_control VARCHAR(MAX) '@editGrid12',
				   display_format VARCHAR(MAX) '@editGrid13'
			   )
		
		MERGE maintain_field_template_detail AS mftd
		USING #maintain_field_template_detail AS temp_mftd ON temp_mftd.field_template_detail_id = mftd.field_template_id
		AND temp_mftd.field_caption = mftd.field_caption
		
		WHEN MATCHED THEN
		UPDATE SET			
			mftd.field_caption = temp_mftd.field_caption,
			mftd.is_disable = temp_mftd.is_disable,
			mftd.insert_required = temp_mftd.insert_required,
			mftd.default_value = temp_mftd.default_value,
			mftd.udf_or_system = temp_mftd.udf_or_system,
			mftd.min_value = temp_mftd.min_value,
			mftd.max_value = temp_mftd.max_value,
			mftd.buy_label = temp_mftd.buy_label,
			mftd.sell_label = temp_mftd.sell_label,
			mftd.update_required = temp_mftd.update_required,
			mftd.hide_control = temp_mftd.hide_control,
			mftd.display_format = temp_mftd.display_format
		;	
				
		EXEC spa_ErrorHandler 0,
             '',
             'spa_edit_all_field_properties',
             'Success',
             'Data successfully saved.',
             ''	
		END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
             '',
             'spa_edit_all_field_properties',
             'Error',
             'Error while updating.',
             ''	
	END CATCH
END			
