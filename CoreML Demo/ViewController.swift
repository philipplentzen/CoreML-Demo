//
//  ViewController.swift
//  CoreML Demo
//
//  Created by Core ML Group.
//

import UIKit
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Using CORE ML
    /**
     Classifies the given image
     
     - returns: Prediction as a string
     */
    func getPrediction(image: CVPixelBuffer) -> String {
        do {
            let fastFoodModel = try FastFoodModel(configuration: .init());
            let prediction = try hotdogModel.prediction(image: image)
            return "\(prediction.classLabel)"
        } catch {
            return "Classification failed!💩";
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel!
    
    // MARK: UI Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupApp()
    }
    
    /**
    Sets up the initial view
     */
    func setupApp() {
        // Prepare menu
        let menu = UIMenu(title: "",
                          children: [
                            UIAction(title: "Choose Image...", image: UIImage(systemName: "photo.fill.on.rectangle.fill"), handler: chooseImageHandler),
                            UIAction(title: "Take Image...", image: UIImage(systemName: "camera"), handler: takeImageHandler),
                          ])
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "camera.on.rectangle"),
                                         menu: menu)
        
        // Add menu button to navigation
        navigationItem.rightBarButtonItem = menuButton
    }

    // MARK: Additional Views
    /**
    Starts the savedPhotos view
     */
    func chooseImageHandler(action: UIAction) {
        let picker = UIImagePickerController()
        // Set the delegate to self, imagePickerController will be called
        picker.delegate = self
        // Use Album for image selection
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true)
    }
    
    /**
    Starts the camera view
     */
    func takeImageHandler(action: UIAction) {
        let picker = UIImagePickerController()
        // Set the delegate to self, imagePickerController will be called
        picker.delegate = self
        // Use camera to take a new image
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        present(picker, animated: true)
    }
    
    // MARK: Handling image input
    /**
     Handles the user image selection
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        // Tell the user the image is classified
        self.setImageCaptionText("Classifying image... 🔍")
        
        // Presents the selected image to the user
        let uiImage = self.getUIImageFromInfo(info)
        imageView.image = uiImage
        
        // Convert uiImage to CVPixelBuffer for classifier
        if let cvPixelBuffer = uiImage.toCVPixelBuffer() {
            // Classificate image
            let result = self.getPrediction(image: cvPixelBuffer)
            
            // Present classification result to the user
            self.setImageCaptionText(result)
            return;
        }
        self.setImageCaptionText("Converting failed!")
    }
    
    /**
     Picks UIImage from Image Picker Control info
     - returns: UIImage from Image Picker Control info
     */
    func getUIImageFromInfo(_ info: [UIImagePickerController.InfoKey : Any]) -> UIImage {
        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else { fatalError("no image from picker") }
        
        return uiImage
    }
    
    // MARK: Set prediction result
    
    /**
     Sets the text of imageCaption Label based on the classification result
     */
    func setImageCaptionText(_ result: String) {
        switch result {
        case "hotdog":
            imageCaption.text = "This is a 🌭"
        case "nothotdog":
            imageCaption.text = "This is not a 🌭"
        default:
            imageCaption.text = result
        }
    }
}


// MARK: Extend UIImage
extension UIImage {
    /**
     Converts an UIImage to CVPixelBuffer or nil
     
    - returns: The image as CVPixelBuffer
     - see: https://gist.github.com/francoismarceau29/abac55c22f6e440800d1d73d72bf2225
     */
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            return nil
        }

        if let pixelBuffer = pixelBuffer {
            CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
            let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
            let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

            context?.translateBy(x: 0, y: self.size.height)
            context?.scaleBy(x: 1.0, y: -1.0)

            UIGraphicsPushContext(context!)
            self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            UIGraphicsPopContext()
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))

            return pixelBuffer
        }

        return nil
    }
}
