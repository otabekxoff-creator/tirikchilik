enum UserSortOption {
  newest,
  name,
  earned,
  adsWatched;

  String get label {
    switch (this) {
      case UserSortOption.newest:
        return 'Yangi';
      case UserSortOption.name:
        return 'Ism';
      case UserSortOption.earned:
        return 'Daromad';
      case UserSortOption.adsWatched:
        return 'Reklamalar';
    }
  }
}
