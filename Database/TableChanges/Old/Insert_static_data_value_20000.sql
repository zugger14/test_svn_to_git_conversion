IF EXISTS (SELECT 1 FROM static_data_value WHERE [type_id] = 20000)
DELETE FROM static_data_value WHERE TYPE_ID=20000

SET IDENTITY_INSERT static_data_value ON
INSERT INTO static_data_value(value_id,TYPE_ID,code,description)
SELECT 20000,20000,'Month +0: Working day',''
UNION
SELECT 20001,20000,'Month +0: Calendar day',''
UNION
SELECT 20002,20000,'Month +1: Working day',''
UNION
SELECT 20003,20000,'Month +1: Calendar day',''
UNION
SELECT 20004,20000,'Month +2: Working day',''
UNION
SELECT 20005,20000,'Month +2: Calendar day',''
UNION
SELECT 20006,20000,'Month +3: Working day',''
UNION
SELECT 20007,20000,'Month +3: Calendar day',''
UNION
SELECT 20008,20000,'Month +4: Working day',''
UNION
SELECT 20009,20000,'Month +4: Calendar day',''
UNION
SELECT 20010,20000,'Month +5: Working day',''
UNION
SELECT 20011,20000,'Month +5: Calendar day',''
SET IDENTITY_INSERT static_data_value OFF



