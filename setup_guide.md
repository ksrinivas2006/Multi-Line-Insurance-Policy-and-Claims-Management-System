# Multi-Line Insurance Claim Triage & Automated Assignment

Salesforce Flow + Agentforce project that retrieves a customer's latest claim,
validates the linked policy, scores the claim's risk, creates a review task for
high-risk claims, and replies through an Agentforce subagent.

## 1. Prerequisites & Custom Object Setup
1. **Custom Object:** `Insurance_Policy__c`
   - `Customer__c` (Lookup → Account)
   - `Policy_Type__c` (Picklist: Health, Auto, Life, Property)
   - `Coverage_Amount__c` (Currency)
   - `Policy_Status__c` (Picklist: Active, Expired, Suspended)
   - `Policy_End_Date__c` (Date)
2. **Custom Object:** `Insurance_Claim__c`
   - `Customer__c` (Lookup → Account)
   - `Policy__c` (Lookup → Insurance_Policy__c)
   - `Claim_Amount__c` (Currency)
   - `Claim_Description__c` (Long Text Area)
3. **Standard Objects:** `Account`, `Task`, `User`

## 2. Flow Variables
| Variable | Type | Availability |
|---|---|---|
| `varAccountName` | Text | Input |
| `varAccountId` | Text | Output |
| `varClaimId` | Text | Output |
| `varPolicyId` | Text | Output |
| `varRiskLevel` | Text | Output |
| `varAssignedTo` | Text | Output |
| `varActionMessage` | Text | Output |

## 3. Flow Configuration (`Insurance_Claim_Triage`)

### A. Retrieval
1. **Get Records:** `Account` where `Name = {!varAccountName}`, sort `CreatedDate` DESC, first record only
2. **Assignment:** `varAccountId = {!Get_Account.Id}`
3. **Get Records:** `Insurance_Claim__c` where `Customer__c = {!varAccountId}`, sort `CreatedDate` DESC, first record only
4. **Assignment:** `varClaimId = {!Get_Claim.Id}`, `varPolicyId = {!Get_Claim.Policy__c}`
5. **Get Records:** `Insurance_Policy__c` where `Id = {!varPolicyId}`

### B. Policy Validation & Risk Analysis (Decision)
- **Rejected:** Policy status is not `Active` OR policy end date is before today
- **High Risk:** Claim amount is greater than 80% of coverage amount OR description contains "total loss", "fire", "hospitalization", "theft"
- **Medium Risk:** Description contains "accident", "damage", "surgery"
- **Default:** Low Risk (eligible for fast-track approval)

Assignments set `varRiskLevel` to Rejected / High / Medium / Low.

### C. Assignment Routing
6. **Decision:** `varRiskLevel = "High"`
7. **Create Records (Task):**
   - `Subject` = "High-Value Claim Review"
   - `WhatId` = `{!varClaimId}`
   - `Priority` = High, `Status` = Not Started
8. **Assignment:** `varAssignedTo`
   - High: "Senior Claims Adjuster"
   - Medium: "Claims Adjuster"
   - Low: "Auto-Approval Queue"
   - Rejected: "Policy Admin Team"

### D. Final Messages
- Rejected: "Policy is inactive or expired. Claim cannot be processed."
- High: "High-risk claim detected. Assigned to senior adjuster for review."
- Medium: "Claim is under standard review by a claims adjuster."
- Low: "Claim is low risk and queued for fast-track approval."

Save and **Activate** the flow.

## 4. Agentforce Subagent
1. Open **Agentforce Builder** and create a subagent: **Claims Triage Assistant**
2. Set the classification description and scope to claim status and triage queries only
3. Add the flow as an action: input `varAccountName`; outputs `varActionMessage`, `varRiskLevel`, `varAssignedTo`, `varClaimId`, `varPolicyId`, `varAccountId`
4. Test in **Conversation Preview** with a valid account name

## 5. Sample Test Data
| Account | Policy Type | Claim Description | Expected Result |
|---|---|---|---|
| Acme Corp | Property | Fire caused total loss | High |
| Globex | Auto | Minor accident damage | Medium |
| Initech | Health | Routine checkup | Low |
| Umbrella | Life | Policy expired last year | Rejected |

## 6. Future Enhancements
- Fraud scoring using claim history per customer
- Email notification to the customer on claim decision
- Dashboard of claims by policy line and risk level

## Tech Stack
Salesforce Developer Org · Flow Builder · Agentforce · Custom Objects
