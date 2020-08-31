UPDATE static_data_value
    SET [code] = 'Send To',
        [category_id] = 21409,
        [description] = 'With Send To'
    WHERE [value_id] = 112203
PRINT 'Updated Static value 112203 - Send To.'

UPDATE static_data_value
    SET [code] = 'CC',
        [category_id] = 21409,
        [description] = 'With CC'
    WHERE [value_id] = 112204
PRINT 'Updated Static value 112204 - CC.'

UPDATE static_data_value
    SET [code] = 'BCC',
        [category_id] = 21409,
        [description] = 'With BCC'
    WHERE [value_id] = 112205
PRINT 'Updated Static value 112205 - BCC.'

UPDATE static_data_value
    SET [code] = 'File Size',
        [category_id] = 21409,
        [description] = 'With attachment file size'
    WHERE [value_id] = 112206
PRINT 'Updated Static value 112206 - File Size.'

UPDATE static_data_value
    SET [code] = 'File size less than',
        [category_id] = 21409,
        [description] = 'With attachment file size less than'
    WHERE [value_id] = 112207
PRINT 'Updated Static value 112207 - File size less than.'

UPDATE static_data_value
    SET [code] = 'File size more than',
        [category_id] = 21409,
        [description] = 'With attachment file size more than'
    WHERE [value_id] = 112208
PRINT 'Updated Static value 112208 - File size more than.'

UPDATE static_data_value
    SET [code] = 'File Extension',
        [category_id] = 21409,
        [description] = 'With attachment file extension'
    WHERE [value_id] = 112209
PRINT 'Updated Static value 112209 - File Extension.'

UPDATE static_data_value
    SET [code] = 'Filename contains',
        [category_id] = 21409,
        [description] = 'With attachment filename contains'
    WHERE [value_id] = 112210
PRINT 'Updated Static value 112210 - Filename contains.'

UPDATE static_data_value
    SET [code] = 'File Name Starts With (in FTP/SFTP)',
        [category_id] = -1,
        [description] = 'Having Prefix'
    WHERE [value_id] = 112211
PRINT 'Updated Static value 112211 - File Name Starts With.'

UPDATE static_data_value
    SET [code] = 'File Extension (in FTP/SFTP)',
        [category_id] = -1,
        [description] = 'Having File Extension'
    WHERE [value_id] = 112212
PRINT 'Updated Static value 112212 - File Extension (FTP\SFTP).'

UPDATE static_data_value
    SET [code] = 'File Name Starts With (in Folder)',
        [category_id] = 21400,
        [description] = 'Having Prefix (Folder)'
    WHERE [value_id] = 112213
PRINT 'Updated Static value 112213 - File Name Starts With (Folder).'

UPDATE static_data_value
    SET [code] = 'File Extension (in Folder)',
        [category_id] = 21400,
        [description] = 'Having File Extension (Folder)'
    WHERE [value_id] = 112214
PRINT 'Updated Static value 112214 - File Extension (Folder).'

