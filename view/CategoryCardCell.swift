//
//  CategoryCardCell.swift
//  OwlGame
//
//  Created by Никита Главацкий on 18/02/2019.
//  Copyright © 2019 StreetPeople. All rights reserved.
//

import UIKit

class CategoryCardCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var star1ImageView: UIImageView!
    @IBOutlet weak var star2ImageView: UIImageView!
    @IBOutlet weak var star3ImageView: UIImageView!
    @IBOutlet weak var star1FilledImageView: UIImageView!
    @IBOutlet weak var star2FilledImageView: UIImageView!
    @IBOutlet weak var star3FilledImageView: UIImageView!
    @IBOutlet weak var categoryNumber: UILabel!
    @IBOutlet weak var ipadCategoryNumber: UILabel!
    @IBOutlet weak var proImage: UIImageView!
    @IBOutlet weak var ipadProImage: UIImageView!
    
    var stars: [UIImageView]?
    var starsFilled: [UIImageView]?
    var changed: Bool = false
    var lastScore: Int64?
    
    override func awakeFromNib() {
        stars = [star1ImageView, star2ImageView, star3ImageView]
        starsFilled = [star1FilledImageView, star2FilledImageView, star3FilledImageView]
    }
    
    func animateChange(){
        let starsCount = getStars(forScore: section!.score)
        let oldStarsCount = getStars(forScore: lastScore!)
        
        if section.sectionType != .remember {
            if let _ = starsFilled{
                if starsCount > 0{
                    animateStar(withIndex: oldStarsCount)
                }
            }
        }
        MusicHelper.sharedHelper.playEffect(of: .star, forNumber: starsCount - oldStarsCount)
        animateMedal(fromIndex: oldStarsCount, toIndex: starsCount)
        
    }
    
    func animateMedal(fromIndex index: Int, toIndex endIndex: Int){
        if index < endIndex{
            let toImage = UIImage(named: "\(self.section!.image!)\(index + 1)")
            UIView.transition(with: self.categoryImageView, duration: 0.7, options: .transitionCrossDissolve, animations: {
                self.categoryImageView.image = toImage
            }, completion: { _ in
                self.animateMedal(fromIndex: index + 1, toIndex: endIndex)
            })
        }
    }
    
    func animateStar(withIndex index: Int) -> Void {
        if let starsFilled = starsFilled, let _ = stars{
            starsFilled[index].image = #imageLiteral(resourceName: "StarCompleted")
            let scale: CGFloat = 380
            let incScale: CGFloat = 1.3
            let scaleTransform = starsFilled[index].transform.scaledBy(x: incScale, y: incScale)
            starsFilled[index].transform = scaleTransform.scaledBy(x: 1.0 / scale, y: 1.0 / scale )
            starsFilled[index].isHidden = false
            UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseInOut, animations: {
                starsFilled[index].transform = scaleTransform
            }, completion: { (finished: Bool) in
                UIView.animate(withDuration: 0.3,
                               animations: { starsFilled[index].transform = scaleTransform.scaledBy(x: 1.0 / incScale, y: 1.0 / incScale )
                }, completion: { (finished: Bool) in
                    let starsCount = self.getStars(forScore: self.section!.score)
                    if starsCount > index+1 {
                        self.animateStar(withIndex: index + 1)
                    }
                })
            })
        }
    }
    
    var section: Section!{
        didSet{
            titleLabel.text = section.name
            
            var score = section!.score
            if changed{
                if let oldScore = lastScore{
                    score = oldScore
                }
            }
            changeHiddenFilledStars(status: true)
            changeHiddenEmptyStars(status: false)
            
            let starsCount = getStars(forScore: score)
        
            for (index, star) in starsFilled!.enumerated(){
                if index < starsCount{
                    star.isHidden = false
                    stars![index].isHidden = false
                }else{
                    star.isHidden = true
                }
            }
            
            if section.sectionType == .remember{
                changeHiddenFilledStars(status: true)
                changeHiddenEmptyStars(status: true)
            }
            
            var image = UIImage(named: "\(section.image!)\(getStars(forScore: section!.score)).png")
            if image == nil{
                image = UIImage(named: "Noname")
            }
            categoryImageView.image = image
        }
    }
    
    func changeProImageState(_ isHidden: Bool){
        proImage?.isHidden = isHidden
        ipadProImage?.isHidden = isHidden
    }
    
    func changeHiddenEmptyStars(status: Bool){
        let starImages = [star1ImageView, star2ImageView, star3ImageView]
        for star in starImages{
            star?.isHidden = status
        }
    }
    
    func changeHiddenFilledStars(status: Bool){
        let starFilledImages = [star1FilledImageView, star2FilledImageView, star3FilledImageView]
        for star in starFilledImages{
            star?.isHidden = status
        }
    }
    
    func getStars(forScore score: Int64) -> Int{
        switch score {
        case 50...69:
            return 1
        case 70...94:
            return 2
        case 95...100:
            return 3
        default:
            return 0
        }
    }
    
}
