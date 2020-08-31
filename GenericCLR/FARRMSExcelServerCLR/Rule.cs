using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace FARRMSExcelServerCLR
{
    public class Rule
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string IxpRuleHash { get; set; }
        public virtual List<string> RuleColumnList { get; set; }
    }
}
