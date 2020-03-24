//
//  Protocols.swift
//  DIPL
//
//  Created by Mario Ivankovic on 09/02/2020.
//  Copyright © 2020 Mario Ivankovic. All rights reserved.
//

import Foundation

protocol UserProfileHeaderDelegate {
    
    func handleEditFollowTapped(for header: UserProfileHeader)
    func setUserStats(for header: UserProfileHeader)
    func handleFollowersTapped(for header: UserProfileHeader)
    func handleFollowingTapped(for header: UserProfileHeader)
    
}

protocol FollowCellDelegate {
    
    func handleFollowTapped(for cell: FollowLikeCell)
    
}

protocol FeedCellDelegate {
    
    func handleUsernameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton(for cell: FeedCell)
    func handleShowLikes(for cell: FeedCell)
    
}

protocol NotificationCellDelegate {
    
    func handleFollowTapped(for cell: NotificationCell)
    func handlePostTapped(for cell: NotificationCell)
    
}

protocol Printable {
    
    var description: String { get }
}
