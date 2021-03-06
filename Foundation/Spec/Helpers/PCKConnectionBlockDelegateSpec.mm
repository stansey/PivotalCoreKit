#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import "CDRSpecHelper.h"
#else
#import <Cedar/CDRSpecHelper.h>
#endif

#import "PCKConnectionBlockDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PCKConnectionBlockDelegateSpec)

describe(@"PCKConnectionBlockDelegate", ^{
    __block NSURLConnection *connection;
    __block PCKConnectionBlockDelegate *delegate;
    __block NSURLResponse *receivedResponse;
    __block NSData *receivedData;
    __block NSError *receivedError;

    __block NSURLResponse *sentResponse;

    beforeEach(^{
        receivedResponse = nil;
        receivedData = nil;
        receivedError = nil;

        connection = fake_for([NSURLConnection class]);

        delegate = [PCKConnectionBlockDelegate delegateWithBlock:^(NSURLResponse *response, NSData *data, NSError *error) {
            receivedResponse = response;
            receivedData = data;
            receivedError = error;
        }];

        sentResponse = [[[NSURLResponse alloc] init] autorelease];

        [delegate connection:connection didReceiveResponse:sentResponse];
        [delegate connection:connection didReceiveData:[@"Hello" dataUsingEncoding:NSUTF8StringEncoding]];
        [delegate connection:connection didReceiveData:[@" World" dataUsingEncoding:NSUTF8StringEncoding]];
    });

    context(@"when the request completes successfully", ^{
        it(@"should call the block, passing in the response, the data, and no error", ^{
            [delegate connectionDidFinishLoading:connection];
            receivedResponse should equal(sentResponse);
            NSString *receivedString = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
            receivedString should equal(@"Hello World");
            receivedError should be_nil;
        });
    });

    context(@"when the request fails", ^{
        it(@"should call the block, passingin the response, nil for the data, and the passed in error", ^{
            NSError *error = [[[NSError alloc] init] autorelease];
            [delegate connection:connection didFailWithError:error];
            receivedResponse should equal(sentResponse);
            receivedData should be_nil;
            receivedError should equal(error);
        });
    });
});

SPEC_END
