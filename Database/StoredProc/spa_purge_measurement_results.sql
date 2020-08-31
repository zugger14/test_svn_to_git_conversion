IF OBJECT_ID(N'spa_purge_measurement_results', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_purge_measurement_results]
 GO 

--This sp purgesmeasurement results
-- exec spa_purge_measurement_results  '2002-12-30'

CREATE PROCEDURE [dbo].[spa_purge_measurement_results]  
	@as_of_date varchar(15)
AS

DECLARE @closed_book_count INT

SELECT     @closed_book_count  = COUNT(*) 
FROM         close_measurement_books
WHERE     (as_of_date >= CONVERT(DATETIME, @as_of_date, 102))


If @closed_book_count >  0
BEGIN
	SELECT 'Error' AS ErrorCode, 'Purge Measurement Results' as Module, 'spa_purge_measurement_results' as Area, 
					'Boooks already closed on or beyond the purge date: ' + @as_of_date as message, ''
END
ELSE
BEGIN

DECLARE @st_where VARCHAR(1000)
SET @st_where='as_of_date ='''+ @as_of_date+''''

EXEC spa_delete_ProcessTable 'report_measurement_values',@st_where
EXEC spa_delete_ProcessTable 'calcprocess_deals',@st_where
EXEC spa_delete_ProcessTable 'calcprocess_aoci_release',@st_where
EXEC spa_delete_ProcessTable 'report_netted_gl_entry',@st_where

DELETE 
FROM   calcprocess_amortization
WHERE  as_of_date = @as_of_date

DELETE 
FROM   report_measurement_values_expired
WHERE  as_of_date = @as_of_date

DELETE 
FROM   calcprocess_deals_expired
WHERE  as_of_date = @as_of_date

	EXEC spa_ErrorHandler 0,
	     'Purge Measurement Results',
	     'spa_purge_measurement_results',
	     'Success',
	     'Measurement results purged for date',
	     ''
END