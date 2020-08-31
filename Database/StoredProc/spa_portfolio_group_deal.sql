/*
* sligal
* sp for table spa_portfolio_group_deal
* date: 
* purpose: iu operations for deals selected from maintain portfolio group.
* params:
	@flag char(1) : Operation flag
	@portfolio_group_deal_id INT :,
    @portfolio_group_id INT :,
    @deal_id VARCHAR(5000) :
	
*/

IF OBJECT_ID(N'[dbo].[spa_portfolio_group_deal]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_portfolio_group_deal]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_portfolio_group_deal]
    @flag CHAR(1),
    @portfolio_group_deal_id VARCHAR(500) = NULL,
    @portfolio_group_id INT = NULL,
    @deal_id VARCHAR(5000) = NULL
AS
 
DECLARE @sql VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
    --SELECT ALL ROWS FROM THE TABLE
    SELECT pgd.portfolio_group_deal_id [ID],
           dbo.FNAHyperLinkText(10131010, pgd.deal_id, pgd.deal_id) AS [Deal ID],
		   sdh.deal_id AS [Reference ID],
		   dbo.FNADateFormat(sdh.deal_date) AS [Deal Date],
		   sdh.physical_financial_flag AS [Physical/Financial],
		   sc.counterparty_name AS [Counterparty Name],
		   dbo.FNADateFormat(sdh.entire_term_start) AS [Term Start],
		   dbo.FNADateFormat(sdh.entire_term_end) AS [Term End]
    FROM portfolio_group_deal pgd
    LEFT JOIN source_deal_header sdh ON sdh.source_deal_header_id = pgd.deal_id
	LEFT JOIN source_counterparty sc ON sdh.counterparty_id = sc.source_counterparty_id
    WHERE pgd.portfolio_group_id = @portfolio_group_id
    
END
ELSE IF @flag = 'a'
BEGIN
    --SELECT A MATCHED ROW FROM THE TABLE
    SELECT pgd.portfolio_group_deal_id,
           pgd.portfolio_group_id,
           pgd.deal_id
    FROM   portfolio_group_deal pgd
    WHERE  pgd.portfolio_group_deal_id = @portfolio_group_deal_id
END
ELSE IF @flag = 'i'
BEGIN TRY
    --INSERT STATEMENT GOES HERE
    INSERT INTO portfolio_group_deal
      (
        portfolio_group_id,
        deal_id
      )
    SELECT @portfolio_group_id, scsv.item
    FROM   dbo.SplitCommaSeperatedValues(@deal_id) scsv
    
    EXEC spa_ErrorHandler 0,
         'portfolio_group_deal',
         'spa_portfolio_group_deal',
         'Success',
         'Insert portfolio_group_deal new record success.',
         ''
END TRY
BEGIN CATCH
	EXEC spa_ErrorHandler -1,
         'portfolio_group_deal',
         'spa_portfolio_group_deal',
         'Failed',
         'Insert portfolio_group_deal new record failed.',
         ''
END CATCH
 
ELSE IF @flag = 'u'
BEGIN
    --UPDATE STATEMENT GOES HERE
    EXEC spa_print 'not required'
END

ELSE IF @flag = 'd'
BEGIN TRY
    --DELETE STATEMENT GOES HERE
    SET @sql = '
    DELETE FROM portfolio_group_deal
    WHERE portfolio_group_deal_id IN (' + @portfolio_group_deal_id + ')'
		  
	exec spa_print @sql
	EXEC(@sql)
	
	EXEC spa_ErrorHandler 0,
         'portfolio_group_deal',
         'spa_portfolio_group_deal',
         'Success',
         'Delete portfolio_group_deal record success.',
         ''
END TRY
BEGIN CATCH
	EXEC spa_ErrorHandler -1,
         'portfolio_group_deal',
         'spa_portfolio_group_deal',
         'Failed',
         'Delete portfolio_group_deal record failed.',
         ''
END CATCH
