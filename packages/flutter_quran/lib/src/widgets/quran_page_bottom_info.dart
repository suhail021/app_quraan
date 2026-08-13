part of '../flutter_quran_screen.dart';

class QuranPageBottomInfoWidget extends StatefulWidget {
  const QuranPageBottomInfoWidget(
      {required this.surahName,
      required this.page,
      required this.hizb,
      super.key});

  final String surahName;
  final int page;
  final int? hizb;

  @override
  State<QuranPageBottomInfoWidget> createState() =>
      _QuranPageBottomInfoWidgetState();
}

class _QuranPageBottomInfoWidgetState extends State<QuranPageBottomInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Center(
        child: Text(widget.page.toString().toArabic(),
            style: FlutterQuran().hafsStyle.copyWith(
              color: Colors.black,
              fontSize: 22,
            )),
      ),
    );
  }
}
