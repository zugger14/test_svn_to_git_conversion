 
 SET ANSI_NULLS ON
 GO
 
 SET QUOTED_IDENTIFIER ON
 GO
  
 IF OBJECT_ID(N'adiha_process.[dbo].[source_price_curve__]', N'U') IS  NULL
 BEGIN
 CREATE TABLE adiha_process.dbo.source_price_curve__
 	(
 		[source_curve_def_id]				VARCHAR (100),
  		[source_system_id]					VARCHAR (100),
  		[as_of_date]						VARCHAR (100),
  		[Assessment_curve_type_value_id]	VARCHAR (100),
  		[curve_source_value_id]				VARCHAR (100),
  		[maturity_date]						VARCHAR (100),
  		[maturity_hour]						VARCHAR (100),
  		[bid_value]							VARCHAR (100),
  		[ask_value]							VARCHAR (100),
  		[curve_value]						VARCHAR (100),
  		[is_dst]							VARCHAR (50)	,
  		[table_code]						VARCHAR (100)
 	)
 END
 ELSE 
 	BEGIN
 		PRINT 'Table source_price_curve__ exists.'
 	END
 
 GO
 
 
 IF OBJECT_ID(N'adiha_process.[dbo].[curve_correlation__]', N'U') IS  NULL
 BEGIN
 CREATE TABLE adiha_process.dbo.curve_correlation__
 	(
 		[as_of_date]			VARCHAR (250),
 		[curve_id_from] 		VARCHAR (250),
 		[curve_id_to]			VARCHAR (250),
 		[term1]					VARCHAR (250),
 		[term2]					VARCHAR (250),
 		[curve_source_value_id]	VARCHAR (250),
 		[value]					VARCHAR (250),
 		[table_code]			VARCHAR (100)
 	)
 END
 ELSE 
 	BEGIN
 		PRINT 'Table curve_correlation__ exists.'
 	END
 
 GO
 
 
IF OBJECT_ID(N'adiha_process.[dbo].[curve_volatility__]', N'U') IS  NULL
 BEGIN
 CREATE TABLE adiha_process.dbo.curve_volatility__
 	(
 		[as_of_date]				VARCHAR (250),
 		[curve_id]					VARCHAR (250),
 		[curve_source_value_id]		VARCHAR (250),
 		[term]						VARCHAR (250),
 		[value]						VARCHAR (250),
 		[granularity]				VARCHAR (100),
 		[table_code]				VARCHAR (100)
 	)
 END
 ELSE 
 	BEGIN
 		PRINT 'Table curve_volatility__ exists.'
 	END
 
 GO
 