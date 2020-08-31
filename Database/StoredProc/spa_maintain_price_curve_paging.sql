IF  EXISTS (SELECT * FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[spa_maintain_price_curve_paging]') AND TYPE IN (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_maintain_price_curve_paging]


SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [dbo].[spa_maintain_price_curve_paging]
				@curve_id				VARCHAR (8000)		,
				@curve_type				INT					,				
				@curve_source			INT					,
				@from_date				VARCHAR(20)			,
				@to_date				VARCHAR(20) = NULL	,
				@tenor_from				VARCHAR(20) = NULL	,
				@tenor_to				VARCHAR(20) = NULL	,
				@ind_con_month			VARCHAR(1)  = NULL	,
				@flag					CHAR(1)	    = NULL	,
				/* 'i' - Insert. 's' - View.
				   'r' - Graph olot in insert Mode. 
				   'v' - Graph plot in View Mode. 
				   't' - Outputs all the curve names from the hierarchy. 
				   'e' - To get the settlement date.*/
				@bidAndask_flag			CHAR(1)		= NULL	,
				@differential_flag		CHAR(1)		= NULL	,
				@CopyCurveID			INT			= NULL  ,
				@average				CHAR(1)		= NULL	,
				@settlementPrices		CHAR(1)		= NULL,
				@get_derive_value		CHAR(1)		='y'	,----'y'-> get derive curve, 'n'-> do not get derive curve
				@process_id				VARCHAR(50)  = NULL	,
				@batch_report_param		VARCHAR(5000)= NULL	,
				@adhihaTableName		VARCHAR(500) = NULL ,
				
				@apply_paging			CHAR(1) = 'y',
				@process_id_paging		VARCHAR(500)=NULL, 
				@page_size				INT =NULL,
				@page_no				INT = NULL
AS

EXEC spa_maintain_price_curve 
			@curve_id,
			@curve_type,
			@curve_source,
			@from_date,
			@to_date,
			@tenor_from,
			@tenor_to,
			@ind_con_month,
			@flag,
			@bidAndask_flag,
			@differential_flag,
			@CopyCurveID,
			@average,
			@settlementPrices,
			@get_derive_value,
			@process_id,
			@batch_report_param,
			@adhihaTableName,
			'y',
			@process_id_paging,
			@page_size,
			@page_no