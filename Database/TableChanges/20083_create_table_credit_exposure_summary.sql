SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
IF OBJECT_ID(N'[dbo].[credit_exposure_summary]', N'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[credit_exposure_summary](
		[id] [int] IDENTITY(1, 1),
		[as_of_date] [datetime] NOT NULL,
		[curve_source_value_id] [int] NOT NULL,
		[Source_Counterparty_ID] [int] NULL,
		[internal_counterparty_id] [int] NULL,
		[contract_id] [int] NULL,
		[ar_prior] [float] NULL,
		[ar_current] [float] NULL,
		[ap_prior] [float] NULL,
		[ap_current] [float] NULL,
		[bom_exposure_to_us] [float] NULL,
		[bom_exposure_to_them] [float] NULL,
		[mtm_exposure_to_us] [float] NULL,
		[mtm_exposure_to_them] [float] NULL,
		[exposure_to_us] [float] NULL,
		[exposure_to_them] [float] NULL,
		[total_exposure_to_us_round] [float] NULL,
		[total_exposure_to_them_round] [float] NULL,
		[effective_exposure_to_us] [float] NULL,
		[effective_exposure_to_them] [float] NULL,
		[d_effective_exposure_to_us] [float] NULL,
		[d_effective_exposure_to_them] [float] NULL,
		[effective_exposure_to_us_round] [float] NULL,
		[effective_exposure_to_them_round] [float] NULL,
		[collateral_received] [float] NULL,
		[collateral_provided] [float] NULL,
		[cash_collateral_received] [float] NULL,
		[cash_collateral_provided] [float] NULL,
		[colletral_not_used_received] [float] NULL,
		[colletral_not_used_provided] [float] NULL,
		[prepay_received] [float] NULL,
		[prepay_provided] [float] NULL,
		[limit_provided] [float] NULL,
		[limit_received] [float] NULL,
		[limit_available_to_us] [float] NULL,
		[limit_available_to_them] [float] NULL,
		[limit_available_to_us_round] [float] NULL,
		[limit_available_to_them_round] [float] NULL,
		[rounding] [int] NULL,
		[threshold_provided] [float] NULL,
		[threshold_received] [float] NULL,
		[counterparty_credit_support_amount] [float] NULL,
		[internal_credit_support_amount] [float] NULL,
		[create_user] [varchar](50) NULL DEFAULT dbo.FNADBUser(),
    	[create_ts] [datetime] NULL DEFAULT GETDATE()
	) 
END
ELSE
BEGIN
    PRINT 'Table credit_exposure_summary already EXISTS'
END
 
GO