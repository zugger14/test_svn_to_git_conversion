IF OBJECT_ID(N'[dbo].[spa_change_group]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].spa_change_group
GO
 
SET ANSI_NULLS ON
GO
  
SET QUOTED_IDENTIFIER ON
GO
  
 
-- ===========================================================================================================
-- Author: rtuladhar@pioneersolutionsglobal.com
-- Create date: 2017-05-02
-- Description: change group
 
-- Params:
-- @flag VARCHAR(1000),
-- @group_id VARCHAR(MAX) = NULL,
-- @new_group VARCHAR(MAX) = NULL,
-- @delete_group VARCHAR(MAX) = NULL,
-- @match_group_shipment_id INT = NULL
-- ===========================================================================================================

CREATE PROCEDURE [dbo].spa_change_group
    @flag VARCHAR(1000),
	@group_id VARCHAR(MAX) = NULL,
	@new_group VARCHAR(MAX) = NULL,
	@delete_group VARCHAR(MAX) = NULL,
	@match_group_shipment_id INT = NULL,
	@previous_group_id INT = NULL
AS
SET NOCOUNT ON


/*
DECLARE 
@flag VARCHAR(1000),
@group_id VARCHAR(MAX) = NULL,
@new_group VARCHAR(MAX) = NULL,
@delete_group VARCHAR(MAX) = NULL,
@match_group_shipment_id INT = NULL,
@previous_group_id INT = NULL
 
--*/
   

DECLARE @sql VARCHAR(MAX)
IF @new_group = ''
	SET @new_group = NULL

--IF OBJECT_ID('tempdb..#filter_criteria') IS NOT NULL 
--	DROP TABLE #filter_criteria

IF @flag = 'change_group'
BEGIN
	BEGIN TRY
		BEGIN TRAN 
		IF @new_group IS NOT NULL -- insert new group name
		BEGIN
			INSERT INTO match_group(group_name)
			SELECT @new_group 

			SET @group_id = SCOPE_IDENTITY()
		END 
		--SELECT *
		UPDATE mgh
		SET match_group_id = @group_id
		FROM match_group_header mgh
		INNER JOIN match_group_shipment mgs ON mgs.match_group_shipment_id = mgh.match_group_shipment_id
		WHERE mgs.match_group_shipment_id = @match_group_shipment_id

		UPDATE match_group_shipment
		SET match_group_id = @group_id
		WHERE match_group_shipment_id = @match_group_shipment_id
	
		
	
		IF @delete_group = 'y'
		BEGIN 
			IF NOT EXISTS(SELECT 1 FROM match_group mg
							INNER JOIN match_group_shipment mgs ON mgs.match_group_id = mg.match_group_id
							WHERE mg.match_group_id = @previous_group_id)
			BEGIN 
				DELETE FROM match_group WHERE match_group_id = @previous_group_id
			END
		END
	--	ROLLBACK TRAN 

		COMMIT TRAN	
		
		EXEC spa_ErrorHandler 0,
			'Matching/Bookout Deals',
			'spa_change_group',
			'Success',
			'Changes has been saved successfully.',
			''
	END TRY
	BEGIN CATCH
		EXEC spa_ErrorHandler -1,
				'Matching/Bookout Deals',
				'spa_change_group',
				'DB Error',
				'Fail to update data.',
				''
	END CATCH
END 
ELSE IF @flag = 'getmatch'
BEGIN 
	SELECT match_group_id, group_name 
	FROM match_group
	WHERE match_group_id <> ISNULL(@previous_group_id, match_group_id)
END
 
 