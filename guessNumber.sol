// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/utils/Strings.sol";
contract guessNumber {
    //mapping the msg.sender to allocate one address to one player
    mapping(address=> User) internal users; 

    string public check_answer;
    //attempt count
    string public attempts_left = "You can try 3 times" ;
    uint256 internal attempts = 0; 
    // solution was made public first to test if the loop is correct
    uint256 private solution;
    bool internal registeredUser = false;
    bool internal startHereCalled = false;
    bool internal feesPaid = false;
    string public fees_to_pay = "the fees are 1 ether";
    uint256 internal fees = 1 ether;
    address public player;
    address private owner;
    struct User {
        string name;
        uint256 age;
    }
    // the contract starts with 20 ether
    constructor() payable{
        owner = msg.sender;
        payable(address(this)).transfer(20 ether);
    }
    function _registerToPlay(string memory name, uint256 age) public{
        require(age >= 18 && age <= 130, "You need to be 18 or older to play");
        users[msg.sender] = User(name,age);
        registeredUser = true;
    }
  

   function _startTheGame() public payable {
    //registerUser needs to be called first
    require(registeredUser == true, "You need to register to play");
    //start here needs to be called with 1 ether msg.value
    require(msg.value == fees, "You need to pay 1 ether to play");
    player = payable(msg.sender);
     //pseudo random generation
    solution = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 6;
    //pay the fees
    payable(address(this)).transfer(fees);
    //activate bool to go to the next function
    feesPaid = true;
    startHereCalled = true;
    //added 
    require(feesPaid == true, "Fee payment failed, please pay 1 ether to play");
}
receive() external payable { }
function guessTheNumber(uint256 guessNum) public payable returns(string memory, string memory)
{
        require(guessNum < 6 && guessNum >= 0 ,"your number needs to be between 0 and 5");
        require(startHereCalled == true," You need to call startHere function first");
        require(attempts < 3, " You lose, try a new game" );
        require(msg.sender== player, "you are not registered as a player");
           //guessing the number
   if (attempts <3) 
   {
        attempts++;
        attempts_left = string(abi.encodePacked("You have ", Strings.toString(3 - attempts), " left."));
            if(guessNum > solution){
                check_answer = "Your number is too high";
                return (check_answer, attempts_left);           
           
            } else if (guessNum < solution){
                check_answer = "Your number is too low";
                return (check_answer, attempts_left);           

            } else {
                check_answer = "Your number is correct. You won";
                attempts_left = "You won.Play again"; 
                payable(address(msg.sender)).transfer(2 ether);
                return (check_answer, attempts_left);           
            }
    }
         
}
    function withdraw() public payable {
        require(msg.sender == owner, "Only the Owner can withdraw");
        payable(msg.sender).transfer(address(this).balance);
        }
}
