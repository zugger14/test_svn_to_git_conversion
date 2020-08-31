

IF COL_LENGTH('lock_as_of_date_id', 'lock_as_of_date_id') IS NOT NULL
BEGIN
    ALTER TABLE lock_as_of_date
    ADD CONSTRAINT PK_lock_as_of_date_id PRIMARY KEY(lock_as_of_date_id)
END