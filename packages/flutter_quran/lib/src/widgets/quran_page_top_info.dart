part of '../flutter_quran_screen.dart';

class QuranPageTopInfoWidget extends StatefulWidget {
  const QuranPageTopInfoWidget(
      {required this.surahName,
      required this.hizb,
      super.key});

  final String surahName;
  final int? hizb;

  @override
  State<QuranPageTopInfoWidget> createState() => _QuranPageTopInfoWidgetState();
}

class _QuranPageTopInfoWidgetState extends State<QuranPageTopInfoWidget> {
  String hizbText = '';

  @override
  void didChangeDependencies() {
    if (widget.hizb != null) {
      final hizbIndex = (widget.hizb! / 4).floor();
      final juzIndex = (hizbIndex / 2).floor();
      final hizbPart = mapNumberToHizbPart(widget.hizb!);
      final hizbString = hizbPart.isNotEmpty ? '$hizbPart الحزب' : 'الحزب';
      
      hizbText =
          'الجزء ${QuranConstants.quranHizbs[juzIndex]} | $hizbString ${QuranConstants.quranHizbs[hizbIndex]}';
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
              child: widget.hizb != null
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        hizbText,
                        style: FlutterQuran()
                            .hafsStyle
                            .copyWith(
                              color: Colors.black, 
                              fontSize: 22,
                            ),
                      ),
                    )
                  : const SizedBox(),
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
