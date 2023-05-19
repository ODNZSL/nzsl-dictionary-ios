//
//  UIImage+Utils.swift
//  NZSLDict
//
//  Created by Nathan Collard on 19/5/2023.
//

import Foundation
import UIKit

extension UIImage {
    func transparentImage() -> UIImage? {
        guard let rawImageRef = self.cgImage else {
            return nil;
        }

        let colorMasking: [CGFloat] = [222, 255, 222, 255, 222, 255]

        guard let maskedImageRef = rawImageRef.copy(maskingColorComponents: colorMasking) else {
            return nil;
        }

        UIGraphicsBeginImageContext(self.size);

        let currentContext = UIGraphicsGetCurrentContext()

        currentContext?.translateBy(x: 0.0, y: self.size.height);
        currentContext?.scaleBy(x: 1.0, y: -1.0);
        currentContext?.draw(maskedImageRef, in: CGRectMake(0, 0, self.size.width, self.size.height))

        let result = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return result
    }
}
