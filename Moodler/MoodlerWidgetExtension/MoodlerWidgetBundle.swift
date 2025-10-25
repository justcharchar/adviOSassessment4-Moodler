//
//  MoodlerWidgetBundle.swift
//  MoodlerWidgetExtension
//
//  Created by Owen Herianto on 25/10/2025.
//

import WidgetKit
import SwiftUI

@main
struct MoodlerWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        MoodlerWidget()
    }
}
