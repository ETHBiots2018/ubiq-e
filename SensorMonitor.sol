contract EnergySensor {
    //get Measurements map from 
    public getMeasurements() return mapping {}
    
}

contract OurEnergySensor is EnergySensor {
    public isOurEnergySensor() {
        return true;
    }
    
    public getPrediction() return (uint128 prediction) {}
    
    //scans address
    //if address != NULL draw power
    public authenticate() {
        
    }
    
    //sends measurements on blockchain
    //sensors need to authenticate
    //
    public sendMeasurements() {}
}
