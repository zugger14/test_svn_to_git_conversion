--Disable triggers on source_price_curve to gain performance on price curve import.

IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGDEL_source_price_curve]'))
	DISABLE TRIGGER [dbo].[TRGDEL_source_price_curve] ON dbo.source_price_curve;  
GO

IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGINS_SOURCE_PRICE_CURVE]'))
	DISABLE TRIGGER [dbo].[TRGINS_SOURCE_PRICE_CURVE] ON dbo.source_price_curve;  
GO

IF  EXISTS (SELECT 1 FROM sys.triggers WHERE OBJECT_ID = OBJECT_ID(N'[dbo].[TRGUPD_source_price_curve]'))
	DISABLE TRIGGER [dbo].[TRGUPD_source_price_curve] ON dbo.source_price_curve;  
GO