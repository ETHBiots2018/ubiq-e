import "SensorMonitor.sol";

pragma solidity ^0.4.20;
contract Owner {
    mapping (address => address) HouseToOwner;
    
    function set(address House) public {
        OurEnergySensor h = OurEnergySensor(House);
        require(h.isOurEnergySensor());
        HouseToOwner[House] = msg.sender;
    }
}
