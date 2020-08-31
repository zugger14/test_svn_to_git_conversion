IF OBJECT_ID(N'[dbo].[spa_deal_summary_report]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_summary_report]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===============================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2008-09-09
-- Description: Description of the functionality in brief.
 
-- Params:
-- @flag CHAR(1)        - Description of param2
-- @param1 VARCHAR(100) - Description of param3
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[spa_deal_summary_report]
    @flag CHAR(1),
    @deal_id INT = NULL
AS
 
DECLARE @SQL VARCHAR(MAX)
 
IF @flag = 's'
BEGIN
    SELECT mdv.source_deal_header_id [deal_id], mdv.deal_id [ref_id], mdv.counterparty [counterparty], mdv.trader [trader], dbo.FNADateFormat(mdv.entire_term_start) [period], mdv.deal_type [deal_type]
    FROM master_deal_view mdv
    WHERE mdv.source_deal_header_id = @deal_id    
END