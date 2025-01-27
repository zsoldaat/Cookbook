//
//  CloudKitShareView.swift
//  Cookbook
//
//  Created by Zac Soldaat on 2025-01-27.
//

import CloudKit
import SwiftUI

struct CloudKitShareView: UIViewControllerRepresentable {
    let share: CKShare

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let sharingController = UICloudSharingController(
            share: share,
            container: CloudKitService.container
        )
        
        sharingController.availablePermissions = [.allowReadOnly, .allowPrivate]
        sharingController.modalPresentationStyle = .formSheet
        return sharingController
    }

    func updateUIViewController(
        _ uiViewController: UIViewControllerType,
        context: Context
    ) { }
}

private final class SceneDelegate: NSObject, UIWindowSceneDelegate {

    private let cloudKitService = CloudKitService()

    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata
    ) {
        Task {
            do {
                try await cloudKitService.accept(cloudKitShareMetadata)
            } catch {
                print(error)
//                logger.error("\(error.localizedDescription, privacy: .public)")
            }
        }
    }
}
