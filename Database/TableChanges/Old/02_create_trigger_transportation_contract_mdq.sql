--For Insert

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGINS_TRANSPORTATION_CONTRACT_MDQ]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGINS_TRANSPORTATION_CONTRACT_MDQ]
GO

CREATE TRIGGER [dbo].[TRGINS_TRANSPORTATION_CONTRACT_MDQ]
ON [dbo].[transportation_contract_mdq]
FOR  INSERT
AS

	INSERT INTO transportation_contract_mdq_audit
	  (
	    id,
	    contract_id,
	    effective_date,
	    mdq,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT 
	       transportation_contract_mdq_id,
	       contract_id,
		   effective_date,
		   mdq,
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

IF OBJECT_ID('[dbo].[TRGUPD_TRANSPORTATION_CONTRACT_MDQ]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_TRANSPORTATION_CONTRACT_MDQ]
GO

CREATE TRIGGER [dbo].[TRGUPD_TRANSPORTATION_CONTRACT_MDQ]
ON [dbo].[transportation_contract_mdq]
FOR UPDATE
AS                                     
	
	DECLARE @update_user    VARCHAR(200)
	DECLARE @update_ts  DATETIME

	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.transportation_contract_mdq
       SET update_user = @update_user,
           update_ts = @update_ts
    FROM dbo.transportation_contract_mdq tcm
      INNER JOIN DELETED u ON tcm.transportation_contract_mdq_id = u.transportation_contract_mdq_id     
      
    INSERT INTO transportation_contract_mdq_audit
	  (
	    id,
	    contract_id,
	    effective_date,
	    mdq,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT 
	       transportation_contract_mdq_id,
	       contract_id,
		   effective_date,
		   mdq,
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

IF OBJECT_ID('[dbo].[TRGDEL_TRANSPORTATION_CONTRACT_MDQ]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGDEL_TRANSPORTATION_CONTRACT_MDQ]
GO

CREATE TRIGGER [dbo].[TRGDEL_TRANSPORTATION_CONTRACT_MDQ]
ON [dbo].[transportation_contract_mdq]
FOR DELETE
AS                                     
  
    INSERT INTO transportation_contract_mdq_audit
	  (
	    id,
	    contract_id,
	    effective_date,
	    mdq,
	    create_user,
	    create_ts,
	    update_user,
	    update_ts,
	    user_action
	  )
	SELECT 
	       transportation_contract_mdq_id,
	       contract_id,
		   effective_date,
		   mdq,
	       create_user,
	       create_ts,
	       update_user,
	       update_ts,
	       'delete' [user_action]
	FROM   DELETED
	
GO








