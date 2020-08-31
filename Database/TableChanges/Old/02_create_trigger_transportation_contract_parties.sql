--For Insert

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_TRANSPORTATION_CONTRACT_PARTIES]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_TRANSPORTATION_CONTRACT_PARTIES]
GO

CREATE TRIGGER [dbo].[TRGINS_TRANSPORTATION_CONTRACT_PARTIES]
ON [dbo].[transportation_contract_parties]
FOR  INSERT
AS

	INSERT INTO transportation_contract_parties_audit
	  (
	    id,
	    contract_id,
	    party,
	    [type],
	    effective_date,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT 
	       transportation_contract_parties_id,
	       contract_id,
		   party,
		   [type],
		   effective_date,
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

IF OBJECT_ID('[dbo].[TRGUPD_TRANSPORTATION_CONTRACT_PARTIES]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_TRANSPORTATION_CONTRACT_PARTIES]
GO

CREATE TRIGGER [dbo].[TRGUPD_TRANSPORTATION_CONTRACT_PARTIES]
ON [dbo].[transportation_contract_parties]
FOR UPDATE
AS    
    UPDATE transportation_contract_parties
       SET update_user = dbo.FNADBUser(),
           update_ts = GETDATE()
    FROM transportation_contract_parties t
    INNER JOIN DELETED u ON t.[transportation_contract_parties_id] = u.[transportation_contract_parties_id]                                 
	
	DECLARE @update_user    VARCHAR(200)
	DECLARE @update_ts  DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()   
      
    INSERT INTO transportation_contract_parties_audit
	  (
	    id,
	    contract_id,
	    party,
	    [type],
	    effective_date,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT 
	       transportation_contract_parties_id,
	       contract_id,
		   party,
		   [type],
		   effective_date,
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

IF OBJECT_ID('[dbo].[TRGDEL_TRANSPORTATION_CONTRACT_PARTIES]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_TRANSPORTATION_CONTRACT_PARTIES]
GO

CREATE TRIGGER [dbo].[TRGDEL_TRANSPORTATION_CONTRACT_PARTIES]
ON [dbo].[transportation_contract_parties]
FOR DELETE
AS                                     
  
    INSERT INTO transportation_contract_parties_audit
	  (
		id,
	    contract_id,
	    party,
	    [type],
	    effective_date,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT 
	       transportation_contract_parties_id,
	       contract_id,
		   party,
		   [type],
		   effective_date,
	       create_user,
	       create_ts,
	       update_user,
	       update_ts,
	       'delete' [user_action]
	FROM   DELETED
	
GO








