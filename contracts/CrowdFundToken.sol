// SPDX-License-Identifier: UNLICENCED
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";


abstract contract ERC20 {
    function name() public view virtual returns (string memory);
    function symbol() public view virtual returns (string memory);
    function decimals() public view virtual returns (uint8);
    function totalSupply() public view virtual returns (uint256);
    function balanceOf(address _owner) public view virtual returns (uint256 balance);
    function transfer(address _to, uint256 _value) public virtual returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success);
    function approve(address _spender, uint256 _value) public virtual returns (bool success);
    function allowance(address _owner, address _spender) public virtual view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract CrowdFundToken is ERC20, Ownable{

/*
This is an ERC-20 contract. 
 */
    string public _name;
    string public _symbol;
    uint8 public _decimal;
    uint public _totalSupply;
    address public _minter;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor () {
        _name = "CrowdFundToken";
        _symbol = "CFT";
        _decimal = 18;
        _totalSupply = 210000;
        _minter = msg.sender;

        balances[_minter] = _totalSupply;
        emit Transfer(address(0),_minter,_totalSupply);
    }
    // Returns the name of the token
    function name() public override view returns (string memory){
        return _name;
    }
    
    // Returns the symbol of the token
    function symbol() public override view returns (string memory){
        return _symbol;
    }
    // Returns the decimals
    function decimals() public override view returns (uint8){
        return _decimal;
    }
    // Returns the total supply
    function totalSupply() public override view returns (uint256){
        return _totalSupply;
    }
    // Returns the balance of an address
    function balanceOf(address _owner) public override view returns (uint256 balance){
        return balances[_owner];
    }
    // Transfer the funds
    function transferFrom(address _from, address _to,uint256 _value) public override returns (bool success){
        require(balances[_from] >= _value || allowed[_minter][_from] >= _value);
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from,_to,_value);
        return true;
    }
    
    // Transfer the funds
    function transfer(address _to, uint256 _value) public override returns (bool success){
        return transferFrom(msg.sender,_to,_value);
    }

    // Allow an address to spend the token on behalf
    function approve(address _spender, uint256 _value) public override returns (bool success){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
    
    // Returns the amount that spender is allowed spend on behalf
    function allowance(address _owner, address _spender) public override view returns (uint256 remaining){
        return allowed[_owner][_spender];
    }

    // Mint tokens
    function mint(uint _amount) public returns (bool) {
        require(msg.sender == _minter);
        balances[_minter]  += _amount;
        _totalSupply += _amount;
        return true; 
    }

}
