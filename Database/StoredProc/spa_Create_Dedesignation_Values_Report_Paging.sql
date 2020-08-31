IF OBJECT_ID(N'spa_Create_Dedesignation_Values_Report_Paging', N'P') IS NOT NULL
DROP PROCEDURE spa_Create_Dedesignation_Values_Report_Paging
 GO 
--exec spa_Create_Dedesignation_Values_Report_paging '2005-03-31', '30', '208', '225', 'd', 'c', 'd', NULL

CREATE PROC [dbo].[spa_Create_Dedesignation_Values_Report_Paging]
   		@as_of_date VARCHAR(50), 
		@sub_entity_id VARCHAR(100),
		@strategy_entity_id VARCHAR(100) = NULL,
		@book_entity_id VARCHAR(100) = NULL, 
		@discount_option CHAR(1),
		@report_type CHAR(1),
		@summary_option CHAR(1), 
		@link_id VARCHAR(100) = NULL,
		@round_value CHAR(1)='0',
		@term_start DATETIME=NULL,
		@term_end DATETIME=NULL,
		@process_id VARCHAR(200)=NULL, 
		@page_size INT =NULL,
		@page_no INT=NULL 
	
 AS
SET NOCOUNT ON


DECLARE @user_login_id VARCHAR(50),@tempTable VARCHAR(300) ,@flag CHAR(1)

	SET @user_login_id=dbo.FNADBUser()

	IF @process_id IS NULL
	BEGIN
		SET @flag='i'
		SET @process_id=REPLACE(NEWID(),'-','_')
	END
	SET @tempTable=dbo.FNAProcessTableName('paging_temp_Dedesignation_Values_Report', @user_login_id,@process_id)
	DECLARE @sqlStmt VARCHAR(5000)


IF @flag='i'
BEGIN
--if @summary_option='s'
	SET @sqlStmt = 'CREATE TABLE ' + @tempTable + '( 
					sno int  identity(1,1),
					Sub varchar(500),
					Strategy varchar(500),
					Book varchar(500),
					HedgeRelID varchar(500),
					DedesignationDate varchar(500),
					Term varchar(500),
					Currency varchar(500),
					DesdesignatedHedgePNL varchar(500),
					DedesignatedAOCI varchar(500),
					DedesignatedPNL varchar(500),
					)'
		EXEC(@sqlStmt)

	SET @sqlStmt = ' insert  '+@tempTable+'
					exec  spa_Create_Dedesignation_Values_Report '+ 
					dbo.FNASingleQuote(@as_of_date) +','+ 
					dbo.FNASingleQuote(@sub_entity_id) +','+ 
					dbo.FNASingleQuote(@strategy_entity_id) +','+ 
					dbo.FNASingleQuote(@book_entity_id) +','+ 
					dbo.FNASingleQuote(@discount_option) +',' +
					dbo.FNASingleQuote(@report_type) +',' +
					dbo.FNASingleQuote(@summary_option) +','+
					dbo.FNASingleQuote(@link_id) +','+
					@round_value +','+
					dbo.FNASingleQuote(@term_start) +','+
					dbo.FNASingleQuote(@term_end)

	EXEC spa_print @sqlStmt
	EXEC(@sqlStmt)

	SET @sqlStmt='select count(*) TotalRow,'''+@process_id +''' process_id  from '+ @tempTable
	EXEC spa_print @sqlStmt
	EXEC(@sqlStmt)
END
ELSE
BEGIN
	DECLARE @row_to INT,@row_from INT
	SET @row_to=@page_no * @page_size
	IF @page_no > 1 
	SET @row_from =((@page_no-1) * @page_size)+1
	ELSE
	SET @row_from =@page_no
END
SET @sqlStmt='
			SELECT	Sub , Strategy, Book, HedgeRelID AS [Hedge Rel ID], DedesignationDate AS [Dedesignation Date]
					,Term, Currency, DesdesignatedHedgePNL AS [Dedesignated Hedge PNL]
					,DedesignatedAOCI AS [Dedesignated AOCI], DedesignatedPNL AS [Dedesignated PNL]

FROM '+ @tempTable  +' where sno between '+ CAST(@row_from AS VARCHAR) +' and '+ CAST(@row_to AS VARCHAR)+ ' order by sno asc'

EXEC spa_print @sqlStmt
EXEC(@sqlStmt)


