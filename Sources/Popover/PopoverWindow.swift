//
//  PopoverWindow.swift
//  Popover
//
//  Created by Ivan Sapozhnik on 29.03.20.
//  Copyright © 2020 heavylightapps. All rights reserved.
//

import Cocoa

public class PopoverWindow: NSPanel {
    private let windowConfiguration: PopoverConfiguration
    private var childContentView: NSView?
    private var backgroundView: PopoverWindowBackgroundView?

    public static func window(with configuration: PopoverConfiguration) -> PopoverWindow {

        let window = PopoverWindow.init(contentRect: .zero, styleMask: .nonactivatingPanel, backing: .buffered, defer: true, configuration: configuration)

        return window
    }

    public override var canBecomeKey: Bool {
        return true
    }

    public override var contentView: NSView? {
        set {
            guard childContentView != newValue, let bounds = newValue?.bounds else { return }

            let antialiasingMask: CAEdgeAntialiasingMask = [.layerLeftEdge, .layerRightEdge, .layerBottomEdge, .layerTopEdge]

            backgroundView = super.contentView as? PopoverWindowBackgroundView
            if (backgroundView == nil) {
                backgroundView = PopoverWindowBackgroundView(frame: bounds, windowConfiguration: windowConfiguration)
                backgroundView?.layer?.edgeAntialiasingMask = antialiasingMask
                super.contentView = backgroundView
            }

            if (self.childContentView != nil) {
                self.childContentView?.removeFromSuperview()
            }

            childContentView = newValue
            childContentView?.translatesAutoresizingMaskIntoConstraints = false
            childContentView?.wantsLayer = true
            childContentView?.layer?.cornerRadius = windowConfiguration.cornerRadius
            childContentView?.layer?.masksToBounds = true
            childContentView?.layer?.edgeAntialiasingMask = antialiasingMask

            guard let userContentView = self.childContentView, let backgroundView = self.backgroundView else { return }
            backgroundView.addSubview(userContentView)

            let left = windowConfiguration.lineWidth + windowConfiguration.contentInset.left
            let right = windowConfiguration.lineWidth + windowConfiguration.contentInset.right
            let top = windowConfiguration.arrowHeight + windowConfiguration.lineWidth + windowConfiguration.contentInset.top
            let bottom = windowConfiguration.lineWidth + windowConfiguration.contentInset.bottom

            NSLayoutConstraint.activate([
                userContentView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: left),
                userContentView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -right),
                userContentView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: top),
                userContentView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -bottom)
            ])
        }

        get {
            childContentView
        }
    }

    public override func frameRect(forContentRect contentRect: NSRect) -> NSRect {
        NSMakeRect(NSMinX(contentRect), NSMinY(contentRect), NSWidth(contentRect), NSHeight(contentRect) + windowConfiguration.arrowHeight)
    }

    private init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool, configuration: PopoverConfiguration) {
        windowConfiguration = configuration
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)

        isOpaque = false
        hasShadow = true
        level = .statusBar
        animationBehavior = .utilityWindow
        backgroundColor = .clear
        collectionBehavior = [.canJoinAllSpaces, .ignoresCycle]
        appearance = NSAppearance.current
    }
}