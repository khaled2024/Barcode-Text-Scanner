//
//  ContentView.swift
//  LiveTextMac
//
//  Created by KhaleD HuSsien on 08/02/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = AppViewModel()
    var body: some View {
        if vm.isLiveTextSupported{
            mainView
        }else{
            VStack(spacing: 10) {
                Text("Your device doesn't have support for scanning barcode with this app!")
                    .font(.headline)
                Text("Your iPhone must be A12 Bionic CPU and later running iOS 16")
                    .font(.subheadline)
            }
            .multilineTextAlignment(.center)
            .padding()
        }
    }
    @ViewBuilder
    private var mainView: some View{
        if let selectedImage = vm.selectedImage{
            ZStack(alignment: .topTrailing) {
                LiveTextView(image: selectedImage)
                Button {
                    vm.selectedImage = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                }
                .buttonStyle(.borderless)
                .padding()
            }
        }else{
            importView
        }
    }
    @ViewBuilder
    private var importView: some View{
        Button {
            vm.importImage()
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.gray.opacity(0.5))
                .overlay{
                    VStack(spacing: 32) {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                        Text("Drag and drop image\n or\n Click to select")
                    }
                }
                .frame(maxWidth: 320,maxHeight: 320)
                .padding()
                .onDrop(of: ["public.file-url"], isTargeted: nil, perform: vm.handleOnDrop(providers:))
        }
        .buttonStyle(.borderless)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
