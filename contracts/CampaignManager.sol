// SPDX-License-Identifier: UNLICENCED

pragma solidity 0.8.6;

import './Campaign.sol'; 

contract CampaignManager {
    /*
    1. This is a smart contract used to deploy the instance of a crowdfunding campaign.
    2. A person who wants to create a crowdfunding campaign calls the 'createCampaign' function and a smart contract gets deployed for his campaign.
    3. 'getDeployedCampaigns' can be called to get the list of all the deployed crowdfunding campaign smart contracts.
     */
    
    // Event
    event CampaignCreated(string CampaignName, string Description, uint FundingGoal, uint Expiry, address Creator, address CrowdfundTokenAddress);
    
    // An array of the deployed campaigns.
    address payable[] public deployedCampaigns;

    // Deployes an instance of a campaign contract.
    function createCampaign(string memory _CampaignName, string memory _description, uint _fundingGoal, uint _expiry, address _crowdfundTokenAddress) external {
        // Reverts an error if the Campaign name is empty.
        bytes memory emptyStringNameTest = bytes(_CampaignName);
        require(!(emptyStringNameTest.length == 0),"Campaign name cannot be an empty string");
        // Reverts an error if the Description of the campaign is empty.
        bytes memory emptyStringDescriptionTest = bytes(_description);
        require(!(emptyStringDescriptionTest.length == 0),"Campaign description cannot be an empty string");
        
        require(_expiry > block.timestamp,"Expiry time is invalid");
        require(_fundingGoal > 0,"Goal amount is invalid");
        
        address newCampaign = address(new Campaign(_CampaignName, _description, _fundingGoal, _expiry, msg.sender,_crowdfundTokenAddress));
        deployedCampaigns.push(payable(newCampaign));
        emit CampaignCreated(_CampaignName, _description, _fundingGoal, _expiry, msg.sender,_crowdfundTokenAddress);
    }

    // Gets the list of all the deployed campaign contracts.
    function getDeployedCampaigns() public view returns (address payable[] memory) {
        return deployedCampaigns;
    }
}
