IF OBJECT_ID(N'[dbo].[spa_update_total_volume_hypo]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_update_total_volume_hypo]
GO

-- ===========================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 2016-03-16
-- Description: Updates total Volume for hypothetical deals
 
-- Params:
-- @id     INT
-- ===========================================================================================================

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_update_total_volume_hypo]
	@id INT,
	@return_value BIT = 0
AS
SET NOCOUNT ON
/*
DECLARE @id INT = 9
DECLARE @return_value BIT = 1

--*/

DECLARE @buy_total_volume NUMERIC(38,20)
DECLARE @sell_total_volume NUMERIC(38,20)
DECLARE @base_load_id INT
DECLARE @dst_group_value_id INT


SELECT @dst_group_value_id = tz.dst_group_value_id
	FROM dbo.adiha_default_codes_values adcv
		INNER JOIN time_zones tz ON tz.timezone_id = adcv.var_value
	WHERE adcv.instance_no = 1
		AND adcv.default_code_id = 36
		AND adcv.seq_no = 1

SELECT @base_load_id = value_id
FROM static_data_value 
where type_id = 10018
AND code = 'Base Load'

SELECT @buy_total_volume = SUM(pmo.buy_volume * 
							CASE pmo.buy_volume_frequency 
								WHEN 'h' THEN hbt.volume_mult 
								WHEN 'd' THEN DATEDIFF(DAY, buy_term_start,buy_term_end) + 1 
								WHEN 't' THEN 1 
								WHEN 'm' THEN 
									CASE WHEN DAY(buy_term_start) = 1 AND DAY(buy_term_end + 1) = 1 
									THEN DATEDIFF(MONTH, buy_term_start, buy_term_end + 1)
									ELSE CAST(DATEDIFF(DAY, buy_term_start, buy_term_end) + 1 AS NUMERIC(30,20)) / DATEDIFF(DAY, CAST(dbo.FNAGetContractMonth(buy_term_start) AS DATETIME), DATEADD(MONTH, 1, CAST(dbo.FNAGetContractMonth(buy_term_end) AS DATETIME)))
									END
							END)
FROM portfolio_mapping_other pmo 
	LEFT JOIN hour_block_term hbt
		ON ISNULL(hbt.block_define_id, @base_load_id) = ISNULL(pmo.block_definition, @base_load_id)
		AND pmo.buy_volume_frequency = 'h'
		AND term_date BETWEEN buy_term_start AND buy_term_end
		AND hbt.dst_group_value_id = @dst_group_value_id
WHERE pmo.portfolio_mapping_other_id = @id	

SELECT @sell_total_volume = SUM(pmo.sell_volume * 
							CASE pmo.sell_volume_frequency 
								WHEN 'h' THEN hbt.volume_mult
								WHEN 'd' THEN DATEDIFF(DAY, sell_term_start,sell_term_end) + 1 
								WHEN 't' THEN 1 
								WHEN 'm' THEN 
									CASE WHEN DAY(sell_term_start) = 1 AND DAY(sell_term_end + 1) = 1 
									THEN DATEDIFF(MONTH, sell_term_start, sell_term_end + 1)
									ELSE CAST(DATEDIFF(DAY, sell_term_start, sell_term_end) + 1 AS NUMERIC(38,20)) / DATEDIFF(DAY, CAST(dbo.FNAGetContractMonth(sell_term_start) AS DATETIME), DATEADD(MONTH, 1, CAST(dbo.FNAGetContractMonth(sell_term_end) AS DATETIME)))
									END
							END)
FROM portfolio_mapping_other pmo 
	LEFT JOIN hour_block_term hbt
		ON ISNULL(hbt.block_define_id, @base_load_id) = ISNULL(pmo.block_definition, @base_load_id)
		AND term_date BETWEEN sell_term_start AND sell_term_end
		AND pmo.sell_volume_frequency = 'h'
		AND hbt.dst_group_value_id = @dst_group_value_id
WHERE pmo.portfolio_mapping_other_id = @id		
	
UPDATE portfolio_mapping_other
	SET buy_total_volume = NULLIF(@buy_total_volume, 0),
		sell_total_volume = NULLIF(@sell_total_volume, 0)
WHERE portfolio_mapping_other_id = @id

IF @return_value = 1
SELECT @buy_total_volume, @sell_total_volume


