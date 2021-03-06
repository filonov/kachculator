import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kachculator/generated/l10n.dart';
import 'package:kachculator/calculators/calc_cooper_strong.dart';
import 'package:kachculator/pages/result_page.dart';
import 'package:kachculator/widgets/mp_widgets.dart';

class CooperStrongPage extends StatefulWidget {
  static String id = '/cooperStrong';

  @override
  _CooperStrongPageState createState() => _CooperStrongPageState();
}

class _CooperStrongPageState extends State<CooperStrongPage> {
  TextEditingController tcMinutes;
  bool errorMinutes;

  bool _validation() {
    if (tcMinutes.text.isEmpty || double.parse(tcMinutes.text) <= 0) {
      setState(() {
        errorMinutes = true;
      });
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    tcMinutes = TextEditingController(text: '4');
    errorMinutes = false;
  }

  @override
  Widget build(BuildContext context) {
    return mpScaffold(
      appBar: mpAppBar(
        title: Text(S.of(context).cooperStrongPageTitle),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 800.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  Text(S.of(context).cooperStrongPageDesc),
                  SizedBox(
                    height: 8.0,
                  ),
                  Container(
                    height: 360.0,
                    child: Image.asset(
                      'images/cooper.png',
                      fit: BoxFit.none,
                      //filterQuality: FilterQuality.low,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: mpTextField(
                      controller: tcMinutes,
                      labelText: S.of(context).cooperStrongMinutes,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  if (errorMinutes)
                    MpValidationMessage(
                      message: S.of(context).cooperStrongMinutesValidation,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 32.0, right: 32.0),
                    child: mpButton(
                      label: S.of(context).calculate,
                      onPressed: () {
                        if (_validation()) return null;
                        String res = '';
                        String force = cooperStrong(
                            context: context,
                            minutes: int.parse(tcMinutes.text));
                        res = '''
**${S.of(context).cooperMark}:** $force
''';
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResultPage(
                              result: res,
                              title: S.of(context).cooperStrongPageTitle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
