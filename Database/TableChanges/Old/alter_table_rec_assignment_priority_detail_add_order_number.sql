IF COL_LENGTH('rec_assignment_priority_detail', 'order_number') IS NULL
BEGIN
    ALTER TABLE rec_assignment_priority_detail ADD order_number INT
END
GO