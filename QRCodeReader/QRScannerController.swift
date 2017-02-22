//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Pablo Mateo Fernández on 27/01/2017.
//  Copyright © 2017 355 Berry Street S.L. All rights reserved.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer
    var qrCodeFrameView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) //Nos da informacion sobre el dispositivo de captura del dispositivo junto con el tipo de dato que va a capturar
        do{
        
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession() //Creamos una sesion(necesario)
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput() //Creamos un ouput para la sesion
            captureSession?.addOutput(captureMetadataOutput) //Lo metemos a la sesion
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode] //LE decimos que tipo de metadatos tenemos, un array de codigos qr
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession) //Creamos una capa con nuestra sesion
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill //Creamos video gravity que lo ajusta a su tamaño
            videoPreviewLayer.frame = view.layer.bounds //Ajustamos el tamaño de la capa del video
            view.layer.addSublayer(videoPreviewLayer)
            
            captureSession?.startRunning()
            
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topbar)
            
            qrCodeFrameView = UIView()
            if let  qrCodeFrameView = qrCodeFrameView{
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch{
            print(error)
            return
        }

        // Do any additional setup after loading the view.
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) { //Se llama cuando la camara etsa capturando datos y nos devuelve un array de metadata objects
        if metadataObjects == nil || metadataObjects.count == 0 { //Comprobamos si tenemos metaobjetos
                qrCodeFrameView?.frame = CGRect.zero //Creamos un frame y ponemos un texto
                messageLabel.text = "No se detecta nada"
            return
        }
        let metadaObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject //Traduce el codigo que lee
        if metadaObj?.type == AVMetadataObjectTypeQRCode {//Comprobamos qu ees qr
            let barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadaObj)//Traduzca el codigo en la capa qr
            qrCodeFrameView?.frame = barCodeObject!.bounds //Creamos un frame igual al objeto qr que hemos detectado
            if metadaObj?.stringValue != nil { //Si lo tiene ponemos como texto el string value que ha detectado
                messageLabel.text = metadaObj?.stringValue
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
