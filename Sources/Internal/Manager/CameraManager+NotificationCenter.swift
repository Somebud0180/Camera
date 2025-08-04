//
//  CameraManager+NotificationCenter.swift of MijickCamera
//
//  Created by Tomasz Kurylik. Sending ❤️ from Kraków!
//    - Mail: tomasz.kurylik@mijick.com
//    - GitHub: https://github.com/FulcrumOne
//    - Medium: https://medium.com/@mijick
//
//  Copyright ©2024 Mijick. All rights reserved.


import Foundation
import UIKit

@MainActor class CameraManagerNotificationCenter {
    private(set) var parent: CameraManager!
}

// MARK: Setup
extension CameraManagerNotificationCenter {
    func setup(parent: CameraManager) {
        self.parent = parent
        NotificationCenter.default.addObserver(self, selector: #selector(handleSessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: parent.captureSession)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeSession), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func resumeSession() {
        let session = parent.captureSession
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if !session.isRunning {
                session.startRunning()
                
                // Force UI update on the main thread after session starts
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    // Post a notification that the camera session has resumed
                    NotificationCenter.default.post(name: Notification.Name("CameraSessionDidResume"), object: nil)
                    
                    // Trigger UI update via objectWillChange
                    self.parent.objectWillChange.send()
                }
            }
        }
    }
}
private extension CameraManagerNotificationCenter {
    @objc func handleSessionWasInterrupted() {
        parent.attributes.lightMode = .off
        parent.videoOutput.reset()
    }
}

// MARK: Reset
extension CameraManagerNotificationCenter {
    func reset() {
        NotificationCenter.default.removeObserver(self, name: .AVCaptureSessionWasInterrupted, object: parent?.captureSession)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}
