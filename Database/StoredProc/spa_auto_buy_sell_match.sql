IF EXISTS (SELECT 1 FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_auto_buy_sell_match]') AND TYPE IN (N'P', N'PC'))
    DROP PROCEDURE [dbo].[spa_auto_buy_sell_match]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/********************************************************************
 * Create date: 2020-02-24											
 * Description: Logic to match all REC deals using MatchAll option
 * Logic Written By : sbohara@pioneersolutionsglobal.com			
 * @flag ->	'c': It's done for only MatchAll so hard coded 'c' below 						
 * ******************************************************************/
CREATE PROCEDURE [dbo].[spa_auto_buy_sell_match]
	@flag CHAR(1),
	@link_id INT = NULL,
	@xmlValue TEXT = NULL,
	@set CHAR(1) = NULL,
	@source_deal_header_id VARCHAR(2000) = NULL,
	@sell_deal_detail_id VARCHAR(2000) = NULL,
	@source_deal_header_id_from VARCHAR(MAX) = NULL,
	@source_deal_detail_id_from VARCHAR(MAX) = NULL,
	@ignore_source_deal_header_id VARCHAR(2000) = NULL,
	@effective_date DATE = NULL,
	@delivery_date_from DATE = NULL,
	@delivery_date_to DATE = NULL,
	@region_id VARCHAR(70)= NULL,
	@not_region_id VARCHAR(70)= NULL,
	@jurisdiction  VARCHAR(MAX) = NULL,
	@not_jurisdiction  VARCHAR(MAX) = NULL,
	@tier_type VARCHAR(MAX) = NULL,
	@nottier_type VARCHAR(MAX) = NULL,
	@technology VARCHAR(MAX) = NULL,
	@not_technology VARCHAR(MAX) = NULL,
	@vintage_year VARCHAR(MAX) = NULL,
	@deal_detail_status VARCHAR(MAX) = NULL,
	@description VARCHAR(500) = NULL,
	@volume_match CHAR(1) = NULL,
	@include_expired_deals CHAR(1) = 'n',
	@show_all_deals CHAR(1) = NULL,
    @product_classification INT = NULL,
	@process_id VARCHAR(70)= NULL,
	@return_process_table VARCHAR(2000) = NULL
AS 

/********Debug Code*********
DECLARE @flag CHAR(1),
		@link_id INT = NULL,
		@xmlValue VARCHAR(MAX) = NULL,
		@set CHAR(1) = NULL,
		@source_deal_header_id VARCHAR(2000) = NULL,
		@sell_deal_detail_id VARCHAR(2000) = NULL,
		@source_deal_header_id_from VARCHAR(2000) = NULL,
		@source_deal_detail_id_from VARCHAR(MAX) = NULL,
		@ignore_source_deal_header_id VARCHAR(2000) = NULL,
		@effective_date DATE=NULL,
		@delivery_date_from DATE = NULL,
		@delivery_date_to DATE = NULL,
		@region_id VARCHAR(70)= NULL,
		@not_region_id VARCHAR(70)= NULL,
		@jurisdiction  VARCHAR(MAX) = NULL,
		@not_jurisdiction  VARCHAR(MAX) = NULL,
		@tier_type VARCHAR(MAX) = NULL,
		@nottier_type VARCHAR(MAX) = NULL,
		@technology VARCHAR(MAX) = NULL,
		@not_technology VARCHAR(MAX) = NULL,
		@vintage_year VARCHAR(MAX) = NULL,
		@deal_detail_status VARCHAR(MAX) = NULL,
		@description VARCHAR(500) = NULL,
		@volume_match CHAR(1) = NULL,
		@include_expired_deals CHAR(1) = 'n',
		@show_all_deals CHAR(1) = NULL,
		@product_classification INT = NULL,
		@process_id VARCHAR(70)= NULL,
		@return_process_table VARCHAR(2000) = NULL

SELECT @flag='g',@source_deal_header_id='224694',@source_deal_header_id_from='224067'

--*************************/
SET NOCOUNT ON

BEGIN
	IF OBJECT_ID(N'tempdb..#deal_info', N'U') IS NOT NULL
		DROP TABLE #deal_info

	CREATE TABLE #deal_info(id INT IDENTITY(1,1), source_deal_header_id INT, source_deal_detail_id INT)

	INSERT INTO #deal_info
	SELECT @source_deal_header_id, @sell_deal_detail_id
--SELECT @effective_date
	IF OBJECT_ID(N'tempdb..#tmp_calc_status_from_auto_match', N'U') IS NOT NULL
		DROP TABLE #tmp_calc_status_from_auto_match

	IF OBJECT_ID(N'tempdb..#tmp_calc_status_detail', N'U') IS NOT NULL
		DROP TABLE #tmp_calc_status_detail

	CREATE TABLE #tmp_calc_status_from_auto_match(
		error_code VARCHAR(100),	
		module VARCHAR(100),
		area VARCHAR(150),
		calc_status VARCHAR(100),
		message_desc VARCHAR(200),
		recommendation VARCHAR(500))

	SELECT NULL AS source_deal_detail_id, * 
	INTO #tmp_calc_status_detail 
	FROM #tmp_calc_status_from_auto_match WHERE 1 = 2

	DECLARE 
		@sell_deal_id INT, 
		@sell_detail_id INT, 
		@xmlVal VARCHAR(MAX), 
		@generator_id INT,
		@volume FLOAT,
		@tmpMatchAllRecs VARCHAR(150)

	DECLARE @i    INT = 1,
			@ii   INT = 1,
			@cid  INT

	SELECT @i = COUNT(*) FROM #deal_info

	WHILE (@ii <= @i)
	BEGIN
		SET @process_id = REPLACE(NEWID(), '-', '_')

		DELETE FROM #tmp_calc_status_from_auto_match

		SELECT 
			@sell_deal_id = source_deal_header_id,
			@sell_detail_id = source_deal_detail_id
		FROM #deal_info
		WHERE id = @ii

		SELECT @volume = sdd.volume_left, 
			@generator_id = sdh.generator_id
		FROM source_deal_header sdh
		INNER JOIN source_deal_detail sdd ON sdd.source_deal_header_id = sdh.source_deal_header_id
		WHERE sdd.source_deal_detail_id = @sell_detail_id 

		SET @xmlVal = 
		'<Root><FormXML term_start="" term_end="" counterparty_id="" deal_date_from="" deal_date_to="" create_ts_from="" create_ts_to="" generator_id="' + ISNULL(CAST(@generator_id AS VARCHAR(50)), '') + '" filter_mode="a" buy_sell_id="b" source_deal_header_id_from="" source_deal_header_id_to="" deal_id="" view_deleted="n" show_unmapped_deals="n" deal_locked="" book_ids="" view_voided="n" source_system_book_id1="" source_system_book_id2="" source_system_book_id3="" source_system_book_id4="" view_detail="y" sub_book_ids=""></FormXML></Root>'

		SET @xmlVal = ISNULL(@xmlValue, @xmlVal)

		EXEC spa_buy_sell_match 
			@flag='c', 
			@xmlValue = @xmlVal, 
			@set = @set, 
			@source_deal_header_id = @sell_deal_id, 
			@sell_deal_detail_id = @sell_detail_id,
			@source_deal_header_id_from = @source_deal_header_id_from,
			@source_deal_detail_id_from = @source_deal_detail_id_from,
			@ignore_source_deal_header_id = @ignore_source_deal_header_id,
			@effective_date = @effective_date,
			@delivery_date_from = @delivery_date_from,
			@delivery_date_to = @delivery_date_to,
			@region_id = @region_id,
			@not_region_id = @not_region_id,
			@jurisdiction = @jurisdiction,
			@not_jurisdiction= @not_jurisdiction,
			@tier_type = @tier_type,
			@nottier_type = @nottier_type,
			@technology = @technology,
			@not_technology = @not_technology,
			@vintage_year = @vintage_year,
			@deal_detail_status = @deal_detail_status,
			@description = @description,
			@volume_match = @volume_match,
			@include_expired_deals = @include_expired_deals,
			@show_all_deals = @show_all_deals,
			@product_classification = @product_classification,
			@process_id = @process_id,
			@return_process_table = @return_process_table

		SELECT @xmlVal = '
			<Root>
				<FormXML link_id="" process__id="" description="' + CAST(@sell_detail_id AS VARCHAR(50)) + '" effective_date="' + CAST(@effective_date AS VARCHAR(50)) + '" assignment_type="" group1="" group2="" group3="" group4="" hedging_relationship_type="" link_type="" match_status="" total_matched_volume ="' + CAST(@volume AS VARCHAR(50)) + '">
			</FormXML>
			<Grid>
				<GridRow source_deal_header_id="' + CAST(@sell_deal_id AS VARCHAR(50)) + '" source_deal_detail_id="' + CAST(@sell_detail_id AS VARCHAR(50)) + '" matched="' + CAST(@volume AS VARCHAR(50)) + '" vintage_year="" expiration_date="" sequence_from="" sequence_to="" set_id="1" state_value_id="" tier_value_id=""></GridRow>
			</Grid></Root>'

		IF NOT EXISTS(SELECT TOP 1 1 FROM #tmp_calc_status_from_auto_match)
		BEGIN
			EXEC spa_buy_sell_match @flag='i', @xmlValue = @xmlVal, @process_id = @process_id
		END

		INSERT INTO #tmp_calc_status_detail
		SELECT @sell_detail_id, * FROM #tmp_calc_status_from_auto_match

		SET @ii = @ii + 1
	END

	SELECT 
		error_code AS [ErrorCode],
		module AS Module,
		area AS Area,
		calc_status AS [Status],
		message_desc AS [Message],
		Recommendation
	FROM #tmp_calc_status_detail tcsd
END