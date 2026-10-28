//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.
//

import Foundation
@testable import SwiftStreamingMarkdown
import Testing

@Suite("Paragraph word stagger")
struct ParagraphAnimationTests {

  /// The configurable timing must be a no-op for callers that don't set it:
  /// the original implementation spread every batch as `0.1 / wordCount`.
  @Test("Default timing reproduces the original 0.1 / wordCount spread")
  func defaultMatchesOriginalSpread() {
    for wordCount in 1...200 {
      let stagger = paragraphWordStagger(wordCount: wordCount, animation: .default)
      #expect(stagger == 0.1 / Double(wordCount))
    }
  }

  @Test("Default timing matches the original fade constants")
  func defaultDurations() {
    let animation = MarkdownRenderConfig.TextAnimationConfig.default
    #expect(animation.wordFadeDuration == 0.5)
    #expect(animation.blockEnterDuration == 0.5)
    #expect(animation.blockEnterRise == 0)
    #expect(MarkdownRenderConfig.default.textAnimation == .default)
  }

  @Test("Small batches get the full per-word stagger")
  func smallBatchUsesFullStagger() {
    let animation = MarkdownRenderConfig.TextAnimationConfig(wordStagger: 0.02, maxTotalStagger: 0.2)
    for wordCount in 1...10 {
      #expect(paragraphWordStagger(wordCount: wordCount, animation: animation) == 0.02)
    }
  }

  @Test("Large batches compress so the last word starts within the cap")
  func burstIsCappedByMaxTotalStagger() {
    let animation = MarkdownRenderConfig.TextAnimationConfig(wordStagger: 0.02, maxTotalStagger: 0.2)
    for wordCount in [11, 20, 50, 500, 5000] {
      let stagger = paragraphWordStagger(wordCount: wordCount, animation: animation)
      #expect(stagger < 0.02)
      #expect(Double(wordCount - 1) * stagger < 0.2)
    }
  }

  @Test("An empty batch does not divide by zero")
  func emptyBatchIsFinite() {
    #expect(paragraphWordStagger(wordCount: 0, animation: .default).isFinite)
  }

  @Test("Builders carry the text animation through")
  func buildersPreserveTextAnimation() {
    let animation = MarkdownRenderConfig.TextAnimationConfig(wordFadeDuration: 0.18, wordStagger: 0.02, maxTotalStagger: 0.2, blockEnterDuration: 0.2, blockEnterRise: 3)
    let config = MarkdownRenderConfig.default
      .withTextAnimation(value: animation)
      .withBlockSpacing(value: 12)
      .withShouldAnimateText(value: true)
    #expect(config.textAnimation == animation)
    #expect(config != MarkdownRenderConfig(shouldAnimateText: true, blockSpacing: 12))
  }
}
