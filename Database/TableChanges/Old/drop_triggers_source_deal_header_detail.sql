
/****** Object:  Trigger [TRGDEL_SOURCE_DEAL_DETAIL]    Script Date: 05/09/2010 10:45:13 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGDEL_SOURCE_DEAL_DETAIL]'))
DROP TRIGGER [dbo].[TRGDEL_SOURCE_DEAL_DETAIL]



/****** Object:  Trigger [TRGUPD_SOURCE_DEAL_DETAIL]    Script Date: 05/09/2010 10:45:56 ******/


/****** Object:  Trigger [TRGDel_FAS_Source_deal_header]    Script Date: 05/09/2010 10:46:09 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGDel_FAS_Source_deal_header]'))
DROP TRIGGER [dbo].[TRGDel_FAS_Source_deal_header]


/****** Object:  Trigger [TRGINS_FAS_Source_deal_header]    Script Date: 05/09/2010 10:46:20 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGINS_FAS_Source_deal_header]'))
DROP TRIGGER [dbo].[TRGINS_FAS_Source_deal_header]


/****** Object:  Trigger [TRGUPD_FAS_Source_deal_header]    Script Date: 05/09/2010 10:46:30 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[TRGUPD_FAS_Source_deal_header]'))
DROP TRIGGER [dbo].[TRGUPD_FAS_Source_deal_header]


/****** Object:  Trigger [ins_trg_source_deal_detail_audit]    Script Date: 05/09/2010 11:54:38 ******/
IF  EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[ins_trg_source_deal_detail_audit]'))
DROP TRIGGER [dbo].[ins_trg_source_deal_detail_audit]