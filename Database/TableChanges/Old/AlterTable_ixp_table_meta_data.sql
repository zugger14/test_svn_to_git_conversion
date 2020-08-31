IF COL_LENGTH('ixp_table_meta_data', 'ipx_tables_id') IS NOT NULL
BEGIN
   EXEC SP_RENAME 'ixp_table_meta_data.[ipx_tables_id]' , 'ixp_tables_id', 'COLUMN'
END
GO