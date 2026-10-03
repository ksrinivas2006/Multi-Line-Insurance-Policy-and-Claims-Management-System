public with sharing class InsurancePolicyClaimsManager {

    // =========================================================
    // 1. GET POLICY + RELATED CLAIMS
    // =========================================================

    @AuraEnabled
    public static Map<String, Object> getPolicy(String policyNumber) {

        Map<String, Object> response =
            new Map<String, Object>();

        if (String.isBlank(policyNumber)) {
            response.put('success', false);
            response.put(
                'message',
                'Policy number is required.'
            );
            return response;
        }

        List<Insurance_Policy__c> policies = [
            SELECT Id,
                   Name,
                   Policy_Number__c,
                   Policy_Type__c,
                   Status__c,
                   Customer__c,
                   Start_Date__c,
                   End_Date__c,
                   Premium__c,
                   Coverage_Amount__c
            FROM Insurance_Policy__c
            WHERE Policy_Number__c = :policyNumber
            LIMIT 1
        ];

        if (policies.isEmpty()) {
            response.put('success', false);
            response.put(
                'message',
                'No policy found for: ' + policyNumber
            );
            return response;
        }

        Insurance_Policy__c policy = policies[0];

        // Get related claims
        List<Insurance_Claim__c> claims = [
            SELECT Id,
                   Name,
                   Claim_Number__c,
                   Claim_Type__c,
                   Status__c,
                   Claim_Amount__c,
                   Approved_Amount__c,
                   Claim_Date__c,
                   Description__c
            FROM Insurance_Claim__c
            WHERE Policy__c = :policy.Id
            ORDER BY Claim_Date__c DESC
        ];

        response.put('success', true);
        response.put(
            'message',
            'Policy retrieved successfully.'
        );

        response.put('policyId', policy.Id);
        response.put(
            'policyNumber',
            policy.Policy_Number__c
        );
        response.put(
            'policyType',
            policy.Policy_Type__c
        );
        response.put(
            'policyStatus',
            policy.Status__c
        );
        response.put(
            'customerId',
            policy.Customer__c
        );
        response.put(
            'startDate',
            policy.Start_Date__c
        );
        response.put(
            'endDate',
            policy.End_Date__c
        );
        response.put(
            'premium',
            policy.Premium__c
        );
        response.put(
            'coverageAmount',
            policy.Coverage_Amount__c
        );

        // =====================================================
        // CLAIM HISTORY
        // =====================================================

        List<Map<String, Object>> claimHistory =
            new List<Map<String, Object>>();

        for (Insurance_Claim__c claim : claims) {

            claimHistory.add(
                new Map<String, Object>{
                    'claimId' =>
                        claim.Id,

                    'claimNumber' =>
                        claim.Claim_Number__c,

                    'claimType' =>
                        claim.Claim_Type__c,

                    'status' =>
                        claim.Status__c,

                    'claimAmount' =>
                        claim.Claim_Amount__c,

                    'approvedAmount' =>
                        claim.Approved_Amount__c,

                    'claimDate' =>
                        claim.Claim_Date__c,

                    'description' =>
                        claim.Description__c
                }
            );
        }

        response.put(
            'claims',
            claimHistory
        );

        return response;
    }


    // =========================================================
    // 2. CREATE INSURANCE CLAIM
    // =========================================================

    @AuraEnabled
    public static Map<String, Object> createClaim(
        String policyNumber,
        String claimType,
        Decimal claimAmount,
        String description
    ) {

        Map<String, Object> response =
            new Map<String, Object>();

        if (String.isBlank(policyNumber)) {
            response.put('success', false);
            response.put(
                'message',
                'Policy number is required.'
            );
            return response;
        }

        if (String.isBlank(claimType)) {
            response.put('success', false);
            response.put(
                'message',
                'Claim type is required.'
            );
            return response;
        }

        if (claimAmount == null || claimAmount <= 0) {
            response.put('success', false);
            response.put(
                'message',
                'Claim amount must be greater than zero.'
            );
            return response;
        }

        List<Insurance_Policy__c> policies = [
            SELECT Id,
                   Policy_Number__c,
                   Status__c,
                   Coverage_Amount__c
            FROM Insurance_Policy__c
            WHERE Policy_Number__c = :policyNumber
            LIMIT 1
        ];

        if (policies.isEmpty()) {
            response.put('success', false);
            response.put(
                'message',
                'Policy not found.'
            );
            return response;
        }

        Insurance_Policy__c policy =
            policies[0];

        if (policy.Status__c != 'Active') {
            response.put('success', false);
            response.put(
                'message',
                'Claims can only be submitted for active policies.'
            );
            return response;
        }

        if (
            policy.Coverage_Amount__c != null &&
            claimAmount > policy.Coverage_Amount__c
        ) {
            response.put('success', false);
            response.put(
                'message',
                'Claim amount exceeds policy coverage.'
            );
            return response;
        }

        Insurance_Claim__c claim =
            new Insurance_Claim__c();

        claim.Policy__c =
            policy.Id;

        claim.Claim_Type__c =
            claimType;

        claim.Claim_Amount__c =
            claimAmount;

        claim.Description__c =
            description;

        claim.Claim_Date__c =
            Date.today();

        claim.Status__c =
            'Submitted';

        insert claim;

        response.put('success', true);

        response.put(
            'message',
            'Insurance claim submitted successfully.'
        );

        response.put(
            'claimId',
            claim.Id
        );

        response.put(
            'claimNumber',
            claim.Claim_Number__c
        );

        response.put(
            'status',
            claim.Status__c
        );

        return response;
    }


    // =========================================================
    // 3. UPDATE CLAIM STATUS
    // =========================================================

    @AuraEnabled
    public static Map<String, Object> updateClaimStatus(
        Id claimId,
        String newStatus,
        Decimal approvedAmount
    ) {

        Map<String, Object> response =
            new Map<String, Object>();

        if (claimId == null) {
            response.put('success', false);
            response.put(
                'message',
                'Claim Id is required.'
            );
            return response;
        }

        List<Insurance_Claim__c> claims = [
            SELECT Id,
                   Claim_Number__c,
                   Status__c,
                   Claim_Amount__c,
                   Approved_Amount__c
            FROM Insurance_Claim__c
            WHERE Id = :claimId
            LIMIT 1
        ];

        if (claims.isEmpty()) {
            response.put('success', false);
            response.put(
                'message',
                'Claim not found.'
            );
            return response;
        }

        Insurance_Claim__c claim =
            claims[0];

        claim.Status__c =
            newStatus;

        if (approvedAmount != null) {
            claim.Approved_Amount__c =
                approvedAmount;
        }

        update claim;

        response.put('success', true);

        response.put(
            'message',
            'Claim status updated successfully.'
        );

        response.put(
            'claimNumber',
            claim.Claim_Number__c
        );

        response.put(
            'status',
            claim.Status__c
        );

        response.put(
            'approvedAmount',
            claim.Approved_Amount__c
        );

        return response;
    }


    // =========================================================
    // 4. GET CLAIM DETAILS
    // =========================================================

    @AuraEnabled
    public static Map<String, Object> getClaim(
        String claimNumber
    ) {

        Map<String, Object> response =
            new Map<String, Object>();

        if (String.isBlank(claimNumber)) {
            response.put('success', false);
            response.put(
                'message',
                'Claim number is required.'
            );
            return response;
        }

        List<Insurance_Claim__c> claims = [
            SELECT Id,
                   Name,
                   Claim_Number__c,
                   Policy__c,
                   Claim_Type__c,
                   Status__c,
                   Claim_Amount__c,
                   Approved_Amount__c,
                   Claim_Date__c,
                   Description__c
            FROM Insurance_Claim__c
            WHERE Claim_Number__c = :claimNumber
            LIMIT 1
        ];

        if (claims.isEmpty()) {
            response.put('success', false);
            response.put(
                'message',
                'Claim not found.'
            );
            return response;
        }

        Insurance_Claim__c claim =
            claims[0];

        response.put('success', true);

        response.put(
            'claimId',
            claim.Id
        );

        response.put(
            'claimNumber',
            claim.Claim_Number__c
        );

        response.put(
            'policyId',
            claim.Policy__c
        );

        response.put(
            'claimType',
            claim.Claim_Type__c
        );

        response.put(
            'status',
            claim.Status__c
        );

        response.put(
            'claimAmount',
            claim.Claim_Amount__c
        );

        response.put(
            'approvedAmount',
            claim.Approved_Amount__c
        );

        response.put(
            'claimDate',
            claim.Claim_Date__c
        );

        response.put(
            'description',
            claim.Description__c
        );

        return response;
    }
}
