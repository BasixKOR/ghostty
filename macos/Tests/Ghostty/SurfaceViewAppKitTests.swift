@testable import Ghostty
import Testing

struct SurfaceViewAppKitTests {
    @Test(arguments: [
        ("\u{0008}", true),
        ("\u{001F}", true),
        ("\u{007F}", false),
        (" ", false),
        ("h", false),
        ("", false),
        ("\u{0009}x", false),
        ("\u{0009}\u{0009}", false),
    ])
    func suppressesOnlySingleC0ControlTextWhileComposing(
        text: String,
        expected: Bool
    ) {
        #expect(
            Ghostty.SurfaceView.shouldSuppressComposingControlInput(
                text,
                composing: true
            ) == expected
        )
    }

    @Test func doesNotSuppressControlTextWhenNotComposing() {
        #expect(
            Ghostty.SurfaceView.shouldSuppressComposingControlInput(
                "\u{0008}",
                composing: false
            ) == false
        )
    }

    @Test func doesNotSuppressMissingText() {
        #expect(
            Ghostty.SurfaceView.shouldSuppressComposingControlInput(
                nil,
                composing: true
            ) == false
        )
    }

    @Test func replaysCommandsThatEndCommittedPreedit() {
        for key in [Ghostty.Input.Key.backspace, .enter, .escape, .h] {
            #expect(Ghostty.SurfaceView.shouldReplayCommittedPreeditKey(
                key,
                modifiers: key == .h ? .control : [],
                preeditEnded: true,
                interpretedAsCommand: true
            ))
        }
    }

    @Test func doesNotReplayCommandWhilePreeditContinues() {
        #expect(!Ghostty.SurfaceView.shouldReplayCommittedPreeditKey(
            .backspace,
            modifiers: [],
            preeditEnded: false,
            interpretedAsCommand: true
        ))
    }

    @Test func doesNotReplayCommittedTextThatWasNotACommand() {
        #expect(!Ghostty.SurfaceView.shouldReplayCommittedPreeditKey(
            .space,
            modifiers: [],
            preeditEnded: true,
            interpretedAsCommand: false
        ))
    }

    @Test func preservesCommittedPreeditArrowBehavior() {
        #expect(Ghostty.SurfaceView.shouldReplayCommittedPreeditKey(
            .arrowRight,
            modifiers: [],
            preeditEnded: true,
            interpretedAsCommand: false
        ))
        #expect(!Ghostty.SurfaceView.shouldReplayCommittedPreeditKey(
            .arrowLeft,
            modifiers: [],
            preeditEnded: true,
            interpretedAsCommand: true
        ))
        #expect(Ghostty.SurfaceView.shouldReplayCommittedPreeditKey(
            .arrowLeft,
            modifiers: .shift,
            preeditEnded: true,
            interpretedAsCommand: false
        ))
    }
}
