﻿/* 
 * Copyright 2008-2011 Mohawk College of Applied Arts and Technology
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
 * User: Justin Fyfe
 * Date: 08-24-2011
 */
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Reflection;
using System.ComponentModel;

namespace MARC.HI.EHRS.SVC.Auditing.Atna
{
    /// <summary>
    /// Represents codified data
    /// </summary>
    public class CodeValue<T>
    {
        // Code Syste,
        private string m_codeSystem = String.Empty;
        private string m_description = String.Empty;

        /// <summary>
        /// The OID of the code system from which the code is pulled
        /// </summary>
        [XmlAttribute("codeSystemName")]
        public string CodeSystem
        {
            get
            {
                if (!String.IsNullOrEmpty(this.m_codeSystem))
                    return this.m_codeSystem;

                // Enum type?
                if (typeof(T).IsEnum)
                {
                    FieldInfo fi = typeof(T).GetField(this.Code.ToString());
                    object[] category = fi.GetCustomAttributes(typeof(CategoryAttribute), false);
                    if (category.Length > 0)
                        return (category[0] as CategoryAttribute).Category;
                }
                return null;
            }
            set
            {
                m_codeSystem = value;
            }
        }
        /// <summary>
        /// The codified data
        /// </summary>
        [XmlAttribute("code")]
        public T Code { get; set; }
        /// <summary>
        /// The english display name for the code
        /// </summary>
        [XmlAttribute("displayName")]
        public string DisplayName
        {
            get
            {
                if (!String.IsNullOrEmpty(this.m_description))
                    return this.m_description;

                // Enum type?
                if (typeof(T).IsEnum)
                {
                    return this.Code.ToString();
                }
                return null;
            }
            set
            {
                m_description = value;
            }
        }
        /// <summary>
        /// Identifies the code or concept in the original system 
        /// </summary>
        [XmlAttribute("originalText")]
        public string OriginalText { get; set; }

        /// <summary>
        /// Default ctor
        /// </summary>
        public CodeValue() { }

        /// <summary>
        /// Create a new instance of the audit code with the specified parameters
        /// </summary>
        /// <param name="code">The code</param>
        public CodeValue(T code)
            : this()
        { this.Code = code; }

        /// <summary>
        /// Create a new instance of the audit code with the specified parameters
        /// </summary>
        /// <param name="code">The code</param>
        /// <param name="codeSystem">The OID of the system from wich the code was drawn</param>
        public CodeValue(T code, string codeSystem)
            : this(code)
        { this.CodeSystem = codeSystem; }

    }
}
