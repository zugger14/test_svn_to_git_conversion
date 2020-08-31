
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_meter_idaaa]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch2]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance_arch2] DROP CONSTRAINT [FK_Calc_Invoice_Volume_meter_idaaa]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_rec_generatoraa]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch2]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance_arch2] DROP CONSTRAINT [FK_Calc_Invoice_Volume_rec_generatoraa]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_variance_arch2_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch2]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance_arch2] DROP CONSTRAINT [FK_Calc_Invoice_Volume_variance_arch2_source_deal_detail]
GO

GO
/****** Object:  Table [dbo].[Calc_Invoice_Volume_variance_arch2]    Script Date: 02/23/2011 14:20:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch2]') AND type in (N'U'))
DROP TABLE [dbo].[Calc_Invoice_Volume_variance_arch2]

GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_meter_idaaa]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch1]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance_arch1] DROP CONSTRAINT [FK_Calc_Invoice_Volume_meter_idaaa]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_rec_generatoraa]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch1]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance_arch1] DROP CONSTRAINT [FK_Calc_Invoice_Volume_rec_generatoraa]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Calc_Invoice_Volume_variance_arch1_source_deal_detail]') AND parent_object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch1]'))
ALTER TABLE [dbo].[Calc_Invoice_Volume_variance_arch1] DROP CONSTRAINT [FK_Calc_Invoice_Volume_variance_arch1_source_deal_detail]
GO

GO
/****** Object:  Table [dbo].[Calc_Invoice_Volume_variance_arch1]    Script Date: 02/23/2011 14:20:31 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Calc_Invoice_Volume_variance_arch1]') AND type in (N'U'))
DROP TABLE [dbo].[Calc_Invoice_Volume_variance_arch1]
