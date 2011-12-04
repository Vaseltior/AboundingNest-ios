/*
File:  ClockServices.h

Abstract:
    This header declares MeasureNetTimeInCPUCycles, which measures the
    execution time of a routine.  Comments below describe the driver routine
    that must be passed to MeasureNetTimeInCPUCyles and the other parameters
    to MeasureNetTimeInCPUCycles.

Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
Apple Inc. ("Apple") in consideration of your agreement to the
following terms, and your use, installation, modification or
redistribution of this Apple software constitutes acceptance of these
terms.  If you do not agree with these terms, please do not use,
install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. 
may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple.  Except
as expressly stated in this notice, no other rights or licenses, express
or implied, are granted by Apple herein, including but not limited to
any patent rights that may be infringed by your derivative works or by
other works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/


#if !defined(apple_com_Accelerate_ClockServices_h)
#define apple_com_Accelerate_ClockServices_h


#if defined(__cplusplus)
extern "C" {
#endif
    
#define IntelProcessor  (defined __i386__ || defined __x86_64__)
    
    
    // Select the timing method to be used.
    
    // Define constants to name the methods.
#define TM_TB   0   // PowerPC's time-base registers.
#define TM_TSC  1   // IA-32's time-stamp counter.
#define TM_PMC  2   // Performance monitor counters.  Works only on G5.
#define TM_UT   3   // Carbon's UpTime.
#define TM_TOD  4   // Open Unix's gettimeofday.
#define TM_MACH 5   // mach_absolute_time.
    
    // Set the method in TimingMethod.
#if defined __ppc__ || defined __ppc64__
#define TimingMethod    TM_MACH // Method to use on PowerPC.
#elif defined __i386__
#define TimingMethod    TM_MACH // Method to use on IA-32.
#elif defined __x86_64__
#define TimingMethod    TM_MACH // Method to use on 64-bit Intel.
#else
#define TimingMethod    TM_MACH // Method to use elsewhere.
#endif
    
    /*  Using the PMCs on earlier processors than the G5's requires changing
     the event number in the first chudSetPMCEvent and using only one PMC to
     count CPU cycles, because there is no event for overflow into another
     PMC.
     */
    
    // Set a flag based on the timing method in use.
#if TimingMethod == TM_PMC
    // To use the performance monitor counters, we need CHUD facilities.
#define NeedCHUD
#endif
    
    
#if TimingMethod == TM_UT
    
#include <Carbon/Carbon.h>  // For Uptime.
    
#elif TimingMethod == TM_TOD
    
#include <sys/time.h>       // For gettimeofday.
    
#elif TimingMethod == TM_MACH
    
#include <mach/mach_time.h>     // For mach_absolute_time.
    
#endif
    
    
    /*  Define ClockValue type.  Four things are defined:
     
     ClockValue is a type name.
     
     ClockMax is a value that can be used when initializing a ClockValue
     that acts as the maximum value a ClockValue can have.
     
     upper and lower are member names used to access parts of a ClockValue.
     */
#if TimingMethod == TM_UT
    
    typedef AbsoluteTime ClockValue;
#define ClockMax    { UINT32_MAX, UINT32_MAX }
#define upper       hi
#define lower       lo
    
#elif TimingMethod == TM_TOD
    
    typedef struct timeval ClockValue;
#define ClockMax    { LONG_MAX, INT_MAX };
    // (Relies on knowledge of timeval definition, unfortunately.)
#define upper       tv_sec
#define lower       tv_usec
    
#elif TimingMethod == TM_MACH
    
    typedef uint64_t ClockValue;
#define ClockMax    UINT64_MAX
    
#else
    
    typedef struct { uint32_t upper, lower; } ClockValue;
#define ClockMax    { UINT32_MAX, UINT32_MAX }
    
#endif  // TimingMethod.

    /*  ClockToCPUCycles.
     
     Convert time (in a ClockValue object) to number of CPU cycles in that time.
     */
    double ClockToCPUCycles(ClockValue t);
    
/*  Define a type describing a routine whose performance will be measured.

    The routine must take a parameter which is the number of iterations to
    execute and another parameter which is a pointer to any type of data.  To
    time any routine, write a small driver routine.  For example:

        struct MyParameters
        {
            int Argument0;
            float *Argument1;
            double Argument2;
        };


        void MyDriver(unsigned int iterations, void *data)
        {
            struct MyParameters *p = (struct MyParameters *) data;
            while (--iterations)
                MyRoutine(p->Argument0, p->Argument1, p->Argument2);
        }

    Then use MyDriver as the routine to be measured.
*/
typedef void (*RoutineToBeTimedType)(unsigned int iterations, void *data);


/*  MeasureNetTimeInCPUCycles.

    This routine measures the net amount of time it takes to execute an
    arbitrary routine.  The net time excludes overhead such as reading the
    clock value and loading the routine into cache.

    The time for multiple iterations (and multiple samples, see below) is
    measured.  This time is divided to return the time for a single iteration.

    Input:

        RoutineToBeTimedType routine.
            Address of a routine to measure.  (See typedef for this type,
            above.)

        unsigned int iterations.
            Number of iterations to be measured.

        void *data.
            Pointer to be passed to the routine.

        unsigned int samples.
            Number of samples to take.  The time a routine takes to perform
            varies due to many factors, so multiple samples are taken in an
            attempt to find the "true" time taken by the routine itself.

            On Mac OS X, the largest variance is often due to interrupts or
            process context switching.  There is no good way to exclude these
            or filter them out.  When interrupts occur, a routine takes longer
            than is required for the routine alone.  Thus, the minimum time
            observed in the samples may be the time the routine takes if no
            interrupts occur.

            By itself, this could produce an incorrectly low time.  For example,
            we might happen to start measuring just after a clock tick and
            stop just before a clock tick.  However, some fine-grain clocks are
            available, so the size of a clock tick should not bias the
            measurement too much.  Also, the measuring routine makes a control
            measurement the same way.  When N iterations are requested,
            MeasureNetTime measures the subject routine for 2 iterations and
            for N+2 iterations.  Factors that may make one measurement too low
            may also make the other measurement too low.  The measuring
            routine returns the difference, so errors should cancel to some
            extent.

    Output:
        Return value.
            Number of CPU cycles to execute one iteration.
*/
double MeasureNetTimeInCPUCycles(
        RoutineToBeTimedType routine,
        unsigned int iterations,
        void *data,
        unsigned int samples
    );


#if defined(__cplusplus)
}   // extern "C"
#endif


#endif // !defined(apple_com_Accelerate_ClockServices_h)
