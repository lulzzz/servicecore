﻿/**
 * Copyright 2012-2012 Mohawk College of Applied Arts and Technology
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
using System.Configuration;
using System.Xml;
using System.Net;
using System.Reflection;

namespace MARC.HI.EHRS.SVC.Auditing.Atna.Configuration
{
    /// <summary>
    /// Identifies the configuration for the ATNA auditing
    /// </summary>
    public class ConfigurationSectionHandler : IConfigurationSectionHandler
    {
        #region IConfigurationSectionHandler Members

        /// <summary>
        /// Configuration Section Handler
        /// </summary>
        public object Create(object parent, object configContext, System.Xml.XmlNode section)
        {
            var retVal = new AuditConfiguration();
            XmlElement auditTargetNode = section.SelectSingleNode("./*[local-name() = 'destination']") as XmlElement;

            if (auditTargetNode == null)
                throw new ConfigurationErrorsException("Missing the 'destination' element in the ATNA configuration", section);

            if (section.Attributes["messagePublisher"] == null)
                throw new ConfigurationErrorsException("You must specify a message publisher interface to use for sending audit messages", section);

            // Create the message handler
            Type auditType = Type.GetType(section.Attributes["messagePublisher"].Value);
            if (auditType == null)
                throw new ConfigurationErrorsException(String.Format("Can't find the type described by '{0}'", section.Attributes["messagePublisher"].Value), section);
            ConstructorInfo ci = auditType.GetConstructor(new Type[] { typeof(IPEndPoint) });
            if (ci == null)
                throw new ConfigurationErrorsException(String.Format("Type '{0}' does not have a constructor expecting a parameter of type System.Net.IPEndPoint", auditType.FullName));

            if (auditTargetNode.Attributes["endpoint"] == null)
                throw new ConfigurationErrorsException("The URI element in the auditTarget element is missing", section);
            

            // Parse IP Address
            string ipAddress = auditTargetNode.Attributes["endpoint"].Value;
            int port = 512;
            if(ipAddress.Contains(':'))
            {
                port = Int32.Parse(ipAddress.Substring(ipAddress.IndexOf(":") + 1));
                ipAddress = ipAddress.Substring(0, ipAddress.IndexOf(":"));
            }

            // Create the audit target
            retVal.AuditTarget = new IPEndPoint(IPAddress.Parse(ipAddress), port);

            // Create the publisher
            retVal.MessagePublisher = ci.Invoke(new object[] { retVal.AuditTarget }) as IMessagePublisher;
            
            return retVal;
        }

        #endregion
    }
}
