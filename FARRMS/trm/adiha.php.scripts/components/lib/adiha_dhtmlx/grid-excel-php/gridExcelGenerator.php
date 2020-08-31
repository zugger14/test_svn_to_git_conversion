<?php
/**
 * GridExcelGenerator class
 * 
 * @copyright Pioneer Solutions
 */

class GridExcelGenerator {
	public $headerHeight = 30;
	public $rowHeight = 20;

	public $fontFamily = 'Helvetica';
	public $headerFontSize = 9;
	public $gridFontSize = 9;
	public $widthProportionality = 6;

	public $strip_tags = false;

	public $bgColor = 'D1E5FE';
	public $lineColor = 'A4BED4';
	public $scaleOneColor = 'FFFFFF';
	public $scaleTwoColor = 'E3EFFF';
	public $textColor = '000000';

	public $headerLinesNum = 0;
	public $headerFileName = false;
	public $outputType = 'Excel2007'; // Excel2003 or Excel2007 or Csv

	public $creator = 'Pioneer Solutions Pvt. Ltd.';
	public $lastModifiedBy = 'Pioneer Solutions Pvt. Ltd.';
	public $title = 'Data';
	public $subject = '';
	public $dsc = '';
	public $keywords = '';
	public $category = '';
	public $without_header = false;
	
	private $footerColumns = Array();
	private $columns = Array();
	private $rows = Array();
	private $profile;
	private $coll_options = Array();
	private $hiddenCols = Array();
	
	/**
	 * Prints the grid into excel file
	 * 
	 * @param   XML  	$xml       Data xml
	 * @param   String  $filename  File name
	 */
	public function printGrid($xml, $filename) {
		$this->headerParse($xml->head);
		$this->footerParse($xml->foot);
		$this->mainParse($xml);
		$this->collectionsParse($xml->coll_options);
		$this->rowsParse($xml->row);
		$this->printGridExcel($filename);
	}

	/**
	 * Sets excel profile
	 */
	private function setProfile() {
		switch ($this->profile) {
			case 'color':
				$this->bgColor = 'D1E5FE';
				$this->lineColor = 'A4BED4';
				$this->scaleOneColor = 'FFFFFF';
				$this->scaleTwoColor = 'E3EFFF';
				$this->textColor = '000000';
				break;
			case 'gray':
				$this->bgColor = 'E3E3E3';
				$this->lineColor = 'B8B8B8';
				$this->scaleOneColor = 'FFFFFF';
				$this->scaleTwoColor = 'EDEDED';
				$this->textColor = '000000';
				break;
			case 'bw':
				$this->bgColor = 'FFFFFF';
				$this->lineColor = '000000';
				$this->scaleOneColor = 'FFFFFF';
				$this->scaleTwoColor = 'FFFFFF';
				$this->textColor = '000000';
				break;
			default:
				break;
		}
	}

	/**
	 * Parses main information from xml and sets profile
	 *
	 * @param   XML  $xml  Data XML
	 */
	private function mainParse($xml) {
		$this->profile = (string) $xml->attributes()->profile;
		$this->setProfile();
		if (!file_exists($this->headerFileName)) {
			$this->headerLinesNum = 0;
			$this->headerFileName = false;
		}
		if (isset($xml->attributes()->without_header)) {
			$this->without_header = true;
		}
	}

	/**
	 * Parse headers data
	 *
	 * @param   XML  $header  Header XML
	 */
	private function headerParse($header) {
		if (isset($header->column)) {
			$header_columns = Array($header->column);
		} else {
			$header_columns = $header->columns;
		}

		$i = 0;
		foreach ($header_columns as $row) {
			$this->columns[$i] = Array();
			$k = 0;
			foreach ($row as $column) {
				$columnArr = Array();
				$columnArr['hidden'] = ($column->attributes()->hidden == 'true');
				if ($columnArr['hidden']) {
					$this->hiddenCols[$k] = true;
					$k++;
					continue;
				}
				$columnArr['text'] = $this->strip(trim((string) $column));
				$columnArr['width'] = trim((string) $column->attributes()->width);
				$columnArr['type'] = trim((string) $column->attributes()->type);
				$columnArr['align'] = trim((string) $column->attributes()->align);
				if (isset($column->attributes()->colspan)) {
					$columnArr['colspan'] = (int) $column->attributes()->colspan;
				}
				if (isset($column->attributes()->rowspan)) {
					$columnArr['rowspan'] = (int) $column->attributes()->rowspan;
				}
				if ($i == 0) {
					$columnArr['excel_type'] = (isset($column->attributes()->excel_type)) ? trim((String) $column->attributes()->excel_type) : "";
				}
				$this->columns[$i][] = $columnArr;
				$k++;
			}
			$i++;
		}
	}

	/**
	 * Parses columns data
	 *
	 * @param   Array  $coll_options  Columns
	 */
	private function collectionsParse($coll_options) {
		for ($i = 0; $i < count($coll_options); $i++) {
			$index = (int) $coll_options[$i]->attributes()->for;
			$this->coll_options[$index] = Array();
			for ($j = 0; $j < count($coll_options[$i]->item); $j++) {
				$item = $coll_options[$i]->item[$j];
				$value = (string) $item->attributes()->value;
				$label = (string) $item->attributes()->label;
				$this->coll_options[$index][$value] = $label;
			}
		}
	}

	/**
	 * Parse footers data
	 *
	 * @param   XML  $footer  Footer XML
	 */
	private function footerParse($footer) {
		if (isset($footer->columns)) {
			$footer_columns = $footer->columns;
			$i = 0;
			foreach ($footer_columns as $row) {
				$this->footerColumns[$i] = Array();
				foreach ($row as $column) {
					$columnArr = Array();
					$columnArr['text'] = $this->strip(trim((string) $column));
					$columnArr['width'] = trim((string) $column->attributes()->width);
					$columnArr['type'] = trim((string) $column->attributes()->type);
					$columnArr['align'] = trim((string) $column->attributes()->align);
					if (isset($column->attributes()->colspan)) {
						$columnArr['colspan'] = (int) $column->attributes()->colspan;
					}
					if (isset($column->attributes()->rowspan)) {
						$columnArr['rowspan'] = (int) $column->attributes()->rowspan;
					}
					$this->footerColumns[$i][] = $columnArr;
				}
				$i++;
			}
		}
	}

	/**
	 * Parse rows data
	 *
	 * @param   XML  $rows  Rows XML
	 */
	private function rowsParse($rows) {
		$i = 0;
		foreach ($rows as $row) {
			$rowArr = Array();
			$cells = $row->cell;
			$k = 0;
			foreach ($cells as $cell) {
				if (isset($this->hiddenCols[$k])) {
					$k++;
					continue;
				}
				$cell_p = Array();
				if (isset($this->coll_options[$k][trim((string) $cell)])) {
					$cell_p['text'] = $this->strip($this->coll_options[$k][trim((string) $cell)]);
				} else {
					$cell_p['text'] = $this->strip(trim((string) $cell));
				}
				
				if (isset($cell->attributes()->bgColor)) {
					$cell_p['bg'] = (string) $cell->attributes()->bgColor;
				} else {
					$color = ($i%2 == 0) ? $this->scaleOneColor : $this->scaleTwoColor;
					$cell_p['bg'] = $color;
				}
				if (isset($cell->attributes()->textColor)) {
					$cell_p['textColor'] = (string) $cell->attributes()->textColor;
				} else {
					$cell_p['textColor'] = $this->textColor;
				}
				$cell_p['bold'] = (isset($cell->attributes()->bold) && $cell->attributes()->bold == 'bold');
				$cell_p['italic'] = (isset($cell->attributes()->italic) && $cell->attributes()->italic == 'italic');
				$cell_p['align'] = isset($cell->attributes()->align) ? $cell->attributes()->align : false;
				$rowArr[] = $cell_p;
				$k++;
			}
			$this->rows[] = $rowArr;
			$i++;
		}
	}

	/**
	 * Print grid data to excel file
	 *
	 * @param   String  $filename  File name
	 */
	public function printGridExcel($filename) {
		$this->wrapper = new GridExcelWrapper();
		$this->wrapper->createXLS($this->headerFileName, $this->headerLinesNum, $this->creator, $this->lastModifiedBy, $this->title, $this->subject, $this->dsc, $this->keywords, $this->category);
		$this->wrapper->headerPrint($this->columns, $this->widthProportionality, $this->headerHeight, $this->textColor, $this->bgColor, $this->lineColor, $this->headerFontSize, $this->fontFamily, $this->without_header);
		for ($i = 0; $i < count($this->rows); $i++) {
			$this->wrapper->rowPrint($this->rows[$i], $this->rowHeight, $this->lineColor, $this->gridFontSize, $this->fontFamily);
		}
		$this->wrapper->footerPrint($this->footerColumns, $this->headerHeight, $this->textColor, $this->bgColor, $this->lineColor, $this->headerFontSize, $this->fontFamily);
		$this->wrapper->outXLS($this->title, $this->outputType, $filename);
	}

	/**
	 * Strips tags
	 *
	 * @param   String  $param  Values
	 *
	 * @return  String          Stripped values
	 */
	private function strip($param) {
		if ($this->strip_tags) {
			$param = strip_tags($param);
		}
		return $param;
	}
}
?>