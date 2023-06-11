//
//  Permission.swift
//  ScannetQRApp
//
//  Created by Kristi on 31.05.2023.
//

import SwiftUI

// Перечисление разрешений камеры

enum Permission: String {
    case idle = "Not Determined"
    case approved = "Access Granted"
    case denied = "Access Denied"
}
