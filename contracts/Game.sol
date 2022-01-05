//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import { SafeMath } from "./Utils.sol";

import "./Bettable.sol";
import "./Payoutable.sol";

//TODO: add Admin role so users can create an event and open betting on it

/* 
This class takes bets and handles payouts for sporting events including participants
and a winner or draw outcome
*/

contract Game is Bettable, Payoutable {

     bytes32 public name;
     bytes32[] public participants;
     uint public date;

     // initializes the contract populating it's storage vars
     // params: _name, bytes32, the name of the event
     // _participants, bytes32[], an array with the teams of entities competing
     // _date, uint, a timestamp in Unix
     function init(bytes32 _name, bytes32[] memory _participants, uint _date, address _owner) external {
          name = _name;
          participants = _participants;
          date = _date;
          transferOwnership(payable(_owner));
     }

}
