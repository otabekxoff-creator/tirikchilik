class PaginationHelper {
  static List<dynamic> getPaginatedItems(
    List<dynamic> items,
    int currentPage,
    int itemsPerPage,
  ) {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, items.length);
    return items.sublist(startIndex, endIndex);
  }

  static bool hasMoreItems(
    List<dynamic> items,
    int currentPage,
    int itemsPerPage,
  ) {
    final endIndex = (currentPage * itemsPerPage + itemsPerPage).clamp(0, items.length);
    return endIndex < items.length;
  }
}
