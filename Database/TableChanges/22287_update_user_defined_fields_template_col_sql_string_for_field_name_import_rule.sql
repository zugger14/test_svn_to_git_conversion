/**
PURPOSE			:	script to update sql string of udf field 'Import Rule'. Issue due to order by clause which is not handled on spa_execute_query when select alias and order by has different column names.
CREATED DATE	:	2019-12-25
CREATED BY		:	sligal
*/
update user_defined_fields_template 
set sql_string = 'SELECT ixp_rule_hash [id], ixp_rules_name [value] FROM ixp_rules ORDER BY 2'
where field_label = 'import rule' and field_name=-10000208