import SwiftUI
import UIKit
import WebKit

/// Inline SwiftUI view for loading a Qualifio campaign.
public struct QualifioInlineCampaign: View {
    private let campaign: String
    private let autoScrollOnPageLoadEnabled: Bool

    @State private var contentHeight: CGFloat = 0

    /// Creates an inline campaign view and loads the provided campaign.
    ///
    /// - Parameters:
    ///   - campaign: The campaign to load.
    ///   - autoScrollOnPageLoadEnabled: When true, subsequent campaign page loads request that
    ///     the parent scroll container bring this view back to its top edge.
    public init(
        campaign: String = Qualifio.DEFAULT_CAMPAIGN,
        autoScrollOnPageLoadEnabled: Bool = true
    ) {
        self.campaign = campaign
        self.autoScrollOnPageLoadEnabled = autoScrollOnPageLoadEnabled
    }

    public var body: some View {
        QualifioInlineCampaignWebView(
            campaign: campaign,
            autoScrollOnPageLoadEnabled: autoScrollOnPageLoadEnabled,
            onContentHeightChanged: { height in
                DispatchQueue.main.async {
                    guard height >= 0, height != contentHeight else {
                        return
                    }

                    contentHeight = height
                }
            }
        )
        .frame(height: contentHeight)
    }
}

private struct QualifioInlineCampaignWebView: UIViewRepresentable {
    let campaign: String
    let autoScrollOnPageLoadEnabled: Bool
    let onContentHeightChanged: (CGFloat) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            autoScrollOnPageLoadEnabled: autoScrollOnPageLoadEnabled,
            onContentHeightChanged: onContentHeightChanged
        )
    }

    func makeUIView(context: Context) -> QualifioInlineCampaignContainerView {
        let userContentController = WKUserContentController()
        userContentController.add(
            context.coordinator,
            name: QualifioInlineCampaignConstants.contentHeightBridgeName
        )

        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.delegate = context.coordinator

        let containerView = QualifioInlineCampaignContainerView(webView: webView)
        context.coordinator.containerView = containerView
        context.coordinator.webView = webView
        context.coordinator.loadCampaignIfNeeded(campaign)

        return containerView
    }

    func updateUIView(_ containerView: QualifioInlineCampaignContainerView, context: Context) {
        context.coordinator.autoScrollOnPageLoadEnabled = autoScrollOnPageLoadEnabled
        context.coordinator.onContentHeightChanged = onContentHeightChanged
        context.coordinator.loadCampaignIfNeeded(campaign)
    }

    static func dismantleUIView(
        _ containerView: QualifioInlineCampaignContainerView,
        coordinator: Coordinator
    ) {
        coordinator.cancelLoading()
        containerView.webView.navigationDelegate = nil
        containerView.webView.uiDelegate = nil
        containerView.webView.scrollView.delegate = nil
        containerView.webView.configuration.userContentController.removeScriptMessageHandler(
            forName: QualifioInlineCampaignConstants.contentHeightBridgeName
        )
    }
}

private final class QualifioInlineCampaignContainerView: UIView {
    private static let loadingViewportHeight: CGFloat = 200
    private var webViewHeightConstraint: NSLayoutConstraint?

    let webView: WKWebView

    init(webView: WKWebView) {
        self.webView = webView
        super.init(frame: .zero)

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
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }

    func applyLoadingViewportHeight() {
        webViewHeightConstraint?.constant = Self.loadingViewportHeight
    }

    func applyContentHeight(_ height: CGFloat) {
        webViewHeightConstraint?.constant = height
    }
}

private final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIScrollViewDelegate {
    weak var containerView: QualifioInlineCampaignContainerView?
    weak var webView: WKWebView?
    var autoScrollOnPageLoadEnabled: Bool
    var onContentHeightChanged: (CGFloat) -> Void

    private var loadTask: Task<Void, Never>?
    private var currentCampaign: String?
    private var lastReportedHeight: CGFloat = 0
    private var acceptsContentHeightReports = false
    private var didLoadInitialPage = false

    init(
        autoScrollOnPageLoadEnabled: Bool,
        onContentHeightChanged: @escaping (CGFloat) -> Void
    ) {
        self.autoScrollOnPageLoadEnabled = autoScrollOnPageLoadEnabled
        self.onContentHeightChanged = onContentHeightChanged
    }

    func loadCampaignIfNeeded(_ campaign: String) {
        guard campaign != currentCampaign else {
            return
        }

        loadCampaign(campaign)
    }

    func cancelLoading() {
        loadTask?.cancel()
        loadTask = nil
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
        logger.error("Failed to load inline campaign.", error: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        logger.error("Failed to load inline campaign.", error: error)
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

    private func loadCampaign(_ campaign: String) {
        guard let configuration = Qualifio.shared.configuration else {
            logger.error("No configuration set. Please call Qualifio.configure()")
            return
        }

        if campaign.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            logger.error("Invalid campaign parameter.")
            return
        }

        currentCampaign = campaign
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
                logger.error("Failed to prepare the campaign URL.", error: error)
            }
        }
    }

    private func applyLoadingLayout() {
        onContentHeightChanged(0)
        containerView?.applyLoadingViewportHeight()
    }

    private func reportContentHeightFromDocument(_ webView: WKWebView) {
        webView.evaluateJavaScript("\(QualifioInlineCampaignConstants.contentHeightScript)();")
    }

    private func reportContentHeight(_ height: CGFloat) {
        let roundedHeight = ceil(height)

        guard roundedHeight >= 1 else {
            return
        }

        guard roundedHeight != lastReportedHeight else {
            return
        }

        applyContentHeight(roundedHeight)
    }

    private func applyContentHeight(_ height: CGFloat) {
        lastReportedHeight = height
        containerView?.applyContentHeight(height)
        onContentHeightChanged(height)
    }

    private func scrollContainingScrollViewToTop(from view: UIView) {
        guard let scrollView = view.containingScrollView else {
            return
        }

        DispatchQueue.main.async {
            let rect = view.convert(CGRect(x: 0, y: 0, width: 1, height: 1), to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: false)
        }
    }

    private func openExternalUrl(_ url: URL) {
        UIApplication.shared.open(url) { success in
            if !success {
                logger.warning("Failed to open the \(url.scheme ?? "") link.")
            }
        }
    }
}

extension UIView {
    fileprivate var containingScrollView: UIScrollView? {
        var currentView = superview

        while let view = currentView {
            if let scrollView = view as? UIScrollView {
                return scrollView
            }

            currentView = view.superview
        }

        return nil
    }
}

private enum QualifioInlineCampaignConstants {
    static let contentHeightBridgeName = "QualifioInlineCampaign"
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

            return Math.ceil(height);
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
              window.webkit.messageHandlers.QualifioInlineCampaign
            ) {
              window.webkit.messageHandlers.QualifioInlineCampaign.postMessage(
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
