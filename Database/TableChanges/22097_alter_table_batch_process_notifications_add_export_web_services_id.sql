IF COL_LENGTH('batch_process_notifications', 'export_web_services_id') IS NULL
BEGIN
    ALTER TABLE batch_process_notifications ADD export_web_services_id INT NULL FOREIGN KEY(export_web_services_id) REFERENCES export_web_service(id);
END
GO