//
//  DataScannerView.swift
//  Barcode Text Scanner
//
//  Created by KhaleD HuSsien on 05/02/2023.
//

import Foundation
import SwiftUI
import VisionKit

struct DataScannerView:UIViewControllerRepresentable {
    //MARK: - Proparties...
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    // For Live Text View
    @Binding var shouldCapturePhoto: Bool
    @Binding var capturePhoto: IdentifiableImage?
    
    // MakeUIViewController...
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true)
        return vc
    }
    // capturePhoto:-
    private func capturePhoto(dataScannerVC: DataScannerViewController){
        Task{ @MainActor in
            do{
                let photo = try await dataScannerVC.capturePhoto()
                self.capturePhoto = IdentifiableImage(image: photo)
            }catch{
                print(error.localizedDescription)
            }
            self.shouldCapturePhoto = false
        }
    }
    //UpdateUIViewController(fro SwiftUI to UIKit)...
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
        // if user press camera buttom
        if shouldCapturePhoto{
            capturePhoto(dataScannerVC: uiViewController)
        }
    }
    // this func make the changes from UIKit to SwiftUI...
    func makeCoordinator() -> coordinator {
        coordinator(recognizedItems: $recognizedItems)
    }
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: coordinator) {
        uiViewController.stopScanning()
    }
   
    
    //MARK: - coordinator incharge all stuff of DataScannerViewControllerDelegate...
    class coordinator: NSObject,DataScannerViewControllerDelegate{
        @Binding var recognizedItems: [RecognizedItem]
        init(recognizedItems: Binding<[RecognizedItem]>) {
            self._recognizedItems = recognizedItems
        }
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("did tap on\(item)")
        }
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
            print("didAddItems \(addedItems)")
        }
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter({ item in
                removedItems.contains(where: {$0.id == item.id})
            })
            print("did remoce items \(removedItems)")
        }
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("become unavailable with error \(error.localizedDescription)")
        }
    }
}
struct IdentifiableImage: Identifiable{
    let id = UUID()
    let image: UIImage
}
 
