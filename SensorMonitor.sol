import "./ubiq.sol";

pragma solidity ^0.4.20;

contract Grid {
    //MAPS THAT LATER ON CAN BE TAKEN DOWN OF BLOCKCHAIN
    mapping (address => uint256) productionMap;
    mapping (address => uint256) consumptionMap;
    //MAPS THAT NEED TO STAY ON BLOCKCHAIN
    mapping (address => address) sensorOwnerMap;
    mapping (address => uint256) toPayMap; 
    
    Authenticator ourAuthenticator;
    SensorOwner ourSensorOwner;
    bool initialized = false;
    
    function Grid(Authenticator authenticator, SensorOwner sensorowner) {
        require(!initialized);
        ourAuthenticator = authenticator;
        ourSensorOwner = sensorowner;
        initialized = true;
    }
    
    function setOwnerOfSensor(address sensor) public {
        require(ourAuthenticator.isAuthenticated(sensor));
        sensorOwnerMap[sensor] = msg.sender;
    }
    
    function getSensorOwner(address sensor) public view returns (address) {
        address owner = sensorOwnerMap[sensor];
        require(owner != 0);
        return owner;
    }
    
    function setConsumption(address user, uint256 consumption) public {
        require(ourAuthenticator.isAuthenticated(msg.sender));
        consumptionMap[user] = consumption;
    }
    
    function getConsumption(address user) public view returns (uint256) {
        return consumptionMap[user];
    }
    
    function setProduction(address user, uint256 production) public {
        require(ourAuthenticator.isAuthenticated(msg.sender));
        productionMap[user] = production;
    }
    
    function getProduction(address user) public view returns (uint256) {
        return productionMap[user];
    }
    
    function getToPay(address user) public view returns (uint256) {
        return toPayMap[user];
    }
    
    function setToPay(address user, uint256 amount) public {
        require(msg.sender == ourSensorOwner.getTokenAddress());
        toPayMap[user] = amount;
    }
    
    //sends measurements on blockchain
    //sensor is calling that
    function sendMeasurement(uint256 production, uint256 consumption) public {
        require(ourAuthenticator.isAuthenticated(msg.sender));
        address user = getSensorOwner(msg.sender);
        consumptionMap[user] += consumption;
        productionMap[user] += production;
        if(production > consumption) {
            address tokenAddress = ourSensorOwner.getTokenAddress();
            UBIQBiots18 token = UBIQBiots18(tokenAddress);
            token.transferFrom(ourSensorOwner, user, production - consumption);
        }
        if(production < consumption) {
            toPayMap[user] += consumption - production;
        }
    }
    
    function resetProduction() public {
        productionMap[msg.sender] = 0;
    }
    
    function resetConsumption() public {
        consumptionMap[msg.sender] = 0;
    }
}

contract SensorOwner {
    mapping (address => uint8) authenticatedSensors;
    address SensorAuthenticator;
    address ourTokenAddress;
    Grid userMaps;
    
    function SensorOwner() {
        SensorAuthenticator = msg.sender;
        Authenticator auth = new Authenticator(this);
        userMaps = new Grid(auth, this);
        
        uint256 amountOfTokens = 100000000;
        UBIQBiots18 token = new UBIQBiots18(amountOfTokens, userMaps);
        ourTokenAddress = token;
        token.approve(userMaps, amountOfTokens);
    }
    
    function addSensor(address newSensor) public {
        require(msg.sender == SensorAuthenticator); 
        authenticatedSensors[newSensor] = 1;
    }
    
    function isAuthenticatedSensor(address sensor) public view returns (bool) {
        return (authenticatedSensors[sensor] == 1);
    }
    
    function getTokenAddress() public view returns (address) {
        return ourTokenAddress;
    }
    
    //TODO
    function collectMoney() {
        
    }
}

contract Authenticator {
    SensorOwner ourSensorOwner;
    bool initialized = false;
    
    function Authenticator(SensorOwner owner) {
        require(!initialized);
        ourSensorOwner = owner;
        initialized = true;
    }
    
    function isAuthenticated(address sensor) public view returns (bool) {
        ourSensorOwner.isAuthenticatedSensor(sensor);
    }
}
