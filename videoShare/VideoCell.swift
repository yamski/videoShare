//
//  VideoCell.swift
//  videoShare
//
//  Created by JOHN YAM on 7/22/15.
//  Copyright © 2015 John Yam. All rights reserved.
//

import Foundation
import UIKit


extension UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

protocol VideoCellProtocol {
    var disableBarBtns: Bool? { get set}
    func launchVideo(index: Int)
    func editInfo(index: Int)
    func editTags(index: Int)
}

class VideoCell: UITableViewCell {
    
    @IBOutlet weak var title: UITextField! 
    @IBOutlet weak var videoLength: UILabel!
    @IBOutlet weak var videoBtn: UIButton!
    
    var delegate: VideoCellProtocol?
    var videoModel: VideoModel!
    var videoIndentifier: String!
    weak var tableView: UITableView!
    var indexPath: NSIndexPath!
    
    var editingCell: Bool! {
        didSet {
            self.delegate?.disableBarBtns = editingCell
            tableView.scrollEnabled = editingCell
            videoBtn.enabled = editingCell
            videoLength.hidden = !editingCell
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if title.text != nil {
            title.alpha = 1.0
            title.textColor = UIColor(red:0.12, green:0.29, blue:0.41, alpha:1)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.delegate = self
    }
    
    
    @IBAction func videoBtnTapped(sender: AnyObject) {
        delegate?.launchVideo(sender.tag)
    }
    

    @IBAction func editVideoInfo(sender: AnyObject) {
        self.delegate?.editInfo(indexPath.row)
    }
 

    @IBAction func addTags(sender: AnyObject) {
        self.delegate?.editTags(indexPath.row)
    }
    
    
    @IBAction func makeFavorite(sender: AnyObject) {
        videoModel.isFavorite = !(videoModel.isFavorite)
        DataManager.sharedInstance.updateModels(videoModel, identifier: videoIndentifier)
    }
}

// MARK: TextField Delegate Methods

extension VideoCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        // y position of cell
        let rectInTableView = tableView.rectForRowAtIndexPath(indexPath)
        let rect = tableView.convertRect(rectInTableView, fromView: tableView.superview!.superview)
        let yPoint = rect.origin.y
        
        // mid point of screen, accounting for orientation
        let screenMidHeight = tableView.superview!.frame.midY
        
        if (yPoint >= screenMidHeight) {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
        print("y: \(yPoint), mid point: \(screenMidHeight)")
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        editingCell = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        title.resignFirstResponder()
        editingCell = true
        layoutSubviews()
        
        if let newText = textField.text { videoModel.title = newText }
        DataManager.sharedInstance.updateModels(videoModel, identifier: videoIndentifier)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        editingCell = true
        return true
    }
}

