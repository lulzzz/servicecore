﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MARC.HI.EHRS.SVC.Core.Services.Policy
{

    /// <summary>
    /// Represents a policy
    /// </summary>
    public interface IPolicy
    {
        /// <summary>
        /// Gets the unique object identifier for the policy
        /// </summary>
        String Oid { get; }

        /// <summary>
        /// Gets the name of the policy
        /// </summary>
        String Name { get; }

        /// <summary>
        /// True whether the policy can be overridden
        /// </summary>
        bool CanOverride { get; }

        /// <summary>
        /// True if the policy is actively enforced
        /// </summary>
        bool IsActive { get; }
    }

    /// <summary>
    /// Represents a policy instance
    /// </summary>
    public interface IPolicyInstance
    {
        /// <summary>
        /// The policy 
        /// </summary>
        IPolicy Policy { get; }
        /// <summary>
        /// The rule
        /// </summary>
        PolicyDecisionOutcomeType Rule { get; }
        /// <summary>
        /// The securable
        /// </summary>
        Object Securable { get; }
    }
    /// <summary>
    /// Represents a policy information service
    /// </summary>
    public interface IPolicyInformationService
    {

        /// <summary>
        /// Gets a list of all policies
        /// </summary>
        IEnumerable<IPolicy> GetPolicies();

        /// <summary>
        /// Get active policies for the specified securable
        /// </summary>
        /// <param name="securable">The object for which policies should be retrieved. Examples: A role, a user, a document, etc.</param>
        IEnumerable<IPolicyInstance> GetActivePolicies(Object securable);

        /// <summary>
        /// Gets the policy by policy OID
        /// </summary>
        IPolicy GetPolicy(String policyOid);
               
    }
}
