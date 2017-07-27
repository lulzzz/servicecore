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

using System.Xml.Serialization;

namespace MARC.HI.EHRS.SVC.Auditing.Data
{
	/// <summary>
	/// Represents the type of network access point.
	/// </summary>
	[XmlType(nameof(NetworkAccessPointType), Namespace = "http://marc-hi.ca/svc/audit")]
	public enum NetworkAccessPointType
	{
		/// <summary>
		/// Represents an identifier which is a machine name.
		/// </summary>
		[XmlEnum("name")]
		MachineName = 0x1,

		/// <summary>
		/// Represents an identifier which is an IP address.
		/// </summary>
		[XmlEnum("ip")]
		IPAddress = 0x2,

		/// <summary>
		/// Represents an identifier which is a telephone number.
		/// </summary>
		[XmlEnum("tel")]
		TelephoneNumber = 0x3
	}
}