/* Copyright (c) 2009 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  GDataEntryMap.m
//

#import "GDataEntryMap.h"
#import "GDataMapConstants.h"

@implementation GDataEntryMap

+ (id)mapEntryWithTitle:(NSString *)str {

  GDataEntryMap *obj = [[[self alloc] init] autorelease];

  [obj setNamespaces:[GDataMapConstants mapsNamespaces]];
  [obj setTitleWithString:str];

  return obj;
}

#pragma mark -

+ (NSString *)standardEntryKind {
  return kGDataCategoryMap;
}

+ (void)load {
  [self registerEntryClass];
}

+ (NSString *)defaultServiceVersion {
  return kGDataMapsDefaultServiceVersion;
}

// convenience accessors

- (NSURL *)featuresFeedURL {
  NSURL *featuresFeedURL = [[self content] sourceURL];
  return featuresFeedURL;
}

@end
