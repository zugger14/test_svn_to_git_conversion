--Author: Tara Nath Subedi
--Dated: March 18, 2010
--Issue against: 1957
--Purpose: Define a new configuration: "Allow to edit locked links by default".
--adding in Maintain Config 
delete adiha_default_codes_values where default_code_id = 33
delete adiha_default_codes_values_possible where default_code_id = 33
delete adiha_default_codes_params where default_code_id = 33
delete adiha_default_codes where default_code_id = 33
insert into adiha_default_codes values(33, 'allow_to_edit_locked_links', 'Allow to edit locked links by default', 'Allow to edit locked links by default', 1)
insert into adiha_default_codes_params values(1, 33, 'allow_to_edit_locked_links', 3, NULL, 'h')
insert into adiha_default_codes_values_possible values(33, 0, 'Do not allow to edit locked links by default')
insert into adiha_default_codes_values_possible values(33, 1, 'Allow to edit locked links by default')
insert into adiha_default_codes_values values(1, 33, 1, 0, NULL)
GO

