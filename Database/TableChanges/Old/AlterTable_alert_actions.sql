IF COL_LENGTH('alert_actions', 'condition_id') IS NULL
BEGIN
    ALTER TABLE alert_actions ADD condition_id INT
    CONSTRAINT [FK_alert_conditions_alert_actions] FOREIGN KEY ([condition_id]) REFERENCES [alert_conditions];
END
GO