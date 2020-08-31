/****** Object:  StoredProcedure [dbo].[spa_pratos_deal_report]    Script Date: 04/11/2012 11:18:21 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_pratos_deal_report]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_pratos_deal_report]
GO

/****** Object:  StoredProcedure [dbo].[spa_pratos_deal_report]    Script Date: 04/11/2012 11:18:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- ===========================================================================================================
-- Create date: 2012-04-10
-- Description: This SP generates the Pratos report which shows how many deals were imported at the EOD and how many deals are in staging tables 

-- Params:
-- @flag CHAR(1) - 's' -> Summary report, -> Detail Report
-- @as_of_date As of Date
-- Example : exec spa_pratos_deal_report 's','2012-01-01'
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[spa_pratos_deal_report]
	@flag CHAR(1)			=	's', --
	@as_of_date	VARCHAR(10) =	NULL

AS 
SET NOCOUNT ON 
BEGIN

	DECLARE @total_deals_imported INT
	DECLARE @deals_in_staging_table INT
	DECLARE @desc VARCHAR(MAX)
	DECLARE @user_login_id varchar(50)
	


	SET @user_login_id = dbo.FNADBUser()
	IF @as_of_date IS NULL
		SET @as_of_date = CONVERT(VARCHAR(10),GETDATE(),120)
	SET @total_deals_imported = 0
	SET @deals_in_staging_table = 0
	
	IF @flag = 's'
	BEGIN
		-- select total pratos deals imported successfully
		SELECT @total_deals_imported = COUNT(*) FROM 
			source_deal_header sdh 
			INNER JOIN user_defined_deal_fields_template uddft ON uddft.template_id=sdh.template_id
				AND uddft.field_name=-5585
			INNER JOIN user_defined_deal_fields uddf ON uddf.source_deal_header_id=sdh.source_deal_header_id
				AND uddft.udf_template_id=uddf.udf_template_id
		WHERE
			CONVERT(VARCHAR(10),sdh.update_ts,120) = CONVERT(VARCHAR(10),@as_of_date,120)
	
		SELECT @deals_in_staging_table = COUNT(*) FROM pratos_stage_deal_header  psdh
			WHERE CONVERT(VARCHAR(10),psdh.create_ts,120) = CONVERT(VARCHAR(10),@as_of_date,120) 
			
		
		SET @desc = 
		CAST(@total_deals_imported AS VARCHAR)+' Deals imported from Pratos out of '+CAST(@total_deals_imported+@deals_in_staging_table AS VARCHAR)+' on '+@as_of_date+
		CASE WHEN @deals_in_staging_table>0 THEN '.'+'<a target="_blank" href="' +  './dev/spa_html.php?__user_name__=' + @user_login_id + 
			'&spa=exec spa_pratos_deal_report ''d'','''+@as_of_date+'''' + '">'+CAST(@deals_in_staging_table AS VARCHAR) +' Deals are still in staging table. Please check Pratos import log for more detail.</a>'	 ELSE '.' END  
			
		
		SELECT 	@desc	
	
	END
	
	IF @flag = 'd'
	BEGIN
		SELECT 
			sdh.source_deal_header_id [Deal ID], 
			source_deal_id_old [Reference ID], 
			dbo.FNADateFormat(psdh.deal_date) [Deal Date], 
			psdh.counterparty Counterparty, 
			psdh.description1 Description1 
		FROM pratos_stage_deal_header psdh
			 LEFT JOIN source_deal_header sdh ON psdh.source_deal_id_old = sdh.deal_id
		WHERE
			CONVERT(VARCHAR(10),psdh.create_ts,120) = CONVERT(VARCHAR(10),@as_of_date,120) 	 

		 ORDER BY  [Reference ID], psdh.deal_date, psdh.counterparty, psdh.description1
		
	
	END	
	

END	

GO


