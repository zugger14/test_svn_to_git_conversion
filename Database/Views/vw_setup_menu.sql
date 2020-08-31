IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_setup_menu]'))
DROP VIEW [dbo].[vw_setup_menu]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_setup_menu]
( setup_menu_id
, function_id
, display_name
, hide_show
, function_name
)
AS
(
	SELECT sm.setup_menu_id
		 , sm.function_id
		 , sm.display_name
		 , CASE WHEN sm.hide_show = 1 THEN 0 ELSE 1 END AS hide_show -- This is done because whenever Hide show = 1 means it not hidden whereas Hide is checked in UI form field
		 , af.function_name
	FROM setup_menu sm
	LEFT JOIN application_functions af
	ON sm.function_id = af.function_id
	WHERE 1 = 1
)

