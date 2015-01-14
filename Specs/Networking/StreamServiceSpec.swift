//
//  StreamServiceSpec.swift
//  Ello
//
//  Created by Sean Dougherty on 12/2/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import Foundation

import Quick
import Moya
import Nimble

class StreamServiceSpec: QuickSpec {
    override func spec() {
        describe("-loadFriendStream", {

            var streamService = StreamService()

            context("success", {
                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.endpointsClosure, stubResponses: true)
                }

                it("Calls success with an array of Activity objects", {
                    var loadedActivities:[Activity]?

                    streamService.loadFriendStream({ (activities) -> () in
                        loadedActivities = activities
                    }, failure: nil)

                    expect(countElements(loadedActivities!)) == 3
                    expect(loadedActivities![1].activityId) == "2014-06-02T00:00:00.000Z"
                    
                    let activity0:Activity = loadedActivities![0]
                    let post0:Post = activity0.subject as Post
                    
                    expect(post0.postId) == "2"
                    expect(post0.href) == "/api/edge/posts/2"
                    expect(post0.token) == "KVNldSWCvfPkjsbWcvB4mA"
                    expect(post0.collapsed) == false
                    expect(post0.viewsCount) == 100
                    expect(post0.commentsCount) == 50
                    expect(post0.repostsCount) == 3
                    
                    let element:Post.TextBodyElement = post0.content[0] as Post.TextBodyElement
                    
                    expect(element.content) == "<p>Get your <a href='/upso' class='user-mention' rel='nofollow'>@upso</a> wallpapers here <img class='emoji' title=':point_right:' alt=':point_right:' src='https://d2r3yqi5wwm1w7.cloudfront.net/images/emoji/unicode/1f449.png' height='20' width='20' align='absmiddle'> <a href='/wtf/post/wallpapers' rel='nofollow'>ello.co/wtf/post/wallpapers</a><br>You can get a matching shirt over here <img class='emoji' title=':point_right:' alt=':point_right:' src='https://d2r3yqi5wwm1w7.cloudfront.net/images/emoji/unicode/1f449.png' height='20' width='20' align='absmiddle'> <a href='http://ello.threadless.com/#/product/upso/mens' rel='nofollow' target='_blank'>ello.threadless.com</a></p>"
                    
                    let post0Author:User = post0.author!
                    expect(post0Author.userId) == "42"
                    expect(post0Author.href) == "/api/edge/users/42"
                    expect(post0Author.username) == "archer"
                    expect(post0Author.name) == "Sterling"
                    expect(post0Author.experimentalFeatures) == false
                    expect(post0Author.relationshipPriority) == "self"
                    expect(post0Author.avatarURL!.absoluteString) == "https://abc123.cloudfront.net/uploads/user/avatar/42/avatar.png"
                })
            })

            context("failure", {

                // smoke test a few failure status codes, the whole lot is tested in ElloProviderSpec

                beforeEach {
                    ElloProvider.sharedProvider = MoyaProvider(endpointsClosure: ElloProvider.errorEndpointsClosure, stubResponses: true)
                }

                context("404", {

                    beforeEach {
                        ElloProvider.errorStatusCode = .Status404
                    }

                    it("Calls failure with an error and statusCode", {

                        var loadedActivities:[Activity]?
                        var loadedStatusCode:Int?
                        var loadedError:NSError?

                        streamService.loadFriendStream({ (activities) -> () in
                            loadedActivities = activities
                        }, failure: { (error, statusCode) -> () in
                                loadedError = error
                                loadedStatusCode = statusCode
                        })

                        expect(loadedActivities).to(beNil())
                        expect(loadedStatusCode!) == 404
                        expect(loadedError!).notTo(beNil())

                        let elloNetworkError = loadedError!.userInfo![NSLocalizedFailureReasonErrorKey] as ElloNetworkError

                        expect(elloNetworkError).to(beAnInstanceOf(ElloNetworkError.self))
//                        expect(elloNetworkError.error) == "not_found"
//                        expect(elloNetworkError.errorDescription) == "The requested resource could not be found."

                    })
                    
                })

            })

        })
    }
}
