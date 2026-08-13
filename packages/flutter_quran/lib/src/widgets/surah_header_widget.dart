part of '../flutter_quran_screen.dart';

class SurahHeaderWidget extends StatelessWidget {
  const SurahHeaderWidget(this.surahName, {super.key});

  final String surahName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.only(bottom: 8.0), // Push text up slightly to center it in the frame
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(Images().surahHeader), fit: BoxFit.fill),
      ),
      alignment: Alignment.center,
      child: Text(
        'سُورَةُ $surahName',
        style: FlutterQuran()
            .hafsStyle
            .copyWith(fontWeight: FontWeight.w700, fontSize: 26, color: Colors.black),
      ),
    );
  }
}
