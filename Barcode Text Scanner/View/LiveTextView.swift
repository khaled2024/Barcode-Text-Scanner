//
//  LiveTextView.swift
//  Barcode Text Scanner
//
//  Created by KhaleD HuSsien on 08/02/2023.
//

import Foundation
import SwiftUI
import VisionKit

@MainActor
struct LiveTextView: UIViewRepresentable{
    // Proparties...
    let image: UIImage
    let imageView = LiveTextImageView()
    let analyzer = ImageAnalyzer()
    let interaction = ImageAnalysisInteraction()
    
    //MARK: - Private func...
    func makeUIView(context: Context) -> some UIView {
        imageView.image = image
        imageView.addInteraction(interaction)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let image = imageView.image else{return}
        Task{ @MainActor in
            let configuration = ImageAnalyzer.Configuration([.text,.machineReadableCode])
            do{
                let analysis = try await analyzer.analyze(image, configuration: configuration)
                interaction.analysis = analysis
                interaction.preferredInteractionTypes = .automatic
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}
class LiveTextImageView: UIImageView{
    override var intrinsicContentSize: CGSize{
        .zero
    }
}
