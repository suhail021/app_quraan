part of '../flutter_quran_screen.dart';

class QuranPageTopInfoWidget extends StatefulWidget {
  const QuranPageTopInfoWidget(
      {required this.surahName,
      required this.juz,
      required this.hizb,
      super.key});

  final String surahName;
  final int juz;
  final int? hizb;

  @override
  State<QuranPageTopInfoWidget> createState() => _QuranPageTopInfoWidgetState();
}

class _QuranPageTopInfoWidgetState extends State<QuranPageTopInfoWidget> {
  String rightText = '';

  @override
  void didChangeDependencies() {
    final juzString = 'الجزء ${QuranConstants.quranHizbs[widget.juz - 1]}';
    if (widget.hizb != null) {
      final hizbIndex = (widget.hizb! / 4).floor();
      final hizbPart = mapNumberToHizbPart(widget.hizb!);
      final hizbString = hizbPart.isNotEmpty ? '$hizbPart الحزب' : 'الحزب';
      
      rightText =
          '$juzString | $hizbString ${QuranConstants.quranHizbs[hizbIndex]}';
    } else {
      rightText = juzString;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('سُورَةُ ${widget.surahName}',
                    style: FlutterQuran()
                        .hafsStyle
                        .copyWith(
                          color: Colors.black, 
                          fontSize: 22,
                        )),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  rightText,
                  style: FlutterQuran()
                      .hafsStyle
                      .copyWith(
                        color: Colors.black, 
                        fontSize: 22,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String mapNumberToHizbPart(int number) {
    final reminder = (number / 4) % 1;
    if (number / 4 == 0) {
      return '';
    } else if (reminder == 0.25) {
      return 'ربع';
    } else if (reminder == 0.5) {
      return 'نصف';
    } else if (reminder == 0.75) {
      return 'ثلاثة أرباع';
    } else {
      return '';
    }
  }
}
