IF OBJECT_ID(N'[spa_get_VaR_report]', N'P') IS NOT NULL
DROP PROC dbo.[spa_get_VaR_report]
GO
/****** Object:  StoredProcedure [dbo].[spa_get_VaR_report]    Script Date: 12/16/2008 20:22:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/************************
Created By: Anal Shrestha
Created On:12-15-2008

SP to get the broker FEE
EXEC spa_get_calc_history 233,'e','2008-01-01','2008-12-31'
*************************/
CREATE PROC [dbo].[spa_get_VaR_report]
	@counterparty_id INT=NULL,
	@counterparty_type CHAR(1),--'i' internal, 'e' external,'b' broker'
	@as_of_date_from DATETIME,
	@as_of_date_to DATETIME=NULL
	
AS
SET NOCOUNT ON

BEGIN

DECLARE @sql_str VARCHAR(8000)

if @as_of_date_to IS NULL
	SET @as_of_date_to=@as_of_date_from

SET @sql_str='
			SELECT
				counterparty_name  as '+case when @counterparty_type='b' then '[Broker]' else '[Counterparty]' end+',
				civv.as_of_date as [AsOfDate],
				civ.prod_date as [ProdDate],
				charge_type.code as [Charge Type],
				civ.[value] as [Value]
			FROM
				source_counterparty sc 
				INNER JOIN calc_invoice_volume_variance civv on civv.counterparty_id=sc.source_counterparty_id
				INNER JOIN calc_invoice_volume civ on civv.calc_id=civ.calc_id
				LEFT JOIN  static_data_value charge_type ON charge_type.value_id=civ.invoice_line_item_id
			WHERE 1=1 
				AND civv.as_of_date between '''+CAST(@as_of_date_from as VARCHAR)+''' AND '''+CAST(@as_of_date_from AS VARCHAR)+''''				
			+ CASE WHEN  @counterparty_id IS NOT NULL THEN ' AND civv.counterparty_id='+CAST (@counterparty_id AS VARCHAR) ELSE '' END
			+ CASE WHEN  @counterparty_type IS NOT NULL THEN ' AND sc.int_ext_flag ='''+@counterparty_type+'''' ELSE '' END

	EXEC(@sql_str)

END
	
	



