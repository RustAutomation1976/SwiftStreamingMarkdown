//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation

struct FadeAnimationData {
  let id: UUID = UUID()
  let startTime: CFTimeInterval
  let duration: CFTimeInterval
  let range: NSRange
}

/// Cubic Bezier ease-out curve shared between iOS and macOS paragraph views.
func paragraphEaseOut(_ t: CGFloat) -> CGFloat {
  let c2: CGFloat = 0.1
  let c4: CGFloat = 1.0

  let t2 = t * t
  let t3 = t2 * t
  let mt = 1 - t
  let mt2 = mt * mt

  return 3 * mt2 * t * c2 + 3 * mt * t2 * c4 + t3
}

/// Delay between consecutive word starts for one appended batch of `wordCount`
/// words, shared between iOS and macOS paragraph views. Compressing by
/// `wordCount` (rather than `wordCount - 1`) keeps the default configuration
/// identical to the original `0.1 / wordCount` spread.
func paragraphWordStagger(wordCount: Int, animation: MarkdownRenderConfig.TextAnimationConfig) -> CFTimeInterval {
  min(animation.wordStagger, animation.maxTotalStagger / Double(max(wordCount, 1)))
}
