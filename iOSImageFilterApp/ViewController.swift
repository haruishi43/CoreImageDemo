//
//  ViewController.swift
//  iOSImageFilterApp
//
//  Created by Haruya Ishikawa on 2017/10/07.
//  Copyright © 2017 Haruya Ishikawa. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation

class ViewController: UIViewController {
    
    // References:
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!
    
    // Params:
    var filtered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do something...
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        if filtered {
            
            imageView.image = UIImage(named: "main")
            
            filterButton.setImage(#imageLiteral(resourceName: "filter"), for: .normal)
        } else {
            let sourceImage = CIImage(image: imageView.image!)
            let sourceExtent: CGRect = sourceImage!.extent
            
            let filteredImage = parisFilter(sourceImage!) /// ------------------ change here --------------
            
            let context = CIContext(options: nil)
            let cgImage = context.createCGImage(filteredImage, from: sourceExtent)
            imageView.image = UIImage(cgImage: cgImage!)
            
            filterButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        }
        filtered = !filtered
    }
    
    // Filter 1:
    func fancyFilter(_ source: CIImage) -> CIImage {
        var filteredImage: CIImage?
        
        // Lens Filter
        let colorFilter1 = CIFilter(name: "CIOverlayBlendMode")
        let colorGenerator1 = CIFilter(name: "CIConstantColorGenerator")
        let color1 = CIColor(red:0.00, green:0.71, blue:1.00, alpha:0.16)
        // Color Control Filter
        let colorControlFilter = CIFilter(name: "CIColorControls")
        // Another Lens Filter
        let colorFilter2 = CIFilter(name: "CIOverlayBlendMode")
        let colorGenerator2 = CIFilter(name: "CIConstantColorGenerator")
        let color2 = CIColor(red:1.00, green:0.49, blue:0.87, alpha:0.3)
        
        // Chain -->
        colorGenerator1?.setValue(color1, forKey: "inputColor")
        let colorImage1 = colorGenerator1?.outputImage
        colorFilter1?.setValue(colorImage1, forKey: "inputImage")
        colorFilter1?.setValue(source, forKey: "inputBackgroundImage")
        filteredImage = colorFilter1?.outputImage
        
        colorControlFilter?.setValue(filteredImage, forKey: kCIInputImageKey)
        colorControlFilter?.setValue(2.0, forKey: "inputSaturation")
        colorControlFilter?.setValue(0.3, forKey: "inputBrightness")
        colorControlFilter?.setValue(1.4, forKey: "inputContrast")
        filteredImage = colorControlFilter?.outputImage
        
        colorGenerator2?.setValue(color2, forKey: "inputColor")
        let colorImage2 = colorGenerator2?.outputImage
        colorFilter2?.setValue(colorImage2, forKey: "inputImage")
        colorFilter2?.setValue(filteredImage, forKey: "inputBackgroundImage")
        filteredImage = colorFilter2?.outputImage
        
        return filteredImage!
    }
    
    // Filter 2:
    func clearFilter(_ source: CIImage) -> CIImage {
        var filteredImage: CIImage?
        
        // Lens Filter
        let colorFilter1 = CIFilter(name: "CIOverlayBlendMode")
        let colorGenerator1 = CIFilter(name: "CIConstantColorGenerator")
        let color1 = CIColor(red:0.10, green:0.79, blue:0.10, alpha:0.16)
        // Color Control Filter
        let colorControlFilter = CIFilter(name: "CIColorControls")
        // Another Lens Filter
        let colorFilter2 = CIFilter(name: "CIOverlayBlendMode")
        let colorGenerator2 = CIFilter(name: "CIConstantColorGenerator")
        let color2 = CIColor(red:0.49, green:0.64, blue:1.00, alpha:0.3)
        
        // Chain -->
        colorGenerator1?.setValue(color1, forKey: "inputColor")
        let colorImage1 = colorGenerator1?.outputImage
        colorFilter1?.setValue(colorImage1, forKey: "inputImage")
        colorFilter1?.setValue(source, forKey: "inputBackgroundImage")
        filteredImage = colorFilter1?.outputImage
        
        colorControlFilter?.setValue(filteredImage, forKey: kCIInputImageKey)
        colorControlFilter?.setValue(1.5, forKey: "inputSaturation")
        colorControlFilter?.setValue(0.2, forKey: "inputBrightness")
        colorControlFilter?.setValue(1.4, forKey: "inputContrast")
        filteredImage = colorControlFilter?.outputImage
        
        colorGenerator2?.setValue(color2, forKey: "inputColor")
        let colorImage2 = colorGenerator2?.outputImage
        colorFilter2?.setValue(colorImage2, forKey: "inputImage")
        colorFilter2?.setValue(filteredImage, forKey: "inputBackgroundImage")
        filteredImage = colorFilter2?.outputImage
        
        return filteredImage!
    }
    
    // Filter 3:
    func retroFilter(_ source: CIImage) -> CIImage {
        var filteredImage: CIImage?
        
        // Distress Marks
        let distressFilter = CIFilter(name: "CIMultiplyBlendMode")
        var distressImage = CIImage(image: UIImage(named: "distortion")!)
        let distressCrop = CIFilter(name: "CICrop")
        distressCrop?.setValue(distressImage, forKey: "inputImage")
        distressCrop?.setValue(CIVector(x: 0, y: 0, z: source.extent.width, w: source.extent.height), forKey: "inputRectangle")
        distressImage = distressCrop?.outputImage
        
        let distressColorMatrix = CIFilter(name: "CIColorMatrix")
        distressColorMatrix?.setDefaults()
        distressColorMatrix?.setValue(distressImage, forKey: kCIInputImageKey)
        distressColorMatrix?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0.4), forKey: "inputAVector")
        distressImage = distressColorMatrix?.outputImage
        
        // make the distress gaussian
        let gaussianGradient = CIFilter(name: "CIGaussianGradient")
        gaussianGradient?.setDefaults()
        gaussianGradient?.setValue(CIVector(x: source.extent.midX, y: source.extent.midY), forKey: "inputCenter")
        gaussianGradient?.setValue(635, forKey: "inputRadius")
        distressFilter?.setDefaults()
        distressFilter?.setValue(distressImage, forKey: "inputImage")
        distressFilter?.setValue(gaussianGradient?.outputImage, forKey: "inputBackgroundImage")
        distressImage = distressFilter?.outputImage
        
        distressCrop?.setValue(distressImage, forKey: "inputImage")
        distressCrop?.setValue(CIVector(x: 0, y: 0, z: source.extent.width, w: source.extent.height), forKey: "inputRectangle")
        distressImage = distressCrop?.outputImage
        
        // add yellow overlay
        let colorOverlay = CIFilter(name: "CIOverlayBlendMode")
        let colorGenerator = CIFilter(name: "CIConstantColorGenerator")
        let color = CIColor(red:0.89, green:0.92, blue:0.19, alpha:0.04)
        colorGenerator?.setValue(color, forKey: "inputColor")
        colorOverlay?.setDefaults()
        colorOverlay?.setValue(colorGenerator?.outputImage, forKey: "inputImage")
        colorOverlay?.setValue(source, forKey: "inputBackgroundImage")
        filteredImage = colorOverlay?.outputImage
        
        // add color controls
        let colorControl = CIFilter(name: "CIColorControls")
        colorControl?.setValue(filteredImage, forKey: kCIInputImageKey)
        colorControl?.setValue(1.1, forKey: "inputSaturation")
        colorControl?.setValue(0.09, forKey: "inputBrightness")
        colorControl?.setValue(1.3, forKey: "inputContrast")
        filteredImage = colorControl?.outputImage
        
        // add temp filter
        let balanceFilter = CIFilter(name: "CITemperatureAndTint")
        balanceFilter?.setDefaults()
        balanceFilter?.setValue(filteredImage, forKey: kCIInputImageKey)
        balanceFilter?.setValue(CIVector(x: 6500, y: 30), forKey: "inputNeutral")
        balanceFilter?.setValue(CIVector(x: 5000, y: 27), forKey: "inputTargetNeutral")
        filteredImage = balanceFilter?.outputImage
        
        // add distress to filteredImage
        let distressOverlay = CIFilter(name: "CIOverlayBlendMode")
        distressOverlay?.setValue(distressImage, forKey: "inputImage")
        distressOverlay?.setValue(filteredImage, forKey: "inputBackgroundImage")
        filteredImage = distressOverlay?.outputImage
        
        return filteredImage!
    }
    
    // Filter 4:
    func vintageFilter(_ source: CIImage) -> CIImage {
        var filteredImage: CIImage?
        
        //
        let smoothGradient = CIFilter(name: "CISmoothLinearGradient")
        let color1 = CIColor(red:0.55, green:0.09, blue:0.09, alpha:1.0)
        let color2 = CIColor(red:0.99, green:0.89, blue:0.69, alpha:1.0)
        smoothGradient?.setValue(color1, forKey: "inputColor0")
        smoothGradient?.setValue(color2, forKey: "inputColor1")
        smoothGradient?.setValue(CIVector(x: 0, y: source.extent.height), forKey: "inputPoint0")
        smoothGradient?.setValue(CIVector(x: source.extent.width, y: source.extent.height), forKey: "inputPoint1")
        
        //
        let gradientCrop = CIFilter(name: "CICrop")
        gradientCrop?.setValue(smoothGradient?.outputImage, forKey: "inputImage")
        gradientCrop?.setValue(CIVector(x: 0, y: 0, z: source.extent.width, w: source.extent.height), forKey: "inputRectangle")
        
        //
        let colorMap = CIFilter(name: "CIColorMap")
        colorMap?.setValue(source, forKey: "inputImage")
        colorMap?.setValue(gradientCrop?.outputImage, forKey: "inputGradientImage")
        filteredImage = colorMap?.outputImage
        
        //
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls?.setDefaults()
        colorControls?.setValue(filteredImage, forKey: "inputImage")
        colorControls?.setValue(0.65, forKey: "inputSaturation")
        colorControls?.setValue(0.1, forKey: "inputBrightness")
        colorControls?.setValue(1.2, forKey: "inputContrast")
        filteredImage = colorControls?.outputImage
        
        //
        let gaussianGradient = CIFilter(name: "CIGaussianGradient")
        gaussianGradient?.setDefaults()
        gaussianGradient?.setValue(CIVector(x: source.extent.midX, y: source.extent.midY), forKey: "inputCenter")
        gaussianGradient?.setValue(CIColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.0), forKey: "inputColor1")
        gaussianGradient?.setValue(800, forKey: "inputRadius")
        gradientCrop?.setValue(gaussianGradient?.outputImage, forKey: "inputImage")
        gradientCrop?.setValue(CIVector(x: 0, y: 0, z: source.extent.width, w: source.extent.height), forKey: "inputRectangle")
        
        //
        let overlayFilter = CIFilter(name: "CIOverlayBlendMode")
        overlayFilter?.setValue(gradientCrop?.outputImage, forKey: "inputImage")
        overlayFilter?.setValue(filteredImage, forKey: "inputBackgroundImage")
        filteredImage = overlayFilter?.outputImage
        
        //
        let sharpen = CIFilter(name: "CISharpenLuminance")
        sharpen?.setValue(filteredImage, forKey: "inputImage")
        sharpen?.setValue(1.5, forKey: "inputSharpness")
        filteredImage = sharpen?.outputImage
        
        return filteredImage!
    }
    
    // Filter 5:
    func daydreamFilter(_ source: CIImage) -> CIImage {
        var filteredImage: CIImage?
        
        //
        let gaussianGradient = CIFilter(name: "CIGaussianGradient")
        gaussianGradient?.setDefaults()
        gaussianGradient?.setValue(CIVector(x: source.extent.midX, y: source.extent.midY), forKey: "inputCenter")
        gaussianGradient?.setValue(800, forKey: "inputRadius")
        let gaussianCrop = CIFilter(name: "CICrop")
        gaussianCrop?.setValue(gaussianGradient?.outputImage, forKey: "inputImage")
        gaussianCrop?.setValue(CIVector(x: 0, y: 0, z: source.extent.width, w: source.extent.height), forKey: "inputRectangle")
        
        //
        let color = CIColor(red: 1.00, green: 0.10, blue: 0.73, alpha: 1.00)
        let colorGenerator = CIFilter(name: "CIConstantColorGenerator")
        colorGenerator?.setValue(color, forKey: "inputColor")
        let colorCrop = CIFilter(name: "CICrop")
        colorCrop?.setValue(colorGenerator?.outputImage, forKey: "inputImage")
        colorCrop?.setValue(CIVector(x: 0, y: 0, z: source.extent.width, w: source.extent.height), forKey: "inputRectangle")
        //
        let colorDodgeBlend = CIFilter(name: "CIColorDodgeBlendMode")
        colorDodgeBlend?.setValue(colorCrop?.outputImage, forKey: "inputImage")
        colorDodgeBlend?.setValue(gaussianCrop?.outputImage, forKey: "inputBackgroundImage")
        
        //
        let dodgeMatrix = CIFilter(name: "CIColorMatrix")
        dodgeMatrix?.setDefaults()
        dodgeMatrix?.setValue(colorDodgeBlend?.outputImage, forKey: "inputImage")
        dodgeMatrix?.setValue(CIVector(x: 0, y: 0, z: 0, w: 0.1), forKey: "inputAVector")
        
        //
        let vibrance = CIFilter(name: "CIVibrance")
        vibrance?.setValue(source, forKey: "inputImage")
        vibrance?.setValue(-0.15, forKey: "inputAmount")
        filteredImage = vibrance?.outputImage
        
        //
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls?.setDefaults()
        colorControls?.setValue(filteredImage, forKey: "inputImage")
        colorControls?.setValue(1.4, forKey: "inputSaturation")
        colorControls?.setValue(0.1, forKey: "inputBrightness")
        colorControls?.setValue(1.2, forKey: "inputContrast")
        filteredImage = colorControls?.outputImage
        
        //
        let inputMatrix = CIFilter(name: "CIColorMatrix")
        inputMatrix?.setDefaults()
        inputMatrix?.setValue(filteredImage, forKey: "inputImage")
        inputMatrix?.setValue(CIVector(x: 1.4, y: 0, z: 0, w: 0), forKey: "inputRVector")
        inputMatrix?.setValue(CIVector(x: 0, y: 1.4, z: 0, w: 0), forKey: "inputGVector")
        inputMatrix?.setValue(CIVector(x: 0, y: 0, z: 1.4, w: 0), forKey: "inputBVector")
        inputMatrix?.setValue(CIVector(x: -0.3, y: -0.3, z: -0.3, w: 0), forKey: "inputBiasVector")
        filteredImage = inputMatrix?.outputImage
        
        //
        let gammaAdjust = CIFilter(name: "CIGammaAdjust")
        gammaAdjust?.setValue(filteredImage, forKey: "inputImage")
        gammaAdjust?.setValue(0.667, forKey: "inputPower")
        filteredImage = gammaAdjust?.outputImage
        
        //
        let outputMatrix = CIFilter(name: "CIColorMatrix")
        outputMatrix?.setDefaults()
        outputMatrix?.setValue(filteredImage, forKey: "inputImage")
        outputMatrix?.setValue(CIVector(x: 0.776, y: 0, z: 0, w: 0), forKey: "inputRVector")
        outputMatrix?.setValue(CIVector(x: 0, y: 0.776, z: 0, w: 0), forKey: "inputGVector")
        outputMatrix?.setValue(CIVector(x: 0, y: 0, z: 0.776, w: 0), forKey: "inputBVector")
        outputMatrix?.setValue(CIVector(x: 0.223, y: 0.223, z: 0.223, w: 0), forKey: "inputBiasVector")
        filteredImage = outputMatrix?.outputImage
        
        //
        let overlayBlend = CIFilter(name: "CIOverlayBlendMode")
        overlayBlend?.setValue(filteredImage, forKey: "inputBackgroundImage")
        overlayBlend?.setValue(dodgeMatrix?.outputImage, forKey: "inputImage")
        filteredImage = overlayBlend?.outputImage
        
        return filteredImage!
    }
    
    // Filter 6:
    func parisFilter(_ source: CIImage) -> CIImage {
        var filteredImage: CIImage?
        
        //
        let color1 = CIColor(red: 0.43, green: 0.52, blue: 0.98, alpha: 0.9)
        let colorGenerator1 = CIFilter(name: "CIConstantColorGenerator")
        colorGenerator1?.setValue(color1, forKey: "inputColor")
        let colorCrop = CIFilter(name: "CICrop")
        colorCrop?.setValue(colorGenerator1?.outputImage, forKey: "inputImage")
        colorCrop?.setValue(CIVector(x: 0, y: 0, z: source.extent.width, w: source.extent.height), forKey: "inputRectangle")
        
        //
        let overlay1 = CIFilter(name: "CIOverlayBlendMode")
        overlay1?.setValue(colorCrop?.outputImage, forKey: "inputImage")
        overlay1?.setValue(source, forKey: "inputBackgroundImage")
        filteredImage = overlay1?.outputImage
        
        //
        let tempTint = CIFilter(name: "CITemperatureAndTint")
        tempTint?.setValue(filteredImage, forKey: kCIInputImageKey)
        tempTint?.setValue(CIVector(x: 6800, y: 5), forKey: "inputNeutral")
        tempTint?.setValue(CIVector(x: 3600, y: 10), forKey: "inputTargetNeutral")
        filteredImage = tempTint?.outputImage
        
        //
        let color2 = CIColor(red: 0.61, green: 0.63, blue: 0.44, alpha: 0.2)
        let colorGenerator2 = CIFilter(name: "CIConstantColorGenerator")
        colorGenerator2?.setValue(color2, forKey: "inputColor")
        colorCrop?.setValue(colorGenerator2?.outputImage, forKey: "inputImage")
        colorCrop?.setValue(CIVector(x: 0, y: 0, z: source.extent.width, w: source.extent.height), forKey: "inputRectangle")
        
        //
        let overlay2 = CIFilter(name: "CIOverlayBlendMode")
        overlay2?.setValue(colorCrop?.outputImage, forKey: "inputImage")
        overlay2?.setValue(filteredImage, forKey: "inputBackgroundImage")
        filteredImage = overlay2?.outputImage
        
        //
        let toneCurve = CIFilter(name: "CIToneCurve")
        toneCurve?.setDefaults()
        toneCurve?.setValue(filteredImage, forKey: "inputImage")
        toneCurve?.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
        toneCurve?.setValue(CIVector(x: 0.1, y: 0.07), forKey: "inputPoint1")
        toneCurve?.setValue(CIVector(x: 0.45, y: 0.6), forKey: "inputPoint2")
        toneCurve?.setValue(CIVector(x: 0.75, y: 0.8), forKey: "inputPoint3")
        toneCurve?.setValue(CIVector(x: 0.99, y: 1), forKey: "inputPoint4")
        filteredImage = toneCurve?.outputImage
        
        //
        let color3 = CIColor(red: 0.916, green: 0.77, blue: 0, alpha: 0.05)
        let colorGenerator3 = CIFilter(name: "CIConstantColorGenerator")
        colorGenerator3?.setValue(color3, forKey: "inputColor")
        colorCrop?.setValue(colorGenerator3?.outputImage, forKey: "inputImage")
        colorCrop?.setValue(CIVector(x: 0, y: 0, z: source.extent.width, w: source.extent.height), forKey: "inputRectangle")

        //
        let overlay3 = CIFilter(name: "CIOverlayBlendMode")
        overlay3?.setValue(colorCrop?.outputImage, forKey: "inputImage")
        overlay3?.setValue(filteredImage, forKey: "inputBackgroundImage")
        filteredImage = overlay3?.outputImage
        
        //
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls?.setDefaults()
        colorControls?.setValue(filteredImage, forKey: "inputImage")
        colorControls?.setValue(1.1, forKey: "inputSaturation")
        colorControls?.setValue(0.15, forKey: "inputBrightness")
        colorControls?.setValue(1.25, forKey: "inputContrast")
        filteredImage = colorControls?.outputImage
        
        return filteredImage!
    }
    
}

