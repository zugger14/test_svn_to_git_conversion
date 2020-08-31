IF OBJECT_ID(N'[dbo].[spa_getIdentifiers]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_getIdentifiers
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2011-06-06
-- Description: CRUD operations for table time_zone

-- Params:
-- @identifiers_number int - to identify identifiers type
-- ===========================================================================================================
CREATE PROCEDURE [dbo].spa_getIdentifiers
    @identifiers_number INT
AS

SELECT sb.source_book_id , sb.source_book_name AS [Source Book Name]
FROM source_book sb 
WHERE sb.source_system_book_type_value_id = @identifiers_number ORDER BY sb.source_book_name


