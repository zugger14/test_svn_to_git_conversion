/*
 * [source_deal_prepay] - Insert Trigger
 */

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_source_deal_prepay]'))
    DROP TRIGGER [dbo].[TRGINS_source_deal_prepay]
GO
 
CREATE TRIGGER [dbo].[TRGINS_source_deal_prepay]
ON [dbo].[source_deal_prepay]
FOR INSERT
AS
BEGIN
	INSERT INTO source_deal_prepay_audit
	  (
	    source_deal_prepay_id,
		prepay,
		value,
		percentage,
		formula_id,
		settlement_date,
		settlement_calendar,
		settlement_days,
		payment_date,
		payment_calendar,
		payment_days,
		granularity,
		source_deal_header_id,		create_user,
		create_ts,
		update_user,
		update_ts,
		user_action	  )
	SELECT 
		source_deal_prepay_id,
		prepay,
		value,
		percentage,
		formula_id,
		settlement_date,
		settlement_calendar,
		settlement_days,
		payment_date,
		payment_calendar,
		payment_days,
		granularity,
		source_deal_header_id,
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts],
		'insert'
	FROM  INSERTED
END
GO


/*
 * [source_deal_prepay] - Update Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_deal_prepay]'))
    DROP TRIGGER [dbo].[TRGUPD_source_deal_prepay]
GO
 
CREATE TRIGGER [dbo].[TRGUPD_source_deal_prepay]
ON [dbo].[source_deal_prepay]
FOR UPDATE
AS
BEGIN
	DECLARE @update_user  VARCHAR(200)
	DECLARE @update_ts    DATETIME
	
	SET @update_user = dbo.FNADBUser()
	SET @update_ts = GETDATE()
	
	UPDATE dbo.source_deal_prepay
	SET    update_user = @update_user,
	       update_ts = @update_ts
	FROM   dbo.source_deal_prepay sdp
	       INNER JOIN DELETED u ON  sdp.source_deal_prepay_id = u.source_deal_prepay_id  
	
	INSERT INTO source_deal_prepay_audit
	  (
	    source_deal_prepay_id,
		prepay,
		value,
		percentage,
		formula_id,
		settlement_date,
		settlement_calendar,
		settlement_days,
		payment_date,
		payment_calendar,
		payment_days,
		granularity,
		source_deal_header_id,		create_user,
		create_ts,
		update_user,
		update_ts,
		user_action	  )
	SELECT 
		source_deal_prepay_id,
		prepay,
		value,
		percentage,
		formula_id,
		settlement_date,
		settlement_calendar,
		settlement_days,
		payment_date,
		payment_calendar,
		payment_days,
		granularity,
		source_deal_header_id,
		[create_user],
		[create_ts],
	    @update_user,
		@update_ts,
		'update' [user_action]
	FROM   INSERTED
END
GO



/*
 * [source_deal_prepay] - Delete Trigger
 */

IF  EXISTS (SELECT * FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_source_deal_prepay]'))
    DROP TRIGGER [dbo].[TRGDEL_source_deal_prepay]
GO
 
CREATE TRIGGER [dbo].[TRGDEL_source_deal_prepay]
ON [dbo].[source_deal_prepay]
FOR DELETE
AS
BEGIN
	INSERT INTO source_deal_prepay_audit
	  (
		source_deal_prepay_id,
		prepay,
		value,
		percentage,
		formula_id,
		settlement_date,
		settlement_calendar,
		settlement_days,
		payment_date,
		payment_calendar,
		payment_days,
		granularity,
		source_deal_header_id,		create_user,
		create_ts,
		update_user,
		update_ts,
		user_action	  )
	SELECT 
		source_deal_prepay_id,
		prepay,
		value,
		percentage,
		formula_id,
		settlement_date,
		settlement_calendar,
		settlement_days,
		payment_date,
		payment_calendar,
		payment_days,
		granularity,
		source_deal_header_id,
		ISNULL([create_user], dbo.FNADBUser()),
		ISNULL([create_ts], GETDATE()),
		[update_user],
		[update_ts],
		'delete'
	FROM    DELETED
END