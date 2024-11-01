// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {HotelToken} from "../src/Token.sol";
import {HotelBooking} from "../src/Booking.sol";

contract DeployerScript is Script {
    function setUp() public {}

    function run() public returns (HotelToken, HotelBooking) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        console2.log("Deploying contracts with the account:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy HotelToken
        HotelToken token = new HotelToken();
        console2.log("HotelToken deployed at:", address(token));

        // Deploy HotelBooking
        HotelBooking hotelBooking = new HotelBooking(address(token));
        console2.log("HotelBooking deployed at:", address(hotelBooking));

        // Initial setup
        // Add some initial rooms
        hotelBooking.addRoom(HotelBooking.RoomCategory.Presidential, 500 ether);
        hotelBooking.addRoom(HotelBooking.RoomCategory.Deluxe, 300 ether);
        hotelBooking.addRoom(HotelBooking.RoomCategory.Suite, 200 ether);
        console2.log("Initial rooms added");

        // Mint tokens to the deployer and HotelBooking contract for testing
        uint256 initialMint = 1000000 ether;
        token.mint(deployer, initialMint);
        console2.log("Minted", initialMint / 1 ether, "tokens to deployer");

        uint256 contractMint = 10000 ether;
        token.mint(address(hotelBooking), contractMint);
        console2.log("Minted", contractMint / 1 ether, "tokens to HotelBooking contract");

        // Approve HotelBooking contract to spend tokens on behalf of deployer
        token.approve(address(hotelBooking), initialMint);
        console2.log("Approved HotelBooking contract to spend tokens on behalf of deployer");

        vm.stopBroadcast();

        console2.log("Deployment and initial setup completed");
        console2.log("HotelToken address:", address(token));
        console2.log("HotelBooking address:", address(hotelBooking));

        return (token, hotelBooking);
    }
}