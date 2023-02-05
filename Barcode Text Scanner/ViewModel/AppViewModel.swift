//
//  AppViewModel.swift
//  Barcode Text Scanner
//
//  Created by KhaleD HuSsien on 05/02/2023.
//

import Foundation
import SwiftUI
import VisionKit
import AVKit

//MARK: - ScanType
enum ScanType: String{
    case barcode
    case text
}
//MARK: - "DataScanner Acces Status Type"Cases :-
enum DataScannerAccesStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}
@MainActor
final class AppViewModel:ObservableObject{
    //MARK: - Proparties...
    @Published var dataScannerAccessStatus: DataScannerAccesStatusType = .notDetermined
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizesMultipleItems = true
    //MARK: - Computed proparity...
    var recognizedDataType: DataScannerViewController.RecognizedDataType{
        scanType == .barcode ?.barcode() : .text(textContentType: textContentType)
    }
    var headerText: String{
        if recognizedItems.isEmpty{
            return "Scanning \(scanType.rawValue)"
        }else{
            return "Recognaized \(recognizedItems) items(s)"
        }
    }
    var dataScannerViewId: Int{
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(recognizesMultipleItems)
        if let textContentType{
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    private var isScannerAvailable: Bool{
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    //MARK: - Private func...
    func requestDataScannerAccessStatus()async{
        // if the iPhone has a camera first...
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else{
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        // ask the piremision for the camera...
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            print("dataScannerAccessStatus \(dataScannerAccessStatus)")
        case .restricted,.denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
        case .notDetermined:
            // show the piremision to access the camera...
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted{
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            }else{
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
        @unknown default:
            break
        }
    }
}
