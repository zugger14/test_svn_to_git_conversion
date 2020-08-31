
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('[dbo].[TRGUPD_TRANSPORTATION_CONTRACT_CAPACITY]', 'TR') IS NOT NULL
    DROP TRIGGER [dbo].[TRGUPD_TRANSPORTATION_CONTRACT_CAPACITY]
GO

CREATE TRIGGER [dbo].[TRGUPD_TRANSPORTATION_CONTRACT_CAPACITY]
ON [dbo].[transportation_contract_capacity]
FOR  UPDATE
AS
	UPDATE transportation_contract_capacity
	SET    update_user = dbo.FNADBUser(),
	       update_ts = GETDATE()
	WHERE  transportation_contract_capacity.ID IN (SELECT ID
	                                               FROM   DELETED)