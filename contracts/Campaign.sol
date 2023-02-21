// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Errors
error CAMPAIGN_EXPIRED();
error COMPLETELY_FUNDED();
error NOT_COMPLETELY_FUNDED();
error NOT_EXPIRED();

contract Campaign{
    /*
    1. This is a crowdfund campaign.
    2. Funds take the form of a custom ERC20 token i.e. CrowdFundToken.
    3. This has a funding goal.
    4. When a funding goal is not met, customers are be able to get a refund of their pledged funds.
    5. dApps using the contract can observe state changes in transaction logs.
     */
    
    // Events
    event fundsRecieved(uint amount,address investor);
    event fundsWithdrawnByCreator(uint time);
    event fundsRefundedToInvestor(address investor,uint amount);

    // Address of the campaign creator
    address public Creator;
    // Name of the campaign
    string public CampaignName;
    // Campaign Description
    string public Description;
    // Funding goal
    uint public FundingGoal; 
    // Time of expiry of the campaign (Unix Timestamp)
    uint public Expiry;
    // The total amount of funds raised till the point
    uint public TotalAmountOfFundRaised;
    // The maximum amount an investor can invest (This will be always lesser than or equal the difference between the FundingGoal and TotalAmountOfFundRaised)
    uint public MaxInvestment;
    // Address of the token
    address public CrowdfundTokenAddress;
    // Specifies if the funds are withdrawn by the Creator. False indicates he has not and True indicates he has
    bool public isWithdrawn;
    
    // Maps the address of the investor to the amount
    mapping(address => uint) investors;

    // Modifiers

    // Reverts an error if the campaign is expired
    modifier notExpired() {
        if(Expiry <= block.timestamp){
            revert CAMPAIGN_EXPIRED();
        }
        else{
            _;
        }
    }
    
    // Reverts an error if the campaign is not expired
    modifier campaignExpired() {
        if(Expiry >= block.timestamp){
            revert NOT_EXPIRED();
        }
        else{
            _;
        }
    }
    
    // Reverts an error if the campaign is completely funded
    modifier notCompletelyFunded() {
        if(FundingGoal == TotalAmountOfFundRaised){
            revert COMPLETELY_FUNDED();
        }
        else{
            _;
        }
    }

    // Reverts an error if the campaign is not completely funded
    modifier completelyFunded() {
        if(FundingGoal != TotalAmountOfFundRaised){
            revert NOT_COMPLETELY_FUNDED();
        }
        else{
            _;
        }
    }

    // Enables only Creator of the campaign to call a function
    modifier onlyCreator() {
        require(msg.sender == Creator,"You are not authorized to call this function");
        _;
    }

    // Enables only investors of the campaign to call a function
    modifier onlyInvestor() {
        require(investors[msg.sender] !=0 ,"You are not an investor!");
        _;
    }

    constructor(string memory _campaignName, string memory _description, uint _fundingGoal, uint _expiry, address _creator, address _crowdfundTokenAddress){
        Creator = _creator;
        CampaignName = _campaignName;
        Description = _description;
        FundingGoal = _fundingGoal;
        Expiry = _expiry;
        MaxInvestment = _fundingGoal; 
        isWithdrawn = false;
        CrowdfundTokenAddress = _crowdfundTokenAddress;
    }

    // Anyone can call this function to invest in the campign, given that the campaign is not expired and not completely funded
    function invest(uint _amount) external notExpired notCompletelyFunded {
        require(_amount > 0,"Amount should be greater than zero");
        require(_amount <= MaxInvestment,"Please check MaxInvestment to see what is the maximum amount you can invest");
        bool success = IERC20(CrowdfundTokenAddress).transferFrom(msg.sender, address(this), _amount);
        require(success);
        TotalAmountOfFundRaised += _amount;
        MaxInvestment -= _amount;
        investors[msg.sender] = _amount;
        emit fundsRecieved(_amount,msg.sender);
    }

    // If the campaign is expired, completely funded and not withdrawn already, Creator can withdraw the funds 
    function withdrawFunds() external onlyCreator campaignExpired completelyFunded {
        require(isWithdrawn == false,"You have already withdrawn the funds");
        bool success = IERC20(CrowdfundTokenAddress).transferFrom(address(this), Creator, TotalAmountOfFundRaised);
        require(success);
        MaxInvestment=0;
        isWithdrawn = true;
        emit fundsWithdrawnByCreator(block.timestamp);
    }

    // If the campaign is expired and not completely funded, Investors can withdraw their funds
    function getRefund() external onlyInvestor campaignExpired {
        require(TotalAmountOfFundRaised != FundingGoal,"Withdraw has been diabled as the funding goal is met");
        bool success = IERC20(CrowdfundTokenAddress).transferFrom(address(this), msg.sender, investors[msg.sender]);
        require(success);
        investors[msg.sender] = 0;
        emit fundsRefundedToInvestor(msg.sender,investors[msg.sender]);
    }
}
