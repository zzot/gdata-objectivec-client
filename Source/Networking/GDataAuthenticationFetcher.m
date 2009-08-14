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
//  GDataAuthenticationFetcher.m
//

#import "GDataAuthenticationFetcher.h"
#import "GDataUtilities.h"

@implementation GDataAuthenticationFetcher
+ (GDataHTTPFetcher *)authTokenFetcherWithUsername:(NSString *)username
                                          password:(NSString *)password
                                           service:(NSString *)serviceID // code for the service to be used, like "cl"
                                            source:(NSString *)source // companyName-applicationName-versionID
                                      signInDomain:(NSString *)domain // nil for www.google.com
                                       accountType:(NSString *)accountType // nil for HOSTED_OR_GOOGLE
                              additionalParameters:(NSDictionary *)params
                                     customHeaders:(NSDictionary *)headers { // nil or map of custom headers to set

  if ([username length] == 0 || [password length] == 0) return nil;

  if ([domain length] == 0) {
    domain = @"www.google.com";
  }

  if (accountType == nil) {
    accountType = @"HOSTED_OR_GOOGLE";
  }

  // unit tests may authenticate to a server running locally with
  // a domain like "localhost:8080"
  NSString *scheme = [domain hasPrefix:@"localhost:"] ? @"http" : @"https";

  NSString *urlTemplate = @"%@://%@/accounts/ClientLogin";
  NSString *authURLString = [NSString stringWithFormat:urlTemplate,
                             scheme, domain];

  NSURL *authURL = [NSURL URLWithString:authURLString];

  NSMutableURLRequest *request;
  request = [NSMutableURLRequest requestWithURL:authURL
                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                timeoutInterval:60];

  // add custom request headers
  NSEnumerator *keyEnum = [headers keyEnumerator];
  NSString *key;
  while ((key = [keyEnum nextObject]) != nil) {
    NSString *value = [headers objectForKey:key];
    [request setValue:value forHTTPHeaderField:key];
  }

  NSString *postTemplate = @"Email=%@&Passwd=%@&source=%@&service=%@&accountType=%@";
  NSString *postString = [NSString stringWithFormat:postTemplate,
                        [GDataUtilities stringByURLEncodingForURI:username],
                        [GDataUtilities stringByURLEncodingForURI:password],
                        [GDataUtilities stringByURLEncodingForURI:source],
                        [GDataUtilities stringByURLEncodingForURI:serviceID],
                        [GDataUtilities stringByURLEncodingForURI:accountType]];

  // add custom post body parameters to the post string; typically params is
  // nil, but it may have captcha token and answer
  keyEnum = [params keyEnumerator];
  while ((key = [keyEnum nextObject]) != nil) {
    NSString *value = [params objectForKey:key];
    postString = [postString stringByAppendingFormat:@"&%@=%@",
                  key, [GDataUtilities stringByURLEncodingForURI:value]];
  }

  GDataHTTPFetcher* fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
  [fetcher setPostData:[postString dataUsingEncoding:NSUTF8StringEncoding]];

  // We're avoiding +[NSURCredential credentialWithUser:password:persistence:]
  // because it fails to autorelease itself on OS X 10.4 .. 10.5.x
  // rdar://5596278
  NSURLCredential *cred;
  cred = [[[NSURLCredential alloc] initWithUser:username
                                       password:password
                                    persistence:NSURLCredentialPersistenceForSession] autorelease];
  [fetcher setCredential:cred];

  [fetcher setIsRetryEnabled:YES];

  return fetcher;
}

@end
