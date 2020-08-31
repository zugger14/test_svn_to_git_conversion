/****** Object:  StoredProcedure [dbo].[spa_privilege_report]    Script Date: 09/03/2009 10:48:06 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[spa_privilege_report_paging]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[spa_privilege_report_paging]
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec spa_privilege_report 'f'
CREATE proc [dbo].spa_privilege_report_paging
					@flag char(1),
					@user_login_id varchar(50)=NULL,
					@role_id int=NULL,
					@process_id VARCHAR(200) = NULL,
					@page_size VARCHAR(50) = NULL,
					@page_no INT = NULL 
AS
SET NOCOUNT ON 

exec [dbo].[spa_privilege_report] 
		@flag ,
		@user_login_id ,
		@role_id ,
		@process_id,
		NULL,
		1   --'1'=enable, '0'=disable
		,@page_size 
		,@page_no 