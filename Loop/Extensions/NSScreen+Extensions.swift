//
//  NSScreen+Extensions.swift
//  Loop
//
//  Created by Kai Azim on 2023-06-14.
//

import Defaults
import SwiftUI

extension NSScreen {
    // Return the CGDirectDisplayID
    // Used in to help calculate the size a window needs to be resized to
    var displayID: CGDirectDisplayID? {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        return deviceDescription[key] as? CGDirectDisplayID
    }

    static var screenWithMouse: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })

        return screenWithMouse
    }

    var safeScreenFrame: CGRect {
        guard
            let displayID
        else {
            print("ERROR: Failed to get NSScreen.displayID in NSScreen.safeScreenFrame")
            return frame.flipY(screen: self)
        }

        let screenFrame = CGDisplayBounds(displayID)
        let visibleFrame = stageStripFreeFrame.flipY(screen: self)

        // By setting safeScreenFrame to visibleFrame, we won't need to adjust its size.
        var safeScreenFrame = visibleFrame

        // By using visibleFrame, coordinates of multiple displays won't
        // work correctly, so we instead use screenFrame's origin.
        safeScreenFrame.origin = screenFrame.origin

        safeScreenFrame.origin.y += menubarHeight
        safeScreenFrame.origin.x -= screenFrame.minX - visibleFrame.minX

        return safeScreenFrame
    }

    var stageStripFreeFrame: NSRect {
        var frame = visibleFrame

        if Defaults[.respectStageManager], StageManager.enabled, StageManager.shown {
            if StageManager.position == .leading {
                frame.origin.x += Defaults[.stageStripSize]
            }

            frame.size.width -= Defaults[.stageStripSize]
        }

        return frame
    }

    var displayBounds: CGRect {
        guard
            let displayID
        else {
            print("ERROR: Failed to get NSScreen.displayID in NSScreen.displayBounds")
            return frame.flipY(screen: self)
        }

        return CGDisplayBounds(displayID)
    }

    var menubarHeight: CGFloat {
        frame.maxY - visibleFrame.maxY
    }
}
