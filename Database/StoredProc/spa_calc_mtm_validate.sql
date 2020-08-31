/****** Object:  StoredProcedure [dbo].[deal_replicate_caller]    Script Date: 03/11/2010 15:46:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_calc_mtm_validate]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_calc_mtm_validate]

GO

Create procedure [dbo].[spa_calc_mtm_validate]
@as_of_date datetime

as

BEGIN

DECLARE @closed_book_count int


SELECT     @closed_book_count  = COUNT(*) 
FROM         close_measurement_books
WHERE     (as_of_date >= CONVERT(DATETIME, dbo.FNAGetContractMonth(@as_of_date), 102))

-- Check if book is already closed
If @closed_book_count > 0 
BEGIN	
	Select 'Error' ErrorCode, 'Run MTM' Module, 'spa_calc_mtm', 'Book Closed' Status, 
		('Accounting Book already closed for run as of date ' + dbo.FNADateFormat(@as_of_date))  Message, 
		'' Recommendation		
	RETURN
END

ELSE
BEGIN
	Exec spa_ErrorHandler 0, 'Run MTM', 

				'spa_calc_mtm', 'Success', 

				'Success in inserting record.', ''
END

END