#Creating all necessary files
#circom merklecircuit.circom --r1cs --wasm --sym --c

#Loading our input into the java file
cp input.json merklecircuit_8inputs_js/input.json

#Enter the merklecircuit_js directory
cd merklecircuit_8inputs_js

#Generating witness
node generate_witness.js merklecircuit_8inputs.wasm input.json witness.wtns

cp witness.wtns ../witness.wtns

#Go to previous directory 
cd ..

#Proving circuits with Zero Knowledge
#changes to 20 instead of 12
snarkjs powersoftau new bn128 16 pot12_0000.ptau -v

#Contributing to the ceremony
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

#Phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

#Set up the verification key 
snarkjs groth16 setup merklecircuit_8inputs.r1cs pot12_final.ptau merklecircuit_8inputs_0000.zkey

snarkjs zkey contribute merklecircuit_8inputs_0000.zkey merklecircuit_8inputs_0001.zkey --name="1st Contributor Name" -v

#Export the verification key
snarkjs zkey export verificationkey merklecircuit_8inputs_0001.zkey verification_key.json

#Generating the proof
snarkjs groth16 prove merklecircuit_8inputs_0001.zkey witness.wtns proof.json public.json

#Verifying the proof
snarkjs groth16 verify verification_key.json public.json proof.json
