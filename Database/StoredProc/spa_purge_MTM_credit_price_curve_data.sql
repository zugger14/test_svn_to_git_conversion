SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON 
GO

/**
	Delete MTM, price curve and credit exposure data

	Parameters 
	@flag : Flag Description
	@as_of_date : As_of_date
*/

CREATE OR ALTER PROCEDURE [dbo].[spa_purge_MTM_credit_price_curve_data]
	@as_of_date DATE = NULL 
AS

SET NOCOUNT ON;
/*
--Added for Debugging Purpose
DECLARE @contextinfo VARBINARY(128) = CONVERT(VARBINARY(128), 'DEBUG_MODE_ON')
SET CONTEXT_INFO @contextinfo
EXEC spa_print 'Use spa_print instead of PRINT statement in debug mode.'

DECLARE
	@as_of_date DATETIME = NULL

--*/
SET @as_of_date = ISNULL(@as_of_date, GETDATE())

DECLARE	@retention_days INT 

/*get value of MTM, Credit Exposure, Price Curve retention period*/
SELECT @retention_days= var_value * -1 
FROM  adiha_default_codes_values
WHERE(instance_no = 1) AND (default_code_id = 215) AND (seq_no = 1)
 
SET @retention_days = ISNULl(@retention_days,-7)

DECLARE @retention_date DATE = DATEADD(DD, @retention_days, @as_of_date)

DROP TABLE IF EXISTS #eom_dates

/*get EOM dates*/
SELECT term_end 
INTO #eom_dates
FROM [FNATermBreakdown] ('m',CONVERT(VARCHAR(10),YEAR(@as_of_date)-1 ) +'-01-01',@as_of_date) 

BEGIN TRY
	BEGIN TRAN
	
	/*delete MTM data of as_of_date less than a week , excluding EOM of current and last year*/
		DELETE sdp
		FROM source_deal_pnl sdp 
		LEFT JOIN  #eom_dates eom on sdp.pnl_as_of_date = eom.term_end	
		WHERE sdp.pnl_as_of_date < @retention_date
			AND eom.term_end IS NULL
			
		DELETE sdpd
		FROM source_deal_pnl_detail sdpd
		LEFT JOIN  #eom_dates eom on sdpd.pnl_as_of_date = eom.term_end	
		WHERE sdpd.pnl_as_of_date < @retention_date
			AND eom.term_end IS NULL			
			
		DELETE ifb
		FROM index_fees_breakdown ifb
		LEFT JOIN  #eom_dates eom ON ifb.as_of_date = eom.term_end	
		WHERE ifb.as_of_date < @retention_date 
			AND eom.term_end IS NULL			
			
		DELETE pcpd
		FROM pnl_component_price_detail pcpd
		LEFT JOIN  #eom_dates eom on pcpd.run_as_of_date = eom.term_end	
		WHERE pcpd.run_as_of_date < @retention_date  AND calc_type='m'
			AND eom.term_end IS NULL
			
		DELETE sdpb
		FROM source_deal_pnl_breakdown sdpb 
		LEFT JOIN  #eom_dates eom on sdpb.as_of_date = eom.term_end	
		WHERE sdpb.as_of_date < @retention_date 
			AND eom.term_end IS NULL		
	
			
	/*delete credit exposure of as_of_date less than a week */ 
		DELETE  
		FROM credit_exposure_detail 
		WHERE as_of_date < @retention_date

		DELETE 
		FROM credit_exposure_summary 
		WHERE as_of_date < @retention_date

	/*delete price curve data of listed curve id and as_of_date less than a week */

		DELETE  spc
		FROM source_price_curve spc 
			INNER JOIN source_price_curve_def spcd ON spc.source_curve_def_id=spcd.source_curve_def_id 
		WHERE spc.as_of_date < @retention_date
		AND spcd.curve_id in ( 'CO2.CER.PFC.D.Fwd'
									, 'CO2.EUA.PFC.D.Fwd'
									, 'CO2.VER.PFC.D.Fwd'
									, 'COAL.API2.PFC.D.Fwd'
									, 'COAL.API2B.PFC.D.Fwd'
									, 'COAL.API2P.PFC.D.Fwd'
									, 'GAS.GPH.PFC.D.Fwd'
									, 'GAS.GPH.PFC.H.Fwd'
									, 'GAS.GPL.PFC.D.Fwd'
									, 'GAS.GPL.PFC.H.Fwd'
									, 'GAS.NCH.PFC.D.Fwd'
									, 'GAS.NCH.PFC.H.Fwd'
									, 'GAS.NCL.PFC.D.Fwd'
									, 'GAS.NCL.PFC.H.Fwd'
									, 'GAS.TTF.PFC.D.Fwd'
									, 'GAS.TTF.PFC.H.Fwd'
									, 'GOO.GOO ALPINE.PFC.D.Fwd'
									, 'GOO.GOO NORDIC.PFC.D.Fwd'
									, 'POWER.DE.PFC.H.Fwd'
									, 'FX.DE.PFC.D.USD'
								)

	/*insert in lock_as_of_date table
	@retention_date - 1 to get previous date of @retention_date 
	*/
	DECLARE @lock_as_of_date DATETIME = DATEADD(day,-1,@retention_date)
	/*delete date if already exists*/

		DELETE FROM lock_as_of_date where close_date = @lock_as_of_date 

	/*insert*/
		INSERT INTO lock_as_of_date(close_date)
		SELECT @lock_as_of_date
	

COMMIT TRAN

END TRY
BEGIN CATCH

	ROLLBACK TRAN

END CATCH

GO	




