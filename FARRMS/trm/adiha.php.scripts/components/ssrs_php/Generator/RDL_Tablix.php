<?php
/**
 *  @brief RDL Tablix
 *
 *  @par Description
 *  This class handles the Tablix XML generation; contains the XML implementations concentrating to Tablix (Normal, Crosstab)
 *  @copyright Pioneer Solutions
 */
class RDL_Tablix extends RDL_Item {

    public $arr_tablix;
    public $arr_tablix_collection = array();
    public $group_mode;
    public $border_style;
    public $border_style_buffer;
    public $page_break;
    public $type;
    public $cross_summary;
    public $no_header;
    public $avg_column_width;
    public $rdl_column_currency_option;
    public $rdl_column_date_format_option;
    public $rdl_column_aggregation_option;
    public $avg_column_height = '0.21in';
    public $border_color = '#ced9e1';
    public $blank_index = 1;
    public $row_ccaption = array();
    public $col_ccaption = array();
    public $summary_unnecessary = TRUE;

    /**
     * Indexes: column_name | report_page_tablix_id | report_tablix_column_id | placement | aggregation | functions | alias | sortable | rounding | thousand_seperation | font | font_size | font_style | text_align | text_color | h_font | h_font_size | h_font_style | h_text_align | h_text_color | default_sort_order | sorting_column | default_sort_direction | background | h_background | dataset_id | custom_field | display_type | datatype_id | render_as | border_style | page_break | negative_mark | currency | date_format
     * @var Array
     */
    public $ttablix;

    /**
     * Indexes: column_name | report_page_tablix_id | report_tablix_column_id | placement | aggregation | functions | alias | sortable | rounding | thousand_seperation | font | font_size | font_style | text_align | text_color | h_font | h_font_size | h_font_style | h_text_align | h_text_color | default_sort_order | sorting_column | default_sort_direction | background | h_background | dataset_id | custom_field | display_type | datatype_id | render_as | border_style | page_break | negative_mark | currency | date_format + column_var | data_type
     * @var Array
     */
    public $details;

    /**
     * Indexes: column_name | report_page_tablix_id | report_tablix_column_id | placement | aggregation | functions | alias | sortable | rounding | thousand_seperation | font | font_size | font_style | text_align | text_color | h_font | h_font_size | h_font_style | h_text_align | h_text_color | default_sort_order | sorting_column | default_sort_direction | background | h_background | dataset_id | custom_field | display_type | datatype_id | render_as | border_style | page_break | negative_mark | currency | date_format + column_var | data_type
     * @var Array
     */
    public $groups;

    /**
     * Indexes: column_name | report_page_tablix_id | report_tablix_column_id | placement | aggregation | functions | alias | sortable | rounding | thousand_seperation | font | font_size | font_style | text_align | text_color | h_font | h_font_size | h_font_style | h_text_align | h_text_color | default_sort_order | sorting_column |default_sort_direction | background | h_background | dataset_id | custom_field | display_type | datatype_id | render_as | border_style | page_break | negative_mark | currency | date_format + column_var | data_type
     * @var Array
     */
    public $rows;

    /**
     * Indexes: column_name | report_page_tablix_id | report_tablix_column_id | placement | aggregation | functions | alias | sortable | rounding | thousand_seperation | font | font_size | font_style | text_align | text_color | h_font | h_font_size | h_font_style | h_text_align | h_text_color | default_sort_order | sorting_column | default_sort_direction | background | h_background | dataset_id | custom_field | display_type | datatype_id | render_as | border_style | page_break | negative_mark | currency | date_format + column_var | data_type
     * @var Array
     */
    public $cols;
    public $tablix_rows = array();

    /**
     * Constructor
     *
     * @param   array   $ssrs_config                    Configuration for SQL Server Reporting Service
     * @param   array   $language_dict                  Language dictionary
     * @param   string  $rdl_column_currency_option     Column currency option for RDL
     * @param   string  $rdl_column_date_format_option  Column date format option for RDL
     * @param   string  $rdl_column_aggregation_option  Column aggregation option for RDL
     * @param   string  $rdl_type                       RDL type
     * @param   string  $process_id                     Process ID
     */
    public function __construct($ssrs_config = null, $language_dict = null, $rdl_column_currency_option = null, $rdl_column_date_format_option = null, $rdl_column_aggregation_option = null, $rdl_type = null, $process_id = null) {
        parent::__construct($ssrs_config, $language_dict, $rdl_type, $process_id);
        $this->rdl_column_currency_option = $rdl_column_currency_option;
        $this->rdl_column_date_format_option = $rdl_column_date_format_option;
        $this->rdl_column_aggregation_option = $rdl_column_aggregation_option;
        $this->display_type = 't';
    }

    /**
     * Reset Border type to default set in form
     */
    public function reset_border_style() {
        $this->border_style = $this->border_style_buffer;
    }

    /**
     * Init current tablix variables, flushing old data in the object
     * @param type $group_mode
     * @param type $border_style
     * @param type $page_break
     * @param type $type
     */
    public function init_tablix($group_mode, $border_style, $page_break, $type, $cross_summary, $no_header) {
        $this->group_mode = $group_mode;
        $this->border_style = $border_style;
        $this->border_style_buffer = $border_style;
        $this->page_break = $page_break;
        $this->type = $type;
        $this->cross_summary = $cross_summary;
        $this->no_header = $no_header;
        $this->tablix_rows = array();
        $this->row_ccaption = array();
        $this->col_ccaption = array();
    }

    /**
     * Push finalised tablix array to collection
     */
    public function finalize_tablix() {
        #set tablix corner caption if its crosstab
        if ($this->type == '2') {
			$caption = '=';
            $caption .= implode(' & "," & ', $this->row_ccaption);
            $caption .= ' & " \\ " & ' . implode(' & ", " & ', $this->col_ccaption);
            $this->setval_from_path($this->arr_tablix, 'TablixCorner/TablixCornerRows/TablixCornerRow/0/TablixCornerCell/0/CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/Value', $caption);
        }
        array_push($this->arr_tablix_collection, $this->arr_tablix);
    }

    /**
     * Get collection of tablix
     *
     * @return  array  Tablix collection
     */
    public function get_tablix_collection() {
        return $this->arr_tablix_collection;
    }

    /**
     * Factory the placement based data to ease processings later on. Very essential step. We store the input array seperately also if whole bunch required, we use that.
     * @param array $info Tablix Item array returned by Database Query.
     */
    public function set_base($info) {
        $this->ttablix = $info;
        $this->details = array();
        $this->groups = array();
        $this->cols = array();
        $this->rows = array();
        foreach ($this->ttablix as $items) {
            //set some special variables
            $items['alias'] = trim($items['alias']);
            $items['column_var'] = preg_replace('/[^\w]/', '_', $items['alias']);
            $items['sorting_column_alias'] = $items['sorting_column'];
            $items['sorting_column'] = preg_replace('/[^\w]/', '_', $items['sorting_column']);
            $items['data_type'] = ($items['datatype_id'] == '3' || $items['datatype_id'] == '4') ? 1 : 2;
            $items['sorting_data_type'] = ($items['sorting_datatype_id'] == '3' || $items['sorting_datatype_id'] == '4') ? 1 : 2;
            //push dataset info
            $this->push_dataset_field($items['column_var'], $items['alias'], $items['data_type']);
            // check if this column already exists in Dataset fields or not            
            if ($items['sorting_column'] != '' && $items['sorting_column'] != 'NULL') {
                $this->push_dataset_field($items['sorting_column'], $items['sorting_column_alias'], $items['sorting_data_type']);
            }
            switch ($items['placement']) {
                case '1':#detail column
                    $this->details[$items['report_tablix_column_id']] = $items;
                    if (!$items['sql_aggregation'] > 0)
                        $this->summary_unnecessary = false;
                    break;
                case '2':#group column
                    $this->groups[$items['report_tablix_column_id']] = $items;
                    break;
                case '3':#column by
                    $this->cols[$items['report_tablix_column_id']] = $items;
                    break;
                case '4':#row by
                    $this->rows[$items['report_tablix_column_id']] = $items;
                    break;
            }
        }
        $this->_set_base_tablix();
    }

    /**
     * Sets base tablix structure on array
     */
    public function _set_base_tablix() {

        $this->arr_tablix = array(
            'TablixCorner' => '',
            'TablixBody' => array(
                'TablixColumns' => array('TablixColumn' => ''),
                'TablixRows' => array(
                    'TablixRow' => ''
                )
            ),
            'TablixColumnHierarchy' => array('TablixMembers' => array('TablixMember' => '')
            ),
            'TablixRowHierarchy' => array(
                'TablixMembers' => ''
            ),
            'RepeatColumnHeaders' => 'true',
            'RepeatRowHeaders' => 'true',
            'DataSetName' => $this->dataset_name,
            'Top' => $this->top,
            'Left' => $this->left,
            'Width' => $this->width,
            'Height' => $this->height,
            'Style' => array(
                'Border' => array(
                    'Color' => '#ced9e1',
                    'Style' => 'None',
                ),
                'TopBorder' => array(
                    'Color' => '#ced9e1',
                    'Style' => 'None',
                ),
                'RightBorder' => array(
                    'Color' => '#ced9e1',
                    'Style' => (($this->border_style == '2') ? 'Solid' : 'None'),
                ),
                'BottomBorder' => array(
                    'Color' => '#ced9e1',
                    'Style' => (($this->border_style == '2') ? 'Solid' : 'None'),
                ),
                'LeftBorder' => array(
                    'Color' => '#ced9e1',
                    'Style' => (($this->border_style == '2') ? 'Solid' : 'None'),
                ),
                'PaddingLeft' => '0pt',
                'PaddingRight' => '0pt',
                'PaddingTop' => '0pt',
                'PaddingBottom' => '0pt'
            ),
            '@attributes' => array('Name' => $this->name)
        );
        if ($this->type == '2') { #if tablix is crosstab then we need corner
            $this->arr_tablix['TablixCorner'] = $this->_set_tablix_corner();
        } else {
            unset($this->arr_tablix['TablixCorner']);
            unset($this->arr_tablix['RepeatColumnHeaders']);
            unset($this->arr_tablix['RepeatRowHeaders']);
        }

        if ($this->page_break > 0) {
            switch ($this->page_break) {
                case '1':
                    $this->arr_tablix['PageBreak'] = array('BreakLocation' => 'Start');
                    break;
                case '2':
                    $this->arr_tablix['PageBreak'] = array('BreakLocation' => 'End');
                    break;
                case '3':
                    $this->arr_tablix['PageBreak'] = array('BreakLocation' => 'StartAndEnd');
                    break;
            }
        }
    }

    /**
     * Returns corner of crosstab tablix as array
     * @param string $value Caption of Crosstab corner
     * @return array Corner Array
     */
    public function _set_tablix_corner() {
        $row_count = (sizeof($this->details) > 1) ? 1 : 0;
        $row_count += sizeof($this->cols);
        $col_count = sizeof($this->rows);
        $tmp_corner_arr = array(
            'TablixCornerRows' => array(
                'TablixCornerRow' => array(
                    array('TablixCornerCell' => array(
                            array(
                                'CellContents' => array(
                                    'Textbox' => array(
                                        'CanGrow' => 'true',
                                        'KeepTogether' => 'true',
                                        'Paragraphs' => array(
                                            'Paragraph' => array(
                                                'TextRuns' => array(
                                                    'TextRun' => array(
                                                        'Value' => '',
                                                        'Style' => array(
                                                            'FontFamily' => 'Tahoma',
                                                            'FontSize' => '8pt',
                                                            'Color' => 'DimGray'
                                                        )
                                                    )
                                                ),
                                                'Style' => ''
                                            )
                                        ),
                                        'rd:DefaultName' => 'textbox_corner_' . $this->name,
                                        'Style' => array(
                                            'Border' => array(
                                                'Color' => 'LightGrey',
                                                'Style' => 'None'
                                            ),
                                            'PaddingLeft' => '2pt',
                                            'PaddingRight' => '2pt',
                                            'PaddingTop' => '2pt',
                                            'PaddingBottom' => '2pt'
                                        ),
                                        '@attributes' => array(
                                            'Name' => 'textbox_corner_' . $this->name
                                        )
                                    ),
                                    'RowSpan' => $row_count,
                                    'ColSpan' => $col_count
                                )
                            )
                        )
                    )
                )
            )
        );

        $cnt_new = $col_count - 1;
        for ($i = 1; $i <= $cnt_new; $i++) {
            $tmp_corner_arr['TablixCornerRows']['TablixCornerRow'][0]['TablixCornerCell'][$i] = '';
        }

        #prepare blank rows, if required 
        for ($i = 1; $i <= ($row_count - 1); $i++) {
            $tmp_blank_corner['TablixCornerCell'] = array();
            for ($j = 1; $j <= $col_count; $j++) {
                array_push($tmp_blank_corner['TablixCornerCell'], '');
            }
            array_push($tmp_corner_arr['TablixCornerRows']['TablixCornerRow'], $tmp_blank_corner);
        }
        return $tmp_corner_arr;
    }

    /**
     * Sets TablixColumns of TablixBody
     */
    public function set_tablix_columns() {
        $total_columns = sizeof($this->ttablix);
		$this->avg_column_width = ((int)str_replace("in","",$this->width) / ($total_columns == 0 ? 1 : $total_columns)) . 'in';
        $tag_count = ($this->type == '2') ? sizeof($this->details) : $total_columns;
        if ($this->type == '2' && ($this->cross_summary == '3' || $this->cross_summary == '4')) {
            $tag_count = $tag_count * 2;
        }
        $tmp_col_arr = array();
        for ($inc = 1; $inc <= $tag_count; $inc++) {
            array_push($tmp_col_arr, array('Width' => $this->avg_column_width));
        }
        $this->arr_tablix['TablixBody']['TablixColumns']['TablixColumn'] = $tmp_col_arr;
    }

    /**

     */

    /**
     * Prep style for Cell content areas
     * @param array $column Column Data
     * @param int $type Style type: 1:Value | 2:Paragraph | 3:Container  (Conceptual)
     * @param type $last_column
     * @param type $apply_formatting
     * @param type $apply_header_style
     * @param type $aggregation_block
     * @param type $no_border
     * @return string|null
     */
    public function get_style($column, $type, $last_column = FALSE, $apply_formatting = FALSE, $apply_header_style = FALSE, $aggregation_block = '', $no_border = FALSE) {
        $style = array();
        $prefix = ($apply_header_style) ? 'h_' : '';
        $number_types = array(2, 3, 5, 6, 13, 14);
        $is_number = (in_array($column['render_as'], $number_types)) ? TRUE : FALSE;
        switch ($type) {
            case '1':#Value
                if ($apply_formatting) {#if not header then allow formattiing
                    switch ($column['render_as']) {
                        case '2':case '3':case '13': //Number or Currency or Price
                            $plain_number = TRUE;
                            $column_format = array();
                            #currency
                            if (($column['render_as'] == '3' || $column['render_as'] == '13') && $column['currency'] > -1) {
                                array_push($column_format, $this->rdl_column_currency_option[$column['currency']][2]);
                                $plain_number = FALSE;
                            }
                            array_push($column_format, '"#"');
                            #thousand_seperation
                            if ($column['thousand_seperation'] < 2) {
                                switch ($column['thousand_seperation']) {
                                    case '0':
                                        array_push($column_format, "Parameters!global_thousand_format.Value");
                                        break;
                                    case '1':
                                        array_push($column_format, '",#"');
                                        break;
                                }
                                $plain_number = FALSE;
                            }
                            #rounding
                            if ($column['rounding'] > -2) {
                                switch ($column['rounding']) {
                                    case '-1':
                                        if ($column['render_as'] == '3'){
											array_push($column_format, "Parameters!global_amount_rounding_format.Value");
										} else if ($column['render_as'] == '13') {
											array_push($column_format, "Parameters!global_price_rounding_format.Value");
										} else {
											array_push($column_format, "Parameters!global_rounding_format.Value");
										}
                                        break;
                                    default:
                                        $strt = "#0";
                                        if($column['rounding'] > 0){
                                            $strt .= "." . str_repeat('0', $column['rounding']);
                                        }
                                        array_push($column_format, '"' . $strt . '"');
                                }
                                $plain_number = FALSE;
                            }
                            #merge all
                            if (!$plain_number && sizeof($column_format) > 0) {
                                $column_format = implode('+', $column_format);
                                $style['Format'] = "=" . $column_format;
                            }
                            break;
                        case '5'://Percentage
                            if ($column['rounding'] > -2) {
                                switch ($column['rounding']) {
                                    case '-1':
                                        $column_format = '="#"+Parameters!global_rounding_format.Value+"%"';
                                        break;
                                    default:
                                        $strt = "#0";
                                        if($column['rounding'] > 0){
                                            $strt .= "." . str_repeat('0', $column['rounding']);
                                        }
                                        $column_format = "#" . $strt . "%";
                                }
                            } else {
                                $column_format = "E";
                            }
                            $style['Format'] = $column_format;
                            break;
                        case '6'://Scientific
                            if ($column['rounding'] > -2) {
                                switch ($column['rounding']) {
                                    case '-1':
                                        $column_format = '="E"+Parameters!global_science_rounding_format.Value';
                                        break;
                                    default:
                                        $column_format = "E" . $column['rounding'];
                                }
                            } else {
                                $column_format = "E";
                            }
                            $style['Format'] = $column_format;
                            break;
                        case '4'://Date
                            $format_seperator = (intval($column['date_format']) === 0) ? '' : '"';
                            $style['Format'] = '=IIf(FormatDateTime(CDate(Fields!' . $column['column_var'] . '.Value),DateFormat.ShortDate) = "1/1/0001","",'.$format_seperator . $this->rdl_column_date_format_option[$column['date_format']][2] . $format_seperator.')';
                            break;
						case '14'://Volume
							$plain_number = TRUE;
                            $column_format = array();
                            array_push($column_format, '"#"');
                            #thousand_seperation
                            if ($column['thousand_seperation'] < 2) {
                                switch ($column['thousand_seperation']) {
                                    case '0':
                                        array_push($column_format, "Parameters!global_thousand_format.Value");
                                        break;
                                    case '1':
                                        array_push($column_format, '",#"');
                                        break;
                                }
                                $plain_number = FALSE;
                            }
                            #rounding
                            if ($column['rounding'] > -2) {
                                switch ($column['rounding']) {
                                    case '-1':
										array_push($column_format, "Parameters!global_volume_rounding_format.Value");
                                        break;
                                    default:
                                        $strt = "#0";
                                        if($column['rounding'] > 0){
                                            $strt .= "." . str_repeat('0', $column['rounding']);
                                        }
                                        array_push($column_format, '"' . $strt . '"');
                                }
                                $plain_number = FALSE;
                            }
                            #merge all
                            if (!$plain_number && sizeof($column_format) > 0) {
                                $column_format = implode('+', $column_format);
                                $style['Format'] = "=" . $column_format;
                            }
							break;
                    }
                }
                #font color
                if ($is_number && $column['negative_mark'] < 2 && $apply_formatting) {
                    #if block (no repeats) and its detail
                    if (!($this->group_mode == '4' && $column['placement'] == '2')) {
                        $font_color = (strlen($column[$prefix . 'text_color']) > 0) ? $column[$prefix . 'text_color'] : "Black";
                        $compare_block = array();
                        array_push($compare_block, (strlen($aggregation_block) > 0) ? $aggregation_block . ' < 0 ' : $this->get_field_name($column['column_var'], $column['render_as'], FALSE) . ' < 0 ');
                        if ($column['negative_mark'] == "0") {
                            array_push($compare_block, 'Parameters!global_negative_mark_format.Value = "1" ');
                        }
                        $compare_str = implode(' AND ', $compare_block);
                        $style['Color'] = '=IIf(' . $compare_str . ',"Red","' . $font_color . '")';
                    } else {
                        $style['Color'] = (strlen($column[$prefix . 'text_color']) > 0) ? $column[$prefix . 'text_color'] : "Black";
                    }
                } else { #font color text
                    $style['Color'] = (strlen($column[$prefix . 'text_color']) > 0) ? $column[$prefix . 'text_color'] : "Black";
                }
                #font family
                $style['FontFamily'] = (strlen($column[$prefix . 'font']) > 0) ? $column[$prefix . 'font'] : 'Tahoma';

                #font size
                $style['FontSize'] = (strlen($column[$prefix . 'font_size']) > 0) ? $column[$prefix . 'font_size'] . 'pt' : '8pt';

                #font style - B I U
                $font_style_map = explode(",", $column[$prefix . 'font_style']);
                if ($font_style_map[0] == 1)
                    $style['FontWeight'] = 'Bold';
                if (($font_style_map[1] ?? '') == 1)
                    $style['FontStyle'] = 'Italic';
                if (($font_style_map[2] ?? '') == 1)
                    $style['TextDecoration'] = 'Underline';
				if ($is_number)
					$style['Language'] = "=Parameters!global_number_format_region.Value";
                break;

            case '2':#Paragraph
                $style['TextAlign'] = (strlen($column[$prefix . 'text_align']) > 0) ? $column[$prefix . 'text_align'] : 'Left';
                break;

            case '3':#Container
                if (!$no_border) {
                    switch ($this->border_style) {
                        case '1':#all
                            $style['Border']['Style'] = 'Solid';
                            $style['Border']['Color'] = $this->border_color;

                            break;
                        case '2':#box
                            $style['Border']['Style'] = 'None';
                            break;
                        case '3':#horizontal lines
                            $style['Border']['Color'] = $this->border_color;
                            $style['Border']['Style'] = 'None';
                            $style['TopBorder']['Style'] = 'Solid';
                            $style['BottomBorder']['Style'] = 'Solid';
                            $style['LeftBorder']['Style'] = 'None';
                            $style['RightBorder']['Style'] = 'None';
                            break;
                        case '4':#vertical lines
                            $noBorder = ($this->type == '1') ? 'LeftBorder' : 'RightBorder';
                            $escapeBorder = ($this->type == '1') ? 'RightBorder' : 'LeftBorder';
                            $style['Border']['Color'] = $this->border_color;
                            $style['Border']['Style'] = 'None';
                            $style['TopBorder']['Style'] = 'None';
                            $style['BottomBorder']['Style'] = 'None';
                            $style[$noBorder]['Style'] = 'None';
                            if (!$last_column)
                                $style[$escapeBorder]['Style'] = 'Solid';
                            break;
                        case '5':#none
                            $style['Border']['Style'] = 'None';
                            $style['TopBorder']['Style'] = 'None';
                            $style['BottomBorder']['Style'] = 'None';
                            $style['LeftBorder']['Style'] = 'None';
                            $style['RightBorder']['Style'] = 'None';
                            break;
                        case '6':#if by chance landed here for invoice design, sending blank style instead of empty hands
                            $style['Border']['Style'] = 'None';
                            $style['TopBorder']['Style'] = 'None';
                            $style['BottomBorder']['Style'] = 'None';
                            $style['LeftBorder']['Style'] = 'None';
                            $style['RightBorder']['Style'] = 'None';
                            break;
                    }
                }
                if (strlen($column[$prefix . 'background']) > 0)
                    $style['BackgroundColor'] = $column[$prefix . 'background'];
                $style['PaddingLeft'] = '2pt';
                $style['PaddingRight'] = '2pt';
                $style['PaddingTop'] = '2pt';
                $style['PaddingBottom'] = '2pt';
                break;
        }

        if (is_array($style) && sizeof($style) > 0) {
            return $style;
        } else {
            return NULL;
        }
    }

    /**
     * Get aggregation name
     *
     * @param   string  $column_var   Column variable
     * @param   int     $aggregation  Aggregation
     * @param   string  $render_as    Render
     *
     * @return  string                Return aggregation function
     */
    public function get_agg_name($column_var, $aggregation, $render_as) {
        if (!($aggregation > 0)) {
            return $this->get_field_name($column_var, $render_as, FALSE);
        }
        $function_initial = $this->rdl_column_aggregation_option[$aggregation][1];
        switch ($function_initial) {
            case 'MinMax':
                return 'Min(' . $this->get_field_name($column_var, $render_as, FALSE) . ') & " - " & Max(' . $this->get_field_name($column_var, $render_as, FALSE) . ')';

                break;
            case 'CountRows':
                return $function_initial . '(' . $this->get_field_name($column_var, NULL, FALSE) . ')';
                break;
            default:
                return $function_initial . '(' . $this->get_field_name($column_var, $render_as, FALSE) . ')';
        }
    }

    /**
     * Get field name
     *
     * @param   string  $column_name                 Column name
     * @param   string  $render_as                   Render as
     * @param   boolean  $with_equalto_expr          TRUE if equalto operator is used else FALSE
     * @param   boolean  $check_blank_value_for_DBL  TRUE if need to check blank value for database else FALSE
     *
     * @return  string                               Return field function
     */
    public function get_field_name($column_name, $render_as = NULL, $with_equalto_expr = TRUE, $check_blank_value_for_DBL = FALSE) {
        $prefix = ($with_equalto_expr) ? '=' : '';
        switch ($render_as) {
            case '2':case '3':case '5':case '6':
                if ($check_blank_value_for_DBL)
                    return $prefix . 'IIf(Len(Fields!' . $column_name . '.Value) > 0,CDbl(Fields!' . $column_name . '.Value),"")';
                else
                    return $prefix . 'CDbl(Fields!' . $column_name . '.Value)';
                break;
            case '4':
                if ($check_blank_value_for_DBL)
                    return $prefix . 'IIf(IsNothing(Fields!' . $column_name . '.Value),"",CDate(Fields!' . $column_name . '.Value))';
                else
                    return $prefix . 'CDate(Fields!' . $column_name . '.Value)';
                break;
            default:
                return $prefix . 'Fields!' . $column_name . '.Value';
        }
    }

    /**
     * Get tablix cell
     *
     * @param   string  $name             Tablix name
     * @param   string  $value            Tablix value
     * @param   boolean  $force_size      TRUE if size is forced else FALSE
     * @param   string  $value_style      Value style
     * @param   string  $paragraph_style  Paragraph style
     * @param   string  $container_style  Container style
     * @param   boolean  $deo_no_output   TRUE if no data element output else FALSE
     *
     * @return  array                     Return tablix cell property
     */
    public function get_tablix_cell($name, $value, $force_size = FALSE, $value_style = NULL, $paragraph_style = NULL, $container_style = NULL, $deo_no_output = FALSE) {
        $tmp_arr = array(
            'Size' => NULL,
            'CellContents' => array(
                'Textbox' => array(
                    'CanGrow' => 'true',
                    'KeepTogether' => 'true',
                    'Paragraphs' => array(
                        'Paragraph' => array(
                            'TextRuns' => array(
                                'TextRun' => array(
                                    'Value' => $value,
                                    'Style' => $value_style
                                )
                            ),
                            'Style' => $paragraph_style
                        )
                    ),
                    'rd:DefaultName' => $name,
                    'Style' => $container_style,
                    '@attributes' => array(
                        'Name' => $name
                    )
                )
            )
        );
        if ($force_size)
            $tmp_arr['Size'] = $force_size;
        else
            unset($tmp_arr['Size']);
        if($deo_no_output)
            $tmp_arr['CellContents']['Textbox']['DataElementOutput'] = 'NoOutput';
        return $tmp_arr;
    }

    /**
     * Sets Column Hierarchy XML nodes
     */
    public function set_tablix_column_hierarchy() {
        $tmp_rdl_partial = array();
        if ($this->type == '2') {#crosstab
            $right_summary_exists = ($this->cross_summary == 3 || $this->cross_summary == 4) ? TRUE : FALSE;
            $total_cols = sizeof($this->cols);
            $total_details = sizeof($this->details);
            $cli = 0;
            foreach ($this->cols as $column) {
                #register column name for corner label
                array_push($this->col_ccaption, 'First(Fields!'.preg_replace("/[^\w]/","_",$column['alias']).'.Value, "Dataset_header")');
                #prepare paths for Group, SortExpressions, TablixHeader, DataElementOutput
                $var_path = str_repeat('TablixMembers/TablixMember/', ($cli + 1));
                $this->remove_last_char($var_path);
                $last_column = ($total_cols == ($cli + 1)) ? TRUE : FALSE;
                $last_column_hdx = ($total_details > 1) ? FALSE : $last_column;

                #Add Group Info
                $this->setval_from_path($tmp_rdl_partial, $var_path . '/Group', array(
                    'GroupExpressions' => array(
                        'GroupExpression' => $this->get_field_name($column['column_var'])
                    ),
                    '@attributes' => array(
                        'Name' => $this->name . '_' . $column['column_var'] . '_Group'
                    )
                ));
                #Add SortExpressions Info
                $sorting_column = ($column['sorting_column'] != '') ? $column['sorting_column'] : $column['column_var'];
                $sort_data = array(
                    'SortExpression' => array(
                        'Value' => $this->get_field_name($sorting_column)
                    )
                );
                if ($column['default_sort_direction'] == '2') {
                    $sort_data['SortExpression']['Direction'] = 'Descending';
                }
                $this->setval_from_path($tmp_rdl_partial, $var_path . '/SortExpressions', $sort_data);
                #Add TablixHeader Info
                $field_name = $this->get_field_name($column['column_var'], $column['render_as']);
                $value_style = $this->get_style($column, 1, $last_column_hdx, TRUE, TRUE);
                $paragraph_style = $this->get_style($column, 2, $last_column_hdx, FALSE, TRUE);
                $container_style = $this->get_style($column, 3, $last_column_hdx, FALSE, TRUE);
                $tmp_cell = $this->get_tablix_cell($this->name . '_' . $column['column_var'], $field_name, $this->avg_column_height, $value_style, $paragraph_style, $container_style);
                if ($column['render_as'] == '1') {
                    $this->setval_from_path($tmp_cell, 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/MarkupType', 'HTML');
                }
                $this->setval_from_path($tmp_rdl_partial, $var_path . '/TablixHeader', $tmp_cell);

                #Add Detail Info; if its last column

                if ($last_column && $total_details > 1) {
                    $detail_header_stack = array();
                    #process for Detail Header now
                    $dti = 0;

                    foreach ($this->details as $column) {
                        $last_column_hd = ($total_details == ($dti + 1)) ? TRUE : FALSE;
                        $last_column_hdy = ($last_column_hd && $last_column_hdx && !$right_summary_exists) ? TRUE : FALSE;
                        $field_name = $this->name . '_' . $column['column_var'] . '_Header';
                        $value_style = $this->get_style($column, 1, $last_column_hdy, FALSE, TRUE);
                        $paragraph_style = $this->get_style($column, 2, $last_column_hdy, FALSE, TRUE);
                        $container_style = $this->get_style($column, 3, $last_column_hdy, FALSE, TRUE);
                        $tmp_cell = $this->get_tablix_cell($field_name, $this->_($column['alias']), $this->avg_column_height, $value_style, $paragraph_style, $container_style);
                        array_push($detail_header_stack, array(
                            'TablixHeader' => $tmp_cell,
                            'KeepTogether' => 'true'
                        ));
                        $dti++;
                    }
                    $this->setval_from_path($tmp_rdl_partial, $var_path . '/TablixMembers/TablixMember', $detail_header_stack);
                } else {#register members for next iteration, make tags align in hierarchy esp. DataElementOutput
                    $this->setval_from_path($tmp_rdl_partial, $var_path . '/TablixMembers/TablixMember', NULL);
                }
                #Add DataElementOutput Info
                $this->setval_from_path($tmp_rdl_partial, $var_path . '/DataElementOutput', 'Output');
                #Add KeepTogether Info; if not first column
                if ($cli > 0) {
                    $this->setval_from_path($tmp_rdl_partial, $var_path . '/KeepTogether', 'true');
                }
                $cli++;
            }
            if ($right_summary_exists) {
                $prev_tablix_member = $tmp_rdl_partial['TablixMembers']['TablixMember'];
                $total_details = sizeof($this->details);
                $detail_header_stack = array();
                array_push($detail_header_stack, $prev_tablix_member);
                $dti = 0;
                #start loop with details stack
                foreach ($this->details as $detail) {
                    $new_tablix_member = array();
                    $last_column_hd = ($total_details == ($dti + 1)) ? TRUE : FALSE;
                    #second loop for column stack
                    $cntr = 1;
                    foreach ($this->cols as $column) {
                        #introduce blanks as per columns
                        if ($dti == 0 && $cntr == 1) {
                            $total_label = $this->_('Total');
                            $column['h_font_style'] = '1,0,0';
                        } else {
                            $total_label = '';
                        }
                        $var_path_right = str_repeat('TablixMembers/TablixMember/', ($cntr - 1));
                        $last_column_right = ($cntr == $total_cols) ? TRUE : FALSE;
                        #Add TablixHeader Info
                        $value_style = $this->get_style($column, 1, $last_column_hd, FALSE, TRUE);
                        $paragraph_style = $this->get_style($column, 2, $last_column_hd, FALSE, TRUE);
                        $container_style = $this->get_style($column, 3, $last_column_hd, FALSE, TRUE);
                        $tmp_cell = $this->get_tablix_cell($this->name . '_right_total_blank_caption' . $this->blank_index, $total_label, $this->avg_column_height, $value_style, $paragraph_style, $container_style);
                        $this->blank_index++;
                        $this->setval_from_path($new_tablix_member, $var_path_right . '/TablixHeader', $tmp_cell);
                        if ($last_column_right && $total_details > 1) {
                            $field_name = $this->name . '_' . $detail['column_var'] . '_Header_Right';
                            $value_style = $this->get_style($detail, 1, $last_column_hd, FALSE, TRUE);
                            $paragraph_style = $this->get_style($detail, 2, $last_column_hd, FALSE, TRUE);
                            $container_style = $this->get_style($detail, 3, $last_column_hd, FALSE, TRUE);
                            $tmp_cell = $this->get_tablix_cell($field_name, $this->_($detail['alias']), $this->avg_column_height, $value_style, $paragraph_style, $container_style);
                            $this->setval_from_path($new_tablix_member, $var_path_right . '/TablixMembers/TablixMember/TablixHeader', $tmp_cell);
                        }
                        $cntr++;
                    }
                    array_push($detail_header_stack, $new_tablix_member);
                    $dti++;
                }
                $tmp_rdl_partial['TablixMembers']['TablixMember'] = $detail_header_stack;
            }
            $this->arr_tablix['TablixColumnHierarchy'] = $tmp_rdl_partial;
        } else {#normal
            $tbx_size = sizeof($this->ttablix);
            for ($ti = 0; $ti < $tbx_size; $ti++) {
                array_push($tmp_rdl_partial, '');
            }
            $this->arr_tablix['TablixColumnHierarchy']['TablixMembers']['TablixMember'] = $tmp_rdl_partial;
        }
    }

    /**
     * Sets Row Hierarchy XML nodes
     */
    public function set_tablix_row_hierarchy() {
        $tmp_rdl_partial = array();
        if ($this->type == '2') {#crosstab
            $cli = 0;
            $total_rows = sizeof($this->rows);
            $bottom_summary_exists = ($this->cross_summary == 2 || $this->cross_summary == 4) ? TRUE : FALSE;
            foreach ($this->rows as $row) {
                #register column name for corner label
                array_push($this->row_ccaption, 'First(Fields!'.preg_replace("/[^\w]/","_",$row["alias"]).'.Value, "Dataset_header")');
                #prepare paths for Group, SortExpressions, TablixHeader, DataElementOutput
                $var_path = str_repeat('TablixMembers/TablixMember/0/', ($cli + 1));
                $this->remove_last_char($var_path);
                $var_path_second = $var_path;
                $this->remove_last_char($var_path_second);
                $var_path_second .= '/1';
                $last_column = ($total_rows == ($cli + 1)) ? TRUE : FALSE;

                #Add Group Info
                $this->setval_from_path($tmp_rdl_partial, $var_path . '/Group', array(
                    'GroupExpressions' => array(
                        'GroupExpression' => $this->get_field_name($row['column_var'])
                    ),
                    '@attributes' => array(
                        'Name' => $this->name . '_' . $row['column_var'] . '_Group'
                    )
                ));
                #Add Sort Info
                $sorting_column = ($row['sorting_column'] != '') ? $row['sorting_column'] : $row['column_var'];
                $sort_data = array(
                    'SortExpression' => array(
                        'Value' => $this->get_field_name($sorting_column)
                    )
                );
                if ($row['default_sort_direction'] == '2') {
                    $sort_data['SortExpression']['Direction'] = 'Descending';
                }
                $this->setval_from_path($tmp_rdl_partial, $var_path . '/SortExpressions', $sort_data);

                #Add TablixHeader Info
                $field_name = $this->get_field_name($row['column_var'], $row['render_as']);
                $value_style = $this->get_style($row, 1, $last_column, TRUE, TRUE);
                $paragraph_style = $this->get_style($row, 2, $last_column, FALSE, TRUE);
                $container_style = $this->get_style($row, 3, $last_column, FALSE, TRUE);
                $tmp_cell = $this->get_tablix_cell($this->name . '_' . $row['column_var'], $field_name, $this->avg_column_width, $value_style, $paragraph_style, $container_style);
                if ($row['render_as'] == '1') {
                    $this->setval_from_path($tmp_cell, 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/MarkupType', 'HTML');
                }
                $this->setval_from_path($tmp_rdl_partial, $var_path . '/TablixHeader', $tmp_cell);
                #add TablixMember placeholder
                if (!$last_column)
                    $this->setval_from_path($tmp_rdl_partial, $var_path . '/TablixMembers/TablixMember', NULL);
                #Add DEO Info
                $this->setval_from_path($tmp_rdl_partial, $var_path . '/DataElementOutput', 'Output');
                #Add KeepTogether Info; if not first row
                if ($cli > 0) {
                    $this->setval_from_path($tmp_rdl_partial, $var_path . '/KeepTogether', 'true');
                }

                if ($bottom_summary_exists && $row['subtotal'] == '1') {/* FROM HERE*/
                    $addon_blanks_cnt = $total_rows - ($cli + 1);
                    $last_column_hd = ($total_rows == ($cli + 1)) ? TRUE : FALSE;
                    if ($cli == 0) {
                        $total_label = $this->_('Total');
                        $row['h_font_style'] = '1,0,0';
                    } else {
                        $total_label = $this->_('Sub-Total');
                        $row['h_font_style'] = '1,1,0';
                    }
                    $value_style = $this->get_style($row, 1, $last_column_hd, FALSE, TRUE);
                    $paragraph_style = $this->get_style($row, 2, $last_column_hd, FALSE, TRUE);
                    $container_style = $this->get_style($row, 3, $last_column_hd, FALSE, TRUE);
                    $tmp_cell = $this->get_tablix_cell($this->name . '_' . $row['column_var'] . '_bottom_total', $total_label, $this->avg_column_width, $value_style, $paragraph_style, $container_style);
                    if ($row['render_as'] == '1') {
                        $this->setval_from_path($tmp_cell, 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/MarkupType', 'HTML');
                    }
                    $this->setval_from_path($tmp_rdl_partial, $var_path_second . '/TablixHeader', $tmp_cell);

                    for ($i = 1; $i <= $addon_blanks_cnt; $i++) {
                        $var_path_third = $var_path_second;
                        $var_path_third .= str_repeat('/TablixMembers/TablixMember/0/', $i);
                        $this->remove_last_char($var_path_third);
                        $last_column_blank = ($i == $addon_blanks_cnt) ? TRUE : FALSE;
                        $value_style = $this->get_style($row, 1, $last_column_blank, FALSE, TRUE);
                        $paragraph_style = $this->get_style($row, 2, $last_column_blank, FALSE, TRUE);
                        $container_style = $this->get_style($row, 3, $last_column_blank, FALSE, TRUE);
                        $tmp_cell = $this->get_tablix_cell($this->name . '_bottom_total_blank_' . $this->blank_index, '', $this->avg_column_width, $value_style, $paragraph_style, $container_style);
                        $this->blank_index++;
                        $this->setval_from_path($tmp_rdl_partial, $var_path_third . '/TablixHeader', $tmp_cell);
                    }
                    $this->setval_from_path($tmp_rdl_partial, $var_path_second . '/KeepWithGroup', 'Before');
                }

                $cli++;
            }
        } else { #normal
            $cli = 0;
            $total_rows = sizeof($this->groups);
            #if grouping exists
            if ($total_rows > 0) {
                $visibility_info_last = NULL;
                foreach ($this->groups as $row) {
                    #prepare paths for Group, SortExpressions, TablixHeader, DataElementOutput
                    $last_column = ($total_rows == ($cli + 1)) ? TRUE : FALSE;
                    if ($cli == 0) {
                        $data_key = 1;
                        $config_key = 0;
                        $key_member = 0;
                    } else {
                        if ($this->group_mode < 3) {
                            $data_key = 1;
                            $config_key = 0;
                            $key_member = 1;
                        } else {
                            $data_key = 0;
                            $config_key = 1;
                            $key_member = 0;
                        }
                    }
                    if ($cli == 0) {
                        $var_path = 'TablixMembers/TablixMember';
                        #first row need these tags in first member
                        $this->setval_from_path($tmp_rdl_partial, $var_path . '/0', array(
                            'Visibility' => NULL,
                            'KeepWithGroup' => 'After',
                            'RepeatOnNewPage' => 'true',
                            'KeepTogether' => 'true'
                        ));
                        if ($this->no_header == '1')
                            $this->setval_from_path($tmp_rdl_partial, $var_path . '/0/Visibility/Hidden', 'true');
                        else
                            unset($tmp_rdl_partial['TablixMembers']['TablixMember'][0]['Visibility']);
                    } else {
                        $var_path = "TablixMembers/TablixMember/1/" . str_repeat("TablixMembers/TablixMember/$key_member/", $cli);
                        #remove '/', '$key_member' and '/'
                        $this->remove_last_char($var_path, 3);
                        #register TablixMember childs so that 0 comes first; ksort not applicable, doing manually
                        $this->setval_from_path($tmp_rdl_partial, $var_path . "/0", NULL);
                        $this->setval_from_path($tmp_rdl_partial, $var_path . "/1", NULL);
                    }

                    #Add Group Info
                    $this->setval_from_path($tmp_rdl_partial, $var_path . "/$data_key/Group", array(
                        'GroupExpressions' => array(
                            'GroupExpression' => $this->get_field_name($row['column_var'], $row['render_as'])
                        ),
                        '@attributes' => array(
                            'Name' => $this->name . '_' . $row['column_var'] . '_Group'
                        )
                    ));

                    #Add Sort Info
                    $sorting_column = ($row['sorting_column'] != '') ? $row['sorting_column'] : $row['column_var'];
                    $this->setval_from_path($tmp_rdl_partial, $var_path . "/$data_key/SortExpressions", array(
                        'SortExpression' => array(
                            'Value' => $this->get_field_name($sorting_column, $row['render_as'])
                        )
                    ));

                    if ($cli > 0) {
                        #Add Keeping Options
                        $this->setval_from_path($tmp_rdl_partial, $var_path . "/$config_key", array(
                            'KeepWithGroup' => 'After',
                            'KeepTogether' => 'true'
                                )
                        );
                    }
                    #assign if there is value and its drilldown
                    if (is_array($visibility_info_last)) {
                        $this->setval_from_path($tmp_rdl_partial, $var_path . "/$data_key/Visibility", $visibility_info_last);
                    }

                    #if drilldown, calculate visibility tag which is usable in next iteration or Detail Collcation tags below if its last iteration
                    if ($this->group_mode < 3) {
                        $hidden = ($this->group_mode == 1) ? 'true' : 'false';
                        $visibility_info_last = array(
                            'Hidden' => $hidden,
                            'ToggleItem' => $this->name . '_' . $row['column_var']
                        );

                        if ($last_column && $this->summary_unnecessary) {
                            $visibility_info_last['Hidden'] = 'true';
                            unset($visibility_info_last['ToggleItem']);
                        }
                    }

                    if ($last_column) {
                        #Add Detail Collection Info
                        $detail = array(
                            array(
                                'Group' => array(
                                    'DataElementName' => 'Detail',
                                    '@attributes' => array(
                                        'Name' => $this->name . '_Details_Group'
                                    )),
                                'TablixMembers' => array('TablixMember' => NULL),
                                'Visibility' => NULL,
                                'DataElementName' => 'Detail_Collection',
                                'DataElementOutput' => 'Output',
                                'KeepTogether' => 'true'
                            ),
                            array(
                                'KeepWithGroup' => 'After',
                                'KeepTogether' => 'true'
                        ));
                        if ($this->group_mode < 3) {
                            array_push($detail, array_shift($detail));
                            $detail[1]['Visibility'] = $visibility_info_last;
                        } else {
                            if ($this->summary_unnecessary) {
                                $detail[0]['Visibility'] = array(
                                    'Hidden' => 'true'
                                );
                            } else {
                                unset($detail[0]['Visibility']);
                            }
                        }
                        $this->setval_from_path($tmp_rdl_partial, $var_path . "/$data_key/TablixMembers/TablixMember", $detail);
                    }
                    $cli++;
                }
                if ($this->cross_summary == '2') {
                    $this->setval_from_path($tmp_rdl_partial, '/TablixMembers/TablixMember/2/KeepWithGroup', 'Before');
                }
            } else { #else set default row hierarchy
                $tmp_rdl_partial = array(
                    'TablixMembers' => array(
                        'TablixMember' => array(
                            array(
                                'Visibility' => NULL,
                                'KeepWithGroup' => 'After',
                                'RepeatOnNewPage' => 'true',
                                'KeepTogether' => 'true'
                            ),
                            array(
                                'Group' => array(
                                    'DataElementName' => 'Detail',
                                    '@attributes' => array(
                                        'Name' => $this->name . '_Details_Group'
                                    )),
                                'TablixMembers' => array('TablixMember' => NULL),
                                'DataElementName' => 'Detail_Collection',
                                'DataElementOutput' => 'Output',
                                'KeepTogether' => 'true'
                            )
                        )
                    )
                );
                if ($this->cross_summary == '2') {
                    $this->setval_from_path($tmp_rdl_partial, '/TablixMembers/TablixMember/2/KeepWithGroup', 'Before');
                }
                if ($this->no_header == '1')
                    $this->setval_from_path($tmp_rdl_partial, '/TablixMembers/TablixMember/0/Visibility/Hidden', 'true');
                else
                    unset($tmp_rdl_partial['TablixMembers']['TablixMember'][0]['Visibility']);
            }
        }
        $this->arr_tablix['TablixRowHierarchy'] = $tmp_rdl_partial;
    }

    /**
     * Sets Row Hierarchy XML nodes
     * 
     */
    public function set_tablix_row() {
        $tmp_rdl_partial = array();
        if ($this->type == '2') {#crosstab
            $cross_keypair = array();
            $right_summary_exists = ($this->cross_summary == 3 || $this->cross_summary == 4) ? TRUE : FALSE;
            $bottom_summary_exists = ($this->cross_summary == 2 || $this->cross_summary == 4) ? TRUE : FALSE;
            $total_details = sizeof($this->details);
            $total_details += ($right_summary_exists) ? sizeof($this->rows) : 0;
            $cli = 0;
            foreach ($this->details as $row) {
                $cross_keypair[$cli] = $row['report_tablix_column_id'];
                $last_column = ($total_details == ($cli + 1)) ? TRUE : FALSE;
                $field_value = $this->get_agg_name($row['column_var'], $row['aggregation'], $row['render_as']);
                $value_style = $this->get_style($row, 1, $last_column, TRUE, FALSE, $field_value);
                $paragraph_style = $this->get_style($row, 2, $last_column, TRUE);
                $container_style = $this->get_style($row, 3, $last_column, TRUE);
                $tmp_cell = $this->get_tablix_cell($this->name . '_' . $row['column_var'], '=' . $field_value, NULL, $value_style, $paragraph_style, $container_style);
                if ($row['render_as'] == '1') {
                    $this->setval_from_path($tmp_cell, 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/MarkupType', 'HTML');
                }
                $tmp_cell['DataElementOutput'] = 'Output';
                array_push($tmp_rdl_partial, $tmp_cell);
                $cli++;
            }
            #if Cross Summary Right or Bottom+Right
            if ($right_summary_exists) {
                foreach ($this->details as $row) {
                    $last_column = ($total_details == ($cli + 1)) ? TRUE : FALSE; //echo '-'.$row['cross_summary_aggregation'];
                    $cross_keypair[$cli] = $row['report_tablix_column_id'];
                    if ($row['cross_summary_aggregation'] > 0) {
                        $field_name = $this->name . '_' . $row['column_var'] . '_foot_right';
                        $field_val = $this->get_agg_name($row['column_var'], $row['cross_summary_aggregation'], $row['render_as']);
                        $value_style = $this->get_style($row, 1, $last_column, TRUE, FALSE, $field_value);
                        $paragraph_style = $this->get_style($row, 2, $last_column, TRUE);
                        $container_style = $this->get_style($row, 3, $last_column, TRUE);
                        $field_val = '=' . $field_val;
                    } else {
                        $field_name = $this->name . '_' . $row['column_var'] . '_foot_right_' . $this->blank_index;
                        $field_val = '';
                        $this->blank_index++;
                        $value_style = $this->get_style($row, 1, $last_column);
                        $paragraph_style = $this->get_style($row, 2, $last_column);
                        $container_style = $this->get_style($row, 3, $last_column);
                    }
                    $tmp_cell = $this->get_tablix_cell($field_name, $field_val, NULL, $value_style, $paragraph_style, $container_style);
                    if ($row['render_as'] == '1') {
                        $this->setval_from_path($tmp_cell, 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/MarkupType', 'HTML');
                    }
                    $tmp_cell['DataElementOutput'] = 'Output';
                    array_push($tmp_rdl_partial, $tmp_cell);
                    $cli++;
                }
            }
            #if bottom row exists
            if ($bottom_summary_exists) {
                if (!is_array($this->arr_tablix['TablixBody']['TablixRows']['TablixRow']))
                    $this->arr_tablix['TablixBody']['TablixRows']['TablixRow'] = array();
                array_push($this->arr_tablix['TablixBody']['TablixRows']['TablixRow'], array(
                    'Height' => $this->avg_column_height,
                    'TablixCells' => array('TablixCell' => $tmp_rdl_partial)
                ));
                $row_size = sizeof($this->rows);
                $i = 1;
                              /*$sum_looper = $this->rows;
                //cut off first element so that last sub-total wont be shown
                {
                    array_shift($sum_looper);echo sizeof($sum_looper); 
                }*/          
                foreach ($this->rows as $row) {
                    if($row['subtotal'] != '1')
                        continue;
                    $last_column_sum = ($i == $row_size) ? TRUE : FALSE;
                    $tmp_rdl_partial_new = $tmp_rdl_partial;
                    foreach ($tmp_rdl_partial_new as $id => $cell) {
                        $this->setval_from_path($tmp_rdl_partial_new[$id], 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/Style/FontWeight', 'Bold');
                        if (!$last_column_sum)
                            $this->setval_from_path($tmp_rdl_partial_new[$id], 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/Style/FontStyle', 'Italic');
                        if ($this->details[$cross_keypair[$id]]['cross_summary_aggregation'] > 0) {
                            $agg_value = '=' . $this->get_agg_name($this->details[$cross_keypair[$id]]['column_var'], $this->details[$cross_keypair[$id]]['cross_summary_aggregation'], $this->details[$cross_keypair[$id]]['render_as']);
                        } else {
                            $agg_value = '';
                        }
                        $this->setval_from_path($tmp_rdl_partial_new[$id], 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/Value', $agg_value);
                        $this->setval_from_path($tmp_rdl_partial_new[$id], 'CellContents/Textbox/rd:DefaultName', $cell['CellContents']['Textbox']['rd:DefaultName'] . '_' . $i);
                        $this->setval_from_path($tmp_rdl_partial_new[$id], 'CellContents/Textbox/@attributes/Name', $cell['CellContents']['Textbox']['@attributes']['Name'] . '_' . $i);
                    }
                    array_push($this->arr_tablix['TablixBody']['TablixRows']['TablixRow'], array(
                        'Height' => $this->avg_column_height,
                        'TablixCells' => array('TablixCell' => $tmp_rdl_partial_new)
                    ));
                    $i++;
                }
            } else {
                $this->arr_tablix['TablixBody']['TablixRows']['TablixRow'] = array(
                    'Height' => $this->avg_column_height,
                    'TablixCells' => array('TablixCell' => $tmp_rdl_partial)
                );
            }
        } else {#normal
            #process header 
            $total_groups = sizeof($this->groups);
            $header_cell_stack = array();
            $header_rows = array();
            #if group exists then merge group and details to get header stack 
            if ($total_groups > 0) {
                $header_rows = array_merge($this->groups, $this->details);
            } else {
                $header_rows = $this->details;
            }

            #formulate header
            $hdi = 0;
			$sort_expressions = array();
            foreach ($header_rows as $column) {
                $last_column_hd = ($total_groups == ($hdi + 1)) ? TRUE : FALSE;
                $field_name = $this->name . '_' . $column['column_var'] . '_Header';
                $value_style = $this->get_style($column, 1, $last_column_hd, FALSE, TRUE);
                $paragraph_style = $this->get_style($column, 2, $last_column_hd, FALSE, TRUE);
                $container_style = $this->get_style($column, 3, $last_column_hd, FALSE, TRUE);
                $tmp_cell = $this->get_tablix_cell($field_name, $this->_($column['alias']), NULL, $value_style, $paragraph_style, $container_style, TRUE);
                
                #make it sort!!
                #Add SortExpressions Info executed by default
                if ($column['sorting_column'] != '') {
                    $sorting_column = ($column['sorting_column'] != '') ? $column['sorting_column'] : $column['column_var'];
                    if ($column['default_sort_direction'] == '2') {
                        $sort_direction = 'Descending';
                    } else {
                        $sort_direction = 'Ascending';
                    }
                    $sort_expressions[(int)$column['default_sort_order']] = array(
                                'Value' => $this->get_field_name($sorting_column),
                                'Direction' => $sort_direction
                        );
                }  

                if ($column['sortable'] == '1') {
                    $this->setval_from_path($tmp_cell, 'CellContents/Textbox/UserSort/SortExpression', $this->get_field_name($column['column_var'], $column['render_as']));
                    if (isset($this->groups[$column['report_tablix_column_id']]) && is_array($this->groups[$column['report_tablix_column_id']])) {
                        $this->setval_from_path($tmp_cell, 'CellContents/Textbox/UserSort/SortExpressionScope', ($this->name . '_' . $column['column_var'] . '_Group'));
                    }
                }
                array_push($header_cell_stack, $tmp_cell);
                $hdi++;
            }

            #Add SortExpressions Info executed by default
            ksort($sort_expressions, SORT_NUMERIC);
            for ($i = 1; $i <= count($sort_expressions); $i++) {
                $this->arr_tablix['SortExpressions']['SortExpression']= $sort_expressions;               
            }

            array_push($tmp_rdl_partial, array(
                'Height' => $this->avg_column_height,
                'TablixCells' => array('TablixCell' => $header_cell_stack)
            ));
            #detail rows; varies as per group_mode + grouping availability
            #Plain report or Block report
            if ($total_groups == 0 || $this->group_mode > 2) {
                $detail_cell_stack = array();
                $di = 0;
                foreach ($header_rows as $column) {
                    $last_column = ($total_groups == ($di + 1)) ? TRUE : FALSE;
                    $field_name = $this->name . '_' . $column['column_var'];
                    $value_style = $this->get_style($column, 1, $last_column, TRUE);
                    $paragraph_style = $this->get_style($column, 2, $last_column, TRUE);
                    $container_style = $this->get_style($column, 3, $last_column, TRUE);
                    $value = $this->get_field_name($column['column_var'], $column['render_as'], TRUE, TRUE);
                    $tmp_cell = $this->get_tablix_cell($field_name, $value, NULL, $value_style, $paragraph_style, $container_style);
                    if ($column['render_as'] == '1') {
                        $this->setval_from_path($tmp_cell, 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/MarkupType', 'HTML');
                    }
                    if ($this->group_mode == 4 && $total_groups > 0) {
                        $this->setval_from_path($tmp_cell, 'CellContents/Textbox/HideDuplicates', $this->dataset_name);
                    }
                    array_push($detail_cell_stack, $tmp_cell);
                    $di++;
                }
                array_push($tmp_rdl_partial, array(
                    'Height' => $this->avg_column_height,
                    'TablixCells' => array('TablixCell' => $detail_cell_stack)
                ));

                #if block mode then add subtotal rows
                if ($this->group_mode > 2) {
                    $rev_groups = array_reverse($this->groups, TRUE);
                    $header_count = sizeof($header_rows);
                    $ri = 0;
                    $first_encounter = TRUE;
                    foreach ($rev_groups as $rs => $rcolumn) {
                        $last_column = ($total_groups == ($ri + 1)) ? TRUE : FALSE;
                        $detail_cell_stack = array();
                        $hi = 0;
                        foreach ($header_rows as $column) {
                            $alias = '';
                            $apply_format = false;
                            $send_agg = false;
                            $last_column_inner = ($header_count == ($hi + 1)) ? TRUE : FALSE;
                            $field_name = $this->name . '_' . $column['column_var'] . '_sum' . $this->blank_index;
                            $this->blank_index++;
                            $markable_for_hide_duplicate = FALSE;
                            $deo_nooutput = FALSE;
                            if ($rs == $column['report_tablix_column_id']) {#intersection
                                if ($this->summary_unnecessary && $first_encounter) {
                                    $alias = $this->get_field_name($column['column_var'], $column['render_as'], FALSE, TRUE);
                                    $apply_format = TRUE;
                                    $send_agg = TRUE;
                                } else {
                                    $alias = $this->_('Sub-Total');
                                    //$column['font_style'] = ($last_column) ? '1,0,0' : '1,1,0';
                                    $column['font_style'] = '1,0,0';
                                    $deo_nooutput = TRUE;
                                    if ($this->border_style_buffer == '6')
                                        $this->border_style = 3;
                                }
                                $first_encounter = FALSE;
                            } else {
                                if (strlen($column['aggregation']) > 0) {
                                    $alias = $this->get_agg_name($column['column_var'], $column['aggregation'], $column['render_as']);
                                    if ($this->summary_unnecessary && $ri > 0)
                                        $column['font_style'] = '1,0,0';
                                    $apply_format = TRUE;
                                    $send_agg = TRUE;
                                } else if ($this->summary_unnecessary && $ri == 0) {
                                    $alias = $this->get_field_name($column['column_var'], $column['render_as'], FALSE, TRUE);
                                    $apply_format = TRUE;
                                    $send_agg = TRUE;
                                    $markable_for_hide_duplicate = TRUE;
                                }
                            }
                            $value_style = $this->get_style($column, 1, $last_column_inner, $apply_format, FALSE, (($send_agg) ? $alias : ''), FALSE);
                            $paragraph_style = $this->get_style($column, 2, $last_column_inner);
                            $container_style = $this->get_style($column, 3, $last_column_inner);
                            $prefix_alias = ($send_agg) ? '=' : '';
                            $tmp_cell = $this->get_tablix_cell($field_name, $prefix_alias . $alias, NULL, $value_style, $paragraph_style, $container_style, $deo_nooutput);
                            if ($markable_for_hide_duplicate && $this->group_mode == 4 && $total_groups > 0) {
                                $this->setval_from_path($tmp_cell, 'CellContents/Textbox/HideDuplicates', $this->dataset_name);
                            }
                            array_push($detail_cell_stack, $tmp_cell);
                            //$zi++;
                        }
                        $this->reset_border_style();
                        $hi++;
                        array_push($tmp_rdl_partial, array(
                            'Height' => $this->avg_column_height,
                            'TablixCells' => array('TablixCell' => $detail_cell_stack)
                        ));
                        $ri++;
                    }
                }
            } else {#drilldown expanded / collapsed
                $header_count = sizeof($header_rows);
                $ri = 0;
                foreach ($this->groups as $rs => $rcolumn) {
                    $last_column = ($total_groups == ($ri + 1)) ? TRUE : FALSE;
                    $detail_cell_stack = array();
                    $hi = 0;
                    foreach ($header_rows as $column) {
                        $alias = '';
                        $apply_format = false;
                        $set_toggle = false;
                        $send_agg = false;
                        $last_column_inner = ($header_count == ($hi + 1)) ? TRUE : FALSE;
                        if ($rcolumn['report_tablix_column_id'] == $column['report_tablix_column_id']) {#intersection
                            $column['font_style'] = ($ri == 0) ? '1,0,0' : '1,1,0';
                            $alias = $this->get_field_name($column['column_var'], $column['render_as'], TRUE, TRUE);
                            $field_name = $this->name . '_' . $column['column_var'];
                            $apply_format = TRUE;
                            $set_toggle = TRUE;
                        } else {
                            $this->blank_index++;
                            $field_name = $this->name . '_' . $column['column_var'] . '_agg' . $this->blank_index;
                            if (strlen($column['aggregation']) > 0) {
                                $alias = $this->get_agg_name($column['column_var'], $column['aggregation'], $column['render_as']);
                                //inherit group item's style in the line
                                //$column['font'] = $rcolumn['font'];
                                //$column['font_size'] = $rcolumn['font_size'];
                                //$column['text_color'] = $rcolumn['text_color'];
                                //$column['background'] = $rcolumn['background'];
                                //$column['font_style'] = ($ri == 0) ? '1,0,0' : '1,1,0';
                                $column['font_style'] = '1,0,0';
                                $apply_format = TRUE;
                                $send_agg = TRUE;
                            }
                        }
                        $value_style = $this->get_style($column, 1, $last_column_inner, $apply_format, FALSE, (($send_agg) ? $alias : ''), FALSE);
                        $paragraph_style = $this->get_style($column, 2, $last_column_inner);
                        $container_style = $this->get_style($column, 3, $last_column_inner);
                        $prefix_alias = ($send_agg) ? '=' : '';
                        $tmp_cell = $this->get_tablix_cell($field_name, $prefix_alias . $alias, NULL, $value_style, $paragraph_style, $container_style);
                        if ($this->group_mode == 2 && $set_toggle) {#expanded drilldown must have image toggled
                            $this->setval_from_path($tmp_cell, 'CellContents/Textbox/ToggleImage/InitialState', 'true');
                        }
                        if ($column['render_as'] == '1') {
                            $this->setval_from_path($tmp_cell, 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/MarkupType', 'HTML');
                        }
                        array_push($detail_cell_stack, $tmp_cell);
                    }
                    $hi++;
                    array_push($tmp_rdl_partial, array(
                        'Height' => $this->avg_column_height,
                        'TablixCells' => array('TablixCell' => $detail_cell_stack)
                    ));
                    $ri++;
                }
                #now detail row of drilldown
                $detail_cell_stack = array();
                $group_count = sizeof($this->groups);
                $dti = 0;
                foreach ($this->groups as $column) {
                    $last_column = ($group_count == ($dti + 1)) ? TRUE : FALSE;
                    $this->blank_index++;
                    $field_name = $this->name . '_' . $column['column_var'] . '_detailblank' . $this->blank_index;
                    $value_style = $this->get_style($column, 1, $last_column);
                    $paragraph_style = $this->get_style($column, 2, $last_column);
                    $container_style = $this->get_style($column, 3, $last_column);
                    $tmp_cell = $this->get_tablix_cell($field_name, '', NULL, $value_style, $paragraph_style, $container_style);
                    array_push($detail_cell_stack, $tmp_cell);
                    $dti++;
                }
                $dti = 0;
                $detail_count = sizeof($this->details);
                foreach ($this->details as $column) {
                    $last_column_inner = ($detail_count == ($dti + 1)) ? TRUE : FALSE;
                    $value_style = $this->get_style($column, 1, $last_column_inner, TRUE);
                    $paragraph_style = $this->get_style($column, 2, $last_column_inner, TRUE);
                    $container_style = $this->get_style($column, 3, $last_column_inner, TRUE);
                    $alias = $this->get_field_name($column['column_var'], $column['render_as'], TRUE, TRUE);
                    $field_name = $this->name . '_' . $column['column_var'];
                    $tmp_cell = $this->get_tablix_cell($field_name, $alias, NULL, $value_style, $paragraph_style, $container_style);
                    if ($column['render_as'] == '1') {
                        $this->setval_from_path($tmp_cell, 'CellContents/Textbox/Paragraphs/Paragraph/TextRuns/TextRun/MarkupType', 'HTML');
                    }
                    array_push($detail_cell_stack, $tmp_cell);
                    $dti++;
                }
                array_push($tmp_rdl_partial, array(
                    'Height' => $this->avg_column_height,
                    'TablixCells' => array('TablixCell' => $detail_cell_stack)
                ));
            }
            #add total row at endline, if required
            if ($this->cross_summary == '2') {
                $detail_cell_stack = array();
                $ccnt = 0;
                foreach ($header_rows as $column) {
                    $alias = '';
                    $apply_format = false;
                    $send_agg = false;
                    $field_name = $this->name . '_' . $column['column_var'] . '_sum_btm' . $this->blank_index;
                    $this->blank_index++;
                    $deo_sum_nooutput = FALSE;
                    if ($ccnt > 0 && $column['cross_summary_aggregation'] > 0 && $column['placement'] == '1') {
                        $alias = $this->get_agg_name($column['column_var'], $column['cross_summary_aggregation'], $column['render_as']);
                        $column['font_style'] = '1,0,0';
                        $apply_format = TRUE;
                        $send_agg = TRUE;
                    }
                    #place label Total
                    if ($ccnt == 0 && $total_groups > 0) {
                        $alias = $this->_('Total');
                        $deo_sum_nooutput = TRUE;
                        $column['font_style'] = '1,0,0';
                        $apply_format = TRUE;
                        $send_agg = false;
                        if ($this->border_style_buffer == '6')
                            $this->border_style = 3;
                    } elseif ($total_groups == 0 && $column['mark_for_total'] == '1') {
                        $alias = $this->_('Total');
                        $deo_sum_nooutput = TRUE;
                        $column['font_style'] = '1,0,0';
                        $apply_format = TRUE;
                        $send_agg = false;
                        if ($this->border_style_buffer == '6')
                            $this->border_style = 3;
                    }
                    $value_style = $this->get_style($column, 1, TRUE, $apply_format, FALSE, (($send_agg) ? $alias : ''), FALSE);
                    $paragraph_style = $this->get_style($column, 2, TRUE);
                    $container_style = $this->get_style($column, 3, TRUE);
                    $prefix_alias = ($send_agg) ? '=' : '';
                    $tmp_cell = $this->get_tablix_cell($field_name, $prefix_alias . $alias, NULL, $value_style, $paragraph_style, $container_style, $deo_sum_nooutput);
                    array_push($detail_cell_stack, $tmp_cell);
                    $ccnt++;
                }
                $this->reset_border_style();
                array_push($tmp_rdl_partial, array(
                    'Height' => $this->avg_column_height,
                    'TablixCells' => array('TablixCell' => $detail_cell_stack)
                ));
            }
            $this->arr_tablix['TablixBody']['TablixRows']['TablixRow'] = $tmp_rdl_partial;
        }
    }

}