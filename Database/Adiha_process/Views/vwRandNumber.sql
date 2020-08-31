/****** Object:  View [dbo].[vwRandNumber]    Script Date: 08/28/2013 11:25:45 ******/


IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vwRandNumber]'))
DROP VIEW [dbo].[vwRandNumber]
GO

/****** Object:  View [dbo].[vwRandNumber]    Script Date: 08/28/2013 11:25:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwRandNumber]
AS
SELECT RAND() as RandNumber
GO


