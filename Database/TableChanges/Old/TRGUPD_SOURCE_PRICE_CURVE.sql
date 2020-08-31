/****** Object:  Trigger [TRGUPD_SOURCE_PRICE_CURVE]    Script Date: 06/23/2011 18:55:13 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_SOURCE_PRICE_CURVE]'))
DROP TRIGGER [dbo].[TRGUPD_SOURCE_PRICE_CURVE]
GO

/****** Object:  Trigger [dbo].[TRGUPD_SOURCE_PRICE_CURVE]    Script Date: 06/23/2011 18:51:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[TRGUPD_SOURCE_PRICE_CURVE]
ON [dbo].[source_price_curve]
FOR UPDATE
AS


--IF  NOT UPDATE(create_user)
UPDATE spc
SET spc.update_user =  dbo.FNADBUser(), spc.update_ts = getdate() 
FROM 
	SOURCE_PRICE_CURVE spc
	INNER JOIN  deleted spc_d
	ON spc.source_curve_def_id=spc_d.source_curve_def_id
		AND spc.as_of_date=spc_d.as_of_date
		AND spc.Assessment_curve_type_value_id=spc_d.Assessment_curve_type_value_id
		AND spc.curve_source_value_id=spc_d.curve_source_value_id
		AND spc.maturity_date=spc_d.maturity_date

