IF OBJECT_ID(N'[dbo].[spa_pratos_mapping_book]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_pratos_mapping_book]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO 


-- ===========================================================================================================
-- Author: dmanandhar@pioneersolutionsglobal.com
-- Create date: 2011-09-14
-- Description: Pratos Mapping for book

-- Params:
--	@flag CHAR(1) - Operation flag
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_pratos_mapping_book]
    @flag CHAR(1),
    @pratos_book_mapping_id INT = NULL,
    @counterparty_id VARCHAR(100) = NULL,
    @country_id VARCHAR(100) = NULL,
    @grid_id VARCHAR(100) = NULL,
    @category_id VARCHAR(100) = NULL,
    @source_system_book_id1 INT = NULL,
    @source_system_book_id2 INT = NULL,
    @source_system_book_id3 INT = NULL,
    @source_system_book_id4 INT = NULL ,
    @region INT = NULL    
AS

DECLARE @sql VARCHAR(MAX)

IF @flag = 's'
BEGIN
	SELECT pbm.id AS [ID],
	       sc.counterparty_name AS [Counterparty],
	       sdv.[code] AS [Country],
	       sdv1.[code] AS [Grid],
	       sdv2.[code] AS [Category],
	       sb.source_book_name AS [Book],
	       sb1.source_book_name AS [Trade Book],
	       sb2.source_book_name AS [Trade Type],
	       sb3.source_book_name AS [None],
	       sdv3.code  AS [Region]
	       
	FROM   pratos_book_mapping pbm
	       INNER JOIN static_data_value sdv ON  pbm.country_id = sdv.value_id AND sdv.type_id=14000
	       INNER JOIN static_data_value sdv1 ON  pbm.grid_id = sdv1.value_id AND sdv1.type_id=18000
	       INNER JOIN static_data_value sdv2 ON  pbm.category = sdv2.value_id AND sdv2.type_id=18100
	       INNER JOIN source_book sb ON  pbm.source_system_book_id1 = sb.source_book_id
	       INNER JOIN source_book sb1 ON  pbm.source_system_book_id2 = sb1.source_book_id
	       INNER JOIN source_book sb2 ON  pbm.source_system_book_id3 = sb2.source_book_id
	       INNER JOIN source_book sb3 ON  pbm.source_system_book_id4 = sb3.source_book_id
	       LEFT JOIN source_counterparty sc ON  sc.source_counterparty_id = pbm.counterparty_id
	       LEFT JOIN static_data_value sdv3 ON sdv3.value_id = pbm.region AND sdv3.type_id=11150
	WHERE  sdv.[type_id] = 14000
       AND sdv1.[type_id] = 18000
       AND sdv2.[type_id] = 18100
END

ELSE IF @flag = 'a'
BEGIN
	SELECT 
		pbm.id, 
		pbm.counterparty_id, 
		pbm.country_id, 
		pbm.grid_id, 
		pbm.category,
		pbm.source_system_book_id1, 
		pbm.source_system_book_id2,
		pbm.source_system_book_id3, 
		pbm.source_system_book_id4,
		pbm.region 
	  FROM pratos_book_mapping pbm
	WHERE pbm.id = @pratos_book_mapping_id
END

ELSE IF @flag = 'i'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
		INSERT INTO pratos_book_mapping
		(
			-- id -- this column value is auto-generated,
			counterparty_id,
			country_id,
			grid_id,
			category,
			source_system_book_id1,
			source_system_book_id2,
			source_system_book_id3,
			source_system_book_id4,
			region
		)
		VALUES	(	
			@counterparty_id,
			@country_id,
			@grid_id,
			@category_id,
			@source_system_book_id1,
			@source_system_book_id2,
			@source_system_book_id3,
			@source_system_book_id4,
			@region  
		)
		
		COMMIT 
		EXEC spa_ErrorHandler 0
			, 'Pratos Book Mapping Table'
			, 'spa_pratos_mapping_book'
			, 'Success'
			, 'Data insert Success'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'Pratos Book Mapping Table'--tablename
			, 'spa_pratos_mapping_book'--sp
			, 'DB Error'--error type
			, 'Failed Inserting Data.'
			, 'Cannot Insert Data.' --personal msg
			
		ROLLBACK 
	END CATCH
END

ELSE IF @flag = 'u'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
	UPDATE pratos_book_mapping
	SET
		counterparty_id = @counterparty_id,
		country_id = @country_id,
		grid_id = @grid_id,
		category = @category_id,
		source_system_book_id1 = @source_system_book_id1,
		source_system_book_id2 = @source_system_book_id2,
		source_system_book_id3 = @source_system_book_id3,
		source_system_book_id4 = @source_system_book_id4,
		region = @region	 
	WHERE 
		id = @pratos_book_mapping_id
	COMMIT 
		EXEC spa_ErrorHandler 0
			, 'Pratos Book Mapping Table'
			, 'spa_pratos_mapping_book'
			, 'Success'
			, 'Data update Success'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			, 'Pratos Book Mapping Table'--tablename
			, 'spa_pratos_mapping_book'--sp
			, 'DB Error'--error type
			, 'Failed Updateing Data.'
			, 'Cannot Update Data.' --personal msg
		ROLLBACK 
	END CATCH
END

ELSE IF @flag = 'd'
BEGIN
	BEGIN TRY
	BEGIN TRAN 
		DELETE FROM pratos_book_mapping WHERE id = @pratos_book_mapping_id
		COMMIT 
		
		EXEC spa_ErrorHandler 0
			, 'Pratos Book Mapping Table'
			, 'spa_pratos_mapping_book'
			, 'Success'
			, 'Data Deleting Success'
			, ''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1
			EXEC spa_ErrorHandler @@ERROR
			, 'Pratos Book Mapping Table'
			, 'spa_pratos_mapping_book'
			, 'DB Error'
			, 'Failed Deleting data.'
			, ''
			
		ROLLBACK 
	END CATCH
END