DELETE FROM adiha_default_codes_values_possible WHERE default_code_id = 36

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '1' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 1, '(GMT -12:00) Eniwetok, Kwajalein')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '2' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 2, '(GMT -11:00) Midway Island, Samoa')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '3' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 3, '(GMT -10:00) Hawaii')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '4' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 4, '(GMT -9:00) Alaska')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '5' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 5, '(GMT -8:00) Pacific Time (US & Canada)')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '6' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 6 ,'(GMT -7:00) Mountain Time (US & Canada)')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '7' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 7, '(GMT -6:00) Central Time (US & Canada), Mexico City')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '8' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 8, '(GMT -5:00) Eastern Time (US & Canada), Bogota, Lima')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '9' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 9, '(GMT -4:00) Atlantic Time (Canada), Caracas, La Paz')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '10' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 10, '(GMT -3:00) Brazil, Buenos Aires, Georgetown')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '11' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 11, '(GMT -3:30) Newfoundland')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '12' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 12, '(GMT -2:00) Mid-Atlantic')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '13' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 13, '(GMT -1:00 hour) Azores, Cape Verde Islands')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '14' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 14, '(GMT) Western Europe Time, London, Lisbon, Casablanca')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '15' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 15, '(GMT +1:00 hour) Brussels, Copenhagen, Madrid, Paris')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '16' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 16, '(GMT +2:00) Kaliningrad, South Africa')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '17' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 17, '(GMT +3:00) Baghdad, Riyadh, Moscow, St. Petersburg')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '18' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 18, '(GMT +3:30) Tehran')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '19' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 19, '(GMT +4:00) Abu Dhabi, Muscat, Baku, Tbilisi')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '20' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 20, '(GMT +4:30) Kabul')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '21' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 21, '(GMT +5:00) Ekaterinburg, Islamabad, Karachi, Tashkent')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '22' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 22, '(GMT +5:30) Bombay, Calcutta, Madras, New Delhi')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '23' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 23, '(GMT +5:45) Kathmandu')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '24' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 24, '(GMT +6:00) Almaty, Dhaka, Colombo')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '25' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 25, '(GMT +7:00) Bangkok, Hanoi, Jakarta')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '26' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 26, '(GMT +8:00) Beijing, Perth, Singapore, Hong Kong')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '27' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 27, '(GMT +9:00) Tokyo, Seoul, Osaka, Sapporo, Yakutsk')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '28' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 28, '(GMT +9:30) Adelaide, Darwin')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '29' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 29, '(GMT +10:00) Eastern Australia, Guam, Vladivostok')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '30' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 30, '(GMT +11:00) Magadan, Solomon Islands, New Caledonia')

IF NOT EXISTS(SELECT 'x' FROM adiha_default_codes_values_possible WHERE var_value = '31' AND default_code_id = 36)
INSERT INTO adiha_default_codes_values_possible (default_code_id, var_value, [description]) VALUES (36, 31, '(GMT +12:00) Auckland, Wellington, Fiji, Kamchatka')