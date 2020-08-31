IF EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[FNARFieldValue]') AND TYPE IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
    DROP FUNCTION [dbo].[FNARFieldValue]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FNARFieldValue]
(
	@deal_id             INT,	-- if -ve  @deal_id then source_deal_detail_id else source_deal_header_id
	@granularity         INT,
	@maturity_date       VARCHAR(20),
	@as_of_date          VARCHAR(20),
	@he                  INT,
	@half                INT,
	@qtr                 INT,
	@counterparty_id     INT,
	@contract_id         INT,
	@audit_date          DATETIME,
	@udf_Charge_type     INT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @total_charge VARCHAR(100)
	DECLARE @udf_value VARCHAR(100)
	
	IF EXISTS(SELECT 1 FROM user_defined_deal_fields_template uddfp WHERE uddfp.[field_id] = @udf_Charge_type AND uddfp.udf_type = 'h')
	BEGIN
		IF @deal_id < 0
			SELECT @deal_id = source_deal_header_Id
			FROM   source_deal_detail
			WHERE  source_deal_detail_Id = ABS(@deal_id)
	END
	
	IF @audit_date IS NOT NULL
	BEGIN
	    IF EXISTS (SELECT 1 FROM user_defined_deal_fields_template uddfp WHERE uddfp.[field_id] = @udf_Charge_type AND uddfp.udf_type = 'h')
	        SELECT @udf_value = udf_value
	        FROM   (
	                   SELECT TOP 1 udf_value
	                   FROM   user_defined_deal_fields_audit uddf
	                          INNER JOIN user_defined_deal_fields_template uddfp
	                               ON  uddfp.udf_template_id = uddf.udf_template_id
	                               AND CONVERT(VARCHAR(10), uddf.update_ts, 120) 
	                                   <= @audit_date
	                               AND uddf.source_deal_header_Id = @deal_id
	                               AND uddfp.udf_type = 'h'
	                               AND uddfp.[field_id] = @udf_Charge_type
	                   ORDER BY
	                          uddf.create_ts DESC
	               ) a
	    ELSE
	        SELECT @udf_value = udf_value
	        FROM   (
	                   SELECT TOP 1 udf_value
	                   FROM   user_defined_deal_detail_fields_audit uddf
	                          INNER JOIN user_defined_deal_fields_template uddfp
	                               ON  uddfp.udf_template_id = uddf.udf_template_id
	                               AND CONVERT(VARCHAR(10), uddf.update_ts, 120)
	                                   <= @audit_date
	                               AND uddf.source_deal_detail_Id = ABS(@deal_id)
	                               AND uddfp.udf_type = 'd'
	                               AND uddfp.[field_id] = @udf_Charge_type
	                   ORDER BY
	                          uddf.create_ts DESC
	               ) a
	END
	
	IF @udf_value IS NULL
	BEGIN
	    IF EXISTS (SELECT 1 FROM user_defined_deal_fields_template uddfp WHERE uddfp.[field_id] = @udf_Charge_type AND uddfp.udf_type = 'h')
	        SELECT @udf_value = uddf.udf_value
	        FROM   user_defined_deal_fields_template uddfp
	               INNER JOIN user_defined_deal_fields uddf
	                    ON  uddfp.udf_template_id = uddf.udf_template_id
	                    AND uddfp.udf_type = 'h'
	                    AND uddf.source_deal_header_id = @deal_id
	                    AND uddfp.[field_id] = @udf_Charge_type
	    ELSE
	        SELECT @udf_value = udddf.udf_value
	        FROM   user_defined_deal_fields_template uddfp
	               INNER JOIN user_defined_deal_detail_fields udddf
	                    ON  uddfp.udf_template_id = udddf.udf_template_id
	                    AND uddfp.udf_type = 'd'
	                    AND udddf.source_deal_detail_id = ABS(@deal_id)
	                    AND uddfp.[field_id] = @udf_Charge_type
	END 
	
	SELECT @total_charge = (
	           CASE ISNUMERIC(@udf_value)
	                WHEN 1 THEN CAST(@udf_value AS FLOAT)
	                ELSE CAST(0 AS FLOAT)
	           END
	       )
	
	RETURN ISNULL(@total_charge, 0)
END