<?php

class DataImportController extends REST {	
    public function DataImport($body) {
		$import_function = $body->import_function;
		$import_type = $body->import_type;
		$import_data = $body->import_data;
		$import_data = str_replace("&", "&amp;", str_replace("'", "''", $import_data));

		$results = (new DataImport)->import($import_data, $import_function, $import_type);
		$this->response($this->json($results));
	 }
    
    public function GetImportFunctionList() {
        $results = DataImport::getImportFunctionList();
		$this->response($this->json($results));
    }
    
    public function GetImportFormat($body) {
        $import_function = $body->import_function;
        $results = DataImport::getImportFormat($import_function);
		$this->response($this->json($results));
    }
	
	public function GetImportStatus($body) {
		$import_process = $body->import_process;
        $results = DataImport::getImportStatus($import_process);
		$this->response($this->json($results));
    }
    
    /*
     * To run import rule sequence from Excel
     * $import_data format:
        [  
            {  
                "sequence_number":"1",
                "import_rule_id":"12617",
                "import_source":"21400",
                "import_file_name":"FirstTraderDefinition.csv"
            },
            {  
                "sequence_number":"2",
                "import_rule_id":"12715",
                "import_source":"21400",
                "import_file_name":"SecondPriceCurveDefinition.csv"
            }
        ]
     */
    public function DataImportCollection($body) {
        $results = DataImport::importCollection($body);
        $this->response($this->json($results));
    }
}
