IF OBJECT_ID(N'[dbo].[spa_eod_calc_remnant_position_after_deal_update]', N'P') IS NOT NULL
    DROP PROC [dbo].[spa_eod_calc_remnant_position_after_deal_update]
GO

-- ============================================================================================================================
-- Author: Pawan Adhikari
-- Create date: 2012-03-09 08:45PM
-- Description: Calculate Positions for Deals.
--              
-- Params:
-- ============================================================================================================================
CREATE PROC [dbo].[spa_eod_calc_remnant_position_after_deal_update]
AS
BEGIN
	
	-- Deals having position update timestamp < deal update timestamp.
	
	DECLARE @spa             VARCHAR(MAX),
	        @job_name        VARCHAR(150),
	        @user_login_id   VARCHAR(30),
	        @effected_deals  VARCHAR(150),
	        @st              VARCHAR(MAX),
	        @process_id      VARCHAR(100),
	        @term_start      VARCHAR(20),
	        @term_end        VARCHAR(20)	

	SET @user_login_id = 'farrms_admin'

	SET @process_id = dbo.FNAGetNewID()
	SET @effected_deals = dbo.FNAProcessTableName('report_position', @user_login_id, @process_id)

	SET @st='CREATE TABLE '+ @effected_deals +'(source_deal_header_id INT, [action] varchar(1)) '
	
	exec spa_print @st
	EXEC(@st)

	--CHANGE HERE to SELECT the required deals
		
	SET @st='INSERT INTO '+@effected_deals +
			' SELECT DISTINCT sdd.source_deal_header_id, ''u''
			  FROM source_deal_detail sdd
				INNER JOIN source_deal_header sdh ON  sdd.source_deal_header_id = sdh.source_deal_header_id
					AND sdh.update_ts BETWEEN CONVERT(VARCHAR(10), GETDATE(), 120) + '' 00:00:00.000'' AND CONVERT(VARCHAR(10), GETDATE(), 120) + '' 23:59:59.000''
				CROSS APPLY(
				  SELECT rp.source_deal_header_id,
						 rp.create_ts
				  FROM report_hourly_Position_deal rp
				  WHERE source_deal_header_Id = sdh.source_deal_header_Id
			      
				  UNION
			      
				  SELECT rp.source_deal_header_id,
						 rp.create_ts
				  FROM report_hourly_Position_profile rp
				  WHERE source_deal_header_Id = sdh.source_deal_header_Id
			  ) a
			  WHERE  a.create_ts < sdh.update_ts '

	EXEC(@st)

	SET @job_name = 'calc_deal_position_breakdown' + @process_id
	EXEC [dbo].[spa_deal_position_breakdown] 'i', NULL, @user_login_id, @process_id

	SET @spa = 'spa_update_deal_total_volume NULL,'''+@process_id+''',0,1,''' + @user_login_id + ''''	

	EXEC (@spa)
	
END

