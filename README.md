# Multi-Line Insurance Policy and Claims Management System

Hey there! 👋 Welcome to my repository. This project is part of my hands-on learning and implementation with Salesforce and Agentforce. Here, I've built an Multi-line Insurance Policy and Claims Management System that minimizes manual work for support teams.

## 💡 What this project is about?:
*   It's a Salesforce-based system that helps an insurance company manage its policies and claims in one place, across different types of insurance (Auto, Health, Property, Life).

*   The problem it solves: Insurance companies often track policies in one system, claims in another, and approvals through emails or spreadsheets. This causes delays, errors, and no clear view of a customer's full history.

---

## 🛠️ How I Built It (Key Components)
* **Salesforce Flow (Auto-Launched):** The core backend engine that fetches account and insurance policy details, runs decision logic based on keywords, and handles record creations.
* **Keyword-Based Intelligence:** 
  * *High Priority:* Triggers on keywords like "urgent", "not working", or "failure".
  * *Medium Priority:* Triggers on "issue", "slow", or "delay".
  * *Low Priority:* Default catch-all category.
* **Set up the org:** Create a free Salesforce Developer Edition org (developer.salesforce.com/signup). This is your sandbox for building.
* **Agentforce Subagent:** Setup → Object Manager → Create → Custom Object

     Insurance_Policy__c (fields: Policy Number, Line of Business, Premium, Sum Insured, Start Date, End Date, Status)
     Coverage__c (Coverage Type, Limit)
     Claim__c (Claim Amount, Incident Date, Status)
     Claim_Payment__c (Amount Paid, Payment Date)
---

## 📂 Project Structure & Workflow
1. **Structure:** The project is built on four linked objects: Account (policyholder) → Insurance_Policy__c (with Record Types for Auto, Health, Property, and Life) → Claim__c → Claim_Payment__c, with Coverage__c attached to each policy to define limits.
2. **Workflow:** An agent issues a policy, the customer files a claim, Apex and validation rules check eligibility, a Flow assigns an adjuster, an approval process routes it to a manager, and once approved, a payment record is created and the dashboards update.
3. **Set Priority & Assign Tasks:** Automatically updates priority levels, creates follow-up tasks for urgent issues, and sets appropriate response messages.
4. **Agentforce Action:** Connects the flow to the agent for seamless user interaction.

---

## 👥 Team Information / Contributors
* **Project Name:** Multi-Line Insurance Policy and Claims Management System
* **Platform:** Salesforce Developer Org & Agentforce

| Role | Name |
| :--- | :--- |
| **Team Lead** | Srinivas K |
| **Member** |  Thilliyappan K |
| **Member** | Yogesh A |
| **Member** | Abisekarapandi A |

---

## ✨ What I Learned & Achieved
* Salesforce development fundamentals, including data modeling (objects, relationships, record types), declarative automation (validation rules, Flows, approval processes), Apex triggers with bulkification, Lightning Web Components, security setup, and testing and deployment.
* Successfully bridged Salesforce backend automation (Flows) with modern conversational AI (Agentforce).
* Handled error-free variable mapping and record creation inside Salesforce Developer Edition.

---

## 🚀 Future Improvements
* Adding advanced SLA monitoring and automated escalation matrices.
* Expanding keyword dictionaries and custom business rules for better categorization.
* Building performance analytics dashboards for support trends.

*Feel free to check out the screenshots and configurations in this repo. If you have any feedback or want to collaborate, let's connect!*
