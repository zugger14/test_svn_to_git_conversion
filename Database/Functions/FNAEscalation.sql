IF OBJECT_ID(N'[dbo].[FNAEscalation]', N'FN') IS NOT NULL
    DROP FUNCTION [dbo].[FNAEscalation]
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================================
-- Author: navaraj@pioneersolutionsglobal.com
-- Create date: 2014-09-02
-- Description: Function to Validate the Syntax
 
-- ===========================================================================================================

CREATE  FUNCTION [dbo].[FNAEscalation] ()
RETURNS FLOAT AS
BEGIN
    RETURN 1
END
GO