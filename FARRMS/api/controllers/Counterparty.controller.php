<?php

class CounterpartyController extends REST {
    public function index() {
        $results = Counterparty::find();
        $this->response($this->json($results), 200);
    }

    public function get($templateId) {
        $results = Counterparty::findOne($templateId);
        $this->response($this->json($results[0]), 200);
    }
    
    public function getDependentCounterparty($template_id) {
        $results = Counterparty::findDependentCounterparty($template_id);
        $this->response($this->json($results), 200);
    }
}
