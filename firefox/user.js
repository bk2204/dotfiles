// Don't enable advertising, private or not.
user_pref("dom.private-attribution.submission.enabled", false);
// Always send a do-not-track header and indicate that we don't want to be
// tracked.
user_pref("privacy.donottrackheader.enabled", true);
// Always indicate that we don't want our information shared or sold.
user_pref("privacy.globalprivacycontrol.enabled", true);
// Turn off all machine learning functionality.
user_pref("browser.ai.control.default", "blocked");
user_pref("browser.ai.control.linkPreviewKeyPoints", "blocked");
user_pref("browser.ai.control.pdfjsAltText", "blocked");
user_pref("browser.ai.control.sidebarChatbot", "blocked");
user_pref("browser.ai.control.smartTabGroups", "blocked");
user_pref("browser.ai.control.translations", "blocked");
user_pref("browser.ml.enable", false);
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.linkPreview.enabled", false);
user_pref("browser.ml.chat.menu", false);
user_pref("browser.ml.chat.page", false);
user_pref("browser.ml.chat.sidebar", false);
user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("browser.tabs.groups.smart.userEnabled", false);
user_pref("extensions.ml.enabled", false);
user_pref("pdfjs.enableAltTextModelDownload", false);
user_pref("pdfjs.enableGuessAltText", false);
user_pref("sidebar.revamp", false);
// Always show the full URL in the address bar.
user_pref("browser.urlbar.trimURLs", false);
// Make clicking on website hover menus work in KDE.
user_pref("widget.gtk.ignore-bogus-leave-notify", 1);
