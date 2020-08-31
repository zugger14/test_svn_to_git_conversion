IF OBJECT_ID(N'[dbo].[spa_rfx_report_page_line]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_page_line]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2012-08-15
-- Description: Add/Update Operations for Report Page Image 
-- IMPORTANT NOTE: THIS STORED PROCEDURE MUST NOT CONTAIN print() statement as this SP is called by SQLSRV library (in the application) which creates issues when it encounters print()
 
-- Params:
-- @flag					CHAR	- Operation flag
-- @process_id				VARCHAR - Operation ID
-- @report_page_line_id	INT		- Textbox ID
-- @page_id					INT		- Report Page ID
-- @name					VARCHAR(300) - Initial Filename
-- @filename				VARCHAR(200) - Generated Filename
-- @width					VARCHAR(45)	 - Content Width
-- @height					VARCHAR(45)	 - Content Height
-- @top						VARCHAR(45)	 - Content Top Position
-- @left 					VARCHAR(45)	 - Content Left Position
-- @hash					VARCHAR(128) - Unique Identifier

-- Sample Use :: EXEC spa_rfx_report_page_line 'i', '751FAC2F_F97C_479F_BE6B_CB39EEE7B0EA', NULL, 648, 'IMG_21112012_144048.png', '216572acaa31ca543242634d38824557.png', '2.6666666666666665', '0.7733333333333333', '4.933333333333334', '2.4266666666666667'
-- Sample Use :: EXEC spa_rfx_report_page_line 'u', '751FAC2F_F97C_479F_BE6B_CB39EEE7B0EA', 123, 648, 'IMG_21112012_144048.png', '216572acaa31ca543242634d38824557.png', '2.6666666666666665', '0.7733333333333333', '4.933333333333334', '2.4266666666666667'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_page_line]
    @flag					CHAR(1),
    @process_id				VARCHAR(500) = NULL,
    @report_page_line_id	INT = NULL,
    @page_id				INT = NULL,
    @color					VARCHAR(45) = NULL,
    @size					VARCHAR(45) = NULL,
    @style					VARCHAR(45) = NULL,
    @width					VARCHAR(45) = NULL,
    @height					VARCHAR(45) = NULL,
    @top					VARCHAR(45) = NULL,
    @left					VARCHAR(45) = NULL,
    @hash					VARCHAR(128) = NULL
AS
SET NOCOUNT ON
DECLARE @user_name              VARCHAR(50),
        @rfx_report_page_line  VARCHAR(200),
        @sql                    VARCHAR(MAX)

SET @user_name = dbo.FNADBUser()
SET @color = '#'+@color
SET @hash = dbo.FNAGetNewID()
SET @rfx_report_page_line = dbo.FNAProcessTableName('report_page_line', @user_name, @process_id)

IF @flag = 'i'
BEGIN
	SET @sql = 'INSERT INTO ' + @rfx_report_page_line + '( page_id, color, size, style, width, height, [top], [left], hash)
                VALUES(
					' + CAST(@page_id AS VARCHAR(10)) + ',
					''' + @color + ''',
					''' + @size + ''',
					''' + @style + ''',
					' + @width + ',
					' + @height + ',
					' + @top + ',
					' + @left + ',
					''' + @hash + '''
                  )'
    EXEC (@sql)
    SET @report_page_line_id = IDENT_CURRENT(@rfx_report_page_line);
    EXEC spa_ErrorHandler 0,
	         'Reporting FX',
	         'spa_rfx_report_page_line',
	         'Success',
	         'Data successfully inserted.',
	         @report_page_line_id
END

IF @flag = 'u'
BEGIN
	IF @report_page_line_id IS NOT NULL
	BEGIN
	SET @sql = 'UPDATE ' + @rfx_report_page_line + '
                  SET [color] = ''' + @color + ''', [size] = ''' + @size + ''',[style] = ''' + @style + ''',
					  width = ' + @width + ',height = ' + @height + ',
					  [top] = ' + @top + ',[left] = ' + @left + '
	            WHERE report_page_line_id  = ' + CAST(@report_page_line_id AS VARCHAR(10))
    EXEC (@sql)
    EXEC spa_ErrorHandler 0,
	         'Reporting FX',
	         'spa_rfx_report_page_line',
	         'Success',
	         'Data successfully updated.',
	         @report_page_line_id
	END
END

IF @flag = 'd'
BEGIN
	IF @report_page_line_id IS NOT NULL
		BEGIN
			SET @sql = 'DELETE FROM ' + @rfx_report_page_line + ' WHERE report_page_line_id = ' + CAST(@report_page_line_id AS VARCHAR(10))
			EXEC(@sql)
			EXEC spa_ErrorHandler 0,
					 'Reporting FX',
					 'spa_rfx_report_page_line',
					 'Success',
					 'Data successfully deleted.',
					 @process_id
		END	
	ELSE
		BEGIN
			EXEC spa_ErrorHandler 0,
					 'Reporting FX',
					 'spa_rfx_report_page_line',
					 'Failed',
					 'Data deletion failed.',
					 @process_id
		END
END

IF @flag = 's'
BEGIN
	IF @report_page_line_id IS NOT NULL
		BEGIN
			SET @sql = 'SELECT 
							color, size, style, width, height, [top], [left]
						FROM ' + @rfx_report_page_line + ' WHERE report_page_line_id = ' + CAST(@report_page_line_id AS VARCHAR(10))
			EXEC(@sql)
			EXEC spa_ErrorHandler 0,
					 'Reporting FX',
					 'spa_rfx_report_page_line',
					 'Success',
					 'Data successfully selected.',
					 @process_id
		END	
	ELSE
		BEGIN
			EXEC spa_ErrorHandler 0,
					 'Reporting FX',
					 'spa_rfx_report_page_line',
					 'Failed',
					 'Data selection failed.',
					 @process_id
		END
END

IF @flag = 'o'
BEGIN
	IF @report_page_line_id IS NOT NULL
		BEGIN
			SET @sql = 'SELECT 
							color, size, style, width, height, [top], [left]
						FROM report_page_line WHERE report_page_line_id = ' + CAST(@report_page_line_id AS VARCHAR(10))
			EXEC(@sql)
		END	
	ELSE
		BEGIN
			EXEC spa_ErrorHandler 0,
					 'Reporting FX',
					 'spa_rfx_report_page_line',
					 'Failed',
					 'Data selection failed.',
					 @process_id
		END
END