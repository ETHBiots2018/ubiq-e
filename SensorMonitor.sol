pragma solidity ^0.4.20;

contract Grid {
    //A Map
    mapping (address => uint256) production;
    mapping (address => uint256) consumption;
    mapping (address => address) sensorOwner;
    
    function setOwnerOfSensor(address sensor) public {
        sensorOwner[sensor] = msg.sender;
    }
    
    function getSensorOwner(address sensor) public view returns (address) {
        return sensorOwner[sensor];
    }
    
    function setConsumption(address user, uint256 consumption) public {
        consumption[user] = consumption;
    }
    
    function getConsumption(address user) public view returns (uint256) {
        return consumption[user];
    }
    
    function setProduction(address user, uint256 consumption) public {
        production[user] = production;
    }
    
    function getProduction(address user) public view returns (uint256) {
        return production[user];
    }
    
    function authenticate() public view returns (address) {
        address owner = getSensorOwner(msg.sender);
        require(owner != 0);
        return owner;
    }  
}

contract SensorOwner {
    mapping (address => uint8) authenticatedSensors;
    address SensorAuthenticator;
    
    function SensorOwner() {
        Grid userMaps = new Grid();
        OurEnergySensor sensorMonitor = new OurEnergySensor();
        User userFunctions = new User();
        Authenticator auth = new Authenticator();
        authenticator.setSensorOwner(this);
    }
    
    function addSensor(address newSensor) public {
        require(msg.sender == SensorAuthenticator); 
        authenticatedSensors[newSensor] = 1;
    }
    
}

contract Authenticator {
    SensorOwner owner;
    function isAuthenticated() public view returns (bool) {
        return (owner.authenticatedSensors[msg.sender] == 1);
    }
    
    function setSensorOwner(SensorOwner owner) {
        this.owner = owner;
    };
}

contract OurEnergySensor {

    Grid userMaps;
    
    function OurEnergySensor() {
        SensorAuthenticator = msg.sender;
        userMaps = new Grid();
    }
    
    //sends measurements on blockchain
    //sensor is calling that
    function sendMeasurement(uint256 production, uint256 consumption) public {
        isOurEnergySensor();
        address owner = authenticate();
        userMaps.setConsumption(owner,consumption);
        userMaps.setProduction(owner,production);
    }
}

contract User {
    function getMyConsuption() {}
    function getMyProduction() {}
    
}
