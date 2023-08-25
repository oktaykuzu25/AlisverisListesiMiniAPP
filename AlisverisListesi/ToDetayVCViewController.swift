//
//  ToDetayVCViewController.swift
//  AlisverisListesi
//
//  Created by Oktay Kuzu on 21.08.2023.
//

import UIKit
import CoreData

class ToDetayVCViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    @IBOutlet weak var kaydetbutton: UIButton!
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var isimtextFlied: UITextField!
    @IBOutlet weak var bedentextflied: UITextField!
     @IBOutlet weak var fiyattextflied: UITextField!
    
    var secilenurunismi = ""
    var secilenurunıd : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //jest algılayıcılar ekrana tıklandığını anlamak icin
        let getReguenenzir = UITapGestureRecognizer(target: self, action: #selector(klavyeyikapa))
        view.addGestureRecognizer(getReguenenzir)
       
        //kullanici görsele tıklama izni
         imageview.isUserInteractionEnabled = true
        //Kullanici görsele tıkladığını anlamak icin
        let imageReguenizer = UITapGestureRecognizer(target: self , action: #selector(gorselsec))
        imageview.addGestureRecognizer(imageReguenizer)
        
        if secilenurunismi != ""{
            
            
            //butonu saklamak
            
            kaydetbutton.isHidden = true
            //secilen ürün isimleri cekip göstermek için
            
            //uuid almak
            
            if let uuidstring = secilenurunıd?.uuidString{
                //veri tabanına ulaşmak 
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appdelegate.persistentContainer.viewContext
                //veri tabanına istek
                let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
                //filtre ekleme
                fetchrequest.predicate = NSPredicate(format: "id=%@", uuidstring)
                
                fetchrequest.returnsObjectsAsFaults = false
                
                do{
                    let sonuclar =  try context.fetch(fetchrequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject]{
                            if let kategorisim = sonuc.value(forKey:"isim") as? String{
                                isimtextFlied.text = kategorisim
                            }
                            if let kategoribeden = sonuc.value(forKey:"beden") as? String{
                               bedentextflied.text = kategoribeden
                            }
                            if let kategorifiyat = sonuc.value(forKey:"fiyat") as? Int{
                               fiyattextflied.text = String(kategorifiyat)
                            }
                            if let kategorigorsel = sonuc.value(forKey: "gorsel") as? Data {
                                let image = UIImage(data: kategorigorsel)
                                 imageview.image=image
                                
                            }
                        }
                                
                    }
                }
                catch{
                    print("hata var ")
                }
                
                
            }
        }
        else{
            isimtextFlied.text=""
            bedentextflied.text=""
            fiyattextflied.text=""
            kaydetbutton.isHidden = false 
        }

    }
    
    @objc func gorselsec(){
        let picker = UIImagePickerController()
        picker.delegate = self
        //kullanicin kütüphanesine gitme
        picker.sourceType = .photoLibrary
        //kullanici fotoyu sectikten sonra kırpmasına izin verme
        picker.allowsEditing = true
        //ekrana basma
        present(picker, animated: true, completion: nil)
         
        
    }
    //kullanici fotoyu sectikten sonra ne yapacak ?
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        imageview.image = info [.editedImage] as? UIImage
        //kullanici fotoyu sectikten sonra view geri gelir. önemli
        self.dismiss(animated: true)
    }
    
    @objc func klavyeyikapa(){
        
        view.endEditing(true)
        
    }
    
    @IBAction func Kaydetbutonu(_ sender: Any) {
        
        //app delegateyi ulaştık ve değişkene attık
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //core data modelinden yararlanmak ve verilere ulaşmak icin " NSEntityDescription" kullaniriz
        let alisveris = NSEntityDescription.insertNewObject(forEntityName: "Alisveris", into: context)
        
        alisveris.setValue(isimtextFlied.text!, forKey: "isim")
        alisveris.setValue(bedentextflied.text!, forKey: "beden")
        
        if let fiyat = Int(fiyattextflied.text!){
            alisveris.setValue(fiyat, forKey: "fiyat")
        }

        //id icin hep kendi değiştrisin ve biz uğraşmayalım diye yapılan yöntem
        
        alisveris.setValue(UUID(), forKey: "id")
        
        //gorsel binary data olarak eklendiği için  onu veriye cevirme yani ikilik tabana cevirme
        
        let data = imageview.image!.jpegData(compressionQuality: 0.5)
        alisveris.setValue(data, forKey: "gorsel")
        
        do {
            try context.save()
            print("Kayıt Edildiii .... :)))")
            
        }
        catch{
            print("Kaydetme başarısız....!!!")
        }
        
        
        //UYgulama icersinde diğer viewlere haber yollamak yeni bir iş yaptık haberin olsun demek için bu da => "NotificationCenter"
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Veri Girildi!"), object: nil)
        
        //Kayıt olduğunda geri dönemsei icin
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
