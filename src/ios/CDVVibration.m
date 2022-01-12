//
//  CDVVibration.m
//  Vibration-Obj-c
//
//  Created by MacBook on 17.08.2021.
//

#import "CDVVibration.h"

@interface CDVVibration ()
@property (nonatomic, retain) IBOutlet CHHapticEngine *engine;

@end

@implementation CDVVibration


// MARK: - Public

- (void)vibrate:(CDVInvokedUrlCommand *) ms {

//    if ([ms isKindOfClass: [NSNumber class]]) {
//        [self singleVibration: ms];
//    } else if ([ms isKindOfClass:[NSArray class]]) {
//        [self multipleVibration: ms];
//    }
//

    NSArray* arguments = ms.arguments;
    if ([arguments isKindOfClass:[NSArray class]]) {
        if ([arguments count] > 1) {
            [self multipleVibration: arguments];
        } else {
            [self singleVibration: [arguments firstObject]];
        }
    }
}

// MARK: - Initial

-(void)initialEngine {

    NSError* error = nil;
    self.engine = [[CHHapticEngine alloc] initAndReturnError:&error];
    // Start the haptic engine.
    [self.engine startAndReturnError:&error];
}

// MARK: - Control

-(void)stop {
    // Stop the engine.
    [self.engine stopWithCompletionHandler:^(NSError* error) {
        // Insert code to call after engine stops.
    }];
}

// MARK: - Private helpers methods

-(void)singleVibration: (NSNumber*) ms {
    if (![CHHapticEngine capabilitiesForHardware].supportsHaptics) {
        return;
    }
    [self stop];
    [self initialEngine];
    //---------------------------------------------------------------------
    float validSeconds = [self convertingSecondsToValid: [ms intValue]];
    float seconds = validSeconds / 1000.0f; // in ms

    CHHapticEvent* event = [[CHHapticEvent alloc] initWithEventType: CHHapticEventTypeHapticContinuous parameters:@[] relativeTime:0 duration: seconds];

    NSError* error = nil;
    CHHapticPattern* pattern = [[CHHapticPattern alloc] initWithEvents:@[event] parameters:@[] error:&error];
    id player = [self.engine createPlayerWithPattern:pattern error:&error];
    [player startAtTime:0 error:&error];
}

-(void)multipleVibration: (NSArray*) mss {
    if (![CHHapticEngine capabilitiesForHardware].supportsHaptics) {
        return;
    }
    [self stop];
    [self initialEngine];
    //---------------------------------------------------------------------
    NSArray* validArray = [[self convertingSecondsArrayToValid: mss] copy];
    NSMutableArray* arrays = [self splittedArrayFrom: validArray divideCount: 2];
    NSMutableArray* events = [[NSMutableArray alloc] init];
    double relativeTime = 0;

    for(int i = 0; i < [arrays count]; i += 1 ) {

        NSArray* subArray = [arrays objectAtIndex: i];
        float value = [(NSNumber *)[subArray objectAtIndex: 0] intValue];
        float duration = value / 1000.0f; // in ms

        CHHapticEvent* event = [[CHHapticEvent alloc] initWithEventType: CHHapticEventTypeHapticContinuous parameters:@[] relativeTime: relativeTime duration: duration];

        if ((1 < [subArray count])) {
            double delay = [(NSNumber *)[subArray objectAtIndex: 1] intValue] / 1000;
            relativeTime += duration + delay;
        }
        [events addObject: event];
    }

    NSError* error = nil;
    CHHapticPattern* pattern = [[CHHapticPattern alloc] initWithEvents: events parameters:@[] error: &error];
    id player = [self.engine createPlayerWithPattern:pattern error:&error];
    [player startAtTime:0 error:&error];
}


-(NSMutableArray*)splittedArrayFrom: (NSArray *) inputArray divideCount: (NSInteger) cnt {
    NSMutableArray *mainArray = [[NSMutableArray alloc]init];
    int itemsRemaining = (int)[inputArray count];

    for (int i =0;i*cnt<[inputArray count]; i++) {
        NSRange range = NSMakeRange(i*cnt, MIN(cnt, itemsRemaining));
        NSArray *childArray = [inputArray subarrayWithRange:range];
        [mainArray addObject:childArray];
        itemsRemaining = (int)(itemsRemaining - range.length);
    }
    return mainArray;
}

-(NSInteger)convertingSecondsToValid: (NSInteger) value {
    return value > 5000 ? 5000 : value;
}

-(NSMutableArray*)convertingSecondsArrayToValid: (NSArray *) values {
    NSMutableArray* newArr = [values mutableCopy];
    NSInteger index = 0;

    for(int i = 0; i < [newArr count]; i += 1 ){
        NSInteger value = [(NSNumber *)[newArr objectAtIndex:i] intValue];
        if (value > 5000) {
            NSNumber *number = [NSNumber numberWithInt: 5000];
            [newArr insertObject: number atIndex: i];
        }
        index += 1;
    }
    return newArr;
}

@end
