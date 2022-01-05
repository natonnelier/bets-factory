//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

import { SafeMath } from "./Utils.sol";

import "./Gameable.sol";
import "./Disableable.sol";
import "./IERC20.sol";

//TODO: what if bets have no winner?

/*
This class is in charge of calculating and paying bet's prizes among winners
including house share
*/

contract Payoutable is Gameable, Disableable {

    using SafeMath for uint;

    //constants
    uint HOUSE_SHARE = 1;

    uint[] public prizes;

    // Events
    event PrizePaid(string message, address user, uint amount, uint date);

    // transfers house share to the owner
    // params amount the house share on current game bets
    function _transferToOwner(uint _amount, Coin _coin) private {
        if (_coin == Coin.Default) {
            payable(owner).transfer(_amount);
        } else {
            IERC20 token = IERC20(coinToAddress[_coin]);
            token.transfer(owner, _amount);
        }
    }

    function _calculateBetTotals(Bet[] memory _bets, int _winner) private pure returns (uint _losingTotal, uint _winningTotal) {
        // count winning bets & get total 
        for (uint i = 0; i < _bets.length; i++) {
            if (_bets[i].winner == _winner) {
                _winningTotal = _winningTotal.add(_bets[i].amount);
            } else {
                _losingTotal = _losingTotal.add(_bets[i].amount);
            }
        }

        return (_losingTotal, _winningTotal);
    }

    // calculates the amount to be paid out for a bet of the given amount, under the given circumstances
    // param _winningTotal the total amount of winning bets
    // param _losingTotal the total amount in losing bets or amount to be distributed among winners
    // param _betAmount the amount of this particular bet
    // returns prize to be paid to user and hause share, in wei
    function _calculateWinnerPrize(uint _losingTotal, uint _winningTotal, uint _betAmount) private view returns (uint _prize, uint _housePrize) {

        //calculate raw share
        uint subtotal = _betAmount + _losingTotal.mul(_betAmount) / _winningTotal;

        //calculate house share
        _housePrize = subtotal / (100 * HOUSE_SHARE);

        //calculate final prize for user
        _prize = subtotal.sub(_housePrize);

        return (_prize, _housePrize);
    }

    function _transferPrize(Coin _coin, address payable _to, uint _prize) private {
        if (_coin == Coin.Default) {
            _to.transfer(_prize);
        } else {
            IERC20 token = IERC20(coinToAddress[_coin]);
            token.transfer(_to, _prize);
        }
    }

    // calculates prizes to pay to each winner and house share
    // param _coin uint corresponding to Coin enum
    // param _winner the index of the winner of the game (0 for draw)
    // TODO: what if bets have no winner?
    function _payPrizes(Coin _coin, int _winner) private returns (bool _paid) {

        Bet[] storage bets = coinToBets[_coin];

        //get totals needed to calculate payment
        (uint _losingTotal, uint _winningTotal) = _calculateBetTotals(bets, _winner);

        //throw error if there are no winners
        require(_winningTotal > 0, "No winning bets");

        uint housePrizeTotal = 0;

        //pay each winner and sum house share 
        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].winner == _winner) {
                (uint _prize, uint _housePrize) = _calculateWinnerPrize(_losingTotal, _winningTotal, bets[i].amount);
                housePrizeTotal = housePrizeTotal.add(_housePrize);
                _transferPrize(_coin, bets[i].user, _prize);

                emit PrizePaid("Prize sent to user address", bets[i].user, _prize, block.timestamp);
            }
        }

        //transfer the house share to the owner
        _transferToOwner(housePrizeTotal, _coin);

        //set gamePaidOut
        paid = true;

        return paid;
    }

    // check outcome and status for a given Game and triggers payout to winners
    // param _gameId the id of the game to check
    // returns boolean indicating if prices where paid or not
    function checkStatusAndPay(Coin _coin, int _winner) public notDisabled onlyOwner returns (bool _paid)  {
        require(_winner > -1, "A winner hasn't been declared for this Game");
        require(!paid, "Prizes have already been paid for this Game");

        _paid = _payPrizes(_coin, _winner);

        return _paid;
    }
}
