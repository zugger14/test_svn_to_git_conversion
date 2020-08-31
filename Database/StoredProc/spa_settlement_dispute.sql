/****** Object:  StoredProcedure [dbo].[spa_settlement_dispute]    Script Date: 07/29/2009 18:33:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_settlement_dispute]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_settlement_dispute]
/****** Object:  StoredProcedure [dbo].[spa_settlement_dispute]    Script Date: 07/29/2009 18:33:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC spa_settlement_dispute 'a',29
CREATE PROCEDURE [dbo].[spa_settlement_dispute]
	@flag CHAR(1),
	@dispute_id INT = NULL,
	@billing_period DATETIME = NULL,
	@dispute_date_time DATETIME = NULL,
	@dispute_user VARCHAR(30) = NULL,
	@dispute_comment VARCHAR(100) = NULL,
	@contract_id INT=NULL,
	@counterparty_id INT=NULL,
	@prod_date  DATETIME = NULL,
	@as_of_date DATETIME = NULL,
	@hour_from VARCHAR(10) =NULL,
	@hour_to VARCHAR(10) =NULL,
	@charge_type VARCHAR(50) =NULL,
	@contact_name VARCHAR(100) =NULL

AS 

IF @flag = 's'
BEGIN
SELECT dispute_id AS [Dispute ID],
       contract_group.contract_name [Contract],
       source_counterparty.counterparty_name [Counterparty],
       dbo.FNADateFormat(prod_date)[Production Date],
       dbo.FNADateFormat(billing_period) [Billing Period],
       dbo.FNADateFormat(as_of_date) [As Of Date],
       dispute_date_time [Dispute Date Time],
       dispute_user [Dispute User],
       dispute_comment [Notes],
       hour_from [Hour From],
       hour_to [Hour To],
       charge_type [Charge Type],
       settlement_dispute.create_user [User name],
       settlement_dispute.create_ts [Time Stamp],
       settlement_dispute.contact_name [Contact Name]
FROM   settlement_dispute
       LEFT JOIN source_counterparty
            ON  source_counterparty.source_counterparty_id = settlement_dispute.counterparty_id
       LEFT JOIN contract_group
            ON  contract_group.contract_id = settlement_dispute.contract_id
WHERE  settlement_dispute.contract_id = @contract_id
       AND settlement_dispute.counterparty_id = @counterparty_id
       AND settlement_dispute.prod_date = @prod_date
       AND settlement_dispute.as_of_date = @as_of_date

END
ELSE IF @flag='a'
BEGIN
	SELECT 
			contract_id [Contract ID],
			counterparty_id [Counterparty ID],
			cast(prod_date AS VARCHAR(30)) [Production Date], 
			cast(as_of_date AS VARCHAR(30)) [As Of Date],				
			cast(billing_period AS VARCHAR(30)) [Billing Period] ,
			cast(dispute_date_time AS VARCHAR(30)) [Dispute Date Time],
			dispute_user [Dispute User],
			dispute_comment [Dispute Comment],hour_from,hour_to,charge_type,contact_name 
			FROM settlement_dispute WHERE dispute_id=@dispute_id
END

ELSE IF @flag = 'i'
BEGIN
	INSERT INTO settlement_dispute
	  (
	    billing_period,
	    dispute_date_time,
	    dispute_user,
	    dispute_comment,
	    contract_id,
	    counterparty_id,
	    prod_date,
	    as_of_date,
	    hour_from,
	    hour_to,
	    charge_type,
	    contact_name
	  )
	VALUES
	  (
	    @billing_period,
	    @dispute_date_time,
	    @dispute_user,
	    @dispute_comment,
	    @contract_id,
	    @counterparty_id,
	    @prod_date,
	    @as_of_date,
	    @hour_from,
	    @hour_to,
	    @charge_type,
	    @contact_name
	  )
	
	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'settlement_dispute',
	         'spa_settlement_dispute',
	         'DB Error',
	         'Failed to insert Settlement dispute.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'settlement_dispute',
	         'spa_settlement_dispute',
	         'Success',
	         'Settlement dispute inserted successfully.',
	         ''
END

ELSE IF @flag = 'u'
BEGIN
	UPDATE settlement_dispute
	SET    billing_period = @billing_period,
	       dispute_date_time = @dispute_date_time,
	       dispute_user = @dispute_user,
	       dispute_comment = @dispute_comment,
	       contract_id = @contract_id,
	       counterparty_id = @counterparty_id,
	       prod_date = @prod_date,
	       as_of_date = @as_of_date,
	       hour_from = @hour_from,
	       hour_to = @hour_to,
	       charge_type = @charge_type,
	       contact_name = @contact_name
	WHERE  dispute_id = @dispute_id
		
	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'settlement_dispute',
	         'spa_settlement_dispute',
	         'DB Error',
	         'Failed to update Settlement dispute.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'settlement_dispute',
	         'spa_settlement_dispute',
	         'Success',
	         'Settlement dispute updated successfully.',
	         ''
END

ELSE IF @flag = 'd'
BEGIN
	DELETE FROM settlement_dispute WHERE dispute_id=@dispute_id
	
	IF @@Error <> 0
	    EXEC spa_ErrorHandler @@Error,
	         'settlement_dispute',
	         'spa_settlement_dispute',
	         'DB Error',
	         'Failed to delete Settlement dispute.',
	         ''
	ELSE
	    EXEC spa_ErrorHandler 0,
	         'settlement_dispute',
	         'spa_settlement_dispute',
	         'Success',
	         'Settlement dispute deleted successfully.',
	         ''
END