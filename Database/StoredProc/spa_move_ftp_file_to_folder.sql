IF OBJECT_ID('spa_move_ftp_file_to_folder') IS NOT NULL
    DROP PROC spa_move_ftp_file_to_folder
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
	It uses clr function to move the file from FTP folder to another ftp folder location.

	Parameters 
	@file_transfer_endpoint_id : File transfer endpoint configured id
	@source_file			: Actual file name with document_path that from temp note
	@remote_working_directory		: Remote FTP working directory, Source Files Contents location to move
	@target_remote_directory		: Remote FTP target directory where files will be moved
    @result					: Use of OUTPUT clause to capture the result.
*/

CREATE PROC [dbo].[spa_move_ftp_file_to_folder]
(
	@file_transfer_endpoint_id INT,
    @source_file NVARCHAR(1024),
	@remote_working_directory NVARCHAR(1024) = NULL,
    @target_remote_directory NVARCHAR(1024) = NULL,
    @result NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	EXEC spa_move_ftp_file_to_folder_using_clr   @file_transfer_endpoint_id = @file_transfer_endpoint_id, @source_file = @source_file, @remoteWorkingDirectory = @remote_working_directory, @targetRemoteDirectory = @target_remote_directory,  @output_result = @result OUTPUT
END