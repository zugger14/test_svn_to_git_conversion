

GO
/****** Object:  StoredProcedure [dbo].[spa_process_risk_control_acknowledge]    Script Date: 10/27/2008 17:24:32 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_process_risk_control_acknowledge]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_process_risk_control_acknowledge]


GO
/****** Object:  StoredProcedure [dbo].[spa_process_risk_control_acknowledge]    Script Date: 10/27/2008 17:24:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spa_process_risk_control_acknowledge]
	@risk_control_email_id int=null,
    @as_of_date varchar(200)=null,
	@message_id int = null,
	@loggedUser varchar(100) = NULL
 

AS
BEGIN

	DECLARE @count INT       	

    INSERT into process_risk_controls_reminders_acknowledge(
     risk_control_reminder_id,
     as_of_date 
     ) VALUES(
     @risk_control_email_id,
     @as_of_date)

--	SELECT @loggedUser = dbo.FNADBUser()
-- #count table will be populated with the pending reminders for the day. If its 1 then on click of acknowledge, it will delete the reminder for 
-- that day and user.
	CREATE TABLE #count
	(
	col1 varchar(1000) COLLATE DATABASE_DEFAULT,
	col2 varchar(1000) COLLATE DATABASE_DEFAULT,
	col3 varchar(1000) COLLATE DATABASE_DEFAULT,
	col4 varchar(1000) COLLATE DATABASE_DEFAULT,
	col5 varchar(1000) COLLATE DATABASE_DEFAULT,
	col6 varchar(1000) COLLATE DATABASE_DEFAULT,
	col7 varchar(1000) COLLATE DATABASE_DEFAULT,
	col8 varchar(1000) COLLATE DATABASE_DEFAULT,
	col9 varchar(1000) COLLATE DATABASE_DEFAULT,
	)


	
	INSERT #count
		EXEC spa_Get_Risk_Control_Activities_perform_reminder @loggedUser,@as_of_date,NULL,NULL,NULL,NULL,R,1,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	SELECT @count = count(*) FROM #count


	IF @count=0	
		EXEC spa_message_board 'd', @loggedUser ,@message_id,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'n'

     
END





