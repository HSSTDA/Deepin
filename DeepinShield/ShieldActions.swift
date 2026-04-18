import ManagedSettings

// ShieldActionDelegate is an NSObject subclass — methods need `override`
class DeepinShieldActions: ShieldActionDelegate {

    // زر "I need more time" — يعطي 5 دقائق إضافية
    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {

        case .primaryButtonPressed:
            // يفتح التطبيق لمدة 5 دقائق فقط
            completionHandler(.defer)

        case .secondaryButtonPressed:
            // يبقى محظوراً
            completionHandler(.close)

        default:
            completionHandler(.close)
        }
    }
}
