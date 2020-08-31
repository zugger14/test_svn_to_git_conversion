IF OBJECT_ID(N'[dbo].[spa_ixp_rules_collection]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_ixp_rules_collection]
GO
 
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

/*
 * @import_data FORMAT
 [  
   {  
      "sequence_number":"1",
      "import_rule_hash":"F9DCB17F_137F_484B_BC28_910FF36CC36E",
      "import_source":"21405",
      "import_file_name":"firstsequencefile.xls"
   },
   {  
      "sequence_number":"2",
      "import_rule_hash":"F9DCB17F_137F_484B_BC28_910FF36CC36E",
      "import_source":"21400",
      "import_file_name":"secondsequencefile.csv"
   },
   {  
      "sequence_number":"3",
      "import_rule_hash":"F9DCB17F_137F_484B_BC28_910FF36CC36E",
      "import_source":"21400",
      "import_file_name":"thirdsequencefile.csv"
   }
]
 */

CREATE PROCEDURE [dbo].[spa_ixp_rules_collection]
	@flag			CHAR(100),
	@import_data	VARCHAR(MAX),
	@batch_process_id VARCHAR(50) = NULL,
	@batch_report_param VARCHAR(1000) = NULL 

AS
SET NOCOUNT ON


DECLARE @process_id			VARCHAR(1000) = dbo.FNAGetNewID(),
		@temp_process_table	VARCHAR(1000),
		@sequence_number	INT,
		@import_rule_id		INT,
		@import_source		INT,
		@import_file_name	VARCHAR(1000),
		@user_login_id		VARCHAR(100) = dbo.FNADBUser()

IF @flag = 'import_excel'
BEGIN
	IF OBJECT_ID('tempdb..#output_status') IS NOT NULL
		DROP TABLE #output_status

	CREATE TABLE #output_status (
		ErrorCode			VARCHAR(1000),
		Module				VARCHAR(1000),
		Area				VARCHAR(1000),
		[Status]			VARCHAR(1000),
		[Message]			VARCHAR(1000),
		[Recommendation]	VARCHAR(1000)
	)


	DECLARE @output_process_table VARCHAR(1000) = 'adiha_process.dbo.import_data_sequence_' + dbo.FNAGetNewID()
	EXEC spa_parse_json @flag = 'parse', @output_process_table = @output_process_table, @return_output = 0, @json_string = @import_data

	IF OBJECT_ID('tempdb..#import_sequence') IS NOT NULL
		DROP TABLE #import_sequence

	CREATE TABLE #import_sequence (
		sequence_number		INT,
		import_rule_hash	VARCHAR(1000),
		import_source		INT,
		import_file_name	VARCHAR(1000)
	)

	EXEC('INSERT INTO #import_sequence (sequence_number, import_rule_hash, import_source, import_file_name)
			SELECT sequence_number, import_rule_hash, import_source, import_file_name FROM ' + @output_process_table)

	DECLARE @run_in_debug_mode CHAR(1) = 'x'
	DECLARE @max_sequence INT
	SELECT @max_sequence = MAX(sequence_number) FROM #import_sequence
	
	DECLARE import_sequence_cursor CURSOR FOR
	SELECT isq.sequence_number, ir.ixp_rules_id, isq.import_source, isq.import_file_name
	FROM #import_sequence isq
	INNER JOIN ixp_rules ir ON ir.ixp_rule_hash = isq.import_rule_hash
	ORDER BY isq.sequence_number

	OPEN import_sequence_cursor
	FETCH NEXT FROM import_sequence_cursor 
	INTO @sequence_number, @import_rule_id, @import_source, @import_file_name
			
			
	WHILE @@FETCH_STATUS = 0   
	BEGIN  	
		SET @temp_process_table =  'adiha_process.dbo.temp_import_data_table_' + dbo.FNAGetNewID()
		SET @process_id = dbo.FNAGetNewID()

		--INSERT INTO #output_status
		EXEC spa_ixp_rules  @flag='t'
							, @process_id=@process_id
							, @ixp_rules_id=@import_rule_id
							, @run_table=@temp_process_table
							, @source =@import_source
							, @run_with_custom_enable = 'n'
							, @server_path=@import_file_name
							, @source_delimiter=','
							, @source_with_header='y'
							, @run_in_debug_mode='y'

		FETCH NEXT FROM import_sequence_cursor 
		INTO @sequence_number, @import_rule_id, @import_source, @import_file_name	
	END
	CLOSE import_sequence_cursor
	DEALLOCATE import_sequence_cursor
END

ELSE IF @flag = 'import_excel_job'
BEGIN	
	BEGIN TRY
		DECLARE @job_query VARCHAR(MAX)
		DECLARE @job_name VARCHAR(1000) = 'import_job_' + dbo.FNAGetNewID()
		SET @job_query = ' spa_ixp_rules_collection @flag = ''import_excel'', @import_data = ''' + @import_data + ''''

		EXEC spa_run_sp_as_job @job_name, @job_query, @job_name, @user_login_id 

		EXEC spa_ErrorHandler 0,
					 'Import Data',
					 'spa_ixp_rules_collection.',
					 'Success',
					 'Import process has been started.',
				 ''
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK
		   
		EXEC spa_ErrorHandler -1,
				'Import Data',
				'spa_ixp_rules_collection.',
				'Error',
				'Failed to start import process.',
				''
	END CATCH
END