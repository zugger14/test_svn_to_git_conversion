IF  EXISTS (SELECT 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNAStorageContractPrice]') 
				AND TYPE in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [dbo].[FNAStorageContractPrice]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	 Syntax validation Function of FNAStorageContractPrice function. Always returns 1 if valid.

	 Parameters
     @source_deal_header_id : Deal Header ID
	 @prod_date : Prod Date
     
*/

CREATE FUNCTION [dbo].[FNAStorageContractPrice](@source_deal_header_id INT, @prod_date DATETIME)
	RETURNS float AS  
BEGIN 
	RETURN 1.0
END

