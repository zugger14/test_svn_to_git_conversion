<!--DOCTYPE transitional.dtd-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>   
    <base target="left"/>
    <link rel="stylesheet" href="../../../css/adiha_style.css"/>
    <?php
    include '../../../adiha.php.scripts/components/include.file.v3.php';
    echo '<title>' . get_PS_form_title('Gl Code Mapping') . '</title>';
    $php_script_loc = $app_php_script_loc;
    $img_loc = $php_script_loc . 'adiha_pm_html/process_controls/';
    $form_name = 'form_manage_doc';
    $account_type_id = isset($_GET['account_type_id']) ? $_GET['account_type_id'] : 'NULL';
    $flag = isset($_GET['flag']) ? $_GET['flag'] : '';
    $entity_id = isset($_GET['entity_id']) ? $_GET['entity_id'] : '';
    $callback_function = (isset($_GET['callback_function'])) ? $_GET['callback_function'] : '';

    $xml_file = $php_script_loc . 'spa_gl_code_mapping.php?flag=s&account_type_id=' . $account_type_id;
    $return_value = readXMLURL($xml_file);

    if ($entity_id == 'NULL' || $entity_id == '') {
        $gl_number_id_st_asset = '';
        $gl_number_id_st_asset_Value = '';
        $gl_number_id_lt_asset = '';
        $gl_number_id_lt_asset_Value = '';
        $gl_number_id_st_liab = '';
        $gl_number_id_st_liab_Value = '';
        $gl_number_id_lt_liab = '';
        $gl_number_id_lt_liab_Value = '';
        $gl_number_id_aoci = '';
        $gl_number_id_aoci_Value = '';
        $gl_number_id_cash = '';
        $gl_number_id_cash_Value = '';
        $gl_number_id_item_st_asset = '';
        $gl_number_id_item_st_asset_Value = '';
        $gl_number_id_item_lt_asset = '';
        $gl_number_id_item_lt_asset_Value = '';
        $gl_number_id_item_st_liab = '';
        $gl_number_id_item_st_liab_Value = '';
        $gl_number_id_item_lt_liab = '';
        $gl_number_id_item_lt_liab_Value = '';
        $gl_number_id_pnl = '';
        $gl_number_id_pnl_Value = '';
        $gl_number_id_set = '';
        $gl_number_id_set_Value = '';
        $gl_number_id_inventory = '';
        $gl_number_id_inventory_Value = '';
        $gl_id_amortization_Value = '';
        $gl_id_amortization = '';
        $gl_id_interest_Value = '';
        $gl_id_interest = '';
        $gl_number_id_expense_Value = '';
        $gl_number_id_expense = '';
        $gl_number_id_gross_set_Value = '';
        $gl_number_id_gross_set = '';

        $gl_id_st_tax_asset = '';
        $gl_id_st_tax_asset_Value = '';
        $gl_id_st_tax_liab_Value = '';
        $gl_id_st_tax_liab = '';
        $gl_id_lt_tax_asset_Value = '';
        $gl_id_lt_tax_asset = '';
        $gl_id_lt_tax_liab_Value = '';
        $gl_id_lt_tax_liab = '';
        $gl_id_tax_reserve_Value = '';
        $gl_id_tax_reserve = '';
        $gl_number_unhedged_der_st_asset = '';
        $gl_number_unhedged_der_st_asset_Value = '';
        $gl_number_unhedged_der_lt_asset = '';
        $gl_number_unhedged_der_lt_asset_Value = '';
        $gl_number_unhedged_der_st_liab = '';
        $gl_number_unhedged_der_st_liab_Value = '';
        $gl_number_unhedged_der_lt_liab = '';
        $gl_number_unhedged_der_lt_liab_Value = '';
    } else {
        if ($flag == 's') {
            $sp_url = $php_script_loc . 'spa_strategy.php?flag=s&fas_strategy_id=' . $entity_id;
            $xml = readXMLURL($sp_url);

            $gl_number_id_st_asset = $xml[0][37];
            $gl_number_id_st_asset_Value = ($xml[0][19] == '' ? 'NULL' : $xml[0][19]);
            $gl_number_id_lt_asset = $xml[0][39];
            $gl_number_id_lt_asset_Value = ($xml[0][21] == '' ? 'NULL' : $xml[0][21]);
            $gl_number_id_st_liab = $xml[0][38];
            $gl_number_id_st_liab_Value = ($xml[0][20] == '' ? 'NULL' : $xml[0][20]);
            $gl_number_id_lt_liab = $xml[0][40];
            $gl_number_id_lt_liab_Value = ($xml[0][22] == '' ? 'NULL' : $xml[0][22]);
            $gl_number_id_aoci = $xml[0][45];
            $gl_number_id_aoci_Value = ($xml[0][27] == '' ? 'NULL' : $xml[0][27]);
            $gl_number_id_cash = $xml[0][48];
            $gl_number_id_cash_Value = ($xml[0][30] == '' ? 'NULL' : $xml[0][30]);
            $gl_number_id_item_st_asset = $xml[0][41];
            $gl_number_id_item_st_asset_Value = ($xml[0][23] == '' ? 'NULL' : $xml[0][23]);
            $gl_number_id_item_lt_asset = $xml[0][43];
            $gl_number_id_item_lt_asset_Value = ($xml[0][25] == '' ? 'NULL' : $xml[0][25]);
            $gl_number_id_item_st_liab = $xml[0][42];
            $gl_number_id_item_st_liab_Value = ($xml[0][24] == '' ? 'NULL' : $xml[0][24]);
            $gl_number_id_item_lt_liab = $xml[0][44];
            $gl_number_id_item_lt_liab_Value = ($xml[0][26] == '' ? 'NULL' : $xml[0][26]);
            $gl_number_id_pnl = $xml[0][46];
            $gl_number_id_pnl_Value = ($xml[0][28] == '' ? 'NULL' : $xml[0][28]);
            $gl_number_id_set = $xml[0][47];
            $gl_number_id_set_Value = ($xml[0][29] == '' ? 'NULL' : $xml[0][29]);
            
            $gl_number_unhedged_der_st_asset = $xml[0][89];
            $gl_number_unhedged_der_st_asset_Value = ($xml[0][88] == '' ? 'NULL' : $xml[0][88]);
            $gl_number_unhedged_der_lt_asset = $xml[0][91];
            $gl_number_unhedged_der_lt_asset_Value = ($xml[0][90] == '' ? 'NULL' : $xml[0][90]);
            $gl_number_unhedged_der_st_liab = $xml[0][93];
            $gl_number_unhedged_der_st_liab_Value = ($xml[0][92] == '' ? 'NULL' : $xml[0][92]);
            $gl_number_unhedged_der_lt_liab = $xml[0][95];
            $gl_number_unhedged_der_lt_liab_Value = ($xml[0][94] == '' ? 'NULL' : $xml[0][94]);

            $gl_number_id_inventory = $xml[0][53];
            $gl_number_id_inventory_Value = ($xml[0][52] == '' ? 'NULL' : $xml[0][52]);
            $gl_id_amortization = $xml[0][56];
            $gl_id_amortization_Value = ($xml[0][55] == '' ? 'NULL' : $xml[0][55]);
            $gl_id_interest = $xml[0][58];
            $gl_id_interest_Value = ($xml[0][57] == '' ? 'NULL' : $xml[0][57]);
            $gl_number_id_expense = $xml[0][60];
            $gl_number_id_expense_Value = ($xml[0][59] == '' ? 'NULL' : $xml[0][59]);
            $gl_number_id_gross_set = $xml[0][62];
            $gl_number_id_gross_set_Value = ($xml[0][61] == '' ? 'NULL' : $xml[0][61]);

            $gl_id_st_tax_asset = $xml[0][75];
            $gl_id_st_tax_asset_Value = ($xml[0][74] == '' ? 'NULL' : $xml[0][74]);
            $gl_id_st_tax_liab = $xml[0][77];
            $gl_id_st_tax_liab_Value = ($xml[0][76] == '' ? 'NULL' : $xml[0][76]);
            $gl_id_lt_tax_asset = $xml[0][79];
            $gl_id_lt_tax_asset_Value = ($xml[0][78] == '' ? 'NULL' : $xml[0][78]);
            $gl_id_lt_tax_liab = $xml[0][81];
            $gl_id_lt_tax_liab_Value = ($xml[0][80] == '' ? 'NULL' : $xml[0][80]);
            $gl_id_tax_reserve = $xml[0][83];
            $gl_id_tax_reserve_Value = ($xml[0][82] == '' ? 'NULL' : $xml[0][82]);
        } else if ($flag == 'b') {
            $sp_url = $php_script_loc . "spa_books.php?flag=s&fas_book_id=" . $entity_id;
            $xml = readXMLURL($sp_url);
            $gl_number_id_st_asset = $xml[0][20];
            $gl_number_id_st_asset_Value = ($xml[0][3] == '' ? 'NULL' : $xml[0][3]);
            $gl_number_id_lt_asset = $xml[0][22];
            $gl_number_id_lt_asset_Value = ($xml[0][5] == '' ? 'NULL' : $xml[0][5]);
            $gl_number_id_st_liab = $xml[0][21];
            $gl_number_id_st_liab_Value = ($xml[0][4] == '' ? 'NULL' : $xml[0][4]);
            $gl_number_id_lt_liab = $xml[0][23];
            $gl_number_id_lt_liab_Value = ($xml[0][6] == '' ? 'NULL' : $xml[0][6]);
            $gl_number_id_aoci = $xml[0][28];
            $gl_number_id_aoci_Value = ($xml[0][11] == '' ? 'NULL' : $xml[0][11]);
            $gl_number_id_cash = $xml[0][31];
            $gl_number_id_cash_Value = ($xml[0][14] == '' ? 'NULL' : $xml[0][14]);
            $gl_number_id_item_st_asset = $xml[0][24];
            $gl_number_id_item_st_asset_Value = ($xml[0][7] == '' ? 'NULL' : $xml[0][7]);
            $gl_number_id_item_lt_asset = $xml[0][26];
            $gl_number_id_item_lt_asset_Value = ($xml[0][9] == '' ? 'NULL' : $xml[0][9]);
            $gl_number_id_item_st_liab = $xml[0][25];
            $gl_number_id_item_st_liab_Value = ($xml[0][8] == '' ? 'NULL' : $xml[0][8]);
            $gl_number_id_item_lt_liab = $xml[0][27];
            $gl_number_id_item_lt_liab_Value = ($xml[0][10] == '' ? 'NULL' : $xml[0][10]);
            $gl_number_id_pnl = $xml[0][29];
            $gl_number_id_pnl_Value = ($xml[0][12] == '' ? 'NULL' : $xml[0][12]);
            $gl_number_id_set = $xml[0][30];
            $gl_number_id_set_Value = ($xml[0][13] == '' ? 'NULL' : $xml[0][13]);

            $gl_number_id_inventory = $xml[0][34];
            $gl_number_id_inventory_Value = ($xml[0][33] == '' ? 'NULL' : $xml[0][33]);
            $gl_id_amortization = $xml[0][36];
            $gl_id_amortization_Value = ($xml[0][35] == '' ? 'NULL' : $xml[0][35]);
            $gl_id_interest = $xml[0][38];
            $gl_id_interest_Value = ($xml[0][37] == '' ? 'NULL' : $xml[0][37]);
            $gl_number_id_expense = $xml[0][40];
            $gl_number_id_expense_Value = ($xml[0][39] == '' ? 'NULL' : $xml[0][39]);
            $gl_number_id_gross_set = $xml[0][42];
            $gl_number_id_gross_set_Value = ($xml[0][41] == '' ? 'NULL' : $xml[0][41]);

            $gl_id_st_tax_asset = $xml[0][46];
            $gl_id_st_tax_asset_Value = ($xml[0][45] == '' ? 'NULL' : $xml[0][45]);
            $gl_id_st_tax_liab = $xml[0][48];
            $gl_id_st_tax_liab_Value = ($xml[0][47] == '' ? 'NULL' : $xml[0][47]);
            $gl_id_lt_tax_asset = $xml[0][50];
            $gl_id_lt_tax_asset_Value = ($xml[0][49] == '' ? 'NULL' : $xml[0][49]);
            $gl_id_lt_tax_liab = $xml[0][52];
            $gl_id_lt_tax_liab_Value = ($xml[0][51] == '' ? 'NULL' : $xml[0][51]);
            $gl_id_tax_reserve = $xml[0][54];
            $gl_id_tax_reserve_Value = ($xml[0][53] == '' ? 'NULL' : $xml[0][53]);

            $gl_number_unhedged_der_st_asset = $xml[0][61];
            $gl_number_unhedged_der_st_asset_Value = ($xml[0][60] == '' ? 'NULL' : $xml[0][60]);
            $gl_number_unhedged_der_lt_asset = $xml[0][63];
            $gl_number_unhedged_der_lt_asset_Value = ($xml[0][62] == '' ? 'NULL' : $xml[0][62]);
            $gl_number_unhedged_der_st_liab = $xml[0][65];
            $gl_number_unhedged_der_st_liab_Value = ($xml[0][64] == '' ? 'NULL' : $xml[0][64]);
            $gl_number_unhedged_der_lt_liab = $xml[0][67];
            $gl_number_unhedged_der_lt_liab_Value = ($xml[0][66] == '' ? 'NULL' : $xml[0][66]);
        } else if ($flag == 'm') {
            $sp_url = $php_script_loc . "spa_source_books_map_GL_codes.php?flag=s&source_book_map_id=" . $entity_id;
            $xml = readXMLURL($sp_url);

            if (empty($xml)) {
                $gl_number_id_st_asset = 'NULL';
                $gl_number_id_st_asset_Value = 'NULL';
                $gl_number_id_st_liab = 'NULL';
                $gl_number_id_st_liab_Value = 'NULL';
                $gl_number_id_lt_asset = 'NULL';
                $gl_number_id_lt_asset_Value = 'NULL';
                $gl_number_id_lt_liab = 'NULL';
                $gl_number_id_lt_liab_Value = 'NULL';
                $gl_number_id_item_st_asset = 'NULL';
                $gl_number_id_item_st_asset_Value = 'NULL';
                $gl_number_id_item_st_liab = 'NULL';
                $gl_number_id_item_st_liab_Value = 'NULL';
                $gl_number_id_item_lt_asset = 'NULL';
                $gl_number_id_item_lt_asset_Value = 'NULL';
                $gl_number_id_item_lt_liab = 'NULL';
                $gl_number_id_item_lt_liab_Value = 'NULL';

                $gl_number_id_aoci = 'NULL';
                $gl_number_id_aoci_Value = 'NULL';
                $gl_number_id_pnl = 'NULL';
                $gl_number_id_pnl_Value = 'NULL';
                $gl_number_id_set = 'NULL';
                $gl_number_id_set_Value = 'NULL';
                $gl_number_id_cash = 'NULL';
                $gl_number_id_cash_Value = 'NULL';

                $gl_number_id_inventory = 'NULL';
                $gl_number_id_inventory_Value = 'NULL';
                $gl_id_amortization = 'NULL';
                $gl_id_amortization_Value = 'NULL';
                $gl_id_interest = 'NULL';
                $gl_id_interest_Value = 'NULL';
                $gl_number_id_expense = 'NULL';
                $gl_number_id_expense_Value = 'NULL';
                $gl_number_id_gross_set = 'NULL';
                $gl_number_id_gross_set_Value = 'NULL';

                $gl_id_st_tax_asset = 'NULL';
                $gl_id_st_tax_asset_Value = 'NULL';
                $gl_id_st_tax_liab = 'NULL';
                $gl_id_st_tax_liab_Value = 'NULL';
                $gl_id_lt_tax_asset = 'NULL';
                $gl_id_lt_tax_asset_Value = 'NULL';
                $gl_id_lt_tax_liab = 'NULL';
                $gl_id_lt_tax_liab_Value = 'NULL';
                $gl_id_tax_reserve = 'NULL';
                $gl_id_tax_reserve_Value = 'NULL';

                $gl_number_unhedged_der_st_asset = 'NULL';
                $gl_number_unhedged_der_st_asset_Value = 'NULL';
                $gl_number_unhedged_der_lt_asset = 'NULL';
                $gl_number_unhedged_der_lt_asset_Value = 'NULL';
                $gl_number_unhedged_der_st_liab = 'NULL';
                $gl_number_unhedged_der_st_liab_Value = 'NULL';
                $gl_number_unhedged_der_lt_liab = 'NULL';
                $gl_number_unhedged_der_lt_liab_Value = 'NULL';
            } else {
                $gl_number_id_st_asset = $xml[0][14] == 'NULL' ? 'NULL' : $xml[0][14];
                $gl_number_id_st_asset_Value = ($xml[0][2] == '' ? 'NULL' : $xml[0][2]);
                $gl_number_id_st_liab = $xml[0][15];
                $gl_number_id_st_liab_Value = ($xml[0][3] == '' ? 'NULL' : $xml[0][3]);
                $gl_number_id_lt_asset = $xml[0][16];
                $gl_number_id_lt_asset_Value = ($xml[0][4] == '' ? 'NULL' : $xml[0][4]);
                $gl_number_id_lt_liab = $xml[0][17];
                $gl_number_id_lt_liab_Value = ($xml[0][5] == '' ? 'NULL' : $xml[0][5]);
                $gl_number_id_item_st_asset = $xml[0][18];
                $gl_number_id_item_st_asset_Value = ($xml[0][6] == '' ? 'NULL' : $xml[0][6]);
                $gl_number_id_item_st_liab = $xml[0][19];
                $gl_number_id_item_st_liab_Value = ($xml[0][7] == '' ? 'NULL' : $xml[0][7]);
                $gl_number_id_item_lt_asset = $xml[0][20];
                $gl_number_id_item_lt_asset_Value = ($xml[0][8] == '' ? 'NULL' : $xml[0][8]);
                $gl_number_id_item_lt_liab = $xml[0][21];
                $gl_number_id_item_lt_liab_Value = ($xml[0][9] == '' ? 'NULL' : $xml[0][9]);

                $gl_number_id_aoci = $xml[0][22];
                $gl_number_id_aoci_Value = ($xml[0][10] == '' ? 'NULL' : $xml[0][10]);
                $gl_number_id_pnl = $xml[0][23];
                $gl_number_id_pnl_Value = ($xml[0][11] == '' ? 'NULL' : $xml[0][11]);
                $gl_number_id_set = $xml[0][24];
                $gl_number_id_set_Value = ($xml[0][12] == '' ? 'NULL' : $xml[0][12]);
                $gl_number_id_cash = $xml[0][25];
                $gl_number_id_cash_Value = ($xml[0][13] == '' ? 'NULL' : $xml[0][13]);

                $gl_number_id_inventory = $xml[0][27];
                $gl_number_id_inventory_Value = ($xml[0][26] == '' ? 'NULL' : $xml[0][26]);
                $gl_id_amortization = $xml[0][29];
                $gl_id_amortization_Value = ($xml[0][28] == '' ? 'NULL' : $xml[0][28]);
                $gl_id_interest = $xml[0][31];
                $gl_id_interest_Value = ($xml[0][30] == '' ? 'NULL' : $xml[0][30]);
                $gl_number_id_expense = $xml[0][33];
                $gl_number_id_expense_Value = ($xml[0][32] == '' ? 'NULL' : $xml[0][32]);
                $gl_number_id_gross_set = $xml[0][35];
                $gl_number_id_gross_set_Value = ($xml[0][34] == '' ? 'NULL' : $xml[0][34]);

                $gl_id_st_tax_asset = $xml[0][37];
                $gl_id_st_tax_asset_Value = ($xml[0][36] == '' ? 'NULL' : $xml[0][36]);
                $gl_id_st_tax_liab = $xml[0][39];
                $gl_id_st_tax_liab_Value = ($xml[0][38] == '' ? 'NULL' : $xml[0][38]);
                $gl_id_lt_tax_asset = $xml[0][41];
                $gl_id_lt_tax_asset_Value = ($xml[0][40] == '' ? 'NULL' : $xml[0][40]);
                $gl_id_lt_tax_liab = $xml[0][43];
                $gl_id_lt_tax_liab_Value = ($xml[0][42] == '' ? 'NULL' : $xml[0][42]);
                $gl_id_tax_reserve = $xml[0][45];
                $gl_id_tax_reserve_Value = ($xml[0][44] == '' ? 'NULL' : $xml[0][44]);

                $gl_number_unhedged_der_st_asset = $xml[0][47];
                $gl_number_unhedged_der_st_asset_Value = ($xml[0][46] == '' ? 'NULL' : $xml[0][46]);
                $gl_number_unhedged_der_lt_asset = $xml[0][49];
                $gl_number_unhedged_der_lt_asset_Value = ($xml[0][48] == '' ? 'NULL' : $xml[0][48]);
                $gl_number_unhedged_der_st_liab = $xml[0][51];
                $gl_number_unhedged_der_st_liab_Value = ($xml[0][50] == '' ? 'NULL' : $xml[0][50]);
                $gl_number_unhedged_der_lt_liab = $xml[0][53];
                $gl_number_unhedged_der_lt_liab_Value = ($xml[0][52] == '' ? 'NULL' : $xml[0][52]);
            }
        }
    }
    ?>
    <style type="text/css">
        .center {
            margin: 0px auto;
            text-align: right; 
            font-size: 11px;
            font-weight: bold;
            padding: 5px;
        }
    </style>
    <body style="background-color: #EAEAEA;">
        <form name="<?php echo $form_name; ?>"> 
            <div class="row" style="margin-left: 115px; height:200px;"> 
                <?php
                $tot_row = count($return_value);
                $cnt = 0;

                while ($cnt < $tot_row) {
                    $column_map_label = $return_value[$cnt][2];
                    $column_map_name = $return_value[$cnt][0];
                    ?>
                    <div class="row">
                        <div class="center component-container-large">
                            <?php
                            echo label_hyperlink_text(10101310, $column_map_label, $form_name . '.txt_gl_number_' . $cnt);
                            echo adiha_texthide($form_name, 'txt_gl_number_' . $cnt, ${$column_map_name . '_Value'});
                            echo adiha_texthide($form_name, 'txt_column_map_name_' . $cnt, $column_map_name);
                            ?>
                        </div>
                        <div class="component-container-large" style="width: 170px;">
                            <?php
                            echo adiha_textbox($form_name, $column_map_name . '_label', $$column_map_name, false);
                            echo adiha_button('fbtn_' . $cnt, 'File', true, 'fbtn_' . $cnt . '_click', $form_name);
                            ?>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <?php
                    echo "<script> 
                            function fbtn_" . $cnt . "_click() {
                                var args = 'call_from=1&' + getAppUserName();
                                var return_value = createWindow('windowMapGLCodes', false, true, args);
    
                                    try {
                                        set_" . $column_map_name . "_label_value(return_value[1]);
                                        set_txt_gl_number_" . $cnt . "_value(return_value[0]);
                                    } catch(exceptions) {}
                            }
                        </script>";
                    $cnt++;
                }
                ?>                                                                                
            </div> 
        </form>
    </body>
    <script type="text/javascript">
        function get_gl_detail() {
            var tot_row = <?php echo $tot_row; ?> ;
            var column = 1;
            var row = 1;
            var xml_text = '<Root>';
            var x = '';
            var y = '';
            gl_array = new Array();
            
            while (row <= tot_row) {
                row_id = row - 1;
                column_map_name = eval('get_txt_column_map_name_' + row_id + '_value()');
                value_id = eval('get_txt_gl_number_' + row_id + '_value()');
                gl_array[column_map_name] = value_id;
                row = row + 1;
            }
        	
            return gl_array;
        }
        
        function setEnabledFile(bol_val) {
            var tot_row = <?php echo $tot_row; ?>;
        	
            if (tot_row == 0) {
                return;
            }
        	
            var row = 1;
            while (row <= tot_row) {
                row_id = row - 1;
                eval('set_fbtn_' + row_id + '_enabled(' + bol_val + ')');
                row ++;
            }
        }
            
        <?php
        if ($callback_function != '') {
            echo 'parent.' . $callback_function . '();';
        }
        ?>
    </script>
<?php echo paint_footer(); ?>