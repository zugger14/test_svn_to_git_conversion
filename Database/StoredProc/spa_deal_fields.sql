IF OBJECT_ID(N'[dbo].[spa_deal_fields]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_fields]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/**  

	Retrieves fields from source_deal_header and source_deal_detail table
	
	Parameters
	@table : 'header' for 'source_deal_header' 
			 'detail' from 'source_deal_detail'

*/



CREATE PROCEDURE [dbo].[spa_deal_fields]
    @table NVARCHAR(100)
AS
IF @table = 'header'
BEGIN
	SELECT COLUMN_NAME [Fields]
	FROM   INFORMATION_SCHEMA.COLUMNS
	WHERE  TABLE_NAME = 'source_deal_header'
	ORDER BY
	       COLUMN_NAME ASC; 
END
ELSE IF @table = 'detail'
BEGIN
	SELECT COLUMN_NAME [Fields]
	FROM   INFORMATION_SCHEMA.COLUMNS
	WHERE  TABLE_NAME = 'source_deal_detail'
	ORDER BY
	       COLUMN_NAME ASC; 
END
