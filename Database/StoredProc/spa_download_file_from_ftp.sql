IF OBJECT_ID('spa_download_file_from_ftp') IS NOT NULL
    DROP PROC spa_download_file_from_ftp
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	It uses clr function to download the file from FTP.

	Parameters 
	@file_transfer_endpoint_id : File transfer endpoint id configured in file_transfer_endpoint table
	@local_destination		: temp note path to be download.
    @source_filename		: Remote path with file name
	@remote_directory		: Remote FTP directory name 
    @extension				: extension of file.
    @result					: Output result.
*/

CREATE PROC [dbo].[spa_download_file_from_ftp]
(
	@file_transfer_endpoint_id INT,
    @local_destination NVARCHAR(1024) = NULL,
    @source_filename NVARCHAR(1024) = NULL,
    @remote_directory NVARCHAR(1024) = NULL,
	@extension NVARCHAR(10)= NULL,
    @result NVARCHAR(MAX) OUTPUT
)
AS
/*
DECLARE 
	file_transfer_endpoint_id INT = 1
	@local_destination NVARCHAR(1024) = NULL,
    @source_filename NVARCHAR(1024) = NULL,
    @remote_directory NVARCHAR(1024) = NULL,
	@extension = NULL,
    @result NVARCHAR(MAX) --OUTPUT
--*/

BEGIN
	EXEC spa_download_file_from_ftp_using_clr @file_transfer_endpoint_id = @file_transfer_endpoint_id, 
											  @source_file= @source_filename,
											  @target_remote_directory = @remote_directory, 
											  @destination = @local_destination,
											  @extension = @extension,
											  @output_result = @result OUTPUT
END