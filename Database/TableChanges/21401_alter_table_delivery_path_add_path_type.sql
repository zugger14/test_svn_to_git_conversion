--modified on 2019-05-24 12:11:17.733, to include it on patch to take to TEST.
IF COL_LENGTH('delivery_path', 'path_type') IS NULL
BEGIN
    ALTER TABLE delivery_path ADD path_type VARCHAR(MAX)
END
GO