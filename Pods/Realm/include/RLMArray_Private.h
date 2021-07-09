////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import <Realm/RLMArray.h>
#import <Realm/RLMConstants.h>

@class RLMObjectBase, RLMProperty;

NS_ASSUME_NONNULL_BEGIN

@interface RLMArray ()
- (instancetype)initWithObjectClassName:(NSString *)objectClassName;
- (instancetype)initWithObjectType:(RLMPropertyType)type optional:(BOOL)optional;
- (NSString *)descriptionWithMaxDepth:(NSUInteger)depth;
- (void)setParent:(RLMObjectBase *)parentObject property:(RLMProperty *)property;
- (void)replaceAllObjectsWithObjects:(NSArray *)objects;
@end

@interface RLMManagedArray : RLMArray
- (instancetype)initWithParent:(RLMObjectBase *)parentObject property:(RLMProperty *)property;
@end

void RLMArrayValidateMatchingObjectType(RLMArray *array, id value);

NS_ASSUME_NONNULL_END
