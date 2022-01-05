//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import { SafeMath } from "./Utils.sol";

import "./Utils.sol";
import "./Gameable.sol";

//TODO: add Admin role so users can create an event and open betting on it

/* 
This class takes bets for Game contracts including participants
and a winner or draw outcome
*/

contract Bettable is Gameable {
    using SafeMath for uint;

    // Events
    event NewBet(string message, address player, Coin coin, uint amount, int winner);

    // returns bets for current user
    function getUserBets() public view returns (Bet[] memory) {
        return userToBets[msg.sender];
    }

    // returns bets in specific coin
    function getCoinBets(Coin _coin) public view returns (Bet[] memory) {
        return coinToBets[_coin];
    }

    // returns total bets by Coin
    // params _coin corresponding to Coin enum
    function getBetsByCoin(Coin _coin) private view returns(uint _t0, uint _t1, uint _t2) {
        Bet[] storage bets = coinToBets[_coin];

        // count winning bets & get total 
        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].winner == 0) {
                _t0 = _t0.add(bets[i].amount);
            } else if (bets[i].winner == 1) {
                _t1 = _t1.add(bets[i].amount);
            } else if (bets[i].winner == 2) {
                _t2 = _t2.add(bets[i].amount);
            }
        }

        return (_t0, _t1, _t2);
    }

    // calculates odds
    // params _numerator, _divisor, elements of the fraction
    // return uint corresponding to odd * 100
    function calculateSingleOdd(uint _numerator, uint _divisor) private pure returns(uint) {
        if (_divisor == 0) {
            return 0;
        } else {
            return 100 + _numerator.mul(100).div(_divisor);
        }
    }

    // get odds by Coin
    // params _coin corresponding to Coin enum
    // returns odd values *100 in order to handle decimals -> to be properly formated in frontend
    function getGameOdds(Coin _coin) public view returns(uint _p0, uint _p1, uint _p2) {
        (uint _total0, uint _total1, uint _total2) = getBetsByCoin(_coin);
        uint totalSum = _total0.add( _total1.add(_total2) );

        _p0 = calculateSingleOdd(_total1.add(_total2), totalSum);
        _p1 = calculateSingleOdd(_total0.add(_total2), totalSum);
        _p2 = calculateSingleOdd(_total0.add(_total1), totalSum);

        return (_p0, _p1, _p2);
    }

    // places a bet on the given game
    // params _gameId the id of the game on which to bet, _winner the index of the participant chosen as winner
    function placeBet(Coin _coin, int _winner) public payable {

        // add the new bet
        Bet memory _bet = Bet(payable(msg.sender), _coin, msg.value, _winner);

        // add the bet to user's
        userToBets[msg.sender].push(_bet);

        // add the bet to coins's array
        coinToBets[_coin].push(_bet);

        // broadcast Event
        emit NewBet("Bet added", msg.sender, _coin, msg.value, _winner);
    }
}
