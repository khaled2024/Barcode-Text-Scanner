//
//  ContentView.swift
//  Barcode Text Scanner
//
//  Created by KhaleD HuSsien on 05/02/2023.
//

import SwiftUI
import VisionKit
import PhotosUI
struct ContentView: View {
    //MARK: - Proparties:-
    @EnvironmentObject var vm: AppViewModel
    private let textContentType: [(title: String,textContentType: DataScannerViewController.TextContentType?)] = [
        ("All",.none),
        ("URL",.URL),
        ("Phone",.telephoneNumber),
        ("Email",.emailAddress),
        ("Address",.fullStreetAddress)
    ]
    //MARK: - Body :-
    var body: some View {
        switch vm.dataScannerAccessStatus{
        case .scannerAvailable:
            mainView
        case .cameraNotAvailable:
            VStack{
                ErrorImageView
                Text("Your device doesn't have a camera!")
            }
            .padding()
        case .scannerNotAvailable:
            VStack(spacing: 10) {
                ErrorImageView
                Text("Your device doesn't have support for scanning barcode with this app!")
                    .font(.headline)
                Text("Your iPhone must be A12 Bionic CPU and later running iOS 16")
                    .font(.subheadline)
            }
            .multilineTextAlignment(.center)
            .padding()
        case .cameraAccessNotGranted:
            VStack{
                ErrorImageView
                Text("Please access the camera in setting!")
            }
            .padding()
        case .notDetermined:
            Text("Requesting camera access!")
                .padding()
        }
    }
    //MARK: - Helper views
    //MARK: - Main View...
    private var mainView: some View{
        // Data Scanner:-
        liveImageFeed
            .background(Color.gray.opacity(0.3))
            .ignoresSafeArea()
            .id(vm.dataScannerViewId)
        // present the sheet :-
        ///(if u want to present another sheet above the firest sheet present it inside the first sheet not after the first sheet...)
        // First Sheet...
            .sheet(isPresented: .constant(true), content: {
                bottomContainerView
                    .background(.ultraThinMaterial)
                    .presentationDetents([.medium,.fraction(0.25)])
                    .presentationDragIndicator(.visible)
                // to didn't make user dismiss the sheet...
                    .interactiveDismissDisabled()
                /// disable the bottom sheet if there was a photo to capture...
                    .disabled(vm.capturePhoto != nil)
                    .onAppear{
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let controller = windowScene.windows.first?.rootViewController?.presentedViewController else{return}
                        controller.view.backgroundColor = .clear
                    }
                //Second Sheet...
                    .sheet(item: $vm.capturePhoto) { photo in
                        ZStack(alignment: .topLeading){
                            LiveTextView(image: photo.image)
                            Button {
                                /// that will dismiss the sheet...
                                vm.capturePhoto = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                            }
                            .foregroundColor(.white)
                            .padding([.top,.trailing])
                        }
                        .edgesIgnoringSafeArea(.bottom)
                    }
            })
            .onChange(of: vm.scanType, perform: {_ in vm.recognizedItems = []})
            .onChange(of: vm.textContentType, perform: {_ in vm.recognizedItems = []})
            .onChange(of: vm.recognizesMultipleItems, perform: {_ in vm.recognizedItems = []})
            .onChange(of: vm.selectedPhotoPickerItem) { newValue in
                guard let newValue = newValue else{return}
                Task{ @MainActor in
                    guard let data = try? await newValue.loadTransferable(type: Data.self),
                          let image = UIImage(data: data)
                    else{return}
                    self.vm.capturePhoto = IdentifiableImage(image: image)
                }
            }
    }
    //MARK: - liveImageFeed...
    @ViewBuilder
    private var liveImageFeed: some View{
        if let capturePhoto = vm.capturePhoto{
            Image(uiImage: capturePhoto.image)
                .resizable()
                .scaledToFit()
        }else{
            DataScannerView(recognizedItems: $vm.recognizedItems,
                            recognizedDataType: vm.recognizedDataType,
                            recognizesMultipleItems: vm.recognizesMultipleItems,
                            shouldCapturePhoto: $vm.shouldCapurePhoto,
                            capturePhoto: $vm.capturePhoto)
        }
    }
    //MARK: - Header View...
    private var headerView: some View{
        VStack{
            HStack{
                Picker("Scan Type", selection: $vm.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)
                }
                .pickerStyle(.segmented)
                Toggle("Scan multiple", isOn: $vm.recognizesMultipleItems)
            }
            .padding(.top)
            if vm.scanType == .text{
                Picker("Text content type", selection: $vm.textContentType) {
                    ForEach(textContentType,id: \.self.textContentType) {option in
                        Text(option.title).tag(option.textContentType)
                    }
                    
                }.pickerStyle(.segmented)
            }
            HStack{
                Text(vm.headerText)
                Spacer()
                // 2 button
                Button {
                    vm.shouldCapurePhoto = true
                } label: {
                    Image(systemName: "camera.circle")
                        .imageScale(.large)
                        .font(.system(size: 30))
                }
                PhotosPicker(selection: $vm.selectedPhotoPickerItem,matching: .images) {
                    Image(systemName: "photo.circle")
                        .imageScale(.large)
                        .font(.system(size: 30))
                }
            }
        }
        .padding(.horizontal)
    }
    //MARK: - BottomContainerView...
    private var bottomContainerView: some View{
        VStack{
            headerView
            ScrollView{
                LazyVStack(alignment: .leading,spacing: 16){
                    ForEach(vm.recognizedItems) { item in
                        switch item{
                        case.barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknown barcode")
                        case.text(let text):
                            Text(text.transcript)
                        @unknown default:
                            Text("Unknown")
                        }
                    }
                }
                .padding()
            }
        }
    }
    //MARK: - ErrorImageView...
    private var ErrorImageView: some View{
        Image("error")
            .resizable()
            .scaledToFill()
            .frame(width: 100, height: 100, alignment: .center)
    }
}

