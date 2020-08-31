IF OBJECT_ID('[dbo].[spa_get_menu_list]', 'p') IS NOT NULL 
	DROP PROCEDURE [dbo].[spa_get_menu_list]
GO 

CREATE PROC [dbo].[spa_get_menu_list]
	@role_id INT = NULL,
	@user_name VARCHAR(50) = NULL,
	@function_id INT = NULL
AS

SET NOCOUNT ON

IF @role_id IS NOT NULL
BEGIN
    SELECT *
    FROM   (
               SELECT menu_group_id,
                      NULL               function_id,
                      group_name [Group Name],
                      0                  seq_order,
                      sequence_order     group_order,
                      NULL               function_call,
                      tool_tips,
                      NULL               function_parameter,
                      r.process_map_file_name,
                      NULL            AS process_file_name,
                      NULL            AS file_path
               FROM   menu_group g
               INNER JOIN application_security_role r ON  r.role_id = g.role_id
               WHERE  g.role_id = @role_id
               
               UNION ALL
               SELECT menu_item_id,
                      mi.function_id,
                      menu_label,
                      mi.sequence_order,
                      mg.sequence_order,
                      i.window_name,
                      mi.tool_tips,
                      f.function_parameter,
                      r.process_map_file_name,
                      pmt.[file_name],
                      f.file_path AS file_path
               FROM menu_item mi
               INNER JOIN menu_group mg ON  mg.menu_group_id = mi.menu_group_id
               INNER JOIN application_functions f ON  f.function_id = mi.function_id
               INNER JOIN application_security_role r ON  r.role_id = mg.role_id
			   LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = f.function_id
               LEFT JOIN process_map_table pmt ON  pmt.id = mi.process_map_id
               WHERE  mg.role_id = @role_id
           ) a
    ORDER BY a.group_order, a.seq_order
END
ELSE IF @user_name IS NOT NULL
BEGIN
	SELECT *
	FROM   (
	           SELECT menu_group_id,
	                  NULL               function_id,
	                  group_name [Group Name],
	                  0                  seq_order,
	                  sequence_order     group_order,
	                  NULL               function_call,
	                  tool_tips,
	                  NULL               function_parameter,
	                  r.process_map_file_name,
	                  NULL            AS process_file_name,
                      NULL            AS file_path
	           FROM   menu_group g
	           LEFT OUTER JOIN application_security_role r ON  r.role_id = g.role_id
	           WHERE  [user_id] = @user_name
	           
	           UNION ALL
	           
	           SELECT menu_item_id,
	                  mi.function_id,
	                  menu_label,
	                  mi.sequence_order,
	                  mg.sequence_order,
	                  i.window_name,
	                  mi.tool_tips,
	                  f.function_parameter,
	                  r.process_map_file_name,
	                  pmt.[file_name],
                      f.file_path AS file_path
	           FROM   menu_item mi
	           INNER JOIN menu_group mg ON  mg.menu_group_id = mi.menu_group_id
	           INNER JOIN application_functions f ON  f.function_id = mi.function_id
			   LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = f.function_id
	           LEFT OUTER JOIN application_security_role r ON  r.role_id = mg.role_id
	           LEFT JOIN process_map_table pmt ON  pmt.id = mi.process_map_id
	           WHERE  mg.[user_id] = @user_name
	       ) a
	ORDER BY a.group_order, a.seq_order
END
ELSE IF @function_id IS NOT NULL
BEGIN
	SELECT af.function_id,
        af.function_name,
        i.window_name function_call,
        af.function_parameter
    FROM   application_functions af
	LEFT JOIN [dbo].[FNAGetAppWindowName]() i ON i.function_id = af.function_id
    WHERE  af.function_id = @function_id
END



