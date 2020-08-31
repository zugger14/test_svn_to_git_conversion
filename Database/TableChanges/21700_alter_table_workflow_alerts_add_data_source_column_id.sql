IF COL_LENGTH('workflow_where_clause','data_source_column_id') IS NULL
	ALTER TABLE workflow_where_clause ADD data_source_column_id INT


IF COL_LENGTH('workflow_link_where_clause','data_source_column_id') IS NULL
	ALTER TABLE workflow_link_where_clause ADD data_source_column_id INT


IF COL_LENGTH('alert_table_where_clause','data_source_column_id') IS NULL
	ALTER TABLE alert_table_where_clause ADD data_source_column_id INT


IF COL_LENGTH('alert_actions','data_source_column_id') IS NULL
	ALTER TABLE alert_actions ADD data_source_column_id INT