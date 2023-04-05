// Intro to Quantum Software Development
// Lab 8: Quantum Fourier Transform
// Copyright 2023 The MITRE Corporation. All Rights Reserved.
//
// Due 4/3 at 6:00PM ET:
//  - Completed exercises and evidence of unit tests passing uploaded to GitHub.

namespace Lab8 {

    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Diagnostics;


    /// # Summary
    /// In this exercise, you must implement the quantum Fourier transform
    /// circuit. The operation should be performed in-place, meaning the
    /// time-domain output should be in the same order as the frequency-domain
    /// input, not reversed.
    ///
    /// # Input
    /// ## register
    /// A qubit register with unknown length in an unknown state. It is of type
    /// Microsoft.Quantum.Arithmetic.BigEndian, which can be used with some
    /// arithmetic library operations. Use the unwrap operator (!) to access
    /// the underlying array. For example, to address the first qubit in the
    /// register, use `register![0]`. For more info, see:
    /// https://learn.microsoft.com/en-us/azure/quantum/user-guide/language/expressions/itemaccessexpressions#item-access-for-user-defined-types
    operation Exercise1 (register : BigEndian) : Unit is Adj + Ctl {
        // Hint: There are two operations you may want to use here:
        //  1. Your implementation of register reversal in Lab 2, Exercise 2.
        //  2. The Microsoft.Quantum.Intrinsic.R1Frac() gate.
        let n = Length(register!);

        

        for i in 0..n-1{
            H(register![i]);
            
            for j in 1..n-i-1{
                Controlled Microsoft.Quantum.Intrinsic.R1Frac([register![i+j]], (2, j+1, register![i]));
            }
        }

        for i in 0..(n-1)/2{
            if (n-i-1 != i){
                SWAP(register![n-i-1], register![i]);
            }
            
        }

        
        
    }




    /// # Summary
    /// In this exercise, you are given a quantum register with a single sine
    /// wave encoded into the amplitudes of each term in the superposition.
    ///
    /// For example: the first sample of the wave will be the amplitude of the
    /// |0> term, the second sample of the wave will be the amplitude of the
    /// |1> term, the third will be the amplitude of the |2> term, and so on.
    ///
    /// Your goal is to find the frequency of these samples, and return that
    /// frequency.
    ///
    /// # Input
    /// ## register
    /// The register which contains the samples of the sine wave in the
    /// amplitudes of its terms.
    ///
    /// ## sampleRate
    /// The number of samples per second that were used to collect the
    /// original samples. You will need this to retrieve the correct
    /// frequency.
    ///
    /// # Output
    /// The frequency of the sine wave.
    ///
    /// # Remarks
    /// When using the DFT to analyze the frequency components of a purely real
    /// signal, typically the second half of the output is thrown away, since
    /// these represent frequencies too fast to show up in the time domain.
    /// Here, we can't just "throw away" a part of the output, so if we measure
    /// a value above N/2, it will need to be mirrored about N/2 to recover the
    /// actual frequency of the input sine wave. For more info, see:
    /// https://en.wikipedia.org/wiki/Nyquist_frequency
    operation Exercise2 (
        register : BigEndian,
        sampleRate : Double
    ) : Double {

        Exercise1(register);
        
        let N = IntAsDouble(2^(Length(register!)));


        mutable measured = MeasureInteger(BigEndianAsLittleEndian(register));
        mutable measuredDouble = IntAsDouble(measured);
        

        if (measuredDouble > N/2.0){
            set measuredDouble = N-measuredDouble;
        }

        set measuredDouble = (measuredDouble*sampleRate)/N;

        return measuredDouble;

    }
}
