IF OBJECT_ID('spa_hedge_capacity_report') IS NOT NULL
DROP PROC dbo.spa_hedge_capacity_report

GO
/*
*exec spa_Create_Available_Hedge_Capacity_Exception_Report '2011-10-31','1', null, null,'c','l',null,'a'
*exec dbo.spa_hedge_capacity_report '1' ,'2011-10-31'
*
*/

CREATE PROC dbo.spa_hedge_capacity_report 
@fas_sub_ids VARCHAR(1000),
@as_of_date VARCHAR(10),
@call_from varchar(1)=null
AS 
SET NOCOUNT ON 
DECLARE @st VARCHAR(MAX)

SET @st = '
		SELECT	dbo.fnadateformat(as_of_date) AsOfDate, fas_sub Subsidiary, fas_str Strategy,fas_book Book, IndexName '
		+case when isnull(@call_from,'g')='u' then ',TenorBucket,dbo.fnadateformat(term_start) TenorStart,dbo.fnadateformat(term_end) TenorEnd' else ', CONVERT(varchar(7), term_start, 120) ContractMonth' end +'
				,	vol_frequency VolumeFrequency, vol_uom VolumeUOM
				, 1.0 * CAST(net_asset_vol AS NUMERIC(18, 2)) [NetAssetVol(+Buy/-Sell)]
				,ISNULL( 1.0 * CAST(net_item_vol AS NUMERIC(18, 2)),0) [NetItemVol(+Buy/-Sell)]
				, 1.0 * CAST(net_available_vol AS NUMERIC(18, 2)) [AvailableCapacity(+Buy/-Sell)], over_hedge OverHedged
		FROM dbo.hedge_capacity_report WHERE as_of_date=''' + @as_of_date + ''' AND fas_sub_id IN (' + @fas_sub_ids + ')
		ORDER BY 2,3,4,5,term_start
		'
--PRINT(@st)
EXEC(@st)
