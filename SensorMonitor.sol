import "./ubiqToken.sol";

/*
 * Author: Jonas Passweg
 */
 
pragma solidity ^0.4.18;

/*
 * Creator of everything, also stores Address of important contracts
 * Owner of the token
 * Adding smartMeters (sensors) can be done with this contract by owner
 */
contract SensorOwner {
    //Stores the address of the authenticated smartMeters (our way of authentification)
    mapping (address => uint8) authenticatedSensors;
    //Address of owner of this contract
    address SensorAuthenticator;
    //Stores our token
    UBIQBiots18 ourToken;
    //Stores our grid
    Grid userMaps;
    
    function SensorOwner() {
        //The owner is the sender
        SensorAuthenticator = msg.sender;
        //Amount our account has at the start
        uint256 amountOfTokens = 100000000;
        //creating the token
        ourToken = new UBIQBiots18();
        //creaing the grid
        userMaps = new Grid(this, ourToken);
        //approving the grid to give tokens to the user (with sendMeasurement method)
        ourToken.approve(userMaps, amountOfTokens); //may be the source of a bug
        ourToken.setOurUserMaps(userMaps);
    }
    
    //Adding a sensor, requires isOwner
    function addSensor(address newSensor) public {
        require(msg.sender == SensorAuthenticator); 
        authenticatedSensors[newSensor] = 1;
    }
    
    //Checks if sensor was added by SensorOwner
    function isAuthenticatedSensor(address sensor) public view returns (bool) {
        return (authenticatedSensors[sensor] == 1);
    }
    
    //returns the address of the tokens
    function getToken() public view returns (address) {
        return ourToken;
    }
    
    //returns the address of the grid
    function getGrid() public view returns (address) {
        return userMaps;
    }
    
    //function for owner to collect the tokens if wanted
    function collectToken(address account, uint256 amount) public {
        require(msg.sender == SensorAuthenticator);
        ourToken.transfer(account, amount);
    }
}

/* Grid: stores all the user data and has a call for sending measurements from a Sensor
 * productionMap: how much a user has produced since last reset
 * consumptionMap: how much a user has consumed since last reset
 * sensorOwnerMap: stores which smartMeter belongs to which user
 * toPayMap: how much the user has to pay for electricity
 */
contract Grid {
    //MAPS THAT LATER ON, CAN BE TAKEN OFF BLOCKCHAIN
    mapping (address => uint256) productionMap;
    mapping (address => uint256) consumptionMap;
    //MAPS THAT NEED TO STAY ON BLOCKCHAIN
    mapping (address => address) sensorOwnerMap;
    mapping (address => uint256) toPayMap; 
    //storing the adresses
    SensorOwner ourSensorOwner;
    UBIQBiots18 ourToken;
    
    function Grid(SensorOwner sensorowner, UBIQBiots18 token) {
        ourSensorOwner = sensorowner;
        ourToken = token;
    }
    
    /* Setters and Getters */
    function setOwnerOfSensor(address sensor) public {
        require(ourSensorOwner.isAuthenticatedSensor(sensor));
        sensorOwnerMap[sensor] = msg.sender;
    }
    
    function getSensorOwner(address sensor) public view returns (address) {
        address owner = sensorOwnerMap[sensor];
        require(owner != 0);
        return owner;
    }
    
    function setConsumption(address user, uint256 consumption) public {
        require(ourSensorOwner.isAuthenticatedSensor(msg.sender));
        consumptionMap[user] = consumption;
    }
    
    function getConsumption(address user) public view returns (uint256) {
        return consumptionMap[user];
    }
    
    function resetConsumption() public {
        consumptionMap[msg.sender] = 0;
    }
    
    function setProduction(address user, uint256 production) public {
        ourSensorOwner.isAuthenticatedSensor(msg.sender);
        productionMap[user] = production;
    }
    
    function getProduction(address user) public view returns (uint256) {
        return productionMap[user];
    }
    
    function resetProduction() public {
        productionMap[msg.sender] = 0;
    }
    
    function getToPay(address user) public view returns (uint256) {
        return toPayMap[user];
    }
    
    function setToPay(address user, uint256 amount) public {
        address tokenAddress = ourToken;
        require(msg.sender == tokenAddress);
        toPayMap[user] = amount;
    }
    
    //sends measurements on blockchain
    //only a authenticated sensor can call this method
    function sendMeasurement(uint256 production, uint256 consumption) public {
        require(ourSensorOwner.isAuthenticatedSensor(msg.sender));
        
        address user = getSensorOwner(msg.sender);
        
        consumptionMap[user] += consumption;
        productionMap[user] += production;
        
        toPayMap[user] += consumption;
        ourToken.transferFrom(ourSensorOwner, user, production);
    }
}
