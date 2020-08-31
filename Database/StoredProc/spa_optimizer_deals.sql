
IF OBJECT_ID(N'[dbo].[spa_optimizer_deals]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_optimizer_deals]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===============================================================================================================
-- Author: Dewanand Manandhar
-- Create date: 2016-02-03
-- ===============================================================================================================

 CREATE PROC [dbo].[spa_optimizer_deals]
	@flag CHAR(1),
	@optimizer_header_id INT = NULL,
	@optimizer_detail_id INT = NULL,
	@source_deal_header_id INT = NULL,
	@optimizer_xml VARCHAR(MAX) = NULL,
	@from_detail_id INT = NULL,
	@reschedule_deal_id INT = NULL,
	@injection_deal_id INT = NULL,
	@withdrawal_deal_id INT = NULL
AS
SET NOCOUNT ON
/*
DECLARE @optimizer_xml VARCHAR(MAX) 
DECLARE @flag CHAR(1) = 'h'
DECLARE @source_deal_header_id int = 36804
DECLARE @reschedule_deal_id INT =36801
declare @from_detail_id INT = NULL

--SET @optimizer_xml = '<optimizer>
--						<header id="" flow_date="2016-02-03" transport_deal_id="351859" package_id="2312323423434" SLN_id="1" receipt_location_id="27528" delivery_location_id="27385" rec_nom_volume="539" del_nom_volume="599" />
--						<detail id="1" optimizer_header_id="" flow_date="2016-02-03" transport_deal_id="351859" up_down_stream="U" source_deal_header_id = "282357" source_deal_detail_id="419863" volume_used="10" />
--					</optimizer>'

SELECT * from optimizer_header order by 1 desc --where transport_deal_id = 351859 order by 1 desc
SELECT * from optimizer_detail --where transport_deal_id = 351859 order by 1 desc



exec [spa_optimizer_deals] 'h', null, null, 36804, null, null, 36801

--*/
DECLARE @idoc INT

IF @flag = 'i'
BEGIN	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @optimizer_xml 
	
	INSERT INTO optimizer_header(
		flow_date, 
		transport_deal_id, 
		package_id,  
		SLN_id, 
		receipt_location_id, 
		delivery_location_id, 
		rec_nom_volume,
		del_nom_volume
	)
	SELECT 
		NULLIF(flow_date, ''),
		NULLIF(transport_deal_id, ''),
		NULLIF(package_id, ''),
		NULLIF(SLN_id, ''),
		NULLIF(receipt_location_id, ''),
		NULLIF(delivery_location_id, ''),
		NULLIF(rec_nom_volume, ''),
		NULLIF(del_nom_volume, '')
	FROM OPENXML (@idoc, '/optimizer/header', 2)
		WITH ( 
			flow_date DATETIME '@flow_date',
			transport_deal_id VARCHAR(20) '@transport_deal_id',
			package_id VARCHAR(1) '@package_id',
			SLN_id VARCHAR(10) '@SLN_id',
			receipt_location_id VARCHAR(10) '@receipt_location_id',
			delivery_location_id VARCHAR(10) '@delivery_location_id',
			rec_nom_volume VARCHAR(50) '@rec_nom_volume',
			del_nom_volume VARCHAR(50) '@del_nom_volume'
		)

	INSERT INTO optimizer_detail(
		optimizer_header_id, 
		flow_date, 
		transport_deal_id, 
		up_down_stream, 
		source_deal_header_id, 
		source_deal_detail_id, 
		volume_used
	)
	SELECT 
		IDENT_CURRENT('optimizer_header'),
		NULLIF(flow_date, ''),
		NULLIF(transport_deal_id, ''),
		NULLIF(up_down_stream, ''),
		NULLIF(source_deal_header_id, ''),
		NULLIF(source_deal_detail_id, ''),
		NULLIF(volume_used, '')
	FROM OPENXML (@idoc, '/optimizer/detail', 2)
		WITH ( 
			flow_date DATETIME '@flow_date',
			transport_deal_id VARCHAR(10) '@transport_deal_id',
			up_down_stream VARCHAR(20) '@up_down_stream',
			source_deal_header_id VARCHAR(10) '@source_deal_header_id',
			source_deal_detail_id VARCHAR(10) '@source_deal_detail_id',
			volume_used VARCHAR(10) '@volume_used'
		)

	EXEC sp_xml_removedocument @idoc
END
ELSE IF @flag = 'h'
BEGIN

BEGIN TRY
	BEGIN TRAN	

	IF OBJECT_ID(N'tempdb..#inserted_opt_header') IS NOT NULL 
		DROP TABLE #inserted_opt_header

	IF OBJECT_ID(N'tempdb..#inserted_opt_detail') IS NOT NULL 
		DROP TABLE #inserted_opt_detail

	CREATE TABLE  #inserted_opt_header (
		rec_nom_volume NUMERIC(38, 18),
		del_nom_volume NUMERIC(38, 18)
	)

	CREATE TABLE #inserted_opt_detail (
		up_down_stream VARCHAR(1) COLLATE DATABASE_DEFAULT,
		volume_used NUMERIC(38, 18)	
	)

	INSERT INTO optimizer_header(
		flow_date,						
		transport_deal_id,				
		package_id,  
		SLN_id,		
		receipt_location_id,			
		delivery_location_id,			
		rec_nom_volume,					
		del_nom_volume					
	)
	OUTPUT INSERTED.rec_nom_volume, INSERTED.del_nom_volume INTO #inserted_opt_header	
	SELECT sdh.entire_term_start flow_date, 
		@source_deal_header_id transport_deal_id,  
		REPLACE(LTRIM(REPLACE(STR(CAST(RAND() AS NUMERIC(20, 20)), 20, 20), '0.', '')), ' ', '') package_id,
		1 SLN_id,
		loc.[1] receipt_location_id,
		loc.[2] delivery_location_id,
		dv.[1] rec_nom_volume,
		dv.[2] del_nom_volume		
	FROM source_deal_header sdh
		LEFT JOIN 
		(
			SELECT source_deal_header_id, deal_volume, leg FROM source_deal_detail) sdd
			PIVOT(MAX(deal_volume) FOR leg IN ([1], [2])
		) AS dv
			ON sdh.source_deal_header_id = dv.source_deal_header_id
		LEFT JOIN 
		(
			SELECT source_deal_header_id, location_id, leg FROM source_deal_detail ) sdd1
			PIVOT(MAX(location_id) FOR leg IN ([1], [2])
		) AS loc
			ON sdh.source_deal_header_id = loc.source_deal_header_id
	WHERE sdh.source_deal_header_id = @source_deal_header_id
	
	IF @injection_deal_id IS NULL AND @withdrawal_deal_id IS NULL  --incase of transport deal
	BEGIN
		INSERT INTO optimizer_detail(
			optimizer_header_id, 
			flow_date,					
			transport_deal_id,			
			up_down_stream,				
			source_deal_header_id,		
			source_deal_detail_id,		
			volume_used					
		)
		OUTPUT INSERTED.up_down_stream, INSERTED.volume_used INTO #inserted_opt_detail
		SELECT IDENT_CURRENT('optimizer_header') ,
			sdh.entire_term_start flow_date,
			@source_deal_header_id transport_deal_id,
			uds.up_down_stream,
			CASE uds.up_down_stream WHEN 'U' THEN sdd_phy.source_deal_header_id ELSE @source_deal_header_id END source_deal_header_id, 
			CASE uds.up_down_stream WHEN 'U' THEN sdd_phy.source_deal_detail_id ELSE sdd_max.[2] END source_deal_detail_id,
			CASE uds.up_down_stream WHEN 'U' THEN dv.[1] ELSE dv.[2] END  volume_used
		FROM source_deal_header sdh 
			LEFT JOIN 
			(
				SELECT source_deal_header_id, deal_volume, leg FROM source_deal_detail) sdd
				PIVOT(MAX(deal_volume) FOR leg IN ([1], [2])
			) AS dv
				ON sdh.source_deal_header_id = dv.source_deal_header_id
			LEFT JOIN 		
			(
				SELECT source_deal_header_id, source_Deal_detail_id, leg FROM source_deal_detail ) sdd 
				PIVOT(MAX(source_Deal_detail_id) FOR leg IN ([1], [2]) 
			
			) AS sdd_max			
				ON sdh.source_deal_header_id =  sdd_max.source_deal_header_id
			CROSS JOIN (
				SELECT 'U' up_down_stream 
				UNION ALL
				SELECT 'D' 
			) uds
			INNER JOIN user_defined_deal_fields uddf
				ON uddf.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN user_defined_deal_fields_template uddft
				ON uddf.udf_template_id = uddft.udf_template_id
			INNER JOIN user_defined_fields_template udft
				ON uddft.field_id = udft.field_id
				AND udft.field_label = 'from deal'
			INNER JOIN source_deal_header sdh_phy
				ON CAST(sdh_phy.source_deal_header_id AS VARCHAR(10)) = CAST(uddf.udf_value AS VARCHAR(10))
			INNER JOIN source_deal_detail sdd_phy
				ON sdh_phy.source_deal_header_id = sdd_phy.source_deal_header_id 
				AND sdd_phy.term_start = sdh.entire_term_end
		WHERE sdh.source_deal_header_id = @source_deal_header_id
			AND (sdd_phy.source_deal_detail_id = @from_detail_id OR @from_detail_id IS NULL)
	END
	ELSE IF @injection_deal_id IS NULL --incase of injection deal
	BEGIN

		INSERT INTO optimizer_detail(
			optimizer_header_id, 
			flow_date,					
			transport_deal_id,			
			up_down_stream,				
			source_deal_header_id,		
			source_deal_detail_id,		
			volume_used					
		)
		OUTPUT INSERTED.up_down_stream, INSERTED.volume_used INTO #inserted_opt_detail
		SELECT   IDENT_CURRENT('optimizer_header') ,
			sdh.entire_term_start flow_date,
			@source_deal_header_id transport_deal_id,
			uds.up_down_stream,
			CASE uds.up_down_stream WHEN 'U' THEN sdd_phy.source_deal_header_id ELSE @injection_deal_id END source_deal_header_id, 
			CASE uds.up_down_stream WHEN 'U' THEN sdd_phy.source_deal_detail_id ELSE sdd_inj.source_deal_detail_id END source_deal_detail_id,
			CASE uds.up_down_stream WHEN 'U' THEN dv.[1] ELSE dv.[2] END  volume_used
		FROM source_deal_header sdh 
			LEFT JOIN 
			(
				SELECT source_deal_header_id, deal_volume, leg FROM source_deal_detail) sdd
				PIVOT(MAX(deal_volume) FOR leg IN ([1], [2])
			) AS dv
			ON sdh.source_deal_header_id = dv.source_deal_header_id
			CROSS JOIN source_deal_detail sdd_inj
			CROSS JOIN (
				SELECT 'U' up_down_stream 
				UNION ALL
				SELECT 'D' 
			) uds
			INNER JOIN user_defined_deal_fields uddf
				ON uddf.source_deal_header_id = sdh.source_deal_header_id
			INNER JOIN user_defined_deal_fields_template uddft
				ON uddf.udf_template_id = uddft.udf_template_id
			INNER JOIN user_defined_fields_template udft
				ON uddft.field_id = udft.field_id
				AND udft.field_label = 'from deal'
			INNER JOIN source_deal_header sdh_phy
				ON CAST(sdh_phy.source_deal_header_id AS VARCHAR(10)) = CAST(uddf.udf_value AS VARCHAR(10))
			INNER JOIN source_deal_detail sdd_phy
				ON sdh_phy.source_deal_header_id = sdd_phy.source_deal_header_id 
				AND sdd_phy.term_start = sdh.entire_term_start
		WHERE sdh.source_deal_header_id = @source_deal_header_id
			AND sdd_inj.source_deal_header_id = @injection_deal_id
		
	END
	ELSE --incase of withdrawal deal
	BEGIN
		INSERT INTO optimizer_detail(
			optimizer_header_id, 
			flow_date,					---sdh.term_start
			transport_deal_id,			-- @source_deal_header_id
			up_down_stream,				--u/d
			source_deal_header_id,		-- case u  then phy_deal_sdh_id esle -- @source_deal_header_id
			source_deal_detail_id,		-- case u  then phy_deal_sdh_id (detail_id) else  @source_deal_header_id (max leg sdd)(leg 2)
			volume_used					--- if u leg 1 -- @source_deal_header_id sdd.deal_volume esle leg 2 sdd.deal_volume
		)
		OUTPUT INSERTED.up_down_stream, INSERTED.volume_used INTO #inserted_opt_detail
		SELECT   IDENT_CURRENT('optimizer_header') ,
		sdh.entire_term_start flow_date,
		@source_deal_header_id transport_deal_id,
		uds.up_down_stream,
		CASE uds.up_down_stream WHEN 'U' THEN @withdrawal_deal_id ELSE sdh.source_deal_header_id END source_deal_header_id, 
		CASE uds.up_down_stream WHEN 'U' THEN sdd_with.source_deal_detail_id  ELSE sdd.source_deal_detail_id END source_deal_detail_id,
		CASE uds.up_down_stream WHEN 'U' THEN dv.[1] ELSE dv.[2] END  volume_used
	FROM source_deal_header sdh 
		INNER JOIN source_deal_detail sdd 
			ON sdd.source_deal_header_id = sdh.source_deal_header_id
			AND sdd.leg = 2
		LEFT JOIN 
		(
			SELECT source_deal_header_id, deal_volume, leg FROM source_deal_detail) sdd
			PIVOT(MAX(deal_volume) FOR leg IN ([1], [2])
		) AS dv
		ON sdh.source_deal_header_id = dv.source_deal_header_id
		CROSS JOIN source_deal_detail sdd_with
		CROSS JOIN (
			SELECT 'U' up_down_stream 
			UNION ALL
			SELECT 'D' 
		) uds	
	WHERE sdh.source_deal_header_id = @source_deal_header_id
		AND sdd_with.source_deal_header_id = @withdrawal_deal_id
		
	END	
		
	IF @reschedule_deal_id IS NOT NULL 
	BEGIN
		UPDATE oh 
			SET oh.rec_nom_volume = sdd_leg1.deal_volume,
				oh.del_nom_volume = sdd_leg2.deal_volume
		FROM optimizer_header oh
			INNER JOIN source_deal_detail sdd_leg1
				ON oh.transport_deal_id = sdd_leg1.source_deal_header_id 
				AND sdd_leg1.leg = 1
			INNER JOIN source_deal_detail sdd_leg2
				ON oh.transport_deal_id = sdd_leg2.source_deal_header_id 
				AND sdd_leg2.leg = 2
		WHERE transport_deal_id = @reschedule_deal_id

		UPDATE od 
			SET od.volume_used = sdd.deal_volume
			--select sdd.deal_volume
			FROM optimizer_detail od
				INNER JOIN source_deal_detail sdd					
					ON od.transport_deal_id = sdd.source_deal_header_id
					AND od.up_down_stream = CASE WHEN sdd.leg = 1 THEN 'U' ELSE 'D' END
			WHERE transport_deal_id = @reschedule_deal_id		
	END
	
	--EXEC spa_ErrorHandler 0 
	--					, 'Schedule' 
	--					, 'spa_optimizer_deals'
	--					, 'Success'
	--					, 'Successfully saved in optimizer.'
	--					, ''


	COMMIT
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK

		--EXEC spa_ErrorHandler -1
		--				, 'Schedule' 
		--				, 'spa_optimizer_deals'
		--				, 'Error'
		--				, 'Error in saving data in optimizer.'
		--				, ''
	END CATCH
END





