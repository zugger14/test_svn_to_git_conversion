IF OBJECT_ID(N'spa_Validate_Dedesignated_Links', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_Validate_Dedesignated_Links]
GO 

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
This Sp is used to validate the de-designated links
	Parameters: 
	@link_id  					: the designation link id being de-designated
	@d_link_id  				: the de-designation  link de-designating @link_id
	@d_percentage  				: This  is  the  % the dedesignation link can de-designate 
	@as_of_date  				: date to run 
	@use_regional_date_format	: Flag to use regional date format
	-- AllowedPercentageDedesignation - This is the % allowed to de-designate
	-- PercentageRelationship - This is  the % of the de-designation  link  used to de-designate
*/

CREATE PROC [dbo].[spa_Validate_Dedesignated_Links]
	@link_id INT, 
	@d_link_id INT, 
	@d_percentage FLOAT, 
	@as_of_date DATETIME, 
	@use_regional_date_format CHAR(1)
AS
  
SET NOCOUNT ON

/** Debug code 
	 drop table  #temp_Dedes
	 DECLARE @link_id int
	 DECLARE @d_link_id int
	 DECLARE @d_percentage float
	 DECLARE @as_of_date datetime
	 declare @use_regional_date_format varchar(1)
 
	 -- SET @link_id = 112
	 -- SET @d_link_id = 113
	 SET @link_id = 110
	 SET @d_link_id = 111
	 -- SET @link_id = 52
	 -- SET @d_link_id = 60
	 SET @use_regional_date_format = 'n'
	 SET @d_percentage = 1
	 SET @as_of_date = '6/30/2004'
--*/


SELECT 	CASE WHEN (nm.buy_sell_flag = dm.buy_sell_flag) THEN 'y'
			WHEN((nm.deal_volume / NULLIF(dm.deal_volume, 0)) IS NULL) THEN 'y' 
		ELSE 'n' END AS Exception, 
		COALESCE(NM.fas_book_id,DM.fas_book_id) AS fas_book_id, 
		COALESCE(NM.link_id, DM.link_id) AS link_id,
		COALESCE(NM.effective_date, DM.effective_date) AS effective_date,
        COALESCE(NM.dedesignated_link_id, DM.dedesignated_link_id) AS dedesignated_link_id, 
        COALESCE(NM.hedge_or_item, DM.hedge_or_item) AS hedge_or_item,
		COALESCE(NM.term_start, DM.term_start) AS term_start,
		COALESCE(NM.term_end, DM.term_end) AS term_end,
        COALESCE(NM.curve_id, DM.curve_id) AS curve_id,
		(nm.deal_volume / NULLIF(dm.deal_volume, 0)) AS percentage_dedesignated,
		1 - (nm.deal_volume / NULLIF(dm.deal_volume, 0))  AS allowed_percentage_dedesignated,
		nm.deal_volume AS d_volume, dm.deal_volume AS h_volume, 
		COALESCE(nm.deal_volume_uom_id, dm.deal_volume_uom_id) AS deal_volume_uom_id,
		(1 - (nm.deal_volume / NULLIF(dm.deal_volume, 0))) * dm.deal_volume / NULLIF(nm.deal_volume, 0) AS dedesignation_per_used,
		dm.buy_sell_flag
	INTO #temp_Dedes
FROM (
	SELECT  fas_book_id, link_id, effective_date,link_type_value_id, 
			dedesignated_link_id, percentage_dedesignated, 
			source_deal_type_id, deal_sub_type_type_id, 
			percentage_included, hedge_or_item, term_start, term_end, 
			buy_sell_flag, curve_id, deal_volume_uom_id,
			CASE WHEN  (deal_volume_uom_id = deal_volume_uom_id_to) THEN deal_volume
			ELSE (deal_volume * Conversion_factor) END As deal_volume
	FROM (SELECT fas_link_header.fas_book_id, fas_link_detail_dedesignation.link_id, fas_link_detail_dedesignation.effective_date,fas_link_header.link_type_value_id, 
				fas_link_detail_dedesignation.dedesignated_link_id, fas_link_detail_dedesignation.percentage_dedesignated, 
				source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
				fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
				source_deal_detail.buy_sell_flag, source_deal_detail.curve_id, 
				SUM(CASE WHEN (deal_volume_frequency = 'm') THEN 
				deal_volume * percentage_included
				ELSE 
				deal_volume * (DATEDIFF(day,term_start,term_end)+1) * percentage_included
				END) AS deal_volume,deal_volume_uom_id,
				MIN(deal_volume_uom_id) AS deal_volume_uom_id_to
			FROM fas_link_detail_dedesignation 
			INNER JOIN fas_link_detail 
			INNER JOIN fas_link_header ON fas_link_detail.link_id = fas_link_header.link_id 
			INNER JOIN source_deal_header ON fas_link_detail.source_deal_header_id = source_deal_header.source_deal_header_id 
			INNER JOIN source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id ON fas_link_detail_dedesignation.dedesignated_link_id = fas_link_header.link_id
			WHERE 	fas_link_detail_dedesignation.dedesignated_link_id = @link_id	
			GROUP BY fas_link_header.fas_book_id, fas_link_detail_dedesignation.link_id, fas_link_detail_dedesignation.effective_date, fas_link_header.link_type_value_id, 
                      fas_link_detail_dedesignation.dedesignated_link_id, fas_link_detail_dedesignation.percentage_dedesignated, 
                      source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
                      fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
                      source_deal_detail.buy_sell_flag, source_deal_detail.curve_id ,deal_volume_uom_id) A
	LEFT OUTER JOIN volume_unit_conversion vuc ON deal_volume_uom_id = from_source_uom_id AND deal_volume_uom_id_to = to_source_uom_id
) 
AS DM --this is a designation  link that is being de-designated
FULL OUTER JOIN
(
SELECT  fas_book_id, link_id,effective_date, link_type_value_id, 
		dedesignated_link_id, percentage_dedesignated, 
		source_deal_type_id, deal_sub_type_type_id, 
		percentage_included, hedge_or_item, term_start, term_end, 
		buy_sell_flag, curve_id, deal_volume_uom_id,
		CASE WHEN  (deal_volume_uom_id = deal_volume_uom_id_to) THEN deal_volume
		ELSE (deal_volume * Conversion_factor) END  As deal_volume
 FROM
	(SELECT fas_link_header.fas_book_id, fas_link_detail_dedesignation.link_id, fas_link_detail_dedesignation.effective_date, fas_link_header.link_type_value_id, 
			fas_link_detail_dedesignation.dedesignated_link_id, fas_link_detail_dedesignation.percentage_dedesignated, 
			source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
			fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
			source_deal_detail.buy_sell_flag, source_deal_detail.curve_id, 
			SUM(CASE WHEN (deal_volume_frequency = 'm') THEN 
			deal_volume *  percentage_dedesignated * percentage_included
			ELSE 
			deal_volume * (DATEDIFF(day,term_start,term_end)+1) * percentage_included *  percentage_dedesignated 
			END) AS deal_volume,
			deal_volume_uom_id,
			MIN(deal_volume_uom_id) AS deal_volume_uom_id_to
	FROM fas_link_detail_dedesignation 
	INNER JOIN fas_link_detail 
	INNER JOIN fas_link_header ON fas_link_detail.link_id = fas_link_header.link_id 
	INNER JOIN source_deal_header ON fas_link_detail.source_deal_header_id = source_deal_header.source_deal_header_id 
	INNER JOIN source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id ON fas_link_detail_dedesignation.link_id = fas_link_header.link_id
	WHERE fas_link_detail_dedesignation.dedesignated_link_id = @link_id	
	GROUP BY fas_link_header.fas_book_id, fas_link_detail_dedesignation.link_id, fas_link_detail_dedesignation.effective_date, fas_link_header.link_type_value_id, 
		fas_link_detail_dedesignation.dedesignated_link_id, fas_link_detail_dedesignation.percentage_dedesignated, 
		source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
		fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
		source_deal_detail.buy_sell_flag, source_deal_detail.curve_id, deal_volume_uom_id )A
LEFT OUTER JOIN volume_unit_conversion vuc ON deal_volume_uom_id = from_source_uom_id AND deal_volume_uom_id_to = to_source_uom_id
) AS NM  --this is a de-designation link that is designating DM
ON NM.fas_book_id = DM.fas_book_id 
	AND NM.link_id = DM.link_id
	AND NM.dedesignated_link_id=  DM.dedesignated_link_id 
	AND NM.hedge_or_item = DM.hedge_or_item 
	AND NM.term_start=DM.term_start 
	AND NM.term_end =  DM.term_end 
	AND NM.effective_date = DM.effective_date
	AND ISNULL(NM.curve_id,-1) = ISNULL(DM.curve_id, -1)
	AND NM.buy_sell_flag <> DM.buy_sell_flag

--select * from #temp_Dedes
--==============================================Check for over dedesignation==================================================
DECLARE @total_percent_dedesig FLOAT
--SET @total_percent_dedesig = (SELECT SUM())
--==============================================New dedesignation==============================================================
IF(@d_link_id IS NOT NULL) 
BEGIN
	INSERT INTO #temp_Dedes
	SELECT 	CASE 	WHEN(nm.buy_sell_flag = dm.buy_sell_flag) THEN 'y'
			WHEN((nm.deal_volume/ NULLIF(dm.deal_volume, 0)) IS NULL) THEN 'y' 
			ELSE 'n' END As Exception, 
			COALESCE(NM.fas_book_id,DM.fas_book_id) AS fas_book_id, 
			COALESCE(NM.link_id, DM.link_id) AS link_id,
			COALESCE(NM.effective_date, DM.effective_date) AS effective_date,
			COALESCE(NM.dedesignated_link_id, DM.dedesignated_link_id) AS dedesignated_link_id, 
			COALESCE(NM.hedge_or_item, DM.hedge_or_item) AS hedge_or_item,
			COALESCE(NM.term_start, DM.term_start) AS term_start,
			COALESCE(NM.term_end, DM.term_end) AS term_end,
			COALESCE(NM.curve_id, DM.curve_id) AS curve_id,
			(nm.deal_volume/ NULLIF(dm.deal_volume, 0)) AS percentage_dedesignated,
			1 - (nm.deal_volume/ NULLIF(dm.deal_volume, 0)) AS allowed_percentage_dedesignated,
			nm.deal_volume AS d_volume, dm.deal_volume AS h_volume, 
			COALESCE(nm.deal_volume_uom_id, dm.deal_volume_uom_id) AS deal_volume_uom_id,
			(1 - (nm.deal_volume / NULLIF(dm.deal_volume, 0))) * dm.deal_volume / NULLIF(nm.deal_volume, 0) AS dedesignation_per_used,
			dm.buy_sell_flag
	 FROM
	(
	SELECT  fas_book_id, link_id, effective_date, link_type_value_id, 
	        dedesignated_link_id, percentage_dedesignated, 
	        source_deal_type_id, deal_sub_type_type_id, 
	        percentage_included, hedge_or_item, term_start, term_end, 
	        buy_sell_flag, curve_id, deal_volume_uom_id,
			CASE WHEN  (deal_volume_uom_id = deal_volume_uom_id_to) THEN deal_volume
			ELSE (deal_volume * Conversion_factor) END As deal_volume
	 FROM
		(SELECT fas_link_header.fas_book_id, @d_link_id AS link_id, @as_of_date AS effective_date, fas_link_header.link_type_value_id, 
				@link_id AS dedesignated_link_id, @d_percentage AS percentage_dedesignated, 
				source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
				fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
				source_deal_detail.buy_sell_flag, source_deal_detail.curve_id, 
				SUM(CASE WHEN (deal_volume_frequency = 'm') THEN 
				deal_volume  * percentage_included
				ELSE 
				deal_volume * (DATEDIFF(day,term_start,term_end)+1) * percentage_included 
				END) AS deal_volume,deal_volume_uom_id,
				MIN(deal_volume_uom_id) AS deal_volume_uom_id_to
		FROM fas_link_detail INNER JOIN
		fas_link_header ON fas_link_detail.link_id = fas_link_header.link_id INNER JOIN
		source_deal_header ON fas_link_detail.source_deal_header_id = source_deal_header.source_deal_header_id INNER JOIN
		source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id 
		WHERE 	fas_link_header.link_id = @link_id	
		GROUP BY fas_link_header.fas_book_id, fas_link_header.link_id, fas_link_header.link_type_value_id, 
			source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
			fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
			source_deal_detail.buy_sell_flag, source_deal_detail.curve_id ,deal_volume_uom_id) A
	LEFT OUTER JOIN volume_unit_conversion vuc ON deal_volume_uom_id = from_source_uom_id AND deal_volume_uom_id_to = to_source_uom_id
	)
	AS DM --This is the designation  link being de-designated
	FULL OUTER JOIN
	(
	SELECT  fas_book_id, link_id,effective_date, link_type_value_id, 
	        dedesignated_link_id, percentage_dedesignated, 
	        source_deal_type_id, deal_sub_type_type_id, 
	        percentage_included, hedge_or_item, term_start, term_end, 
	        buy_sell_flag, curve_id, deal_volume_uom_id,
			CASE WHEN  (deal_volume_uom_id = deal_volume_uom_id_to) THEN deal_volume
			ELSE (deal_volume * Conversion_factor) END As deal_volume
	 FROM
		(SELECT fas_link_header.fas_book_id, @d_link_id AS link_id, @as_of_date AS effective_date, fas_link_header.link_type_value_id, 
				@link_id AS dedesignated_link_id, @d_percentage AS percentage_dedesignated, 
				source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
				fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
				source_deal_detail.buy_sell_flag, source_deal_detail.curve_id, 
				SUM(CASE WHEN (deal_volume_frequency = 'm') THEN 
						deal_volume * percentage_included * @d_percentage
					ELSE 
						deal_volume * (DATEDIFF(day,term_start,term_end)+1) * percentage_included * @d_percentage
					END) AS deal_volume,
				deal_volume_uom_id,
				MIN(deal_volume_uom_id) AS deal_volume_uom_id_to
		FROM fas_link_detail INNER JOIN
	        fas_link_header ON fas_link_detail.link_id = fas_link_header.link_id INNER JOIN
	        source_deal_header ON fas_link_detail.source_deal_header_id = source_deal_header.source_deal_header_id INNER JOIN
	        source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id 
		WHERE fas_link_header.link_id = @d_link_id	
		GROUP BY fas_link_header.fas_book_id, fas_link_header.link_id, fas_link_header.link_type_value_id, 
	        source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
	        fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
	        source_deal_detail.buy_sell_flag, source_deal_detail.curve_id, deal_volume_uom_id )A
	LEFT OUTER JOIN volume_unit_conversion vuc ON deal_volume_uom_id = from_source_uom_id AND deal_volume_uom_id_to = to_source_uom_id
	) AS NM  --This is the de-designation  link being designated
	
	ON NM.fas_book_id = DM.fas_book_id 
		AND NM.link_id = DM.link_id 
		AND NM.hedge_or_item = DM.hedge_or_item 
		AND NM.term_start=DM.term_start 
		AND NM.term_end =  DM.term_end 
		AND NM.effective_date = DM.effective_date
		AND ISNULL(NM.curve_id,-1) = ISNULL(DM.curve_id, -1)
		AND NM.buy_sell_flag <> DM.buy_sell_flag
END
	
IF @use_regional_date_format IS NULL
	SET @use_regional_date_format = 'n'

--This link is not dedesignated at all and this sp is called from % dedesgination
--Second condition is dedesignation by offsetting link
IF @d_link_id IS NULL AND (SELECT COUNT(1) FROM #temp_Dedes) = 0
BEGIN
	SELECT 	'No' AS  Exception,
		link_id AS [DedesigHedgingRelID],	
	--	@use_regional_date_format as use_regional_date_format,
		CASE WHEN  (@use_regional_date_format = 'n') THEN 
				links.effective_date 
			 ELSE dbo.FNADateFormat(links.effective_date) 
			 END AS [EffectiveDate],
		link_id AS [HedgingRelID],
		CASE WHEN  (hedge_or_item = 'h') THEN 'Hedge' ELSE 'Item' END [HedgeItem],
		CASE WHEN  (@use_regional_date_format = 'n') THEN term_start ELSE dbo.FNADateFormat(term_start) END AS [TermStart],
		CASE WHEN  (@use_regional_date_format = 'n') THEN term_end ELSE dbo.FNADateFormat(term_end) END AS [TermEnd],
		scd.curve_name AS [Index],
		0 AS [DedesignationVolume],
		CAST(ROUND(deal_volume, 2) AS VARCHAR)  AS [DesignationVolume],
		deal_volume_uom_id AS [UOMID],
		su.uom_name AS [UOM],
		0 AS [PercentageDedesignated],
		1 AS [AllowedPercentageDedesignation],
		0 AS  [PercentageRelationship]
	FROM
		(SELECT fas_link_header.fas_book_id, @link_id AS link_id,  @as_of_date AS effective_date, 
				fas_link_header.link_type_value_id, 
				@link_id AS dedesignated_link_id, 1 AS percentage_dedesignated, 
				source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
				fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
				source_deal_detail.buy_sell_flag, source_deal_detail.curve_id, 
				SUM(CASE WHEN (deal_volume_frequency = 'm') THEN 
						deal_volume  * percentage_included
					ELSE 
						deal_volume * (DATEDIFF(day,term_start,term_end)+1) * percentage_included 
				END) AS deal_volume,
				deal_volume_uom_id
		FROM fas_link_detail INNER JOIN
			fas_link_header ON fas_link_detail.link_id = fas_link_header.link_id INNER JOIN
			source_deal_header ON fas_link_detail.source_deal_header_id = source_deal_header.source_deal_header_id INNER JOIN
			source_deal_detail ON source_deal_header.source_deal_header_id = source_deal_detail.source_deal_header_id 
		WHERE 	fas_link_header.link_id = @link_id	
		GROUP BY fas_link_header.fas_book_id, fas_link_header.link_id, fas_link_header.link_type_value_id, 
			source_deal_header.source_deal_type_id, source_deal_header.deal_sub_type_type_id, 
			fas_link_detail.percentage_included, fas_link_detail.hedge_or_item, source_deal_detail.term_start, source_deal_detail.term_end, 
			source_deal_detail.buy_sell_flag, source_deal_detail.curve_id ,deal_volume_uom_id) links
	LEFT OUTER JOIN source_price_curve_def scd ON  scd.source_curve_def_id = links.curve_id 
	LEFT OUTER JOIN source_uom su ON su.source_uom_id = links.deal_volume_uom_id
	ORDER BY links.link_id, links.hedge_or_item, links.term_start
END
ELSE
BEGIN
	SELECT 	CASE WHEN  (Exception = 'y')  THEN 'Yes' ELSE 'No' END AS Exception,
			link_id AS [DedesigHedgingRelID],	
			CASE WHEN  (@use_regional_date_format = 'n') THEN effective_date ELSE dbo.FNADateFormat(effective_date) 
				END AS [EffectiveDate],
			dedesignated_link_id AS [HedgingRelID],
			CASE WHEN (hedge_or_item = 'h') THEN 'Hedge' ELSE 'Item' END [HedgeItem],
			CASE WHEN (@use_regional_date_format = 'n') THEN term_start ELSE dbo.FNADateFormat(term_start) END AS [TermStart],
			CASE WHEN (@use_regional_date_format = 'n') THEN term_end ELSE dbo.FNADateFormat(term_end) END AS [TermEnd],
			scd.curve_name AS [Index],
			CAST(ROUND(d_volume, 2) AS VARCHAR) AS [DedesignationVolume],
			CAST(ROUND(h_volume, 2) AS VARCHAR) AS [DesignationVolume],
			deal_volume_uom_id AS [UOMID],
			su.uom_name AS [UOM],
			CAST(ROUND(percentage_dedesignated, 2) AS VARCHAR) AS [PercentageDedesignated],
			CAST(ROUND(CASE WHEN   (allowed_percentage_dedesignation > percentage_dedesignated) THEN
						percentage_dedesignated ELSE allowed_percentage_dedesignation 
					END, 2) AS VARCHAR) As [AllowedPercentageDedesignation],
			CAST(ROUND(CASE WHEN   (allowed_percentage_dedesignation > percentage_dedesignated) THEN
						percentage_dedesignated ELSE allowed_percentage_dedesignation 
					END * ISNULL(h_volume, 0)/NULLIF(d_volume, 0), 2) AS VARCHAR) AS  [PercentageRelationship]
	FROM (
		SELECT  A.Exception, A.fas_book_id, A.link_id, A.effective_date, A.dedesignated_link_id, A.hedge_or_item, A.term_start, A.term_end, A.curve_id, A.percentage_dedesignated, 
			SUM(running_percentage_dedesignated) AS running_percentage_dedesignated, 
			CASE WHEN (1 - (SUM(running_percentage_dedesignated) - percentage_dedesignated)) < 0 THEN 0
				WHEN (1 - (SUM(running_percentage_dedesignated) - percentage_dedesignated)) > percentage_dedesignated THEN percentage_dedesignated 
				ELSE  (1 - (SUM(running_percentage_dedesignated) - percentage_dedesignated)) END 
			AS allowed_percentage_dedesignation,
			--		1 AS allowed_percentage_dedesignation,
			A.d_volume, A.h_volume, 
			A.deal_volume_uom_id	
		FROM  #temp_Dedes A
		INNER JOIN (SELECT  effective_date, hedge_or_item, term_start, term_end, curve_id, SUM(percentage_dedesignated) AS running_percentage_dedesignated, buy_sell_flag
					FROM #temp_Dedes
					GROUP BY effective_date, hedge_or_item, term_start, term_end, curve_id, buy_sell_flag
				) B ON A.buy_sell_flag = B.buy_sell_flag 
			AND A.hedge_or_item = B.hedge_or_item 
			AND A.term_start = B.term_start 
			AND A.term_end = B.term_end 
			AND ISNULL(A.curve_id, -1) = ISNULL(B.curve_id , -1)
			AND A.effective_date > = B.Effective_date
		WHERE a.percentage_dedesignated IS NOT NULL
		GROUP BY A.Exception, A.fas_book_id, A.link_id, A.effective_date, A.dedesignated_link_id, A.hedge_or_item, A.term_start, A.term_end, A.curve_id, A.percentage_dedesignated,
			A.d_volume, A.h_volume, 
			A.deal_volume_uom_id,
			A.dedesignation_per_used, A.buy_sell_flag
	) links 
	LEFT OUTER JOIN source_price_curve_def scd ON  scd.source_curve_def_id = links.curve_id 
	LEFT OUTER JOIN source_uom su ON su.source_uom_id = links.deal_volume_uom_id
	ORDER BY links.link_id, links.hedge_or_item, links.term_start
	--having a.link_id = 51 --a.term_start = '6/1/2005' and percentage_dedesignated IS NOT NULL
END

GO





