//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";


//TODO: add Admin role so users can create an event and open betting on it

/* 
This class includes all the storage vars belonging to Game contract that Bettable and Payoutable
need to handle bettings and payout calculations
*/

contract Gameable is Ownable {

     bool public paid;
     int public winner;

    // Coins is the default network transaction coin 'Default' and acceptes ERC20 tokens
    enum Coin { Default, USDC, USDT, DAI }

    struct Bet {
        address payable user;
        Coin coin;
        uint amount;
        int winner;  // index of the winner in _game.participants[], 0 for draw, -1 for no winner
    }

    mapping(address => Bet[]) internal userToBets;
    mapping(Coin => Bet[]) internal coinToBets;
    mapping(Coin => address) internal coinToAddress;

    // coinToAddress is populated with addresses corresponding to the contracts in Ethereum Mainnet
    constructor() {
        coinToAddress[Coin.USDC] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        coinToAddress[Coin.USDT] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        coinToAddress[Coin.DAI] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

}
