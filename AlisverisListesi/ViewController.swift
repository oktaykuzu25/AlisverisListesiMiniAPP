//
//  ViewController.swift
//  AlisverisListesi
//
//  Created by Oktay Kuzu on 21.08.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableview: UITableView!
    var isimdizisi = [String] ()
    var idDizisi = [UUID]()
    var secilenisim = ""
    var secilenUUID :UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
        
        tableview.dataSource = self
        tableview .delegate = self
        
         //üst bara "+" işareti koyma
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(artıbutonutiklandi))
        verilerial()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //gözlemci eklemek için bu işlem olunca ne olacak
        NotificationCenter.default.addObserver(self, selector: #selector(verilerial), name: NSNotification.Name(rawValue: "Veri Girildi!"), object: nil)
    }
    
    
    
    @objc func verilerial (){
        //bu dizi icersindeki herşeyi sil
        isimdizisi.removeAll(keepingCapacity: false)
        idDizisi.removeAll(keepingCapacity: false)
        //veri tabına ulaştık
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        // verileri cekmek için verileri cekme isteği oluşturmamız gerekiyor  buda bu kodla yapılır => " NSFetchRequest" yapılır
        let fetchreuquest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
        // büyük verileri kaydetmek icin yapılır
        fetchreuquest.returnsObjectsAsFaults = false
        
        do {
            //burda sonuclar diziye cevirdik
          let sonuclar =   try context.fetch(fetchreuquest)
            if sonuclar.count > 0 {
                //sonucları diziye atıcaz
                for sonuc in sonuclar as! [NSManagedObject]{
                    if let isim = sonuc.value(forKey: "isim") as? String{
                        isimdizisi.append(isim)
                        
                    }
                    
                    if let id = sonuc.value(forKey: "id") as? UUID{
                        idDizisi.append(id)
                    }
                }
                //table view icindeki yazıları güncelleme
                tableview.reloadData()
            
                
            }
           
        }
        catch {
            print("hata var ")
            
        }
    }

    //table view kaç satır olucak
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimdizisi.count
    }
    
    
     //satırlar icinde neler yazıcak
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimdizisi[indexPath.row]
        return cell
    }
    
    @objc func artıbutonutiklandi (){
        secilenisim = ""
        performSegue(withIdentifier: "ToDetayVC", sender: nil)
    }
    
    //verileri aktarmak icin diğer sayfaya
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToDetayVC"{
            let destinationVC = segue.destination as! ToDetayVCViewController
            destinationVC.secilenurunismi=secilenisim
            destinationVC.secilenurunıd=secilenUUID
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //ne secildiyse onu almak
        secilenisim=isimdizisi[indexPath.row]
        secilenUUID=idDizisi[indexPath.row]
        performSegue(withIdentifier: "ToDetayVC", sender: nil)
    }
    
    
    //istenilen veriyi tabloda ve veri tabanında silme fonksiyonu Önemli !!
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
         // veri tabanına ulaştık
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
            // veri tabanındaki id dizindeki isteilen id ye ulaşma
            let uuidString = idDizisi[indexPath.row].uuidString
            
            
            fetchrequest.predicate = NSPredicate(format:"id=%@",uuidString)
            do{
                let sonuclar = try context.fetch(fetchrequest)
                if sonuclar.count > 0{
                    for sonuc in sonuclar as! [NSManagedObject] {
                        if let id = sonuc.value(forKey:"id") as? UUID {
                            //secilen id ile silinmesi geren aynı mı onu yaptık
                            if id == idDizisi[indexPath.row] {
                               //veri tabanından sil
                                context.delete(sonuc)
                                //isim dizisindne sil
                                isimdizisi.remove(at: indexPath.row)
                                //id dizisinden sil
                                idDizisi.remove(at: indexPath.row)
                                //table view den sil ve güncelle
                                self.tableview.reloadData()
                                do {
                                    try context.save()
                                }
                                catch {
                                    
                                }
                                break
                            }
                            
                        }
                            
                    }
                }
                    
            }
            catch{
                print("hata")
                
            }
        }
    }
}

