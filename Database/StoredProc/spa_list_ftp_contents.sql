IF OBJECT_ID('spa_list_ftp_contents') IS NOT NULL
    DROP PROC spa_list_ftp_contents
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[spa_list_ftp_contents]
(
	@file_transfer_endpoint_id INT,
    @remote_directory NVARCHAR(1024) = NULL,
    @result NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	EXEC spa_list_ftp_contents_using_clr @file_transfer_endpoint_id = @file_transfer_endpoint_id, 
										 @target_remote_directory = @remote_directory, 
										 @output_result = @result OUTPUT
END