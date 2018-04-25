//
//  CommentsViewController.swift
//  Consumer
//
//  Created by Zsolt Mikola
//  Copyright © 2018 Zsolt Mikola. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController {

    @IBOutlet weak var commentsLabel: UILabel!

    private let commentsUrl = URL(string: "https://jsonplaceholder.typicode.com/posts/42/comments")

    @IBAction func loadComments(_ sender: Any) {

        postComments(completionHandler: { [weak self] data, _, commentError in
            guard let strongSelf = self, let jsonString = data else { return }
            DispatchQueue.main.async {
                strongSelf.commentsLabel.text = String(data: jsonString, encoding: String.Encoding.utf8) ?? ""
            }
        })

    }

    func postComments(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        guard let url = commentsUrl else { return }

        URLSession.shared.dataTask(with: url, completionHandler:{data, response, error in
            completionHandler(data, response, error)
        }).resume()
    }
}

