import Foundation

/// Mimics the API of DispatchSourceTimer but in a way that prevents
/// crashes that occur from calling resume multiple times on a timer that is
/// already resumed (noted by https://github.com/SiftScience/sift-ios/issues/52
open class DispatchTimer {

    public enum State {
        case suspended
        case resumed
    }

    public let timeInterval: TimeInterval
    public let repeating: Bool
    /// The amount of time after the scheduled fire date that the timer may fire.
    @UnfairLocked
    public var tolerance: TimeInterval = 0

    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        t.setEventHandler { [weak self] in
            guard let this = self else { return }
            if this.tolerance > 0 {
                this.tolerance = max(0, this.tolerance - this.timeInterval)
            } else {
                self?.eventHandler?(this)
            }
        }
        return t
    }()

    open var eventHandler: ((DispatchTimer) -> Void)?

    private(set) var state: State = .suspended

    public init(timeInterval: TimeInterval, repeating: Bool, handler: ((DispatchTimer) -> Void)? = nil) {
        self.timeInterval = timeInterval
        self.eventHandler = handler
        self.repeating = repeating
    }

    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }

    open func resume() {
        guard state != .resumed else { return }
        state = .resumed
        timer.resume()
    }

    open func suspend() {
        guard state != .suspended else { return }
        state = .suspended
        timer.suspend()
    }
}
