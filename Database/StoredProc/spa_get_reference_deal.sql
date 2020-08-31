/****** Object:  StoredProcedure [dbo].[spa_get_reference_deal]    Script Date: 04/14/2009 21:25:01 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_reference_deal]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_get_reference_deal]
/****** Object:  StoredProcedure [dbo].[spa_get_reference_deal]    Script Date: 04/14/2009 21:26:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- exec spa_get_reference_deal 2498

CREATE PROC [dbo].[spa_get_reference_deal]
	@source_deal_header_id INT

AS 
BEGIN
	
--------Start of Old Logic---------
--	SELECT 
--			CAST(ISNULL(sdh1.source_deal_header_id,sdh2.source_deal_header_id) AS VARCHAR)+ISNULL(' - '+sdv.code,''),
--			ISNULL(sdh1.source_deal_header_id,sdh2.source_deal_header_id)
--		
--	FROM
--		source_deal_header sdh 
--		LEFT JOIN source_deal_header sdh1 on sdh1.close_reference_id=sdh.source_deal_header_id
--		LEFT JOIN source_deal_header sdh2 on sdh2.source_deal_header_id=sdh.close_reference_id
--		LEFT JOIN static_data_value sdv on sdv.value_id=ISNULL(sdh1.deal_reference_type_id,sdh2.deal_reference_type_id)
--
--	WHERE
--		
--		sdh.source_deal_header_id=@source_deal_header_id
--	

--------End of Old Logic---------

	DECLARE @deal_reference_type_id INT

	SELECT 
		@deal_reference_type_id = deal_reference_type_id 
		FROM source_deal_header 
		WHERE source_deal_header_id = @source_deal_header_id


	IF @deal_reference_type_id is not null
	BEGIN	
		SELECT 
			CAST(sdh.source_deal_header_id AS VARCHAR) + CASE WHEN sdv.code IS NULL THEN '' ELSE ' - ' + CAST(sdv.code AS VARCHAR) END,
			sdh.source_deal_header_id
		FROM source_deal_header sdh
		INNER JOIN source_deal_header sdh1 ON sdh1.close_reference_id = sdh.source_deal_header_id
		LEFT JOIN static_data_value sdv ON sdv.value_id = sdh.deal_reference_type_id
		WHERE sdh1.source_deal_header_id = @source_deal_header_id
	END
	ELSE
	BEGIN
		SELECT 
			CAST(sdh.close_reference_id AS VARCHAR) + CASE WHEN sdvt.code IS NULL THEN '' ELSE ' - ' + sdvt.code END,
			sdh.close_reference_id
		FROM
			source_deal_header sdh
			INNER JOIN source_deal_header sdho ON sdh.close_reference_id = sdho.source_deal_header_id
			INNER JOIN source_deal_header sdht ON sdht.close_reference_id = sdho.source_deal_header_id
			LEFT JOIN static_data_value sdvt ON sdvt.value_id = sdht.deal_reference_type_id
		WHERE sdh.source_deal_header_id = @source_deal_header_id
	END

END
