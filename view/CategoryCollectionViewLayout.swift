//
//  CategoryCollectionViewLayout.swift
//  OwlGame
//
//  Created by Никита Главацкий on 15/04/2019.
//  Copyright © 2019 StreetPeople. All rights reserved.
//

import UIKit

protocol CategoryCollectionViewDelegate: class {
    func theNumberOfItemsInCollectionView() -> Int
}

extension CategoryCollectionViewDelegate {
    func heightForContentInItem(inCollectionView collectionView: UICollectionView, at indexPath: IndexPath) -> CGFloat {
        return 0
    }
}

class CategoryCollectionViewLayout: UICollectionViewLayout {
    fileprivate var numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 0
    fileprivate var cellHeight: CGFloat = 315
    fileprivate var cellWidth: CGFloat = 219
    fileprivate var cellMargin: CGFloat = 26
    fileprivate var iphoneCellMargin: CGFloat = 26 / 2
    
    weak var delegate: CategoryCollectionViewDelegate?
    
    
    //An array to cache the calculated attributes
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    //For content size
    fileprivate var contentHeight: CGFloat {
        guard let collectionView = collectionView else {return 0}
        let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.left + insets.right)
    }
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {return 0}
        let insets = collectionView.contentInset
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            return collectionView.bounds.width / 3 * 4 + 3 * iphoneCellMargin //+ cellPadding * 2 * (4+1)
        }else{
            return collectionView.bounds.width - (insets.left + insets.right)
        }
        
    }
    
    //Setting the content size
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        //We begin measuring the location of items only if the cache is empty
//        cache.removeAll()
        guard cache.isEmpty == true, let collectionView = collectionView else {return}
        
        //            let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        var yOffset = [CGFloat]()
        
//        let numberOfItems = delegate?.theNumberOfItemsInCollectionView()
        var rows = 2
        var itemsInRow = [2, 2]
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
            cellHeight = collectionView.bounds.height - 2*cellMargin
            cellWidth = collectionView.bounds.width / 3 - iphoneCellMargin
            rows = 1
            itemsInRow = [4]
        }else{
            cellHeight = (collectionView.bounds.height - 3*cellMargin) / 2
            cellWidth = (collectionView.bounds.width - 3*cellMargin) / 2
        }
        
        
        
        let yMargin = cellMargin
        //        print(yMarginx)
        for i in 0..<rows{
            let xMargin = cellMargin
            for j in 0..<itemsInRow[i]{
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                    xOffset.append(iphoneCellMargin + iphoneCellMargin*2 * CGFloat(j) + CGFloat(j) * cellWidth)
                }else{
                    xOffset.append(xMargin * CGFloat(j+1) + CGFloat(j) * cellWidth)
                }
                yOffset.append(yMargin * CGFloat(i + 1) + CGFloat(i) * cellHeight)
                
                
            }
            
        }
        
        //For each item in a collection view
        print(cellWidth)
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            //Measuring the frame
            let frame = CGRect(x: xOffset[indexPath.row], y: yOffset[indexPath.row], width: cellWidth, height: cellHeight)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
//            let insetFrame = frame.insetBy(dx: 0, dy: 0)
            
            //Creating attributres for the layout and caching them
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            print ("frame.maxY", frame.maxY)
            
            //We increase the max height of the content as we get more items
            //                contentHeight = max(collectionView.frame.height + 10, frame.maxY)
            
            
            //We increase the yOffset, too
            //                yOffset[column] = yOffset[column] + 2 * (height - cellPadding)
            //
            //                // print ("column: \(column), yOffset: \(yOffset[column])")
            //
            //                let numberOfItems = delegate?.theNumberOfItemsInCollectionView()
            //
            //                //Changing column so the next item will be added to a different column
            //
            //                if let numberOfItems = numberOfItems, indexPath.item == numberOfItems - 1
            //                {
            //                    //In case we get to the last cell, we check the column of the cell before
            //                    //The last one, and based on that, we change the column
            //                    print ("indexPath.item: \(indexPath.item), numberOfItems: \(numberOfItems)")
            //                    print ("A")
            //                    switch column {
            //                    case 0:
            //                        column = 2
            //                    case 2:
            //                        column = 0
            //                    case 1:
            //                        column = 2
            //                    default:
            //                        return
            //                    }
            //                } else  {
            //                    print ("B")
            //                    column = column < (numberOfColumns - 1) ? (column + 1) : 0
            //                }
        }
        
    }
    
    
    //Is called  to determine which items are visible in the given rect
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        //Loop through the cache and look for items in the rect
        for attribute in cache {
            if attribute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attribute)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    //The attributes for the item at the indexPath
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    
}

