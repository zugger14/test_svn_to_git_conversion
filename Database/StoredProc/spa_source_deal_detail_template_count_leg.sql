IF OBJECT_ID(N'[dbo].[spa_source_deal_detail_template_count_leg]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_source_deal_detail_template_count_leg]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: rajiv@pioneersolutionsglobal.com
-- Create date: 2012-08-29
-- Description: Count number of entry in source_deal_detail_template for any template
 
-- Params:
-- @template_id INT -- template id
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_source_deal_detail_template_count_leg]
    @template_id INT
AS

SELECT COUNT(sddt.template_id)
FROM source_deal_header_template sdht
INNER JOIN source_deal_detail_template sddt ON  sdht.template_id = sddt.template_id
WHERE sddt.template_id = @template_id             