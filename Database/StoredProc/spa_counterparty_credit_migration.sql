
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_counterparty_credit_migration]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_counterparty_credit_migration]
GO


CREATE PROCEDURE [dbo].[spa_counterparty_credit_migration]
@flag char(1),
@counterparty_credit_migration_id VARCHAR(250) = NULL,
@counterparty_credit_info_id int = NULL,
@effective_date DATE = NULL,
@counterparty int = NULL,
@internal_counterparty int = NULL,
@contract int = NULL,
@rating int = NULL,
@credit_limit int = NULL,
@credit_limit_to_us int = NULL,
@Counterparty_id INT = NULL
AS 
SET NOCOUNT ON
DECLARE @sql VARCHAR(5000)

IF @flag = 'd'
BEGIN
		DELETE FROM master_view_counterparty_credit_migration WHERE counterparty_credit_migration_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@counterparty_credit_migration_id))
		DELETE FROM counterparty_credit_migration WHERE counterparty_credit_migration_id IN (SELECT item FROM dbo.SplitCommaSeperatedValues(@counterparty_credit_migration_id))
		IF @@ERROR <> 0
		BEGIN
			EXEC spa_ErrorHandler @@ERROR, 'Counterparty Credit Migration', 
					'spa_counterparty_credit_migration', 'DB Error', 
					'Delete  failed.', ''
			RETURN
		END

			ELSE EXEC spa_ErrorHandler 0, 'Counterparty Credit Migration', 
					'spa_counterparty_credit_migration', 'Success', 
					'Changes have been saved successfully.',''


END

ELSE IF @flag='g' --Counterparty Credit Info Enhancement DHTMLX Grid
BEGIN
	SELECT 
		ccm.counterparty_credit_migration_id [Migration ID],
		dbo.FNADateFormat(ccm.effective_date) [Effective Date],
		scn2.counterparty_name [Counterparty],
		scn3.counterparty_name [Internal Counterparty],
		cg.[contract_name] [Contract],
		sdv.code [Rating],
		ccm.credit_limit [Credit Limit],
		ccm.credit_limit_to_us [Credit Limit to US],
		sc.currency_name [Currency]
	FROM
		counterparty_credit_migration ccm
	INNER JOIN counterparty_credit_info cci ON cci.counterparty_credit_info_id = ccm.counterparty_credit_info_id
	LEFT JOIN source_counterparty scn ON scn.source_counterparty_id = cci.Counterparty_id
	LEFT JOIN source_counterparty scn2 ON scn2.source_counterparty_id = ccm.counterparty
	LEFT JOIN source_counterparty scn3 ON scn3.source_counterparty_id = ccm.internal_counterparty
	LEFT JOIN contract_group AS cg ON cg.contract_id = ccm.[contract]
	INNER JOIN  source_currency sc ON sc.source_currency_id = ccm.currency
	INNER JOIN static_data_value AS sdv ON sdv.value_id = ccm.rating
	WHERE scn.source_counterparty_id=@Counterparty_id --counterparty_credit_info_id
END