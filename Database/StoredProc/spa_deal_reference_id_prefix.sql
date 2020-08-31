IF OBJECT_ID(N'[dbo].[spa_deal_reference_id_prefix]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_deal_reference_id_prefix]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ===========================================================================================================
-- Author: ashakya@pioneersolutionsglobal.com
-- Create date: 20th November, 2012
-- Description: CRUD operations for table deal_reference_id_prefix

-- Params:
-- @flag CHAR(1) - Operation flag
-- @deal_reference_id_prefix INT - Deal Reference ID
-- @deal_type VARCHAR(100) - Deal Type
-- @sub_deal_type VARCHAR(100) - SubDeal Type
-- @prefix VARCHAR(100) - Prefix

-- EXEC spa_deal_reference_id_prefix 's'
-- EXEC spa_deal_reference_id_prefix 'a', 1 
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_deal_reference_id_prefix]
      @flag CHAR(1)
    , @deal_reference_id_prefix_id INT = NULL
    , @deal_type INT = NULL
    , @prefix VARCHAR(100) = NULL
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN	
	SELECT	d.deal_reference_id_prefix_id AS [Deal Reference ID Prefix]
			,deal_type AS [Deal Type ID]
			,s.source_deal_type_name AS [Deal Type]
			,prefix AS [Prefix]
	FROM deal_reference_id_prefix d
	LEFT JOIN source_deal_type s ON s.source_deal_type_id = d.deal_type
END
ELSE IF @flag = 'a'
BEGIN
	SELECT deal_type, prefix 
	FROM deal_reference_id_prefix	 
	WHERE deal_reference_id_prefix_id = @deal_reference_id_prefix_id
   
END
ELSE IF @flag = 'i'
BEGIN
    IF EXISTS (SELECT 1 FROM deal_reference_id_prefix WHERE deal_type = @deal_type AND prefix = @prefix)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'deal_reference_id_prefix' 
			, 'spa_deal_reference_id_prefix'   
			, 'Error'        
			, 'This combination of Deal Type and Prefix already exits.' 
			, '' 
		RETURN
	END
	
	BEGIN TRY 
		INSERT INTO deal_reference_id_prefix (deal_type, prefix) 
		VALUES (@deal_type, @prefix)
    
		EXEC spa_ErrorHandler 0,
			 'deal_reference_id_prefix',
			 'spa_deal_reference_id_prefix',
			 'Success',
			 'Deal Reference ID Prefix successfully inserted.',
			 @deal_reference_id_prefix_id	
	END TRY 
    BEGIN CATCH 
		DECLARE @err_no3 INT
		SELECT @err_no3 = ERROR_NUMBER()
		
		EXEC spa_ErrorHandler @err_no3,
			 'deal_reference_id_prefix',
			 'spa_deal_reference_id_prefix',
			 'DB Error',
			 'Error on inserting Deal Reference ID Prefix.',
			 ''	
	END CATCH	
END
ELSE IF @flag = 'u'
BEGIN
	IF EXISTS (SELECT 1 FROM deal_reference_id_prefix WHERE deal_type = @deal_type 
			   AND prefix = @prefix 
			   AND deal_reference_id_prefix_id <> @deal_reference_id_prefix_id)
	BEGIN
		EXEC spa_ErrorHandler -1
			, 'deal_reference_id_prefix' 
			, 'spa_deal_reference_id_prefix'   
			, 'Error'        
			, 'This combination of data already exits.' 
			, ''
		RETURN 
	END
	
	BEGIN TRY
		UPDATE deal_reference_id_prefix
		SET	deal_type = @deal_type
			, prefix = @prefix 
		WHERE deal_reference_id_prefix_id = @deal_reference_id_prefix_id
	    
	    EXEC spa_ErrorHandler 0,
				 'deal_reference_id_prefix',
				 'spa_deal_reference_id_prefix',
				 'Success',
				 'Deal Reference ID Prefix successfully updated.',
				 @deal_reference_id_prefix_id 
	       
	END TRY	
	BEGIN CATCH
		IF @@ERROR <> 0
		EXEC spa_ErrorHandler @@ERROR,
			 'deal_reference_id_prefix',
			 'spa_deal_reference_id_prefix',
			 'DB Error',
			 'Error on updating Deal Reference ID Prefix.',
			 ''
	END CATCH		
END
ELSE IF @flag = 'd'
BEGIN
    DELETE FROM deal_reference_id_prefix WHERE deal_reference_id_prefix_id = @deal_reference_id_prefix_id

    IF @@ERROR <> 0
	    EXEC spa_ErrorHandler @@ERROR,
	         'deal_reference_id_prefix',
	         'spa_deal_reference_id_prefix',
	         'DB Error',
	         'Error on deleting Deal Reference ID Prefix.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'deal_reference_id_prefix',
	         'spa_deal_reference_id_prefix',
	         'Success',
	         'Deal Reference ID Prefix successfully deleted.',
	         @deal_reference_id_prefix_id 
END