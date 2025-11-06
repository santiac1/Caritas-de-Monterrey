//
//  ImageLoader.swift
//  CaritasMonterrey
//
//  Created by Alumno on 20/10/25.
//

import Combine
import Foundation
import SwiftUI
import UIKit

final class ImageLoader: ObservableObject {
    @Published var image: Image?

    private var cancellable: AnyCancellable?
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    deinit {
        cancel()
    }

    func load() {
        guard let url else { return }

        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .map { uiImage -> Image? in
                guard let uiImage else { return nil }
                return Image(uiImage: uiImage)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.image = $0 }
    }

    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}
