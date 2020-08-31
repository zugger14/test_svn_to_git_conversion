IF OBJECT_ID(N'[dbo].[spa_deal_default_value_maping]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_default_value_maping]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spa_deal_default_value_maping]
    @flag NCHAR(1)
AS
SET NOCOUNT ON
 
IF @flag = 's'
BEGIN
	SELECT	ddv.deal_default_value_id, 
			sdt.source_deal_type_name AS deal_type_id,
			sdv.code AS pricing_type,
			sc.commodity_name AS commodity,
			CASE ddv.buy_sell_flag WHEN 'b' THEN 'Buy' WHEN 's' THEN 'Sell' ELSE 'All' END buy_sell_flag,
			idtst.internal_deal_type_subtype_type AS internal_deal_type,
			idtst2.internal_deal_type_subtype_type AS internal_deal_sub_type,
			sdv4.code AS actual_granularity,
			sdv5.code AS volume_frequency,
			ddv.term_frequency,
			CASE WHEN ddv.pay_opposite = 'y' THEN 'Yes' ELSE 'No' END AS pay_opposite,
			sdt2.source_deal_type_name AS deal_sub_type_type_id,
			sdv7.code AS underlying_options,
			CASE WHEN  ddv.physical_financial_flag  = 'p' THEN 'Physical' ELSE 'Financial' END AS physical_financial_flag
		FROM deal_default_value ddv
		LEFT JOIN source_deal_type AS sdt ON sdt.source_deal_type_id = ddv.deal_type_id
		LEFT JOIN static_data_value AS sdv ON sdv.value_id = ddv.pricing_type
		LEFT JOIN source_commodity AS sc ON sc.source_commodity_id = ddv.commodity
		LEFT JOIN internal_deal_type_subtype_types idtst ON ddv.internal_deal_type = idtst.internal_deal_type_subtype_id
		LEFT JOIN internal_deal_type_subtype_types idtst2 ON ddv.internal_deal_sub_type = idtst2.internal_deal_type_subtype_id
		LEFT JOIN static_data_value AS sdv4 ON sdv4.value_id = ddv.actual_granularity
		LEFT JOIN static_data_value AS sdv5 ON sdv5.value_id = ddv.volume_frequency
		LEFT JOIN source_deal_type sdt2 ON ddv.deal_sub_type_type_id = sdt2.source_deal_type_id
		LEFT JOIN static_data_value AS sdv7 ON sdv7.value_id = ddv.underlying_options

		ORDER BY sdt.source_deal_type_name
								
END
IF @flag = 'p'
BEGIN
	SELECT value_id,code FROM static_data_value AS sdt WHERE sdt.[type_id] = 46700
END


IF @flag = 'c'
BEGIN
	SELECT source_commodity_id,commodity_name FROM source_commodity AS sc
END

IF @flag = 'q'
BEGIN
	--SELECT value_id,code FROM static_data_value AS sdv WHERE sdv.[type_id] = 5004
	SELECT 
		internal_deal_type_subtype_id,
		internal_deal_type_subtype_type
	FROM internal_deal_type_subtype_types 
	WHERE type_subtype_flag IS NULL
END

IF @flag = 'w'
BEGIN
	SELECT 
		internal_deal_type_subtype_id,
		internal_deal_type_subtype_type
	FROM internal_deal_type_subtype_types 
	WHERE type_subtype_flag = 'y'
END

IF @flag = 'x'
BEGIN
	--SELECT value_id,code FROM static_data_value AS sdv WHERE sdv.value_id =  1225
	SELECT 
		source_deal_type_id,
		source_deal_type_name
	FROM source_deal_type 
	WHERE sub_type='n'
END


IF @flag = 'v'
BEGIN
	SELECT value_id,code FROM static_data_value AS sdt WHERE sdt.[type_id] = 978
END

IF @flag = 'g'
BEGIN
	--SELECT value_id,code FROM static_data_value AS sdt WHERE sdt.[type_id] = 978
	EXEC spa_getVolumeFrequency
END

IF @flag = 'h'
BEGIN
	SELECT value_id,code FROM static_data_value AS sdt WHERE sdt.[type_id] = 978
	--EXEC spa_getVolumeFrequency
END

IF @flag = 'e'
BEGIN
	--SELECT value_id,code FROM static_data_value AS sdv WHERE sdv.value_id =  1225
	SELECT
		source_deal_type_id,
		deal_type_id
	FROM source_deal_type 
	WHERE sub_type='y'
END

IF @flag = 'f'
BEGIN
	SELECT 'p' code,'Physical' Data UNION  SELECT 'f' code,'Financial' Data
END


IF @flag = 'a'
BEGIN
	select value_id,code from static_data_value where type_id = 46900
END
