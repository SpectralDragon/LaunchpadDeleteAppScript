//
//  main.swift
//  Script
//
//  Created by v.a.prusakov on 10/01/2018.
//  Copyright © 2018 v.a.prusakov. All rights reserved.
//

import Foundation

enum Consts {
    static let contentsFolder = "Contents"
    static let masReceiptFolder = "_MASReceipt"
    static let receiptFile = "receipt"
}

typealias Application = (name: String, path: String)

func checkApplicationFolder() {
    let urls = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask)
    for url in urls {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path), !contents.isEmpty else {
            print("❌ Don't have contents in path \(url.path)")
            return
        }
        
        var applications = [Application]()
        for contentURL in contents {
            let path = url.appendingPathComponent(contentURL)
            applications.append(contentsOf: recursiveFoundContentsFolder(by: path))
        }
        
        let unAppStoreApplication = checkContentsWithoutMASReceiptFolder(by: applications)

        unAppStoreApplication.forEach {
            do {
                let application = try createMissedFolder(for: $0)
                createMissedFile(for: application)
            }
            catch { print("❌ Can't create folder for path:", $0.path) }
        }
    }
}


func recursiveFoundContentsFolder(by url: URL) -> [Application] {
    var applications = [Application]()
    guard let contents = try? FileManager.default.contentsOfDirectory(atPath: url.path), !contents.isEmpty else {
        print("❌ Don't have contents in path \(url.path)")
        return []
    }
    
    for content in contents {
        if content != Consts.contentsFolder {
            let urlPath = url.appendingPathComponent(content)
            let foundedContent = recursiveFoundContentsFolder(by: urlPath)
            applications.append(contentsOf: foundedContent)
        } else {
            applications.append((url.lastPathComponent, url.path + "/" + content))
        }
    }
    
    return applications
}

func checkContentsWithoutMASReceiptFolder(by applications: [Application]) -> [Application] {
    return applications.filter {
        (try? !FileManager.default.contentsOfDirectory(atPath: $0.path).contains(Consts.masReceiptFolder)) ?? false
    }
}

func createMissedFolder(for application: Application) throws -> Application {
    let masReceiptFolder = application.path + "/" + Consts.masReceiptFolder
    try FileManager.default.createDirectory(atPath: masReceiptFolder, withIntermediateDirectories: false)
    
    return (application.name, masReceiptFolder)
}

func createMissedFile(for application: Application) {
    let missedFilePath = application.path + "/" + Consts.receiptFile
    let contents = "Do u kno de way".data(using: .utf8)
    let created = FileManager.default.createFile(atPath: missedFilePath, contents: contents)
    if created { print("✅ Now you can deleted \(application.name) in Launchpad") } else { print("❌ Can't create file for path: \(missedFilePath)") }
}

checkApplicationFolder()
