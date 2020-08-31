<?php
/**
  *
  * Copyright (c) 2009, Persistent Systems Limited
  *
  * Redistribution and use, with or without modification, are permitted
  *  provided that the following  conditions are met:
  *   - Redistributions of source code must retain the above copyright notice,
  *     this list of conditions and the following disclaimer.
  *   - Neither the name of Persistent Systems Limited nor the names of its contributors
  *     may be used to endorse or promote products derived from this software
  *     without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
  * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
  * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */

/**
  *
  * class RenderAsCSV
  */
class RenderAsCSV extends RenderBaseType implements IRenderType
{
    /**     
     * @xml : Encoding
     */
    public $Encoding;

   /**    
    * @xml :ExcelMode
    */
    public $ExcelMode;

    /**     
     * @xml : FieldDelimiter
     */
    public $FieldDelimiter;

    /**     
     * @xml : FileExtension
     */
    public $FileExtension;

    /**     
     * @xml : NoHeader
     */
    public $NoHeader;

    /**     
     * @xml : Qualifier
     */
     public $Qualifier;

    /**     
     * @xml : RecordDelimiter
     */
     public $RecordDelimiter;

     /**     
     * @xml : SuppressLineBreaks
     */
    public $SuppressLineBreaks;

    /**     
     * @xml : UseFormattedValues
     */
    public $UseFormattedValues;

    public function RenderAsCSV()
    {
        $this->Encoding = null;
        $this->ExcelMode = null;
        $this->FieldDelimiter = null;
        $this->FileExtension = null;
        $this->NoHeader = null;
        $this->Qualifier = null;
        $this->RecordDelimiter = null;
        $this->SuppressLineBreaks = null;
        $this->UseFormattedValues = null;
    }

    public function GetFormat()
    {
        return "CSV";
    }

    public function GetDevInfoXML()
    {
        return parent::GetDevInfoXML_Base($this);
    }
}
?>
