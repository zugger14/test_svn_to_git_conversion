IF OBJECT_ID('spa_upload_file_to_ftp') IS NOT NULL
    DROP PROC spa_upload_file_to_ftp
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	It uses clr function to download the file from FTP.

	Parameters 
	@file_transfer_endpoint_id : File transfer endpoint id, Configured in file_transfer_endpoint table
    @source_filename		: Actual file name with document_path that from temp note
	@remote_directory		: Remote FTP directory name 
    @result					: Output result.
*/

CREATE PROC [dbo].[spa_upload_file_to_ftp]
(
	@file_transfer_endpoint_id INT,
    @source_filename NVARCHAR(1024),
    @remote_directory NVARCHAR(1024),
    @result NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	EXEC spa_upload_file_to_ftp_using_clr @file_transfer_endpoint_id = @file_transfer_endpoint_id, 
										  @source_file= @source_filename,
										  @target_remote_directory=@remote_directory,
										  @output_result = @result OUTPUT
END