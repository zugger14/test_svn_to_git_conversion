/****** Object:  UserDefinedFunction [dbo].[FNAGetTemplateFieldTable]    Script Date: 04/20/2012 10:21:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF EXISTS (
       SELECT *
       FROM   sys.objects
       WHERE  OBJECT_ID = OBJECT_ID(N'[dbo].[FNAGetTemplateFieldTable]')
              AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT')
   )
    DROP FUNCTION [dbo].[FNAGetTemplateFieldTable]
GO

CREATE FUNCTION [dbo].[FNAGetTemplateFieldTable]
(
	@template_id       INT,
	@header_detail     CHAR(1),
	@include_udf       CHAR(1) = NULL
)
RETURNS @List TABLE (
                        farrms_field_id VARCHAR(100) ,
                        field_lable VARCHAR(200) ,
                        default_value VARCHAR(100) ,
                        data_type VARCHAR(200) ,
                        is_udf CHAR(1) ,
                        insert_required CHAR(1) ,
                        update_required CHAR(1) ,
                        min_value VARCHAR(200) ,
                        max_value VARCHAR(200) 
                    )

BEGIN
	DECLARE @field_template_id INT
	SELECT @field_template_id = field_template_id FROM source_deal_header_template WHERE template_id = @template_id
	
	INSERT INTO @List
	SELECT mfd.farrms_field_id,
		   ISNULL(mftd.field_caption, mfd.default_label),	
	       mftd.default_value,
	       mfd.data_type,
	       'n',
	       COALESCE(mftd.insert_required, mfd.insert_required),
	       COALESCE(mftd.update_required, mfd.update_required),
	       CASE WHEN mfd.[data_type] = 'datetime' THEN dbo.FNAGetSQLStandardDate(mftd.min_value) ELSE CAST(mftd.min_value AS VARCHAR(200)) END,
	       CASE WHEN mfd.[data_type] = 'datetime' THEN dbo.FNAGetSQLStandardDate(mftd.max_value) ELSE CAST(mftd.max_value AS VARCHAR(200)) END
	FROM   maintain_field_deal mfd
	JOIN maintain_field_template_detail mftd ON  mftd.field_id = mfd.field_id
	WHERE  mftd.field_template_id = @field_template_id
	       AND ISNULL(udf_or_system, 's') = 's'
	       AND header_detail = @header_detail
	       AND CASE 
	                WHEN @header_detail = 'h' THEN field_group_id
	                ELSE '1'
	           END IS NOT NULL
	       AND mfd.farrms_field_id NOT IN ('source_deal_header_id', 
	                                      'source_deal_detail_id', 'create_user', 
	                                      'create_ts', 'update_user', 
	                                      'update_ts', 'template_id', 'assignment_type_value_id', 'compliance_year', 'state_value_id', 
										  'assigned_date', 'assigned_by')
	UNION
	SELECT mfd.farrms_field_id,
		   ISNULL(mftd.field_caption, mfd.default_label),	
	       mftd.default_value,
	       mfd.data_type,
	       'n',
	       COALESCE(mftd.insert_required, mfd.insert_required),
	       COALESCE(mftd.update_required, mfd.update_required),
	       CASE WHEN mfd.[data_type] = 'datetime' THEN dbo.FNAGetSQLStandardDate(mftd.min_value) ELSE CAST(mftd.min_value AS VARCHAR(200)) END,
	       CASE WHEN mfd.[data_type] = 'datetime' THEN dbo.FNAGetSQLStandardDate(mftd.max_value) ELSE CAST(mftd.max_value AS VARCHAR(200)) END
	FROM maintain_field_deal mfd 
	JOIN maintain_field_template_detail  mftd 
		ON mftd.field_id = mfd.field_id
		AND mftd.field_template_id = @field_template_id
		AND ISNULL(mftd.udf_or_system, 's') = 's' 
	WHERE header_detail = @header_detail AND mfd.farrms_field_id IN ('fixed_float_leg')	
	           
	           
	OPTION(MAXRECURSION 0)
	
	IF @include_udf = 'y'
	BEGIN
		INSERT INTO @List
		SELECT DISTINCT 
				'UDF___' + CAST(udf_temp.udf_template_id AS VARCHAR),
				ISNULL(mftd.field_caption, udf_temp.Field_label),
				CASE 
					WHEN udf_temp.Field_type = 'a' THEN dbo.FNADateFormat(ISNULL(mftd.default_value, udf_temp.default_value))
					ELSE ISNULL(mftd.default_value, udf_temp.default_value)
				END default_value,
				udf_temp.[data_type],
				'y',
				mftd.insert_required,
				mftd.update_required,
				CASE WHEN udf_temp.[data_type] = 'datetime' THEN dbo.FNAGetSQLStandardDate(mftd.min_value) ELSE CAST(mftd.min_value AS VARCHAR(200)) END,
				CASE WHEN udf_temp.[data_type] = 'datetime' THEN dbo.FNAGetSQLStandardDate(mftd.max_value) ELSE CAST(mftd.max_value AS VARCHAR(200)) END
		FROM   user_defined_fields_template udf_temp
		JOIN maintain_field_template_detail mftd
			ON  mftd.field_id = udf_temp.udf_template_id
			AND mftd.field_template_id = @field_template_id
			AND ISNULL(mftd.udf_or_system, 's') = 'u' 
		JOIN user_defined_deal_fields_template uddft
			ON uddft.udf_user_field_id = udf_temp.udf_template_id
			AND uddft.template_id = @template_id
		WHERE udf_temp.udf_type = @header_detail
	END
	RETURN
END

GO