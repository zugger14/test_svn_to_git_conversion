 IF OBJECT_ID(N'[dbo].[spa_check_mdq_volume]', N'P') IS NOT NULL
     DROP PROCEDURE [dbo].spa_check_mdq_volume
 GO
  
 SET ANSI_NULLS ON
 GO
  
 SET QUOTED_IDENTIFIER ON
 GO
  
/*-- ===============================================================================================================
 Author: Dewanand Manandhar
 Create date: 2016-02-15
 Description: 
 Params:
 @flag CHAR(1)        - Description of param2

	declare @x  NUMERIC(38, 20)  exec [spa_check_mdq_volume] 'path', '2016-02-03', 12010, 2561 , @x output
	declare @x NUMERIC(38, 20) exec [spa_check_mdq_volume] 'contract','2016-02-03', 12010, 2561 , @x output

*/-- ===============================================================================================================

CREATE PROCEDURE [dbo].[spa_check_mdq_volume]
	@flag VARCHAR(20)
	, @flow_date DATETIME
	, @path_id INT 
	, @contract_id INT 
	, @avail_volume NUMERIC(38, 20) OUTPUT
	, @mdq_rmdq VARCHAR(200) OUTPUT

AS
SET NOCOUNT ON	

/*
DECLARE
	@flag VARCHAR(20) = 'PATH'
	, @flow_date DATETIME = '2016-04-05'
	, @path_id INT = 1296
	, @contract_id INT = 3610	
	, @avail_volume  NUMERIC(38, 20)
--*/


DECLARE  @created_volume NUMERIC(38, 20)
		, @max_avail_mdq_date DATETIME
		, @max_mdq_volume NUMERIC(38, 20)
		, @is_segmented CHAR(1)
		, @p_mdq_rmdq VARCHAR(100)
		, @c_mdq_rmdq VARCHAR(100)

	
IF OBJECT_ID('tempdb..#path_info') IS NOT NULL 
	DROP TABLE #path_info

IF OBJECT_ID('tempdb..#leg_path') IS NOT NULL 
	DROP TABLE #leg_path

IF OBJECT_ID('tempdb..#path_info1') IS NOT NULL 
	DROP TABLE #path_info1

IF OBJECT_ID('tempdb..#leg_path1') IS NOT NULL 
	DROP TABLE #leg_path1

SELECT @is_segmented = ISNULL(segmentation, 'n')
FROM contract_group 
WHERE contract_id = @contract_id


IF @flag IN('CONTRACT', 'MDQ_RMDQ')
BEGIN	 
	SELECT @max_avail_mdq_date = MAX(effective_date) 
	FROM transportation_contract_mdq
	WHERE contract_id = @contract_id
		AND effective_date <= @flow_date
	
	IF EXISTS(SELECT 1 
		FROM transportation_contract_mdq
		WHERE contract_id = @contract_id
			AND @max_avail_mdq_date IS NOT NULL
		)
	BEGIN 
		SELECT @max_mdq_volume = mdq
		FROM transportation_contract_mdq
		WHERE contract_id = @contract_id
			AND effective_date = @max_avail_mdq_date
	END
	ELSE 
	BEGIN
		SELECT @max_mdq_volume = ISNULL(mdq, 0)
		FROM contract_group 
		WHERE contract_id = @contract_id
	END

END
IF @flag IN('CONTRACT', 'MDQ_RMDQ') AND @is_segmented = 'y'
BEGIN
	SELECT  @max_avail_mdq_date = MAX(dpm.effective_date) 
	FROM delivery_path_mdq dpm
	WHERE dpm.effective_date <= @flow_date
		AND path_id = @path_id
		AND contract_id = @contract_id
	GROUP BY dpm.path_id

	--IF @max_mdq_volume IS NULL 
	--BEGIN
	--	IF EXISTS (	SELECT * 
	--				FROM delivery_path_mdq dpm
	--				WHERE dpm.path_id = @path_id 
	--					AND contract_id = @contract_id	
	--					AND @max_avail_mdq_date IS NOT NULL				
	--			)
 
	--	BEGIN
	--		SELECT @max_mdq_volume = MAX(dpm.mdq)
	--		FROM delivery_path dp
	--			INNER JOIN delivery_path_mdq dpm
	--				ON dp.path_id = dpm.path_id
	--		WHERE dp.path_id = @path_id 
	--			AND contract = @contract_id
	--			AND effective_date = @max_avail_mdq_date	
	--		GROUP BY dp.path_id, from_location, to_location, contract
	--	END
	--	ELSE 
	--	BEGIN
	--		SELECT @max_mdq_volume = ISNULL(mdq, 0)
	--		FROM delivery_path 
	--		WHERE path_id = @path_id
	--	END
	--END 

	SELECT  MAX(minor_from.source_minor_location_id) from_loc, 
		MAX(minor_to.source_minor_location_id) to_loc, 
		sdd.source_deal_header_id
	INTO #leg_path
	FROM source_deal_detail sdd
		INNER JOIN source_deal_header sdh 
			ON  sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_deal_header_template sdht 
			ON sdht.template_id = sdh.template_id
		LEFT JOIN source_minor_location minor_from 
			ON minor_from.source_minor_location_id = sdd.location_id AND sdd.Leg = 1
		LEFT JOIN source_minor_location minor_to 
			ON minor_to.source_minor_location_id = sdd.location_id AND sdd.Leg = 2
		WHERE sdht.template_name = 'Transportation NG' 
							AND sdd.term_start =  @flow_date
	GROUP BY sdd.source_deal_header_id


	SELECT dp.path_id, dp.from_location, to_location, contract contract_id 
		INTO #path_info
	FROM delivery_path dp
		LEFT JOIN delivery_path_mdq dpm
			ON dp.path_id = dpm.path_id
			AND effective_date = @max_avail_mdq_date
	WHERE dp.path_id = @path_id 
		AND dp.contract = @contract_id	
	GROUP BY dp.path_id, from_location, to_location, contract

	SELECT @created_volume =  SUM(deal_volume) 
	FROM source_deal_detail sdd
		INNER JOIN (
				SELECT  sdd.source_deal_header_id--, --* --minor_from.source_minor_location_id,minor_to.source_minor_location_id, sdd.source_deal_header_id, dp.path_id --, sum(sdd.deal_volume) deal_volume
				FROM source_deal_detail sdd
					INNER JOIN source_deal_header sdh 
						ON  sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN source_deal_header_template sdht 
						ON sdht.template_id = sdh.template_id
					INNER JOIN #leg_path lp on sdh.source_deal_header_id = lp.source_deal_header_id 
					INNER JOIN #path_info p 
						ON p.contract_id = sdh.contract_id
						AND (p.from_location = lp.from_loc) 
						AND (p.to_location =  lp.to_loc )
					WHERE sdht.template_name = 'Transportation NG' 
						AND sdd.term_start =  @flow_date		
					GROUP BY sdd.source_deal_header_id
		) s
			ON sdd.source_deal_header_id = s.source_deal_header_id
				and sdd.leg = 2

	SELECT @avail_volume = @max_mdq_volume - ISNULL(@created_volume, 0) 
	SET @c_mdq_rmdq = 'C-' + + CAST(dbo.FNARemoveTrailingZero(@max_mdq_volume) AS VARCHAR(50)) + '/' + CAST(dbo.FNARemoveTrailingZero(@avail_volume) AS VARCHAR(50))
	
END
ELSE IF @flag IN('CONTRACT', 'MDQ_RMDQ') AND @is_segmented = 'n'
BEGIN
	
	SELECT @created_volume = SUM(sdd.deal_volume)
	FROM  source_deal_detail sdd
		INNER JOIN source_deal_header sdh 
			ON  sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_deal_header_template sdht 
			ON sdht.template_id = sdh.template_id
		INNER JOIN contract_group cg
			ON cg.contract_id = sdh.contract_id
		WHERE sdht.template_name = 'Transportation NG' 
			AND sdd.term_start =  @flow_date
			AND sdh.contract_id = @contract_id
			AND sdd.leg = 2

	SELECT @avail_volume = @max_mdq_volume - ISNULL(@created_volume, 0) 
	SET @c_mdq_rmdq = 'C-' + CAST(dbo.FNARemoveTrailingZero(@max_mdq_volume) AS VARCHAR(50)) + '/' + CAST(dbo.FNARemoveTrailingZero(@avail_volume) AS VARCHAR(50))
END
IF @flag IN('PATH', 'MDQ_RMDQ')
BEGIN
	SELECT  @max_avail_mdq_date = MAX(dpm.effective_date) 
	FROM delivery_path_mdq dpm
	WHERE dpm.effective_date <= @flow_date
		AND path_id = @path_id
	GROUP BY dpm.path_id
	
	IF EXISTS (	SELECT 1 
				FROM delivery_path_mdq dpm
				WHERE dpm.path_id = @path_id 
					AND @max_avail_mdq_date IS NOT NULL				
			)
 
	BEGIN
		SELECT @max_mdq_volume = MAX(dpm.mdq)
		FROM delivery_path dp
			INNER JOIN delivery_path_mdq dpm
				ON dp.path_id = dpm.path_id
		WHERE dp.path_id = @path_id 
			AND effective_date = @max_avail_mdq_date	
		GROUP BY dp.path_id, from_location, to_location
	END
	ELSE 
	BEGIN
		SELECT @max_mdq_volume = ISNULL(mdq, 0)
		FROM delivery_path 
		WHERE path_id = @path_id
	END	

	SELECT  MAX(minor_from.source_minor_location_id) from_loc, 
		MAX(minor_to.source_minor_location_id) to_loc, 
		sdd.source_deal_header_id
	INTO #leg_path1
	FROM source_deal_detail sdd
		INNER JOIN source_deal_header sdh 
			ON  sdh.source_deal_header_id = sdd.source_deal_header_id
		INNER JOIN source_deal_header_template sdht 
			ON sdht.template_id = sdh.template_id
		LEFT JOIN source_minor_location minor_from 
			ON minor_from.source_minor_location_id = sdd.location_id AND sdd.Leg = 1
		LEFT JOIN source_minor_location minor_to 
			ON minor_to.source_minor_location_id = sdd.location_id AND sdd.Leg = 2
		WHERE sdht.template_name = 'Transportation NG' 
							AND sdd.term_start =  @flow_date
	GROUP BY sdd.source_deal_header_id


	SELECT dp.path_id, dp.from_location, to_location
		INTO #path_info1
	FROM delivery_path dp
		LEFT JOIN delivery_path_mdq dpm
			ON dp.path_id = dpm.path_id
			AND effective_date = @max_avail_mdq_date
	WHERE dp.path_id = @path_id
	GROUP BY dp.path_id, from_location, to_location

	SELECT @created_volume = SUM(deal_volume) 
	FROM source_deal_detail sdd
		INNER JOIN (
				SELECT sdd.source_deal_header_id
				FROM source_deal_detail sdd
					INNER JOIN source_deal_header sdh 
						ON  sdh.source_deal_header_id = sdd.source_deal_header_id
					INNER JOIN source_deal_header_template sdht 
						ON sdht.template_id = sdh.template_id
					INNER JOIN #leg_path1 lp 
						ON sdh.source_deal_header_id = lp.source_deal_header_id 
					INNER JOIN #path_info1 p 
						ON (p.from_location = lp.from_loc) 
						AND (p.to_location =  lp.to_loc )
					WHERE sdht.template_name = 'Transportation NG' 
						AND sdd.term_start =  @flow_date		
					GROUP BY sdd.source_deal_header_id
		) s
			ON sdd.source_deal_header_id = s.source_deal_header_id
				AND sdd.leg = 2

	SELECT @avail_volume = @max_mdq_volume - ISNULL(@created_volume, 0)  
	SET @p_mdq_rmdq = 'P-' + CAST(dbo.FNARemoveTrailingZero(@max_mdq_volume) AS VARCHAR(50)) + '/' + CAST(dbo.FNARemoveTrailingZero(@avail_volume) AS VARCHAR(50))
END
IF @flag = 'MDQ_RMDQ'
BEGIN
	SET @mdq_rmdq = @p_mdq_rmdq + CHAR(13) + CHAR(10) + @c_mdq_rmdq
END 


GO