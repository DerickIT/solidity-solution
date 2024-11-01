// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HotelBooking {
    address public owner;
    IERC20 public token;

    enum RoomCategory { Presidential, Deluxe, Suite }

    struct Review {
        address guest;
        uint8 rating;
        string comment;
    }

    struct Room {
        uint256 id;
        RoomCategory category;
        uint256 pricePerNight;
        bool isAvailable;
        Review[] reviews;
    }

    struct Booking {
        address guest;
        uint256 roomId;
        uint256 checkInDate;
        uint256 checkOutDate;
        bool cancelled; // Added: Cancellation status
    }

    mapping(uint256 => Room) public rooms;
    mapping(uint256 => Booking) public roomBookings;
    uint256 public roomCount;
    uint256 public constant CANCELLATION_FEE_PERCENTAGE = 10; // Added: Cancellation fee

    event RoomAdded(uint256 roomId, string category, uint256 pricePerNight);
    event RoomBooked(uint256 roomId, address guest, uint256 checkInDate, uint256 checkOutDate);
    event RoomAvailabilityChanged(uint256 roomId, bool isAvailable);
    event ReviewAdded(uint256 roomId, address guest, uint8 rating, string comment);
    event TokensWithdrawn(address indexed owner, uint256 amount);
    event BookingCancelled(uint256 roomId, address guest, uint256 refundAmount); // Added: Cancellation event
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); // Added: Ownership transfer event


    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier roomExists(uint256 roomId) {
        require(roomId < roomCount, "Room does not exist");
        _;
    }

    modifier validRating(uint8 rating) {
        require(rating > 0 && rating <= 5, "Rating must be between 1 and 5");
        _;
    }

    modifier bookingExists(uint256 roomId) {
        require(roomId < roomCount && roomBookings[roomId].guest != address(0), "Booking does not exist");
        _;
    }

    constructor(address _token) {
        owner = msg.sender;
        token = IERC20(_token);
    }

    function addRoom(RoomCategory category, uint256 pricePerNight) public onlyOwner {
        uint256 roomId = roomCount++;
        Room storage room = rooms[roomId];
        room.id = roomId;
        room.category = category;
        room.pricePerNight = pricePerNight;
        room.isAvailable = true;
        emit RoomAdded(roomId, getCategoryString(category), pricePerNight);
    }

    function setRoomAvailability(uint256 roomId, bool isAvailable) public onlyOwner roomExists(roomId) {
        rooms[roomId].isAvailable = isAvailable;
        emit RoomAvailabilityChanged(roomId, isAvailable);
    }

    function bookRoomByCategory(RoomCategory category, uint256 checkInDate, uint256 checkOutDate) public {
        require(checkInDate < checkOutDate, "Invalid booking dates");
        require(checkOutDate > block.timestamp, "Check-out date must be in the future"); //Added: Time constraint

        uint256 roomId = findAvailableRoomByCategory(category);
        require(roomId != type(uint256).max, "No available room in the requested category");

        uint256 totalPrice = (checkOutDate - checkInDate) * rooms[roomId].pricePerNight;
        require(token.balanceOf(msg.sender) >= totalPrice, "Insufficient token balance");

        require(token.transferFrom(msg.sender, address(this), totalPrice), "Token transfer failed");

        roomBookings[roomId] = Booking({
            guest: msg.sender,
            roomId: roomId,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            cancelled: false // Added: Set initial cancellation status
        });

        rooms[roomId].isAvailable = false;
        emit RoomBooked(roomId, msg.sender, checkInDate, checkOutDate);
    }

    function addReview(uint256 roomId, uint8 rating, string memory comment) public roomExists(roomId) validRating(rating) {
        rooms[roomId].reviews.push(Review({
            guest: msg.sender,
            rating: rating,
            comment: comment
        }));
        emit ReviewAdded(roomId, msg.sender, rating, comment);
    }

    function findAvailableRoomByCategory(RoomCategory category) internal view returns (uint256) {
        for (uint256 i = 0; i < roomCount; i++) {
            if (rooms[i].category == category && rooms[i].isAvailable) {
                return rooms[i].id;
            }
        }
        return type(uint256).max; // Return a max value to indicate no available room
    }

    function getRoomDetails(uint256 roomId) public view roomExists(roomId) returns (
        string memory category, uint256 pricePerNight, bool isAvailable, Review[] memory reviews
    ) {
        Room memory room = rooms[roomId];
        return (getCategoryString(room.category), room.pricePerNight, room.isAvailable, room.reviews);
    }

    function getBookingDetails(uint256 roomId) public view roomExists(roomId) returns (
        address guest, uint256 checkInDate, uint256 checkOutDate, string memory category, bool cancelled //Added: cancelled status
    ) {
        Booking memory booking = roomBookings[roomId];
        Room memory room = rooms[roomId];
        return (booking.guest, booking.checkInDate, booking.checkOutDate, getCategoryString(room.category), booking.cancelled);
    }

    function getCategoryString(RoomCategory category) internal pure returns (string memory) {
        if (category == RoomCategory.Presidential) {
            return "Presidential";
        } else if (category == RoomCategory.Deluxe) {
            return "Deluxe";
        } else if (category == RoomCategory.Suite) {
            return "Suite";
        }
        return "";
    }

    function getAllRooms() public view returns (Room[] memory) {
        Room[] memory allRooms = new Room[](roomCount);
        for (uint256 i = 0; i < roomCount; i++) {
            allRooms[i] = rooms[i];
        }
        return allRooms;
    }

    function withdrawTokens(uint256 amount) public onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance in contract");
        require(token.transfer(owner, amount), "Token transfer failed");
        emit TokensWithdrawn(owner, amount);
    }

    function cancelBooking(uint256 roomId) public bookingExists(roomId) {
        Booking storage booking = roomBookings[roomId];
        require(booking.guest == msg.sender, "Only the guest can cancel the booking");
        require(booking.checkOutDate > block.timestamp, "Booking cannot be cancelled after check-out"); //Added: Time constraint

        uint256 refundAmount = (booking.checkOutDate - block.timestamp) * rooms[roomId].pricePerNight;
        uint256 cancellationFee = (refundAmount * CANCELLATION_FEE_PERCENTAGE) / 100;
        refundAmount -= cancellationFee;

        require(token.transfer(msg.sender, refundAmount), "Token transfer failed");
        booking.cancelled = true;
        rooms[roomId].isAvailable = true;
        emit BookingCancelled(roomId, msg.sender, refundAmount);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
