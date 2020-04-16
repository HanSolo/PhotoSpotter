//
//  CloudDataManager.swift
//  PhotoSpotter
//
//  Created by Gerrit Grunwald on 14.04.20.
//  Copyright © 2020 Gerrit Grunwald. All rights reserved.
//

import Foundation

class CloudDataManager {

    static let sharedInstance = CloudDataManager() // Singleton

    struct DocumentsDirectory {
        static let localDocumentsURL  : URL? = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last!
        static let iCloudDocumentsURL : URL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }


    // Return the Document directory (Cloud OR Local)
    // To do in a background thread
    func getDocumentDiretoryURL() -> URL {
        print(DocumentsDirectory.iCloudDocumentsURL!)
        print(DocumentsDirectory.localDocumentsURL!)
        if UserDefaults.standard.bool(forKey: "useCloud") && isCloudEnabled()  {
            return DocumentsDirectory.iCloudDocumentsURL!
        } else {
            return DocumentsDirectory.localDocumentsURL!
        }
    }

    // Return true if iCloud is enabled
    func isCloudEnabled() -> Bool {
        if DocumentsDirectory.iCloudDocumentsURL != nil { return true }
        else { return false }
    }

    // Delete All files at URL
    func deleteFilesInDirectory(url: URL?) {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: url!.path)
        while let file = enumerator?.nextObject() as? String {

            do {
                try fileManager.removeItem(at: url!.appendingPathComponent(file))
                print("Files deleted")
            } catch let error as NSError {
                print("Failed deleting files : \(error)")
            }
        }
    }

    // Move local files to iCloud
    // iCloud will be cleared before any operation
    // No data merging
    func moveFileToCloud() {
        if isCloudEnabled() {
            deleteFilesInDirectory(url: DocumentsDirectory.iCloudDocumentsURL!) // Clear destination
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.localDocumentsURL!.path)
            while let file = enumerator?.nextObject() as? String {
                do {
                    try fileManager.setUbiquitous(true,
                                                  itemAt: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file),
                                                  destinationURL: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file))
                    print("Moved to iCloud")
                } catch {
                    print("Failed to move file to Cloud : \(error)")
                }
            }
        }
    }

    // Move iCloud files to local directory
    // Local dir will be cleared
    // No data merging
    func moveFileToLocal() {
        if isCloudEnabled() {
            deleteFilesInDirectory(url: DocumentsDirectory.localDocumentsURL!)
            let fileManager = FileManager.default
            let enumerator = fileManager.enumerator(atPath: DocumentsDirectory.iCloudDocumentsURL!.path)
            while let file = enumerator?.nextObject() as? String {
                do {
                    try fileManager.setUbiquitous(false,
                                                  itemAt: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file),
                                                  destinationURL: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file))
                    print("Moved to local dir")
                } catch {
                    print("Failed to move file to local dir : \(error)")
                }
            }
        }
    }
}
