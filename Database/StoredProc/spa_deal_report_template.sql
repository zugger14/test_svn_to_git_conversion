/****** Object:  StoredProcedure [dbo].[spa_deal_report_template]    Script Date: 07/23/2009 01:04:54 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_deal_report_template]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_deal_report_template]

/****** Object:  StoredProcedure [dbo].[spa_deal_report_template]    Script Date: 07/23/2009 01:05:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [dbo].[spa_deal_report_template]
@flag  CHAR(1),
@template_id INT=null,
@template_name VARCHAR(50)=null,
@template_description VARCHAR(100)=null,
@filename VARCHAR(100)=null

AS
SET NOCOUNT ON 

IF @flag='s'
BEGIN 
	SELECT template_id,template_name  FROM deal_report_template 
END






