--For Insert

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_TRANSPORTATION_CONTRACT_RANK]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].TRGINS_TRANSPORTATION_CONTRACT_RANK
GO

CREATE TRIGGER [dbo].[TRGINS_TRANSPORTATION_CONTRACT_RANK]
ON [dbo].[transportation_contract_rank]
FOR  INSERT
AS

	INSERT INTO transportation_contract_rank_audit
	  (
		[id],
		[contract_id],
		[rank_id],
		[effective_date],
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT 
		[transportation_contract_rank_id],
		[contract_id],
		[rank_id],
		[effective_date],
		create_user,
		create_ts,
		update_user,
		update_ts,
		'insert' [user_action]
		FROM   INSERTED
GO

--For update

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_TRANSPORTATION_CONTRACT_RANK]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_TRANSPORTATION_CONTRACT_RANK]
GO

CREATE TRIGGER [dbo].[TRGUPD_TRANSPORTATION_CONTRACT_RANK]
ON [dbo].[transportation_contract_rank]
FOR UPDATE
AS    
    UPDATE transportation_contract_rank
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM transportation_contract_rank t
    INNER JOIN DELETED u ON t.[transportation_contract_rank_id] = u.[transportation_contract_rank_id]                                 
	
	DECLARE @update_user    VARCHAR(200)
	DECLARE @update_ts  DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()   
      
    INSERT INTO transportation_contract_rank_audit
	  (
	    [id],
		[contract_id],
		[rank_id],
		[effective_date],
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT 
		[transportation_contract_rank_id],
		[contract_id],
		[rank_id],
		[effective_date],
		create_user,
		create_ts,
		@update_user,
		@update_ts,
		'update' [user_action]
	FROM   INSERTED
	
GO


--For Delete

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGDEL_TRANSPORTATION_CONTRACT_RANK]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_TRANSPORTATION_CONTRACT_RANK]
GO

CREATE TRIGGER [dbo].[TRGDEL_TRANSPORTATION_CONTRACT_RANK]
ON [dbo].[transportation_contract_rank]
FOR DELETE
AS                                     
  
    INSERT INTO transportation_contract_rank_audit
	  (
		[id],
		[contract_id],
		[rank_id],
		[effective_date],
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT 
		[transportation_contract_rank_id],
		[contract_id],
		[rank_id],
		[effective_date],
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    'delete' [user_action]
	FROM   DELETED
	
GO








