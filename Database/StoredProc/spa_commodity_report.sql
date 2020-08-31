IF OBJECT_ID('spa_commodity_report') IS NOT NULL
DROP PROC dbo.spa_commodity_report

GO

/*
*exec spa_Create_Available_Hedge_Capacity_Exception_Report '2011-10-31','1', null, null,'c','l',null,'a'
*exec dbo.spa_hedge_capacity_report '1' ,'2011-10-31'
*
*/

CREATE PROC dbo.spa_commodity_report 
@flag varchar(10) = 'r',
@source_commodity_id VARCHAR(1000)  = null,
@commodity_group1 VARCHAR(10) = null,
@commodity_group2 VARCHAR(10)  = null,
@commodity_group3 VARCHAR(10)  = null,
@commodity_group4 VARCHAR(10)  = null,
@valuation_curve VARCHAR(10) = null,
@quality VARCHAR(10) = null
AS 

SET NOCOUNT ON

DECLARE @st VARCHAR(MAX)

	SET @st = 'SELECT sdv1.code AS [Commodity Group],
							sc.commodity_id AS [Commodity],
							spcd.curve_name AS [Valuation Curve],
							sdv.code AS [Quality]	
							FROM source_commodity sc
				FULL OUTER JOIN commodity_quality cq ON cq.source_commodity_id = sc.source_commodity_id
				INNER JOIN static_data_value sdv ON sdv.value_id = cq.quality
				INNER JOIN static_data_value sdv1 ON sdv1.value_id = sc.commodity_group1
				INNER join source_price_curve_def spcd ON spcd.source_curve_def_id = sc.valuation_curve
				WHERE 1 = 1 '

	IF @source_commodity_id IS NOT NULL 
		SET @st = @st + ' AND sc.source_commodity_id = ' + @source_commodity_id

	IF @valuation_curve IS NOT NULL 
		SET @st = @st + ' AND sc.valuation_curve = ' + @valuation_curve	

	IF @commodity_group1 IS NOT NULL 
		SET @st = @st + ' AND sc.commodity_group1 = ' + @commodity_group1	

	IF @commodity_group2 IS NOT NULL 
		SET @st = @st + ' AND sc.commodity_group2 = ' + @commodity_group2	

	IF @commodity_group3 IS NOT NULL 
		SET @st = @st + ' AND sc.commodity_group3 = ' + @commodity_group3	

	IF @commodity_group4 IS NOT NULL 
		SET @st = @st + ' AND sc.commodity_group3 = ' + @commodity_group4	

--PRINT(@st)
EXEC(@st)

