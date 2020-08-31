IF OBJECT_ID(N'[dbo].[spa_get_template_uom_index_frequency]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_get_template_uom_index_frequency
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: CRUD operations for table time_zone

-- Params:
-- @template_id INT- Template id
-- ===========================================================================================================

CREATE PROCEDURE [dbo].spa_get_template_uom_index_frequency
    @flag CHAR(1),
    @template_id INT = NULL,
    @app_user VARCHAR(500) = NULL
AS
IF @flag = 'g' --get frequency, uom, index
BEGIN
	SELECT	sddt.deal_volume_frequency, 
			+ CASE WHEN sddt.deal_volume_frequency = 'h' THEN 'Hourly' 
				WHEN sddt.deal_volume_frequency = 'd' THEN 'Daily'
				WHEN sddt.deal_volume_frequency = 'm' THEN 'Monthly'
				WHEN sddt.deal_volume_frequency = 't' THEN 'Term'
				WHEN sddt.deal_volume_frequency = 'a' THEN 'Annually'
				ELSE '' END AS frequency, 
			sddt.deal_volume_uom_id, 
			su.uom_name, 
			sddt.curve_id, 
			spcd.curve_name, 
			sdht.template_id
	FROM source_deal_header_template sdht
	INNER JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id
	LEFT JOIN source_price_curve_def spcd ON spcd.source_curve_def_id = sddt.curve_id
	LEFT JOIN source_uom su ON su.source_uom_id = sddt.deal_volume_uom_id
	WHERE sdht.template_id = @template_id
END 
IF @flag = 't' --to get user name mapped in trader
BEGIN
	SELECT st.source_trader_id, st.trader_desc FROM source_traders st 
	WHERE st.user_login_id = @app_user  
END

--insert into #temp_table values('h','Hourly')
--insert into #temp_table values('d','Daily')
--insert into #temp_table values('w','Weekly')
--insert into #temp_table values('m','Monthly')
--insert into #temp_table values('q','Quarterly')
--insert into #temp_table values('s','Semi-Annually')
--insert into #temp_table values('a','Annually')
--insert into #temp_table values('t','Term')

--SELECT sddt.deal_volume_frequency, sddt.deal_volume_uom_id, sddt.curve_id
--  FROM source_deal_header_template sdht
--INNER JOIN source_deal_detail_template sddt ON sdht.template_id = sddt.template_id
