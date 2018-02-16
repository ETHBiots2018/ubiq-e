import "./SensorMonitor.sol";

/*
 * Source: https://github.com/ConsenSys/Token-Factory/blob/master/contracts/StandardToken.sol
 * Author: ConsenSys
 * Edited by: Jonas Passweg
 */
pragma solidity ^0.4.18;

contract Token {

    /// @return total amount of tokens
    function totalSupply() public constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract UBIQBiots18 is StandardToken {
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                 // An identifier: eg SBX, XPR etc..
    string public version = 'H1.0'; 
    address owner;
    Grid ourUserMaps;

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    function UBIQBiots18() public {
        uint256 amount = 1000000;
        balances[msg.sender] = amount;               // Give the creator all initial tokens. This is set to 1'000'000 for example. 
            //If you want your initial tokens to be X and your decimal is 5, set this value to X * 100000.
        totalSupply = amount * 1000000000000000000;                  // Update total supply (1'000'000 for example)
        name = "UBIQBiots18";                                        // Set the name for display purposes
        decimals = 18;                                               // Amount of decimals for display purposes
        symbol = "UBIQ";                                             // Set the symbol for display purposes
        owner = msg.sender;                                          // The owner of the contract gets ETH
    }
    
    //The price if user want to pay their energy bill with money
    uint256 public buyPrice;

    //Method that sets price / user must be owner = SensorOwner contract
    function setPrices(uint256 newBuyPrice) public {
        require(msg.sender == owner);
        buyPrice = newBuyPrice;
    }
    
    function setOurUserMaps(Grid userMaps) public {
        require(msg.sender == owner);
        ourUserMaps = userMaps;
    }
    
    //returns price of energy at that moment
    function getPrice() public view returns (uint256) {
        return buyPrice;
    }
    
    //Way for user to pay energy bill with cash
    //called by user
    //returns balance
    function payEnergyWithTokens() public {
        uint256 toPay = ourUserMaps.getToPay(msg.sender);   //gets the amount the user has to pay
        uint256 balance = balanceOf(msg.sender);            //see balanceOf
        
        //pays with all the tokens the user has and subtracts them of the amount the user has to pay
        //transfer these token to the owner of the contract
        if(toPay > balance) {
            ourUserMaps.setToPay(msg.sender, toPay - balance);
            transfer(owner, balance);
        } else {
            ourUserMaps.setToPay(msg.sender, 0);
            transfer(owner, balance - toPay);
        }
    }
    
    //Way for user to pay energy bill with cash
    //called by user
    function payEnergyWithCash() public {
        //get contract with bank account
        //uint256 amountPayed = 100;
        //uint256 toPay = ourUserMaps.getToPay(msg.sender);
        ourUserMaps.setToPay(msg.sender, 0); //later changed with toPay-amountPayed
    }
    
    /* Additional Market can be implemented here
    mapping(address => uint256) propositions;
    function propose(address to, )
    */
    
}
