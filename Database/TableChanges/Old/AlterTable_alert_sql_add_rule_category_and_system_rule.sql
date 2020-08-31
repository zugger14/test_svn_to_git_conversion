IF COL_LENGTH('alert_sql', 'rule_category') IS NULL
BEGIN
    ALTER TABLE alert_sql ADD rule_category INT
END
GO

EXEC('UPDATE alert_sql SET rule_category = 26000 WHERE rule_category IS NULL')

IF COL_LENGTH('alert_sql', 'system_rule') IS NULL
BEGIN
    ALTER TABLE alert_sql ADD system_rule CHAR(1)
END
GO

EXEC('UPDATE alert_sql SET system_rule = ''n'' WHERE system_rule IS NULL')