//
//  PDFView.swift
//  Assets Bundling POC
//

import UIKit
import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    let documentURL: URL

    init(documentURL: URL) {
        self.documentURL = documentURL
    }

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: documentURL)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = PDFDocument(url: documentURL)
    }
}
