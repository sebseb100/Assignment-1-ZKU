//Version 
pragma circom 2.0.0;

//This just imports the MiMCSponge hashing function for our use 
include "/Users/shming/Documents/MerkleTreeCircuit/mimcsponge.circom";

//Creating a template to generate some circuits 
template MerkleTree()
{
    //The input is an array with a size of 2 but it should be 4
    //This can be adjusted to 8 as well when we must input 8 array values
    //array_input is the identifier of the signal
    signal input array_input[2]; ///<could be changed to 4

    //This is the output with identifier totalHash
    signal output totalHash;                   
    ///(n_inputs,n_rounds,n_outputs)
    //Defining a component which is the hash function we'll use
    component hash_func = MiMCSponge(2, 220, 1); ///<<could be changed to 4!

    //signal input
    //assigning a value of 0 the the signal 
    hash_func.k <== 0;

    //array_input value 0 is assigned to the hash functions 0
    //array_input value 1 is assigned to the hash functions 1
    hash_func.ins[0] <== array_input[0];
    hash_func.ins[1] <== array_input[1];

    //total hash is assigned to the output[0] of the hash function
    totalHash <== hash_func.outs[0];
}

//Generating more circuits
//This tempelate accepts n 
template merkleRoot(n) 
{  
    //input it takes in is a number of leaves so the input 
    //an array of size [n]
    signal input leaves[n]; 
    //signal hashes;

    //outputs the root of the transaction hash
    signal output root;

    //creating a variable hashes that is an array size 2*n - 1
    //so an array size 8 would have 15 blocks in the merkle tree
    signal input hashes[2*n-1];

    //creating a compenent hash
    component hash[n]; 
    
    //we inherit the MerkleTree() template 

    //indexing through the merkle tree
    for(var i = 0; i < n-4; i++)
    {
        hash[i]= MerkleTree();
        //Now we can assign values 
        hash[i].array_input[0] <== leaves[i];        
        hash[i].array_input[1] <== leaves[i+1]; 

        //Hashes now contains components  
        hashes[i] <== hash[i].totalHash;   
    }
    //assigning the root to the hash at the top after the for loop finishes indexing
    root <== hashes[0];
}
//array size 4 is what this indicates
component main {public [leaves]} = merkleRoot(4);