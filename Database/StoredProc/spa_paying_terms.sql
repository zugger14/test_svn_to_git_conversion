IF OBJECT_ID(N'[dbo].[spa_paying_terms]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[spa_paying_terms]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/**
	General stored procedure for paying terms.

	Parameters
		@flag :'s' - Return payment details data
		@payment_terms_id    : payment terms id
		@del_ids	: ids of the payment terms to be deleted
	
**/

CREATE PROCEDURE [dbo].[spa_paying_terms]
	@flag CHAR(1) = NULL,	
	@payment_terms_id INT = NULL,
	@del_ids VARCHAR(MAX) = NULL
AS
/*
Declare
	@flag CHAR(1) = NULL,	
	@payment_terms_id INT = NULL
--*/
SET NOCOUNT ON

IF @flag = 's'
BEGIN
	SELECT 
		payment_details_id
		, payment_terms_id
		, sdv1.value_id fees
		, formula_id
		, formula_name
		, [percentage]
		, settlement_date
		, sdv2.value_id settlement_rule
		, settlement_days
		, payment_date
		, sdv3.value_id payment_rule
		, payment_days
		, deal_level
		, prepay	
	FROM payment_details pd
	 LEFT JOIN static_data_value sdv1 ON pd.fees = sdv1.value_id
	 LEFT JOIN static_data_value sdv2 ON pd.settlement_rule = sdv2.value_id
	 LEFT JOIN static_data_value sdv3 ON pd.payment_rule = sdv3.value_id
	WHERE payment_terms_id = @payment_terms_id
END

IF @flag = 'a'
BEGIN
	SELECT 
		 payment_terms_id
		, payment_name
	FROM setup_paying_terms
END

IF @flag = 'd'
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DELETE pd
			FROM payment_details pd
			INNER JOIN dbo.FNASplit(@del_ids, ',') di ON di.item = pd.payment_terms_id

			DELETE spt
			FROM setup_paying_terms spt
			INNER JOIN dbo.FNASplit(@del_ids, ',') di ON di.item = spt.payment_terms_id

		COMMIT TRAN
		
		EXEC spa_ErrorHandler 0,
			'Payment Terms',
			'spa_paying_terms',
			'Success',
			'Data deleted successfully.',
			@del_ids
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRAN

		DECLARE @err_msg VARCHAR(MAX) = ERROR_MESSAGE()

		EXEC spa_ErrorHandler @@ERROR,
			'Payment Terms',
			'spa_paying_terms',
			'DB Error',
			@err_msg,
			''
	END CATCH
END

GO

