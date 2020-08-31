IF NOT EXISTS (SELECT name FROM sysindexes WHERE name = 'IDX_transportation_rate_schedule')
CREATE UNIQUE INDEX IDX_transportation_rate_schedule ON transportation_rate_schedule (rate_type_id,effective_date)


