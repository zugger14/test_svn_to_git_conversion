/****** Object:  View [dbo].[vwNewID]    Script Date: 03/19/2009 14:41:27 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwNewID]'))
DROP VIEW [dbo].[vwNewID]
GO
/****** Object:  View [dbo].[vwNewID]    Script Date: 03/19/2009 14:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwNewID]
AS
SELECT NEWID() AS new_id
