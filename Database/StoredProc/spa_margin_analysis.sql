IF OBJECT_ID(N'spa_margin_analysis', N'P') IS NOT NULL
	DROP PROCEDURE dbo.spa_margin_analysis
GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		skhanal@pioneersolutionsglobal.com
-- Create date: 08/01/2018
-- Description:	Stored procedure for Margin Analysis
-- =============================================
CREATE PROCEDURE spa_margin_analysis 
	@flag char(1) = NULL,
	@process_margin_header_id INT = NULL
AS
BEGIN
	SET NOCOUNT ON

	IF @flag ='g'
	BEGIN
		SELECT 
			 sc.[counterparty_id] [counterparty_id]
			, pmh.process_margin_header_id
			, pmh.counterparty_id [source_counterparty_id]
			, pmh.contract_id [source_contract_id]
			, pmh.product_id [source_product_id]
			, cg.source_contract_id [contract_id]
			, sdv.code [product_id]
		FROM process_margin_header pmh
		INNER JOIN source_counterparty sc
			ON pmh.counterparty_id = sc.source_counterparty_id
		INNER JOIN contract_group cg
			ON pmh.contract_id = cg.contract_id
		INNER JOIN static_data_value sdv
			ON pmh.product_id = sdv.value_id and sdv.type_id = 108100
	END

	ELSE IF @flag = 'm'
	BEGIN
		SELECT process_margin_detail_id
			, process_margin_header_id
			, effective_date
			, initial_margin
			, initial_margin_per
			, maintenance_margin
			, maintenance_margin_per
			, currency_id
			, lot_size
			, uom_id
			, CONVERT(DECIMAL(10, 2), post_rec_threshold) [post_rec_threshold]
			, rounding 
		FROM process_margin_detail
		WHERE process_margin_header_id = @process_margin_header_id
	END

END
GO
