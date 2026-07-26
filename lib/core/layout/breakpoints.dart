abstract final class AppBreakpoints {
  static const compact = 600.0;
  static const expanded = 1024.0;
}

enum LayoutSize { compact, medium, expanded }

LayoutSize layoutSizeFor(double width) {
  if (width < AppBreakpoints.compact) return LayoutSize.compact;
  if (width < AppBreakpoints.expanded) return LayoutSize.medium;
  return LayoutSize.expanded;
}
