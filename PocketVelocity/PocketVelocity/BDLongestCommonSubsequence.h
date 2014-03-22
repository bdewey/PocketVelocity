//
//  BDLongestCommonSubsequence.h
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

#import <UIKit/UIKit.h>

//
//  This class represents a longest common subsequence between two arrays.
//  If the two arrays have more than one subsequence, the class represents just one.
//

@interface BDLongestCommonSubsequence : NSObject

//
//  A subsequence is defined between two arrays. It is represented as a set of indexes in both
//  the first and second arrays where the array elements at each index are equal (as defined by
//  the |isEqual:| message).
//

@property (nonatomic, strong, readonly) NSArray *firstArray;
@property (nonatomic, strong, readonly) NSArray *secondArray;

//
//  The elements of the first array that belong to the longest subsequence.
//

@property (nonatomic, strong, readonly) NSIndexSet *firstArraySubsequenceIndexes;

//
//  The elements of the second array that belong to the longest subsequence.
//

@property (nonatomic, strong, readonly) NSIndexSet *secondArraySubsequenceIndexes;


//
//  And finally, here's how you create one of these objects... just give it the two arrays, and
//  you can read off the subsequence indexes right away.
//  
//  Note it's possible for there to be no common subsequence.
//

+ (BDLongestCommonSubsequence *)subsequenceWithFirstArray:(NSArray *)firstArray andSecondArray:(NSArray *)secondArray;

@end
