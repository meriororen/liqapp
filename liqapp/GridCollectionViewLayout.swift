//
//  GridCollectionViewLayout.swift
//  liqapp
//
//  Created by Isa Ansharullah on 10/19/16.
//  Copyright © 2016 DuldulStudio. All rights reserved.
//

import UIKit

protocol GridCollectionLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForBoxAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat
}

class GridCollectionLayoutAttributes: UICollectionViewLayoutAttributes {
    var boxHeight = CGFloat(0.0)
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! GridCollectionLayoutAttributes
        copy.boxHeight = boxHeight
        return copy
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let attributes = object as? GridCollectionLayoutAttributes {
            if attributes.boxHeight == boxHeight {
                return super.isEqual(object)
            }
        }
        return false
    }
}

class GridCollectionViewLayout: UICollectionViewLayout {
    
    var delegate: GridCollectionLayoutDelegate?
    
    var numberOfColumns = 3
    var cellPadding = CGFloat(1.0)
    
    var cache = [GridCollectionLayoutAttributes]()
    
    var contentHeight = CGFloat(0.0)
    var contentWidth: CGFloat {
        //let insets = collectionView!.contentInset
        //return collectionView!.bounds.width - (insets.left + insets.right)
        return collectionView!.bounds.width - 20.0
    }
    
    override class var layoutAttributesClass: AnyClass {
        return GridCollectionLayoutAttributes.self
    }
    
    override func prepare() {
        guard cache.isEmpty else {
            return
        }
        
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth + 10.0)
        }
        
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let width = columnWidth - cellPadding * 2
            let boxHeight = delegate!.collectionView(collectionView!, heightForBoxAtIndexPath: indexPath, withWidth: width)
            
            let height = cellPadding + boxHeight
            
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = GridCollectionLayoutAttributes(forCellWith: indexPath)
            
            attributes.boxHeight = boxHeight
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            if column >= numberOfColumns - 1 {
                column = 0
            } else {
                column += 1
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        
        return layoutAttributes
    }
}
