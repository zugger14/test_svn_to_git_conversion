
IF OBJECT_ID(N'spa_approveRepricedLinkGen', N'P') IS NOT NULL
DROP PROCEDURE [dbo].[spa_approveRepricedLinkGen]
 GO 





--This procedure approves generated hedging relationships for repricing 
--DROP PROC spa_approveRepricedLinkGen


CREATE PROCEDURE [dbo].[spa_approveRepricedLinkGen] @gen_hedge_group_id int,
					@gen_approved varchar(1)			    
AS

DECLARE @sql_stmt varchar(1000)
DECLARE @gen_link_id INT


If @gen_approved = 'y'
BEGIN
	select @gen_link_id = gen_link_id from gen_fas_link_header where gen_hedge_group_id = @gen_hedge_group_id
	
	SET @sql_stmt = '
	UPDATE gen_fas_link_header SET gen_approved = ''' + @gen_approved + '''
	WHERE     gen_link_id = ' + cast(@gen_link_id as varchar) 


	--print @sql_stmt
	exec (@sql_stmt)

	If @@ERROR = 0
	BEGIN
		CREATE TABLE #status
		(
		ErrorCode varchar(50) COLLATE DATABASE_DEFAULT,
		Module varchar(50) COLLATE DATABASE_DEFAULT,
		Area varchar(50) COLLATE DATABASE_DEFAULT,
		Status varchar(50) COLLATE DATABASE_DEFAULT,
		Message varchar(250) COLLATE DATABASE_DEFAULT,
		Recommendation varchar(250) COLLATE DATABASE_DEFAULT
		)
		
-- 		DECLARE @eff_test_profile_id int
		DECLARE @user_name varchar(50)
		DECLARE @job_name varchar(50)
-- 		SELECT 	@eff_test_profile_id = eff_test_profile_id  FROM gen_hedge_group where gen_hedge_group_id = @gen_hedge_group_id

		set @user_name = dbo.FNADBUser()
		set @job_name = 'FinalizeJob - ' + cast(@gen_hedge_group_id as varchar) 
		INSERT #status 
		EXEC spa_finalize_approved_transactions_job 'u', 30, @job_name, @user_name, NULL

		--EXEC spa_gen_transaction @gen_hedge_group_id, @eff_test_profile_id,  @user_name
	
		
		If (select count(*) from #status where ErrorCode = 'Error') > 0 
		BEGIN
			Select * from #status
			return
		END
	END
END
Else
BEGIN
	EXEC spa_genhedgegroup 'd', @gen_hedge_group_id
END


If @@ERROR <> 0
BEGIN
	Exec spa_ErrorHandler @@ERROR, 'Transaction Processing', 
			'spa_approve_gen_link', 'DB Error', 
			'Failed to approve gen relationships.', ''
	Return
END
Else
BEGIN
	Exec spa_ErrorHandler 0, 'Transaction Processing', 
			'spa_approve_gen_links', 'Success', 
			'Selected relationships approved.', ''
	Return
END






