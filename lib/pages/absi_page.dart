import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kachculator/config.dart';
import 'package:kachculator/generated/l10n.dart';
import 'package:kachculator/calculators/calc.dart';
import 'package:kachculator/calculators/calc_absi.dart';
import 'package:kachculator/pages/result_page.dart';
import 'package:kachculator/widgets/mp_widgets.dart';

class AbsiPage extends StatefulWidget {
  static String id = '/absi';

  @override
  _AbsiPageState createState() => _AbsiPageState();
}

class _AbsiPageState extends State<AbsiPage> {
  TextEditingController tcWeight;
  TextEditingController tcHeight;
  TextEditingController tcWaistCircumference;
  TextEditingController tcAge;
  bool heightError;
  bool weightError;
  bool waistCircumferenceError;
  bool ageError;

  double bmi = 0;
  Gender gender;
  String result = '';
  bool isUS;

  bool _validation() {
    if (tcHeight.text.isEmpty || double.parse(tcHeight.text) <= 0) {
      setState(() {
        heightError = true;
      });
      return true;
    }
    if (tcWeight.text.isEmpty || double.parse(tcWeight.text) <= 0) {
      setState(() {
        weightError = true;
      });
      return true;
    }
    if (tcAge.text.isEmpty || double.parse(tcAge.text) <= 0) {
      setState(() {
        ageError = true;
      });
      return true;
    }
    if (tcWaistCircumference.text.isEmpty ||
        double.parse(tcWaistCircumference.text) <= 0) {
      setState(() {
        waistCircumferenceError = true;
      });
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    tcWeight = TextEditingController(text: '90');
    tcHeight = TextEditingController(text: '184');
    tcWaistCircumference = TextEditingController(text: '84');
    tcAge = TextEditingController(text: '41');
    gender = Gender.male;
    isUS =
        weightError = heightError = waistCircumferenceError = ageError = false;
  }

  @override
  Widget build(BuildContext context) {
    return mpScaffold(
      appBar: mpAppBar(title: Text(S.of(context).absiPageTitle)),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 800.0),
            padding: EdgeInsets.all(8.0),
            child: ListView(
              children: [
                // http://www.myhealthywaist.org/fileadmin/pdf/WCMG-Self-Measurement.pdf
                Text(S.of(context).absiPageDesc),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: mpTextField(
                    controller: tcWeight,
                    labelText: S.of(context).bmiWeight,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(demicalRegExp))
                    ],
                  ),
                ),
                if (weightError)
                  MpValidationMessage(
                    message: S.of(context).bmiWeightValidation,
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: mpTextField(
                    controller: tcHeight,
                    labelText: S.of(context).bmiHeight,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(demicalRegExp))
                    ],
                  ),
                ),
                if (heightError)
                  MpValidationMessage(
                    message: S.of(context).bmiHeightValidation,
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: mpTextField(
                    controller: tcWaistCircumference,
                    labelText: S.of(context).absiWaistCircumference,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(demicalRegExp))
                    ],
                  ),
                ),
                if (waistCircumferenceError)
                  MpValidationMessage(
                    message: S.of(context).absiWaistCircumferenceValidation,
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: mpTextField(
                    controller: tcAge,
                    labelText: S.of(context).age,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                if (ageError)
                  MpValidationMessage(
                    message: S.of(context).absiAgeValidation,
                  ),
                mpSelectFromTwo(
                  value1: Gender.female,
                  value2: Gender.male,
                  itemText1: S.of(context).female,
                  itemText2: S.of(context).male,
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                ),
                mpSwitch(
                  context: this.context,
                  title: S.of(context).useImperialUS,
                  value: isUS,
                  onChanged: (bool value) {
                    if (_validation()) return null;
                    setState(() {
                      isUS = value;
                      double weight = double.parse(tcWeight.text);
                      double height = double.parse(tcHeight.text);
                      double waistCircumference =
                          double.parse(tcWaistCircumference.text);
                      if (isUS) {
                        weight = kgToLbs(weight);
                        height = cmToInch(height);
                        waistCircumference = cmToInch(waistCircumference);
                      } else {
                        weight = lbsToKg(weight);
                        height = inchToCm(height);
                        waistCircumference = inchToCm(waistCircumference);
                      }
                      tcWeight.text = weight.toStringAsFixed(3);
                      tcHeight.text = height.toStringAsFixed(1);
                      tcWaistCircumference.text =
                          waistCircumference.toStringAsFixed(1);
                    });
                  },
                  onTap: () {
                    setState(() {
                      isUS = !isUS;
                    });
                  },
                ),
                mpButton(
                  label: S.of(context).calculate,
                  onPressed: () {
                    if (_validation()) return null;
                    double weight = double.parse(tcWeight.text);
                    double height = double.parse(tcHeight.text);
                    int age = int.parse(tcAge.text);
                    if (age > 85) age = 85;
                    double waistCircumference =
                        double.parse(tcWaistCircumference.text);

                    if (isUS) {
                      weight = lbsToKg(weight);
                      height = inchToCm(height);
                      waistCircumference = inchToCm(waistCircumference);
                    }

                    CalcABSI calc = CalcABSI(
                      context: context,
                      weightAthlete: weight,
                      heightAthleteCm: height,
                      gender: gender,
                      age: age,
                      waistCircumferenceCm: waistCircumference,
                    );

                    String sGender = (gender == Gender.male)
                        ? S.of(context).male
                        : S.of(context).female;
                    String res = """
**${S.of(context).age}:** $age

**${S.of(context).gender}**: $sGender

**${S.of(context).bmiHeight}**: $height

**${S.of(context).bmiPageTitle}**: ${calc.bmi.toStringAsFixed(3)}

**${S.of(context).absiWaistCircumference}**: $waistCircumference

**ABSI:** ${calc.absi.toStringAsFixed(5)}

**${S.of(context).absiMean}**: ${calc.absiMean.toStringAsFixed(5)}

**${S.of(context).absiRisk}**: ${calc.absiRisk}
"""; //
                    Navigator.push(
                      context,
                      mpPageRoute(
                        builder: (context) => ResultPage(
                          result: res,
                          title: S.of(context).absiPageTitle,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
