//
//  VersionData.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

public struct VersionData: Codable {

    public struct UpdateMessage: Codable {
        public let language: String
        public let forcedUpdate: String
        public let recommendedUpdate: String

        public init(language: String, forcedUpdate: String, recommendedUpdate: String) {
            self.language = language
            self.forcedUpdate = forcedUpdate
            self.recommendedUpdate = recommendedUpdate
        }
    }

    public let latestVersion: String
    public let minimalVersion: String
    public let updateLink: String?
    public let messages: [UpdateMessage]?

    public init(latestVersion: String, minimalVersion: String, updateLink: String? = nil, messages: [UpdateMessage]? = nil) {
        self.latestVersion = latestVersion
        self.minimalVersion = minimalVersion
        self.updateLink = updateLink
        self.messages = messages
    }
}
