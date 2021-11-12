//
//  ViewController.swift
//  CoreML Demo
//
//  Created by Philipp Lentzen on 23.10.21.
//

import UIKit
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /**
     Handles the classification and returns the result
     */
    func handleClassification(image: CGImage) -> String {
        return "I don't know???🤔"
    }
    
    /**
     Outlets
     */
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel!
    
    /**
     Override viewDidLoad
     */
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
    
    /**
     Handles the user image selection
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        // Tell the user the image is classified
        self.setImageCaptionText("classifying image... 🔍")
        
        // Presents the selected image to the user
        let uiImage = self.getUIImageFromInfo(info)
        imageView.image = uiImage
        
        // Prepares the selected image for classification
        let cgImage = self.convertToCgImage(uiImage);
        
        // Classificate image
        let result = self.handleClassification(image: cgImage)
        
        // Present classification result to the user
        self.setImageCaptionText(result)
    }
    
    /**
     Get UIImage from Image Picker Control info
     */
    func getUIImageFromInfo(_ info: [UIImagePickerController.InfoKey : Any]) -> UIImage {
        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else { fatalError("no image from picker") }
        
        return uiImage
    }
    
    /**
     Converts an UIImage to a CGImage
     */
    func convertToCgImage(_ uiImage: UIImage) -> CGImage {
        guard let cgImage = uiImage.cgImage
            else { fatalError("can't create CIImage from UIImage") }
        
        return cgImage;
    }
    
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

