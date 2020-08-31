IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_get_company_name]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[spa_get_company_name]

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Narendra Shrestha
-- Create date: 1st September, 2010
-- Description:	Get company name
-- =============================================

CREATE PROCEDURE [dbo].[spa_get_company_name] 
	
AS
BEGIN
	SET NOCOUNT ON;
	SELECT ph.entity_name FROM portfolio_hierarchy ph WHERE ph.entity_id = -1
END
GO