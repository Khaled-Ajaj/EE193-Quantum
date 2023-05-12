// QSD Lab 9 Tests
// Copyright 2023 The MITRE Corporation. All Rights Reserved.
//
// DO NOT MODIFY THIS FILE.

namespace Lab9 {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Preparation;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Logical;


    
    operation RunIntToQubitTest(
        testNum: Int
    ) : Unit
    {
        let numBits = Ceiling(Lg(IntAsDouble(testNum+1)));
        use reg = Qubit[numBits];

        intToQubits(testNum, reg);
        let measured = Microsoft.Quantum.Arithmetic.MeasureInteger(LittleEndian(reg));

        ApplyToEach(Reset, reg);

        if (measured != testNum){
            fail "measured integer is incorrect";
        }

        
    }


    operation runAdderTest(num1: Int, num2: Int): Int{
        
        // num1 and num2 registers must be the same size.
        let maxVal = Max([num1, num2]);
        mutable numBits = 0;

        // edge case 0 + 0
        if (maxVal == 0){
            set numBits = 1;
        }
        else{
            set numBits = Ceiling(Lg(IntAsDouble(maxVal+1)));
        }
        
        use reg1 = Qubit[numBits];
        use reg2 = Qubit[numBits];
        
        // result and carry registers
        use res = Qubit[numBits];
        use carry = Qubit[numBits];

        // setup input registers
        intToQubits(num1, reg1);
        intToQubits(num2, reg2);
        
        // run adder
        adder(reg1, reg2, res, carry);

        // append carry
        let totalSum = res + [carry[Length(carry)-1]];
        // measure sum as integer
        let intSum = MeasureInteger(LittleEndian(totalSum));

        // reset
        ApplyToEach(Reset, reg1);
        ApplyToEach(Reset, reg2);
        ApplyToEach(Reset, res);
        ApplyToEach(Reset, carry);

        
        return intSum;
    }



    @Test("QuantumSimulator")
    operation IntToQubitTest() : Unit {
        RunIntToQubitTest(0);
        RunIntToQubitTest(5);
        RunIntToQubitTest(273);
        RunIntToQubitTest(1024);
    
    }

    @Test("QuantumSimulator")
    operation fullAdderTest() : Unit {
        
        // 000 to 111
        for i in 0..7{
            let arr = IntAsBoolArray(i, 3); //[a, b, cin]
            let a = arr[0];
            let b = arr[1];
            let cin = arr[2];

            // ouputs of classical full adder
            let trueSum = Xor(cin, Xor(a,b));
            let trueCout = (a and b) or (Xor(a,b) and (cin));

            // setup inputs
            use inputReg = Qubit[3];
            use outputReg = Qubit[2];
            intToQubits(i, inputReg);

            //run adder
            fullAdder(inputReg[0], inputReg[1], inputReg[2], outputReg[0], outputReg[1]);

            //check correctness
            let resSum = M(outputReg[0]) == One;
            let resCout = M(outputReg[1]) == One;

            // clean up
            ApplyToEach(Reset, inputReg);
            ApplyToEach(Reset, outputReg);

            // check result correctness
            if (resSum != trueSum){
                fail "sum is incorrect \n";
            }

            if (resCout != trueCout){
                fail "carry-out is incorrect \n";
            }
            

        }
    
    }

    @Test("QuantumSimulator")
    operation adderTest() : Unit {
        
        for i in 0..20{
            for j in 0..20{

                let trueSum = i+j;
                let adderSum = runAdderTest(i,j);

                if (trueSum != adderSum){
                    fail $"{i} + {j} sum is incorrect: got {adderSum}, expected {trueSum}\n";
                }
                
            }
        }
    }

//     @Test("QuantumSimulator")
//     operation Exercise2SubroutineTest() : Unit {
//         for i in 0..2 {
//             mutable validMeasure = false;
//             for j in 0..9 {
//                 if not validMeasure {
//                     set validMeasure = RunSubroutineTest(5, 9, 6, 0.046875);
//                 }
//             }
//             if not validMeasure {
//                 fail "Your implementation measured 0 too many times. If you think you have the correct implementation, please try again.";
//             }

//             set validMeasure = false;
//             for j in 0..4 {
//                 if not validMeasure {
//                     set validMeasure = RunSubroutineTest(7, 15, 4, 0.03125);
//                 }
//             }
//             if not validMeasure {
//                 fail "Your implementation measured 0 too many times. If you think you have the correct implementation, please try again.";
//             }
//         }
//     }


//     @Test("QuantumSimulator")
//     function Exercise3ConvergentTest() : Unit {

//         mutable tests = [
//             // 5 mod 9
//             (0, 256, 0, 1, 9),
//             (43, 256, 1, 6, 9),
//             (85, 256, 1, 3, 9),
//             (128, 256, 1, 2, 9),
//             (171, 256, 2, 3, 9),
//             (213, 256, 5, 6, 9),

//             // 7 mod 15
//             (0, 256, 0, 1, 15),
//             (64, 256, 1, 4, 15),
//             (128, 256, 1, 2, 15),
//             (192, 256, 3, 4, 15),

//             // 11 mod 21
//             (0, 512, 0, 1, 21),
//             (85, 512, 1, 6, 21),
//             (171, 512, 1, 3, 21),
//             (256, 512, 1, 2, 21),
//             (341, 512, 2, 3, 21),
//             (427, 512, 5, 6, 21)
//         ];

//         for test in tests {
//             let (testNumerator, testDenominator, trueNumerator, trueDenominator, threshold) = test;
//             let (numerator, denominator) = Exercise3_FindPeriodCandidate(testNumerator, testDenominator, threshold);
//             if denominator == 0 {
//                 fail "You returned a denominator of 0, which should not be possible.";
//             }
//             EqualityFactI(numerator, trueNumerator, $"You gave {numerator} / {denominator}, which doesn't match the expected convergent for {testNumerator} / {testDenominator}.");
//             EqualityFactI(denominator, trueDenominator, $"You gave {numerator} / {denominator}, which doesn't match the expected convergent for {testNumerator} / {testDenominator}.");
//         }

//     }


//     @Test("QuantumSimulator")
//     operation Exercise4PeriodTest() : Unit {
//         mutable period = Exercise4_FindPeriod(9, 5);
//         EqualityFactI(period, 6, "Incorrect period found.");

//         set period = Exercise4_FindPeriod(15, 7);
//         EqualityFactI(period, 4, "Incorrect period found.");
//     }


//     @Test("QuantumSimulator")
//     function Exercise5FactorTest() : Unit {

//         EqualityFactI(Exercise5_FindFactor(9, 2, 6), -2, "Your function should have returned -2 because this period results in a factor of 1.");

//         EqualityFactI(Exercise5_FindFactor(9, 4, 3), -1, "Your function should have returned -1 because this period is odd.");

//         EqualityFactI(Exercise5_FindFactor(9, 7, 3), -1, "Your function should have returned -1 because this period is odd.");

//         mutable factor = Exercise5_FindFactor(15, 2, 4);
//         if (factor != 5 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 5 but got {factor}.";
//         }

//         set factor = Exercise5_FindFactor(15, 4, 2);
//         if (factor != 5 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 5 but got {factor}.";
//         }

//         set factor = Exercise5_FindFactor(15, 7, 4);
//         if (factor != 5 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 5 but got {factor}.";
//         }

//         set factor = Exercise5_FindFactor(15, 8, 4);
//         if (factor != 5 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 5 but got {factor}.";
//         }

//         set factor = Exercise5_FindFactor(15, 11, 2);
//         if (factor != 5 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 5 but got {factor}.";
//         }

//         set factor = Exercise5_FindFactor(15, 13, 4);
//         if (factor != 5 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 5 but got {factor}.";
//         }

//         set factor = Exercise5_FindFactor(21, 2, 6);
//         if (factor != 7 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 7 but got {factor}.";
//         }

//         EqualityFactI(Exercise5_FindFactor(21, 4, 3), -1, "Your function should have returned -1 because this period is odd.");

//         EqualityFactI(Exercise5_FindFactor(21, 5, 6), -2, "Your function should have returned -2 because this period results in a factor of 1.");

//         set factor = Exercise5_FindFactor(21, 8, 2);
//         if (factor != 7 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 7 but got {factor}.";
//         }

//         set factor = Exercise5_FindFactor(21, 10, 6);
//         if (factor != 7 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 7 but got {factor}.";
//         }

//         set factor = Exercise5_FindFactor(21, 11, 6);
//         if (factor != 7 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 7 but got {factor}.";
//         }

//         set factor = Exercise5_FindFactor(21, 13, 2);
//         if (factor != 7 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 7 but got {factor}.";
//         }

//         EqualityFactI(Exercise5_FindFactor(21, 16, 3), -1, "Your function should have returned -1 because this period is odd.");

//         EqualityFactI(Exercise5_FindFactor(21, 17, 6), -2, "Your function should have returned -2 because this period results in a factor of 1.");

//         set factor = Exercise5_FindFactor(21, 19, 6);
//         if (factor != 7 and factor != 3)
//         {
//             fail $"You returned an incorrect factor, expected 3 or 7 but got {factor}.";
//         }

//         EqualityFactI(Exercise5_FindFactor(21, 20, 2), -2, "Your function should have returned -2 because this period results in a factor of 1.");
//     }
}
