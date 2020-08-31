IF EXISTS (
    SELECT 1
    FROM   sys.views
    WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[user_defined_deal_fields_template]')
)
    DROP VIEW [dbo].user_defined_deal_fields_template
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW user_defined_deal_fields_template 
AS 

SELECT
	uddft.[udf_template_id],
	uddft.[template_id],
	uddft.[field_name],
	uddft.[Field_label],
	uddft.[Field_type],
	uddft.[data_type],
	uddft.[is_required],
	uddft.[sql_string],
	uddft.[create_user],
	uddft.[create_ts],
	uddft.[update_user],
	uddft.[update_ts],
	uddft.[udf_type],
	uddft.sequence,
	uddft.[field_size],
	uddft.[field_id],
	uddft.[default_value],
	uddft.[book_id],
	uddft.[udf_group],
	uddft.[udf_tabgroup],
	uddft.[formula_id],
	uddft.[internal_field_type],
	uddft.[currency_field_id],
	uddft.[udf_user_field_id],
	uddft.[leg],
	uddft.[calc_granularity],
	uddft.deal_udf_type
FROM user_defined_deal_fields_template_main uddft
WHERE uddft.template_id IS NOT NULL 

UNION

SELECT
	udft.[udf_template_id]*-1 [udf_template_id],
	sdht.template_id [template_id],
	udft.[field_name],
	udft.[Field_label],
	udft.[Field_type],
	udft.[data_type],
	udft.[is_required],
	udft.[sql_string],
	udft.[create_user],
	udft.[create_ts],
	udft.[update_user],
	udft.[update_ts],
	udft.[udf_type],
	udft.[sequence],
	udft.[field_size],
	udft.[field_id],
	udft.[default_value],
	udft.[book_id],
	udft.[udf_group],
	udft.[udf_tabgroup],
	udft.[formula_id],
	udft.[internal_field_type],
	udft.[currency_field_id],
	udft.[udf_template_id] [udf_user_field_id],
	udft.[leg],
	udft.[calc_granularity],
	udft.deal_udf_type
FROM user_defined_fields_template udft
OUTER APPLY (
	SELECT template_id FROM source_deal_header_template 
) sdht
LEFT JOIN  user_defined_deal_fields_template_main uddft ON ISNULL(uddft.template_id, -1) = sdht.template_id AND uddft.udf_user_field_id = udft.udf_template_id
WHERE udft.udf_type <> 'o'
AND uddft.udf_template_id IS NULL