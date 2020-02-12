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
    
    func handleFollowTapped(for cell: FollowCell)
    
}
