// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title BlockRide - A Decentralized  Ride Sharing  Platform
 * @notice This smart contract allows drivers to register and riders to book rides securely using blockchain.
 */

contract BlockRide {
    address public owner;

    struct Ride {
        address rider;
        address driver;
        uint fare;
        bool isCompleted;
    }

    mapping(uint => Ride) public rides;
    uint public rideCount;

    event RideCreated(uint indexed rideId, address indexed rider, uint fare);
    event RideAccepted(uint indexed rideId, address indexed driver);
    event RideCompleted(uint indexed rideId, address indexed rider, address indexed driver);

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Create a new ride request with a specified fare.
     * @param _fare The price (in wei) that the rider is willing to pay.
     */
    function createRide(uint _fare) external payable {
        require(_fare > 0, "Fare must be greater than zero");
        rideCount++;
        rides[rideCount] = Ride({
            rider: msg.sender,
            driver: address(0),
            fare: _fare,
            isCompleted: false
        });

        emit RideCreated(rideCount, msg.sender, _fare);
    }

    /**
     * @notice Drivers can accept an available ride.
     * @param _rideId ID of the ride to accept.
     */
    function acceptRide(uint _rideId) external {
        Ride storage ride = rides[_rideId];
        require(ride.driver == address(0), "Ride already accepted");
        require(!ride.isCompleted, "Ride already completed");

        ride.driver = msg.sender;
        emit RideAccepted(_rideId, msg.sender);
    }

    /**
     * @notice Mark a ride as completed and transfer fare to driver.
     * @param _rideId ID of the ride to complete.
     */
    function completeRide(uint _rideId) external payable {
        Ride storage ride = rides[_rideId];
        require(msg.sender == ride.rider, "Only rider can confirm completion");
        require(!ride.isCompleted, "Ride already completed");
        require(ride.driver != address(0), "No driver assigned");
        require(msg.value == ride.fare, "Incorrect fare amount");

        ride.isCompleted = true;
        payable(ride.driver).transfer(msg.value);

        emit RideCompleted(_rideId, ride.rider, ride.driver);
    }
}

