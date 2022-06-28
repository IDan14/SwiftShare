//
//  PDFCreator.swift
//  LearnMore
//
//  Created by Dan ILCA on 27/11/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import PDFKit
import SwiftyBeaver

open class PDFCreator {

    public enum PageSize {
        case a3
        case a4
        case a5
        case a6
        case letter

        public var inInches: CGSize {
            switch self {
            case .a3:
                return CGSize(width: 11.69, height: 16.54)
            case .a4:
                return CGSize(width: 8.27, height: 11.69)
            case .a5:
                return CGSize(width: 5.83, height: 8.27)
            case .a6:
                return CGSize(width: 4.13, height: 5.83)
            case .letter:
                return CGSize(width: 8.5, height: 11)
            }
        }
    }

    public init() {}

    open func build(size: CGSize,
                    dpi: CGFloat = 72.0,
                    title: String? = nil,
                    titleFont: UIFont? = nil,
                    titleColor: UIColor? = nil,
                    titleRelativePosition: CGPoint = CGPoint(x: 0.5, y: 0.5),
                    image: UIImage? = nil,
                    imageRatio: CGFloat = 1.0,
                    backgroundColor: UIColor? = nil,
                    metaData: [CFString: String]? = nil) -> Data {
        SwiftyBeaver.debug("Create flyer - page size: \(size) inches | title: \(title ?? "")")
        let format = UIGraphicsPDFRendererFormat()
        if let pdfMetaData = metaData {
            format.documentInfo = pdfMetaData as [String: Any]
        }

        let pageWidth = round(size.width * dpi)
        let pageHeight = round(size.height * dpi)
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            if let backgroundColor = backgroundColor {
                backgroundColor.setFill()
                context.fill(pageRect)
            }
            if let image = image {
                addImage(pageRect: pageRect, image: image, maxRatio: imageRatio)
            }
            if let title = title {
                addTitleCentered(title: title, font: titleFont, color: titleColor ?? .label, relativePosition: titleRelativePosition, pageRect: pageRect)
            }
        }
        return data
    }

    open func addTitle(title: String, font: UIFont? = nil, at: CGPoint) {
        let attributedTitle = getAttributedTitle(title: title, font: font)
        attributedTitle.draw(at: at)
    }

    open func addTitleCentered(title: String, font: UIFont? = nil, color: UIColor, relativePosition: CGPoint, pageRect: CGRect) {
        let attributedTitle = getAttributedTitle(title: title, font: font, color: color, alignment: .center)
        let titleStringSize = attributedTitle.size()
        let startX = max(pageRect.width * relativePosition.x - titleStringSize.width / 2, 0)
        let startY = max(pageRect.height * relativePosition.y - titleStringSize.height, 0)
        let width = (startX + titleStringSize.width) > pageRect.width ? pageRect.width - startX : titleStringSize.width
        attributedTitle.draw(in: CGRect(x: startX, y: startY, width: width, height: pageRect.height - startY))
    }

    private func getAttributedTitle(title: String, font: UIFont? = nil, color: UIColor = .black, alignment: NSTextAlignment = .natural) -> NSAttributedString {
        let titleFont = font ?? UIFont.systemFont(ofSize: 64.0, weight: .bold)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.allowsDefaultTighteningForTruncation = true
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = alignment
        let titleAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: titleFont,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        return NSAttributedString(string: title, attributes: titleAttributes)
    }

    open func addImage(pageRect: CGRect, image: UIImage, maxRatio: CGFloat = 1.0) {
        let maxWidth = pageRect.width * maxRatio
        let maxHeight = pageRect.height * maxRatio
        let aspectRatio = min(maxWidth / image.size.width, maxHeight / image.size.height)
        let scaledSize = CGSize(width: image.size.width * aspectRatio, height: image.size.height * aspectRatio)
        SwiftyBeaver.debug("Image of size: \(image.size) scaled to: \(scaledSize) | Page size: \(pageRect.size)")
        let imageRect = CGRect(x: (pageRect.width - scaledSize.width) / 2.0, y: (pageRect.height - scaledSize.height) / 2.0, width: scaledSize.width, height: scaledSize.height)
        image.draw(in: imageRect)
    }

    open func save(data: Data, fileName: String, directory: FileManager.SearchPathDirectory = .cachesDirectory) -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true)
        if paths.count == 0 {
            return nil
        }
        let path = paths[0].appending("/").appending(fileName)
        if FileManager.default.createFile(atPath: path, contents: data, attributes: nil) {
            return URL(fileURLWithPath: path)
        } else {
            return nil
        }
    }
}
