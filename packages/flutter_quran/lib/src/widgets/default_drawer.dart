part of '../flutter_quran_screen.dart';

class _DefaultDrawer extends StatefulWidget {
  const _DefaultDrawer();

  @override
  State<_DefaultDrawer> createState() => _DefaultDrawerState();
}

class _DefaultDrawerState extends State<_DefaultDrawer> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final jozzs = FlutterQuran().getAllJozzs();
    final hizbs = FlutterQuran().getAllHizbs();
    final surahs = FlutterQuran().getAllSurahs();
    
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            trailing: const Icon(Icons.search_outlined),
            title: const Text('بحث بالآيات'),
            onTap: () async {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => const _FlutterQuranSearchScreen()));
            },
          ),
          ExpansionTile(
            title: const Text('الفهرس'),
            initiallyExpanded: true,
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                title: const Text('السورة'),
                initiallyExpanded: true,
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث عن سورة...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                  ...surahs.asMap().entries.where((entry) => 
                    entry.value.contains(_searchQuery)
                  ).map((entry) {
                    final index = entry.key;
                    final surahName = entry.value;
                    return ListTile(
                      title: Text(
                        surahName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => FlutterQuran().navigateToSurah(index + 1),
                    );
                  }),
                ],
              ),
              ExpansionTile(
                title: const Text('الجزء'),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                    jozzs.length,
                    (jozzIndex) => ExpansionTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              jozzs[jozzIndex],
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          children: List.generate(2, (index) {
                            final hizbIndex = (index == 0 && jozzIndex == 0)
                                ? 0
                                : ((jozzIndex * 2 + index));
                            return InkWell(
                              onTap: () {
                                FlutterQuran().navigateToHizb(hizbIndex + 1);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  hizbs[hizbIndex],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          }),
                        )
                    //    )
                    ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('العلامات'),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: FlutterQuran()
                    .getUsedBookmarks()
                    .map((bookmark) => ListTile(
                          leading: Icon(
                            Icons.bookmark,
                            color: Color(bookmark.colorCode),
                          ),
                          title: Text(
                            bookmark.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onTap: () =>
                              FlutterQuran().navigateToBookmark(bookmark),
                        ))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
