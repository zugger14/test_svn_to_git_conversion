IF EXISTS (SELECT 1 FROM sys.objects WHERE [object_id] = OBJECT_ID(N'[dbo].[FNARWACOGWD]') AND [type] IN (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNARWACOGWD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	Get wacog value based on prior day, prior month and current month

	Parameters
	@source_deal_detail_id : source deal detail ID
	@wacog_option : WACOG Option
	
*/

CREATE FUNCTION [dbo].[FNARWACOGWD] (@source_deal_detail_id INT, @wacog_option INT)
RETURNS FLOAT AS
/*--------------------------Debug Params----------------------

DECLARE @source_deal_detail_id INT = 260284,
		@wacog_option INT = 110500
		SELECT * FROM static_data_value where type_id=110500
------------------------------------------------------------*/
BEGIN
	DECLARE @term DATETIME,
			@location_id INT,
			@ret_value FLOAT,
			@contract_id INT
	
	SET @wacog_option = ISNULL(@wacog_option, 110500)

	SELECT @term = term_start,
		   @location_id = location_id,
		   @contract_id = sdh.contract_id
	FROM source_deal_detail sdd
	INNER JOIN source_deal_header sdh ON sdh.source_deal_header_id = sdd.source_deal_header_id
	WHERE sdd.source_deal_detail_id = @source_deal_detail_id
						  
	SELECT @ret_value = w.wacog
	FROM (
		SELECT TOP(1) wacog 
		FROM dbo.calcprocess_storage_wacog
		WHERE 1 <> 1
			OR (
				(@wacog_option = 110500 AND term <= @term AND location_id = @location_id AND ISNULL(contract_id, -1) = ISNULL(@contract_id, -1)) OR --Prior Day
				(@wacog_option = 110501 AND CONVERT(VARCHAR(7), term, 120) = CONVERT(VARCHAR(7), DATEADD(MONTH, DATEDIFF(MONTH, -1, @term) - 1, -1), 120) AND location_id = @location_id AND ISNULL(contract_id, -1) = ISNULL(@contract_id, -1)) OR --Prior Month
				(@wacog_option = 110502 AND CONVERT(VARCHAR(7), term, 120) = CONVERT(VARCHAR(7), @term, 120) AND location_id = @location_id AND ISNULL(contract_id, -1) = ISNULL(@contract_id, -1)) --Current Month
			)
		
		ORDER BY term DESC
	) w
	
	RETURN @ret_value
END
GO