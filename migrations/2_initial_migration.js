//Instancia de nuestro contrato CrowdFunding.sol
const CrowdFunding = artifacts.require("CrowdFunding");


//Este scri´pt hace deploy de nuestro contrato a la blockchain
module.exports = function(deployer){
    deployer.deploy(CrowdFunding);
};