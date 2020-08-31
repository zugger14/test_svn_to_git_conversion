/****** Object:  StoredProcedure [dbo].[spa_check_invoice_saved]    Script Date: 05/21/2009 23:03:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_check_invoice_saved]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_check_invoice_saved]
/****** Object:  StoredProcedure [dbo].[spa_check_invoice_saved]    Script Date: 05/21/2009 23:03:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- exec spa_check_invoice_saved '2004-02-01',1

CREATE PROCEDURE [dbo].[spa_check_invoice_saved]
		@deal_date_from varchar(20),
		@counterparty_id int
AS

--print 'xxx' + @summary_option 
DECLARE @invoice_id INT

	if (select count(*) from save_invoice where 
		counterparty_id = @counterparty_id and term_month = dbo.FNAGetContractMonth(@deal_date_from)
			--and isnull(status, 20700) <> 20704
		) >= 1
	begin
		SELECT @invoice_id=max(save_invoice_id) from save_invoice where 
		counterparty_id = @counterparty_id and term_month = dbo.FNAGetContractMonth(@deal_date_from)
			--and isnull(status, 20700) <> 20704


		declare @error_desc varchar(250)
		set @error_desc = 'Invoice for this Counterparty for Period ' + dbo.FNADateFormat(@deal_date_from)
				+ ' is already created. Please void it first if you want to save it again.'

		Select 	'Error' ErrorCode, 
			'Save Invoice' Module, 
			'spa_check_invoice_saved' Area, 
			'Error'Status, 
			@error_desc Message, 
			'' Recommendation,@invoice_id


-- 		Exec spa_ErrorHandler 1, 'Save Invoice', 
-- 				'spa_check_invoice_saved', 'Error', @error_desc, ''

		RETURN
	end
	else

		Exec spa_ErrorHandler 0, 'Save Invoice', 
				'spa_check_invoice_saved', 'Success', 'Not saved', ''






