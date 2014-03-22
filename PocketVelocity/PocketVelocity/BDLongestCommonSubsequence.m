//
//  BDLongestCommonSubsequence.m
//
//  Created by Brian Dewey on 5/25/12.
//
//  Copyright 2011 Brian Dewey.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "BDLongestCommonSubsequence.h"

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@interface BDLongestCommonSubsequence ()

//
//  Make the properties read/write for us internally.
//

@property (nonatomic, strong) NSArray *firstArray;
@property (nonatomic, strong) NSArray *secondArray;
@property (nonatomic, strong) NSIndexSet *firstArraySubsequenceIndexes;
@property (nonatomic, strong) NSIndexSet *secondArraySubsequenceIndexes;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation BDLongestCommonSubsequence

@synthesize firstArray                    = firstArray_;
@synthesize secondArray                   = secondArray_;
@synthesize firstArraySubsequenceIndexes  = firstArraySubsequenceIndexes_;
@synthesize secondArraySubsequenceIndexes = secondArraySubsequenceIndexes_;

////////////////////////////////////////////////////////////////////////////////////////////////////

+ (BDLongestCommonSubsequence *)subsequenceWithFirstArray:(NSArray *)firstArray andSecondArray:(NSArray *)secondArray {
  
  BDLongestCommonSubsequence *subsequence = [[BDLongestCommonSubsequence alloc] init];
  
  subsequence.firstArray = firstArray;
  subsequence.secondArray = secondArray;

  NSMutableIndexSet *firstSubsequence = [NSMutableIndexSet indexSet];
  NSMutableIndexSet *secondSubsequence = [NSMutableIndexSet indexSet];
  
  //
  //  Step one: Build up the subsequence length array. We're finding the longest subsequences of
  //  each combination of prefixes of |firstArray| and |secondArray|.
  //
  
  NSUInteger subsequenceLengths[firstArray.count + 1][secondArray.count + 1];
  
  //
  //  Initialize everything in the first row and the first column to be zero.
  //
  
  for (int i = 0; i < firstArray.count+1; i++) {
    
    subsequenceLengths[i][0] = 0;
  }
  for (int i = 0; i < secondArray.count+1; i++) {
    
    subsequenceLengths[0][i] = 0;
  }
  
  //
  //  Build up the subsequence length array. Remember, LCS(i,j) == subsequenceLengths[i+1][j+1]
  //  (index 0 is for taking zero characters from the string, not the zeroth character)
  //
  
  for (int i = 0; i < firstArray.count; i++) {
    for (int j = 0; j < secondArray.count; j++) {
      
      id<NSObject> firstObject = [firstArray objectAtIndex:i];
      id<NSObject> secondObject = [secondArray objectAtIndex:j];
      
      if ([firstObject isEqual:secondObject]) {
        
        //
        //  If the objects at firstArray[i] and secondArray[j] are equal, then LCS(i,j) is
        //  1 + LCS(i-1,j-1).
        //
        
        subsequenceLengths[i+1][j+1] = 1 + subsequenceLengths[i][j];
        
      } else {
        
        subsequenceLengths[i+1][j+1] = MAX(subsequenceLengths[i+1][j], subsequenceLengths[i][j+1]);
      }
    }
  }
  
  //
  //  Next step: Backtrace through the |subsequenceLengths| array
  //
  
  int i = firstArray.count - 1;
  int j = secondArray.count - 1;
  while ((i >= 0) && (j >= 0) && (subsequenceLengths[i+1][j+1] > 0)) {
    
    id<NSObject> firstObject = [firstArray objectAtIndex:i];
    id<NSObject> secondObject = [secondArray objectAtIndex:j];

    if ([firstObject isEqual:secondObject]) {
      
      //
      //  The firstArray[i] and secondArray[j] are in the subsequence.
      //
      
      [firstSubsequence addIndex:i];
      [secondSubsequence addIndex:j];
      i--;
      j--;
      
    } else {
      
      //
      //  Which path back through |subsequenceLengths| gives us the longest subsequence?
      //
      
      if (subsequenceLengths[i][j+1] > subsequenceLengths[i+1][j]) {
        
        i--;
        
      } else {
        
        j--;
      }
    }
  }
  
  subsequence.firstArraySubsequenceIndexes = firstSubsequence;
  subsequence.secondArraySubsequenceIndexes = secondSubsequence;
  return subsequence;
}

////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *)description {
  
  NSMutableString *description = [NSMutableString stringWithCapacity:32];
  NSMutableArray *subsequence = [NSMutableArray arrayWithCapacity:firstArraySubsequenceIndexes_.count];
  
  [self.firstArraySubsequenceIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    
    [subsequence addObject:[self.firstArray objectAtIndex:idx]];
  }];
  [description appendFormat:@"First: %@\n Second: %@\n Subsequence: %@", [self.firstArray description], [self.secondArray description], [subsequence description]];
  return description;
}

@end
