IF COL_LENGTH('dashboard_template_detail', 'template_data_type_name') IS NULL
BEGIN
    ALTER TABLE dashboard_template_detail ADD template_data_type_name NVARCHAR(200)
END
GO