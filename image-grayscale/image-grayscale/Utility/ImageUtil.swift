//
//  ImageUtil.swift
//  image-grayscale
//  
//  Created by komachi16 on 2024/10/06.
//

import UIKit
import CoreImage

class ImageUtil {

    static func applyMonochromeFilter(to image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image),
              let filter = CIFilter(name: "CIColorMonochrome") else {
            return image
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIColor(red: 0.0, green: 0.0, blue: 0.0), forKey: kCIInputColorKey)
        filter.setValue(1.0, forKey: kCIInputIntensityKey)

        let context = CIContext()
        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return image
    }

    static func fixImageOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        }

        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage ?? image
    }
}
