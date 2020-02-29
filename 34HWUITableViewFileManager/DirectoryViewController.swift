//
//  DirectoryViewController.swift
//  34HWUITableViewFileManager
//
//  Created by Сергей on 18.02.2020.
//  Copyright © 2020 Sergei. All rights reserved.
//

import UIKit

class DirectoryViewController: UITableViewController {
    
    //MARK: Properties
    var path = "/Users/sergej/Desktop/TestFolder"
    var pathContents = [String]()
    var selectedPath = ""
    var alertController = UIAlertController(title: "File Info", message: "", preferredStyle: .alert)
    var alertAcitionOk =  UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    var foldersNames = [String]()
    var filesNames =  [String]()
    var tempFilesNames = [String]()
    let duration = 0.3
    
    //MARK: Life Cyrcle
    
    override func loadView() {
        super.loadView()
    
        pathContents =  getContents(atPath: path)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        alertController.addAction(alertAcitionOk)
        
    }
    
    //MARK: Interface Builder Actions
    
    @IBAction func actionInfoCell(_ sender: UIButton) {
        
        let cell = sender.superCell() ?? UITableViewCell()
        let indexPath = tableView.indexPath(for: cell) ?? IndexPath()
        
        let pathFile = getFilePathBy(indexPath: indexPath, mainPath: path)
        
        let attributesFile = getAttributesOfItem(atPath: pathFile)
        let fileModificationDate = attributesFile[FileAttributeKey.modificationDate] as! Date
        let strFileModificationDate = stringFrom(date: fileModificationDate,
                                                 format: "MM-dd-yyyy HH:mm")
        let fileSystemFileNumber = attributesFile[FileAttributeKey.systemFileNumber] as! Int
        let fileExtensionHidden = attributesFile[FileAttributeKey.extensionHidden] as! Int
        let strFileExtensionHidden = fileExtensionHidden == 1 ? "hidden" : "not hidden"
        let massage = """
        Index Path File - section: \(indexPath.section) row: \(indexPath.row)\n
          File Modification Date: \(strFileModificationDate)\n
            File System File Number: \(fileSystemFileNumber)\n
        File Extension: \(strFileExtensionHidden)\n
        """
        alertController.message = massage
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func actionEdit(_ sender: UIBarButtonItem) {

        tableView.performBatchUpdates({
            tableView.setEditing(!tableView.isEditing, animated: true)
        }, completion: nil)
        
        if tableView.isEditing {
            sender.title = UIButtonTitle.done.rawValue
            let addFolderButton = UIBarButtonItem(title: "Add Folder",
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(addFolderAction(sender:)))
            navigationItem.leftBarButtonItem = addFolderButton
    
        } else {
            sender.title = UIButtonTitle.edit.rawValue
            navigationItem.leftBarButtonItem = nil
        }
        
    }
    
    @IBAction func sortContents(sender: UIBarButtonItem) {
        
        for fileName in pathContents {
            
            let filePath = (self.path as NSString).appendingPathComponent(fileName)
            
            if !isDirectory(byPath: filePath) {
                filesNames.append(fileName)
            } else {
                foldersNames.append(fileName)
            }

        }
        
        pathContents = foldersNames + filesNames
        foldersNames.removeAll()
        filesNames.removeAll()
    
        tableView.reloadDataWithTransitionFade(duration: duration)
        
    }
    
    //если заголовок кнопки hid тгда файлы показываем
    //
    
    @IBAction func filesHiddenOrOpen(sender: UIBarButtonItem) {
        
        if sender.title == UIButtonTitle.hide.rawValue {
        
            for fileName in pathContents {
            
                let filePath = (self.path as NSString).appendingPathComponent(fileName)
            
                if isFileHidden(atPath: filePath) {
                    
                let fileIndex = pathContents.firstIndex(of: fileName) ?? 0
                let hidenName = pathContents.remove(at: fileIndex)
                tempFilesNames.append(hidenName)
                    
                }
                
            }
            
        } else {
            
            pathContents.append(contentsOf: tempFilesNames)
            tableView.reloadDataWithTransitionFade(duration: duration)
            tempFilesNames.removeAll()
            
        }
        
        tableView.reloadDataWithTransitionFade(duration: duration)
        sender.title = sender.title == UIButtonTitle.open.rawValue ? UIButtonTitle.hide.rawValue :
                                                                     UIButtonTitle.open.rawValue
    }
    
    //если имя файла
    
    @IBAction func sortByNames(sender: UIBarButtonItem) {

        pathContents.sort()
        
        tableView.reloadDataWithTransitionFade(duration: duration)
    }
    
    //MARK: Selectors Action
    
    @objc private func addFolderAction(sender: UIBarButtonItem) {

        let alertController = UIAlertController(title: "Create Folder",
                                                message: "📂",
                                                preferredStyle: .alert)
        let alertActionOk = UIAlertAction(title: "Ok", style: .default) { (ok) in
            
            let folderName = "\(alertController.textFields?[0].text ?? "")"
            let folderPath = (self.path as NSString).appendingPathComponent(folderName)
            
            if !FileManager.default.fileExists(atPath: folderPath) {
                
                do {
                    try FileManager.default.createDirectory(atPath: folderPath,
                                                            withIntermediateDirectories: false,
                                                            attributes: nil)
                    self.pathContents.insert(folderName, at: 0)
                } catch let error {
                    print(error.localizedDescription)
                }
                
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
            }
            
        }
            alertController.addAction(alertActionOk)
        
            alertController.addTextField { (textField) in
            textField.placeholder = "Enter name folder"
        }

        self.present(alertController, animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        let lastPath = (path as NSString).lastPathComponent
        navigationItem.title = lastPath
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return pathContents.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pathComponent = pathContents[indexPath.row]
        let filePath = (path as NSString).appendingPathComponent(pathComponent)
        
        let lastPath = (filePath as NSString).lastPathComponent
        
        if isDirectory(indexPath: indexPath) {
            
            let folderCell = tableView.dequeueReusableCell(withIdentifier: "FolderCell",
                                                           for: indexPath) as? FolderCell
            folderCell?.nameLabel.text = lastPath
            let folderName = pathContents[indexPath.row]
            let folderPath = (path as NSString).appendingPathComponent(folderName)
            let sizeFolder = getSizeFolder(pathFolder: folderPath)
            let stringSizeLabel = ByteCountFormatter.string(fromByteCount: sizeFolder,
                                                            countStyle: .memory)
            folderCell?.sizeLabel.text = stringSizeLabel
            
            return folderCell ?? FolderCell()
        } else {
            
            let fileCell = tableView.dequeueReusableCell(withIdentifier: "FileCell",
                                                         for: indexPath) as? FileCell
            fileCell?.nameLabel.text = lastPath
            let fileDate = getCreateFileDate(theFile: filePath)
            let stringFileDate = stringFrom(date: fileDate, format: "MM-dd-yyyy HH:mm")
            fileCell?.dateLabel.text = stringFileDate
            let sizeFile = getSize(file: filePath)
            fileCell?.sizeLabel.text = ByteCountFormatter.string(fromByteCount: sizeFile,
                                                                 countStyle: .file)
            
            return fileCell ?? FileCell()
        }
    
    }
    
    //MARK: UITable View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isDirectory(indexPath: indexPath) {
            
            let pathComponent = pathContents[indexPath.row]
            let filePath = (path as NSString).appendingPathComponent(pathComponent)
            selectedPath = filePath
           
            self.performSegue(withIdentifier: "navigateDeep", sender: nil)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0.0
        if isDirectory(indexPath: indexPath) {
            height = 60.0
        } else {
            height = 80.0
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let filePath = getFilePathBy(indexPath: indexPath, mainPath: path)
            
            do {
                try FileManager.default.removeItem(atPath: filePath)
                pathContents = getContents(atPath: path)
            } catch let error {
                print(error.localizedDescription)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
    //MARK: Segue
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! DirectoryViewController
        vc.path = selectedPath
        
    }
    
    //MARK: Help Functions
    
    private func isDirectory(indexPath: IndexPath) -> Bool {
        var isDirectory: ObjCBool = false
        let pathComponent = pathContents[indexPath.row]
        let fullPath = (path as NSString).appendingPathComponent(pathComponent)
        FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory)
        
        return isDirectory.boolValue
    }
    
    private func getCreateFileDate(theFile: String) -> Date {
       var date = Date()
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: theFile)
            date = attributes[FileAttributeKey.creationDate] as! Date
        } catch let error {
            print("\(error.localizedDescription)")
        }
        
        return date
    }
    
    private func stringFrom(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    private func getSize(file: String) -> Int64 {
        
        let fileAttributes = getAttributesOfItem(atPath: file)
        let sizeFile = fileAttributes[FileAttributeKey.size] as? Int64
        
        return sizeFile ?? Int64.min
    }
    
    private func getAttributesOfItem(atPath: String) -> [FileAttributeKey: Any] {
        var attributes = [FileAttributeKey: Any]()
        
        do {
            attributes = try FileManager.default.attributesOfItem(atPath: atPath)
        } catch let error {
            print("\(error.localizedDescription)")
        }
        
        return attributes
    }

    private func getContents(atPath: String) -> [String] {
        var pathContents = [String]()
        do {
            pathContents =  try FileManager.default.contentsOfDirectory(atPath: atPath)
        } catch let error {
            print(error.localizedDescription)
        }
        return pathContents
    }
    
    private func isDirectory(byPath: String) -> Bool {
        
        var result: ObjCBool = false
        FileManager.default.fileExists(atPath: byPath, isDirectory: &result)
        
        return result.boolValue
    }
    
    private func isFileHidden(atPath: String) -> Bool {
        var isHidden = false
        var valueHidden = 0
        
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: atPath)
                valueHidden = attributes[FileAttributeKey.extensionHidden] as! Int
            } catch let error {
                print(error.localizedDescription)
            }
        
        if valueHidden == 1 {
            isHidden = true
        }
    
    return isHidden
    }
    
    private func getAttributesFile(atPath: String) -> [FileAttributeKey: Any] {
        var fileAttributes = [FileAttributeKey: Any]()
        
        do {
        
            fileAttributes = try FileManager.default.attributesOfItem(atPath: atPath)
        
        } catch let error {
            print(error.localizedDescription)
        }
         
        return fileAttributes
    }
    
    //MARK: Recursion Function
    
    private func getSizeFolder(pathFolder: String) -> Int64 {

        var sizeFolder: Int64 = 0
        
        let contents = getContents(atPath: pathFolder)
        
        for path in contents {
            
            let filePath = (pathFolder as NSString).appendingPathComponent(path)
            
            if !isDirectory(byPath: filePath) {
                
                let sizeFile = getSize(file: filePath)
                sizeFolder += sizeFile

            } else {
               sizeFolder += getSizeFolder(pathFolder: filePath)
            }
            
        }
        return sizeFolder
    }
    
    private func getFilePathBy(indexPath: IndexPath, mainPath: String) -> String {
        var pathContents = [String]()
        
        do {
            pathContents = try FileManager.default.contentsOfDirectory(atPath: mainPath)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let fileName = pathContents[indexPath.row]
        let filePath = (mainPath as NSString).appendingPathComponent(fileName)
        
        return filePath
    }
    
}
