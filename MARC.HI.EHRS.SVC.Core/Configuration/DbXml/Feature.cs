﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Serialization;

namespace MARC.HI.EHRS.SVC.Core.Configuration.DbXml
{
    [XmlType(Namespace = "http://marc-hi.ca/plugin/dbxml", TypeName = "Feature")]
    [XmlRoot(Namespace = "http://marc-hi.ca/plugin/dbxml", ElementName = "Feature")]
    public class Feature : DbXmlBase
    {
        /// <summary>
        /// The version of the feature
        /// </summary>
        [XmlAttribute("version")]
        public String Version { get; set; }

        /// <summary>
        /// The list of commands used to install the feature
        /// </summary>
        [XmlArray("install")]
        [XmlArrayItem("sqlCommand", Type = typeof(SqlCommand))]
        [XmlArrayItem("sqlScript", Type = typeof(SqlScript))]
        public List<Command> Install { get; set; }

        /// <summary>
        /// The list of commands used to install the feature
        /// </summary>
        [XmlArray("uninstall")]
        [XmlArrayItem("sqlCommand", Type = typeof(SqlCommand))]
        [XmlArrayItem("sqlScript", Type=typeof(SqlScript))]
        public List<Command> UnInstall { get; set; }

    }
}
