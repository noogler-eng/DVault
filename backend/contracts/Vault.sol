// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
contract Vault{

    uint256 private vaultId;

    struct Docs{
        string name;
        string link;
    }

    struct VaultRoom{
        uint256 id;
        Docs[] documents;
    }

    mapping (address => uint256) addressToOwner;
    mapping (uint256 => address[]) isAccess;
    mapping (uint256 => VaultRoom) getVault;
    mapping (address => bool) isHavingVault;

    modifier onlyAccess(uint256 _vaultId){
        bool isValidAcesser = false;
        for(uint i=0; i<isAccess[_vaultId].length; i++){
            if(msg.sender == isAccess[_vaultId][i]){
                isValidAcesser = true;
                // Exit loop early once access is confirmed
                break;
            }
        }
        require(isValidAcesser, 'you have not access');
        _;
    }

    function createVault() public payable{
        require(!isHavingVault[msg.sender], 'you already have an vault');
        require(msg.value == 0.1 ether, 'creation of vault requires 0.1 eth');
        
        Docs[] memory documents;
        getVault[vaultId] = VaultRoom(vaultId, documents);
        
        // Set the owner of the vault
        addressToOwner[msg.sender] = vaultId;
        isHavingVault[msg.sender] = true;
        isAccess[vaultId].push(msg.sender);
        vaultId++;
    }

    function storeInVault(uint256 _vaultId, string memory _name, string memory _link) public onlyAccess(_vaultId){
        Docs memory doc = Docs(_name, _link);
        getVault[_vaultId].documents.push(doc);
    }

    function getFromVault(uint256 _vaultId, string memory _name) public onlyAccess(_vaultId) view returns(string memory){
        for(uint i=0; i<getVault[_vaultId].documents.length; i++){
            if(keccak256(abi.encode(getVault[_vaultId].documents[i].name)) == keccak256(abi.encode(_name))){
                return getVault[_vaultId].documents[i].link;
            }
        }
        return "Document not found";
    }

    function givingVaultAccess(uint256 _vaultId, address _toAccess) public {
        require(addressToOwner[msg.sender] == _vaultId, 'you are not owner of this');
        require(_toAccess != address(0), 'invalid address');
        isAccess[_vaultId].push(_toAccess);
    }

    function removeAccess(uint256 _vaultId, address _fromAccess) public {
        require(addressToOwner[msg.sender] == _vaultId, 'you are not owner of this');
        require(_fromAccess != address(0), 'invalid address');
        


        for(uint i=0; i<isAccess[_vaultId].length; i++){
            if(isAccess[_vaultId][i] == _fromAccess){
                isAccess[_vaultId][i] = isAccess[_vaultId][isAccess[_vaultId].length - 1];
                // removing the last element of isAccess[_vaultId] array
                isAccess[_vaultId].pop();
                break;
            }
        }
    }

}