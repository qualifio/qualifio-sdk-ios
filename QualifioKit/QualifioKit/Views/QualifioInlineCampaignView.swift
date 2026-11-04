import UIKit
import WebKit

/// Inline UIKit view for loading a Qualifio campaign.
public final class QualifioInlineCampaignView: UIView {
    private static let loadingViewportHeight: CGFloat = 200

    /// The campaign currently loaded, or pending until the view is attached.
    public private(set) var campaign: String?

    /// When true, after the initial campaign page has loaded, each subsequent page load requests
    /// that the parent scroll container bring this view back to its top edge.
    public var autoScrollOnPageLoadEnabled: Bool {
        didSet {
            coordinator.autoScrollOnPageLoadEnabled = autoScrollOnPageLoadEnabled
        }
    }

    internal var onContentHeightChanged: ((CGFloat) -> Void)?

    private let webView: WKWebView
    private let coordinator: Coordinator
    private var webViewHeightConstraint: NSLayoutConstraint?
    private var contentHeight: CGFloat = 0
    private var isCellInvalidationScheduled = false

    /// Creates an inline campaign view and loads the provided `campaign`.
    ///
    /// - Parameter autoScrollOnPageLoadEnabled: When true, subsequent campaign page loads request that
    ///   the parent scroll container bring this view back to its top edge.
    public init(
        campaign: String = Qualifio.DEFAULT_CAMPAIGN,
        autoScrollOnPageLoadEnabled: Bool = true
    ) {
        self.autoScrollOnPageLoadEnabled = autoScrollOnPageLoadEnabled
        self.coordinator = Coordinator(autoScrollOnPageLoadEnabled: autoScrollOnPageLoadEnabled)
        self.webView = Self.makeWebView(coordinator: coordinator)
        super.init(frame: .zero)

        commonInit()
        loadCampaign(campaign)
    }

    public required init?(coder: NSCoder) {
        self.autoScrollOnPageLoadEnabled = true
        self.coordinator = Coordinator(autoScrollOnPageLoadEnabled: true)
        self.webView = Self.makeWebView(coordinator: coordinator)
        super.init(coder: coder)

        commonInit()
        loadCampaign()
    }

    /// Loads a campaign into the inline WKWebView.
    ///
    /// Loading starts immediately if the view is attached to a window, otherwise once it is attached.
    /// Calling this before the view is attached replaces the pending campaign.
    public func loadCampaign(_ campaign: String = Qualifio.DEFAULT_CAMPAIGN) {
        if Qualifio.shared.configuration == nil {
            logger.error("No configuration set. Please call Qualifio.shared.configure()")
            return
        }

        if campaign.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            logger.error("Invalid campaign parameter.")
            return
        }

        self.campaign = campaign
        coordinator.loadCampaign(campaign)
    }

    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: contentHeight)
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        coordinator.containerDidMoveToWindow()
    }

    private static func makeWebView(coordinator: Coordinator) -> WKWebView {
        let userContentController = WKUserContentController()
        userContentController.add(
            WeakScriptMessageHandler(coordinator),
            name: QualifioInlineCampaignConstants.contentHeightBridgeName
        )

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.delegate = coordinator

        return webView
    }

    private func commonInit() {
        backgroundColor = .clear
        clipsToBounds = true

        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)

        let webViewHeightConstraint = webView.heightAnchor.constraint(
            equalToConstant: Self.loadingViewportHeight
        )
        self.webViewHeightConstraint = webViewHeightConstraint

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webViewHeightConstraint,
        ])

        coordinator.containerView = self
        coordinator.webView = webView
    }

    fileprivate func applyLoadingLayout() {
        webViewHeightConstraint?.constant = Self.loadingViewportHeight
        updateContentHeight(0)
    }

    fileprivate func applyContentHeight(_ height: CGFloat) {
        webViewHeightConstraint?.constant = height
        updateContentHeight(height)
    }

    private func updateContentHeight(_ height: CGFloat) {
        guard height != contentHeight else {
            return
        }

        contentHeight = height
        invalidateIntrinsicContentSize()

        // SwiftUI resizes from the callback.
        // Table and collection view cells resize when their list measures them again.
        if let onContentHeightChanged {
            onContentHeightChanged(height)
        } else {
            scheduleContainingCellsInvalidation()
        }
    }

    private func scheduleContainingCellsInvalidation() {
        guard !isCellInvalidationScheduled else {
            return
        }

        isCellInvalidationScheduled = true

        // The height can change while the list is laying out or applying an update, so resize the
        // cell on the next run loop turn, once the list has finished.
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }

            isCellInvalidationScheduled = false
            invalidateContainingCells()
        }
    }

    private func invalidateContainingCells() {
        guard window != nil else {
            return
        }

        var cellContentView: UIView?
        var currentView = superview

        while let view = currentView {
            if let tableViewCell = view as? UITableViewCell {
                cellContentView = tableViewCell.contentView
            } else if let collectionViewCell = view as? UICollectionViewCell {
                cellContentView = collectionViewCell.contentView
            } else if let tableView = view as? UITableView, let contentView = cellContentView {
                invalidate(contentView, in: tableView)
                cellContentView = nil
            } else if let collectionView = view as? UICollectionView, let contentView = cellContentView {
                invalidate(contentView, in: collectionView)
                cellContentView = nil
            }

            currentView = view.superview
        }
    }

    private func invalidate(_ cellContentView: UIView, in tableView: UITableView) {
        if #available(iOS 16.0, *), tableView.selfSizingInvalidation != .disabled {
            cellContentView.invalidateIntrinsicContentSize()
        } else {
            UIView.performWithoutAnimation {
                tableView.performBatchUpdates(nil)
            }
        }
    }

    private func invalidate(_ cellContentView: UIView, in collectionView: UICollectionView) {
        if #available(iOS 16.0, *), collectionView.selfSizingInvalidation != .disabled {
            cellContentView.invalidateIntrinsicContentSize()
        } else {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
}

/// Keeps `WKUserContentController`, which retains its message handlers, from owning the coordinator.
private final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private weak var handler: WKScriptMessageHandler?

    init(_ handler: WKScriptMessageHandler) {
        self.handler = handler
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handler?.userContentController(userContentController, didReceive: message)
    }
}

private final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
    weak var containerView: QualifioInlineCampaignView?
    weak var webView: WKWebView?
    var autoScrollOnPageLoadEnabled: Bool

    private var loadTask: Task<Void, Never>?
    private var pendingCampaign: String?
    private var lastReportedHeight: CGFloat = 0
    private var acceptsContentHeightReports = false
    private var didLoadInitialPage = false

    init(autoScrollOnPageLoadEnabled: Bool) {
        self.autoScrollOnPageLoadEnabled = autoScrollOnPageLoadEnabled
    }

    deinit {
        loadTask?.cancel()
    }

    func loadCampaign(_ campaign: String) {
        pendingCampaign = campaign
        startPendingLoad()
    }

    func containerDidMoveToWindow() {
        startPendingLoad()
    }

    // MARK: UIScrollViewDelegate

    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.minimumZoomScale = scrollView.zoomScale
        scrollView.maximumZoomScale = scrollView.zoomScale
    }

    // MARK: WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        acceptsContentHeightReports = true
        reportContentHeightFromDocument(webView)

        if !didLoadInitialPage {
            didLoadInitialPage = true
            return
        }

        if autoScrollOnPageLoadEnabled {
            scrollContainingScrollViewToTop(from: webView)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        logNavigationError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        logNavigationError(error)
    }

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
    ) {
        if let targetFrame = navigationAction.targetFrame, !targetFrame.isMainFrame {
            decisionHandler(.allow)
            return
        }

        let url = navigationAction.request.url
        let scheme = url?.scheme?.lowercased()
        if scheme == "http" || scheme == "https" {
            decisionHandler(.allow)
            return
        }

        // The WebView can't load mailto:, tel:, etc. Let the OS handle them.
        if let url {
            openExternalUrl(url)
        }
        decisionHandler(.cancel)
    }

    // MARK: WKUIDelegate

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }

        return nil
    }

    // MARK: WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard acceptsContentHeightReports,
              message.name == QualifioInlineCampaignConstants.contentHeightBridgeName,
              let heightString = message.body as? String,
              let height = Double(heightString) else {
            return
        }

        reportContentHeight(CGFloat(height))
    }

    // MARK: Private

    private func startPendingLoad() {
        guard containerView?.window != nil,
              let configuration = Qualifio.shared.configuration,
              let campaign = pendingCampaign
        else {
            return
        }

        pendingCampaign = nil
        lastReportedHeight = 0
        acceptsContentHeightReports = false
        applyLoadingLayout()

        loadTask?.cancel()
        loadTask = Task { [weak self] in
            do {
                let url = try await Qualifio.shared.prepareCampaignUrl(configuration, campaign)

                guard !Task.isCancelled else {
                    return
                }

                self?.didLoadInitialPage = false
                self?.webView?.load(URLRequest(url: url))
            } catch {
                guard !Task.isCancelled else {
                    return
                }

                logger.error("Failed to prepare the campaign URL.", error: error)
            }
        }
    }

    private func applyLoadingLayout() {
        containerView?.applyLoadingLayout()
    }

    private func reportContentHeightFromDocument(_ webView: WKWebView) {
        webView.evaluateJavaScript("\(QualifioInlineCampaignConstants.contentHeightScript)();")
    }

    private func reportContentHeight(_ height: CGFloat) {
        let roundedHeight = height.rounded()

        guard roundedHeight >= 1 else {
            return
        }

        guard abs(roundedHeight - lastReportedHeight) > 1 else {
            return
        }

        applyContentHeight(roundedHeight)
    }

    private func applyContentHeight(_ height: CGFloat) {
        lastReportedHeight = height
        containerView?.applyContentHeight(height)
    }

    private func logNavigationError(_ error: Error) {
        // A navigation replaced by another one, such as a campaign switch, is not a failure.
        if (error as NSError).domain == NSURLErrorDomain, (error as NSError).code == NSURLErrorCancelled {
            return
        }

        logger.error("Failed to load inline campaign.", error: error)
    }

    private func scrollContainingScrollViewToTop(from view: UIView) {
        DispatchQueue.main.async {
            for scrollView in view.containingScrollViews {
                let rect = view.convert(CGRect(x: 0, y: 0, width: 1, height: 1), to: scrollView)
                scrollView.scrollRectToVisible(rect, animated: true)
            }
        }
    }

    private func openExternalUrl(_ url: URL) {
        Task {
            let opened = await UIApplication.shared.open(url)
            if !opened {
                logger.warning("Failed to open the \(url.scheme ?? "") link.")
            }
        }
    }
}

extension UIView {
    fileprivate var containingScrollViews: [UIScrollView] {
        var scrollViews: [UIScrollView] = []
        var currentView = superview

        while let view = currentView {
            if let scrollView = view as? UIScrollView {
                scrollViews.append(scrollView)
            }

            currentView = view.superview
        }

        return scrollViews
    }
}

private enum QualifioInlineCampaignConstants {
    static let contentHeightBridgeName = "QualifioInlineCampaignView"
    static let contentHeightScript = """
        (function() {
          if (window.__qualifioInlineCampaignHeightObserver) {
            window.__qualifioInlineCampaignHeightObserver.report();
            return;
          }

          var measureDocument = function(
            targetDocument,
            targetWindow,
            correctIframeHeight
          ) {
            var body = targetDocument.body;
            var scrollY = targetWindow ? targetWindow.pageYOffset || 0 : 0;
            var height = 0;

            if (body) {
              var elements = body.querySelectorAll('*');
              for (var i = 0; i < elements.length; i += 1) {
                height = Math.max(
                  height,
                  elements[i].getBoundingClientRect().bottom + scrollY
                );
              }
            }

            if (height <= 0) {
              var documentElement = targetDocument.documentElement;
              height = Math.max(
                body ? body.scrollHeight : 0,
                documentElement ? documentElement.scrollHeight : 0,
                body ? body.offsetHeight : 0,
                documentElement ? documentElement.offsetHeight : 0
              );
            }

            if (correctIframeHeight && body) {
              var iframes = body.querySelectorAll('iframe');
              if (iframes.length === 1) {
                var iframe = iframes[0];
                var hasDeclaredHeight =
                  iframe.style.height !== '' || iframe.hasAttribute('height');
                if (hasDeclaredHeight) {
                  try {
                    var iframeDocument = iframe.contentDocument;
                    if (iframeDocument) {
                      if (
                        !iframeDocument.body ||
                        iframeDocument.body.children.length === 0
                      ) {
                        return 0;
                      }

                      var contentHeight = measureDocument(
                        iframeDocument,
                        iframe.contentWindow,
                        false
                      );
                      if (contentHeight <= 0) {
                        return 0;
                      }

                      height +=
                        contentHeight - iframe.getBoundingClientRect().height;
                    }
                  } catch (error) {
                    // Cross-origin frames keep their rendered outer size.
                  }
                }
              }
            }

            return height;
          };

          var lastHeight = 0;
          var reportScheduled = false;
          var postContentHeight = function(height) {
            if (height === lastHeight) {
              return;
            }

            lastHeight = height;
            if (
              window.webkit &&
              window.webkit.messageHandlers &&
              window.webkit.messageHandlers.QualifioInlineCampaignView
            ) {
              window.webkit.messageHandlers.QualifioInlineCampaignView.postMessage(
                height.toString()
              );
            }
          };

          var report = function() {
            if (reportScheduled) {
              return;
            }

            reportScheduled = true;
            window.requestAnimationFrame(function() {
              reportScheduled = false;
              postContentHeight(measureDocument(document, window, true));
            });
          };

          window.__qualifioInlineCampaignHeightObserver = { report: report };

          if (window.ResizeObserver) {
            var resizeObserver = new ResizeObserver(report);
            resizeObserver.observe(document.documentElement);
            if (document.body) {
              resizeObserver.observe(document.body);
            }
          }

          if (window.MutationObserver) {
            var mutationObserver = new MutationObserver(report);
            mutationObserver.observe(document.documentElement, {
              attributes: true,
              childList: true,
              subtree: true
            });
          }

          window.addEventListener('load', report);
          window.addEventListener('resize', report);

          var iframes = document.querySelectorAll('iframe');
          if (iframes.length === 1) {
            iframes[0].addEventListener('load', report);
          }

          report();
        })
    """
}
