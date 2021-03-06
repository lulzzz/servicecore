﻿/**
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

namespace MARC.HI.EHRS.SVC.Auditing.Data
{
    /// <summary>
    /// Audit source type
    /// </summary>
    [XmlType(nameof(AuditSourceType), Namespace = "http://marc-hi.ca/svc/audit")]
    public enum AuditSourceType
    {
        [XmlEnum("ui")]
        EndUserInterface = 1,
        [XmlEnum("dev")]
        DeviceOrInstrument = 2,
        [XmlEnum("web")]
        WebServerProcess = 3,
        [XmlEnum("app")]
        ApplicationServerProcess = 4,
        [XmlEnum("db")]
        DatabaseServerProcess = 5,
        [XmlEnum("sec")]
        SecurityServerProcess = 6,
        [XmlEnum("isol1")]
        ISOLevel1or3Component = 7,
        [XmlEnum("isol4")]
        ISOLevel4or6Software = 8,
        [XmlEnum("other")]
        Other = 9
    }
}
