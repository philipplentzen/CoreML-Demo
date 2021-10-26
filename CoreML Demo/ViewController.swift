//
//  ViewController.swift
//  CoreML Demo
//
//  Created by Philipp Lentzen on 23.10.21.
//

import UIKit
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func handleClassification(image: CGImage) -> String {
        do {
            let hotDogClassifier = try HotDogClassifier(configuration: .init())
            let hotDogModelInput = try HotDogClassifierInput(imageWith: image)
            let prediction = try hotDogClassifier.prediction(input: hotDogModelInput)
            
            guard let confidence = prediction.classLabelProbs[prediction.classLabel] else {
                return "no confidence"
            }
            
            return "\(prediction.classLabel): \(confidence)"
        } catch {
            return "Classification failed!😯"
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupApp()
    }
    
    /**
        Sets up the initial view
     */
    func setupApp() {
        let menu = UIMenu(title: "",
                          children: [
                            UIAction(title: "Choose Image...", handler: chooseImageHandler),
                            UIAction(title: "Take Image...", handler: takeImageHandler),
                          ])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .camera,
                                                            menu: menu)
    }

    /**
        Starts the savedPhotos view
     */
    func chooseImageHandler(action: UIAction) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true)
    }
    
    /**
        Starts the camera view
     */
    func takeImageHandler(action: UIAction) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        present(picker, animated: true)
    }
    
    /**
        Handles receiving image and starts classification
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        imageCaption.text = "Analyzing image... 🔍"
        
        guard let uiImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else { fatalError("no image from picker") }
        guard let cgImage = uiImage.cgImage
            else { fatalError("can't create CIImage from UIImage") }

        imageView.image = uiImage
        imageCaption.text = self.handleClassification(image: cgImage)
    }
}

