
IF OBJECT_ID(N'[dbo].[spa_rfx_report_page_textbox_dhx]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_rfx_report_page_textbox_dhx]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
-- ===========================================================================================================
-- Author: padhikari@pioneersolutionsglobal.com
-- Create date: 2012-08-15
-- Description: Add/Update Operations for Report Page Textbox
 
-- Params:
-- @flag					CHAR	- Operation flag
-- @process_id				VARCHAR - Operation ID
-- @report_page_textbox_id	INT		- Textbox ID
-- @page_id					INT		- Report Page ID
-- @content					VARCHAR(MAX) - Textbox Content
-- @font					VARCHAR(200) - Font Family
-- @font_size				VARCHAR(200) - Font Size
-- @font_style				VARCHAR(10)	 - Font Style (B,I,U)
-- @width					VARCHAR(45)	 - Content Width
-- @height					VARCHAR(45)	 - Content Height
-- @top						VARCHAR(45)	 - Content Top Position
-- @left 					VARCHAR(45)	 - Content Left Position
-- @hash					VARCHAR(128) - Unique Identifier

-- Sample Use :: EXEC spa_rfx_report_page_textbox_dhx 'i', 'D1A620D4_337F_4938_A6C9_EC3769BB6B8B', NULL, 637, 't df dfgdf', 'Arial', '8', '0,0,0', '2.6666666666666665', '0.26666666666666666', '1.5466666666666666', '0.6933333333333334'
-- Sample Use :: EXEC spa_rfx_report_page_textbox_dhx 'u', 'D1A620D4_337F_4938_A6C9_EC3769BB6B8B', 1, 637, 't df dfgdf', 'Arial', '8', '0,0,0', '2.6666666666666665', '0.26666666666666666', '1.5466666666666666', '0.6933333333333334'
-- ===========================================================================================================
CREATE PROCEDURE [dbo].[spa_rfx_report_page_textbox_dhx]
    @flag CHAR(1),
    @process_id VARCHAR(500) = NULL,
    @report_page_textbox_id INT = NULL,
    @page_id INT = NULL,
    @content VARCHAR(MAX) = NULL,
    @font VARCHAR(200) = NULL,
    @font_size VARCHAR(200) = NULL,
    @font_style VARCHAR(10) = NULL,
    @width VARCHAR(45) = NULL,
    @height VARCHAR(45) = NULL,
    @top VARCHAR(45) = NULL,
    @left VARCHAR(45) = NULL,
    @hash VARCHAR(128) = NULL
AS
SET NOCOUNT ON
DECLARE @user_name                       VARCHAR(50),
        @rfx_report_page_textbox          VARCHAR(200),
        @sql                             VARCHAR(MAX)

SET @user_name = dbo.FNADBUser()
SET @hash = dbo.FNAGetNewID()
SET @rfx_report_page_textbox = dbo.FNAProcessTableName('report_page_textbox', @user_name, @process_id)

DECLARE @rfx_report VARCHAR(200) = dbo.FNAProcessTableName('report', @user_name, @process_id)
DECLARE @rfx_report_page VARCHAR(200) = dbo.FNAProcessTableName('report_page', @user_name, @process_id)

IF @flag = 'i'
BEGIN TRY
/*
	BEGIN TRAN
	--INSERT DATASET FOR TEXTBOX DYNAMIC PARAM VALUE RESOLUTION START
	DECLARE @report_id INT, @source_id INT
	
	SELECT @source_id = ds.data_source_id
	FROM data_source ds 
	WHERE ds.name = 'ResolveTextParam'

	DECLARE @sqln NVARCHAR(MAX)
	SET @sqln = '
	SELECT @report_id = r.report_id
	FROM ' + @rfx_report + ' r
	INNER JOIN ' + @rfx_report_page + ' rp ON rp.report_id = r.report_id
	WHERE rp.report_page_id = ' + @page_id + '
	'
	EXEC sp_executesql @sqln, N'@report_id INT OUTPUT', @report_id OUT

	IF OBJECT_ID('tempdb..#error_info') IS NOT NULL
		DROP TABLE #error_info
	CREATE TABLE #error_info (
		error_code VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL,
		module VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL,
		area VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL,
		[status] VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL,
		[message] VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL,
		recommendation VARCHAR(1000) COLLATE DATABASE_DEFAULT NULL
	)

	INSERT INTO #error_info
	EXEC spa_rfx_report_dataset_dhx @flag='i', @process_id=@process_id, @report_id=@report_id, @source_id=@source_id

	IF NOT EXISTS(SELECT TOP 1 1 FROM #error_info WHERE error_code = 0)
	BEGIN
		RAISERROR('dataset_error', 16, 1)
		RETURN
	END
	--INSERT DATASET FOR TEXTBOX DYNAMIC PARAM VALUE RESOLUTION END
	*/
	SET @sql = 'INSERT INTO ' + @rfx_report_page_textbox + '
                  ( page_id,content,font,font_size,font_style,width,height,[top],[left],hash)VALUES(
					' + CAST(@page_id AS VARCHAR(10)) + ',
					''' + @content + ''',
					''' + @font + ''',
					''' + @font_size + ''',
					''' + @font_style + ''',
					' + @width + ',
					' + @height + ',
					' + @top + ',
					' + @left + ',
					''' + @hash + '''
                  )'
    EXEC (@sql)
	
    SET @report_page_textbox_id = IDENT_CURRENT(@rfx_report_page_textbox)

	

	EXEC spa_ErrorHandler 0, 'Reporting FX', 'spa_rfx_report_dataset_dhx', 'Success','',@report_page_textbox_id
	
	

	COMMIT

    EXEC spa_ErrorHandler 0,
	         'Reporting FX',
	         'spa_rfx_report_page_textbox_dhx',
	         'Success',
	         'Data successfully inserted.',
	         @report_page_textbox_id
END TRY
BEGIN CATCH
	ROLLBACK
	DECLARE @err_msg_i VARCHAR(5000) = ERROR_MESSAGE()

	IF @err_msg_i = 'dataset_error'
		SET @err_msg_i = 'Error on inserting dataset ResolveTextParam'
	EXEC spa_ErrorHandler 1,
	         'Reporting FX',
	         'spa_rfx_report_page_textbox_dhx',
	         'Failed',
	         @err_msg_i,
	         @report_page_textbox_id
	

END CATCH

IF @flag = 'u'
BEGIN
	IF @report_page_textbox_id IS NOT NULL
	BEGIN
	SET @sql = 'UPDATE ' + @rfx_report_page_textbox + '
                  SET content = ''' + @content + ''', font = ''' + @font + ''', font_size = ''' + @font_size + ''',
                  font_style = ''' + @font_style + ''', width = ' + @width + ',height = ' + @height + ',
                  [top] = ' + @top + ',[left] = ' + @left + '
	            WHERE report_page_textbox_id  = ' + CAST(@report_page_textbox_id AS VARCHAR(10))
    EXEC (@sql)
    --PRINT (@sql)
    EXEC spa_ErrorHandler 0,
	         'Reporting FX',
	         'spa_rfx_report_page_textbox_dhx',
	         'Success',
	         'Data successfully updated.',
	         @report_page_textbox_id
	END
END

IF @flag = 'd'
BEGIN
	IF @report_page_textbox_id IS NOT NULL
		BEGIN
			SET @sql = 'DELETE FROM ' + @rfx_report_page_textbox + ' WHERE report_page_textbox_id = ' + CAST(@report_page_textbox_id AS VARCHAR(10))
			EXEC(@sql)
			EXEC spa_ErrorHandler 0,
					 'Reporting FX',
					 'spa_rfx_report_page_textbox_dhx',
					 'Success',
					 'Data successfully deleted.',
					 @process_id
		END	
	ELSE
		BEGIN
			EXEC spa_ErrorHandler 0,
					 'Reporting FX',
					 'spa_rfx_report_page_textbox_dhx',
					 'Failed',
					 'Data deletion failed.',
					 @process_id
		END
END
