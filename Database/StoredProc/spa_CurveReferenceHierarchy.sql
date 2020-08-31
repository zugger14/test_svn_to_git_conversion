/****** Object:  StoredProcedure [dbo].[spa_CurveReferenceHierarchy]    Script Date: 06/22/2009 12:21:38 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_CurveReferenceHierarchy]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_CurveReferenceHierarchy]
/****** Object:  StoredProcedure [dbo].[spa_CurveReferenceHierarchy]    Script Date: 06/22/2009 11:31:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Sishir Maharjan>
-- Create date: <02/18/2009>
-- Description:	<To fetch if the parsed curve id is referred by another curve>
-- =============================================
CREATE  PROCEDURE [dbo].[spa_CurveReferenceHierarchy]
	@curve_id varchar(max),@flag CHAR(1)= NULL, 
	@pre_granularity_id varchar(100) = NULL,
	@market_value_desc VARCHAR(100) = NULL,
	@market_value_id VARCHAR(100) = NULL,
	@curve_tou INT = NULL
AS
IF @flag IS NULL 
BEGIN

	SET NOCOUNT ON;
	
	select count(*) as ReferenceCount from CurveReferenceHierarchy where curveId = cast(@curve_id as varchar) and RefID_1 is not null


END

ELSE IF @flag='s' --check for data in source_price_curve
BEGIN

	SET NOCOUNT ON;
	
	SELECT COUNT(*) AS priceCurve FROM dbo.source_price_curve WHERE source_curve_def_id=CAST(@curve_id AS VARCHAR)
	
END

ELSE IF @flag='c' --check for data in source_price_curve as well check granuality if it can be change or not.
BEGIN
	SET NOCOUNT ON;
	DECLARE @count VARCHAR (MAX)
	DECLARE @desc VARCHAR(200)
	SET @curve_id= LEFT(@curve_id, 10)

	SELECT @count = COUNT(*) FROM dbo.source_price_curve WHERE source_curve_def_id= CONVERT(bigint, @curve_id)
	--PRINT @COUNT
	
	IF (@count > 0)
	BEGIN
		declare @granuality varchar (100)
		SELECT @granuality = Granularity FROM source_price_curve_def WHERE source_curve_def_id = CONVERT(bigint, @curve_id)
		IF (@granuality != @pre_granularity_id)
		BEGIN
			SELECT @desc = 'Granularity cannot be changed. The curve contains price of different granularity.'
			SELECT 'false'  AS status, @desc AS [desc]
			RETURN
		END
	END 

	IF EXISTS (SELECT 1 FROM source_price_curve_def WHERE market_value_id = @market_value_id AND market_value_desc = @market_value_desc AND curve_tou = @curve_tou AND source_curve_def_id <> @curve_id) -- Checking unique combination of market_value_id,market_value_desc, time of use (cannot define in table because of null value.)
	BEGIN
		--SELECT @desc = 'Market Value ID must be unique for Market (' + code + ').' FROM static_data_value WHERE value_id = @market_value_desc
		SELECT @desc = 'Combination of Time of Use, Market Description and Market Value ID must be unique.'
		SELECT 'false' AS status, @desc AS [desc]
	END
	ELSE IF EXISTS (SELECT 1 FROM source_price_curve_def WHERE market_value_id = @market_value_id AND market_value_desc = @market_value_desc AND source_curve_def_id <> @curve_id) -- Checking unique combination of market_value_id,market_value_desc (cannot define in table because of null value.)
	BEGIN
		SELECT @desc = 'Combination of <b>Market</b> and <b>Market Value ID</b> must be unique.'
		SELECT 'false' AS status, @desc AS [desc]
	END
	ELSE
	BEGIN
		SELECT 'true'
	END
	
END
    