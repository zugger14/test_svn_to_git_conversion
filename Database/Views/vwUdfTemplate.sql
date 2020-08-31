SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

IF OBJECT_ID(N'dbo.vwUdfTemplate', N'V') IS NOT NULL DROP VIEW dbo.vwUdfTemplate
GO

CREATE VIEW [dbo].[vwUdfTemplate]
AS 
	SELECT
		udf_template_id
		,field_name
		,field_type
		,data_type
		,data_source_type_id
		,window_id
		,formula_id
		,internal_field_type
		,leg
		,sql_string
		,udf_type
		,default_value
		,udf_category
		,deal_udf_type
		,field_id
		,field_label
		,'' test
		,CASE WHEN field_type = 'a' 
				THEN default_value 
			  ELSE NULL 
		 END default_value_date
		,include_in_credit_exposure
	FROM user_defined_fields_template