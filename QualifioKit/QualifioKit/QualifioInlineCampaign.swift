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
        webView.scrollView.backgroundColor = .clear

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

private final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        acceptsContentHeightReports = true
        reportContentHeightFromDocument(
            webView,
            waitsForLazyElements: !didLoadInitialPage
        )

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

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard acceptsContentHeightReports,
              message.name == QualifioInlineCampaignConstants.contentHeightBridgeName,
              let heightString = message.body as? String,
              let height = Double(heightString) else {
            return
        }

        reportContentHeight(CGFloat(height))
    }

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

    private func reportContentHeightFromDocument(
        _ webView: WKWebView,
        waitsForLazyElements: Bool
    ) {
        let waitsForLazyElementsArgument = waitsForLazyElements ? "true" : "false"
        webView.evaluateJavaScript(
            "\(QualifioInlineCampaignConstants.contentHeightScript)(\(waitsForLazyElementsArgument));"
        )
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
}

private extension UIView {
    var containingScrollView: UIScrollView? {
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
        (function(waitForLazyElements) {
          if (window.__qualifioInlineCampaignHeightObserver) {
            window.__qualifioInlineCampaignHeightObserver.report();
            return;
          }

          var measure = function() {
            var body = document.body;
            var scrollY = window.pageYOffset || 0;
            var height = 0;

            if (body) {
              var elements = body.querySelectorAll('*');
              for (var i = 0; i < elements.length; i += 1) {
                var rects = elements[i].getClientRects();
                for (var j = 0; j < rects.length; j += 1) {
                  height = Math.max(height, rects[j].bottom + scrollY);
                }
              }
            }

            if (height <= 0) {
              var documentElement = document.documentElement;
              height = Math.max(
                body ? body.scrollHeight : 0,
                documentElement ? documentElement.scrollHeight : 0,
                body ? body.offsetHeight : 0,
                documentElement ? documentElement.offsetHeight : 0
              );
            }

            return Math.ceil(height);
          };

          var lastHeight = 0;
          var reportingState = {
            phase: 'initializing',
            initialHeight: 0,
            timeoutId: null
          };

          var postContentHeight = function(height) {
            if (Math.abs(height - lastHeight) < 1) {
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

          var activateReporting = function(height) {
            if (reportingState.phase === 'active') {
              return;
            }

            reportingState.phase = 'active';
            reportingState.initialHeight = 0;
            if (reportingState.timeoutId !== null) {
              window.clearTimeout(reportingState.timeoutId);
              reportingState.timeoutId = null;
            }
            postContentHeight(height);
          };

          var handleMeasuredHeight = function(height, forceInitialReport) {
            if (reportingState.phase === 'initializing') {
              return;
            }

            if (reportingState.phase === 'waiting') {
              if (
                !forceInitialReport &&
                Math.abs(height - reportingState.initialHeight) < 1
              ) {
                return;
              }

              activateReporting(height);
              return;
            }

            postContentHeight(height);
          };

          var report = function() {
            window.requestAnimationFrame(function() {
              handleMeasuredHeight(measure(), false);
            });
          };

          var initialHeight = measure();
          var hasLazyElements =
            waitForLazyElements &&
            document.querySelector('[loading="lazy"]') !== null;

          if (hasLazyElements) {
            reportingState.phase = 'waiting';
            reportingState.initialHeight = initialHeight;
            reportingState.timeoutId = window.setTimeout(function() {
              handleMeasuredHeight(measure(), true);
            }, 500);
          } else {
            activateReporting(initialHeight);
          }

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
        })
    """
}
