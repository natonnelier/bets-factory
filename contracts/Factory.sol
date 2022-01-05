//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import './CloneFactory.sol';
import './Game.sol';
import './Ownable.sol';

/* 
This class handles the creation of Game contracts following the Clone Factory Pattern, for which the original
contract works as proxy for the others, reducing gas expending. This is accomplished using delegateCall function:
https://medium.com/coinmonks/delegatecall-calling-another-contract-function-in-solidity-b579f804178c
*/

contract Factory is CloneFactory, Ownable {
    Game[] public games;
    address masterContract; // address of the proxy contract

    constructor(address _masterContract) {
        masterContract = _masterContract;
    }

    // creates a Game contract for a specific Bettable, Payouitable event
    // params: _name, bytes32, the name of the event
    // _participants, bytes32[], an array with the teams of entities competing
    // _date, uint, a timestamp in Unix
    function createGame(bytes32 _name, bytes32[] memory _participants, uint _date) external onlyOwner returns (address) {
        Game game = Game(createClone(masterContract));
        game.init(_name, _participants, _date, owner);
        games.push(game);

        return address(game);
    }

    // returns an array with all created Games
    function getGames() external view returns(Game[] memory) {
        return games;
    }
}
