IF OBJECT_ID('[dbo].[spa_approveLinkGen]') IS NOT NULL
    DROP PROCEDURE dbo.spa_approveLinkGen
GO 

--This procedure approves generated hedging relationships
--DROP PROC spa_approveLinkGen
--exec spa_approveLinkGen '198',  'y', '2009-06-30', '2012-07-31'

GO

CREATE PROCEDURE dbo.spa_approveLinkGen 
	@gen_link_id VARCHAR(MAX),
	@gen_approved CHAR(1) = 'y',
	@as_of_date VARCHAR(20) = NULL,
	@as_of_date_to VARCHAR(20) = NULL
AS
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET QUOTED_IDENTIFIER ON
	
	DECLARE @sql_stmt    VARCHAR(MAX)
	DECLARE @source      VARCHAR(50),
	        @process_id  VARCHAR(100)
	
	SELECT @process_id = REPLACE(NEWID(), '-', '_')
	
	SET @sql_stmt = 'UPDATE gen_fas_link_header SET gen_approved = ''' + @gen_approved + ''',approved_process_id=''' + @process_id + ''''
					+ 'WHERE gen_hedge_group_id in (' + @gen_link_id + ')'
	
	EXEC spa_print @sql_stmt
	EXEC (@sql_stmt)
	
	SET @source = @as_of_date + '|' + @as_of_date_to
	EXEC spa_compliance_workflow 117,'i',@process_id,@source			
	
	IF @@ERROR <> 0
	BEGIN
	    EXEC spa_ErrorHandler @@ERROR,
	         'Transaction Processing',
	         'spa_approve_gen_link',
	         'DB Error',
	         'Failed to approve gen relationships.',
	         ''
	    
	    RETURN
	END
	ELSE
	BEGIN
	    EXEC spa_ErrorHandler 0,
	         'Transaction Processing',
	         'spa_approve_gen_links',
	         'Success',
	         'Selected relationships approved.',
	         ''
	    
	    RETURN
	END




