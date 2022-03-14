pragma circom 2.0.0; 

//This just imports the MiMCSponge hashing function for our use 
include "/Users/shming/Documents/MerkleTreeCircuit/mimcsponge.circom";

//creating hash function
template hashing(n)
{
    //receives an input of arrays size n
    signal input leaves[n];
    //outputs single hash
    signal output hash;

    //creating the hash function component 
    //(n_inputs,n_rounds,n_outputs)
    component hash_function = MiMCSponge(2,220,1);

    //function takes in two inputs and outputs 1
    //we're going to receive those back the same way
    leaves[0] ==> hash_function.ins[0];
    leaves[1] ==> hash_function.ins[1];

    hash_function.k <== 0;

    //where we receive the output from the function
    hash <== hash_function.outs[0];

}

template merkleTree(n)
{
    //takes in a array size n
    signal input leaves[n];

    //outputs a single output 
    signal output rootHash;

    //create a component to find the root
    //accepts array size n
    component findRoot[n];
    var iter = 0;

    //creating a for loop to index through
    for (var i=0; i<n; i+=2)
    {
        findRoot[iter] = hashing(2);
        leaves[i] ==> findRoot[iter].leaves[0];
        leaves[i+1] ==> findRoot[iter].leaves[1];
        iter++;
    }

    component calcRoot1[2];
    var counter = 0;
    //start,stop,step
    for (var index = 0; index < n/2; index+=2)
    {
        calcRoot1[counter] = hashing(2);
        findRoot[index].hash ==> calcRoot1[counter].leaves[0];
        findRoot[index+1].hash ==> calcRoot1[counter].leaves[1];
        counter ++;
    }

    component calcRoot2 = hashing(2);
    calcRoot1[0].hash ==> calcRoot2.leaves[0];
    calcRoot1[1].hash ==> calcRoot2.leaves[1];
    rootHash <== calcRoot2.hash;
}

//accounting for 8 inputs
component main = merkleTree(8);
