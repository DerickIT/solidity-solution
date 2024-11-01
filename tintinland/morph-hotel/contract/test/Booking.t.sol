// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Booking.sol";
import "../src/Token.sol";

contract TestHotelBooking is Test {
    HotelBooking public bookingContract;
    HotelToken public tokenContract;

    address public owner = address(0x123);
    address public guest1 = address(0x456);
    address public guest2 = address(0x789);

    uint256 public constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        vm.startPrank(owner);
        tokenContract = new HotelToken();
        bookingContract = new HotelBooking(address(tokenContract));
        vm.stopPrank();

        vm.deal(owner, INITIAL_BALANCE);
        vm.deal(guest1, INITIAL_BALANCE);
        vm.deal(guest2, INITIAL_BALANCE);

        tokenContract.mint(owner, INITIAL_BALANCE);
        tokenContract.mint(guest1, INITIAL_BALANCE);
        tokenContract.mint(guest2, INITIAL_BALANCE);
    }

    function testAddRoom() public {
        vm.prank(owner);
        bookingContract.addRoom(HotelBooking.RoomCategory.Presidential, 100 ether);
        
        (string memory category, uint256 price, bool isAvailable, ) = bookingContract.getRoomDetails(0);
        assertEq(category, "Presidential");
        assertEq(price, 100 ether);
        assertTrue(isAvailable);
    }

    function testBookRoom() public {
        vm.prank(owner);
        bookingContract.addRoom(HotelBooking.RoomCategory.Deluxe, 50 ether);

        uint256 checkInDate = block.timestamp + 1 days;
        uint256 checkOutDate = checkInDate + 2 days;

        vm.startPrank(guest1);
        tokenContract.approve(address(bookingContract), 100 ether);
        bookingContract.bookRoomByCategory(HotelBooking.RoomCategory.Deluxe, checkInDate, checkOutDate);
        vm.stopPrank();

        (address bookedGuest, uint256 bookedCheckIn, uint256 bookedCheckOut, string memory bookedCategory, bool cancelled) = bookingContract.getBookingDetails(0);
        assertEq(bookedGuest, guest1);
        assertEq(bookedCheckIn, checkInDate);
        assertEq(bookedCheckOut, checkOutDate);
        assertEq(bookedCategory, "Deluxe");
        assertFalse(cancelled);
    }

    function testCancelBooking() public {
        vm.prank(owner);
        bookingContract.addRoom(HotelBooking.RoomCategory.Suite, 75 ether);

        uint256 checkInDate = block.timestamp + 1 days;
        uint256 checkOutDate = checkInDate + 2 days;

        vm.startPrank(guest2);
        tokenContract.approve(address(bookingContract), 150 ether);
        bookingContract.bookRoomByCategory(HotelBooking.RoomCategory.Suite, checkInDate, checkOutDate);
        
        uint256 balanceBeforeCancel = tokenContract.balanceOf(guest2);
        bookingContract.cancelBooking(0);
        uint256 balanceAfterCancel = tokenContract.balanceOf(guest2);
        vm.stopPrank();

        assertTrue(balanceAfterCancel > balanceBeforeCancel);

        (, , , , bool cancelled) = bookingContract.getBookingDetails(0);
        assertTrue(cancelled);
    }

    function testAddReview() public {
        vm.prank(owner);
        bookingContract.addRoom(HotelBooking.RoomCategory.Presidential, 100 ether);

        vm.prank(guest1);
        bookingContract.addReview(0, 5, "Excellent service!");

        (, , , HotelBooking.Review[] memory reviews) = bookingContract.getRoomDetails(0);
        assertEq(reviews.length, 1);
        assertEq(reviews[0].guest, guest1);
        assertEq(reviews[0].rating, 5);
        assertEq(reviews[0].comment, "Excellent service!");
    }

    function testWithdrawTokens() public {
        vm.prank(owner);
        bookingContract.addRoom(HotelBooking.RoomCategory.Deluxe, 50 ether);

        vm.startPrank(guest1);
        tokenContract.approve(address(bookingContract), 100 ether);
        bookingContract.bookRoomByCategory(HotelBooking.RoomCategory.Deluxe, block.timestamp + 1 days, block.timestamp + 3 days);
        vm.stopPrank();

        uint256 contractBalance = tokenContract.balanceOf(address(bookingContract));
        uint256 ownerBalanceBefore = tokenContract.balanceOf(owner);

        vm.prank(owner);
        bookingContract.withdrawTokens(contractBalance);

        uint256 ownerBalanceAfter = tokenContract.balanceOf(owner);
        assertEq(ownerBalanceAfter, ownerBalanceBefore + contractBalance);
    }

    function testGetAllRooms() public {
        vm.startPrank(owner);
        bookingContract.addRoom(HotelBooking.RoomCategory.Presidential, 100 ether);
        bookingContract.addRoom(HotelBooking.RoomCategory.Deluxe, 50 ether);
        bookingContract.addRoom(HotelBooking.RoomCategory.Suite, 75 ether);
        vm.stopPrank();

        HotelBooking.Room[] memory allRooms = bookingContract.getAllRooms();
        assertEq(allRooms.length, 3);
        assertEq(uint(allRooms[0].category), uint(HotelBooking.RoomCategory.Presidential));
        assertEq(uint(allRooms[1].category), uint(HotelBooking.RoomCategory.Deluxe));
        assertEq(uint(allRooms[2].category), uint(HotelBooking.RoomCategory.Suite));
    }

    function testSetRoomAvailability() public {
        vm.prank(owner);
        bookingContract.addRoom(HotelBooking.RoomCategory.Presidential, 100 ether);

        vm.prank(owner);
        bookingContract.setRoomAvailability(0, false);

        (, , bool isAvailable, ) = bookingContract.getRoomDetails(0);
        assertFalse(isAvailable);
    }

    function testTransferOwnership() public {
        address newOwner = address(0xABC);

        vm.prank(owner);
        bookingContract.transferOwnership(newOwner);

        assertEq(bookingContract.owner(), newOwner);
    }

    function testFailBookUnavailableRoom() public {
        vm.prank(owner);
        bookingContract.addRoom(HotelBooking.RoomCategory.Deluxe, 50 ether);

        vm.prank(owner);
        bookingContract.setRoomAvailability(0, false);

        vm.startPrank(guest1);
        tokenContract.approve(address(bookingContract), 100 ether);
        bookingContract.bookRoomByCategory(HotelBooking.RoomCategory.Deluxe, block.timestamp + 1 days, block.timestamp + 3 days);
        vm.stopPrank();
    }

    function testFailCancelNonExistentBooking() public {
        vm.prank(guest1);
        bookingContract.cancelBooking(999);
    }

    function testFailWithdrawTokensAsNonOwner() public {
        vm.prank(guest1);
        bookingContract.withdrawTokens(100 ether);
    }
}