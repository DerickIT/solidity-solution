// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract InsertionSort {
    
    function sort(uint[] memory arr) public pure returns (uint[] memory) {
        for (uint i = 1; i < arr.length; i++) {
            uint key = arr[i];
            int j = int(i) - 1;
            
            while (j >= 0 && arr[uint(j)] > key) {
                arr[uint(j + 1)] = arr[uint(j)];
                j--;
            }
            
            arr[uint(j + 1)] = key;
        }
        
        return arr;
    }
    
    function testSort() public pure returns (uint[] memory) {
        uint[] memory testArray = new uint[](4);
        testArray[0] = 2;
        testArray[1] = 5; 
        testArray[2] = 3;
        testArray[3] = 1;
        
        return sort(testArray);
    }
}
