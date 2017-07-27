﻿/*
 * Copyright 2012-2013 Mohawk College of Applied Arts and Technology
 * 
 * Licensed under the Apache License, Version 2.0 (the "License"); you 
 * may not use this file except in compliance with the License. You may 
 * obtain a copy of the License at 
 * 
 * http://www.apache.org/licenses/LICENSE-2.0 
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the 
 * License for the specific language governing permissions and limitations under 
 * the License.
 * 
 * User: fyfej
 * Date: 7-5-2012
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace MARC.HI.EHRS.SVC.Localization
{
    /// <summary>
    /// Localization data
    /// </summary>
    [XmlRoot("locale", Namespace = "urn:marc-hi:ca/localization")]
    [XmlType("locale", Namespace = "urn:marc-hi:ca/localization")]
    public class LocalizationData
    {

        /// <summary>
        /// Localization name
        /// </summary>
        [XmlAttribute("name")]
        public String LocaleName { get; set; }

        /// <summary>
        /// String name/value pairs
        /// </summary>
        [XmlElement("string")]
        public List<StringData> Strings { get; set; }
    }

    /// <summary>
    /// String data
    /// </summary>
    [XmlType("stringData", Namespace = "urn:marc-hi:ca/localization")]
    public class StringData
    {
        /// <summary>
        /// Name of the string
        /// </summary>
        [XmlAttribute("name")]
        public string Name { get; set; }
        /// <summary>
        /// Value of the string
        /// </summary>
        [XmlText]
        public string Value { get; set; }
    }


}
